#!/bin/bash

#####################################################################################################################
#                                                                                                                   #
#                             This script is written by Pierre aka Linoge                                           #
#  This program is open source; you can redistribute it and/or modify it under the terms of the GNU General Public  #
#                 The author bears no responsibility  for malicious or illegal use.                                 #
#                                                                                                                   #
#                                                                                                                   #
#####################################################################################################################

# ~~~~~~~~~~  Environment Setup ~~~~~~~~~~ #
    NORMAL=`echo "\033[m"`           #White text
    MENU=`echo "\033[36m"`           #Cyan text
    NUMBER=`echo "\033[33m"`         #Dark Yellow text
    CONFIRM=`echo "\033[32m"`        #Green text
	LIGHTCONFIRM=`echo "\033[1;32m"` #Light Green text
    RED_TEXT=`echo "\033[31m"`       #Red text
    ENTER_LINE=`echo "\033[33m"`     #Blue text
    JILL_COLOR=`echo "\033[35m"`     #Purple text
    INTRO_TEXT=`echo "\033[102;41m"` #green bg and white text
    INFO=`echo "\033[103;30m"`       #yellow bg
    SUCCESS=`echo "\033[102;30m"`    #green bg
    FGRED=`echo "\033[41m"`          #Red Bg white text
    MENU1=`echo "\033[101;30m"`      #light red bg
    WARP=`echo "\033[106;30m"`       #lightblue bg
    BLACK=`echo "\033[109;30m"`      #Black bg
    END=`echo "\033[0m"`
# ~~~~~~~~~~  Environment Setup ~~~~~~~~~~ #

#################################### Install Bind9 if its not installed ####################################

install_fn(){
if [ ! -x /etc/bind ];then
echo "$warn\nYou need to install Bind9"
  sleep 1
  echo "${MENU}\nDo you want to do it now? (y/n)"
echo "1" > install.log
  read var
    if [ $var = y ];then
    sudo apt-get install bind9 -y
	${END}
    clear
    nameservers_fn
    else
    clear
    exit;
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
echo "${MENU}\nyou seem to already have an configured DNS-server.. do you wish to proceed adding zones? (y/n)${END}"
  read dns
    if [ $dns = y ];then
    clear
    dnsnames_fn
    else
    clear
    show_menu
    fi
else
clear
dnsnames_fn
fi
}

########################### Checking /eth/network/interfaces if DNS-servers are correct ################################

dnsnames_fn(){
content=$( cat /etc/network/interfaces | grep dns-nameservers)
if [ "$?" = 0 ]
then
  echo "${MENU}\nplease check that ${END}${FGRED}$content${END}${MENU} is correct!? (y/n)${END}"
  read dns
    if [ $dns = y ];then
    clear
    interfaces_fn
    else
    clear
    interfaces_fn
    fi
else 
setdns_fn
fi
}

################################ Set ip to /eth/network/interfaces #########################################

interfaces_fn(){
sleep 3
netwok=$( cat /etc/network/interfaces | address)
if [ "$?" = 0 ]
then 
forwarders_fn
else
clear
 echo "${FGRED}You have not set an static IP address! DNS-server will not be reacheble if this machine changes IP all the time.${END}"
 sleep 6
fi
   echo "${MENU}\nDo you want yo set an static ip? now? (y/n)${END}"
   read vip
	if [ $vip = y ];then
	echo "${MENU}\nAre you really sure you know what you are doing? (y/n)${END}"
		read vsur
		if [ $vsur = y ];then
		seeip=$(ifconfig | grep "inet addr" | grep Bcast | cut -d ':' -f2 | cut -d 'B' -f1)
		echo "${MENU}Your current IP is ${END}${LIGHTCONFIRM}$seeip${END}${MENU} make sure to set you IP in same network${END}"
		contents=$( cat /etc/network/interfaces | grep dns-nameservers)
		echo $contents > temp.log
		echo "${MENU}Type in an ip-adress that is free in your network${END}"
		read myip
		echo "${MENU}Type in an your netmask${END}"
		read netmask
		echo "${MENU}Type in an your gateway${END}"
		read gatewaay
		sudo echo "auto lo eth0
		iface lo inet loopback
		iface eth0 inet static" > /etc/network/interfaces
		sudo echo "$myip" >> /etc/network/interfaces
		sudo echo "$netmask" >> /etc/network/interfaces
		sudo echo "$gatewaay" >> /etc/network/interfaces
		cat temp.log | grep dns-nameservers >> /etc/network/interfaces
		echo "${NUMBER}Restarting network card${END}"
		sudo /etc/init.d/networking restart
		clear
		forwarders_fn
		else
		show_menu
		fi
   else
   forwarders_fn
   fi
}

################################ Adding DNS-servers to /eth/network/interfaces #########################################

