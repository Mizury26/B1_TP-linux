# Partie 3 : Configuration et mise en place de NextCloud


- [Partie 3 : Configuration et mise en place de NextCloud](#partie-3--configuration-et-mise-en-place-de-nextcloud)
  - [1. Base de données](#1-base-de-données)
  - [2. Serveur Web et NextCloud](#2-serveur-web-et-nextcloud)
  - [3. Finaliser l'installation de NextCloud](#3-finaliser-linstallation-de-nextcloud)

## 1. Base de données

🌞 **Préparation de la base pour NextCloud**

- une fois en place, il va falloir préparer une base de données pour NextCloud :
  - connectez-vous à la base de données à l'aide de la commande `sudo mysql -u root -p`
  - exécutez les commandes SQL :
  ```sql
  [manon@db-linux-tp5 ~]$ sudo mysql -u root -p
  [sudo] password for manon:
  Enter password:
  Welcome to the MariaDB monitor.  Commands end with ; or \g.
  Your MariaDB connection id is 16
  Server version: 10.5.16-MariaDB MariaDB Server
  
  Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab     and others.
  
  Type 'help;' or '\h' for help. Type '\c' to clear the    current input statement.
  ```sql
  MariaDB [(none)]> CREATE USER 'nextcloud'@'10.105.1.11' IDENTIFIED BY 'cloud'
    -> CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci
    -> GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'10.105.1.11'
    -> FLUSH PRIVILEGES
    -> ;
    ERROR 1064 (42000): You have an error in your SQL syntax;   check the manual that corresponds to your MariaDB server  version for the right syntax to use near 'CREATE DATABASE    IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE  utf8mb4...' at line 2
    MariaDB [(none)]> CREATE USER 'nextcloud'@'10.105.1.11'     IDENTIFIED BY 'pewpewpew';
    Query OK, 0 rows affected (0.003 sec)

    MariaDB [(none)]> CREATE DATABASE IF NOT EXISTS nextcloud   CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
    Query OK, 1 row affected (0.000 sec)

    MariaDB [(none)]> GRANT ALL PRIVILEGES ON nextcloud.* TO    'nextcloud'@'10.105.1.11';
    Query OK, 0 rows affected (0.001 sec)

    MariaDB [(none)]> FLUSH PRIVILEGES;
    Query OK, 0 rows affected (0.000 sec)

    MariaDB [(none)]> exit
    Bye
    ```

🌞 **Exploration de la base de données**

- afin de tester le bon fonctionnement de la base de données, vous allez essayer de vous connecter, **comme NextCloud le fera plus tard** :
  - depuis la machine `web.tp5.linux` vers l'IP de `db.tp5.linux`
  - utilisez la commande `mysql` pour vous connecter à une base de données depuis la ligne de commande

- **donc vous devez effectuer une commande `mysql` sur `web.tp5.linux`**

- une fois connecté à la base, utilisez les commandes SQL fournies ci-dessous pour explorer la base

```sql
SHOW DATABASES;
USE <DATABASE_NAME>;
SHOW TABLES;
```
```bash
[manon@web-linux-tp5 /]$ mysql -u nextcloud -h 10.105.1.12 -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 19
Server version: 5.5.5-10.5.16-MariaDB MariaDB Server
Copyright (c) 2000, 2022, Oracle and/or its affiliates.
Oracle is a registered trademark of Oracle Corporationand/ or its
affiliates. Other names may be trademarks of their respective
owners.
Type 'help;' or '\h' for help. Type '\c' to clear the  current input statement.

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| nextcloud          |
+--------------------+
2 rows in set (0.01 sec)

mysql> use nextcloud;
Database changed
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| nextcloud          |
+--------------------+
2 rows in set (0.00 sec)
```


🌞 **Trouver une commande SQL qui permet de lister tous les utilisateurs de la base de données**

- vous ne pourrez pas utiliser l'utilisateur `nextcloud` de la base pour effectuer cette opération : il n'a pas les droits
- il faudra donc vous reconnectez localement à la base en utilisant l'utilisateur `root`

```sql
[manon@db-linux-tp5 ~]$    
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 7
Server version: 10.5.16-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
MariaDB [(none)]> SELECT User FROM mysql.user;
+-------------+
| User        |
+-------------+
| nextcloud   |
| mariadb.sys |
| mysql       |
| root        |
+-------------+
4 rows in set (0.001 sec)
```

## 2. Serveur Web et NextCloud

⚠️⚠️⚠️ **N'OUBLIEZ PAS de réinitialiser votre conf Apache avant de continuer. En particulier, remettez le port et le user par défaut.**

```bash
[manon@web-linux-tp5 ~]$ head -n 10 /etc/httpd/conf/httpd.conf              
ServerRoot "/etc/httpd"

Listen 80

Include conf.modules.d/*.conf

User apache
Group apache
```
```bash
[manon@web-linux-tp5 ~]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources:
  services: cockpit dhcpv6-client ssh
  ports: 80/tcp
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

🌞 **Install de PHP**

```bash
# On ajoute le dépôt CRB
$ sudo dnf config-manager --set-enabled crb
# On ajoute le dépôt REMI
$ sudo dnf install dnf-utils http://rpms.remirepo.net/enterprise/remi-release-9.rpm -y

# On liste les versions de PHP dispos, au passage on va pouvoir accepter les clés du dépôt REMI
$ dnf module list php

# On active le dépôt REMI pour récupérer une version spécifique de PHP, celle recommandée par la doc de NextCloud
$ sudo dnf module enable php:remi-8.1 -y

# Eeeet enfin, on installe la bonne version de PHP : 8.1
$ sudo dnf install -y php81-php
```
-> Ok

🌞 **Install de tous les modules PHP nécessaires pour NextCloud**

```bash
# eeeeet euuuh boom. Là non plus j'ai pas pondu ça, c'est la doc :
$ sudo dnf install -y libxml2 openssl php81-php php81-php-ctype php81-php-curl php81-php-gd php81-php-iconv php81-php-json php81-php-libxml php81-php-mbstring php81-php-openssl php81-php-posix php81-php-session php81-php-xml php81-php-zip php81-php-zlib php81-php-pdo php81-php-mysqlnd php81-php-intl php81-php-bcmath php81-php-gmp
```
-> Ok

🌞 **Récupérer NextCloud**

- créez le dossier `/var/www/tp5_nextcloud/`
  ```bash
  [manon@web-linux-tp5 ~]$ sudo mkdir /var/www/tp5_nextcloud
  ```
- récupérer le fichier suivant avec une commande `curl` ou `wget` : https://download.nextcloud.com/server/prereleases/nextcloud-25.0.0rc3.zip
  ```bash
  [manon@web-linux-tp5 ~]$ sudo dnf install wget
  [manon@web-linux-tp5 ~]$ wget https://download.nextcloud.com/server/prereleases/nextcloud-25.0.0rc3.zip
  ```
- extrayez tout son contenu dans le dossier `/var/www/tp5_nextcloud/` en utilisant la commande `unzip`
```bash	
[manon@web-linux-tp5 ~]$ sudo dnf install unzip -y
```
  ```bash
  [manon@web-linux-tp5 ~]$ unzip /home/manon/nextcloud-25.0.0rc3.zip
  ```
  ```bash
  [manon@web-linux-tp5 nextcloud]$ sudo mv * /var/www/tp5_nextcloud
  ```
  - contrôlez que le fichier `/var/www/tp5_nextcloud/index.html` existe pour vérifier que tout est en place
  ```bash
  [manon@web-linux-tp5 tp5_nextcloud]$ ls | grep index
  index.html
  ```
- **assurez-vous que le dossier `/var/www/tp5_nextcloud/` et tout son contenu appartient à l'utilisateur qui exécute le service Apache**
  - utilisez une commande `chown` si nécessaire
  ```bash
  [manon@web-linux-tp5 www]$ sudo chown -R apache:apache tp5_nextcloud/
  [manon@web-linux-tp5 www]$ ls -al | grep tp5
  drwxr-xr-x.  3 apache root   23 Jan 29 15:07 tp5_nextcloud
  ```

🌞 **Adapter la configuration d'Apache**

- regardez la dernière ligne du fichier de conf d'Apache pour constater qu'il existe une ligne qui inclut d'autres fichiers de conf
- créez en conséquence un fichier de configuration qui porte un nom clair et qui contient la configuration suivante :

```apache
<VirtualHost *:80>
  # on indique le chemin de notre webroot
  DocumentRoot /var/www/tp5_nextcloud/
  # on précise le nom que saisissent les clients pour accéder au service
  ServerName  web.tp5.linux

  # on définit des règles d'accès sur notre webroot
  <Directory /var/www/tp5_nextcloud/> 
    Require all granted
    AllowOverride All
    Options FollowSymLinks MultiViews
    <IfModule mod_dav.c>
      Dav off
    </IfModule>
  </Directory>
</VirtualHost>
```
```bash
[manon@web-linux-tp5 conf.d]$ sudo vim website.conf
[manon@web-linux-tp5 conf.d]$ cat website.conf
<VirtualHost *:80>
  # on indique le chemin de notre webroot
  DocumentRoot /var/www/tp5_nextcloud/
  # on précise le nom que saisissent les clients pour accéder au service
  ServerName  web.tp5.linux

  # on définit des règles d'accès sur notre webroot
  <Directory /var/www/tp5_nextcloud/>
    Require all granted
    AllowOverride All
    Options FollowSymLinks MultiViews
    <IfModule mod_dav.c>
      Dav off
    </IfModule>
  </Directory>
</VirtualHost>
```

🌞 **Redémarrer le service Apache** pour qu'il prenne en compte le nouveau fichier de conf
```bash
[manon@web-linux-tp5 conf.d]$ sudo systemctl restart httpd
```


## 3. Finaliser l'installation de NextCloud

➜ **Sur votre PC**

- modifiez votre fichier `hosts` (oui, celui de votre PC, de votre hôte)
  - pour pouvoir joindre l'IP de la VM en utilisant le nom `web.tp5.linux`
- avec un navigateur, visitez NextCloud à l'URL `http://web.tp5.linux`
```bash
[manon@web-linux-tp5 ~]$ curl localhost -v
*   Trying ::1:80...
* Connected to localhost (::1) port 80 (#0)
> GET / HTTP/1.1
> Host: localhost
> User-Agent: curl/7.76.1
> Accept: */*
>
* Mark bundle as not supporting multiuse
< HTTP/1.1 200 OK
< Date: Tue, 31 Jan 2023 10:24:52 GMT
< Server: Apache/2.4.53 (Rocky Linux)
< X-Powered-By: PHP/8.1.14
< Content-Security-Policy: default-src 'self'; script-src 'self' 'nonce-ck1ZNC9LNDdQT0t1WXRudVVEdmQ2dm5YbDVpZUZZeVZ1ZWVUT1hoUThvTT06Nkx4UGxOb0NjcVBaQWI3WkpFT3JqWjZFeGRUeFdlZjc3WVRMWGhRRHRQaz0='; style-src 'self' 'unsafe-inline'; frame-src *; img-src * data: blob:; font-src 'self' data:; media-src *; connect-src *; object-src 'none'; base-uri 'self';
< Expires: Thu, 19 Nov 1981 08:52:00 GMT
< Cache-Control: no-store, no-cache, must-revalidate
< Pragma: no-cache
< Set-Cookie: oc_sessionPassphrase=yHTjOrPbWtZotJyVCNYYKftW7t41bajDWREQPSAx8FqgsNsm%2FqxO17Z7wYsek42SwwBAcTcc99qFq8Ehr13eHErzqv5diT9PMbBCQ1AVUNwFFrpVEUyhBldaLSjsB11Z; path=/; HttpOnly; SameSite=Lax
< Set-Cookie: nc_sameSiteCookielax=true; path=/; httponly;expires=Fri, 31-Dec-2100 23:59:59 GMT; SameSite=lax
< Set-Cookie: nc_sameSiteCookiestrict=true; path=/; httponly;expires=Fri, 31-Dec-2100 23:59:59 GMT; SameSite=strict
< Set-Cookie: oc8mfjj1b7c8=hc45at9cnj00u2d704p3m5p1ep; path=/; HttpOnly; SameSite=Lax
< Referrer-Policy: no-referrer
< X-Content-Type-Options: nosniff
< X-Frame-Options: SAMEORIGIN
< X-Permitted-Cross-Domain-Policies: none
< X-Robots-Tag: none
< X-XSS-Protection: 1; mode=block
< Transfer-Encoding: chunked
< Content-Type: text/html; charset=UTF-8
<
<!DOCTYPE html>
<html class="ng-csp" data-placeholder-focus="false" lang="en" data-locale="en" >
        <head
 data-requesttoken="rMY4/K47POKuYtnuUDvd6vnXl5ieFYyVueeTOXhQ8oM=:6LxPlNoCcqPZAb7ZJEOrjZ6ExdTxWef77YTLXhQDtPk=">
                <meta charset="utf-8">
                <title>
                        Nextcloud               </title>
                <meta name="viewport" content="width=device-width, initial-scale=1.0, minimum-scale=1.0">
                                <meta name="apple-itunes-app" content="app-id=1125420102">
                                <meta name="theme-color" content="#0082c9">
                <link rel="icon" href="/core/img/favicon.ico">
                <link rel="apple-touch-icon" href="/core/img/favicon-touch.png">
                <link rel="mask-icon" sizes="any" href="/core/img/favicon-mask.svg" color="#0082c9">
                <link rel="manifest" href="/core/img/manifest.json">
                <link rel="stylesheet" href="/core/css/server.css?v=ba222ded25d957b900c03bef914333cd">
<link rel="stylesheet" href="/apps/theming/css/default.css?v=ba222ded25d957b900c03bef914333cd">
<link rel="stylesheet" href="/core/css/guest.css?v=ba222ded25d957b900c03bef914333cd">
                <script nonce="ck1ZNC9LNDdQT0t1WXRudVVEdmQ2dm5YbDVpZUZZeVZ1ZWVUT1hoUThvTT06Nkx4UGxOb0NjcVBaQWI3WkpFT3JqWjZFeGRUeFdlZjc3WVRMWGhRRHRQaz0=" defer src="/dist/core-common.js?v=ba222ded25d957b900c03bef914333cd"></script>
<script nonce="ck1ZNC9LNDdQT0t1WXRudVVEdmQ2dm5YbDVpZUZZeVZ1ZWVUT1hoUThvTT06Nkx4UGxOb0NjcVBaQWI3WkpFT3JqWjZFeGRUeFdlZjc3WVRMWGhRRHRQaz0=" defer src="/dist/core-main.js?v=ba222ded25d957b900c03bef914333cd"></script>
<script nonce="ck1ZNC9LNDdQT0t1WXRudVVEdmQ2dm5YbDVpZUZZeVZ1ZWVUT1hoUThvTT06Nkx4UGxOb0NjcVBaQWI3WkpFT3JqWjZFeGRUeFdlZjc3WVRMWGhRRHRQaz0=" defer src="/dist/core-install.js?v=ba222ded25d957b900c03bef914333cd"></script>
                        </head>
        <body id="body-login">
                <noscript>
        <div id="nojavascript">
                <div>
                        This application requires JavaScript for correct operation. Please <a href="https://www.enable-javascript.com/" target="_blank" rel="noreferrer noopener">enable JavaScript</a> and reload the page.            </div>
        </div>
</noscript>
                                <div class="wrapper">
                        <div class="v-align">
                                                                        <header role="banner">
                                                <div id="header">
                                                        <div class="logo"></div>
                                                </div>
                                        </header>
                                                                <main>
                                        <h1 class="hidden-visually">
                                                Nextcloud                                       </h1>
                                        <input type='hidden' id='hasMySQL' value='1'>
<input type='hidden' id='hasSQLite' value='1'>
<input type='hidden' id='hasPostgreSQL' value=''>
<input type='hidden' id='hasOracle' value=''>
<form action="index.php" method="post" class="guest-box install-form">
<input type="hidden" name="install" value="true">
                        <fieldset id="adminaccount">
                <legend>Create an <strong>admin account</strong></legend>
                <p>
                        <label for="adminlogin">Username</label>
                        <input type="text" name="adminlogin" id="adminlogin"
                                value=""
                                autocomplete="off" autocapitalize="none" autocorrect="off" autofocus required>
                </p>
                <p class="groupbottom">
                        <label for="adminpass">Password</label>
                        <input type="password" name="adminpass" data-typetoggle="#show" id="adminpass"
                                value=""
                                autocomplete="off" autocapitalize="none" autocorrect="off" required>
                        <button id="show" class="toggle-password" aria-label="Show password">
                                <img src="/core/img/actions/toggle.svg" alt="Toggle password visibility">
                        </button>
                </p>
        </fieldset>

                <fieldset id="advancedHeader">
                <legend><a id="showAdvanced" tabindex="0" href="#">Storage &amp; database<img src="/core/img/actions/caret.svg" /></a></legend>
        </fieldset>

                <fieldset id="datadirField">
                <div id="datadirContent">
                        <label for="directory">Data folder</label>
                        <input type="text" name="directory" id="directory"
                                placeholder="/var/www/tp5_nextcloud/data"
                                value="/var/www/tp5_nextcloud/data"
                                autocomplete="off" autocapitalize="none" autocorrect="off">
                </div>
        </fieldset>

                <fieldset id='databaseBackend'>
                                <legend>Configure the database</legend>
                <div id="selectDbType">
                                                <input type="radio" name="dbtype" value="sqlite" id="sqlite"
                        />
                <label class="sqlite" for="sqlite">SQLite</label>
                                                                <input type="radio" name="dbtype" value="mysql" id="mysql"
                        />
                <label class="mysql" for="mysql">MySQL/MariaDB</label>
                                                </div>
        </fieldset>

                                <fieldset id='databaseField'>
                <div id="use_other_db">
                        <p class="grouptop">
                                <label for="dbuser">Database user</label>
                                <input type="text" name="dbuser" id="dbuser"
                                        value=""
                                        autocomplete="off" autocapitalize="none" autocorrect="off">
                        </p>
                        <p class="groupmiddle">
                                <label for="dbpass">Database password</label>
                                <input type="password" name="dbpass" id="dbpass"
                                        value=""
                                        autocomplete="off" autocapitalize="none" autocorrect="off">
                                <button id="show" class="toggle-password" aria-label="Show password">
                                        <img src="/core/img/actions/toggle.svg" alt="Toggle password visibility">
                                </button>
                        </p>
                        <p class="groupmiddle">
                                <label for="dbname">Database name</label>
                                <input type="text" name="dbname" id="dbname"
                                        value=""
                                        autocomplete="off" autocapitalize="none" autocorrect="off"
                                        pattern="[0-9a-zA-Z$_-]+">
                        </p>
                                                <p class="groupbottom">
                                <label for="dbhost">Database host</label>
                                <input type="text" name="dbhost" id="dbhost"
                                        value="localhost"
                                        autocomplete="off" autocapitalize="none" autocorrect="off">
                        </p>
                        <p class="info">
                                Please specify the port number along with the host name (e.g., localhost:5432).                 </p>
                </div>
                </fieldset>

                        <div id="sqliteInformation" class="notecard warning">
                        <legend>Performance warning</legend>
                        <p>You chose SQLite as database.</p>
                        <p>SQLite should only be used for minimal and development instances. For production we recommend a different database backend.</p>
                        <p>If you use clients for file syncing, the use of SQLite is highly discouraged.</p>
                </div>

        <div class="icon-loading-dark float-spinner">&nbsp;</div>

        <div class="buttons"><input type="submit" class="primary" value="Install" data-finishing="Installing …"></div>

        <p class="info">
                <span class="icon-info-white"></span>
                Need help?              <a target="_blank" rel="noreferrer noopener" href="https://docs.nextcloud.com/server/25/go.php?to=admin-install">See the documentation ↗</a>
        </p>
</form>
                                </main>
                        </div>
                </div>
                <footer role="contentinfo">
                        <p class="info">
                                <a href="https://nextcloud.com" target="_blank" rel="noreferrer noopener">Nextcloud</a> – a safe home for all your data                 </p>
                </footer>
        </body>
</html>
* Connection #0 to host localhost left intact
```
  - c'est possible grâce à la modification de votre fichier `hosts`
- on va vous demander un utilisateur et un mot de passe pour créer un compte admin (id : admin mdp : admin1234)
  - ne saisissez rien pour le moment
- cliquez sur "Storage & Database" juste en dessous
  - choisissez "MySQL/MariaDB"
  - saisissez les informations pour que NextCloud puisse se connecter avec votre base
- saisissez l'identifiant et le mot de passe admin que vous voulez, et validez l'installation

🌴 **C'est chez vous ici**, baladez vous un peu sur l'interface de NextCloud, faites le tour du propriétaire :)

🌞 **Exploration de la base de données**

- connectez vous en ligne de commande à la base de données après l'installation terminée
  ```bash
  [manon@db-linux-tp5 ~]$ sudo mysql -u root
  ```
- déterminer combien de tables ont été crées par NextCloud lors de la finalisation de l'installation
  - ***bonus points*** si la réponse à cette question est automatiquement donnée par une requête SQL
  ```sql
  Welcome to the MariaDB monitor.  Commands end with ; or \g.
  Your MariaDB connection id is 145
  Server version: 10.5.16-MariaDB MariaDB Server
  
  Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and  others.
  
  Type 'help;' or '\h' for help. Type '\c' to clear the   current input statement.
  
  MariaDB [(none)]> SELECT count(*) AS number FROM  INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'nextcloud';
  +--------+
  | number |
  +--------+
  |     95 |
  +--------+
  1 row in set (0.000 sec)
  
  MariaDB [(none)]>
  ```

➜ **NextCloud est tout bo, en place, vous pouvez aller sur [la partie 4.](../part4/README.md)**
