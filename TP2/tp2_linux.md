# TP2 : Appréhender l'environnement Linux



## Checklist



# I. Service SSH



## 1. Analyse du service



🌞 **S'assurer que le service `sshd` est démarré**

```bash
[manon@machine ~]$ systemctl status sshd
● sshd.service - OpenSSH server daemon
     Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; vendor preset: enabled)
     Active: active (running) since Fri 2022-12-09 16:08:53 CET; 5min ago
       Docs: man:sshd(8)
             man:sshd_config(5)
   Main PID: 684 (sshd)
      Tasks: 1 (limit: 2684)
     Memory: 5.8M
        CPU: 48ms
     CGroup: /system.slice/sshd.service
             └─684 "sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups"

Dec 09 16:08:53 machine.lab.ingesup systemd[1]: Starting OpenSSH server daemon...
Dec 09 16:08:53 machine.lab.ingesup sshd[684]: Server listening on 0.0.0.0 port 22.
Dec 09 16:08:53 machine.lab.ingesup sshd[684]: Server listening on :: port 22.
Dec 09 16:08:53 machine.lab.ingesup systemd[1]: Started OpenSSH server daemon.
Dec 09 16:09:14 machine.lab.ingesup sshd[849]: Accepted password for manon from 10.3.1.1 port 58465 ssh2
Dec 09 16:09:14 machine.lab.ingesup sshd[849]: pam_unix(sshd:session): session opened for user manon(uid=1000) by (uid=0)
```

🌞 **Analyser les processus liés au service SSH**

- afficher les processus liés au service `sshd`

```bash
[manon@machine ~]$ ps -ef | grep sshd
root         684       1  0 16:08 ?        00:00:00 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups
root         849     684  0 16:09 ?        00:00:00 sshd: manon [priv]
manon        853     849  0 16:09 ?        00:00:00 sshd: manon@pts/0
```

🌞 **Déterminer le port sur lequel écoute le service SSH**

```bash
[manon@machine ~]$ ss | grep ssh
tcp   ESTAB  0      52                        10.3.1.2:ssh           10.3.1.1:58465
```

🌞 **Consulter les logs du service SSH**

- les logs du service sont consultables avec une commande `journalctl`
```bash
[manon@machine log]$ journalctl | grep ssh
Dec 09 16:08:53 machine.lab.ingesup systemd[1]: Created slice Slice /system/sshd-keygen.
Dec 09 16:08:53 machine.lab.ingesup systemd[1]: Reached target sshd-keygen.target.
Dec 09 16:08:53 machine.lab.ingesup sshd[684]: Server listening on 0.0.0.0 port 22.
Dec 09 16:08:53 machine.lab.ingesup sshd[684]: Server listening on :: port 22.
Dec 09 16:09:14 machine.lab.ingesup sshd[849]: Accepted password for manon from 10.3.1.1 port 58465 ssh2
Dec 09 16:09:14 machine.lab.ingesup sshd[849]: pam_unix(sshd:session): session opened for user manon(uid=1000) by (uid=0)
Dec 09 16:29:59 machine.lab.ingesup sshd[909]: Accepted password for manon from 10.3.1.1 port 65273 ssh2
Dec 09 16:29:59 machine.lab.ingesup sshd[909]: pam_unix(sshd:session): session opened for user manon(uid=1000) by (uid=0)
Dec 09 16:30:26 machine.lab.ingesup sshd[913]: Received disconnect from 10.3.1.1 port 65273:11: disconnected by user
Dec 09 16:30:26 machine.lab.ingesup sshd[913]: Disconnected from user manon 10.3.1.1 port 65273
Dec 09 16:30:26 machine.lab.ingesup sshd[909]: pam_unix(sshd:session): session closed for user manon
```
- un fichier de log qui répertorie toutes les tentatives de connexion SSH existe

