# TP 3 : We do a little scripting

## Rendu

📁 **Fichier `/srv/idcard/idcard.sh`**

🌞 **Vous fournirez dans le compte-rendu**, en plus du fichier, **un exemple d'exécution avec une sortie**, dans des balises de code.

```bash
[manon@tp3linux idcard]$ sudo bash idcard.sh
Machine name : tp3linux.lab.ingesup
OS Rocky Linux and kernel version is 5.14.0-70.26.1.el9_0.x86_64
IP : 10.3.1.5
RAM : 87Mi memory available on 457Mi total memory
Disk : 5.1G space left
Top 5 processes by RAM usage :
- /usr/bin/python3
- /usr/sbin/NetworkManager
- /usr/lib/systemd/systemd
- /usr/lib/systemd/systemd
- sshd:
Listening ports :
- 323 udp : chronyd
- 80 tcp : httpd
- 22 tcp : sshd
Here is your random cat : cat.png
```

# II. Script youtube-dl


## Rendu

📁 **Le script `/srv/yt/yt.sh`**

📁 **Le fichier de log `/var/log/yt/download.log`**, avec au moins quelques lignes

🌞 Vous fournirez dans le compte-rendu, en plus du fichier, **un exemple d'exécution avec une sortie**, dans des balises de code.

```bash
[manon@tp3linux yt]$ ./yt.sh 'https://www.youtube.com/watch?v=PCicKydX5GE'
Video https://www.youtube.com/watch?v=PCicKydX5GE was downloaded.
File path : /srv/yt/downloads/3 Second Video/3 Second Video.mp4
```

# III. MAKE IT A SERVICE


## Rendu

📁 **Le script `/srv/yt/yt-v2.sh`**

📁 **Fichier `/etc/systemd/system/yt.service`**

🌞 Vous fournirez dans le compte-rendu, en plus des fichiers :

- un `systemctl status yt` quand le service est en cours de fonctionnement
 ```bash
    [manon@tp3linux yt]$ systemctl status yt
● yt.service - Script to download a list of Youtube url with Youtube-dl
     Loaded: loaded (/etc/systemd/system/yt.service; enabled; vendor preset: disabled)
     Active: active (running) since Thu 2023-01-12 21:54:57 CET; 1min 39s ago
   Main PID: 1349 (bash)
      Tasks: 1 (limit: 2684)
     Memory: 420.0K
        CPU: 1min 36.910s
     CGroup: /system.slice/yt.service
             └─1349 /bin/bash /srv/yt/yt-v2.sh

Jan 12 21:54:57 localhost.localdomain systemd[1]: Started Script to download a list of Youtube url with Youtube-dl.
```


- un extrait de `journalctl -xe -u yt`

```bash
[manon@tp3linux yt]$ journalctl -xe -u yt
Jan 12 22:08:12 localhost.localdomain bash[1349]: Video https://www.youtube.com/watch?v=QC8iQqtG0hg was downloaded.
Jan 12 22:08:12 localhost.localdomain bash[1349]: File path : /srv/yt/downloads/5 Second Video: Watch the Milky Way Rise/5 Second Video: Watch the Milky Wa>
```