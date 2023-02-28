# **集群部署OpenSearch&&OpenSearch-Dashboard**

## 1. 下载安装包

```http
https://www.opensearch.org/downloads.html
```

## 2. 初始化系统

### 1. 集群服务器信息

| 节点服务 | ip           |
| -------- | ------------ |
| node1    | 192.168.1.11 |
| node2    | 192.168.1.12 |

### 1. 文件系统

节点服务器创建文件  app(opensearch,opensearch-dashboard安装目录)，logs(日志目录)，data(opensearch数据目录)

```bash
mkdir /opt/opensearch/{app,logs,data}
```

### 2. 解压安装包

```bash
tar -xzvf opensearch-1.3.5-linux-x64.tar.gz -C /opt/opensearch/app
tar -xzvf opensearch-dashboards-1.3.5-linux-x64.tar.gz -C /opt/opensearch/app
```

### 3. 修改linux内核参数

```bash
vim /etc/sysctl.conf
vm.max_map_count=262144
sudo sysctl -p
```

### 4. 调整opensearch内存参数

```bash
vim /opt/opensearch/app/opensearch-1.3.5/config/jvm.option

-Xms9g
-Xmx9g
```

### 5. 创建opensearch用户

```bash
useradd opensearch
chown opensearch:opensearch /opt/opensearch/*
```

### 6. 修改打开文件数

修改 **/etc/security/limits.d/20-nproc.conf** , ***20-nproc.conf***  不存在修改    **/etc/security/limits.conf**

```bash
vim /etc/security/limits.d/20-nproc.conf

opensearch soft nofile 65536
opensearch hard nofile 65536
opensearch soft nproc 65536
opensearch hard nproc 65536
opensearch soft memlock unlimited
opensearch hard memlock unlimited
```

```bash
vim /etc/security/limits.conf

opensearch soft nofile 65536
opensearch hard nofile 65536
opensearch soft nproc 65536
opensearch hard nproc 65536
opensearch soft memlock unlimited
opensearch hard memlock unlimited
```

### 7. 创建opensearch 运行unit

```bash
cat >/lib/systemd/system/opensearch.service <<-\EOF
[Unit]
Description=OpenSearch
Documentation=https://opensearch.org
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
RuntimeDirectory=opensearch
PrivateTmp=true
User=opensearch
Group=opensearch
Environment=OPENSEARCH_HOME=/opt/opensearch/app/opensearch-1.3.5
Environment=OPENSEARCH_PATH_CONF=/opt/opensearch/app/opensearch-1.3.5/config
Environment=OPENSEARCH_STARTUP_SLEEP_TIME=5
Environment=OPENSEARCH_SD_NOTIFY=true
Environment=PID_DIR=/run/opensearch

WorkingDirectory=/opt/opensearch/app/opensearch-1.3.5

ExecStart=/opt/opensearch/app/opensearch-1.3.5/bin/opensearch -p ${PID_DIR}/opensearch.pid --quiet

StandardOutput=journal
StandardError=inherit

# Specifies the maximum file descriptor number that can be opened by this process
LimitNOFILE=65535
# Specifies the maximum number of processes
LimitNPROC=4096
# Specifies the maximum size of virtual memory
LimitAS=infinity
LimitMEMLOCK=infinity
# Specifies the maximum file size
LimitFSIZE=infinity
# Disable timeout logic and wait until process is stopped
TimeoutStopSec=0
# SIGTERM signal is used to stop the Java process
KillSignal=SIGTERM
# Send the signal only to the JVM rather than its control group
KillMode=process
# Java process is never killed
SendSIGKILL=no
# When a JVM receives a SIGTERM signal it exits with code 143
SuccessExitStatus=143
# Allow a slow startup before the systemd notifier module kicks in to extend the timeout
TimeoutStartSec=75
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload

```

### 8. 创建opensearch-dashboards运行unit

