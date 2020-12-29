: << !
# create instances
aws ec2 run-instances \
--image-id ami-0ddeeb0bdb5987751 \
--instance-type t2.micro \
--count 1 \
--key-name txy \
--security-group-ids sg-c42e09ba \
--subnet-id subnet-14631a58 \
--tag-specifications 'ResourceType=instance,Tags=[{Key=tpc,Value=tpc}]' \
--network-interfaces 'AssociatePublicIpAddress=true,DeviceIndex=0' \
--placement 'GroupName = tpc'

# 存储优化 i3en.12xlarge 48核CPU 384G 内存 7.5T SSD * 4 50Gb网卡
# 计算优化 c5.metal 96核CPU 192G 内存 无SSD 25Gb网卡
# 存储优化 i3.metal：64核CPU 512G内存 1.5T SSD*8 50Gb网卡
# 存储优化 i3en.metal：96核CPU 768G内存 7T SSD*8 100Gb网卡


# get all public ips and private ips
export ips=`aws ec2 describe-instances --filters "Name=tag:tpc,Values=tpc" --query "Reservations[].Instances[].NetworkInterfaces[].PrivateIpAddresses[]"`
echo $ips


# terminate all instances
export instanceIds=`aws ec2 describe-instances --filters "Name=tag:tpc,Values=tpc" --query "Reservations[].Instances[].InstanceId"`
aws ec2 terminate-instances --instance-ids $instanceIds
!

# server info
server1PublicIP=18.191.183.228
server1PrivateIP=172.31.39.1
server2PublicIP=3.137.208.20
server2PrivateIP=172.31.33.70
# client info
tpc1PublicIP=3.17.204.232
# tpc2PublicIP=
# tpc3PublicIP=
# tpc2PrivateIP=
# tpc3PrivateIP=

# init server

ssh -i ~/Desktop/txy.pem ubuntu@$server1PublicIP "sudo mkfs -t xfs /dev/nvme1n1"
# ssh -i ~/Desktop/txy.pem ubuntu@$serverPublicIP "sudo mkfs -t ext4 /dev/nvme2n1"
# ssh -i ~/Desktop/txy.pem ubuntu@$serverPublicIP "sudo mkfs -t ext4 /dev/nvme3n1"
# ssh -i ~/Desktop/txy.pem ubuntu@$serverPublicIP "sudo mkfs -t ext4 /dev/nvme4n1"
ssh -i ~/Desktop/txy.pem ubuntu@$server1PublicIP "sudo mount -t xfs /dev/nvme1n1 /home/ubuntu/data/data1"
# ssh -i ~/Desktop/txy.pem ubuntu@$serverPublicIP "sudo mount -t ext4 /dev/nvme2n1 /home/ubuntu/data/data2"
# ssh -i ~/Desktop/txy.pem ubuntu@$serverPublicIP "sudo mount -t ext4 /dev/nvme3n1 /home/ubuntu/data/data3"
# ssh -i ~/Desktop/txy.pem ubuntu@$serverPublicIP "sudo mount -t ext4 /dev/nvme4n1 /home/ubuntu/data/data4"
ssh -i ~/Desktop/txy.pem ubuntu@$server1PublicIP "sudo chmod 777 /home/ubuntu/data/data1"
# ssh -i ~/Desktop/txy.pem ubuntu@$serverPublicIP "sudo chmod 777 /home/ubuntu/data/data2"
# ssh -i ~/Desktop/txy.pem ubuntu@$serverPublicIP "sudo chmod 777 /home/ubuntu/data/data3"
# ssh -i ~/Desktop/txy.pem ubuntu@$serverPublicIP "sudo chmod 777 /home/ubuntu/data/data4"
# sudo fdisk -l
# sudo df -h
# vim /etc/profile and ~/.bashrc change jdk from 8 to 11
ssh -i ~/Desktop/txy.pem ubuntu@$server2PublicIP "sudo mkfs -t xfs /dev/nvme1n1"
ssh -i ~/Desktop/txy.pem ubuntu@$server2PublicIP "sudo mount -t xfs /dev/nvme1n1 /home/ubuntu/data/data1"
ssh -i ~/Desktop/txy.pem ubuntu@$server2PublicIP "sudo chmod 777 /home/ubuntu/data/data1"


