# TP2 : Appréhender l'environnement Linux

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
- gérer le firewall :
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
Utilisateur@PC-Manon MINGW64 ~$ curl http://10.3.1.2:80 | head -n 7
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
-> Le serveur tourne

## 2. Analyser la conf de NGINX

🌞 **Déterminer le path du fichier de configuration de NGINX**

```bash
[manon@machine ~]$ sudo find /etc -iname nginx.conf
[sudo] password for manon:
/etc/nginx/nginx.conf
```

🌞 **Trouver dans le fichier de conf**

- les lignes qui permettent de faire tourner un site web d'accueil
```bash
[manon@machine nginx]$ cat nginx.conf | grep server -A 15
    server {
        listen       80;
        listen       [::]:80;
        server_name  _;
        root         /usr/share/nginx/html;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }
```
- une ligne qui parle d'inclure d'autres fichiers de conf

```bash
[manon@machine nginx]$ cat nginx.conf | grep include
include /usr/share/nginx/modules/*.conf;
    include             /etc/nginx/mime.types;
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    include /etc/nginx/conf.d/*.conf;
        include /etc/nginx/default.d/*.conf;
#        include /etc/nginx/default.d/*.conf;
```

## 3. Déployer un nouveau site web

🌞 **Créer un site web**

```bash
[manon@machine var]$ sudo mkdir www
[sudo] password for manon:
[manon@machine var]$ cd www
[manon@machine www]$ sudo mkdir tp2_linux
[manon@machine www]$ cd tp2_linux/
[manon@machine tp2_linux]$ sudo touch index.html
[manon@machine tp2_linux]$ sudo vim index.html
 1L, 38B written
[manon@machine tp2_linux]$ cat index.html
<h1>MEOW mon premier serveur web</h1>
```

🌞 **Adapter la conf NGINX**

- dans le fichier de conf principal
  - vous supprimerez le bloc `server {}` repéré plus tôt pour que NGINX ne serve plus le site par défaut
```bash
[manon@machine nginx]$ sudo vim nginx.conf
```
```bash
[manon@machine nginx]$ cat nginx.conf | grep server -A 15
# Settings for a TLS enabled server.
#
#    server {
#        listen       443 ssl http2;
#        listen       [::]:443 ssl http2;
#        server_name  _;
#        root         /usr/share/nginx/html;
#
#        ssl_certificate "/etc/pki/nginx/server.crt";
#        ssl_certificate_key "/etc/pki/nginx/private/server.key";
#        ssl_session_cache shared:SSL:1m;
#        ssl_session_timeout  10m;
#        ssl_ciphers PROFILE=SYSTEM;
#        ssl_prefer_server_ciphers on;
#
#        # Load configuration files for the default server block.
#        include /etc/nginx/default.d/*.conf;
#
#        error_page 404 /404.html;
#            location = /40x.html {
#        }
#
#        error_page 500 502 503 504 /50x.html;
#            location = /50x.html {
#        }
#    }

```
  - redémarrez NGINX pour que les changements prennent effet
```bash
[manon@machine nginx]$ sudo systemctl restart nginx
```

- créez un nouveau fichier de conf
```bash
[manon@machine conf.d]$ sudo touch servernginx.conf
```
```bash
[manon@machine conf.d]$ echo $RANDOM
14209
```
```bash
[manon@machine nginx]$ cat conf.d/servernginx.conf
server {
  listen 14209;

  root /var/www/tp2_linux;
}
```
```bash
[manon@machine conf.d]$ sudo firewall-cmd --add-port=14209/tcp --permanent
success
[manon@machine conf.d]$ sudo firewall-cmd --remove-port=80/tcp --permanent
success
[manon@machine conf.d]$ sudo firewall-cmd --reload
success
```
  - redémarrez NGINX pour que les changements prennent effet
```bash
[manon@machine nginx]$ sudo systemctl restart nginx
```

🌞 **Visitez votre super site web**

```bash
[manon@machine nginx]$ curl http://10.3.1.2:14209
<h1>MEOW mon premier serveur web</h1>
```

# III. Your own services


## 1. Analyse des services existants


🌞 **Afficher le fichier de service SSH**

