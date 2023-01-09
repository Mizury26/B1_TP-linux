#!/bin/bash
echo "Machine name : $(hostnamectl hostname)"
echo "OS $(cat /etc/os-release | head -n 2) and kernel version is $(uname -r)"
echo "IP : $(ip a | grep enp0s8 | grep inet | tr -s ' ' | cut -d'/' -f1 | cut -d ' ' -f3)"
echo "RAM : $(free -h | grep Mem | tr -s ' ' | cut -d ' ' -f4) memory available on $(free -h | grep Mem | tr -s ' ' | cut -d ' ' -f2) total memory"
echo "Disque : $(df -h | grep ' /$' |tr -s ' ' | cut -d' ' -f4) space left"


echo "Top 5 processes by RAM usage :"
processes="$(ps -e -o cmd= --sort=-%mem | head -n5 | cut -d' ' -f1)"
while read line
do
echo "- $line"
done <<< "${processes}"


echo "Listening ports :"
ports=$(ss -lutnpr4H | tr -s ' ' | cut -d' ' -f1)" $(ss -lutnpr4H | tr -s ' ' | cut -d' ' -f5 | cut -d':' -f2) $(ss -lutnpr4H | tr -s ' ' | cut -d' ' -f7 | cut -d'"' -f2)"
while read line
do
echo "-  $line"
done <<< "${ports}"

curl https://cataas.com/cat --output cat 2> /dev/null
cat_name='cat'
cat_type="$(file cat | cut -d' ' -f2)"
if [[ "${cat_type}" == JPEG ]]
then
file_type='.jpeg'
elif [[ "${cat_type}" == PNG ]]
then
file_type='.png'
elif [[ "${cat_type}" == GIF ]]
then
file_type='.gif'
else
echo "Not good format"
fi
new_cat_file="cat${file_type}"
cp "${cat_name}" "${new_cat_file}"
rm "${cat_name}"
echo "Here is your random cat : ${new_cat_file}"