#!/bin/bash

if [ -f /home/kishen/Workspace/config/env.sh ]; then
    . /home/kishen/Workspace/config/env.sh
else
        printf "[$(date "+%d-%b-%Y %H:%M:%S") #ERROR] env.sh does not exists\n" 
    exit 1
fi

if [ $# -ne 1 ];
then
	echo "USAGE: $0 [-daemon] server.properties [--override property=value]*"
	exit 1
fi

COMMAND="$1"

cd $KAFKA_BIN

case $1 in
  -start)
    $KAFKA_BIN/zookeeper-server-start.sh
    sleep 5
    $KAFKA_BIN/kafka-server-start.sh
    shift
    ;;
  -stop)
    $KAFKA_BIN/kafka-server-stop.sh
    sleep 5
    $KAFKA_BIN/zookeeper-server-stop.sh
    shift
    ;;
  -status)
    $KAFKA_BIN/zookeeper-server-status.sh
    $KAFKA_BIN/kafka-server-status.sh
    shift
    ;;
  *)
    ;;
esac