ssh -i ~/Desktop/txy.pem ubuntu@$server1PublicIP "sudo chmod 777 /etc/hosts && sudo echo '$server1PrivateIP server1' >> /etc/hosts && sudo echo '$server2PrivateIP server2' >> /etc/hosts"
ssh -i ~/Desktop/txy.pem ubuntu@$server2PublicIP "sudo chmod 777 /etc/hosts && sudo echo '$server2PrivateIP server1' >> /etc/hosts && sudo echo '$server1PrivateIP server2' >> /etc/hosts"


#init tpc1
# ssh -i ~/Desktop/txy.pem ubuntu@$tpc1PublicIP "sudo chmod 777 /etc/hosts && sudo echo '$serverPrivateIP server1' >> /etc/hosts"
ssh -i ~/Desktop/txy.pem ubuntu@$tpc1PublicIP "sudo chmod 777 /etc/hosts && sudo echo '$server1PrivateIP server1' >> /etc/hosts && sudo echo '$tpc2PrivateIP tpc2' >> /etc/hosts && sudo echo '$tpc3PrivateIP tpc3' >> /etc/hosts"

#init tpc2 and tpc3
# ssh -i ~/Desktop/txy.pem ubuntu@$tpc2PublicIP "sudo chmod 777 /etc/hosts && sudo echo '$server1PrivateIP server1' >> /etc/hosts"
# ssh -i ~/Desktop/txy.pem ubuntu@$tpc3PublicIP "sudo chmod 777 /etc/hosts && sudo echo '$server1PrivateIP server1' >> /etc/hosts"


# 600G

# ===============================================
# TPCx-IoT Performance Metric (IoTps) Report

# Test Run 1 details : Total Time For Warmup Run In Seconds = 225.401
# Test Run 1 details : Total Time In Seconds = 207.147
#                       Total Number of Records = 300000000

# TPCx-IoT Performance Metric (IoTps): 1448246.8971

# ===============================================

# ===============================================
# TPCx-IoT Performance Metric (IoTps) Report

# Test Run 1 details : Total Time For Warmup Run In Seconds = 308.716
# Test Run 1 details : Total Time In Seconds = 273.599
#                       Total Number of Records = 300000000

# TPCx-IoT Performance Metric (IoTps): 1096495.2357



#  Raft member(sender) - compete for log manager before commit: 43760840.19, 7626739, 5.74
#          Raft member(sender) - commit log in log manager: 236865.61, 7626739, 0.03
#            Raft member(sender) - get logs to be committed: 5540.49, 6368968, 0.00
#            Raft member(sender) - delete logs exceeding capacity: 115.25, 761, 0.15
#            Raft member(sender) - append and stable committed logs: 6295.56, 6368969, 0.00
#            Raft member(sender) - apply after committing logs: 201864.49, 6368969, 0.03
#              Raft member(sender) - provide log to consumer: 191700.71, 7626716, 0.03
#              Raft member(sender) - apply logs that cannot run in parallel: 0.00, 0, NaN
#          Raft member(sender) - wait until log is applied: 4677366.20, 7626742, 0.61
#            Raft member(sender) - in apply queue: 3944666.84, 7626716, 0.52
#            Raft member(sender) - apply data log: 1207017.88, 7626715, 0.16
#        Raft member(sender) - log from create to accept: 133048.03, 7626796, 0.02
#     Data group member - wait for leader: 0.00, 0, NaN
#     Data group member - forward to leader: 0.00, 0, NaN
#     Log dispatcher - in queue: 0.00, 0, NaN
#     Log dispatcher - from create to end: 0.00, 0, NaN
#   Meta group member - execute in remote group: 0.00, 0, NaN
#  Raft member(receiver) - index diff: 0.00, 0, NaN


# ===============================================
# TPCx-IoT Performance Metric (IoTps) Report

# Test Run 1 details : Total Time For Warmup Run In Seconds = 318.585
# Test Run 1 details : Total Time In Seconds = 272.661
#                       Total Number of Records = 300000000

# TPCx-IoT Performance Metric (IoTps): 1100267.3649

# ===============================================

