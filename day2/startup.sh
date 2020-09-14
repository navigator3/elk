#!/bin/bash
sudo mkdir -p /tmp/startup
echo "${name}-${surname}-${ext_ip}-${int_ip}"
sudo systemctl stop firewalld
sudo systemctl disable firewalld

#>>>>>>. install elasticsearch  <<<<<<<
sudo yum install -y java-1.8.0

sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
cat > /etc/yum.repos.d/elasticsearch.repo << EOF
[elasticsearch]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=0
autorefresh=1
type=rpm-md
EOF
sudo yum install -y --enablerepo=elasticsearch elasticsearch
sudo systemctl daemon-reload
sudo systemctl enable elasticsearch
sudo systemctl start elasticsearch

sudo sed -i '23c node.name: node-1' /etc/elasticsearch/elasticsearch.yml
#sudo sed -i '43c bootstrap.memory_lock: true' /etc/elasticsearch/elasticsearch.yml
sudo sed -i '55c network.host: 0.0.0.0' /etc/elasticsearch/elasticsearch.yml
#sudo sed -i '59c http.port: 9200' /etc/elasticsearch/elasticsearch.yml
#sudo sed -i '47c MAX_LOCKED_MEMORY=unlimited' /etc/sysconfig/elasticsearch
#sudo sed -i '68c discovery.seed_hosts: ["127.0.0.1"]' /etc/elasticsearch/elasticsearch.yml
sudo sed -i '72c cluster.initial_master_nodes: ["node-1"]' /etc/elasticsearch/elasticsearch.yml


sudo systemctl restart elasticsearch


#>>>>>>. install Kibana   <<<<<<<

cat > /etc/yum.repos.d/kibana.repo << EOF
[kibana-7.x]
name=Kibana repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF

sudo yum install -y kibana
sudo sed -i '2c server.port: 5601' /etc/kibana/kibana.yml
sudo sed -i '7c server.host: "0.0.0.0"' /etc/kibana/kibana.yml
sudo sed -i '28c elasticsearch.hosts: ["http://${int_ip}:9200"]' /etc/kibana/kibana.yml
sudo systemctl daemon-reload
sudo systemctl enable kibana
sudo systemctl start kibana
sudo systemctl restart elasticsearch #repeat 1 more for kibana
#>>>>> i nstall nginx  <<<<<<<
#sudo yum install -y epel-release
#sudo yum install -y nginx
