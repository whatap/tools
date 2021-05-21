#!/usr/bin/env bash

echo "license=$WHATAP_LICENSE" |tee /whatap_conf/whatap.conf
echo "whatap.server.host=$WHATAP_HOST" |tee -a /whatap_conf/whatap.conf
echo "createdtime=$HOSTNAME" |tee -a /whatap_conf/whatap.conf
echo "oname=$NODE_NAME" |tee -a /whatap_conf/whatap.conf

/usr/whatap/infra/whatap_infrad foreground