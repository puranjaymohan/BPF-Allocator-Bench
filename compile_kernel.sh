#!/bin/bash

SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

echo $SCRIPT

trap  "{ killall stress; exit; }" SIGINT SIGTERM EXIT ERR

if [ "$EUID" -ne 0 ]
then
	echo "Please run with root!"
	exit
fi

CMD="perf stat -e ITLB_WALK,L1I_TLB,INST_RETIRED,iTLB-load-misses -a make -j64"

if ! command -v "${SCRIPTPATH}"/stress &> /dev/null
then
	echo "stress executable not found! Please run make in BPF-Allocator-Bench"
	exit
fi

echo "Cloning linux kernel"
git clone https://github.com/amazonlinux/linux.git --depth=1 --branch=amazon-6.1.y/mainline
cd linux
git checkout 1c62d571b500f3bd92da1b5402ed9cb85d93deb4
echo ""

echo "Starting 20 instances of stress"
echo "This will load 160 eBPF programs and trigger 100 of them continuously"

for i in {1..20}
do
	("${SCRIPTPATH}"/stress > /dev/null 2>&1) &
done

echo ""
echo "Starting the stresser"

for i in {1..100}
do
	echo "Iteration ${i}"

	make distclean
	make defconfig
	${CMD} 2> out.log

	grep "ITLB_WALK" out.log | awk -F" " '{print $1}' >> ITLB_WALK.log
	grep "L1I_TLB" out.log | awk -F" " '{print $1}' >> L1I_TLB.log
	grep "INST_RETIRED" out.log | awk -F" " '{print $1}' >> INST_RETIRED.log
	grep "iTLB-load-misses" out.log | awk -F" " '{print $1}' >> iTLB-load-misses.log
	grep "seconds" out.log | awk -F" " '{print $1}' >> seconds.log

	rm out.log
done

killall stress
