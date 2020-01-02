#!/bin/bash
clear

source //etc/profile.d/env.sh
scriptname=$(basename $0 .sh) 
scriptlog=/tmp/$scriptname.log

log(){
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

while getopts j: name
   do
     case $name in
        j) token="$OPTARG" ;;        # LOG FILE
        *) usage ;;
     esac
   done
program=$(awk  -v var="$token"  -F'=' '{  if ( toupper(var) == toupper($1) ) print $2  }' //etc/profile.d/jenkins.properties)

if [ -z $program ]; then
    log "$token is invalid" ERROR
fi


USERNAME=api
APITOKEN=11a19ca7fd8e7b2c95c59e6f07deeece29
JENKINS_SERVER="localhost:5050"
JOB=$program
JOB_QUERY=/job/${JOB}
URL="http://${USERNAME}:${APITOKEN}@${JENKINS_SERVER}/${JOB_QUERY}"

BUILD_STATUS_QUERY=/lastBuild/api/json
log "URL: ${URL}${BUILD_STATUS_QUERY}" 
JOB_STATUS_JSON=`~/anaconda3/bin/curl --silent ${URL}${BUILD_STATUS_QUERY}` 
#log "JOB_STATUS_JSON: ${JOB_STATUS_JSON}"
CURRENT_BUILD_NUMBER_QUERY=/lastBuild/buildNumber
CURRENT_BUILD_JSON=`~/anaconda3/bin/curl --silent ${URL}${CURRENT_BUILD_NUMBER_QUERY}`
log "CURRENT_BUILD_JSON: ${CURRENT_BUILD_JSON}" 
LAST_STABLE_BUILD_NUMBER_QUERY=/lastStableBuild/buildNumber
LAST_STABLE_BUILD_JSON=`~/anaconda3/bin/curl --silent ${URL}${LAST_STABLE_BUILD_NUMBER_QUERY}`
log "LAST_STABLE_BUILD_JSON: ${LAST_STABLE_BUILD_JSON}"

check_build(){
    GOOD_BUILD="${GREEN}Last build successful. "
    BAD_BUILD="${RED}Last build failed. "
    RESULT=`echo "${JOB_STATUS_JSON}" | sed -n 's/.*"result":\([\"A-Za-z]*\),.*/\1/p'`
    log "RESULT: ${RESULT}"
    CURRENT_BUILD_NUMBER=${CURRENT_BUILD_JSON}
    LAST_STABLE_BUILD_NUMBER=${LAST_STABLE_BUILD_JSON}
    LAST_BUILD_STATUS=${GOOD_BUILD}
    echo "${LAST_STABLE_BUILD_NUMBER}" | grep "is not available" > /dev/null
    GREP_RETURN_CODE=$?
    log "GREP_RETURN_CODE: ${GREP_RETURN_CODE}"
    if [ ${GREP_RETURN_CODE} -ne 0 ]
    then
        if [ `expr ${CURRENT_BUILD_NUMBER} - 1` -gt ${LAST_STABLE_BUILD_NUMBER} ]
        then
            LAST_BUILD_STATUS=${BAD_BUILD}
        fi
    fi

    if [ "${RESULT}" = "null" ]
    then
        MESSAGE="Building ${JOB} ${CURRENT_BUILD_NUMBER}... last stable was ${LAST_STABLE_BUILD_NUMBER}${CLEAR_COLOURS}"
    elif [ "${RESULT}" = "\"SUCCESS\"" ]
    then
        MESSAGE="${JOB} ${CURRENT_BUILD_NUMBER} completed successfully."
    elif [ "${RESULT}" = "\"FAILURE\"" ]
    then
        LAST_BUILD_STATUS=${BAD_BUILD}
        MESSAGE="${JOB} ${CURRENT_BUILD_NUMBER} failed${CLEAR_COLOURS}"
    else
        LAST_BUILD_STATUS=${BAD_BUILD}
        MESSAGE="${JOB} ${CURRENT_BUILD_NUMBER} status unknown - '${RESULT}'${CLEAR_COLOURS}"
    fi
    log "${MESSAGE}"
}

check_build
 
RESULT=`echo ${RESULT}|sed 's/\"//g'`
value=`mysql  -u$MYSQLUSER -p$MYSQLPASSWORD   --database=staging -e "select  data.insertProcess('${JOB}','${RESULT}','$MESSAGE') as output;"`

