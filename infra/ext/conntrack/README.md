# Whatap Agent Custom Script Registration

This document explains how to register a custom script with the Whatap monitoring agent. The example provided demonstrates how to monitor Conntrack module's `nf_conntrack_count` and `nf_conntrack_max` values in CentOS 7 and calculate their usage percentage.

## Prerequisites

- Whatap agent installed on a Linux server.
- Basic understanding of Linux command line and permission system.

## Custom Script Example

The script, `conntrack_percent.sh`, calculates the usage percentage of the Conntrack module by comparing `nf_conntrack_count` to `nf_conntrack_max`.

```bash
#!/bin/bash

# /proc/sys/net/netfilter/nf_conntrack_count 읽기
nf_conntrack_count=$(cat /proc/sys/net/netfilter/nf_conntrack_count)

# /proc/sys/net/netfilter/nf_conntrack_max 읽기
nf_conntrack_max=$(cat /proc/sys/net/netfilter/nf_conntrack_max)

# 백분율 계산
conntrack_percent=$(awk "BEGIN {printf \"%.2f\", ($nf_conntrack_count / $nf_conntrack_max) * 100}")

echo "H ${HOSTNAME} conntrack_percent ${conntrack_percent}"
```

## Registration Process
To register the conntrack_percent.sh script with the Whatap agent, follow these steps:

1. Navigate to the Whatap Agent Directory
Change your current directory to where the Whatap agent is installed, typically /usr/whatap/infra.

```bash
cd /usr/whatap/infra
```
2. save conntrack_percent.sh in ext directory
open text editor like vi and create conntrack_percent.sh file 
```bash
sudo mkdir -p ext 
cd ext
sudo vi conntrack_percent.sh
...
sudo chmod +x conntrack_percent.sh
```

3. Initialize the Custom Script
Use the whatap_infrad program to initialize the custom script. Replace {non-root user} with the actual username under which the script should be executed.

```bash
cd /usr/whatap/infra
sudo WHATAP_HOME=$PWD/conf ./whatap_infrad --user {non-root user} init-script
```
4. Restart the Whatap Agent
After registration, restart the Whatap agent to apply the changes.

```bash
sudo service whatap-infra restart
```
## Notes
Ensure the custom script is executable and the specified user has sufficient permissions to execute it.
The configuration and management of the custom script, including its execution frequency, are managed through the Whatap agent's configuration file.
For more information on configuring and managing custom scripts with Whatap, refer to the official documentation or contact Whatap support.



