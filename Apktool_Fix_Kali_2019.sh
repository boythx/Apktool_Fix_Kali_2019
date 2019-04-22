#!/bin/bash 
# Author: catenatedgoose
# Version: 1.6
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
echo -e "${YELLOW}                     Apktool_Fix_Kali_2019 Version 1.6${BLUE}"
echo
sleep 2

con_chk=$(wget -q --tries=5 --timeout=20 --spider http://google.com ; echo $?)
if [[ $con_chk != 0 ]]; then
        echo -e "${RED}Warning!${YELLOW} This script needs an internet connection!"
        echo
        echo "Please connect to the internet and try again."
        exit
fi

__apk_tool_fix(){ 
    mapfile -t pkg_depends < <(apt-cache depends apktool | cut -d':' -f2 | sed  "s/^[ \t]*//;/<java7-runtime-headless>/d" | sort -u)
  
    x=0
    echo
    for depend in "${pkg_depends[@]}"; do 
        pkg_qry=$(dpkg-query -s $depend &>/dev/null ; echo $?)
        if [ $pkg_qry = 0 ]; then
            echo -e "${YELLOW}$depend is ${GREEN}Installed.${RESTORE}"
        else 
            x=1
            echo -e "${YELLOW}$depend is ${RED}missing.${RESTORE}"
            ARRAY+=($depend)
        fi
    done 

    inst_zipalign=$(dpkg-query -s zipalign &>/dev/null ; echo $?)
    if [ $inst_zipalign = 0 ]; then
        echo -e "${YELLOW}zipalign is ${GREEN}Installed.${RESTORE}"
    else
        echo -e "${YELLOW}zipalign is ${RED}missing.${RESTORE}"
        echo -e "${YELLOW}Installing ${RED}zipalign ${YELLOW}now.${RESTORE}"
        apt-get install zipalign -y &>/dev/null
        wait
    fi

    [[ $x = 1 ]] && echo && echo -e "${RED}**** ${YELLOW}Fixing missing dependencies now ${RED}****${RESTORE}" && apt --fix-broken install -y &>/dev/null && wait && echo || echo && echo -e "${GREEN}All dependencies are installed for Apktool :)${RESTORE}"   

    sleep 2

    verCheck=$(apktool --version | cut -d'.' -f2)
    if [ $verCheck -lt 4 ]; then
        echo
        echo -e "${RED}**** ${YELLOW}Apktool is not the latest version! ${RED}****${RESTORE}"
        echo
        echo -e "${YELLOW}Upgrading Apktool to Apktool 2.4.0 ${YELLOW}please wait...${RESTORE}"
        echo
        sleep 3
        rm -f  /usr/bin/apktool /usr/bin/apktool.jar
        wget -O /usr/bin/apktool https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool &>/dev/nul
        wget -O /usr/bin/apktool.jar https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.4.0.jar &>/dev/null
        wait
        chmod a+x /usr/bin/apktool /usr/bin/apktool.jar        
    else
        echo
        echo -e "${GREEN}Apktool is version 2.4.0 or greater already :)${RESTORE}"
        sleep 3
    fi

}
__apk_tool_fix

statusCheck=$(apktool --version)
if [ "$statusCheck" == "2.4.0" ]; then
    msf_inst_chk=$(dpkg -s metasploit-framework &>/dev/null; echo $?)
    if [ $msf_inst_chk = 0 ]; then
        echo
        echo -e "${YELLOW}Testing Apktool please wait...${YELLOW}"
        echo
        sleep 2
        __apk_tool_fix_chk(){
            rm -f -r /tmp/test /tmp/*error /tmp/*.apk # Clean up if script is ran multiple times
            msf_test=$(msfvenom -p android/meterpreter/reverse_tcp LHOST=localhost LPORT=4444 R -o /tmp/test.apk &>/dev/null) 
            [ -f /tmp/test.apk ] && echo -e "${YELLOW}Decompiling Apk with Apktool${YELLOW}...${RESTORE}" && apktool d /tmp/test.apk -o /tmp/test 1>/dev/null 2>/tmp/apk_d_error || echo -e "${RED}[*] ERROR [*]${YELLOW} Test file doesnt exist please send ${RED}ERROR${YELLOW} to developer."
            [ -f /tmp/apk_d_error ] && [ -s /tmp/apk_d_error ] && echo -e "${RED}[*] ERROR [*]${YELLOW} Test file doesnt exist please send ${RED}ERROR${YELLOW} to developer." && cat /tmp/apk_d_error || rm  /tmp/apk_d_error
       	    [ -f /tmp/test ] && [ -f /tmp/apk_d_error ] || echo && echo -e "${YELLOW}Building decompiled Apk with Apktool${YELLOW}...${RESTORE}" && apktool b /tmp/test -o /tmp/fixed.apk 1>/dev/null 2>/tmp/apk_b_error
            [ -f /tmp/apk_b_error ] && [ -s /tmp/apk_b_error ] && echo -e "${RED}[*] ERROR [*]${YELLOW} Apk Build ${RED}ERROR${YELLOW} persists please send ${RED}ERROR${YELLOW} to developer." && cat /tmp/apk_b_error || rm  /tmp/apk_b_error
       	    [ -f /tmp/apk_d_error ] || [ -f /tmp/apk_b_error ] || echo && echo -e "${GREEN}**** Apktool is working and ready to use :) ****${RESTORE}" && echo && rm -r -f /tmp/*.apk /tmp/test
            
        }

        __apk_tool_fix_chk

    else 
        echo
        echo -e "${YELLOW}Metasploit-Framework was not detected. Apk could not be generated to test Apktool. Please test Apktool manually and report any ${RED}ERRORS${YELLOW} to developer.${RESTORE}."
        exit
    fi

fi


    mapfile -t pkg_depends < <(apt-cache depends apktool | cut -d':' -f2 | sed  "s/^[ \t]*//;/<java7-runtime-headless>/d" | sort -u)
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
            cd /tmp && apt-get download $depend &>/dev/null && cd $pwd
            ARRAY+=($depend)
        fi
    done
 
if [[ $x = 1 ]]; then 
            echo    
            echo -e "${YELLOW}The following packages will be installed:"
            echo -e "${GREEN}${ARRAY[@]}" 
            sleep 3
            dpkg -i /tmp/*.deb &>/dev/null ; wait && rm /tmp/*.deb
           
              #revise  for dbl_chk in "${pkg_depends[@]}"; do 
                    pkg_qry=$(dpkg-query -s $depend &>/dev/null ; echo $?)
                    if [ $pkg_qry = 0 ]; then
                        x=0
                    else 
                        x=1
                     fi
                 done
         
fi
