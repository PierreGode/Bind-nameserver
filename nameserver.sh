#!/bin/bash

#####################################################################################################################
#                                                                                                                   #
#                     This script is written by Pierre aka Linoge, admin of Webbh4tt                                #
#  This program is open source; you can redistribute it and/or modify it under the terms of the GNU General Public  #
#                 The author bears no responsibility  for malicious or illegal use.                                 #
#                                                                                                                   #
#                                                                                                                   #
#####################################################################################################################

# ~~~~~~~~~~  Environment Setup ~~~~~~~~~~ #
    NORMAL=`echo "\033[m"`
    MENU=`echo "\033[36m"` #Blue
    NUMBER=`echo "\033[33m"` #yellow
    FGRED=`echo "\033[41m"`
    RED_TEXT=`echo "\033[31m"` #Red
    ENTER_LINE=`echo "\033[33m"`
    INTRO_TEXT=`echo "\033[32m"` #green and white text
    INFOS=`echo "\033[103;30m"` #yellow bg
    SUCCESS=`echo "\033[102;30m"` #green bg
    WARNING=`echo "\033[101;30m"` #red bg
    WARP=`echo "\033[106;30m"` #lightblue bg
    BLACK=`echo "\033[109;30m"` #SPACE bg
    END=`echo "\033[0m"`
# ~~~~~~~~~~  Environment Setup ~~~~~~~~~~ #

########################### Install Bind9 if its not installed ################################
install_fn(){
if [ ! -x /etc/bind ];then
echo "$warn\nYou need to install Bind9"
  sleep 1
  echo "$q\nDo you want to do it now? (y/n)"
  read var
    if [ $var = y ];then
    sudo apt-get install bind9 -y
    clear
    nameservers_fn
    else
    clear
    nameservers_fn
    fi
fi
clear
nameservers_fn
}
########################### Checking /eth/network/interfaces for DNS-servers ################################
nameservers_fn(){
content=$( cat /etc/network/interfaces | grep dns-nameservers)
if [ "$?" = 0 ]
then
echo "$q\nyou seem to already have an configured DNS-server.. do you wish to proceed adding zones? (y/n)"
  read dns
    if [ $dns = y ];then
    clear
    zones_fn
    else
    clear
    show_menu
    fi
else
clear
show_menu
fi
clear
interfaces_fn
}
########################### Checking /eth/network/interfaces if DNS-servers are correct ################################
dnsnames_fn(){
content=$( cat /etc/network/interfaces | grep dns-nameservers)
if [ "$?" = 0 ]
then
  echo "$q\nplease check that = $content is correct!? (y/n)"
  read dns
    if [ $dns = y ];then
    clear
    zones_fn
else
clear
interfaces
fi
    fi
}
########################### Adding DNS-servers to /eth/network/interfaces ################################
interfaces_fn(){
echo "${MENU}$q\nDo you whan to set DNS-servername to localhost in the network interfaces ( recomended! )? (y/n)${END}"
read vir
if [ $vir = y ];then
sudo echo "dns-nameservers 127.0.0.1" >> /etc/network/interfaces
clear
forwarders_fn
else
clear
show_menu
fi
}

