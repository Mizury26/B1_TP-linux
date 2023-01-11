#!/bin/bash
#11/01/2023
##Youtube-dl script by manon
if [ ! -d $"/srv/yt/downloads" ]; then
echo "no directory named /srv/yt/downloads"
exit 1
fi
if [ ! -d $"/var/log/yt" ]; then
echo "no directory named /var/log/yt"
exit 1
fi
video_name=$(youtube-dl "$1" -e 2>/dev/null)
mkdir /srv/yt/downloads/"${video_name}"
youtube-dl "$1" --output "/srv/yt/downloads/${video_name}/${video_name}.mp4" >/dev/null
touch /srv/yt/downloads/"${video_name}"/description
youtube-dl "$1" --get-description >"/srv/yt/downloads/${video_name}/description" >/dev/null
echo "Video $1 was downloaded."
echo "File path : /srv/yt/downloads/${video_name}/${video_name}.mp4"
echo "[$(date "+%y/%m/%d %H:%M:%S")] Video ${video_name} was downloaded. File path : /srv/yt/downloads/${video_name}/${video_name}.mp4" >> /var/log/yt/download.log