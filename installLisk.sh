#!/bin/bash
####################################################
#Lisk Installation Script
#
#
#
#
#
####################################################

#Variable Declaration
UNAME=$(uname)-$(uname -m)
echo $UNAME
defaultLiskLocation=~

#Verification Checks
if [ "$USER" == "root" ]; then
  echo "Error: Lisk should not be installed be as root. Exiting."
  exit 1
fi

#Install NTP or Chrony for Time Management - Physical Machines only - Courtesy of MrV
if [[ "$(uname)" == "Linux" ]]; then
 if [[ -f "/etc/debian_version" &&  ! -f "/proc/user_beancounters" ]]; then
   if pgrep -x "ntpd" > /dev/null
    then
      echo "√ NTP is running"
    else
      echo "X NTP is not running"
      read -r -n 1 -p "Would like to install NTP? (y/n): " $REPLY
	  if [[  $REPLY =~ ^[Yy]$ ]]
		then
        sudo apt-get update
        sudo apt-get install ntp -yyq
        sudo service ntp stop
        sudo ntpdate pool.ntp.org
        sudo service ntp start
			if pgrep -x "ntpd" > /dev/null
				then
					echo "√ NTP is running"
				else
					echo -e "\nLisk requires NTP running on Debian based systems. Please check /etc/ntp.conf and correct any issues."
					exit 0
			fi
		else
		echo -e "\nLisk requires NTP on Debian based systems, exiting."
		exit 0
	  fi
   fi #End Debian Checks
   
 elif [[ -f "/etc/redhat-release" &&  ! -f "/proc/user_beancounters" ]]; then
   if pgrep -x "ntpd" > /dev/null
   then
      echo "√ NTP is running"
   else
      if pgrep -x "chronyd" > /dev/null
      then
        echo "√ Chrony is running"
      else
        echo "X NTP and Chrony are not running"
        read -r -n 1 -p "Would like to install NTP? (y/n): " $REPLY
        if [[  $REPLY =~ ^[Yy]$ ]]
        then
      sudo yum install ntp ntpdate ntp-doc
      sudo chkconfig ntpd on
      sudo ntpdate pool.ntp.org
      sudo  /etc/init.d/ntpd start
		if pgrep -x "ntpd" > /dev/null
				then
					echo "√ NTP is running"
				else
					echo -e "\nLisk requires NTP running on Debian based systems. Please check /etc/ntp.conf and correct any issues."
					exit 0
			fi
      else
      echo -e "\nLisk requires NTP or Chrony on RHEL based systems, exiting."
      exit 0
        fi
      fi
   fi #End Redhat Checks
   
 elif [[ -f "/proc/user_beancounters" ]]; then
   echo "_ Running OpenVZ VM, NTP and Chrony are not required"
 fi
elif [[ "$(uname)" == "FreeBSD" ]]; then
	if pgrep -x "ntpd" > /dev/null
	   then
		  echo "√ ntp is running"
	   else
		  echo "X ntp is not running"
		  read -r -n 1 -p "Would like to install ntp? (y/n): " $REPLY
		  if [[  $REPLY =~ ^[Yy]$ ]]
		  then
		  pkg_add -rv  ntp
		#work in progress for ntp install on freebsd
		  else
		  echo -e "\nLisk requires NTP FreeBSD based systems, exiting."
		  exit 0
	    fi
    fi #End FreeBSD Checks
elif [[ "$(uname)" == "Darwin" ]]; then
	if pgrep -x "ntpd" > /dev/null
	   then
		    echo "√ NTP is running"
	   else
			sudo launchctl load /System/Library/LaunchDaemons/org.ntp.ntpd.plist
			sleep 1
			if pgrep -x "ntpd" > /dev/null
				then
					echo "√ NTP is running"
				else
				echo -e "\nNTP did not start, Please verify its configured on your system"
				exit 0
			fi
	fi	#End Darwin Checks
fi #End NTP Checks



liskVersion=`curl -s https://downloads.lisk.io/lisk/test/ | grep $UNAME | cut -d'"' -f2`
liskDir=`echo $liskVersion | cut -d'.' -f1`

echo -e "\nDownloading current Lisk binaries: "$liskVersion

wget -q  https://downloads.lisk.io/lisk/test/$liskVersion

echo -e "Extracting Lisk binaries to "$defaultLiskLocation/$liskDir

tar -xf $liskVersion -C $defaultLiskLocation 

echo -e "\nCleaning up downloaded files"
rm -f $liskVersion



cd $defaultLiskLocation/$liskDir

echo -e "\nColdstarting Lisk for the first time"
bash lisk.sh coldstart

echo -e "\nStopping Lisk to perform database tuning"
bash lisk.sh stop


wget -q https://raw.githubusercontent.com/Isabello/Lisk-Provisioning/master/liskMemTuner.sh
wget -q --directory-prefix=$defaultLiskLocation/$liskDir/pgsql/data -O https://raw.githubusercontent.com/Isabello/Lisk-Provisioning/master/postgresql.conf 

echo -e "\nExecuting database tuning operation"
bash $defaultLiskLocation/$liskDir/liskMemTuner.sh

echo -e "\nStarting Lisk with all parameters in place."
bash lisk.sh start

