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