setdns_fn(){ 
echo "${MENU}\nDo you whant to set DNS-servername to localhost in the network interfaces ( recomended! )? (y/n)${END}"
read vir
if [ $vir = y ];then
sudo echo "dns-nameservers 127.0.0.1" >> /etc/network/interfaces
echo "${NUMBER}Restarting network card${END}"
sudo /etc/init.d/networking restart
sleep 2
clear
interfaces_fn
else
clear
interfaces_fn
fi
}

#################################### Install Bind9 if its not installed - fast setup ####################################

installbind_fn(){
if [ ! -x /etc/bind ];then
echo "$warn\nYou need to install Bind9"
  sleep 1
  echo "${MENU}\nDo you want to do it now? (y/n)"
  read vaar
    if [ $vaar = y ];then
    sudo apt-get install bind9 -y
	${END}
	clear
	zones_fn
    else
    show_menu
    fi
else
echo "${MENU}Bind9 is already installed on this server.. if you made an uninstall ${END}"
echo "${MENU}of bind9 then make sure to do an apt-get purge bind9a                ${END}"
sleep 6
clear
show_menu
fi
clear
zones_fn
}

#################### Setting forwardes to google DNS in /etc/bind/named.conf.options for redundancy ####################

forwarders_fn(){
echo "${MENU}\nDo you whan to set forwarders to google DNS ( recomended! )? (y/n)${END}"
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

############################################ Adding new zones ############################################

zones_fn(){
sudo cp /etc/bind/named.conf.local /etc/bind/named.conf.local.backup
echo "${MENU}Please type in you dns name ( like... mysite.com )${END}"
read Site
echo "zone \"$Site\" {
        type master;
        file \"/etc/bind/db.$Site\";
};" >> /etc/bind/named.conf.local
echo "${MENU}Please type in the ip adress for your dns name ( like... 192.168.1.3  = mysite.com )${END}"
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
echo "${LIGHTCONFIRM}plese verify your setup${END}"
echo $controll
sleep 7
clear
show_menu
}

############################################ Verify zones ############################################

verify_fn(){
lista=$(cat /etc/bind/named.conf.local | grep zone | cut -d '"' -f2 | cut -d '/' -f1)
echo "generating list of zones in conf file...
$lista"
echo ""
echo "${SUCCESS}Please type address to check${END}"
read Sites
controlls=$(dig $Sites | grep $Sites)
clear
echo "${NUMBER}plese verify your setup${END}"
echo $controlls
sleep 7
clear
show_menu
}

############################################ Deleting zones ###########################################

delete_fn(){
cd /etc/bind/
seedb=$(ls db*)
lista=$(cat /etc/bind/named.conf.local | grep zone | cut -d '"' -f2 | cut -d '/' -f1)
echo "generating list of zones in conf file...
$lista"
echo ""
echo "${LIGHTCONFIRM}type what zone you wish to remove (ex mysite.com)${END}"
read dbfile
echo "${MENU}\nAre you sure you want to delete the zone${END}${LIGHTCONFIRM} $dbfile? (y/n)${END}"
read vyr
    if [ $vyr = y ];then
    sudo rm -rf db.$dbfile
    fi
cat /etc/bind/named.conf.local| sed "/$dbfile/,+1 d" > /etc/bind/named.conf.local.new
sudo cp /etc/bind/named.conf.local.new /etc/bind/named.conf.local
show_menu 
}

############################################ Menu ############################################

clear
show_menu(){
    echo "${ENTER_LINE}      Nameserver is  DNS-server setup script    ${END}"
    echo "${ENTER_LINE}     Created for Ubuntulinux by Pierre Goude    ${END}"
    echo "${NORMAL}                                                    ${END}"
    echo "${MENU}*****************Nameserver By Pierre**************${NORMAL}"
    echo "${NORMAL}                                                    ${NORMAL}"
    echo "${MENU}*${NUMBER} 1)${MENU} Install DNS nameserver from scrach on a new server ${NORMAL}"
    echo "${MENU}*${NUMBER} 2)${MENU} Install bind9 and add zones ${NORMAL}"
    echo "${MENU}*${NUMBER} 3)${MENU} Add new zones  ${NORMAL}"
    echo "${MENU}*${NUMBER} 4)${MENU} Delete zones ${NORMAL}"
	echo "${MENU}*${NUMBER} 5)${MENU} Verify zones ${NORMAL}"
    echo "${NORMAL}                                                    ${NORMAL}"
    echo "${MENU}*****************Nameserver By Pierre**************${NORMAL}"
    echo "${ENTER_LINE}Please enter a menu option and enter or ${RED_TEXT}enter to exit. ${NORMAL}"
    read opt
    while [ $opt != "" ]
    do
    if [ $opt = "" ]; then 
            exit;
    else
        case $opt in
        1) clear;
        install_fn;
        ;;

        2) clear;
            installbind_fn;
            ;;

        3) clear;
            zones_fn
            ;;

        4) clear;
            delete_fn;
            ;;
		5) clear;
            verify_fn;
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