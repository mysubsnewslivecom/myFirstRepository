#!/bin/bash
. /home/kishen/Workspace/config/env.sh
clear
ScriptDetails

usage(){
	log "Usage: $SCRIPT_NAME -j service -s status" "ERROR"
}

dir(){
    if [ "$(dirname $0)"  == "." ]; then
    {
        dir=`pwd -P`
    }
    else 
    {
        dir=$(dirname $0)
    }
    fi;
    log "dir: $dir" INFO
    echo $dir
}

checkFile(){
    service="$1"
    if [ -f $dir/appln/$service ] ; then
        . "$dir/appln/$service"
    else
        log "Service $service does not exists" ERROR
    fi;
}
Service(){
    arg="$1"
    message="$2"
    local CMD="sh ${SCRIPT_CMD} ${arg} "
    #        log $CMD INFO
    #	printf "%-50s" "$message ..."
    log "${message} ..." INFO
    log "${CMD}"  INFO
    logger "${CMD}"  INFO
#    log "`exec ssh -q $(hostname)  $CMD `"  INFO
    log "`eval exec $CMD `"  INFO
    ret=$?
    if  [ "$arg" == "status" ]; then
        log $arg INFO
    fi;
}


if [ $# -eq 0 ]; then
    usage
fi

while getopts j:s: name
    do
        case $name in
            j) service="$OPTARG" ;;        # LOG FILE
            s) status="$OPTARG" ;;        # LOG FILE
            *) usage ;;
        esac
    done

log "Service: ${service}"  INFO
log "Status: ${status}"  INFO
dir
checkFile "${service}"

case "$status" in
start)
	Service start "Starting Service"
;;
stop)
	Service stop "Stopping Service"
;;
status)
	Service status "Checking status"
;;
restart)
	Service stop "Stopping Service"
	sleep 10
	Service start "Starting Service"
;;
ALL)
	
;;
*)
        usage
esac


EndScript