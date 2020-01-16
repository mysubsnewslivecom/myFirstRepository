#!/bin/bash
clear

if [ -f /etc/profile.d/env.sh ]; then
    . /etc/profile.d/env.sh
else
    printf "[$(date "+%d-%b-%Y %H:%M:%S") #ERROR] env.sh does not exists\n" 
    exit 1
fi

[ $# -eq 0 ] && log "Usage: $0 appln" ERROR 

param=$1

PATTERN="\$PID_"${param^^}
application=`eval echo ${PATTERN}|cut -d'|' -f1`
PATTERN=`eval echo ${PATTERN}|cut -d'|' -f2`

if [ -z "${PATTERN}" -o -z "${application}" ] ; then
    log "${param} not found" ERROR
fi


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