```bash
cat > /lib/systemd/system/opensearch-dashboards.service <<-\EOF
[Unit]
Description=OpenSearch Dashboards
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=opensearch
Group=opensearch
Environment=KILL_ON_STOP_TIMEOUT=0
Environment=OSD_PATH_CONF=/opt/opensearch/app/opensearch-dashboards-1.3.5/config
WorkingDirectory=/opt/opensearch/app/opensearch-dashboards-1.3.5
ExecStart=/opt/opensearch/app/opensearch-dashboards-1.3.5/bin/opensearch-dashboards
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload

```



## 3. CA证书

证书是安全插件所提供的功能，包放在下面，配置证书的位置是在主配置文件 **opensearch.yml** 里面配置。

### 1. 创建CA证书的文件目录

```bash
mkdir /opt/opensearch/app/opensearch-1.3.5/config/certs
```

### 2. 安装openssl

```bash
yum install openssl
```

### 3. 生成CA证书

```bash
cd /opt/opensearch/app/opensearch-1.3.5/config/certs
# root CA
openssl genrsa -out root-ca-key.pem 2048
openssl req -new -x509 -sha256 -key root-ca-key.pem -subj "/C=CA/ST=ONTARIO/L=TORONTO/O=ORG/OU=UNIT/CN=ROOT" -out root-ca.pem -days 730
# admin cert
openssl genrsa -out admin-key-temp.pem 2048
openssl pkcs8 -inform PEM -outform PEM -in admin-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out admin-key.pem
openssl req -new -key admin-key.pem -subj "/C=CA/ST=ONTARIO/L=TORONTO/O=ORG/OU=UNIT/CN=ADMIN" -out admin.csr
openssl x509 -req -in admin.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -sha256 -out admin.pem -days 730
# node1 cert
openssl genrsa -out node1-key-temp.pem 2048
openssl pkcs8 -inform PEM -outform PEM -in node1-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out node1-key.pem
openssl req -new -key node1-key.pem -subj "/C=CA/ST=ONTARIO/L=TORONTO/O=ORG/OU=UNIT/CN=node1.example.com" -out node1.csr
openssl x509 -req -in node1.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -sha256 -out node1.pem -days 730	
# node cert 2
openssl genrsa -out node2-key-temp.pem 2048
openssl pkcs8 -inform PEM -outform PEM -in node2-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out node2-key.pem
openssl req -new -key node2-key.pem -subj "/C=CA/ST=ONTARIO/L=TORONTO/O=ORG/OU=UNIT/CN=node2.example.com" -out node2.csr
openssl x509 -req -in node2.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -sha256 -out node2.pem -days 730

# 将node2节点需要的相关证书发送到node2服务器CA的目录
scp admin.pem root@192.168.0.2:/opt/opensearch/app/opensearch-1.3.5/config/certs
scp admin-key.pem root@192.168.0.2:/opt/opensearch/app/opensearch-1.3.5/config/certs
scp node1.pem root@192.168.0.2:/opt/opensearch/app/opensearch-1.3.5/config/certs
scp node1-key.pem root@192.168.0.2:/opt/opensearch/app/opensearch-1.3.5/config/certs
scp node2.pem root@192.168.0.2:/opt/opensearch/app/opensearch-1.3.5/config/certs
scp node2-key.pem root@192.168.0.2:/opt/opensearch/app/opensearch-1.3.5/config/certs
scp root-ca.pem root@192.168.0.2:/opt/opensearch/app/opensearch-1.3.5/config/certs
```

### 4. 获取证书信息

```bash
# admin subject信息
[root@localhost certs]# openssl x509 -subject -nameopt RFC2253 -noout -in admin.pem
subject=CN=A,OU=UNIT,O=ORG,L=TORONTO,ST=ONTARIO,C=CA

# node1 subject信息
[root@localhost certs]# openssl x509 -subject -nameopt RFC2253 -noout -in node1.pem
subject=CN=node1.dns.a-record,OU=UNIT,O=ORG,L=TORONTO,ST=ONTARIO,C=CA

# node2 subject信息
[root@localhost certs]# openssl x509 -subject -nameopt RFC2253 -noout -in node2.pem
subject=CN=node2.dns.a-record,OU=UNIT,O=ORG,L=TORONTO,ST=ONTARIO,C=CA
```



