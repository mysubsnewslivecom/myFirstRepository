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

application="Zookeeper"

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
    local STATE=$4
    [ "$ACTION" == "Stopping" ] && STATE="STOPPED" 
    [ "$ACTION" == "Starting" ] && STATE="STARTED" 
    [ -z "${STATE}" ] && STATE="NOT RUNNING"   
    [ -z "${ACTION}" ] && ACTION="Checking"   
    printf "%-50s" "${ACTION} $NAME..."
    sleep 3
        if [ $(checkPID ${PID}) -ne 0 ] ; then
            printf "\033[0;33m%s\033[0m\n" "[ ${STATE} ]"
        else
            printf "\033[1;38m%s\033[0m\n" "[ RUNNING ]"
        fi

}

killPID(){
    local PID="${1}"
    
    if [ -n "${PID}" ]; then    
        SIGNAL=${SIGNAL:-TERM}
        kill -s ${SIGNAL} "${PID}" >/dev/null 2>&1
        local retval=$?
    else 
        log "No argument passed to check PID" ERROR
    fi
    echo ${retval} 
}

removeFile(){
  local PIDFILE="$1"
    if [ -n "${PIDFILE}" ]; then    
        rm -v "${PIDFILE}" >/dev/null 2>&1
        local retval=$?
        if [ ${retval} -ne 0 ]; then
          log "${PIDFILE} could not be removed" ERROR
        else
          log "${PIDFILE} removed" INFO >/dev/null 2>&1
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
                local getPID=$(killPID ${PID})
                if [ ${getPID} -eq 0 ]; then
                    removeFile ${PIDFILE}
                    statusService "${PID}" "${application}" "Stopping"
                fi
            else
                statusService "$PID" "${application}"
                removeFile ${PIDFILE}
            fi    
        else
          log "${PIDFILE} cannot be read. " ERROR
        #  statusService "$PID" "${application}"
        fi
      else
        log "PID file is empty" ERROR 
        removeFile ${PIDFILE}
        statusService "$PID" "${application}"
      fi
    else
#      log "${PIDFILE} does not exists" ERROR
        statusService "$PID" "${application}"
    fi
  else
    log "No argument passed for  \${PIDFILE}"
  fi

}

pid "${ZOOKEEPER_PID}" "${application}"
