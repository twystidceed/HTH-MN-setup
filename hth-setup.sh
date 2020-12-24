#!/bin/bash
# Twystid's Masternode Setup Script V3.2 for Ubuntu
#
# Script will attempt to auto detect primary public IP address
# This script is capable of installing with or without swap depending on your VPS
# Usage:
# bash hth-setup.sh 
#

#Color codes
RED='\033[0;91m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
PURPLE='\033[1;35m'
NC='\033[0m' # No Color

#TCP port
PORT=65000
RPC=59999

#GLOBAL VARIABLES - Check the daemon deployment section for proper deployment

#this is the Github Source for the binaries

SOURCE=https://github.com/HTHcoin/helpthehomelesscoin/releases/download/0.14.08/homeless-0.14.08-ubuntu18.tar.gz


#The archive itself from the source

ARCHIVE=homeless-0.14.08-ubuntu18.tar.gz

#ADDNODES
ADDNODEA=155.138.198.71:65000
ADDNODEB=173.212.221.11:65000 
ADDNODEC=95.217.67.185:65000

#name of the folder created with the git clone when clonign the repository
FOLDER=HTH-MN-setup

#official name
NAME='Help The Homeless'

#name2 is the actual name of the binary when installed on VPS [CASE SENSISTIVE]
NAME2=helpthehomeless

#Simply the Ticker of the coin for referenceing in the script - no usage case not sensitive
TICKER=HTH

#actual name of the hidden folder for the coin [CASE SENSITIVE]
HIDDEN=.helpthehomeless

#Actual name of the conf file in the hidden folder [CASE SENSITIVE]
CONF=helpthehomeless.conf

#actual name od the coin daemon [CASE SENSITIVE]
DAEMON=helpthehomelessd

#Actual name of the coin daemon -cli [CASE SENSITIVE]
CLI=helpthehomeless-cli

#name of the monitor script [CASE SENSITIVE]
MONITOR=hthmon.sh

#only enable if needed due to binaries being extracted to a second folder within the cloned folder
#FOLDER2=if needed 


#####################################
#     END OF GLOBAL VARIABLES       #
#####################################


#Clear keyboard input buffer
function clear_stdin { while read -r -t 0; do read -r; done; }

#Delay script execution for N seconds
function delay { echo -e "${GREEN}Sleep for $1 seconds...${NC}"; sleep "$1"; }

#Stop daemon if it's already running
function stop_daemon {
    if pgrep -x $DAEMON > /dev/null; then
        echo -e "${YELLOW}Attempting to stop $DAEMON${NC}"
        $CLI stop
        delay 30
        if pgrep -x $DAEMON > /dev/null; then
            echo -e "${RED}$DAEMON daemon is still running!${NC} \a"
            echo -e "${RED}Attempting to kill...${NC}"
            pkill -9 $DAEMON
            delay 30
            if pgrep -x $DAEMON > /dev/null; then
                echo -e "${RED}Can't stop $DAEMON! Reboot and try again...${NC} \a"
                exit 2
            fi
        fi
    fi
}




#Process command line parameters
genkey=$1

clear
echo -e "${PURPLE}####### #     # #     #  #####  ####### ### ######  ${NC}"
echo -e "${PURPLE}   #    #  #  #  #   #  #     #    #     #  #     # ${NC}"
echo -e "${PURPLE}   #    #  #  #   # #   #          #     #  #     # ${NC}"
echo -e "${PURPLE}   #    #  #  #    #     #####     #     #  #     # ${NC}"
echo -e "${PURPLE}   #    #  #  #    #          #    #     #  #     # ${NC}"
echo -e "${PURPLE}   #    #  #  #    #    #     #    #     #  #     # ${NC}"
echo -e "${PURPLE}   #     ## ##     #     #####     #    ### ######  ${NC}"
echo -e
echo -e "${PURPLE}      #     # ### #     # ### #     #  #####  ${NC}"
echo -e "${PURPLE}      ##   ##  #  ##    #  #  ##    # #     # ${NC}"
echo -e "${PURPLE}      # # # #  #  # #   #  #  # #   # #       ${NC}"
echo -e "${PURPLE}      #  #  #  #  #  #  #  #  #  #  # #  #### ${NC}"
echo -e "${PURPLE}      #     #  #  #   # #  #  #   # # #     # ${NC}"
echo -e "${PURPLE}      #     #  #  #    ##  #  #    ## #     # ${NC}"
echo -e "${PURPLE}      #     # ### #     # ### #     #  #####  ${NC}"
echo -e
echo -e "${GREEN}$NAME Masternode Setup Script V3 for Ubuntu LTS${NC}"
echo -e
echo -e "${GREEN}This script contains multiple options - please choose proper selections${NC}"
echo -e
echo -e "${YELLOW}Dont forget to subscribe to the HTH Github for update notifications!${NC}"
echo -e 
sleep 5

