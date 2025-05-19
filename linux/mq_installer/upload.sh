#!/usr/bin/env bash

rm whatap_mq_exporter_installer.run
makeself --notemp . whatap_mq_exporter_installer.run \
  "Whatap IBM MQ Exporter Installer" ./install.sh

scp  whatap_mq_exporter_installer.run whatap@192.168.1.203:~
#scp  whatap_mq_exporter_installer.run whatap@192.168.1.204:~
#scp  whatap_mq_exporter_installer.run whatap@192.168.1.205:~
