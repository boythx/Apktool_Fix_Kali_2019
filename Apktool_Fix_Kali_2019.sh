#!/bin/bash 
# Author: catenatedgoose
# Version: 2.0
# Description: A basic fix for apktool in kali linux. This script replaces apktool 2.3.4-dirty with 2.4 so common errors will be avoided. This also adds packages to work with msfvenom.

RED='\033[00;31m'
GREEN='\033[00;32m'
YELLOW='\033[00;33m'
BLUE='\033[0;34m'
RESTORE='\033[0m'

echo -e "${BLUE}"
echo '
      _____     __                __         __    _____                 
     / ___/__ _/ /____ ___  ___ _/ /____ ___/ /___/ ___/__  ___  ___ ___ 
    / /__/ _ `/ __/ -_) _ \/ _ `/ __/ -_) _  /___/ (_ / _ \/ _ \(_-</ -_)
    \___/\_,_/\__/\__/_//_/\_,_/\__/\__/\_,_/    \___/\___/\___/___/\__/' 
echo                                                                      
echo -e "${YELLOW}                     Apktool_Fix_Kali_2019 Version ${BLUE}2.0${RESTORE}"
echo

[[ $(wget -q --tries=5 --timeout=20 --spider http://google.com ; echo $?) != 0 ]] && echo -e "${RED}Warning!${YELLOW} This script needs an internet connection!" && echo && echo -e "${YELLOW}Please connect to the internet and try again.${RESTORE}" && exit

chk_inst_depends() {
    mapfile -t pkg_depends < <(apt-cache depends apktool | cut -d':' -f2 | sed  "s/^[ \t]*//;/<java7-runtime-headless>/d" | sed '/^apktool\b/d' | sort -u)
    pwd=$(pwd)
    x=0
    echo
    for depend in "${pkg_depends[@]}"; do 
        pkg_qry=$(dpkg-query -s $depend &>/dev/null ; echo $?)
        if [ $pkg_qry = 0 ]; then
            echo -e "${YELLOW}$depend is ${GREEN}Installed.${RESTORE}"
        else 
            x=1
            echo -e "${YELLOW}$depend is ${RED}missing.${RESTORE}"
            MISSING+=($depend)
            [[ -e /tmp/repair_depends ]] || mkdir /tmp/repair_depends
            cd /tmp/repair_depends && apt-get download $depend &>/dev/null && cd $pwd
        fi
    done      
    if [[ $x = 1 ]]; then 

        if [[ "${MISSING[*]} " != *"aapt"* ]] && [[ "${MISSING[*]} " == *"google-android-build-tools-installer"* ]]; then
            MISSING=( "${MISSING[@]/google-android-build-tools-installer/}" ) && rm /tmp/repair_depends/google-android-build-tools-installer*
            echo ; echo -e "${YELLOW}With ${BLUE}aapt ${YELLOW}installed you do not need ${BLUE}google-android-build-tools-installer.${RESTORE}";echo
        elif [[ "${MISSING[*]} " != *"google-android-build-tools-installer"* ]] && [[ $(dpkg-query -s google-android-build-tools-installer &>/dev/null ; echo $?) = 0 ]] && [[ "${MISSING[*]} " == *"aapt"* ]]; then
            MISSING=( "${MISSING[@]/aapt/}" ) && rm /tmp/repair_depends/aapt*
            echo ; echo -e "${YELLOW}With ${BLUE}google-android-build-tools-installer ${YELLOW}installed you do not need ${BLUE}aapt.${RESTORE}" ; echo
        elif [[ "${MISSING[*]} " == *"aapt"* ]] && [[ "${MISSING[*]} " == *"google-android-build-tools-installer"* ]]; then
            echo
            echo -e "${RED}ATTENTION:${YELLOW} The following packages conflict with each other please select one:${BLUE}  "
            echo
            options=("aapt" "google-android-build-tools-installer" "help")                    
	    select opt in "${options[@]}"
                do
                    case $opt in
                        "aapt")
                            MISSING=( "${MISSING[@]/google-android-build-tools-installer/}" )
                            rm /tmp/repair_depends/google-android-build-tools-installer*
                            break
                        ;;
                        "google-android-build-tools-installer")
                            MISSING=( "${MISSING[@]/aapt/}" )
                            rm /tmp/repair_depends/aapt*
                            break
                        ;;
                        "help")
                            echo
                            echo -e "${YELLOW}The package google-android-build-tools-installer is large and contains aapt in addition to other packages that may not be necessary to run apktool. We recomend just installing aapt itself.${BLUE}"
                            echo
                            sleep 2
                        ;;
                        *)
                            echo
                            echo -e "Invalid option please enter a valid numerical option"
                        ;;
                        esac
                done         
        fi  
    
    [[ -z ${MISSING[@]} ]] || echo && echo -e "${YELLOW}The following dependencies will be installed:" && sleep 2 && echo && for depends in ${MISSING[@]}; do echo -e "${BLUE}$depends${RESTORE}"; done
    [[ -z "$(ls -A /tmp/repair_depends)" ]] || dpkg -i /tmp/repair_depends/*.deb &>/dev/null ; wait && apt --fix-broken install -y &>/dev/null ; wait
    rm -r -f /tmp/repair_depends
    
    fi
}
chk_inst_depends

TEST_APKTOOL() {
    echo && echo -e "${YELLOW}Testing ${GREEN}Apktool ${YELLOW}please wait..."
    wget -O /tmp/test.apk https://github.com/catenatedgoose/test.apk/blob/master/test.apk?raw=true &>/dev/null ; wait
    [ -f /tmp/test.apk ] && echo && echo -e "${YELLOW}Decompiling...${RESTORE}" && apktool d /tmp/test.apk -o /tmp/test 1>/dev/null 2>/tmp/apk_d_error || echo -e "${RED}[*] ERROR [*]${YELLOW} Test file doesnt exist please send ${RED}ERROR${YELLOW} to developer."
    [ -f /tmp/apk_d_error ] && [ -s /tmp/apk_d_error ] && echo -e "${RED}[*] ERROR [*]${YELLOW} Test file doesnt exist please send ${RED}ERROR${YELLOW} to developer." && cat /tmp/apk_d_error || rm  /tmp/apk_d_error
    [ -f /tmp/test ] && [ -f /tmp/apk_d_error ] || echo && echo -e "${YELLOW}Building...${RESTORE}" && apktool b /tmp/test -o /tmp/fixed.apk 1>/dev/null 2>/tmp/apk_b_error
    [ -f /tmp/apk_b_error -a -s /tmp/apk_b_error ] && echo && echo -e "${RED}[*] ERROR [*]${YELLOW} Apk Build ${RED}ERROR${YELLOW} persists please send the following${YELLOW} to developer:${YELLOW}" && echo && cat /tmp/apk_b_error || rm  /tmp/apk_b_error
    [ ! -f /tmp/apk_d_error -a ! -f /tmp/apk_b_error ] && echo && echo -e "${GREEN}**** Apktool is working and ready to use ****${RESTORE}" && echo && rm -r -f /tmp/*.apk /tmp/test || rm -r/tmp/*_error
}

APKTOOL_UPGRADE() {
    echo && echo -e "${YELLOW}Installing ${GREEN}Apktool 2.4.0 ${YELLOW}this may take a moment please wait...${RESTORE}" ; echo
    axel -n 10 --output=/usr/bin/apktool https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool &>/dev/null ; wait && axel -n 10 --output=/usr/bin/apktool.jar https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.4.0.jar &>/dev/null ; wait && echo && echo -e "${YELLOW}Download complete ${GREEN}apktool ${YELLOW}wrapper and ${GREEN}apktool.jar ${YELLOW}are in /usr/bin"
    [ -e /usr/bin/apktool -a -e /usr/bin/apktool.jar ] && chmod +x /usr/bin/apktool /usr/bin/apktool.jar 
    TEST_APKTOOL
}


APKTOOL_VERSION() {
    echo && echo -e "${YELLOW}Checking the version of Apktool you have installed.${RESTORE}"
    sleep 1
    verCheck=$(apktool --version | cut -d'.' -f2)
    if [ $verCheck -lt 4 ]; then
        echo
        echo -e "${RED}**** ${YELLOW}Apktool is not the latest version! ${RED}****${RESTORE}"
        echo 
        echo -e "${YELLOW}Removing Apktool version $(apktool --version) please wait...${RESTORE}"
        dpkg --purge --force-depends apktool &>/dev/null ; wait
        [[ -e /usr/bin/apktool ]] && rm -f /usr/bin/apktool ; [[ -e /usr/bin/apktool.jar ]] && rm -f /usr/bin/apktool.jar
        APKTOOL_UPGRADE   
    else
        echo
        echo -e "${YELLOW}Apktool is ${GREEN}version 2.4.0.${RESTORE}" 
        sleep 1
        TEST_APKTOOL
    fi

}

[ $(dpkg-query -s apktool &>/dev/null ; echo $?) = 0 -o -e /usr/bin/apktool ] && APKTOOL_VERSION || APKTOOL_UPGRADE