installbind_fn(){
if [ ! -x /etc/bind ];then
echo "$warn\nYou need to install Bind9"
  sleep 1
  echo "$q\nDo you want to do it now? (y/n)"
  read var
    if [ $var = y ];then
    sudo apt-get install bind9 -y
    else
  echo ""
    fi
fi
clear
zones_fn
}
########################### Setiing forwardes to google DNS in /etc/bind/named.conf.options for redundancy ################################
forwarders_fn(){
echo "${MENU}$q\nDo you whan to set forwarders to google DNS ( recomended! )? (y/n)${END}"
read ver
if [ $ver = y ];then
sudo cp /etc/bind/named.conf.options /etc/bind/named.conf.options.backup
echo "options {
        directory \"/var/cache/bind\";

        // If there is a firewall between you and nameservers you want
        // to talk to, you may need to fix the firewall to allow multiple
        // ports to talk.  See http://www.kb.cert.org/vuls/id/800113

        // If your ISP provided one or more IP addresses for stable
        // nameservers, you probably want to use them as forwarders.
        // Uncomment the following block, and insert the addresses replacing
        // the all-0's placeholder.

         forwarders {
                8.8.8.8;
                8.8.4.4;
         };

        //========================================================================
        // If BIND logs error messages about the root key being expired,
        // you will need to update your keys.  See https://www.isc.org/bind-keys
        //========================================================================
        dnssec-validation auto;

        auth-nxdomain no;    # conform to RFC1035
        listen-on-v6 { any; };
};" > /etc/bind/named.conf.options
fi
clear
zones_fn
}
########################### Adding new zones ################################
zones_fn(){
sudo cp /etc/bind/named.conf.local /etc/bind/named.conf.local.backup
echo "${MENU}Please type in you dns name ( like... iamcool.com )${END}"
read Site
echo "zone \"$Site\" {
        type master;
        file \"/etc/bind/db.$Site\";
};" >> /etc/bind/named.conf.local
echo "${MENU}Please type in the ip adress for your dns name ( like... 192.168.1.3  = iamcool.com )${END}"
read Ip
sudo cp /etc/bind/db.empty /etc/bind/db.$Site
sudo echo "; BIND reverse data file for empty rfc1918 zone
;
; DO NOT EDIT THIS FILE - it is used for multiple zones.
; Instead, copy it, edit named.conf, and use that copy.
;
\$TTL    86400
@       IN      SOA     $Site. root.localhost. (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                          86400 )       ; Negative Cache TTL
;
        IN      A       $Ip
@       IN      NS      localhost." > /etc/bind/db.$Site
sudo service bind9 restart
echo "${SUCCESS}All done!${END}"
sleep 3
controll=$(dig $Site | grep $Site)
clear
echo "plese verify your setup"
echo $controll
sleep 7
clear
show_menu
}

delete_fn(){
cd /etc/bind/
seedb=$(ls db*)
echo $seedb
echo ""
echo "type what zone you wish to remove (ex mysite.com without the db.)"
read dbfile
echo "$q\nAre you sure you want to delete the zone $dbfile? (y/n)"
read vyr
    if [ $vyr = y ];then
    sudo rm -rf db.$dbfile
    fi
cat /etc/bind/named.conf.local| sed "/$dbfile/,+1 d" > /etc/bind/named.conf.local.new
sudo cp /etc/bind/named.conf.local.new /etc/bind/named.conf.local
show_menu 
}
########################### Menu ################################
clear
show_menu(){
    echo "${INTRO_TEXT} Nameserver is  DNS-server setup script    ${INTRO_TEXT}"
    echo "${INTRO_TEXT}Created for Ubuntulinux by Pierre from Webbhatt  ${INTRO_TEXT}"
    echo "${NORMAL}                                                    ${NORMAL}"
    echo "${MENU}*****************NameserverBy*Pierre**************${NORMAL}"
    echo "${NORMAL}                                                    ${NORMAL}"
    echo "${MENU}*${NUMBER} 1)${MENU} Install DNS nameserver from scrach on a new server ${NORMAL}"
    echo "${MENU}*${NUMBER} 2)${MENU} Install bind9 and add zones ${NORMAL}"
    echo "${MENU}*${NUMBER} 3)${MENU} Add new zones  ${NORMAL}"
    echo "${MENU}*${NUMBER} 4)${MENU} Delete zones ${NORMAL}"
    echo "${NORMAL}                                                    ${NORMAL}"
    echo "${MENU}*****************NameserverBy*Pierre**************${NORMAL}"
    echo "${ENTER_LINE}Please enter a menu option and enter or ${RED_TEXT}enter to exit. ${NORMAL}"
    read opt
    while [ opt != '' ]
    do
    if [[ $opt = "" ]]; then 
            exit;
    else
        case $opt in
        1) clear;
        install_fn;
        ;;

        2) clear;
            install_fn;
            ;;

        3) clear;
            zones_fn
            ;;

        4) clear;
            delete_fn;
            ;;

        x)exit;
        ;;

        \n)exit;
        ;;

        *)clear;
        show_menu;
        ;;
    esac
fi
done
}
clear
show_menu