### 5. opensearch  yml配置

```yaml
# 集群名称
cluster.name: opensearch
# 节点名称
node.name: node1
# 向节点添加自定义属性
node.attr.rack: RHV
# 数据存储路径，多路径逗号隔开	
path.data: /opt/opensearch/app/data
# 日志文件路径
path.logs: /opt/opensearch/logs
# 启动锁定内存
bootstrap.memory_lock: true
# 当前主机ip
network.host: 192.168.1.11
# 访问端口
http.port: 9200
# 集群通信端口
transport.port: 9300
# 集群信息
discovery.seed_hosts: ["192.168.1.11:9300", "192.168.1.12:9300"]
# 使用一组初始的符合主节点的节点引导集群
cluster.initial_master_nodes: ["192.168.1.11"]
# 在完整集群重启后阻止初始恢复，直到启动 N 个节点
gateway.recover_after_nodes: 1
# 删除索引时需要明确的名称
action.destructive_requires_name: true

# 证书相对路径
plugins.security.ssl.transport.pemcert_filepath: certs/node1.pem
plugins.security.ssl.transport.pemkey_filepath: certs/node1-key.pem
plugins.security.ssl.transport.pemtrustedcas_filepath: certs/root-ca.pem
plugins.security.ssl.transport.enforce_hostname_verification: false

# 证书相对路径
plugins.security.ssl.http.pemcert_filepath: certs/node1.pem
plugins.security.ssl.http.pemkey_filepath: certs/node1-key.pem
plugins.security.ssl.http.pemtrustedcas_filepath: certs/root-ca.pem
plugins.security.ssl.http.enabled: true

plugins.security.allow_unsafe_democertificates: true
plugins.security.allow_default_init_securityindex: true

# admin subject信息
plugins.security.authcz.admin_dn:
  - 'CN=A,OU=UNIT,O=ORG,L=TORONTO,ST=ONTARIO,C=CA'
 
 # 集群 subject信息
plugins.security.nodes_dn:
  - 'CN=node1.dns.a-record,OU=UNIT,O=ORG,L=TORONTO,ST=ONTARIO,C=CA'
  - 'CN=node2.dns.a-record,OU=UNIT,O=ORG,L=TORONTO,ST=ONTARIO,C=CA'

plugins.security.audit.type: internal_opensearch
plugins.security.enable_snapshot_restore_privilege: true
plugins.security.check_snapshot_restore_write_privileges: true
plugins.security.restapi.roles_enabled: ["all_access", "security_rest_api_access"]
plugins.security.system_indices.enabled: true
plugins.security.system_indices.indices: [".opendistro-alerting-config", ".opendistro-alerting-alert*", ".opendistro-anomaly-results*", ".opendistro-anomaly-detector*", ".opendistro-anomaly-checkpoints", ".opendistro-anomaly-detection-state", ".opendistro-reports-*", ".opendistro-notifications-*", ".opendistro-notebooks", ".opendistro-asynchronous-search-response*", ".replication-metadata-store"]
node.max_local_storage_nodes: 2

```

### 6. opensearch-dashboard yml 配置

```yaml
opensearch.hosts: ["https://192.168.1.11:9200","https://1192.168.1.12:9200"]
opensearch.ssl.verificationMode: none
opensearch.username: "admin"
opensearch.password: "admin"
opensearch.requestHeadersWhitelist: [ authorization,securitytenant ]
opensearch_security.multitenancy.enabled: true
opensearch_security.multitenancy.tenants.preferred: ["Private", "Global"]
opensearch_security.readonly_mode.roles: ["kibana_read_only"]
opensearch_security.cookie.secure: false
server.host: 192.168.1.11
server.port: 5601

```

su - opensearch -c "/data/opensearch/app/opensearch-dashboards-2.5.0/bin/opensearch-dashboards" &