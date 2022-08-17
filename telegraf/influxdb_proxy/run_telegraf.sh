#!/usr/bin/env bash
WHATAP_HOST_IP=
WHATAP_HOST_PORT=6600
WHATAP_PCODE=
WHATAP_LICENSE=
WHATAP_TELEGRAF_IMAGE=registry.whatap.io:5000/telegraf:local
CONTAINER_NAME=whatap_telegraf

docker build -t $WHATAP_TELEGRAF_IMAGE .


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

cat >./influxdb.conf <<EOL
[[inputs.influxdb_v2_listener]]
  ## Address and port to host InfluxDB listener on
  ## (Double check the port. Could be 9999 if using OSS Beta)
  service_address = ":8086"
EOL

docker stop $CONTAINER_NAME
docker rm $CONTAINER_NAME
docker run -d --name $CONTAINER_NAME \
        -v $(pwd)/telegraf.conf:/etc/telegraf/telegraf.conf \
        -v $(pwd)/influxdb.conf:/etc/telegraf/telegraf.d/influxdb.conf \
        -p 8086:8086 \
        -v $(pwd)/whatap.conf:/etc/telegraf/telegraf.d/whatap.conf \
        $WHATAP_TELEGRAF_IMAGE
