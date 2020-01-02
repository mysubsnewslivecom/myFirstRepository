#!/bin/bash
#################################################
#Script for new debian 9 setup			#
#################################################

scriptname=`basename $0`
scriptlog=/tmp/$scriptname.log

log(){
        logMessage="$1"
        logLevel="$2"
        if [ "$logLevel" == "ERROR" ] ; then
            exit 
        fi
        printf "$(date "+%d-%m-%Y %H:%M:%S") #$logLevel\t- $logMessage \n"|tee -a $scriptlog
}

cd ~/.local/share/applications/

read -p 'Application Name: ' applnName
read -p 'Comment: ' applComment
read -p 'Executable Path: ' applnExec
read -p 'Icon: ' applnIcon

log "[Desktop Entry]" INFO
log "Type=Application" INFO
log "Encoding=UTF-8" INFO
log "Name=$applnName" INFO
log "Comment=$applComment" INFO
log "Exec=$applnExec" INFO
log "Icon=$applnIcon" INFO
log "Terminal=false" INFO

fileName=$applnName.desktop
log "$fileName" INFO

if [ -f $fileName ]; then
    log "$fileName exists" ERROR
else 
    log "$fileName does not exists" INFO
fi

cat /dev/null > $fileName
log "`pwd -P`" INFO
log "$fileName" INFO

printf "[Desktop Entry]\n" >> $fileName
printf "Type=Application\n" >> $fileName 
printf "Encoding=UTF-8\n" >> $fileName
printf "Name=$applnName\n" >> $fileName
printf "Comment=$applComment\n" >> $fileName
printf "Exec=$applnExec\n" >> $fileName
printf "Icon=$applnIcon\n" >> $fileName
printf "Terminal=false\n" >> $fileName

log "end of $scriptname"