enkey=$3
#Enter the new BLS genkey
clear
echo -e "${YELLOW}AXE Coin DIP003 Masternode Setup Script V3 for Ubuntu 18.04 LTS${NC}"
	read -e -p "Enter your BLS key:" genkey3;
              read -e -p "Confirm your BLS key: " genkey4;

#Confirming match
  if [ $genkey3 = $genkey4 ]; then
     echo -e "${GREEN}MATCH! ${NC} \a" 
else 
     echo -e "${RED} Error: BLS key do not match. Restart script and try again...${NC} \a";exit 1
fi
sleep .5
clear

# Determine primary public IP address
sudo apt-get -y install dnsutils
publicip=$(dig +short myip.opendns.com @resolver1.opendns.com)

if [ -n "$publicip" ]; then
    echo -e "${YELLOW}IP Address detected:" $publicip ${NC}
else
    echo -e "${RED}ERROR: Public IP Address was not detected!${NC} \a"
    clear_stdin
    read -e -p "Enter VPS Public IP Address: " publicip
    if [ -z "$publicip" ]; then
        echo -e "${RED}ERROR: Public IP Address must be provided. Try again...${NC} \a"
        exit 1
    fi
fi

	
#DEPENCDENCY INStALL
echo -e "${YELLOW}=====================================================${NC}"
echo -e "${YELLOW}=====================================================${NC}"
echo -e 
echo -e "${PURPLE}===========Dependency Install================${NC}"
echo -e
echo -e "${RED}Skip install for nodes previously configured for time.!${NC}"
echo -e "${RED}IF UNSURE PRESS Y - If you are missing any, the daemon will fail to launch.!${NC}"
echo -e 
echo -e "${GREEN}Select Y or N to continue${NC}"

 read DEPS
 
 if [[ $DEPS =~ "y" ]] ; then
	echo  -e "${GREEN}installing Dependencies${NC}"
	sudo DEBIAN_FRONTEND=noninteractive apt-get update -y
	sudo apt-get -y upgrade
	sudo apt-get -y dist-upgrade
	sudo apt-get -y autoremove
	sudo apt-get -y install wget nano htop jq dtrx
	sudo apt-get -y install libzmq3-dev
	sudo apt-get -y install libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev libboost-test-dev libboost-thread-dev
	sudo apt-get -y install libevent-dev
	sudo apt -y install software-properties-common
	sudo add-apt-repository ppa:bitcoin/bitcoin -y
	sudo apt-get -y update
	sudo apt-get -y install libdb4.8-dev libdb4.8++-dev
	sudo apt-get -y install libminiupnpc-dev
	sudo apt-get -y install fail2ban
	sudo service fail2ban restart
	sudo apt-get install -y libdb5.3++-dev libdb++-dev libdb5.3-dev libdb-dev && ldconfig
	sudo apt-get install -y unzip libzmq3-dev build-essential libssl-dev libboost-all-dev libqrencode-dev libminiupnpc-dev libboost-system1.58.0 libboost1.58-all-dev libdb4.8++ libdb4.8 libdb4.8-dev libdb4.8++-dev libevent-pthreads-2.0-5
	
	else
	if [ -d "/var/lib/fail2ban/" ]; 
		then
			echo -e "${GREEN}Dependencies already installed...Skipping${NC}"
            echo -e "${GREEN}If daemon fails, restart and select Y${NC}"
            sleep 5

		else
			echo -e "${GREEN}Updating system and installing required packages...${NC}"

			sudo DEBIAN_FRONTEND=noninteractive apt-get update -y
			sudo apt-get -y upgrade
			sudo apt-get -y dist-upgrade
			sudo apt-get -y autoremove
			sudo apt-get -y install wget nano htop jq dtrx
			sudo apt-get -y install libzmq3-dev
			sudo apt-get -y install libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev libboost-test-dev libboost-thread-dev
			sudo apt-get -y install libevent-dev
			sudo apt-get instal unzip
			sudo apt -y install software-properties-common
			sudo add-apt-repository ppa:bitcoin/bitcoin -y
			sudo apt-get -y update
			sudo apt-get -y install libdb4.8-dev libdb4.8++-dev
			sudo apt-get install unzip
			sudo apt-get -y install libminiupnpc-dev
			sudo apt-get -y install fail2ban
			sudo service fail2ban restart
			sudo apt-get install -y libdb5.3++-dev libdb++-dev libdb5.3-dev libdb-dev && ldconfig
			sudo apt-get install -y unzip libzmq3-dev build-essential libssl-dev libboost-all-dev libqrencode-dev libminiupnpc-dev libboost-system1.58.0 libboost1.58-all-dev libdb4.8++ libdb4.8 libdb4.8-dev libdb4.8++-dev libevent-pthreads-2.0-5
	fi
