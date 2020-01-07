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

PATTERN="\$PID_"${1^^}
application=`eval echo ${PATTERN}|cut -d'|' -f1`
PATTERN=`eval echo ${PATTERN}|cut -d'|' -f2`

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
    [ -z "${ACTION}" ] && ACTION="Checking"   
    printf "%-50s" "${ACTION} $NAME..."
    sleep 3
        if [ $(checkPID ${PID}) -eq 0 ] ; then
          STATE="RUNNING"
        else
          STATE="NOT RUNNING"
        fi
            printf "\033[0;33m%s\033[0m\n" "[ ${STATE} ]"

}


pid(){
  local PID=$(ps ax | grep ${PATTERN} | grep java | grep -v grep | awk '{print $1}')
        statusService "$PID" "${application}"
}

pid "${application}"
