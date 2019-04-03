#!/bin/bash 
# Author: catenatedgoose
# Description: A basic fix for apktool in kali linux. This script replaces apktool 2.3.4-dirty with 2.4 so common errors will be avoided. This also adds packages to work with msfvenom.

###############################
########## Libraries ##########
###############################
# aapt                        #
# android-framework-res       #
# android-libaapt             #
# android-libandroidfw        #     
# android-libbacktrace        #
# android-libbase             #
# android-libcutils           #
# android-liblog              #
# android-libunwind           #
# android-libutils            #
# android-libziparchive       #
# junit                       #
# libantlr-java               #
# libantlr3-runtime-java      #
# libapache-pom-java          #
# libatinject-jsr330-api-java #      
# libcommons-cli-java         #
# libcommons-io-java          #
# libcommons-lang3-java       #         
# libcommons-parent-java      #
# libguava-java               #
# libjaxp1.3-java             #
# libjsr305-java              #
# libprotobuf-lite17          #
# libsmali-java               #
# libstringtemplate-java      # 
# libxmlunit-java             # 
# libxpp3-java                #
# libyaml-snake-java          #
# libzopfli1                  #                                    
###############################

##############
# Dependents #
##############
# apktool    #
# zipalign   #
##############


RED='\033[00;31m'
GREEN='\033[00;32m'
YELLOW='\033[00;33m'
RESTORE='\033[0m'

echo -e "${YELLOW}Installing any missing libraries and dependencies please wait...${RESTORE}"

apt-get install aapt android-framework-res android-libaapt android-libandroidfw android-libbacktrace android-libbase android-libcutils android-liblog android-libunwind android-libutils android-libziparchive junit libantlr-java libantlr3-runtime-java libapache-pom-java libatinject-jsr330-api-java libcommons-cli-java libcommons-io-java libcommons-lang3-java libcommons-parent-java libguava-java libjaxp1.3-java libjsr305-java libprotobuf-lite17 libsmali-java libstringtemplate-java libxmlunit-java libxpp3-java libyaml-snake-java libzopfli1 apktool zipalign -y &>/dev/null

echo
echo -e "${GREEN}Libraries and dependencies are installed.${RESTORE}"
sleep 2

echo
echo -e "${YELLOW}Checking apktool version and modifying if needed.${RESTORE}"
sleep 2
echo 
chk_inst_apktool=$(dpkg-query -s apktool &>/dev/null ; echo $?)

if [ $chk_inst_apktool = 0 ]; then
    verCheck=$(apktool --version | cut -d'.' -f2)
    if [ $verCheck -lt 4 ]; then
        echo -e "${YELLOW}Upgrading apktool to apktool 2.4${RESTORE}"
        echo
        sleep 3
        rm -f  /usr/bin/apktool /usr/bin/apktool.jar
        wget -O /usr/bin/apktool https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool &>/dev/nul
        wget -O /usr/bin/apktool.jar https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.4.0.jar &>/dev/null
        wait
        chmod a+x /usr/bin/apktool /usr/bin/apktool.jar
            
    else
        echo -e "${GREEN}apktool 2.4.0 or greater already..${RESTORE}"
        echo
        sleep 3
    fi

else
    echo -e "${RED}No version of apktool was detected. Please contact developer.${RESTORE}"
fi

statusCheck=$(apktool --version)
if [ "$statusCheck" == "2.4.0" ]; then
    echo -e "${GREEN}apktool is ready to be used.${RESTORE}"
    sleep 3
else
    echo -e "${RED}Something went wrong contact developer!${RESTORE}"
    sleep 3
fi


