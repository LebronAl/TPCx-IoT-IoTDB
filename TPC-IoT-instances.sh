#!/bin/bash
# Usage: ./tpcx-iot-instances.sh 1000 4 100

# Usage check

echo ">>>>>>>>> entering instances"

counter=1
recordCount=$1
numInstances=$2
threadCount=$3
start=$4
clientID=$5
DATABASE_CLIENT=$6
PWD=$7
SUT_PARAMETERS=$8
RUN_TYPE=$9

operationCount=$((recordCount / numInstances))  # Improve this to be total of record count
echo "intance Operation: $operationCount"
#threadCount=$((totalThreadCount / numInstances))
echo "instance Tread: $threadCount"

while [ $counter -le $numInstances ]
do

echo $counter

cat << EOF | tee $PWD/tpc_iot_instance${counter}_workload
insertstart=$start
insertcount=$operationCount
recordcount=$recordCount
operationcount=$operationCount
workload=com.yahoo.ycsb.workloads.CoreWorkload
readallfields=true
readproportion=0.0
updateproportion=0.0
# scanproportion=0
insertproportion=1
threadcount=$threadCount
requestdistribution=uniform
EOF

#echo "./tpcx-iot/bin/tpcx-iot load basic -P ./tpc_iot_instance${counter}_workload -s > /dev/shm/large$counter.dat"
#nohup ./tpcx-iot/bin/tpcx-iot load basic -P ./tpc_iot_instance${counter}_workload -s > /dev/null &

echo "./tpcx-iot/bin/tpcx-iot run $DATABASE_CLIENT -P $PWD/tpc_iot_instance${counter}_workload -p $SUT_PARAMETERS -p client=$clientID${counter} -p runtype=$RUN_TYPE -s > $PWD/logs/db$RUN_TYPE$counter.dat &"
nohup $PWD/tpcx-iot/bin/tpcx-iot run $DATABASE_CLIENT -P $PWD/tpc_iot_instance${counter}_workload -p $SUT_PARAMETERS -p client=$clientID${counter} -p runtype=$RUN_TYPE -s > $PWD/logs/db$RUN_TYPE$counter.dat &
#nohup $PWD/tpcx-iot/bin/tpcx-iot run $DATABASE_CLIENT -P ./tpc_iot_instance${counter}_workload -p columnfamily=cf -s > $PWD/logs/db$counter.dat &
pids="$pids $!"

start=$((operationCount * counter))

((counter++))

done
echo "instaces pids = $pids"
wait $pids
echo All done

