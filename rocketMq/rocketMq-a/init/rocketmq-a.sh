#!/bin/bash
echo "关闭防火墙"
service firewalld stop

cd /data/rocketmq/rocketmq-a/bin

nohup ./mqnamesrv &

nohup ./mqbroker -c ../conf/2m-noslave/broker-a.properties &