```bash
[manon@machine log]$ sudo tail -n 10 secure
Dec  9 17:21:36 machine sshd[1269]: Server listening on :: port 22.
Dec  9 17:21:36 machine sudo[1265]: pam_unix(sudo:session): session closed for user root
Dec  9 17:30:55 machine unix_chkpwd[1275]: password check failed for user (manon)
Dec  9 17:30:55 machine sudo[1272]: pam_unix(sudo:auth): authentication failure; logname=manon uid=1000 euid=0 tty=/dev/pts/0 ruser=manon rhost=  user=manon
Dec  9 17:30:59 machine sudo[1272]:   manon : TTY=pts/0 ; PWD=/var/log ; USER=root ; COMMAND=/bin/cat secure
Dec  9 17:30:59 machine sudo[1272]: pam_unix(sudo:session): session opened for user root(uid=0) by manon(uid=1000)
Dec  9 17:30:59 machine sudo[1272]: pam_unix(sudo:session): session closed for user root
Dec  9 17:32:01 machine sudo[1280]:   manon : TTY=pts/0 ; PWD=/var/log ; USER=root ; COMMAND=/bin/tail -n 10 secure
Dec  9 17:32:01 machine sudo[1280]: pam_unix(sudo:session): session opened for user root(uid=0) by manon(uid=1000)
Dec  9 17:32:01 machine sudo[1280]: pam_unix(sudo:session): session closed for user root
```

## 2. Modification du service

Dans cette section, on va aller visiter et modifier le fichier de configuration du serveur SSH.

Comme tout fichier de configuration, celui de SSH se trouve dans le dossier `/etc/`.

Plus précisément, il existe un sous-dossier `/etc/ssh/` qui contient toute la configuration relative au protocole SSH

🌞 **Identifier le fichier de configuration du serveur SSH**

```bash
[manon@machine ssh]$ sudo cat sshd_config
[sudo] password for manon:
#       $OpenBSD: sshd_config,v 1.104 2021/07/02 05:11:21 dtucker Exp $

# This is the sshd server system-wide configuration file.  See
# sshd_config(5) for more information.

# This sshd was compiled with PATH=/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin

# The strategy used for options in the default sshd_config shipped with
# OpenSSH is to specify options with their default value where
# possible, but leave them commented.  Uncommented options override the
# default value.

# To modify the system-wide sshd configuration, create a  *.conf  file under
#  /etc/ssh/sshd_config.d/  which will be automatically included below
Include /etc/ssh/sshd_config.d/*.conf

# If you want to change the port on a SELinux system, you have to tell
# SELinux about this change.
# semanage port -a -t ssh_port_t -p tcp #PORTNUMBER
#
#Port 22
#AddressFamily any
#ListenAddress 0.0.0.0
#ListenAddress ::

#HostKey /etc/ssh/ssh_host_rsa_key
#HostKey /etc/ssh/ssh_host_ecdsa_key
#HostKey /etc/ssh/ssh_host_ed25519_key

# Ciphers and keying
#RekeyLimit default none

# Logging
#SyslogFacility AUTH
#LogLevel INFO

# Authentication:

#LoginGraceTime 2m
#PermitRootLogin prohibit-password
#StrictModes yes
#MaxAuthTries 6
#MaxSessions 10

#PubkeyAuthentication yes

# The default is to check both .ssh/authorized_keys and .ssh/authorized_keys2
# but this is overridden so installations will only check .ssh/authorized_keys
AuthorizedKeysFile      .ssh/authorized_keys

#AuthorizedPrincipalsFile none

#AuthorizedKeysCommand none
#AuthorizedKeysCommandUser nobody

# For this to work you will also need host keys in /etc/ssh/ssh_known_hosts
#HostbasedAuthentication no
# Change to yes if you don't trust ~/.ssh/known_hosts for
# HostbasedAuthentication
#IgnoreUserKnownHosts no
# Don't read the user's ~/.rhosts and ~/.shosts files
#IgnoreRhosts yes

# To disable tunneled clear text passwords, change to no here!
#PasswordAuthentication yes
#PermitEmptyPasswords no

# Change to no to disable s/key passwords
#KbdInteractiveAuthentication yes

# Kerberos options
#KerberosAuthentication no
#KerberosOrLocalPasswd yes
#KerberosTicketCleanup yes
#KerberosGetAFSToken no
#KerberosUseKuserok yes

# GSSAPI options
#GSSAPIAuthentication no
#GSSAPICleanupCredentials yes
#GSSAPIStrictAcceptorCheck yes
#GSSAPIKeyExchange no
#GSSAPIEnablek5users no

# Set this to 'yes' to enable PAM authentication, account processing,
# and session processing. If this is enabled, PAM authentication will
# be allowed through the KbdInteractiveAuthentication and
# PasswordAuthentication.  Depending on your PAM configuration,
# PAM authentication via KbdInteractiveAuthentication may bypass
# the setting of "PermitRootLogin without-password".
# If you just want the PAM account and session checks to run without
# PAM authentication, then enable this but set PasswordAuthentication
# and KbdInteractiveAuthentication to 'no'.
# WARNING: 'UsePAM no' is not supported in Fedora and may cause several
# problems.
#UsePAM no

#AllowAgentForwarding yes
#AllowTcpForwarding yes
#GatewayPorts no
#X11Forwarding no
#X11DisplayOffset 10
#X11UseLocalhost yes
#PermitTTY yes
#PrintMotd yes
#PrintLastLog yes
#TCPKeepAlive yes
#PermitUserEnvironment no
#Compression delayed
#ClientAliveInterval 0
#ClientAliveCountMax 3
#UseDNS no
#PidFile /var/run/sshd.pid
#MaxStartups 10:30:100
#PermitTunnel no
#ChrootDirectory none
#VersionAddendum none

# no default banner path
#Banner none

# override default of no subsystems
Subsystem       sftp    /usr/libexec/openssh/sftp-server

# Example of overriding settings on a per-user basis
#Match User anoncvs
#       X11Forwarding no
#       AllowTcpForwarding no
#       PermitTTY no
#       ForceCommand cvs server
```

