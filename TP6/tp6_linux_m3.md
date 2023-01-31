# Module 3 : Fail2Ban

🌞 Faites en sorte que :

- si quelqu'un se plante 3 fois de password pour une co SSH en moins de 1 minute, il est ban
- vérifiez que ça fonctionne en vous faisant ban
- utilisez une commande dédiée pour lister les IPs qui sont actuellement ban
- afficher l'état du firewall, et trouver la ligne qui ban l'IP en question
- lever le ban avec une commande liée à fail2ban
-------------------------------------------------------------
- On installe Fail2Ban :
```bash
[manon@web-tp6-linux ~]$ sudo dnf install epel-release -y
[manon@web-tp6-linux ~]$ sudo dnf install fail2ban -y
```
- On vérifie qu'il est bien désactivé :
```bash
[manon@web-tp6-linux ~]$ systemctl status fail2ban.service
○ fail2ban.service - Fail2Ban Service
     Loaded: loaded (/usr/lib/systemd/system/fail2ban.service; disabled; vendor preset: di>     Active: inactive (dead)
       Docs: man:fail2ban(1)
lines 1-4/4 (END)...skipping...
○ fail2ban.service - Fail2Ban Service
     Loaded: loaded (/usr/lib/systemd/system/fail2ban.service; disabled; vendor preset: disabled)
     Active: inactive (dead)
       Docs: man:fail2ban(1)
```
- On créer un fichier jail.local à partir du fichier jail.conf car il ne doit pas être modifié :
```bash
[manon@web-tp6-linux fail2ban]$ sudo cp jail.conf jail.local
```
- on modifie la conf du fichier /etc/jail2ban/jail.local avec les paramètres qui nous intéressent :
```bash
# "bantime" is the number of seconds that a host is banned.
# bantime  = 10m
# Permanent ban
bantime = -1 # -1 -> ban définitif 

# A host is banned if it has generated "maxretry" during the last "findtime"
# seconds.
findtime  = 1m

# "maxretry" is the number of failures before a host get banned.
maxretry = 3
```

```bash
[sshd]

# To use more aggressive sshd modes set filter parameter "mode" in jail.local:
# normal (default), ddos, extra or aggressive (combines all).
# See "tests/files/logs/sshd" or "filter.d/sshd.conf" for usage example and details.
#mode   = normal
enabled = true
port    = ssh
logpath = %(sshd_log)s
backend = %(sshd_backend)s
``
- On démarre le service :

```bash
[manon@web-tp6-linux fail2ban]$ sudo systemctl start fail2ban
[manon@web-tp6-linux fail2ban]$ sudo systemctl status fail2ban
● fail2ban.service - Fail2Ban Service
     Loaded: loaded (/usr/lib/systemd/system/fail2ban.service; enabled; vendor preset: disabled)
     Active: active (running) since Tue 2023-01-31 15:30:13 CET; 4s ago
       Docs: man:fail2ban(1)
    Process: 1965 ExecStartPre=/bin/mkdir -p /run/fail2ban (code=exited, status=0/SUCCESS)
   Main PID: 1966 (fail2ban-server)
      Tasks: 5 (limit: 11078)
     Memory: 12.1M
        CPU: 90ms
     CGroup: /system.slice/fail2ban.service
             └─1966 /usr/bin/python3 -s /usr/bin/fail2ban-server -xf start

Jan 31 15:30:13 web-tp6-linux systemd[1]: Starting Fail2Ban Service...
Jan 31 15:30:13 web-tp6-linux systemd[1]: Started Fail2Ban Service.
Jan 31 15:30:13 web-tp6-linux fail2ban-server[1966]: 2023-01-31 15:30:13,637 fail2ban.configreader   [1966]: WARNING 'allowipv6' not defined in 'Definition'. Using default one: 'auto'
Jan 31 15:30:13 web-tp6-linux fail2ban-server[1966]: Server ready
```
- L'ip a bien était bannie :
```bash
[manon@db-tp6-linux ~]$ ssh manon@10.105.1.11
manon@10.105.1.11's password:
efPermission denied, please try again.
manon@10.105.1.11's password:
Permission denied, please try again.
manon@10.105.1.11's password:
manon@10.105.1.11: Permission denied (publickey,gssapi-keyex,gssapi-with-mic,password).
[manon@db-tp6-linux ~]$ ssh manon@10.105.1.11
ssh: connect to host 10.105.1.11 port 22: Connection refused
```
- On peut lister les IPs qui on etaient ban avec la commande :
```bash
[manon@web-tp6-linux fail2ban]$ sudo fail2ban-client status sshd
Status for the jail: sshd
|- Filter
|  |- Currently failed: 0
|  |- Total failed:     3
|  `- Journal matches:  _SYSTEMD_UNIT=sshd.service + _COMM=sshd
`- Actions
   |- Currently banned: 1
   |- Total banned:     1
   `- Banned IP list:   10.105.1.12
```
- On peut visualiser la ligne du firewall qui banne l'ip avec la commande :
```bash
[manon@web-tp6-linux fail2ban]$ sudo iptables -vnL
[sudo] password for manon:
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination
 1429 87924 f2b-sshd   tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            multiport dports 22

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain f2b-sshd (1 references)
 pkts bytes target     prot opt in     out     source               destination
   22  1260 REJECT     all  --  *      *       10.105.1.12          0.0.0.0/0            reject-with icmp-port-unreachable
 1407 86664 RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0
```
- On peut déban une ip avec la commande :
```bash
[manon@web-tp6-linux fail2ban]$ sudo fail2ban-client set sshd unbanip 10.105.1.12
```
```bash
[manon@web-tp6-linux fail2ban]$ sudo iptables -vnL
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination
 1540 94528 f2b-sshd   tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            multiport dports 22

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain f2b-sshd (1 references)
 pkts bytes target     prot opt in     out     source               destination
 1518 93268 RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0
 ```