fi


#Network Settings
echo -e "${GREEN}Installing Network Settings...${NC}"
{
sudo apt-get install ufw -y
} &> /dev/null
echo -ne '[##                 ]  (10%)\r'
{
sudo apt-get update -y
} &> /dev/null
echo -ne '[######             ] (30%)\r'
{
sudo ufw default deny incoming
} &> /dev/null
echo -ne '[#########          ] (50%)\r'
{
sudo ufw default allow outgoing
sudo ufw allow ssh
} &> /dev/null
echo -ne '[###########        ] (60%)\r'
{
sudo ufw allow $PORT/tcp
sudo ufw allow $RPC/tcp
} &> /dev/null
echo -ne '[###############    ] (80%)\r'
{
sudo ufw allow 22/tcp
sudo ufw limit 22/tcp
} &> /dev/null
echo -ne '[#################  ] (90%)\r'
{
echo -e "${YELLOW}"
sudo ufw --force enable
echo -e "${NC}"
} &> /dev/null
echo -ne '[###################] (100%)\n'

#Generating Random Password for axed JSON RPC
rpcuser=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
rpcpassword=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

echo -e "${YELLOW}=====================================================${NC}"
echo -e "${YELLOW}=====================================================${NC}"
echo -e 
echo -e "${PURPLE}===========Optional SWAP Installation================${NC}"
echo -e
echo -e "${RED}Some providers do not allow you to install swap!${NC}"
echo -e 
echo -e "${GREEN}If you have VPS with locked swap select N to continue${NC}"
echo -e "${GREEN}If you need to install SWAP or are unsure select Y${NC}"
echo -e
echo -e "${YELLOW}=====================================================${NC}"
echo -e "${YELLOW}=====================================================${NC}"
echo -e


echo -e "${GREEN}Do you wish to install SWAP Y or N ?${NC} \n"
 read SWAP
 
	if [[ $SWAP =~ "y" ]] ; then
			echo "installing SWAP"
			if grep -q "swapfile" /etc/fstab; then
				echo -e "${GREEN}Skipping disk swap configuration...${NC} \n"
			else
				echo -e "${YELLOW}Creating 2GB disk swap file. \nThis may take a few minutes!${NC} \a"
				touch /var/swap.img
				chmod 600 /var/swap.img
				dd if=/dev/zero of=/var/swap.img bs=1024k count=2000
				mkswap /var/swap.img 2> /dev/null
				swapon /var/swap.img 2> /dev/null
				if [ $? -eq 0 ]; then
					echo '/var/swap.img none swap sw 0 0' >> /etc/fstab
					echo -e "${GREEN}Swap was created successfully!${NC} \n"
				else
					echo -e "${RED}Operation not permitted! Optional swap was not created.${NC} \a"
					rm /var/swap.img
				fi
			fi
	fi
	clear
	
	
	
# INSTALLING BINARIES 	
sudo apt-get install -y dtrx
cd ~/$FOLDER
	sudo wget $SOURCE
	sudo dtrx -n -f $ARCHIVE
	rm -rf $ARCHIVE
	clear
		