#   Meta group member - execute in local group: 84559242.10, 20030128, 4.22
#     Data group member - execute locally: 84536814.47, 20030128, 4.22
#        Raft member(sender) - compete for log manager before append: 52835595.82, 20030148, 2.64
#        Raft member(sender) - locally append log: 25630.28, 20030148, 0.00
#        Raft member(sender) - build SendLogRequest: 27023.41, 20030148, 0.00
#          Raft member(sender) - build AppendEntryRequest: 18420.37, 20030148, 0.00
#        Raft member(sender) - offer log to dispatcher: 131040.48, 20030148, 0.01
#          Raft member(sender) - sender wait for prev log: 0.00, 0, NaN
#          Raft member(sender) - serialize logs: 0.00, 0, NaN
#          Raft member(sender) - send log: 0.00, 0, NaN
#          Raft member(receiver) - log parse: 0.00, 0, NaN
#          Raft member(receiver) - receiver wait for prev log: 0.00, 0, NaN
#          Raft member(receiver) - append entrys: 0.00, 0, NaN
#        Raft member(sender) - wait for votes: 2991.80, 20030148, 0.00
#        Raft member(sender) - locally commit log(using dispatcher): 31403843.65, 20024787, 1.57
#          Raft member(sender) - compete for log manager before commit: 30203369.65, 20030148, 1.51
#          Raft member(sender) - commit log in log manager: 231447.63, 20030148, 0.01
#            Raft member(sender) - get logs to be committed: 11258.48, 17422684, 0.00
#            Raft member(sender) - delete logs exceeding capacity: 142.95, 2002, 0.07
#            Raft member(sender) - append and stable committed logs: 13046.12, 17422684, 0.00
#            Raft member(sender) - apply after committing logs: 155368.90, 17422684, 0.01
#              Raft member(sender) - provide log to consumer: 135179.80, 20030128, 0.01
#              Raft member(sender) - apply logs that cannot run in parallel: 0.00, 0, NaN
#          Raft member(sender) - wait until log is applied: 979851.88, 20030148, 0.05
#            Raft member(sender) - put into apply queue for each log: 116498.75, 20030128, 0.01
#            Raft member(sender) - take from apply queue for each log: 11334749.92, 20030128, 0.57
#            Raft member(sender) - in apply queue: 531902.81, 20030128, 0.03
#            Raft member(sender) - apply data log: 516755.29, 20030128, 0.03
#        Raft member(sender) - log from create to accept: 171948.52, 20030148, 0.01
#     Data group member - wait for leader: 0.00, 0, NaN
#     Data group member - forward to leader: 0.00, 0, NaN
#     Log dispatcher - in queue: 0.00, 0, NaN
#     Log dispatcher - from create to end: 0.00, 0, NaN
#   Meta group member - execute in remote group: 0.00, 0, NaN
#  Raft member(receiver) - index diff: 0.00, 0, NaN
# }

# Test Run 1 details : Total Time For Warmup Run In Seconds = 554.183
# Test Run 1 details : Total Time In Seconds = 530.346
#                       Total Number of Records = 30000000

# TPCx-IoT Performance Metric (IoTps): 56566.8450

# ===============================================

