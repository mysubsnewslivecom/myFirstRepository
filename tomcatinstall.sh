#!/bin/bash
clear

if [ -f /etc/profile.d/env.sh ]; then
    . /etc/profile.d/env.sh
else
        printf "[$(date "+%d-%b-%Y %H:%M:%S") #ERROR] env.sh does not exists\n" 
    exit 1
fi 
#ScriptDetails

usage(){

    if [ $1 -ne 2 ]; then
    	log "Usage: $SCRIPT_NAME filename" "ERROR"
    fi


}
status (){
    message="$1"
    code="$2"
    [ ${code} -eq 0 ] && log "${message} SUCCESS" INFO || log "${message} FAILURE" ERROR
    unset message
    unset code
}
usage $#

file="$1"
directory="$2"
installdirectory="/opt/${directory}"

_self="${0##*.}"
#echo "$_self is called"











fileDetails(){


    if [ -f ${file} ]; then
        log "File exists" 
    else
        log "File ${file} does not exists" ERROR
        #exit 2
    fi

    filename=$(basename -- "${file}")
    extension="${filename#*.}"
    case "$filename" in
        *.tar.bz2) 
            subDir=`echo "${filename}"|sed 's/.tar.bz2//g'` 
            ;;
        *.bz2)
            subDir=`echo "${filename}"|sed 's/.bz2//g'`
            ;;
        *.tar.gz) 
            subDir=`echo "${filename}"|sed 's/.tar.gz//g'`
#            cmd="tar -xzf ${installdirectory}/${filename} -C ${installdirectory}/${subDir}/"
            cmd="tar -xzf ${installdirectory}/${filename} "
            ;;
        *.tgz)
            subDir=`echo "${filename}"|sed 's/.tgz//g'`
            cmd="tar -xzf ${installdirectory}/${filename} "
            ;;
        *.gz)      
            subDir=`echo "${filename}"|sed 's/.gz//g'`
            cmd="gunzip -c ${installdirectory}/${filename} > ${installdirectory}/${subDir}/"
            ;;
        *.zip)           
            subDir=`echo "${filename}"|sed 's/.zip//g'`
            cmd="unzip  ${installdirectory}/${filename} -d ${installdirectory}/${subDir}/"
            ;;
        *.7z)  
            subDir=`echo "${filename}"|sed 's/.7z//g'`
            ;;
        *)
            echo "invalid extension" 
            exit 1            
            ;;
    esac

    log "File: ${file}"
    log "Install Directory: ${installdirectory}"
    log "DirectoryName: ${subDir}"
    log "Command: ${cmd}"

    if [ -d ${installdirectory} ]; then
        log "Directory ${installdirectory} exists "
    else
        log "Directory ${installdirectory} does not exists"
        sudo mkdir ${installdirectory}/ -p
        sudo chown -R ${USER}:common ${installdirectory}/
        ls -ld ${installdirectory}
    fi

    start

}


start(){

#    local CMD=$1
    cp  -ipv ${file} ${installdirectory}
    status "Copy file to destination" $?
    chmod 755 ${installdirectory}/${file}
    status "Changing permisssion" $?
    log "`ls -lrt ${installdirectory}/${file}`"
    cd ${installdirectory}
    ${cmd}
    status "Untaring ${file}" $?
    ln -sf ${subDir} latest
    status "Symlink ${subDir}" $?
    sudo chown -R ${USER}:common ${installdirectory}/${subDir}
    status "Changing owner" $?
}





fileDetails

EndScript


