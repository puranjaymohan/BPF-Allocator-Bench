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

if [[ ! -n $1 ]];
then
	echo "No command give in the parameters"
	CMD="perf stat -e iTLB-load-misses -a --timeout 6000"
	echo "will run ${CMD}"

	if ! command -v perf &> /dev/null
	then
		echo "perf could not be found"
		exit
	fi
else
	CMD="$1"
fi

if [[ ! -n $2 ]];
then
	NUM=20
else
	NUM=$2
fi

if ! command -v "${SCRIPTPATH}"/stress &> /dev/null
then
	echo "stress executable not found! Please run make"
	exit
fi

echo ""

echo "Starting ${NUM} instances of stress"
echo "This will load ${NUM}x8 eBPF programs and trigger ${NUM}x5 of them continuously"

for (( i=1; i<=$NUM; i++ ))
do
	("${SCRIPTPATH}"/stress > /dev/null 2>&1) &
done

echo ""
echo "Starting perf"
echo "going to run ${CMD}"

${CMD}

killall stress