🌞 **Modifier le fichier de conf**

- exécutez un `echo $RANDOM` pour demander à votre shell de vous fournir un nombre aléatoire

```bash
  [manon@machine ~]$ echo $RANDOM
    1924
```
- changez le port d'écoute du serveur SSH pour qu'il écoute sur ce numéro de port

```bash
  [manon@machine ssh]$ sudo cat sshd_config | grep Port
    Port 1924
    #GatewayPorts no
```
- gérer le firewall
  - fermer l'ancien port
```bash
  [manon@machine ssh]$ sudo firewall-cmd --remove-port=22/tcp --permanent
Warning: NOT_ENABLED: 22:tcp
success
```
  - ouvrir le nouveau port
```bash
[manon@machine ssh]$ sudo firewall-cmd --add-port=1924/tcp --permanent
success
```
```bash
[manon@machine ssh]$ sudo firewall-cmd --reload
success
```
  - vérifier avec un `firewall-cmd --list-all` que le port est bien ouvert
```bash
[manon@machine ssh]$ sudo firewall-cmd --list-all | grep ports
  ports: 1924/tcp
  forward-ports:
  source-ports:
```

🌞 **Redémarrer le service**

```bash
[manon@machine ssh]$ sudo systemctl restart sshd
```

🌞 **Effectuer une connexion SSH sur le nouveau port**

```bash
PS C:\Users\Utilisateur> ssh -p 1924 manon@machine
manon@machine's password:
Last login: Fri Dec  9 16:59:08 2022 from 10.3.1.1
[manon@machine ~]$
```
✨ **Bonus : affiner la conf du serveur SSH**

- faites vos plus belles recherches internet pour améliorer la conf de SSH
- par "améliorer" on entend essentiellement ici : augmenter son niveau de sécurité
- le but c'est pas de me rendre 10000 lignes de conf que vous pompez sur internet pour le bonus, mais de vous éveiller à divers aspects de SSH, la sécu ou d'autres choses liées


# II. Service HTTP


## 1. Mise en place

🌞 **Installer le serveur NGINX**
```bash
[manon@machine log]$ sudo dnf install nginx
```
🌞 **Démarrer le service NGINX**

```bash
[manon@machine log]$ sudo systemctl enable nginx
Created symlink /etc/systemd/system/multi-user.target.wants/nginx.service → /usr/lib/systemd/system/nginx.service.
[manon@machine log]$ sudo systemctl start nginx
```

🌞 **Déterminer sur quel port tourne NGINX**

```bash
[manon@machine ~]$ sudo ss -lutnp | grep nginx
[sudo] password for manon:
tcp   LISTEN 0      511          0.0.0.0:80        0.0.0.0:*    users:(("nginx",pid=11112,fd=6),("nginx",pid=11111,fd=6))
tcp   LISTEN 0      511             [::]:80           [::]:*    users:(("nginx",pid=11112,fd=7),("nginx",pid=11111,fd=7))
```
```bash
[manon@machine ~]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
[manon@machine ~]$ sudo firewall-cmd --reload
success
```

