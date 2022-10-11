#!/usr/bin/env bash

cat >./start.sh <<EOL

service rsyslog start
/usr/bin/telegraf -config /etc/telegraf/telegraf.conf -config-directory /etc/telegraf/telegraf.d \$TELEGRAF_OPTS

EOL

cat >./Dockerfile <<EOL
from ubuntu:20.04

WORKDIR /home/whatap

RUN apt update

RUN apt install -y curl snmp snmp-mibs-downloader rsyslog net-tools

RUN curl http://repo.whatap.io/telegraf/telegraf-release-1.21.1/linux/amd64/telegraf_1.21.1-1_amd64.deb -o telegraf_1.21.1-1_amd64.deb

RUN dpkg -i telegraf_1.21.1-1_amd64.deb

ADD ./start.sh .

CMD ["bash", "./start.sh"]

EOL

WHATAP_ADDR='["tcp://1.2.3.4:6600", "tcp://5.6.7.8:6600"]'
WHATAP_PCODE=123
WHATAP_LICENSE=xxxx-xxxx-xxxx
WHATAP_TELEGRAF_IMAGE=registry.whatap.io:5000/dev/telegraf:20221011
CONTAINER_NAME=whatap_telegraf

docker build -t $WHATAP_TELEGRAF_IMAGE .

cat >./whatap.conf <<EOL
[[outputs.whatap]]
#   ## WhaTap license. Required
    license = "$WHATAP_LICENSE"
#   ## WhaTap project code. Required
    pcode = $WHATAP_PCODE
#
#   ## WhaTap server IP. Required
    servers = $WHATAP_ADDR
#
#   ## Connection timeout.
#   # timeout = "60s"

EOL

cat >./telegraf.conf <<EOL
[global_tags]

# Configuration for telegraf agent
[agent]
  interval = "60s"
  hostname = ""
  omit_hostname = false

EOL

cat >./url-check.conf <<EOL
# HTTP/HTTPS request given an address a method and a timeout
[[inputs.http_response]]
  urls = ["https://www.naver.com"]

  response_timeout = "10s"

  follow_redirects = false

  response_body_field = 'response_body'

  response_body_max_size = "32MiB"

  response_string_match = "naver"
EOL

docker stop $CONTAINER_NAME 
docker rm $CONTAINER_NAME 
docker run -d --name $CONTAINER_NAME \
	-v $PWD/telegraf.conf:/etc/telegraf/telegraf.conf \
	-v $PWD/url-check.conf:/etc/telegraf/telegraf.d/url-check.conf \
	-v $PWD/whatap.conf:/etc/telegraf/telegraf.d/whatap.conf \
	-v $PWD/test.sh:/script/test.sh \
	$WHATAP_TELEGRAF_IMAGE