- vous pouvez obtenir son chemin avec un `systemctl status <SERVICE>`
```bash
[manon@machine ~]$ systemctl status sshd
● sshd.service - OpenSSH server daemon
     Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; vendor preset: enabled)
     Active: active (running) since Sun 2022-12-11 17:41:07 CET; 7min ago
       Docs: man:sshd(8)
             man:sshd_config(5)
   Main PID: 692 (sshd)
      Tasks: 1 (limit: 2684)
     Memory: 5.8M
        CPU: 130ms
     CGroup: /system.slice/sshd.service
             └─692 "sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups"

Dec 11 17:41:07 machine.lab.ingesup systemd[1]: Starting OpenSSH server daemon...
Dec 11 17:41:07 machine.lab.ingesup sshd[692]: Server listening on 0.0.0.0 port 22.
Dec 11 17:41:07 machine.lab.ingesup sshd[692]: Server listening on :: port 22.
Dec 11 17:41:07 machine.lab.ingesup systemd[1]: Started OpenSSH server daemon.
Dec 11 17:41:30 machine.lab.ingesup sshd[856]: Accepted password for manon from 10.3.1.1 port 49882 ssh2
Dec 11 17:41:31 machine.lab.ingesup sshd[856]: pam_unix(sshd:session): session opened for user manon(uid=1000) by (uid=0)
```
- mettez en évidence la ligne qui commence par `ExecStart=`
```bash
[manon@machine system]$ cat sshd.service | grep ExecStart
ExecStart=/usr/sbin/sshd -D $OPTIONS
```
```bash
[manon@machine system]$ sudo systemctl start sshd
```

🌞 **Afficher le fichier de service NGINX**

- mettez en évidence la ligne qui commence par `ExecStart=`
```bash
[manon@machine system]$ cat nginx.service | grep ExecStart
ExecStartPre=/usr/bin/rm -f /run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t
ExecStart=/usr/sbin/nginx
```

## 3. Création de service


🌞 **Créez le fichier `/etc/systemd/system/tp2_nc.service`**

```bash
[manon@machine system]$ echo $RANDOM
7523
```
```bash
[manon@machine system]$ sudo touch tp2_nc.service
[manon@machine system]$ sudo vim tp2_nc.service
[manon@machine system]$ cat tp2_nc.service
[Unit]
Description=Super netcat tout fou

[Service]
ExecStart=/usr/bin/nc -l 7523
```
```bash
[manon@machine system]$ sudo firewall-cmd --add-port=7523/tcp --permanent
success
[manon@machine system]$ sudo firewall-cmd --reload
success
```

🌞 **Indiquer au système qu'on a modifié les fichiers de service**

```bash
[manon@machine system]$ sudo systemctl daemon-reload
```

🌞 **Démarrer notre service de ouf**

```bash
[manon@machine system]$ sudo systemctl start tp2_nc.service
```

🌞 **Vérifier que ça fonctionne**

- vérifier que le service tourne avec un `systemctl status <SERVICE>`

```bash
[manon@machine system]$ sudo systemctl status tp2_nc.service
● tp2_nc.service - Super netcat tout fou
     Loaded: loaded (/etc/systemd/system/tp2_nc.service; static)
     Active: active (running) since Sun 2022-12-11 18:03:01 CET; 1min 2s ago
   Main PID: 1000 (nc)
      Tasks: 1 (limit: 2684)
     Memory: 784.0K
        CPU: 2ms
     CGroup: /system.slice/tp2_nc.service
             └─1000 /usr/bin/nc -l 7523

Dec 11 18:03:01 machine.lab.ingesup systemd[1]: Started Super netcat tout fou.
```
- vérifier que `nc` écoute bien derrière un port avec un `ss`
```bash
[manon@machine system]$ sudo ss -lutmp | grep nc
tcp   LISTEN 0      10           0.0.0.0:7523       0.0.0.0:*    users:(("nc",pid=1000,fd=4))
tcp   LISTEN 0      10              [::]:7523          [::]:*    users:(("nc",pid=1000,fd=3))
```

🌞 **Les logs de votre service**
```bash
[manon@machine system]$ sudo journalctl -xe -u tp2_nc | grep Started
Dec 11 18:03:01 machine.lab.ingesup systemd[1]: Started Super netcat tout fou.

[manon@machine system]$ sudo journalctl -xe -u tp2_nc | grep hello
Dec 11 18:18:13 machine.lab.ingesup nc[1083]: hello !!

[manon@machine system]$ sudo journalctl -xe -u tp2_nc | grep Stopped
Dec 11 18:17:29 machine.lab.ingesup systemd[1]: Stopped Super netcat tout fou.
```

🌞 **Affiner la définition du service**

- faire en sorte que le service redémarre automatiquement s'il se termine

```bash
[manon@machine system]$ cat /etc/systemd/system/tp2_nc.service
[Unit]
Description=Super netcat tout fou

[Service]
ExecStart=/usr/bin/nc -l 7523
Restart=always
```
```bash
[manon@machine system]$ sudo systemctl daemon-reload
```