🌞 **Déterminer les processus liés à l'exécution de NGINX**

```bash
[manon@machine ~]$ ps -ef | grep nginx
root       11111       1  0 17:40 ?        00:00:00 nginx: master process /usr/sbin/nginx
nginx      11112   11111  0 17:40 ?        00:00:00 nginx: worker process
```

🌞 **Euh wait**

```bash
Utilisateur@PC-Manon MINGW64 ~
$ curl http://10.3.1.2:80 | head -n 7
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  7620  100  7620    0     0  1960k      0 --:--:-- --:--:-- --:--:-- 2480k
<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">

```

## 2. Analyser la conf de NGINX

🌞 **Déterminer le path du fichier de configuration de NGINX**

```bash
[manon@machine ~]$ which nginx
/usr/sbin/nginx
[manon@machine ~]$ ls -al /usr/sbin/nginx
-rwxr-xr-x. 1 root root 1330200 Oct 31 16:37 /usr/sbin/nginx
```

🌞 **Trouver dans le fichier de conf**

- les lignes qui permettent de faire tourner un site web d'accueil (la page moche que vous avez vu avec votre navigateur)
  - ce que vous cherchez, c'est un bloc `server { }` dans le fichier de conf
  - vous ferez un `cat <FICHIER> | grep <TEXTE> -A X` pour me montrer les lignes concernées dans le compte-rendu
    - l'option `-A X` permet d'afficher aussi les `X` lignes après chaque ligne trouvée par `grep`
- une ligne qui parle d'inclure d'autres fichiers de conf
  - encore un `cat <FICHIER> | grep <TEXTE>`
  - bah ouais, on stocke pas toute la conf dans un seul fichier, sinon ça serait le bordel

## 3. Déployer un nouveau site web

🌞 **Créer un site web**

- bon on est pas en cours de design ici, alors on va faire simplissime
- créer un sous-dossier dans `/var/www/`
  - par convention, on stocke les sites web dans `/var/www/`
  - votre dossier doit porter le nom `tp2_linux`
- dans ce dossier `/var/www/tp2_linux`, créez un fichier `index.html`
  - il doit contenir `<h1>MEOW mon premier serveur web</h1>`

🌞 **Adapter la conf NGINX**

- dans le fichier de conf principal
  - vous supprimerez le bloc `server {}` repéré plus tôt pour que NGINX ne serve plus le site par défaut
  - redémarrez NGINX pour que les changements prennent effet
- créez un nouveau fichier de conf
  - il doit être nommé correctement
  - il doit être placé dans le bon dossier
  - c'est quoi un "nom correct" et "le bon dossier" ?
    - bah vous avez repéré dans la partie d'avant les fichiers qui sont inclus par le fichier de conf principal non ?
    - créez votre fichier en conséquence
  - redémarrez NGINX pour que les changements prennent effet
  - le contenu doit être le suivant :

```nginx
server {
  # le port choisi devra être obtenu avec un 'echo $RANDOM' là encore
  listen <PORT>;

  root /var/www/tp2_linux;
}
```

🌞 **Visitez votre super site web**

- toujours avec une commande `curl` depuis votre PC (ou un navigateur)

# III. Your own services

Dans cette partie, on va créer notre propre service :)

HE ! Vous vous souvenez de `netcat` ou `nc` ? Le ptit machin de notre premier cours de réseau ? C'EST L'HEURE DE LE RESORTIR DES PLACARDS.

## 1. Au cas où vous auriez oublié

Au cas où vous auriez oublié, une petite partie qui ne doit pas figurer dans le compte-rendu, pour vous remettre `nc` en main.

➜ Dans la VM

- `nc -l 8888`
  - lance netcat en mode listen
  - il écoute sur le port 8888
  - sans rien préciser de plus, c'est le port 8888 TCP qui est utilisé

➜ Allumez une autre VM vite fait

- `nc <IP_PREMIERE_VM> 8888`
- vérifiez que vous pouvez envoyer des messages dans les deux sens

> Oubliez pas d'ouvrir le port 8888/tcp de la première VM bien sûr :)

