#!/bin/bash

echo "Enter client file"

DATABASE_RECORDS_COUNT=$1
prefix=$2
i=$3
clientId=$4
DATABASE_CLIENT=$5
PWD=$6
NUM_INSTANCES=$7
NUM_THREADS=$8
#echo $NUM_THREADS
SUT_PARAMETERS=$9
WORKLOAD=${10}
LOGFILE_NAME=${11}

mkdir -p $PWD/logs
start=`date +%s%3N`


echo -e "${green}$sep${NC}" | tee -a $PWD/logs/TPCx-IoT-result-"$prefix"-"$clientId-$LOGFILE_NAME$i".log
echo -e "${green} Running TPCx-IoT Benchmark Suite - Run $i - Epoch $start ${NC}" | tee -a $PWD/logs/TPCx-IoT-result-"$prefix"-"$clientId-$LOGFILE_NAME$i".log
echo -e "${green} TPCx-IoT Version ${version} ${NC}" | tee -a $PWD/logs/TPCx-IoT-result-"$prefix"-"$clientId-$LOGFILE_NAME$i".log
echo -e "${green}$sep${NC}" | tee -a $PWD/logs/TPCx-IoT-result-"$prefix"-"$clientId-$LOGFILE_NAME$i".log
echo "" | tee -a $PWD/logs/TPCx-IoT-result-"$prefix"-"$clientId-$LOGFILE_NAME$i".log
echo -e "${green}Starting IoT Run $i output being return to $PWD/logs/IoT-run-time-$LOGFILE_NAME$i.txt ${NC}" | tee -a $PWD/logs/TPCx-IoT-result-"$prefix"-"$clientId-$LOGFILE_NAME$i".log
echo "" | tee -a $PWD/logs/TPCx-IoT-result-"$prefix"-"$clientId-$LOGFILE_NAME$i".log

# Command for running workload IoT based on the YCSB params

start_string=`grep insertstart $PWD/tpcx-iot/workloads/$WORKLOAD`
INSERT_START=$(echo $start_string | cut -d'=' -f2)
operation_count_string=`grep operationcount $PWD/tpcx-iot/workloads/$WORKLOAD`
DATABASE_RECORDS_COUNT=$(echo $operation_count_string | cut -d'=' -f2)
# Invoke the instance.sh here. 

echo ">>>>>>>> $PWD/TPC-IoT-instances.sh $DATABASE_RECORDS_COUNT $NUM_INSTANCES $NUM_THREADS $INSERT_START $clientId $DATABASE_CLIENT $LOGFILE_NAME"
$PWD/TPC-IoT-instances.sh $DATABASE_RECORDS_COUNT $NUM_INSTANCES $NUM_THREADS $INSERT_START $clientId $DATABASE_CLIENT $PWD $SUT_PARAMETERS $LOGFILE_NAME

#  Command for running workload IoT based on the YCSB params
#(time  $PWD/tpcx-iot/bin/tpcx-iot run $DATABASE_CLIENT -P $PWD/tpcx-iot/workloads/$WORKLOAD -p columnfamily=cf -p recordcount=$DATABASE_RECORDS_COUNT -p client=$clientId -threads $NUM_THREADS) 2> >(tee $PWD/logs/IoT-Workload-run-time-$LOGFILE_NAME$i.txt)

result=$?

if [ $result -ne 0 ]; then
 echo -e "${red}======== Error while executing run command database table IoT Workload Result FAILURE========${NC}" | tee -a $PWD/logs/TPCx-IoT-result-"$prefix"-"$clientId-$LOGFILE_NAME$i".log
 benchmark_result=0
else
 echo -e "${green}Run Result SUCCESS===All records can be queried and inserted ${NC}" | tee -a $PWD/logs/TPCx-IoT-result-"$prefix"-"$clientId-$LOGFILE_NAME$i".log
fi
cat $PWD/logs/IoT-Workload-run-time-$LOGFILE_NAME$i-$clientId.txt >> $PWD/logs/TPCx-IoT-result-"$prefix"-"$clientId-$LOGFILE_NAME$i".log

# Capture Results
 # Capture Success/Failure
 # TODO :: Code for capturing results success and failure and log them back to the workload log file
echo "" | tee -a $PWD/logs/TPCx-IoT-result-"$prefix"-"$clientId-$LOGFILE_NAME$i".log
echo "" | tee -a $PWD/logs/TPCx-IoT-result-"$prefix"-"$clientId-$LOGFILE_NAME$i".log
echo -e "${green}======== Workload IoT Run Result SUCCESS ========${NC}" | tee -a $PWD/logs/TPCx-IoT-result-"$prefix"-"$clientId-$LOGFILE_NAME$i".log
echo -e "${green}======== Time taken by Workload IoT = `grep real $PWD/logs/IoT-Workload-run-time-$LOGFILE_NAME$i-$clientId.txt | awk '{print $2}'`====${NC}" | tee -a $PWD/logs/TPCx-IoT-result-"$prefix"-"$clientId-$LOGFILE_NAME$i".log
echo "" | tee -a $PWD/logs/TPCx-IoT-result-"$prefix"-"$clientId-$LOGFILE_NAME$i".log
echo "" | tee -a $PWD/logs/TPCx-IoT-result-"$prefix"-"$clientId-$LOGFILE_NAME$i".log
end=`date +%s%3N`

total_time=`expr $end - $start`
total_time_in_seconds=$(echo "scale=3;$total_time/1000" | bc)
echo -e "${green}Test Run $i on $clientId details: Total Time = $total_time_in_seconds ${NC}" | tee -a $PWD/logs/TPCx-IoT-result-"$prefix"-"$clientId-$LOGFILE_NAME$i".log
