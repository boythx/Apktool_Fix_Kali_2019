#!/bin/bash 
# Author: catenatedgoose
# Version: 1.3
# Description: A basic fix for apktool in kali linux. This script replaces apktool 2.3.4-dirty with 2.4 so common errors will be avoided. This also adds packages to work with msfvenom.

RED='\033[00;31m'
GREEN='\033[00;32m'
YELLOW='\033[00;33m'
RESTORE='\033[0m'

__apk_tool_fix(){

mapfile -t pkg_depends < <(apt-cache depends apktool | awk -F'Depends:' '{print $1, $2}' | awk '!/</' | cut -d'|' -f1 |  awk 'NF' | awk '$1=$1' | awk '!/openjdk-8-jre-headless/')

for (( i=0; i<${#array_nums[@]}; i++ )); do echo ${array_nums[i]}; done

for depend in "${pkg_depends[@]}"; do 
    pkg_qry=$(dpkg-query -W --showformat='${Status}\n' $depend &>/dev/null ; echo $?)
    if [ $pkg_qry = 0 ]; then
        echo -e "${YELLOW}$depend is ${GREEN}Installed.${RESTORE}"
    else 
        
        echo -e "${YELLOW}$depend is ${RED}missing.${RESTORE}"
        echo -e "${YELLOW}Installing ${RED}$depend ${YELLOW}now.${RESTORE}"
        apt-get install $depend -y &>/dev/null 
        wait
        dpkg-query -W --showformat='${Status}\n' $depend &>/dev/null && echo -e "${YELLOW}$depend is ${GREEN}Installed${RESTORE}" || echo -e "$depend ${RED}Install ERROR${RESTORE}"   
    fi
done 

inst_zipalign=$(dpkg-query -W --showformat='${Status}\n' zipalign &>/dev/null ; echo $?)
if [ $inst_zipalign = 0 ]; then
    echo -e "${YELLOW}zipalign is ${GREEN}Installed.${RESTORE}"
else
    echo -e "${YELLOW}zipalign is ${RED}missing.${RESTORE}"
    echo -e "${YELLOW}Installing ${RED}zipalign ${YELLOW}now.${RESTORE}"
    apt-get install zipalign -y &>/dev/null
    wait
fi

sleep 2

verCheck=$(apktool --version | cut -d'.' -f2)
if [ $verCheck -lt 4 ]; then
    echo
    echo -e "${RED}**** ${YELLOW}Apktool is not the latest version! ${RED}****${RESTORE}"
    echo
    echo -e "${YELLOW}Upgrading apktool to ${GREEN}Apktool 2.4.0 ${YELLOW}please wait...${RESTORE}"
    echo
    sleep 3
    rm -f  /usr/bin/apktool /usr/bin/apktool.jar
    wget -O /usr/bin/apktool https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool &>/dev/nul
    wget -O /usr/bin/apktool.jar https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.4.0.jar &>/dev/null
    wait
    chmod a+x /usr/bin/apktool /usr/bin/apktool.jar        
else
    echo
    echo -e "${GREEN}apktool 2.4.0 or greater already :)${RESTORE}"
    sleep 3
fi

}
__apk_tool_fix

statusCheck=$(apktool --version)
if [ "$statusCheck" == "2.4.0" ]; then
    echo
    echo -e "${GREEN}apktool is ready to be used.${RESTORE}"
else
    echo
    echo -e "${RED}Error: Corrupt or missing binaries. ${YELLOW}Removing all packages and reinstalling please wait...${RESTORE}"
    apt-get purge apktool -y &>/dev/null && apt auto-remove -y &>/dev/null; wait
    apt-get install kali-linux-full -y &>/dev/null; wait
    __apk_tool_fix
    [[ $(apktool --version) = 2.4.0 ]] && exit || echo -e "${RED}Could not resolve ERROR contact developer!${RESTORE}"

fi
