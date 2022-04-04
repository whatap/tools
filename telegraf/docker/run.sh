#!/usr/bin/env bash

WHATAP_HOST_IP=
WHATAP_HOST_PORT=6600
WHATAP_PCODE=
WHATAP_LICENSE=
SNMP_DEVICE_IP=
WHATAP_TELEGRAF_IMAGE=registry.whatap.io:5000/dev/telegraf:2000004041
SNMP_COMMUNITY=public
SNMP_VERSION=2
CONTAINER_NAME=whatap_telegraf

cat >./whatap.conf <<EOL
[[outputs.whatap]]
#   ## WhaTap license. Required
    license = "$WHATAP_LICENSE"
#   ## WhaTap project code. Required
    pcode = $WHATAP_PCODE
#
#   ## WhaTap server IP. Required
    servers = ["tcp://$WHATAP_HOST_IP:$WHATAP_HOST_PORT"]
#
#   ## Connection timeout.
#   # timeout = "60s"

EOL

cat >./snmp_device.conf <<EOL
[[inputs.snmp]]
  ## Agent addresses to retrieve values from.
  ##   format:  agents = ["<scheme://><hostname>:<port>"]
  ##   scheme:  optional, either udp, udp4, udp6, tcp, tcp4, tcp6.
  ##            default is udp
  ##   port:    optional
  ##   example: agents = ["udp://127.0.0.1:161"]
  ##            agents = ["tcp://127.0.0.1:161"]
  ##            agents = ["udp4://v4only-snmp-agent"]

  agents = ["udp://$SNMP_DEVICE_IP:161"]

  ## Timeout for each request.
  # timeout = "5s"

  ## SNMP version; can be 1, 2, or 3.
   version = $SNMP_VERSION 

  ## SNMP community string.
   community = "$SNMP_COMMUNITY"

  ## Agent host tag
  # agent_host_tag = "agent_host"

  ## Number of retries to attempt.
  # retries = 3

  ## The GETBULK max-repetitions parameter.
  # max_repetitions = 10

  ## SNMPv3 authentication and encryption options.
  ##
  ## Security Name.
  # sec_name = "myuser"
  ## Authentication protocol; one of "MD5", "SHA", "SHA224", "SHA256", "SHA384", "SHA512" or "".
  # auth_protocol = "MD5"
  ## Authentication password.
  # auth_password = "pass"
  ## Security Level; one of "noAuthNoPriv", "authNoPriv", or "authPriv".
  # sec_level = "authNoPriv"
  ## Context Name.
  # context_name = ""
  ## Privacy protocol used for encrypted messages; one of "DES", "AES", "AES192", "AES192C", "AES256", "AES256C", or "".
  ### Protocols "AES192", "AES192", "AES256", and "AES256C" require the underlying net-snmp tools
  ### to be compiled with --enable-blumenthal-aes (http://www.net-snmp.org/docs/INSTALL.html)
  # priv_protocol = ""
  ## Privacy password used for encrypted messages.
  # priv_password = ""

  ## Add fields and tables defining the variables you wish to collect.  This
  ## example collects the system uptime and interface variables.  Reference the
  ## full plugin documentation for configuration details.
  [[inputs.snmp.field]]
    oid = "RFC1213-MIB::sysUpTime.0"
    name = "uptime"

  [[inputs.snmp.field]]
    oid = "RFC1213-MIB::sysName.0"
    name = "source"
    is_tag = true

  [[inputs.snmp.table]]
    oid = "IF-MIB::ifXTable"
    name = "interface"
    inherit_tags = ["source"]

  [[inputs.snmp.table.field]]
    oid = "IF-MIB::ifDescr"
    name = "ifDescr"
    is_tag = true

  [[aggregators.derivative]]
    period = "60s"
    max_roll_over = 1

    fieldpass = ["*Octets", "*Pkts"]
    drop_original = false

  [aggregators.derivative.tags]
    aggr = "derivative"

[[processors.starlark]]
  source = '''
def apply(metric):
    for (k, v) in metric.fields.items():
        if k.endswith('Octets_rate'):
            metric.fields[k] *= 8

    return metric

'''

EOL

cat >./telegraf.conf <<EOL
[global_tags]

# Configuration for telegraf agent
[agent]
  interval = "10s"
  round_interval = true
  metric_batch_size = 1000
  metric_buffer_limit = 10000
  collection_jitter = "0s"
  flush_interval = "10s"
  flush_jitter = "0s"
  precision = ""

  hostname = ""
  omit_hostname = false

EOL

cat >snmp_trap.conf <<EOL
[[inputs.snmp_trap]]
  service_address = "udp://:162"
  path = ["/usr/share/snmp/mibs"]
EOL

docker run -d --name $CONTAINER_NAME \
	-v $(pwd)/telegraf.conf:/etc/telegraf/telegraf.conf \
	-v $(pwd)/snmp_device.conf:/etc/telegraf/telegraf.d/snmp_device.conf \
	-v $(pwd)/snmp_trap.conf:/etc/telegraf/telegraf.d/snmp_trap.conf \
	-p 162:162/udp \
	-v $(pwd)/whatap.conf:/etc/telegraf/telegraf.d/whatap.conf \
	$WHATAP_TELEGRAF_IMAGE