# Deploy binaries to /usr/bin
 cd ~/$FOLDER/
	sudo cp $NAME2* /usr/bin/
	sudo chmod 755 -R ~/$FOLDER
	sudo chmod 755 /usr/bin/$NAME2*
 
 # Deploy masternode monitoring script
 cp ~/$FOLDER/$MONITOR /usr/local/bin/
	sudo chmod 711 /usr/local/bin/$MONITOR
 
 #Create datadir
 if [ ! -f ~/$HIDDEN/$CONF ]; then 
 	sudo mkdir ~/$HIDDEN
 fi

echo -e "${YELLOW}Creating $CONF...${NC}"

cat <<EOF > ~/.helpthehomeless/helpthehomeless.conf
rcuser=$rpcuser
rpcpassword=$rpcpassword
EOF

sudo chmod 755 -R ~/$HIDDEN/$CONF


# Create conf
cat <<EOF > ~/$HIDDEN/$CONF

rpcuser=$rpcuser
rpcpassword=$rpcpassword
rpcallowip=127.0.0.1
#----
listen=1
server=1
daemon=1
#----
masternode=1
masternodeblsprivkey=$genkey3
externalip=$publicip
#----
addnode=$ADDNODEA
addnode=$ADDNODEB
addnode=$ADDNODEC
EOF

#Finally, starting daemon with new $CONF
$DAEMON -daemon
delay 10

#Setting auto start cron job daemon
cronjob="@reboot sleep 30 && $DAEMON -daemon"
crontab -l > tempcron
if ! grep -q "$cronjob" tempcron; then
    echo -e "${GREEN}Configuring crontab job...${NC}"
    echo $cronjob >> tempcron
    crontab tempcron
fi
rm tempcron

echo -e "========================================================================
${YELLOW}Masternode setup is complete!${NC}
========================================================================
Masternode was installed with VPS IP Address: ${YELLOW}$publicip${NC}
Masternode BLS Key: ${YELLOW}$genkey3${NC}
======================================================================== \a"
clear_stdin
read -p "*** Press any key to continue ***" -n1 -s

echo -e 
"
Currently your masternode is syncing with the $TICKER network...
The following screen will display in real-time
the list of peer connections, the status of your masternode,
node synchronization status and additional network and node stats.
"
clear_stdin
read -p "*** Press any key to continue ***" -n1 -s

echo -e "
${GREEN}...scroll up to see previous screens...${NC}
Here are some useful commands and tools for masternode troubleshooting:
========================================================================
To view masternode configuration produced by this script in $CONF:
${YELLOW}cat ~/$HIDDEN/$CONF${NC}
Here is your $CONF generated by this script:
-------------------------------------------------${YELLOW}"
cat ~/$HIDDEN/$CONF
echo -e "${NC}-------------------------------------------------
NOTE: To edit $CONF, first stop the $DAEMON daemon,
then edit the $CONF file and save it in nano: (Ctrl-X + Y + Enter),
then start the $DAEMON daemon back up:
             to stop:   ${YELLOW}$CLI stop${NC}
             to edit:   ${YELLOW}nano ~/$HIDDEN/$CONF${NC}
             to start:  ${YELLOW}$DAEMON -daemon{NC}
========================================================================
To view %TICKER debug log showing all MN network activity in realtime:
             ${YELLOW}tail -f ~/$HIDDEN/debug.log${NC}
========================================================================
To monitor system resource utilization and running processes:
                   ${YELLOW}htop${NC}
========================================================================
To view the list of peer connections, status of your masternode, 
sync status etc. in real-time, run the $MONITOR script:
                 ${YELLOW}$MONITOR${NC}
or just type 'node' and hit <TAB> to autocomplete script name.
========================================================================
Enjoy your $TICKER Masternode and thanks for using this setup script!

If you found this script useful, please donate to : 
${GREEN} BTC ${NC} - ${YELLOW} bc1q6fwu7sm8jv06xgcx74w556mcjs0vc2vk5glux8 ${NC}
${GREEN} HTH ${NC} - ${YELLOW} hX54dpap61pjWsAt2TFwFjYZFMdSRzWcvt ${NC}
${GREEN} ETH ${NC} - ${YELLOW} 0xaC314385d7B99E0e44666309652CAb8FB2f9B1D6 ${NC}

...and make sure to check back for updates!

Contact Twystidceed#4126 on discord if you need additional support

Do not forget to follow the HTH GitHub and Discords so you do not miss out on important Updates!!
"
delay 10
# Run $MONITOR
sudo $MONITOR

# EOF
