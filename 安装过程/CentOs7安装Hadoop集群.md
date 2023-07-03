## 1. 安装3台centos7服务器
### 1.1 配置名字hadoop01\hadoop02\hadoop03
`hostnamectl set-hostname hadoop01`
`hostnamectl set-hostname hadoop02`
`hostnamectl set-hostname hadoop03`
### 1.2 修改hosts文件
`vi /etc/hosts`
文件末尾添加以下内容：
```shell
hadoop01的ip地址 hadoop01
hadoop02的ip地址 hadoop02
hadoop03的ip地址 hadoop03
如
192.168.0.11    hadoop01
```
### 1.3 关闭防火墙
```shell
systemctl stop firewalld
```
```shell
systemctl disable firewalld
```
## 2. xshell点击工具，选择发送键输入到所有会话
### 2.1 **所有窗口状态改成NO(即同时输入命令到单个窗口)**
## 3. hadoop01输入以下命令
### 3.1做ssh 公私钥 无秘；中途直接回车
```shell
ssh-keygen -t rsa -P ''
```
### 3.2 copy公钥到hadoop02，hadoop03；输入yes，再输入密码
```shell
ssh-copy-id hadoop01
```
```shell
ssh-copy-id hadoop02
```
```shell
ssh-copy-id hadoop03
```
## 4. 测试以上操作是否成功
### 4.1 hadoop02，hadoop03分别输入以下命令
```shell
cd .ssh/
ls
```
![image.png](https://cdn.nlark.com/yuque/0/2023/png/12885594/1677567239412-a5780d9b-3d06-4378-910b-1f00fe996411.png#averageHue=%23dde1da&clientId=u79462fa3-f1a0-4&from=paste&id=u3012b81e&originHeight=161&originWidth=815&originalType=url&ratio=1&rotation=0&showTitle=false&size=95085&status=done&style=none&taskId=uaca5d6c9-cca3-467c-8b4e-ef807ce60dc&title=)
### 4.2 hadoop01输入以下命令
```shell
ssh hadoop02
ssh hadoop03
exit
```
![image.png](https://cdn.nlark.com/yuque/0/2023/png/12885594/1677567288626-3942820a-dab3-4818-913c-1e255b5e9349.png#averageHue=%23d0dacf&clientId=u79462fa3-f1a0-4&from=paste&id=u9ec3bd59&originHeight=206&originWidth=454&originalType=url&ratio=1&rotation=0&showTitle=false&size=115338&status=done&style=none&taskId=ua9868665-5e58-491c-ae77-39c17216206&title=)
## 5. 第2步的基础，hadoop02和hadoop03窗口状态改成OFF（命令输入到02 和03）
### 5.1 输入以下命令，和第3步一样
```shell
ssh-keygen -t rsa -P ''
```
### 5.2 copy公钥到hadoop02，hadoop03；输入yes，再输入密码
```shell
ssh-copy-id hadoop01
```
```shell
ssh-copy-id hadoop02
```
```shell
ssh-copy-id hadoop03
```
### 5.3 以上操作都完成后hadoop01，hadoop02和hadoop03的窗口状态都改成OFF，任意一个窗口按下ctrl+l
![image.png](https://cdn.nlark.com/yuque/0/2023/png/12885594/1677567655190-a0cd71c6-2ecf-4b86-8790-0027157a61f1.png#averageHue=%235c5b5b&clientId=u79462fa3-f1a0-4&from=paste&id=u05f647bd&originHeight=789&originWidth=1115&originalType=url&ratio=1&rotation=0&showTitle=false&size=82039&status=done&style=none&taskId=ueeb51e5a-d64d-4425-bbb2-cbfa7fa09fb&title=)
## 6. 安装chrony
```shell
yum -y install chrony
```
## 7. 安装wget
```shell
yum install -y gcc vim wget
```
## 8. 配置chrony
```shell
vim /etc/chrony.conf
```
### 8.1 文件添加如下内容，注释掉server 0.centos.pool.ntp.org iburst
![image.png](https://cdn.nlark.com/yuque/0/2023/png/12885594/1677567770667-e4724a77-6f56-4297-8488-28e7066a5af6.png#averageHue=%23f5efc3&clientId=u79462fa3-f1a0-4&from=paste&id=ue053dfd2&originHeight=522&originWidth=1033&originalType=url&ratio=1&rotation=0&showTitle=false&size=410195&status=done&style=none&taskId=u89831cc7-70e6-42af-8b3d-bfe782b02b3&title=)
```shell
server ntp1.aliyun.com 
server ntp2.aliyun.com 
server ntp3.aliyun.com
```
## 9. 启动chrony
```shell
systemctl start chronyd
```
## 10. 安装psmisc
```shell
yum install -y psmisc
```
## 11. 备份原始源
```shell
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
```
## 12. 下载源
```shell
wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
```
## 13. 清除缓存
```shell
yum clean all
yum makecache
```
## 14. 打开xftp，将jdk安装包分别拖到三台机器的opt文件夹下，然后执行以下命令，安装jdk
```shell
cd /opt
tar -zxf jdk-8u111-linux-x64.tar.gz
mkdir soft
mv jdk1.8.0_111/ soft/jdk180
```
### 14.1 配置环境变量
```shell
vim /etc/profile
```
```shell
#java env
export JAVA_HOME=/opt/soft/jdk180
export PATH=$JAVA_HOME/bin:$PATH
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
```
```shell
source /etc/profile
```
## 15.打开xftp，将zookeeper安装包分别拖到三台机器的opt文件夹下，然后执行以下命令，安装zookeeper
```shell
tar -zxf zookeeper-3.4.5-cdh5.14.2.tar.gz
```
```shell
mv zookeeper-3.4.5-cdh5.14.2 soft/zk345
```
### 15.1 修改zoo.cfg文件
```shell
cd soft/zk345/conf/
cp zoo_sample.cfg zoo.cfg
vim zoo.cfg
```
修改dataDir=/opt/soft/zk345/datas：
```shell
dataDir=/opt/soft/zk345/datas
```
文件末尾加上以下内容：
```shell
server.1=192.168.239.137:2888:3888 
server.2=192.168.239.141:2888:3888 
server.3=192.168.239.142:2888:3888
```
## 16. 创建datas文件夹
```shell
cd /opt/soft/zk345/
mkdir datas
```
## 17hadoop01，hadoop02和hadoop03的窗口状态都改成ON
### 17.1 hadoop01页面输入以下命令
```shell
cd datas
echo "1"> myid
cat myid
```
### 17.2 hadoop02页面输入以下命令
```shell
cd datas
echo "2"> myid
cat myid
```
### 17.3 hadoop03页面输入以下命令
```shell
cd datas
echo "3"> myid
cat myid
```
## 18. hadoop01，hadoop02和hadoop03的窗口状态都改成OFF
### 18.1 配置zookeeper运行环境
```shell
vim /etc/profile
```
```shell
#Zookeeper env
export ZOOKEEPER_HOME=/opt/soft/zk345
export PATH=$PATH:$ZOOKEEPER_HOME/bin
```
```shell
source /etc/profile
```
## 19. 启动zookeeper集群
```shell
zkServer.sh start
```
## 20. jps命令查看，必须要有进程QuorumPeerMain
```shell
jps
```
## 21. 打开xftp，将Hadoop安装包分别拖到三台机器的opt文件夹下，然后执行以下命令，安装Hadoop集群
```shell
cd /opt
tar -zxf hadoop-2.6.0-cdh5.14.2.tar.gz
mv hadoop-2.6.0-cdh5.14.2 soft/hadoop260
cd soft/hadoop260/etc/hadoop
```
### 21.1 添加对应各个文件夹
```shell
mkdir -p /opt/soft/hadoop260/tmp 
mkdir -p /opt/soft/hadoop260/dfs/journalnode_data 
mkdir -p /opt/soft/hadoop260/dfs/edits 
mkdir -p /opt/soft/hadoop260/dfs/datanode_data
mkdir -p /opt/soft/hadoop260/dfs/namenode_data
```
### 21.2 配置hadoop-env.sh
```shell
vim hadoop-env.sh
```
修改JAVA_HOME和HADOOP_CONF_DIR的值如下：
```shell
export JAVA_HOME=/opt/soft/jdk180 
export HADOOP_CONF_DIR=/opt/soft/hadoop260/etc/hadoop
```
### 21.3 配置core-site.xml，快捷键shift+G到文件末尾添加如下内容（注意改机器名！！！）
```shell
vim core-site.xml
```
```properties
<configuration> 
<!--指定hadoop集群在zookeeper上注册的节点名--> 
<property> 
<name>fs.defaultFS</name> 
<value>hdfs://hacluster</value> 
</property> 
<!--指定hadoop运行时产生的临时文件--> 
<property> 
<name>hadoop.tmp.dir</name> 
<value>file:///opt/soft/hadoop260/tmp</value> 
</property> 
<!--设置缓存大小 默认4KB--> <property> 
<name>io.file.buffer.size</name> 
<value>4096</value> 
</property> 
<!--指定zookeeper的存放地址--> 
<property> 
<name>ha.zookeeper.quorum</name> 
<value>hadoop01:2181,hadoop02:2181,hadoop03:2181</value> 
</property> 
<!--配置允许root代理访问主机节点--> 
<property> 
<name>hadoop.proxyuser.root.hosts</name>
<value>*</value> 
</property> 
<!--配置该节点允许root用户所属的组--> 
<property> 
<name>hadoop.proxyuser.root.groups</name> 
<value>*</value> 
</property> 
</configuration>
```
### 21.4 配置hdfs-site.xml，文件末尾添加如下内容（注意改机器名！！！）
```shell
vim hdfs-site.xml
```
```properties
<configuration> 
<property> 
<!--数据块默认大小128M--> 
<name>dfs.block.size</name> 
<value>134217728</value> 
</property> 
<property> 
<!--副本数量 不配置默认为3--> 
<name>dfs.replication</name> 
<value>3</value> 
</property> 
<property> 
<!--namenode节点数据(元数据)的存放位置--> 
<name>dfs.name.dir</name> 
<value>file:///opt/soft/hadoop260/dfs/namenode_data</value> 
</property> 
<property> 
<!--datanode节点数据(元数据)的存放位置--> 
<name>dfs.data.dir</name> 
<value>file:///opt/soft/hadoop260/dfs/datanode_data</value> 
</property>
<property>
<!--开启hdfs的webui界面--> 
<name>dfs.webhdfs.enabled</name> 
<value>true</value> 
</property> 
<property> 
<!--datanode上负责进行文件操作的线程数--> 
<name>dfs.datanode.max.transfer.threads</name> 
<value>4096</value> </property> 
<property> 
<!--指定hadoop集群在zookeeper上的注册名--> 
<name>dfs.nameservices</name> 
<value>hacluster</value> 
</property> 
<property> 
<!--hacluster集群下有两个namenode分别是nn1,nn2--> 
<name>dfs.ha.namenodes.hacluster</name> 
<value>nn1,nn2</value> 
</property> 
<!--nn1的rpc、servicepc和http通讯地址 --> 
<property> 
<name>dfs.namenode.rpc-address.hacluster.nn1</name> 
<value>hadoop01:9000</value> 
</property>
<property> 
<name>dfs.namenode.servicepc-address.hacluster.nn1</name> 
<value>hadoop01:53310</value> 
</property> 
<property> 
<name>dfs.namenode.http-address.hacluster.nn1</name> 
<value>hadoop01:50070</value> 
</property> 
<!--nn2的rpc、servicepc和http通讯地址 --> 
<property> 
<name>dfs.namenode.rpc-address.hacluster.nn2</name> 
<value>hadoop02:9000</value> 
</property> 
<property> 
<name>dfs.namenode.servicepc-address.hacluster.nn2</name> 
<value>hadoop02:53310</value> 
</property> 
<property> 
<name>dfs.namenode.http-address.hacluster.nn2</name> 
<value>hadoop02:50070</value> 
</property> 
<property> 
<!--指定Namenode的元数据在JournalNode上存放的位置--> 
<name>dfs.namenode.shared.edits.dir</name> 
<value>qjournal://hadoop01:8485;hadoop02:8485;hadoop03:8485/hacluster</value> 
</property> 
<property> 
<!--指定JournalNode在本地磁盘的存储位置--> 
<name>dfs.journalnode.edits.dir</name> 
<value>/opt/soft/hadoop260/dfs/journalnode_data</value> 
</property> 
<property> 
<!--指定namenode操作日志存储位置--> 
<name>dfs.namenode.edits.dir</name> 
<value>/opt/soft/hadoop260/dfs/edits</value> 
</property> 
<property> 
<!--开启namenode故障转移自动切换--> 
<name>dfs.ha.automatic-failover.enabled</name> 
<value>true</value> 
</property> 
<property> 
<!--配置失败自动切换实现方式--> 
<name>dfs.client.failover.proxy.provider.hacluster</name> 
<value>org.apache.hadoop.hdfs.server.namenode.ha.ConfiguredFailoverProxyProvider</value> 
</property> 
<property> 
<!--配置隔离机制--> 
<name>dfs.ha.fencing.methods</name> 
<value>sshfence</value> 
</property> 
<property> 
<!--配置隔离机制需要SSH免密登录--> 
<name>dfs.ha.fencing.ssh.private-key-files</name> 
<value>/root/.ssh/id_rsa</value>
</property> 
<property> 
<!--hdfs文件操作权限 false为不验证--> 
<name>dfs.premissions</name> 
<value>false</value> 
</property> 
</configuration>
```
### 21.5 配置mapred-site.xml，文件末尾添加如下内容（注意改机器名！！！）
```shell
cp mapred-site.xml.template mapred-site.xml
vim mapred-site.xml
```
```properties
<configuration> 
<property> 
<!--指定mapreduce在yarn上运行--> 
<name>mapreduce.framework.name</name> 
<value>yarn</value> 
</property> 
<property> 
<!--配置历史服务器地址--> 
<name>mapreduce.jobhistory.address</name> 
<value>hadoop01:10020</value> 
</property> 
<property> 
<!--配置历史服务器webUI地址--> 
<name>mapreduce.jobhistory.webapp.address</name> 
<value>hadoop01:19888</value> 
</property> 
<property> 
<!--开启uber模式--> 
<name>mapreduce.job.ubertask.enable</name> 
<value>true</value> 
</property> 
</configuration>
```
### 21.6 配置yarn-site.xml，文件末尾添加如下内容（注意改机器名！！！）
```shell
vim yarn-site.xml
```
```properties
<configuration> 
<property> 
<!--开启yarn高可用--> 
<name>yarn.resourcemanager.ha.enabled</name> 
<value>true</value> 
</property> 
<property> 
<!-- 指定Yarn集群在zookeeper上注册的节点名--> 
<name>yarn.resourcemanager.cluster-id</name> 
<value>hayarn</value> 
</property> 
<property> 
<!--指定两个resourcemanager的名称--> 
<name>yarn.resourcemanager.ha.rm-ids</name> 
<value>rm1,rm2</value> 
</property> 
<property> 
<!--指定rm1的主机--> 
<name>yarn.resourcemanager.hostname.rm1</name> 
<value>hadoop02</value> 
</property>
<property> 
<!--指定rm2的主机--> 
<name>yarn.resourcemanager.hostname.rm2</name> 
<value>hadoop03</value> 
</property> 
<property> 
<!--配置zookeeper的地址--> 
<name>yarn.resourcemanager.zk-address</name> 
<value>hadoop01:2181,hadoop02:2181,hadoop03:2181</value> 
</property> <property> 
<!--开启yarn恢复机制--> 
<name>yarn.resourcemanager.recovery.enabled</name> 
<value>true</value> 
</property> 
<property> 
<!--配置执行resourcemanager恢复机制实现类--> 
<name>yarn.resourcemanager.store.class</name> 
<value>org.apache.hadoop.yarn.server.resourcemanager.recovery.ZKRMStateStore</value> 
</property> 
<property> 
<!--指定主resourcemanager的地址--> 
<name>yarn.resourcemanager.hostname</name> 
<value>hadoop03</value> 
</property> 
<property> 
<!--nodemanager获取数据的方式--> 
<name>yarn.nodemanager.aux-services</name> 
<value>mapreduce_shuffle</value> 
</property> 
<property> 
<!--开启日志聚集功能--> 
<name>yarn.log-aggregation-enable</name> 
<value>true</value> 
</property> 
<property> 
<!--配置日志保留7天--> 
<name>yarn.log-aggregation.retain-seconds</name> 
<value>604800</value> 
</property> 
</configuration>
```
## 22. 配置slaves
```shell
vim slaves
```
### 22.1 快捷键dd删除localhost，添加如下内容
```shell
hadoop01
hadoop02
hadoop03
```
## 23. 配置hadoop环境变量
```shell
vim /etc/profile
```
```shell
#hadoop env
export HADOOP_HOME=/opt/soft/hadoop260 
export HADOOP_MAPRED_HOME=$HADOOP_HOME 
export HADOOP_COMMON_HOME=$HADOOP_HOME 
export HADOOP_HDFS_HOME=$HADOOP_HOME 
export YARN_HOME=$HADOOP_HOME 
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native 
export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin 
export HADOOP_INSTALL=$HADOOP_HOME
```
```shell
source /etc/profile
```
## 24. 启动Hadoop集群
### 24.1 输入以下命令
```shell
hadoop-daemon.sh start journalnode
```
### 24.2 输入jps命令，会发现多了一个进程JournalNode
```shell
jps
```
### 24.3 格式化namenode(只在hadoop01主机上)（hadoop02和hadoop03的窗口状态改成ON）
```shell
hdfs namenode -format
```
### 24.4 将hadoop01上的Namenode的元数据复制到hadoop02相同位置
```shell
scp -r /opt/soft/hadoop260/dfs/namenode_data/current/ root@hadoop02:/opt/soft/hadoop260/dfs/namenode_data
```
### 24.5 在hadoop01上格式化故障转移控制器zkfc
```shell
hdfs zkfc -formatZK
```
### 24.6 在hadoop01上启动dfs服务，再输入jps查看进程
```shell
start-dfs.sh
```
```shell
jps
```
![image.png](https://cdn.nlark.com/yuque/0/2023/png/12885594/1677569056592-f3bed9c2-4c47-4eb3-b21a-9c1aa5675992.png#averageHue=%23bec2bd&clientId=u79462fa3-f1a0-4&from=paste&id=ud874e8bc&originHeight=131&originWidth=251&originalType=url&ratio=1&rotation=0&showTitle=false&size=61421&status=done&style=none&taskId=uef569f8c-1ddd-450e-a8cb-43af9376646&title=)
### 24.7 在hadoop03上启动yarn服务，再输入jps查看进程
```shell
start-yarn.sh
```
```shell
jps
```
![image.png](https://cdn.nlark.com/yuque/0/2023/png/12885594/1677569093963-30b86fe8-73d4-4b56-9e82-d26858b05a22.png#averageHue=%23ccd8cb&clientId=u79462fa3-f1a0-4&from=paste&id=u233a6a85&originHeight=143&originWidth=218&originalType=url&ratio=1&rotation=0&showTitle=false&size=62798&status=done&style=none&taskId=u2ebaba90-26f3-40a0-a6fe-faadb119e24&title=)
### 24.8 在hadoop02上输入jps查看进程，如下图
![image.png](https://cdn.nlark.com/yuque/0/2023/png/12885594/1677569112569-c1fbf2e7-7d80-431a-8a62-5524c049a609.png#averageHue=%23eaebe6&clientId=u79462fa3-f1a0-4&from=paste&id=u3877247f&originHeight=151&originWidth=243&originalType=url&ratio=1&rotation=0&showTitle=false&size=61003&status=done&style=none&taskId=u2a6fe061-cbbc-4c53-b756-76fec6d3e1a&title=)
### 24.9 在hadoop01上启动history服务器，jps则会多了一个JobHistoryServer的进程
```shell
mr-jobhistory-daemon.sh start historyserver
```
```shell
jps
```
### 24.10 在hadoop02上启动resourcemanager服务，jps则会多了一个Resourcemanager的进程
```shell
yarn-daemon.sh start resourcemanager
```
```shell
jps
```
## 25. 检查集群情况
### 25.1 在hadoop01上查看服务状态，hdfs haadmin -getServiceState nn1则会对应显示active，nn2则显示standby
```shell
hdfs haadmin -getServiceState nn1
```
```shell
hdfs haadmin -getServiceState nn2
```
### 25.2 在hadoop03上查看resourcemanager状态，yarn rmadmin -getServiceState rm1则会对应显示standby，rm2则显示active
```shell
yarn rmadmin -getServiceState rm1
```
```shell
yarn rmadmin -getServiceState rm2
```
## 26. 浏览器输入IP地址:50070，对比以下图片
### 26.1 hadoop01的IP地址，注意查看是否为“active”
![image.png](https://cdn.nlark.com/yuque/0/2023/png/12885594/1677569236074-d43ef328-1f59-42ce-ba4f-067dd3f477ac.png#averageHue=%23f4f3f2&clientId=u79462fa3-f1a0-4&from=paste&id=u0245ca9c&originHeight=344&originWidth=745&originalType=url&ratio=1&rotation=0&showTitle=false&size=37824&status=done&style=none&taskId=u66b1bd93-9a46-45b4-9365-224df1e4908&title=)
### 26.2 hadoop02的IP地址，注意查看是否为“standby”
![image.png](https://cdn.nlark.com/yuque/0/2023/png/12885594/1677569265287-a6a4bb70-4152-42b6-908c-1db64e2129f4.png#averageHue=%23f5f4f3&clientId=u79462fa3-f1a0-4&from=paste&id=uc419cc68&originHeight=376&originWidth=679&originalType=url&ratio=1&rotation=0&showTitle=false&size=39837&status=done&style=none&taskId=u333c0c52-df25-4ebc-ac53-8e7299ef12d&title=)
### 26.3 最后选择上方的Datanodes，查看是否是三个节点，如何是，则高可用hadoop集群搭建成功！！！
![image.png](https://cdn.nlark.com/yuque/0/2023/png/12885594/1677569281817-a384227d-aa40-4458-9954-a49884036adc.png#averageHue=%23fafaf9&clientId=u79462fa3-f1a0-4&from=paste&id=uc0952956&originHeight=970&originWidth=1251&originalType=url&ratio=1&rotation=0&showTitle=false&size=105728&status=done&style=none&taskId=u2a2acde7-fe1c-4f59-a88d-f7296aa3e0a&title=)
