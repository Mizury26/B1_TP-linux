```bash
[manon@storagetp4linux storage]$ sudo dnf install nfs-utils
```
```bash
[manon@webtp4linux ~]$ sudo mkdir -p /var/www/site_web_1/
[sudo] password for manon:
[manon@webtp4linux ~]$ sudo mkdir -p /var/www/site_web_2/
```
```bash
[manon@webtp4linux ~]$ sudo mount 10.3.2.4:/storage/site_web_1 /var/www/site_web_1/
[sudo] password for manon:
[manon@webtp4linux ~]$ sudo mount 10.3.2.4:/storage/site_web_2 /var/www/site_web_2/
```
```bash
[manon@webtp4linux ~]$ df -h
Filesystem                    Size  Used Avail Use% Mounted on
devtmpfs                      210M     0  210M   0% /dev
tmpfs                         229M     0  229M   0% /dev/shm
tmpfs                          92M  2.2M   90M   3% /run
/dev/mapper/rl-root           6.2G  1.2G  5.1G  18% /
/dev/sda1                    1014M  210M  805M  21% /boot
tmpfs                          46M     0   46M   0% /run/user/1000
10.3.2.4:/storage/site_web_1  2.0G     0  1.9G   0% /var/www/site_web_1
10.3.2.4:/storage/site_web_2  2.0G     0  1.9G   0% /var/www/site_web_2
```
```bash
[manon@webtp4linux ~]$ cat /etc/fstab

#
# /etc/fstab
# Created by anaconda on Thu Oct 13 09:03:58 2022
#
# Accessible filesystems, by reference, are maintained under '/dev/disk/'.
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info.
#
# After editing this file, run 'systemctl daemon-reload' to update systemd
# units generated from this file.
#
/dev/mapper/rl-root     /                       xfs     defaults        0 0
UUID=3a82558c-8817-489e-9d0a-42517504a6a7 /boot                   xfs     defaults        0 0
/dev/mapper/rl-swap     none                    swap    defaults        0 0
10.3.2.4:/storage/site_web_1 /var/www/site_web_1/ nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0
10.3.2.4:/storage/site_web_2 /var/www/site_web_2/ nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0
```