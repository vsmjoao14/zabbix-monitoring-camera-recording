# Variables
usr="$1"
pass="$2"
ip_addr="$3"
cam_channel="$4"
cam_desc="$5"
i=-144000

# While loop to keep trying until i is 0
while [ $i -lt 0 ]
do
    # Decrease the current time by the value of variable i
    date=$(date -d "$current_date - $i minutes" +"%Y_%m_%d_%H_%M")

    # Take a snapshot of the channel
    /opt/ffmpeg/ffmpeg/ffmpeg -i "rtsp://$usr:$pass@$ip_addr:554/cam/playback?channel=$cam_channel&starttime=${date}_00&endtime=${date}_29" -frames:v 1 -update 1 -timeout 5 "/opt/ffmpeg/return-img/NVR-$ip_addr-$cam_channel-$cam_desc-0-90.png" &> /dev/null

    # True/False condition for the taken snapshot
    if [ -e "/opt/ffmpeg/return-img/NVR-$ip_addr-$cam_channel-$cam_desc-0-90.png" ]; then
        existe="true"
        # Record the return
        echo $((i * -1))
        # Remove the previously created PNG file
        rm "/opt/ffmpeg/return-img/NVR-$ip_addr-$cam_channel-$cam_desc-0-90.png"
        break
    else
        # Try to create the second PNG file
        /opt/ffmpeg/ffmpeg/ffmpeg -i "rtsp://$usr:$pass@$ip_addr:554/cam/playback?channel=$cam_channel&starttime=${date}_30&endtime=${date}_59" -frames:v 1 -update 1 -timeout 5 "/opt/ffmpeg/return-img/NVR-$ip_addr-$cam_channel-$cam_desc-0-90.png" &> /dev/null

        if [ -e "/opt/ffmpeg/return-img/NVR-$ip_addr-$cam_channel-$cam_desc-30-90.png" ]; then
            existe="true"
            # Record the return
            echo $((i * -1))
            # Remove the previously created PNG file
            rm "/opt/ffmpeg/return-img/NVR-$ip_addr-$cam_channel-$cam_desc-30-90.png"
            break
        else
            # Subtract 1440 from the value of variable i
            i=$((i+14400))
        fi
    fi
    sleep 2s
done

# If the while loop ends and no image is found, print 0
if [ "$existe" == "false" ]; then
    echo "0"
fi