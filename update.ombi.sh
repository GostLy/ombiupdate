#!/bin/bash
DATE=$(date +"%m.%d.%Y")
OMBI_PATH="/opt/Ombi"
OMBI_BAK=$HOME'/tmp/ombi.bak-'$DATE
if [ -d "$OMBI_BAK" ]; then
        rm -rf "$OMBI_BAK"
fi
FILENAME_DL="linux-x64.tar.gz"
SERVICE_NAME="ombi.service"
OMBI_URL="https://github.com/Ombi-app/Ombi/releases"
VERSION=$(curl -s $OMBI_URL | grep "$FILENAME_DL" | grep -Po ".*\/download\/v([0-9\.]+).*" | awk -F'/' '{print $6}' | tr -d 'v' | sort -V | tail -1)
# echo 'version: '$VERSION # DEBUG
SAVE_AS=$HOME'/tmp/ombi.'$VERSION'.x64.tar.gz'
OMBI_SAVE_PATH=$HOME'/tmp/ombi.'$VERSION'.x64'
if [ -f "$SAVE_AS" ]; then
        echo "No update necessary, Ombi v$VERSION is installed and is the latest release."
else
        sudo systemctl stop ${SERVICE_NAME} # Stop the Ombi service.
        wget -O $SAVE_AS "$OMBI_URL/download/v$VERSION/$FILENAME_DL" # Download the new version of Ombi
        xt $SAVE_AS # Extract the new version of Ombi
        mkdir "$OMBI_BAK" # Create a backup directory for the current files.
        mv $OMBI_PATH/* $OMBI_BAK/ # Move current Ombi files to the backup directory.
        mv $OMBI_SAVE_PATH/* $OMBI_PATH/ # Move new version of Ombi files to the Ombi app directory.
        rm -rf $OMBI_SAVE_PATH # Remove the empty directory where the new version was extracted.
        sudo systemctl start ombi.service # Start the Ombi service.
        sudo systemctl status ombi.service # Show us the status of Ombi after the update.
        printf "\nPrevious version of Ombi files have been backed up to %s\n\n\t\tOmbi - Update to v%s complete.\n\n" "$OMBI_BAK" "$VERSION"
fi
