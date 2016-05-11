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

#Install NTP or Chrony for Time Management - Physical Machines only
 if [[ -f "/etc/debian_version" &&  ! -f "/proc/user_beancounters" ]]; then
   if pgrep -x "ntpd" > /dev/null
   then
      echo "√ NTP is running"
   else
      echo "X NTP is not running"
      read -r -n 1 -p "Would like to install ntp? (y/n): " $REPLY
      if [[  $REPLY =~ ^[Yy]$ ]]
      then
        sudo apt-get update
        sudo apt-get install ntp -yyq
        sudo service ntp stop
        sudo ntpdate pool.ntp.org
        sudo service ntp start
      else
      echo -e "\nLisk requires NTP on Debian based systems, exiting."
      exit 0
      fi
   fi
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
        read -r -n 1 -p "Would like to install ntp? (y/n): " $REPLY
        if [[  $REPLY =~ ^[Yy]$ ]]
        then
      yum install ntp ntpdate ntp-doc
      chkconfig ntpd on
      ntpdate pool.ntp.org
      /etc/init.d/ntpd start
      else
      echo -e "\nLisk requires NTP or Chrony on RHEL based systems, exiting."
      exit 0
        fi
      fi
   fi
 elif [[ -f "/proc/user_beancounters" ]]; then
   echo "_ Running OpenVZ VM, NTP and Chrony are not required"
 fi



liskVersion=`curl -s https://downloads.lisk.io/lisk/test/ | grep $UNAME | cut -d'"' -f2`
wget https://downloads.lisk.io/lisk/test/$liskVersion

tar -xvf $liskVersion -C $defaultLiskLocation

rm -f $liskVersion

liskDir=`echo $liskVersion | cut -d'.' -f1`

cd $defaultLiskLocation/$liskDir

bash lisk.sh coldstart
bash lisk.sh stop

cp ~/test/postgresql.conf $defaultLiskLocation/$liskDir/pgsql/data
cp ~/test/liskMemTuner.sh $defaultLiskLocation/$liskDir

bash $defaultLiskLocation/$liskDir/liskMemTuner.sh

bash lisk.sh start


