#!/bin/bash -v
apt-get update -y
export DEBIAN_FRONTEND=noninteractive
apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
apt-get install -y apt-transport-https
echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-6.x.list
apt-get update -y
apt-get install -y default-jre
apt-get install -y logstash

cat <<EOF > /etc/logstash/logstash.conf
input {
  beats {
    port => 5044
    host => "0.0.0.0"
  }
}
output {
  elasticsearch {
    hosts => localhost
    manage_template => false
    index => "%{[@metadata][beat]}-%{[@metadata][version]}-%{+YYYY.MM.dd}"
  }
}
EOF
systemctl stop logstash
systemctl start logstash
