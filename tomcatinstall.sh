#!/bin/bash
clear

. /home/kishen/Workspace/config/env.sh 
ScriptDetails

usage(){

    if [ $1 -ne 2 ]; then
    	log "Usage: $SCRIPT_NAME filename" "ERROR"
    fi


}

usage $#

file="$1"
directory="$2"
installdirectory="/opt/${directory}"
#filename=$(basename -- "$file")
#extension="${filename##*.*}"
#filename="${filename%.*}"

#echo $filename
#echo $extension

status (){
    message="$1"
    code="$2"
    [ ${code} -eq 0 ] && log "${message} SUCCESS" INFO || log "${message} FAILURE" ERROR
    unset message
    unset code
}

echo $file|grep "."

log "${installdirectory}"

if [ -f /home/kishen/Downloads/${file} ]; then
    log "File exists" 
else
    log "File does not exists" ERROR
    exit 2
fi

if [ -d ${installdirectory} ]; then
    log "Directory ${installdirectory} exists "
else
    log "Directory does not exists"
    sudo mkdir ${installdirectory} -p
    sudo chown -R ${USER}:common ${installdirectory}
    ls -ld ${installdirectory}
fi

start(){
    cp  /home/kishen/Downloads/${file} ${installdirectory}
    status "Copy file to destination" $?
    chmod 755 ${installdirectory}/${file}
    status "Changing permisssion" $?
    log "`ls -lrt ${installdirectory}/${file}`"
    cd ${installdirectory}
    tar -xf ${file}
    status "Untaring ${file}" $?
    ln -sf ${file} latest
    status "Symlink ${file}" $?
    chown -R ${USER}:common ${installdirectory}/${file}
    status "Changing owner" $?
}

start

EndScript


