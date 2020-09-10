#!/bin/bash
sudo mkdir -p /tmp/startup
echo "${name}-${surname}"
sudo systemctl stop firewalld
sudo systemctl disable firewalld

#>>>>>>. install elasticsearch  <<<<<<<
sudo yum -y install java-1.8.0
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

#sudo sed -i '43c bootstrap.memory_lock: true' /etc/elasticsearch/elasticsearch.yml
#sudo sed -i '55c network.host: ${ext_ip}' /etc/elasticsearch/elasticsearch.yml
#sudo sed -i '59c http.port: 9200' /etc/elasticsearch/elasticsearch.yml
#sudo sed -i '47c MAX_LOCKED_MEMORY=unlimited' /etc/sysconfig/elasticsearch

sudo systemctl daemon-reload
sudo systemctl enable elasticsearch
sudo systemctl start elasticsearch


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
#sudo sed -i '28c elasticsearch.hosts: ["http://localhost:9200"]' /etc/kibana/kibana.yml
sudo systemctl enable kibana
sudo systemctl start kibana

#>>>>> i nstall nginx  <<<<<<<
#sudo yum install -y epel-release
#sudo yum install -y nginx
