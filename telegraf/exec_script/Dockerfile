from ubuntu:20.04

WORKDIR /home/whatap

RUN apt update

RUN apt install -y curl snmp snmp-mibs-downloader rsyslog net-tools

RUN curl http://repo.whatap.io/telegraf/telegraf-release-1.21.1/linux/amd64/telegraf_1.21.1-1_amd64.deb -o telegraf_1.21.1-1_amd64.deb

RUN dpkg -i telegraf_1.21.1-1_amd64.deb

ADD ./start.sh .

CMD ["bash", "./start.sh"]

