#!/usr/bin/env sh

export CATEGORY=whatap_telegraf_test
export PK=22
export KEY_TARGET=var1
export OUTPUT_TG=val1

export KEY_STATE=ok_state
export STATE_COUNT=33

echo ${CATEGORY}",pk="${PK} ${KEY_TARGET}"=\""${OUTPUT_TG}"\","${KEY_STATE}"="${STATE_COUNT}

