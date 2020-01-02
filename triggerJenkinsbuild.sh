#!/bin/bash
#################################################
#Script for new debian 9 setup                  #
#################################################
clear

. /home/kishen/Workspace/config/env.sh

scriptname=$(basename $0 .sh) 
scriptlog=/tmp/$scriptname.log

logq(){
        logMessage="$1"
        logLevel="$2"
        printf "[$(date "+%d-%m-%Y %H:%M:%S")] #$logLevel\t- $logMessage \n"|tee -a $scriptlog
        if [ "$logLevel" == "ERROR" ] ; then
            exit 
        fi
}
usage(){

	log "Usage: $0 -l token" "ERROR"
}

checkstatus(){
    url=http://$username:$apitoken@$jenkins_server/job/$program/lastBuild/api/json
 #   echo $url
    JOB_STATUS_JSON=$(curl -X POST --silent   $url )
    echo $JOB_STATUS_JSON| sed -n 's/.*"result":\([\"A-Za-z]*\),.*/\1/p'
}

getVariables(){

    var="$1"
    local value=$(awk -F'=' -v var=$var ' { if( $1==var ) print $2 } ' $jenkinlog)
    echo "${value}"
    unset value
    unset var
}

while getopts j: name
   do
     case $name in
        j) token="APP_$OPTARG" ;;        # LOG FILE
        *) usage ;;
     esac
   done

program=$(awk  -v var="$token"  -F'=' '{  if ( toupper(var) == toupper($1) ) print $2  }' /home/kishen/Workspace/config/jenkins.properties)
if [ -z $program ]; then
    log "$token is invalid" ERROR
fi

username="$(getVariables APP_API_USER)"
apitoken="$(getVariables API_API_TOKEN)"

jenkins_server="$(getVariables jenkins_server)"
url="http://$username:$apitoken@$jenkins_server/job/$program/build?token=$program"

log "username: $username"
log "apitoken: $apitoken" 
log "token: $program"   
log "url: $url"

status=$(curl -X POST --write-out %{http_code} --silent --output /dev/null  $url )
if [ $status -ne 201 ] ; then
    log "Request failed with exit $status" ERROR
else
    log "The request has been fulfilled $status"
fi


log $(checkstatus)
