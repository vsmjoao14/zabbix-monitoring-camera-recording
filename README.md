# Zabbix monitoring camera recording
This repository provides a Bash script used to validate camera recordings on an NVR (Network Video Recorder). The script is run through Zabbix and makes use of variables obtained from it.

# Requirements:
  - Zabbix 6.0 or higher
  - FFmpeg release date 2023-07-21 or more recent

# Objective:
The purpose of the script is to check that the cameras connected to the NVR are recording correctly, by trying to capture still images (frames) of an RTSP (Real-Time Streaming Protocol) video stream at specific intervals.

# Image:

![image](https://github.com/user-attachments/assets/7f90611d-14db-40e2-981b-3a9a520892ad)

# Usage:
Clone the repository:

```bash
git clone <REPOSITORY_URL>
cd zabbix-monitoring-camera-recording
```

Copy the ffmpeg/ folder to the /opt/ directory:

```bash
cp -r ffmpeg/ /opt/
```

Copy the files camera-record.sh, camera-record-num-of-days.sh, and imagem-convert.sh to the /../externalscripts directory. By default, it is located at: /usr/lib/zabbix/externalscripts/

```bash
cp camera-record.sh camera-record-num-of-days.sh imagem-convert.sh /usr/lib/zabbix/externalscripts/
```

Allow scripts to run:

```bash
cd /usr/lib/zabbix/externalscripts/
chmod +x camera-record-num-of-days.sh camera-record.sh imagem-convert.sh
chmod 755 -R /opt/ffmpeg
chown zabbix:zabbix -R /opt/ffmpeg
```

# Script Content:
## Header
The script should be executed using the Bash interpreter.

## Variables:
The variables are obtained through the execution of the External Scripts item within Zabbix.
- usr: username for authentication on the NVR.
- pass: password for authentication on the NVR.
- ip_addr: IP address of the NVR.
- cam_channel: camera channel to be checked.
- cam_desc: camera description.
- i: time interval in minutes to be subtracted from the current time (initialized with -30).

## Date Calculation:
The date and time of the recording analysis are calculated based on the current time minus the variable i (default: 30 minutes), returning the result in the format YYYY_MM_DD_HH_MM.

## Frame Capture:
The FFmpeg utility is used to capture a frame from the RTSP video stream of the specified channel at the calculated time interval. During the query, the image is compressed and resized to the 500:281p scale. The result is saved in a PNG file.

## File Existence Check:
In this block, the script checks if the PNG file was created in the previous step. If it exists, it prints 1 on the screen confirming that there is video content. Otherwise, the script tries to capture a frame from a different time interval. After that, it checks again if the PNG file exists; if not, it prints 0 indicating that there is no video content.

# Template Contents:
 - 5 Macros
 - 1 Value mapping
 - 5 Items
 - 2 Triggers

## Description:
The base template was created for use with Intelbras NVRs that support RTSP connection. However, it should work with any equipment that uses the RTSP protocol.

## Items:
There are four items with the following names: CAM Recording, CAM Recording Availability %, CAM Recording Image, CAM Recording Num Of Days, and CAM Status. All items are disabled by default. It is recommended to modify, add, and remove items as needed.

The CAM Recording item checks the recording status from now-30m. The 30-minute interval ensures that there will be no overlaps between queries and recordings on the NVR. This interval can be adjusted according to the environment.

The CAM Recording Availability 5m % item calculates the time versus recording availability, returning values in percentage.

The CAM Recording Image item converts the resulting .PNG image from the CAM Recording item to Base64.

The CAM Recording Num Of Days item functions similarly to CAM Recording but acts as now-100d, checking if there is a recording checkpoint 100 days ago. In this item, the condition to return the value 0 (not recording/recorded) is different. The variable "i" is initialized with the value -144000 (100 days in minutes) and, if the recording is not found, 14400 (10 days in minutes) is added to the variable value, trying again until the variable "i" value is 0, at which point it returns that there are no recording checkpoints.

Finally, the CAM Status item checks the asset's availability via ICMPv4.

## Macros:

When applying the template, it is necessary to pay attention to the macros within the corresponding host, as they will define the IP, login, and password of the NVR, as well as the camera channel. As mentioned earlier, macros are extremely important for the connection. Four macros are used: NVR IP, NVR Login, NVR Password, and Camera Channel. There is no specific naming rule for the macros, as long as they match those used within the item key. It is suggested to use the following pattern:

1. NVR IP MACRO:
 - Macro: {$HOSTIP.NVR}
 - Value: Text
 - Description: NVR "NVR_HOSTNAME" IP
2. NVR LOGIN MACRO:
 - Macro: {$USER.NVR}
 - Value: Text
 - Description: User for authentication in NVR "NVR_HOSTNAME"
3. NVR PASSWORD MACRO:
 - Macro: {$PASSWD.NVR}
 - Value: Secret Text
 - Description: Password for authentication in NVR "NVR_HOSTNAME"
4. CAMERA CHANNEL MACRO:
 - Macro: {$CAMCHANNEL.NVR}
 - Value: Secret Text
 - Description: NVR "NVR_HOSTNAME" Cam Channel
5. DIRETÓRIO DA IMAGEM:
 - Macro: {$IMG.DIR}
 - Value: Text
 - Description: Camera image directory (for default /opt/ffmpeg/return-base64/)

## Triggers:

CAM not recording on NVR:
‘count(/template/item_key,#20,"eq","0")>=20’. For recovery: ‘count(/template/item_key,#10,"eq","1")>=10’.

Availability of CAM recording on NVR < 90d:
‘count(/template/item_key,#6,"lt","90")>=6’. For recovery: ‘count(/template/item_key,#3,"ge","90")>=3’.

# Note:

It is recommended to also include another BASE template related to the camera model to monitor items such as ICMP, CPU, Memory, etc.

# Idea: 

Dashboard in Grafana:

![Captura de tela 2024-08-27 210336](https://github.com/user-attachments/assets/8a6331eb-90d9-45fe-b55c-730757e32a8b)
<a href="https://github.com/vsmjoao14/grafana-monitoring-camera-recording" style="display: inline-block; padding: 10px 20px; font-size: 16px; color: white; background-color: #007bff; text-align: center; text-decoration: none; border-radius: 5px;">Grafana Monitoring Camera Recording</a>

# Possible next updates:

  - Identification of image quality and content through AI.
  - Analysis of a longer recording period beyond a single frame.

If you have any questions or suggestions, don't hesitate to contact me:

*E-mail: joao.souza0823@gmail.com*
*LinkedIn: https://www.linkedin.com/in/joaovsouza/*

