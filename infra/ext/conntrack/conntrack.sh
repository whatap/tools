#!/bin/bash

# /proc/sys/net/netfilter/nf_conntrack_count 읽기
nf_conntrack_count=$(cat /proc/sys/net/netfilter/nf_conntrack_count)

# /proc/sys/net/netfilter/nf_conntrack_max 읽기
nf_conntrack_max=$(cat /proc/sys/net/netfilter/nf_conntrack_max)

# 백분율 계산
conntrack_percent=$(awk "BEGIN {printf \"%.2f\", ($nf_conntrack_count / $nf_conntrack_max) * 100}")

echo "H ${HOSTNAME} conntrack_percent ${conntrack_percent}"