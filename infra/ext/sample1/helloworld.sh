#!/bin/bash


HOST=`hostname`
while IFS='=' read -r -d '' n v; do
  printf "M $HOST %s %s\n" "$n" "$v"
done < <(env -0)

echo "H $HOST hosttime $(date +%s)"