#   Meta group member - execute in local group: 196760.86, 1997438, 0.10
#     Data group member - execute locally: 195476.19, 1997438, 0.10
#        Raft member(sender) - compete for log manager before append: 3353.47, 1997440, 0.00
#        Raft member(sender) - locally append log: 24153.29, 1997440, 0.01
#        Raft member(sender) - build SendLogRequest: 2341.55, 1997440, 0.00
#          Raft member(sender) - build AppendEntryRequest: 1428.71, 1997440, 0.00
#        Raft member(sender) - offer log to dispatcher: 19303.03, 1997440, 0.01
#          Raft member(sender) - sender wait for prev log: 0.00, 0, NaN
#          Raft member(sender) - serialize logs: 0.00, 0, NaN
#          Raft member(sender) - send log: 0.00, 0, NaN
#          Raft member(receiver) - log parse: 0.00, 0, NaN
#          Raft member(receiver) - receiver wait for prev log: 0.00, 0, NaN
#          Raft member(receiver) - append entrys: 0.00, 0, NaN
#        Raft member(sender) - wait for votes: 313.62, 1997440, 0.00
#        Raft member(sender) - locally commit log(using dispatcher): 142679.18, 1997122, 0.07
#          Raft member(sender) - compete for log manager before commit: 901.45, 1997440, 0.00
#          Raft member(sender) - commit log in log manager: 28716.65, 1997440, 0.01
#            Raft member(sender) - get logs to be committed: 1134.55, 1997281, 0.00
#            Raft member(sender) - delete logs exceeding capacity: 29.83, 198, 0.15
#            Raft member(sender) - append and stable committed logs: 1448.18, 1997281, 0.00
#            Raft member(sender) - apply after committing logs: 24405.28, 1997281, 0.01
#              Raft member(sender) - provide log to consumer: 22539.37, 1997438, 0.01
#              Raft member(sender) - apply logs that cannot run in parallel: 0.00, 0, NaN
#          Raft member(sender) - wait until log is applied: 112148.26, 1997440, 0.06
#            Raft member(sender) - put into apply queue for each log: 20562.47, 1997438, 0.01
#            Raft member(sender) - take from apply queue for each log: 2101147.41, 1997438, 1.05
#            Raft member(sender) - in apply queue: 47352.18, 1997438, 0.02
#            Raft member(sender) - apply data log: 59835.00, 1997438, 0.03
#        Raft member(sender) - log from create to accept: 20123.78, 1997440, 0.01
#     Data group member - wait for leader: 0.00, 0, NaN
#     Data group member - forward to leader: 0.00, 0, NaN
#     Log dispatcher - in queue: 0.00, 0, NaN
#     Log dispatcher - from create to end: 0.00, 0, NaN
#   Meta group member - execute in remote group: 0.00, 0, NaN
#  Raft member(receiver) - index diff: 0.00, 0, NaN
# }

#   Meta group member - execute in local group: 50706.48, 659358, 0.08
#     Data group member - execute locally: 50353.64, 659358, 0.08
#        Raft member(sender) - compete for log manager before append: 982.12, 659360, 0.00
#        Raft member(sender) - locally append log: 8722.18, 659360, 0.01
#        Raft member(sender) - build SendLogRequest: 781.32, 659360, 0.00
#          Raft member(sender) - build AppendEntryRequest: 484.29, 659360, 0.00
#        Raft member(sender) - offer log to dispatcher: 6815.02, 659360, 0.01
#          Raft member(sender) - sender wait for prev log: 0.00, 0, NaN
#          Raft member(sender) - serialize logs: 0.00, 0, NaN
#          Raft member(sender) - send log: 0.00, 0, NaN
#          Raft member(receiver) - log parse: 0.00, 0, NaN
#          Raft member(receiver) - receiver wait for prev log: 0.00, 0, NaN
#          Raft member(receiver) - append entrys: 0.00, 0, NaN
#        Raft member(sender) - wait for votes: 106.87, 659360, 0.00
#        Raft member(sender) - locally commit log(using dispatcher): 31813.19, 659042, 0.05
#          Raft member(sender) - compete for log manager before commit: 238.27, 659360, 0.00
#          Raft member(sender) - commit log in log manager: 6581.58, 659360, 0.01
#            Raft member(sender) - get logs to be committed: 433.15, 659285, 0.00
#            Raft member(sender) - delete logs exceeding capacity: 7.17, 64, 0.11
#            Raft member(sender) - append and stable committed logs: 475.15, 659285, 0.00
#            Raft member(sender) - apply after committing logs: 5143.75, 659285, 0.01
#              Raft member(sender) - provide log to consumer: 4573.27, 659358, 0.01
#              Raft member(sender) - apply logs that cannot run in parallel: 0.00, 0, NaN
#          Raft member(sender) - wait until log is applied: 24753.79, 659360, 0.04
#            Raft member(sender) - put into apply queue for each log: 3764.57, 659358, 0.01
#            Raft member(sender) - take from apply queue for each log: 710344.19, 659358, 1.08
#            Raft member(sender) - in apply queue: 5760.64, 659358, 0.01
#            Raft member(sender) - apply data log: 14264.55, 659358, 0.02
#        Raft member(sender) - log from create to accept: 7079.89, 659360, 0.01
#     Data group member - wait for leader: 0.00, 0, NaN
#     Data group member - forward to leader: 0.00, 0, NaN
#     Log dispatcher - in queue: 0.00, 0, NaN
#     Log dispatcher - from create to end: 0.00, 0, NaN
#   Meta group member - execute in remote group: 0.00, 0, NaN
#  Raft member(receiver) - index diff: 0.00, 0, NaN
# }


