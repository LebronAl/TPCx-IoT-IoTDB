#!/bin/bash

#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#  @author Chinmayi Narasimhadevara
#  @author Karthik Kulkarni
#
#

shopt -s expand_aliases

source ./Benchmark_Parameters.sh
source ./Benchmark_Macros.sh

version="1.0.5"

#script assumes clush or pdsh
#unalias psh
if (type clush > /dev/null); then
  alias psh=clush
  alias dshbak=clubak
  CLUSTER_SHELL=1
elif (type pdsh > /dev/null); then
  CLUSTER_SHELL=1
  alias psh=pdsh
fi
parg="-a"

# Setting Color codes
green='\e[0;32m'
red='\e[0;31m'
yellow='\e[0;33m'
blue='\e[0;34m'
NC='\e[0m' # No Color

sep='==================================='
hssize=$DATABASE_RECORDS_COUNT
prefix="Records"

if [ -f ./TPCx-IoT-result-"$prefix".log ]; then
   mv ./TPCx-IoT-result-"$prefix".log ./TPCx-IoT-result-"$prefix".log.`date +%Y%m%d%H%M%S`
fi

echo "" | tee -a ./TPCx-IoT-result-"$prefix".log
echo -e "${green}Running $prefix test${NC}" | tee -a ./TPCx-IoT-result-"$prefix".log
echo -e "${green}IoT data size is $hssize${NC}" | tee -a ./TPCx-IoT-result-"$prefix".log
echo -e "${green}All Output will be logged to file ./TPCx-IoT-result-$prefix.log${NC}" | tee -a ./TPCx-IoT-result-"$prefix".log
echo "" | tee -a ./TPCx-IoT-result-"$prefix".log

## CLUSTER VALIDATE SUITE ##


if [ $CLUSTER_SHELL -eq 1 ]
then
   echo -e "${green}$sep${NC}" | tee -a ./TPCx-IoT-result-"$prefix".log
   echo -e "${green} Running Cluster Validation Suite${NC}" | tee -a ./TPCx-IoT-result-"$prefix".log
   echo -e "${green}$sep${NC}" | tee -a ./TPCx-IoT-result-"$prefix".log
   echo "" | tee -a ./TPCx-IoT-result-"$prefix".log
   echo "" | tee -a ./TPCx-IoT-result-"$prefix".log

   #source ./IoT_cluster_validate_suite.sh | tee -a ./TPCx-IoT-result-"$prefix".log

   echo "" | tee -a ./TPCx-IoT-result-"$prefix".log
   echo -e "${green} End of Cluster Validation Suite${NC}" | tee -a ./TPCx-IoT-result-"$prefix".log
   echo "" | tee -a ./TPCx-IoT-result-"$prefix".log
   echo "" | tee -a ./TPCx-IoT-result-"$prefix".log
else
   echo -e "${red}CLUSH NOT INSTALLED for cluster audit report${NC}" | tee -a ./TPCx-IoT-result-"$prefix".log
   echo -e "${red}To install clush follow USER_GUIDE.txt${NC}" | tee -a ./TPCx-IoT-result-"$prefix".log
fi

## IoT BENCHMARK SUITE ##
# Create Table
# Data Delete
# Workload Parameters for run
# Capture Results
# Capture Success/Failure
# Data Check -- on all database related queries
# Data Validate -- on both size of data and cluster
# Result -- Time/SF Number of operations

# Create the table in the database for the IoT workload to run against it.
echo -e "${green}Checking if the IoT Data Table exists already ${NC}" | tee -a ./TPCx-IoT-result-"$prefix".log
echo $CHECK_IF_TABLE_EXISTS | $SUT_SHELL > log
cat log | grep "Table $IOT_DATA_TABLE does exist"
if [ $? != 0 ]
then
echo $CREATE_TABLE | $SUT_SHELL
else
echo -e "${green}**** Table already exists, will not recreate *****" | tee -a ./TPCx-IoT-result-"$prefix".log
fi

rm log
rm driver_host_list.txt

