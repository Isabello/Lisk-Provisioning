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
      echo "√ ntp is running"
   else
      echo "X ntp is not running"
      read -r -n 1 -p "Would like to install ntp? (y/n): " $REPLY
      if [[  $REPLY =~ ^[Yy]$ ]]
      then
        sudo apt-get update
        sudo apt-get install ntp -yyq
        sudo service ntp stop
        sudo ntpdate pool.ntp.org
        sudo service ntp start
      fi
   fi
 elif [[ -f "/etc/redhat-release" &&  ! -f "/proc/user_beancounters" ]]; then
   if pgrep -x "ntpd" > /dev/null
   then
      echo "√ ntp is running"
   else
      if pgrep -x "chronyd" > /dev/null
      then
        echo "√ chrony is running"
      else
        echo "X ntp and chrony are not running"
        read -r -n 1 -p "Would like to install ntp? (y/n): " $REPLY
        if [[  $REPLY =~ ^[Yy]$ ]]
        then
      yum install ntp ntpdate ntp-doc
      chkconfig ntpd on
      ntpdate pool.ntp.org
      /etc/init.d/ntpd start
        fi
      fi
   fi
 elif [[ -f "/proc/user_beancounters" ]]; then
   echo "_ Running OpenVZ VM"
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


