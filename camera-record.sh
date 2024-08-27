#!/bin/bash

# Script used for validating camera recordings on the Intelbrás NVR
# Variable values are obtained through Zabbix macros

# Variables
usr="$1"
pass="$2"
ip_addr="$3"
cam_channel="$4"
cam_desc="$5"
i=-30

# Decrease the current time by the value of variable i
date=$(date -d "$current_date - $i minutes" +"%Y_%m_%d_%H_%M")

# Take a snapshot of the channel and compress the image

/opt/ffmpeg/ffmpeg/ffmpeg -y -i "rtsp://$usr:$pass@$ip_addr:554/cam/playback?channel=$cam_channel&starttime=${date}_00&endtime=${date}_29" -frames:v 1 -q:v 25 -vf scale=500:281 -update 1 -timeout 5 "/opt/ffmpeg/return-img/NVR-$ip_addr-$cam_channel-$cam_desc.jpg" &> /dev/null

# True/False condition for the taken snapshot
if [ -e "/opt/ffmpeg/homolog/return-img/NVR-$ip_addr-$cam_channel-$cam_desc.jpg" ]; then
    existe="true"
    # Record the return
    echo "1"
else
    # Try to create the second JPG file and compress the image
    /opt/ffmpeg/ffmpeg/ffmpeg -y -i "rtsp://$usr:$pass@$ip_addr:554/cam/playback?channel=$cam_channel&starttime=${date}_30&endtime=${date}_59" -frames:v 1 -q:v 25 -vf scale=500:281 -update 1 -timeout 5 "/opt/ffmpeg/return-img/NVR-$ip_addr-$cam_channel-$cam_desc.jpg" &> /dev/null

    if [ -e "/opt/ffmpeg/return-img/NVR-$ip_addr-$cam_channel-$cam_desc.jpg" ]; then
        existe="true"
        # Record the return
        echo "1"
    else
        existe="false"
        echo "0"
    fi
fi

sleep 5s