# Get the number of clients and divide the records amongst the clients
if [ "$NUM_CLIENTS" -gt "1" ]; then
 echo -e "${green}Running $prefix test with $NUM_CLIENTS clients ${NC}" | tee -a ./TPCx-IoT-result-"$prefix".log
 num_records_per_client=$(echo "$DATABASE_RECORDS_COUNT/$NUM_CLIENTS" | bc)
 echo $num_records_per_client
else
 echo -e "${green}Running $prefix test with $NUM_CLIENTS client ${NC}" | tee -a ./TPCx-IoT-result-"$prefix".log
 num_records_per_client=$DATABASE_RECORDS_COUNT
fi
pids=""

# Create the configuration files for the number of records/operations per client
mkdir -p confFiles
PWD=$(pwd)
insertstart=0
for ((c=1; c<=$NUM_CLIENTS; c++))
do
    #echo $c
    cp ./tpcx-iot/workloads/workloadiot.template ./confFiles/workloadiot-$c
    echo "insertstart="$insertstart >> ./confFiles/workloadiot-$c
    echo "operationcount="$num_records_per_client >> ./confFiles/workloadiot-$c
    insertstart=$(echo "$insertstart+$num_records_per_client+1" | bc)
done
# remove any duplicates from the driver list
sort client_driver_host_list.txt | uniq >> driver_host_list.txt

j=1
for k in `cat driver_host_list.txt`;
do
scp ./confFiles/workloadiot-$j $k:$PWD/tpcx-iot/workloads/workloadiot
clush -w $k -B "rm -rf $PWD/logs"
clush -w $k -B "mkdir -p $PWD/logs"
j=$(echo $j+1 | bc)
done

for i in `seq 1 1 `;
do
benchmark_result=1
# Data Delete
echo -e "${green}$sep${NC}" | tee -a ./TPCx-IoT-result-"$prefix".log
echo -e "${green}Deleting Previous Data - Start - `date`${NC}" | tee -a ./TPCx-IoT-result-"$prefix".log
echo $TRUNCATE_TABLE | $SUT_SHELL

sleep $SLEEP_BETWEEN_RUNS
echo -e "${green}Deleting Previous Data - End - `date`${NC}" | tee -a ./TPCx-IoT-result-"$prefix".log
echo -e "${green}$sep${NC}" | tee -a ./TPCx-IoT-result-"$prefix".log
echo "" | tee -a ./TPCx-IoT-result-"$prefix".log
echo "" | tee -a ./TPCx-IoT-result-"$prefix".log

echo -e "${green}Warmup Run - Start - `date`${NC}" | tee -a ./TPCx-IoT-result-"$prefix".log
# Warmup Run for drivers
for k in `cat driver_host_list.txt`;
do
echo $k
clush -w $k -B "nohup $PWD/TPC-IoT-client.sh $WARMUP_RECORDS_COUNT $prefix $i $k $DATABASE_CLIENT $PWD $NUM_INSTANCES_PER_CLIENT $NUM_THREADS_PER_INSTANCE $SUT_PARAMETERS workloadiot warmup > $PWD/logs/IoT-Workload-run-time-warmup$i-$k.txt" &
pids="$pids $!"
done


echo "master file pids = $pids"
wait $pids
echo "All drivers have completed" | tee -a ./TPCx-IoT-result-"$prefix".log
echo -e "${green}Warmup Run - End - `date`${NC}" | tee -a ./TPCx-IoT-result-"$prefix".log
max=0
for k in `cat driver_host_list.txt`;
do
t=$(clush -w $k -B "grep 'Total Time' $PWD/logs/TPCx-IoT-result-$prefix-$k-warmup$i.log")
echo $t
n=$(echo $t|awk '{print $13}')
 if (( $(bc <<< "$n > $max") ))
 then
    max="$n"
 fi
