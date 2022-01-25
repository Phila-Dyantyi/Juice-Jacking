#!/bin/bash

##########################################This is where the script checks for a phone connection before accessing the data on the phone###########################################

LOCALPATH=$(pwd)
usbcounter=$(lsusb | wc -l)
currentcounter=$usbcounter
#wait for the phone to connect (not mounted)
echo 'Connection is being established...'
while [ $usbcounter -eq $currentcounter ]; do
currentcounter=$(lsusb | wc -l)
done
#######################################################Done checking the phone connection#############################################################################################################





####################################################################This is the where the phone is being mounted######################################################################################
gvfs-mount -li | awk -F= '{if(index($2,"mtp") == 1)system("gvfs-mount "$2)}'

#Here we are waiting to see if the phone is unlocked.
echo 'Congratulations!!! The phone is now Connected. Waiting for unlock...'
until [ -d /run/user/$UID/gvfs/mtp*/* ]; do
:
done
######################################################################The end of mounting the phone###############################################################################################



####################################################################Moving to the file system#######################################################################
cd /run/user/$UID/gvfs/mtp*/*
ls
echo 'FILE SYSTEM IS NOW ACCESSED!'

cd "$LOCALPATH"
#################################################################The END!!!##########################################################################################