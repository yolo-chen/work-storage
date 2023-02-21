#!/bin/bash
echo "关闭防火墙"
service firewalld stop

cd /data/rocketmq/rocketmq-b/bin

nohup ./mqnamesrv &

nohup ./mqbroker -c ../conf/2m-noslave/broker-b.properties &