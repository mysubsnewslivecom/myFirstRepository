#!/bin/bash
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if [ -f /home/kishen/Workspace/config/env.sh ]; then
    . /home/kishen/Workspace/config/env.sh
else
        printf "[$(date "+%d-%b-%Y %H:%M:%S") #ERROR] env.sh does not exists\n" 
    exit 1
fi

application="Kafka"

checkPID(){
    local PID="${1}"
    
    if [ -n "${PID}" ]; then    
        ps -p ${PID} >/dev/null 2>&1
        local retval=$?
    else 
        local retval=1
    fi
    echo ${retval} 
}

statusService() {
    local PID=$1
    local NAME=$2        
    local ACTION=$3
    local STATE=""
    [ "$ACTION" == "Stopping" ] && STATE="STOPPED" 
    [ "$ACTION" == "Starting" ] && STATE="STARTED" 
    [ -z "${STATE}" ] && STATE="RUNNING"   
    [ -z "${ACTION}" ] && ACTION="Checking"  
    printf "%-50s" "${ACTION} $NAME..."
    sleep 3
        if [ $(checkPID ${PID}) -eq 0 ] ; then
            printf "\033[0;33m%s\033[0m\n" "[ ${STATE} ]"
        else
            printf "\033[1;38m%s\033[0m\n" "[ NOT RUNNING ]"
        fi

}

removeFile(){
  local PIDFILE="$1"
    if [ -n "${PIDFILE}" ]; then    
        rm -v "${PIDFILE}" >/dev/null 2>&1
        local retval=$?
        if [ ${retval} -ne 0 ]; then
          log "${PIDFILE} could not be removed" ERROR
        else
          log "${PIDFILE} removed" INFO
        fi
    else 
        log "No argument passed to remove file" ERROR
    fi
}

pid(){
  local PIDFILE="$1"
  if [ ! -z "$PIDFILE" ]; then
    if [ -f "$PIDFILE" ]; then
      if [ -s "$PIDFILE" ]; then
        if [ -r "$PIDFILE" ]; then
        local PID=`cat ${PIDFILE}`
        local getPID=$(checkPID ${PID})
            if [ ${getPID} -eq 0 ]; then
                    statusService "${PID}" "${application}"
            else
                    statusService "${PID}" "${application}"
            fi    
        else
          log "${PIDFILE} cannot be read. " ERROR
        statusService "$PID" "${application}"
        fi
      else
        log "PID file is empty" ERROR 
        removeFile ${PIDFILE}
        statusService "$PID" "${application}"
      fi
    else
              nohup $base_dir/kafka-run-class.sh $EXTRA_ARGS kafka.Kafka  "${PROPERTY_FILE}"  > /dev/null  2>&1 < /dev/null &
                echo $! > ${PIDFILE}
                local PID=`cat ${PIDFILE}`
                statusService "$PID" "${application}" "Starting"
    fi
  else
    log "No argument passed for  \${PIDFILE}"
  fi

}


if [ $# -lt 1 ];
then
#	echo "USAGE: $0 [-daemon] server.properties [--override property=value]*"
#	exit 1
    PROPERTY_FILE="$KAFKA_CONF/server.properties"
fi
base_dir=$(dirname $0)

PROPERTY_FILE="$KAFKA_CONF/server.properties"

if [ "x$KAFKA_LOG4J_OPTS" = "x" ]; then
    export KAFKA_LOG4J_OPTS="-Dlog4j.configuration=file:$base_dir/../config/log4j.properties"
fi

if [ "x$KAFKA_HEAP_OPTS" = "x" ]; then
    export KAFKA_HEAP_OPTS="-Xmx1G -Xms1G"
fi

EXTRA_ARGS=${EXTRA_ARGS-'-name kafkaServer -loggc'}

COMMAND=$1
case $COMMAND in
  -daemon)
    EXTRA_ARGS="-daemon "$EXTRA_ARGS
    shift
    ;;
  *)
    ;;
esac

#exec nohup  $base_dir/kafka-run-class.sh $EXTRA_ARGS kafka.Kafka "$@" &
#echo $! > /opt/kafka/latest/logs/kafka.pid

pid "${KAFKA_PID}" "${application}"
