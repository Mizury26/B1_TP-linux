# Module 4 : Monitoring

Dans ce sujet on va installer un outil plutôt clé en main pour mettre en place un monitoring simple de nos machines.

L'outil qu'on va utiliser est [Netdata](https://learn.netdata.cloud/docs/agent/packaging/installer/methods/kickstart).


🌞 **Installer Netdata**

- je vous laisse suivre la doc pour le mettre en place [ou ce genre de lien](https://wiki.crowncloud.net/?How_to_Install_Netdata_on_Rocky_Linux_9)
- vous n'avez PAS besoin d'utiliser le "Netdata Cloud" machin truc. Faites simplement une install locale.
- installez-le sur `web.tp6.linux` et `db.tp6.linux`.

-> Ok !

➜ **Une fois en place**, Netdata déploie une interface un Web pour avoir moult stats en temps réel, utilisez une commande `ss` pour repérer sur quel port il tourne.

Utilisez votre navigateur pour visiter l'interface web de Netdata `http://<IP_VM>:<PORT_NETDATA>`.

🌞 **Une fois Netdata installé et fonctionnel, déterminer :**

- l'utilisateur sous lequel tourne le(s) processus Netdata
```bash
[manon@web-tp6-linux netdata]$ cat netdata.conf | grep user
        # run as user = netdata
```

- si Netdata écoute sur des ports
    ```bash
    [manon@web-tp6-linux netdata]$ sudo ss -altpn | grep    netdata
    LISTEN 0      4096       127.0.0.1:8125       0.0.0.0:*     users:(("netdata",pid=28589,fd=63))
    LISTEN 0      4096         0.0.0.0:19999      0.0.0.0:*     users:(("netdata",pid=28589,fd=7))
    LISTEN 0      4096           [::1]:8125          [::]:*     users:(("netdata",pid=28589,fd=60))
    LISTEN 0      4096            [::]:19999         [::]:*     users:(("netdata",pid=28589,fd=8))
    ```
- comment sont consultables les logs de Netdata
```bash
[manon@web-tp6-linux netdata]$ head -n 5 access.log
2023-02-07 11:10:34: 1: 28744 '[localhost]:41076' 'CONNECTED'
2023-02-07 11:10:34: 1: 28744 '[localhost]:41076' 'DISCONNECTED'
2023-02-07 11:10:34: 1: 28744 '[localhost]:41076' 'DATA' (sent/all = 26627/26627 bytes -0%, prep/sent/total = 0.21/0.04/0.25 ms) 200 '/netdata.conf'
2023-02-07 11:17:27: 2: 28744 '[10.105.1.1]:50208' 'CONNECTED'
2023-02-07 11:17:27: 3: 28768 '[10.105.1.1]:50209' 'CONNECTED'
```
```bash
[manon@web-tp6-linux netdata]$ journalctl -u netdata | head -n 5
Feb 07 11:10:19 web-tp6-linux systemd[1]: Starting Real time performance monitoring...
Feb 07 11:10:19 web-tp6-linux systemd[1]: Started Real time performance monitoring.
Feb 07 11:10:19 web-tp6-linux netdata[28589]: CONFIG: cannot load cloud config '/var/lib/netdata/cloud.d/cloud.conf'. Running with internal defaults.
Feb 07 11:10:19 web-tp6-linux netdata[28589]: 2023-02-07 11:10:19: netdata INFO  : MAIN : CONFIG: cannot load cloud config '/var/lib/netdata/cloud.d/cloud.conf'. Running with internal defaults.
Feb 07 11:10:19 web-tp6-linux netdata[28589]: 2023-02-07 11:10:19: netdata INFO  : MAIN : Found 0 legacy dbengines, setting multidb diskspace to 256MB
```
🌞 **Configurer Netdata pour qu'il vous envoie des alertes** 

- dans [un salon Discord](https://learn.netdata.cloud/docs/agent/health/notifications/discord) dédié en cas de soucis

```bash
[manon@web-tp6-linux netdata]$ cat health_alarm_notify.conf | grep discord
# discord (discord.com) global notification options

# multiple recipients can be given like this:
#                  "CHANNEL1 CHANNEL2 ..."

# enable/disable sending discord notifications
SEND_DISCORD="YES"

# Create a webhook by following the official documentation -
# https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/1073951843450900561/qiBeEBRrujElkAEcJnv_8FB6_BdAHrtSw_DzysaK61vEQ0Mzq7AYHMh6mCmacDpJFg-n"

# if a role's recipients are not configured, a notification will be send to
# this discord channel (empty = do not send a notification for unconfigured
# roles):
DEFAULT_RECIPIENT_DISCORD="alarms"

```

🌞 **Vérifier que les alertes fonctionnent**

- en surchargeant volontairement la machine :

```bash
[manon@web-tp6-linux ~]$ stress -c 5 -m 5
stress: info: [2801] dispatching hogs: 5 cpu, 0 io, 5 vm, 0 hdd
```


