#!/bin/bash


if [ -f /etc/profile.d/env.sh ]; then
    . /etc/profile.d/env.sh
    clear
    ScriptDetails
else
        printf "[$(date "+%d-%b-%Y %H:%M:%S") #ERROR] env.sh does not exists\n" 
    exit 1
fi

ARGS="--broker-list localhost:9092 --topic com.test"

msg="Test Message"

log "Sending ${msg}" INFO

log "${msg}" INFO| ${KAFKA_BIN}/kafka-console-producer.sh ${ARGS} >/dev/null 2>&1

[ $? -ne 0 ] && log "Failed" 
unset msg



#${KAFKA_BIN}/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic com.test --from-beginning



EndScript