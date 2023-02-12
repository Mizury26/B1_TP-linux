# Module 2 : Sauvegarde du système de fichiers


## Sommaire

- [Module 2 : Sauvegarde du système de fichiers](#module-2--sauvegarde-du-système-de-fichiers)
  - [Sommaire](#sommaire)
  - [I. Script de backup](#i-script-de-backup)
    - [1. Ecriture du script](#1-ecriture-du-script)
    - [2. Clean it](#2-clean-it)
    - [3. Service et timer](#3-service-et-timer)
  - [II. NFS](#ii-nfs)
    - [1. Serveur NFS](#1-serveur-nfs)
    - [2. Client NFS](#2-client-nfs)

## I. Script de backup

Partie à réaliser sur `web.tp6.linux`.

### 1. Ecriture du script

🌞 **Ecrire le script `bash`**

- il s'appellera `tp6_backup.sh`
- il devra être stocké dans le dossier `/srv` sur la machine `web.tp6.linux`
- le script doit commencer par un *shebang* qui indique le chemin du programme qui exécutera le contenu du script

```bash
[manon@web-tp6-linux srv]$ sudo touch tp6_backup.sh
```
```bash
#!/bin/bash
#12/02/2023
#script_backup by Manon

# check if the repository /srv/backup exists
if [ ! -d $"/srv/backup" ]; then
echo "no directory named /srv/backup"
exit 1
fi
cd /srv/backup/

# creation of 3 useful variables
date=`date +"%Y%m%d%H%M%S"`
file_name_z="nextcloud_$date.zip"
file_name_b="nextcloud_$date.bak"

#save of nextcloud in the file $file_name_b
mysqldump --single-transaction -h 10.105.1.12 -u nextcloud -YES nextcloud > $file_name_b

#compression of the file in the correct format
zip -r $file_name_z $file_name_b

#deletion of the file woth the bad format
rm -rf $file_name_b
```

### 2. Clean it


➜ **Environnement d'exécution du script**

- créez un utilisateur sur la machine `web.tp6.linux`
  - il s'appellera `backup`
  - son homedir sera `/srv/backup/`
  - son shell sera `/usr/bin/nologin`

  ```bash
  [manon@web-tp6-linux srv]$ sudo useradd -m -d /srv/backup/ -s /usr/sbin/nologin backup
  ```
- cet utilisateur sera celui qui lancera le script
- le dossier `/srv/backup/` doit appartenir au user `backup`
    ```bash
    [manon@web-tp6-linux /]$ sudo chown backup /srv/backup/
    ```
- pour tester l'exécution du script en tant que l'utilisateur `backup`, utilisez la commande suivante :

```bash
$ sudo -u backup /srv/tp6_backup.sh
```

### 3. Service et timer

🌞 **Créez un *service*** système qui lance le script

- vous appelerez le service `backup.service`
    ```bash
    [manon@web-tp6-linux ~]$ cat /etc/systemd/system/backup.service
    [Unit]
    Description=Run service backup nextcloud

    [Service]
    ExecStart= /bin/bash /srv/tp6_backup.sh
    User=backup
    Type=oneshot

    [Install]
    WantedBy=multi-users.target
    ```
- assurez-vous qu'il fonctionne en utilisant des commandes `systemctl`

```bash
$ sudo systemctl status backup
$ sudo systemctl start backup
```
```bash
[manon@web-tp6-linux config]$ sudo systemctl status backup
○ backup.service - Run service backup nextcloud
     Loaded: loaded (/etc/systemd/system/backup.service; disabled; vendor preset: disabled)
     Active: inactive (dead)
Feb 12 22:19:53 web-tp6-linux systemd[1]: Starting Run service backup nextcloud...
Feb 12 22:19:53 web-tp6-linux systemd[1]: backup.service: Deactivated successfully.
Feb 12 22:19:53 web-tp6-linux systemd[1]: Finished Run service backup nextcloud.
```

🌞 **Créez un *timer*** système qui lance le *service* à intervalles réguliers

- le fichier doit être créé dans le même dossier
- le fichier doit porter le même nom
- l'extension doit être `.timer` au lieu de `.service`
- ainsi votre fichier s'appellera `backup.timer`

```bash
[manon@web-tp6-linux system]$ cat backup.timer
[Unit]
Description=Run service backup

[Timer]
OnCalendar=*-*-* 4:00:00

[Install]
WantedBy=timers.target
```

🌞 Activez l'utilisation du *timer*

```bash
[manon@web-tp6-linux system]$ sudo systemctl daemon-reload
[manon@web-tp6-linux system]$  sudo systemctl start backup.timer
[sudo] password for manon:
[manon@web-tp6-linux system]$ sudo systemctl enable backup.timer
Created symlink /etc/systemd/system/timers.target.wants/backup.timer → /etc/systemd/system/backup.timer.
[manon@web-tp6-linux system]$ sudo systemctl status backup.timer
● backup.timer - Run service backup
     Loaded: loaded (/etc/systemd/system/backup.timer; enabled; vendor pres>     Active: active (waiting) since Sun 2023-02-12 22:51:26 CET; 11s ago
      Until: Sun 2023-02-12 22:51:26 CET; 11s ago
    Trigger: Mon 2023-02-13 04:00:00 CET; 5h 8min left
   Triggers: ● backup.service

Feb 12 22:51:26 web-tp6-linux systemd[1]: Started Run service backup.

[manon@web-tp6-linux system]$ ^C
[manon@web-tp6-linux system]$ sudo systemctl list-timers
NEXT                        LEFT          LAST                        PASSE>Mon 2023-02-13 00:00:00 CET 1h 8min left  Sun 2023-02-12 12:12:43 CET 10h a>Mon 2023-02-13 00:22:03 CET 1h 30min left Sun 2023-02-12 22:45:31 CET 6min >Mon 2023-02-13 04:00:00 CET 5h 8min left  n/a                         n/a  >Mon 2023-02-13 12:27:46 CET 13h left      Sun 2023-02-12 12:27:46 CET 10h a>
4 timers listed.
Pass --all to see loaded but inactive timers, too.
lines 1-8/8 (END)...skipping...
NEXT                        LEFT          LAST                        PASSED   UNIT                         ACTIVATES
Mon 2023-02-13 00:00:00 CET 1h 8min left  Sun 2023-02-12 12:12:43 CET 10h ago  logrotate.timer              logrotate.service
Mon 2023-02-13 00:22:03 CET 1h 30min left Sun 2023-02-12 22:45:31 CET 6min ago dnf-makecache.timer          dnf-makecache.service
Mon 2023-02-13 04:00:00 CET 5h 8min left  n/a                         n/a      backup.timer                 backup.service
Mon 2023-02-13 12:27:46 CET 13h left      Sun 2023-02-12 12:27:46 CET 10h ago  systemd-tmpfiles-clean.timer systemd-tmpfiles-clean.service
```

## II. NFS

### 1. Serveur NFS

🖥️ **VM `storage.tp6.linux`**

🌞 **Préparer un dossier à partager sur le réseau** (sur la machine `storage.tp6.linux`)

- créer un dossier `/srv/nfs_shares`
```bash 
[manon@storage-tp-linux ~]$ sudo mkdir /srv/nfs_shares
```
- créer un sous-dossier `/srv/nfs_shares/web.tp6.linux/`
```bash
[manon@storage-tp-linux ~]$ sudo mkdir /srv/nfs_shares/web.tp6.linux
```

🌞 **Installer le serveur NFS** (sur la machine `storage.tp6.linux`)

- installer le paquet `nfs-utils`
```bash
[manon@storage-tp-linux nfs_shares]$ sudo dnf install nfs-utils -y
```
- créer le fichier `/etc/exports`
```bash$
[manon@storage-tp-linux nfs_shares]$ cat /etc/exports
/srv/nfs_shares/web.tp6.linux/    10.105.1.11(rw,sync,no_subtree_check)
```
- ouvrir les ports firewall nécessaires
```bash
[manon@storage-tp-linux nfs_shares]$ sudo firewall-cmd --permanent --add-service=nfs
success
[manon@storage-tp-linux nfs_shares]$ sudo firewall-cmd --permanent --add-service=mountd
success
[manon@storage-tp-linux nfs_shares]$ sudo firewall-cmd --permanent --add-service=rpc-bind
success
[manon@storage-tp-linux nfs_shares]$ sudo firewall-cmd --reload
success
[manon@storage-tp-linux nfs_shares]$ sudo firewall-cmd --list-all | grep services
  services: cockpit dhcpv6-client mountd nfs rpc-bind ssh
```
- démarrer le service
```bash
[manon@storage-tp-linux nfs_shares]$ sudo firewall-cmd --list-all | grep services
  services: cockpit dhcpv6-client mountd nfs rpc-bind ssh
[manon@storage-tp-linux nfs_shares]$ sudo systemctl start nfs-server
[manon@storage-tp-linux nfs_shares]$ sudo systemctl status nfs-server
● nfs-server.service - NFS server and services
     Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; disabled; vendor preset: disabled)
     Active: active (exited) since Sun 2023-02-12 23:23:35 CET; 8s ago
    Process: 45131 ExecStartPre=/usr/sbin/exportfs -r (code=exited, status=0/SUCCESS)
    Process: 45132 ExecStart=/usr/sbin/rpc.nfsd (code=exited, status=0/SUCCESS)
    Process: 45149 ExecStart=/bin/sh -c if systemctl -q is-active gssproxy; then systemctl reload gssproxy ; fi (code=exited, status=0/SUCCESS)
   Main PID: 45149 (code=exited, status=0/SUCCESS)
        CPU: 16ms

Feb 12 23:23:35 storage-tp-linux.lab.ingesup systemd[1]: Starting NFS server and services...
Feb 12 23:23:35 storage-tp-linux.lab.ingesup systemd[1]: Finished NFS server and services.
```

### 2. Client NFS

🌞 **Installer un client NFS sur `web.tp6.linux`**

```bash
[manon@web-tp6-linux system]$ sudo dnf install nfs-utils -y
```

- il devra monter le dossier `/srv/nfs_shares/web.tp6.linux/` qui se trouve sur `storage.tp6.linux`
- le dossier devra être monté sur `/srv/backup/`
```bash
[manon@web-tp6-linux system]$ sudo mount 10.105.1.14:/srv/nfs_shares/web.tp6.linux/ /srv/backup/
```
- faites en sorte que le dossier soit automatiquement monté quand la machine s'allume
```bash
[manon@web-tp6-linux system]$ cat /etc/fstab
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
10.105.1.14:/srv/nfs_shares/web.tp6.linux/  /srv/backup/  nfs  defaults  0  0
```

🌞 **Tester la restauration des données** sinon ça sert à rien :)

- livrez-moi la suite de commande que vous utiliseriez pour restaurer les données dans une version antérieure

