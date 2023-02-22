## 项目启动命令
```shell
#!/bin/bash
source /etc/profile
echo "更新APICENTER_PLATFORM项目..."

tomcatDir=/data/wujing/service
projectName=base_platform.jar

#创建备份目录
cd $tomcatDir/platform/bak/
dd=$(date '+%Y-%m-%d' )
if [ ! -d $dd  ];then
  mkdir $dd
else
  echo "dir exist"
fi

#停服务
echo "停服务..."
#service pet stop
#sleep 3
#服务不能正常停止的，kill掉
TomcatID=$(ps -ef |grep $tomcatDir/platform/$projectName |grep -v 'grep'|awk '{print $2}')
if [ "${TomcatID}" != "" ]; then
   kill -9 $TomcatID
   echo "kill plat server, PID:${TomcatID}"
fi

#echo "启动服务..."
#service pet start
chmod u+x $tomcatDir/platform/$projectName
nohup java -jar  $tomcatDir/platform/$projectName > $tomcatDir/platform/start/log.txt 2>&1 &

#备份包
echo "备份包..."
cd $tomcatDir/platform/
cp -f $projectName bak/$dd/

#部署新服务
#echo "部署新包..."
#mv -f $tomcatDir/$projectName $tomcatDir/platform/$projectName

#授权
#chmod u+x $tomcatDir/platform/$projectName



# 等待30秒后请求自动化测试地址
#sleep 60
#curl 'http://http://20.21.1.113:9090/jenkins/buildByToken/build?job=pet_v4&token=a14b3285-ea9b-4f67-8edc-be56005a3873'
```
## 中间件初始化命令
```shell
#!/bin/bash
echo "关闭防火墙"
service firewalld stop

echo "启动mysql"
service mysqld restart

echo "启动redis"
cd /data/redis/redis-5.0.14/redis_cluster
redis-server 7001/redis.conf
redis-server 7002/redis.conf
redis-server 7003/redis.conf

echo "启动nginx"
cd /usr/local/nginx
./sbin/nginx -c conf/nginx.conf

echo "启动minio"
cd /data/minio/
./run.sh

echo "启动 nacos"
cd /data/nacos/nacos/bin
./startup.sh

```
```shell
#!/bin/bash
echo "关闭防火墙"
service firewalld stop

cd /data/rocketmq/rocketmq-a/bin

nohup ./mqnamesrv &

nohup ./mqbroker -c ../conf/2m-noslave/broker-a.properties &
```
