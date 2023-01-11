#!/bin/bash
#11/01/2023
#Script to download a list of Youtube url with Youtube-dl by manon

url="${1}"
video_name=$(youtube-dl "$url" -e 2>/dev/null)
url_list="/srv/yt/url_list.txt"

download() {
    mkdir /srv/yt/downloads/"${video_name}"
    youtube-dl "${url}" --output "/srv/yt/downloads/${video_name}/${video_name}.mp4" >/dev/null
    touch /srv/yt/downloads/"${video_name}"/description
    youtube-dl "${url}" --get-description >"/srv/yt/downloads/${video_name}/description" >/dev/null
    echo "Video ${url} was downloaded."
    echo "File path : /srv/yt/downloads/${video_name}/${video_name}.mp4"
    echo "[$(date "+%y/%m/%d %H:%M:%S")] Video ${video_name} was downloaded. File path : /srv/yt/downloads/${video_name}/${video_name}.mp4" >> /var/log/yt/download.log
}

if [ ! -d $"/srv/yt/downloads" ]; then
    echo "no directory named /srv/yt/downloads"
    exit 1
fi
if [ ! -d $"/var/log/yt" ]; then
    echo "no directory named /var/log/yt"
    exit 1
fi

while true
do
    while read -r file
    do
        if [[ -ne "${file}" ]]; then
            if echo "${file}" | grep -q "https://www.youtube.com"; then
                download "${file}"
            else
                echo "not a youtube url"
            fi
            sed -i '1d' ${url_list}
        fi
    sleep 5
    done <<< "$(cat "${url_list}")"
done
