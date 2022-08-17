from ubuntu:20.04

WORKDIR /home/whatap

RUN curl http://repo.whatap.io/telegraf/telegraf-release-1.21.1/linux/amd64/telegraf_1.21.1-1_amd64.deb -o telegraf_1.21.1-1_amd64.deb

RUN dpkg -i telegraf_1.21.1-1_amd64.deb


CMD ["/usr/bin/telegraf", "-config", "/etc/telegraf/telegraf.conf", "-config-directory", "/etc/telegraf/telegraf.d", "$TELEGRAF_OPTS"]