## 2. Analyse des services existants

Un service c'est quoi concrètement ? C'est juste un processus, que le système lance, et dont il s'occupe après.

Il est défini dans un simple fichier texte, qui contient une info primordiale : la commande exécutée quand on "start" le service.

Il est possible de définir beaucoup d'autres paramètres optionnels afin que notre service s'exécute dans de bonnes conditions.

🌞 **Afficher le fichier de service SSH**

- vous pouvez obtenir son chemin avec un `systemctl status <SERVICE>`
- mettez en évidence la ligne qui commence par `ExecStart=`
  - encore un `cat <FICHIER> | grep <TEXTE>`
  - c'est la ligne qui définit la commande lancée lorsqu'on "start" le service
    - taper `systemctl start <SERVICE>` ou exécuter cette commande à la main, c'est (presque) pareil

🌞 **Afficher le fichier de service NGINX**

- mettez en évidence la ligne qui commence par `ExecStart=`

## 3. Création de service

![Create service](./pics/create_service.png)

Bon ! On va créer un petit service qui lance un `nc`. Et vous allez tout de suite voir pourquoi c'est pratique d'en faire un service et pas juste le lancer à la min.

Ca reste un truc pour s'exercer, c'pas non plus le truc le plus utile de l'année que de mettre un `nc` dans un service n_n

🌞 **Créez le fichier `/etc/systemd/system/tp2_nc.service`**

- son contenu doit être le suivant (nice & easy)

```service
[Unit]
Description=Super netcat tout fou

[Service]
ExecStart=/usr/bin/nc -l <PORT>
```

> Vous remplacerez `<PORT>` par un numéro de port random obtenu avec la même méthode que précédemment.

🌞 **Indiquer au système qu'on a modifié les fichiers de service**

- la commande c'est `sudo systemctl daemon-reload`

🌞 **Démarrer notre service de ouf**

- avec une commande `systemctl start`

🌞 **Vérifier que ça fonctionne**

- vérifier que le service tourne avec un `systemctl status <SERVICE>`
- vérifier que `nc` écoute bien derrière un port avec un `ss`
  - vous filtrerez avec un `| grep` la sortie de la commande pour n'afficher que les lignes intéressantes
- vérifer que juste ça marche en vous connectant au service depuis une autre VM
  - allumez une autre VM vite fait et vous tapez une commande `nc` pour vous connecter à la première

> **Normalement**, dans ce TP, vous vous connectez depuis votre PC avec un `nc` vers la VM, mais bon. Vos supers OS Windows/MacOS chient un peu sur les conventions de réseau, et ça marche pas super super en utilisant un `nc` directement sur votre machine. Donc voilà, allons au plus simple : allumez vite fait une deuxième qui servira de client pour tester la connexion à votre service `tp2_nc`.

➜ Si vous vous connectez avec le client, que vous envoyez éventuellement des messages, et que vous quittez `nc` avec un CTRL+C, alors vous pourrez constater que le service s'est stoppé

- bah oui, c'est le comportement de `nc` ça ! 
- le client se connecte, et quand il se tire, ça ferme `nc` côté serveur aussi
- faut le relancer si vous voulez retester !

🌞 **Les logs de votre service**

- mais euh, ça s'affiche où les messages envoyés par le client ? Dans les logs !
- `sudo journalctl -xe -u tp2_nc` pour visualiser les logs de votre service
- `sudo journalctl -xe -u tp2_nc -f ` pour visualiser **en temps réel** les logs de votre service
  - `-f` comme follow (on "suit" l'arrivée des logs en temps réel)
- dans le compte-rendu je veux
  - une commande `journalctl` filtrée avec `grep` qui affiche la ligne qui indique le démarrage du service
  - une commande `journalctl` filtrée avec `grep` qui affiche un message reçu qui a été envoyé par le client
  - une commande `journalctl` filtrée avec `grep` qui affiche la ligne qui indique l'arrêt du service

🌞 **Affiner la définition du service**

- faire en sorte que le service redémarre automatiquement s'il se termine
  - comme ça, quand un client se co, puis se tire, le service se relancera tout seul
  - ajoutez `Restart=always` dans la section `[Service]` de votre service
  - n'oubliez pas d'indiquer au système que vous avez modifié les fichiers de service :)