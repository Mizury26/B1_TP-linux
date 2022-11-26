# TP1 : Are you dead yet ?  

- [TP1 : Are you dead yet ?](#tp1--are-you-dead-yet-)
- [I. Intro](#i-intro)
  - [II. Feu](#ii-feu)

# I. Intro

**Le but va être de péter la machine virtuelle.**

Par "péter" on entend la rendre inutilisable :

➜ Si la machine boot même plus, c'est valide  
➜ Si la machine boot, mais que en mode *rescue*, et qu'on peut pas rétablir, c'est valide  
➜ Si la machine boot, mais que l'expérience utilisateur est tellement dégradée qu'on peut rien faire, c'est valide

**Bref si on peut pas utiliser la machine normalement, c'est VA-LI-DE.**  

## II. Feu

🌞 **Trouver au moins 4 façons différentes de péter la machine :**

- VM 1 :
 on supprime le programme GRUP qui permet de faire démarrer la vm :
```
cd /run
```
```
rm GRUB
```
- VM 2 :
 on supprime le shell bash ce qui empêche l'utilisateur de se connecter :
```
rm /usr/bin/bash

```
- VM 3 :
 on créer un service qui éteint la VM dès son démarrage :
 ```
 cd /etc/systemd/system
```
```
sudo nano mtn.service
```
```
[Unit]
Description=shutdown attack

[Service]
Type=simple
ExecStart=/usr/sbin/shutdown


[Install]
WantedBy=multi-user.target
```


- VM 4 :
 on remplit la partition du disque par des zéros ce qui le rend inutilisable :
```
sudo dd if=/dev/zero of=/dev/sga bs=4M
```