done
echo $max
total_time_warmup_in_seconds=$max
# Delete data after warmup run
#echo $TRUNCATE_TABLE | $SUT_SHELL
#sleep 60
echo -e "${green}Measured Run - Start - `date`${NC}" | tee -a ./TPCx-IoT-result-"$prefix".log
pids=""
# Start the driver on each of the clients
for k in `cat driver_host_list.txt`;
do
echo $k
clush -w $k -B "nohup $PWD/TPC-IoT-client.sh $DATABASE_RECORDS_COUNT $prefix $i $k $DATABASE_CLIENT $PWD $NUM_INSTANCES_PER_CLIENT $NUM_THREADS_PER_INSTANCE $SUT_PARAMETERS workloadiot run > $PWD/logs/IoT-Workload-run-time-run$i-$k.txt" &
pids="$pids $!"
done
# Wait for all the clients to come back and get the max time from all the clients and use that for the metric.
echo "master file run pids = $pids"
wait $pids
echo "All drivers have completed" | tee -a ./TPCx-IoT-result-"$prefix".log
echo -e "${green}Measured Run - End - `date`${NC}" | tee -a ./TPCx-IoT-result-"$prefix".log
max=0
for k in `cat driver_host_list.txt`;
do
t=$(clush -w $k -B "grep 'Total Time' $PWD/logs/TPCx-IoT-result-$prefix-$k-run$i.log")
#echo $t
n=$(echo $t|awk '{print $13}')
 if (( $(bc <<< "$n > $max") ))
 then
    max="$n"
 fi
done
echo $max

# Data Check
echo "" | tee -a ./TPCx-IoT-result-"$prefix".log
echo "" | tee -a ./TPCx-IoT-result-"$prefix".log

start=`date +%s%3N`
echo -e "${green}Starting Data Validation ${NC}" | tee -a ./TPCx-IoT-result-"$prefix".log
repl=$(./IoTDataCheck.sh)
r="$((repl))"
if [ -z $repl ]; then
  echo -e "${red} Replication script does not produce any results. ${NC}" | tee -a ./TPCx-IoT-result-"$prefix".log
 #benchmark_result=0
else
  if [ $repl -lt 2 ]; then
   echo -e  "${red}Data Validation Failure === Replication factor is lower than 2 ${NC}" | tee -a ./TPCx-IoT-result-"$prefix".log
   benchmark_result=0
  else
   echo -e "${green}Data Validation Success === Replication factor is greater than or equal to 2 ${NC}" | tee -a ./TPCx-IoT-result-"$prefix".log
  fi
fi

echo "" | tee -a ./TPCx-IoT-result-"$prefix".log
echo "" | tee -a ./TPCx-IoT-result-"$prefix".log
echo -e "${green}Starting count of rows in table ${NC}"| tee -a ./TPCx-IoT-result-"$prefix".log

# source ./IoTDataRowCount.sh $i
# Get the row count from the database output and compare with the input size
#num_rows=$(cat logs/IoTValidate-time-run$i.txt | grep $ROW_COUNT | awk -F = '{print $2;}')
if [ "$num_rows" -lt "$DATABASE_RECORDS_COUNT" ]; then
 echo -e  "${red}Data Validation Failure === Run result is not ok, not all records were inserted row count is different ${NC}" | tee -a ./TPCx-IoT-result-"$prefix".log
 echo -e  "${yellow} - Inserted count :${NC} $num_rows" | tee -a ./TPCx-IoT-result-"$prefix".log
 echo -e  "${green} - Targeted count :${NC} $DATABASE_RECORDS_COUNT" | tee -a ./TPCx-IoT-result-"$prefix".log
 benchmark_result=0
else
 echo -e "${green}Data Validation Success === Run result is ok, $num_rows records are inserted  ${NC}" | tee -a ./TPCx-IoT-result-"$prefix".log
 echo -e  "${blue} - Inserted count :${NC} $num_rows" | tee -a ./TPCx-IoT-result-"$prefix".log
 echo -e  "${green} - Targeted count :${NC} $DATABASE_RECORDS_COUNT" | tee -a ./TPCx-IoT-result-"$prefix".log
fi

