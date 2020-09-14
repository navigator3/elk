sudo systemctl stop firewalld
sudo systemctl disable firewalld
echo "${name}_${surname}"
mkdir -p /tmp/scripts
echo "${ip_elk_serv_int} \
privet" > /tmp/scripts/test_ip
sudo yum install -y java-1.8.0
sudo yum install -y java-1.8.0-openjdk-devel

#>>>>>> install logstash
sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
cat > /etc/yum.repos.d/logstash.repo << EOF
[logstash-7.x]
name=Elastic repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF
sudo yum install -y logstash



##sudo groupadd tomcat
##sudo useradd -s /bin/nologin -g tomcat tomcat
sudo mkdir -p /opt/tomcat
cd /opt/tomcat/
echo "poimt 1" > /opt/tomcat/points_test
sudo yum install -y wget
sudo wget https://mirror.datacenter.by/pub/apache.org/tomcat/tomcat-8/v8.5.57/bin/apache-tomcat-8.5.57.tar.gz
sudo tar -zxvf apache-tomcat-8.5.57.tar.gz
#sudo chown -R tomcat:tomcat /opt/tomcat/*
sudo /opt/tomcat/apache-tomcat-8.5.57/bin/startup.sh
sudo touch /opt/tomcat/apache-tomcat-8.5.57/webapps/my.war


sudo cat > /etc/logstash/conf.d/logstash-tomcat.conf << EOF
input {
  file {
    path => "/opt/tomcat/apache-tomcat-8.5.57/logs/catalina.out"
    start_position => "beginning"
  }
}

output {
  elasticsearch {
    hosts => ["${ip_elk_serv_int}:9200"]
  }
  stdout { codec => rubydebug }
}
EOF
#sudo systemctl daemon-reload
#sudo systemctl enable logstash
#sudo systemctl start logstash
sudo /usr/share/logstash/bin/logstash -f /etc/logstash/conf.d/logstash-tomcat.conf &
