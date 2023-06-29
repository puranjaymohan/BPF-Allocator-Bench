#!/bin/bash

SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

CMD="perf stat -e ITLB_WALK,L1I_TLB,INST_RETIRED,iTLB-load-misses -a --timeout 30000"

echo "sno, ITLB_WALK, L1I_TLB, INST_RETIRED, iTLB-load-misses, seconds" > data.csv

for i in {1..40}
do
        echo "Iteration ${i}"

        "${SCRIPTPATH}"/run.sh "${CMD}" "${i}" 2> out.log;

        data1=$(grep "ITLB_WALK" out.log | awk -F" " '{print $1}')

        data2=$(grep "L1I_TLB" out.log | awk -F" " '{print $1}')

        data3=$(grep "INST_RETIRED" out.log | awk -F" " '{print $1}')

	data4=$(grep "iTLB-load-misses" out.log | awk -F" " '{print $1}')

	data5=$(grep "seconds" out.log | awk -F" " '{print $1}')

	echo "$i, $data1, $data2, $data3, $data4, $data5" >> data.csv

        rm out.log
done