echo "" | tee -a ./TPCx-IoT-result-"$prefix".log
echo "" | tee -a ./TPCx-IoT-result-"$prefix".log

end=`date +%s%3N`
total_time_for_validation_in_seconds=`expr $end - $start`
total_time_for_validation=$(echo "scale=3;$total_time_for_validation_in_seconds/1000" | bc)
total_time_in_seconds="$(echo "scale=4;$max" | bc)"
# Check if the total time and warm up time are greater than 30 minutes
if  [[ "$benchmark_result" -eq "1" &&  $(bc <<< "$total_time_in_seconds < 1800") -eq 1 &&  $(bc <<< "$total_time_warmup_in_seconds < 1800") -eq 1 ]];
then
 echo -e "${red}$sep${NC}" | tee -a ./TPCx-IoT-result-"$prefix".log
 echo -e "${red}No Performance Metric (IoTps) as run time or warm up run time is less than 30 minutes ${NC}" | tee -a ./TPCx-IoT-result-"$prefix".log
 echo -e "${red}$sep${NC}" | tee -a ./TPCx-IoT-result-"$prefix".log
 benchmark_result=0
fi

benchmark_result=1

if (($benchmark_result == 1))
then
total_time_in_seconds="$(echo "scale=4;$max" | bc)"
#total_time_in_hour=$(echo "scale=4;$total_time_in_seconds/3600" | bc)
echo -e "${green}Test Run $i : Total Time In Seconds = $total_time_in_seconds ${NC}" | tee -a $PWD/TPCx-IoT-result-"$prefix".log
# Get the max time from a driver and divide by scale factor to get the metric
scale_factor=$hssize
perf_metric=$(echo "scale=4;$scale_factor/$total_time_in_seconds" | bc)
echo -e "${green}$sep============${NC}" | tee -a ./TPCx-IoT-result-"$prefix".log
echo "" | tee -a ./TPCx-IoT-result-"$prefix".log
echo -e "${green}md5sum of core components:${NC}" | tee -a ./TPCx-IoT-result-"$prefix".log
md5sum ./TPC-IoT-master.sh ./tpcx-iot/lib/core-0.13.0-SNAPSHOT.jar ./IoT_cluster_validate_suite.sh | tee -a $PWD/TPCx-IoT-result-"$prefix".log
echo "" | tee -a ./TPCx-IoT-result-"$prefix".log

echo -e "${green}$sep============${NC}" | tee -a ./TPCx-IoT-result-"$prefix".log
echo -e "${green}TPCx-IoT Performance Metric (IoTps) Report ${NC}" | tee -a ./TPCx-IoT-result-"$prefix".log
echo "" | tee -a ./TPCx-IoT-result-"$prefix".log
echo -e "${green}Test Run $i details : Total Time For Warmup Run In Seconds = $total_time_warmup_in_seconds ${NC}" | tee -a ./TPCx-IoT-result-"$prefix".log

echo -e "${green}Test Run $i details : Total Time In Seconds = $total_time_in_seconds ${NC}" | tee -a ./TPCx-IoT-result-"$prefix".log
echo -e "${green}                      Total Number of Records = $scale_factor ${NC}" | tee -a ./TPCx-IoT-result-"$prefix".log
echo "" | tee -a ./TPCx-IoT-result-"$prefix".log
echo -e "${green}TPCx-IoT Performance Metric (IoTps): $perf_metric ${NC}" | tee -a ./TPCx-IoT-result-"$prefix".log
echo "" | tee -a ./TPCx-IoT-result-"$prefix".log
echo -e "${green}$sep============${NC}" | tee -a ./TPCx-IoT-result-"$prefix".log
else
echo -e "${red}$sep${NC}" | tee -a ./TPCx-IoT-result-"$prefix".log
echo -e "${red}No Performance Metric (IoTps) as some tests Failed ${NC}" | tee -a ./TPCx-IoT-result-"$prefix".log
echo -e "${red}$sep${NC}" | tee -a ./TPCx-IoT-result-"$prefix".log

fi


done
