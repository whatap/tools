#!/usr/bin/python
import struct
import socket
import sys
import os
import re

config_file = '/usr/whatap/monitoring/conf/monitor_agent.conf'
if not os.path.exists(config_file):
    print 'config file', config_file, 'not found'
    sys.exit(1)
f = open(config_file,'r')
lines = f.readlines()
f.close()
for line in lines:
    serveraddr_match= re.match('^ServerActive=(?P<zserver>[0-9\.]+)$', line)
    if serveraddr_match:
        zserver = serveraddr_match.group('zserver')
    hostguid_match= re.match('^Hostname=(?P<hostguid>[\w\-]+)$', line)
    if hostguid_match:
        hostguid = hostguid_match.group('hostguid')

zport =10051
mydata='{ "request":"active checks", "host":"%s" }'%(hostguid)
data_length = len(mydata)
data_header = str(struct.pack('q', data_length))
socket.setdefaulttimeout(10)
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.connect((zserver, zport))
data_to_send = 'ZBXD\1' + str(data_header) + str(mydata)
sock.send(data_to_send)
response_header = sock.recv(5)
if not response_header == 'ZBXD\1':
    err_message = u'Invalid response from server. Malformed data?\n---\n%s\n---\n' % str(mydata)
    sys.stderr.write(err_message)
    sys.exit(1)

response_data_header = sock.recv(8)
response_data_header = response_data_header[:4]
response_len = struct.unpack('i', response_data_header)[0]
response_raw = sock.recv(response_len)
sock.close()
print response_raw

