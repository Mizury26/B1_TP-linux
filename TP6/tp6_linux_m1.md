# Module 1 : Reverse Proxy

## Sommaire

- [Module 1 : Reverse Proxy](#module-1--reverse-proxy)
  - [Sommaire](#sommaire)
- [I. Setup](#i-setup)
- [II. HTTPS](#ii-https)

# I. Setup

🖥️ **VM `proxy.tp6.linux`**

🌞 **On utilisera NGINX comme reverse proxy**

- installer le paquet `nginx`
```bash
[manon@proxy-tpf6-linux ~]$ sudo dnf install nginx
```
- démarrer le service `nginx`
  ```bash
  [manon@proxy-tpf6-linux ~]$ sudo systemctl start nginx
  ```
  ```bash
  [manon@proxy-tpf6-linux ~]$ sudo systemctl status nginx
  ● nginx.service - The nginx HTTP and reverse proxy server
       Loaded: loaded (/usr/lib/systemd/system/nginx.service;   disabled; vendor prese>
       Active: active (running) since Tue 2023-01-31 17:03:23 CET;  6s ago
      Process: 1048 ExecStartPre=/usr/bin/rm -f /run/nginx.pid  (code=exited, status=>
      Process: 1049 ExecStartPre=/usr/sbin/nginx -t (code=exited,   status=0/SUCCESS)
      Process: 1050 ExecStart=/usr/sbin/nginx (code=exited,   status=0/SUCCESS)
     Main PID: 1051 (nginx)
        Tasks: 2 (limit: 2684)
       Memory: 1.9M
          CPU: 29ms
       CGroup: /system.slice/nginx.service
               ├─1051 "nginx: master process /usr/sbin/nginx"
               └─1052 "nginx: worker process"

  Jan 31 17:03:23 proxy-tpf6-linux systemd[1]: Starting The nginx   HTTP and reverse p>
  Jan 31 17:03:23 proxy-tpf6-linux nginx[1049]: nginx: the  configuration file /etc/n>
  Jan 31 17:03:23 proxy-tpf6-linux nginx[1049]: nginx:  configuration file /etc/nginx>
  Jan 31 17:03:23 proxy-tpf6-linux systemd[1]: Started The nginx  HTTP and reverse pr>
  ```
- utiliser la commande `ss` pour repérer le port sur lequel NGINX écoute
  ```bash
  [manon@proxy-tpf6-linux ~]$ sudo ss -alutnp4 | grep nginx
  tcp   LISTEN 0      511          0.0.0.0:80        0.0.0.0:*      users:(("nginx",pid=1052,fd=6),("nginx",pid=1051,fd=6))
  ```
- ouvrir un port dans le firewall pour autoriser le trafic vers NGINX
  ```bash
  [manon@proxy-tpf6-linux ~]$ sudo firewall-cmd --add-port=80/tcp --permanent
  success
  [manon@proxy-tpf6-linux ~]$ sudo firewall-cmd --reload
  success
  ```
- utiliser une commande `ps -ef` pour déterminer sous quel utilisateur tourne NGINX
  ```bash
  [manon@proxy-tpf6-linux ~]$ ps -ef | grep nginx
  nginx       1052    1051  0 17:03 ?        00:00:00 nginx:  worker process
  ```
- vérifier que le page d'accueil NGINX est disponible en faisant une requête HTTP sur le port 80 de la machine
```bash
[manon@proxy-tpf6-linux ~]$ curl localhost:80
<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
      /*<![CDATA[*/

      html {
        height: 100%;
        width: 100%;
      }
        body {
  background: rgb(20,72,50);
  background: -moz-linear-gradient(180deg, rgba(23,43,70,1) 30%, rgba(0,0,0,1) 90%)  ;
  background: -webkit-linear-gradient(180deg, rgba(23,43,70,1) 30%, rgba(0,0,0,1) 90%) ;
  background: linear-gradient(180deg, rgba(23,43,70,1) 30%, rgba(0,0,0,1) 90%);
  background-repeat: no-repeat;
  background-attachment: fixed;
  filter: progid:DXImageTransform.Microsoft.gradient(startColorstr="#3c6eb4",endColorstr="#3c95b4",GradientType=1);
        color: white;
        font-size: 0.9em;
        font-weight: 400;
        font-family: 'Montserrat', sans-serif;
        margin: 0;
        padding: 10em 6em 10em 6em;
        box-sizing: border-box;

      }


  h1 {
    text-align: center;
    margin: 0;
    padding: 0.6em 2em 0.4em;
    color: #fff;
    font-weight: bold;
    font-family: 'Montserrat', sans-serif;
    font-size: 2em;
  }
  h1 strong {
    font-weight: bolder;
    font-family: 'Montserrat', sans-serif;
  }
  h2 {
    font-size: 1.5em;
    font-weight:bold;
  }

  .title {
    border: 1px solid black;
    font-weight: bold;
    position: relative;
    float: right;
    width: 150px;
    text-align: center;
    padding: 10px 0 10px 0;
    margin-top: 0;
  }

  .description {
    padding: 45px 10px 5px 10px;
    clear: right;
    padding: 15px;
  }

  .section {
    padding-left: 3%;
   margin-bottom: 10px;
  }

  img {

    padding: 2px;
    margin: 2px;
  }
  a:hover img {
    padding: 2px;
    margin: 2px;
  }

  :link {
    color: rgb(199, 252, 77);
    text-shadow:
  }
  :visited {
    color: rgb(122, 206, 255);
  }
  a:hover {
    color: rgb(16, 44, 122);
  }
  .row {
    width: 100%;
    padding: 0 10px 0 10px;
  }

  footer {
    padding-top: 6em;
    margin-bottom: 6em;
    text-align: center;
    font-size: xx-small;
    overflow:hidden;
    clear: both;
  }

  .summary {
    font-size: 140%;
    text-align: center;
  }

  #rocky-poweredby img {
    margin-left: -10px;
  }

  #logos img {
    vertical-align: top;
  }

  /* Desktop  View Options */

  @media (min-width: 768px)  {

    body {
      padding: 10em 20% !important;
    }

    .col-md-1, .col-md-2, .col-md-3, .col-md-4, .col-md-5, .col-md-6,
    .col-md-7, .col-md-8, .col-md-9, .col-md-10, .col-md-11, .col-md-12 {
      float: left;
    }

    .col-md-1 {
      width: 8.33%;
    }
    .col-md-2 {
      width: 16.66%;
    }
    .col-md-3 {
      width: 25%;
    }
    .col-md-4 {
      width: 33%;
    }
    .col-md-5 {
      width: 41.66%;
    }
    .col-md-6 {
      border-left:3px ;
      width: 50%;


    }
    .col-md-7 {
      width: 58.33%;
    }
    .col-md-8 {
      width: 66.66%;
    }
    .col-md-9 {
      width: 74.99%;
    }
    .col-md-10 {
      width: 83.33%;
    }
    .col-md-11 {
      width: 91.66%;
    }
    .col-md-12 {
      width: 100%;
    }
  }

  /* Mobile View Options */
  @media (max-width: 767px) {
    .col-sm-1, .col-sm-2, .col-sm-3, .col-sm-4, .col-sm-5, .col-sm-6,
    .col-sm-7, .col-sm-8, .col-sm-9, .col-sm-10, .col-sm-11, .col-sm-12 {
      float: left;
    }

    .col-sm-1 {
      width: 8.33%;
    }
    .col-sm-2 {
      width: 16.66%;
    }
    .col-sm-3 {
      width: 25%;
    }
    .col-sm-4 {
      width: 33%;
    }
    .col-sm-5 {
      width: 41.66%;
    }
    .col-sm-6 {
      width: 50%;
    }
    .col-sm-7 {
      width: 58.33%;
    }
    .col-sm-8 {
      width: 66.66%;
    }
    .col-sm-9 {
      width: 74.99%;
    }
    .col-sm-10 {
      width: 83.33%;
    }
    .col-sm-11 {
      width: 91.66%;
    }
    .col-sm-12 {
      width: 100%;
    }
    h1 {
      padding: 0 !important;
    }
  }


  </style>
  </head>
  <body>
    <h1>HTTP Server <strong>Test Page</strong></h1>

    <div class='row'>

      <div class='col-sm-12 col-md-6 col-md-6 '></div>
          <p class="summary">This page is used to test the proper operation of
            an HTTP server after it has been installed on a Rocky Linux system.
            If you can read this page, it means that the software is working
            correctly.</p>
      </div>

      <div class='col-sm-12 col-md-6 col-md-6 col-md-offset-12'>


        <div class='section'>
          <h2>Just visiting?</h2>

          <p>This website you are visiting is either experiencing problems or
          could be going through maintenance.</p>

          <p>If you would like the let the administrators of this website know
          that you've seen this page instead of the page you've expected, you
          should send them an email. In general, mail sent to the name
          "webmaster" and directed to the website's domain should reach the
          appropriate person.</p>

          <p>The most common email address to send to is:
          <strong>"webmaster@example.com"</strong></p>

          <h2>Note:</h2>
          <p>The Rocky Linux distribution is a stable and reproduceable platform
          based on the sources of Red Hat Enterprise Linux (RHEL). With this in
          mind, please understand that:

        <ul>
          <li>Neither the <strong>Rocky Linux Project</strong> nor the
          <strong>Rocky Enterprise Software Foundation</strong> have anything to
          do with this website or its content.</li>
          <li>The Rocky Linux Project nor the <strong>RESF</strong> have
          "hacked" this webserver: This test page is included with the
          distribution.</li>
        </ul>
        <p>For more information about Rocky Linux, please visit the
          <a href="https://rockylinux.org/"><strong>Rocky Linux
          website</strong></a>.
        </p>
        </div>
      </div>
      <div class='col-sm-12 col-md-6 col-md-6 col-md-offset-12'>
        <div class='section'>

          <h2>I am the admin, what do I do?</h2>

        <p>You may now add content to the webroot directory for your
        software.</p>

        <p><strong>For systems using the
        <a href="https://httpd.apache.org/">Apache Webserver</strong></a>:
        You can add content to the directory <code>/var/www/html/</code>.
        Until you do so, people visiting your website will see this page. If
        you would like this page to not be shown, follow the instructions in:
        <code>/etc/httpd/conf.d/welcome.conf</code>.</p>

        <p><strong>For systems using
        <a href="https://nginx.org">Nginx</strong></a>:
        You can add your content in a location of your
        choice and edit the <code>root</code> configuration directive
        in <code>/etc/nginx/nginx.conf</code>.</p>

        <div id="logos">
          <a href="https://rockylinux.org/" id="rocky-poweredby"><img src="icons/poweredby.png" alt="[ Powered by Rocky Linux ]" /></a> <!-- Rocky -->
          <img src="poweredby.png" /> <!-- webserver -->
        </div>
      </div>
      </div>

      <footer class="col-sm-12">
      <a href="https://apache.org">Apache&trade;</a> is a registered trademark of <a href="https://apache.org">the Apache Software Foundation</a> in the United States and/or other countries.<br />
      <a href="https://nginx.org">NGINX&trade;</a> is a registered trademark of <a href="https://">F5 Networks, Inc.</a>.
      </footer>

  </body>
</html>
```

🌞 **Configurer NGINX**

- nous ce qu'on veut, c'est que NGINX agisse comme un reverse proxy entre les clients et notre serveur Web
- deux choses à faire :
  - créer un fichier de configuration NGINX
    - repérez les fichiers inclus par le fichier de conf principal, et créez votre fichier de conf en conséquence
    ```bash
    [manon@proxy-tp6-linux nginx]$ cat nginx.conf | grep include
    include /etc/nginx/conf.d/*.conf;
    ```
    ```bash
    [manon@proxy-tp6-linux conf.d]$ sudo vim rproxy.conf
    [manon@proxy-tp6-linux conf.d]$ cat rproxy.conf
    server {
    # On indique le nom que client va saisir pour accéder au service
    # Pas d'erreur ici, c'est bien le nom de web, et pas de proxy qu'on veut ici !
    server_name www.nextcloud.tp6;

    # Port d'écoute de NGINX
    listen 80;

    location / {
        # On définit des headers HTTP pour que le proxying se passe bien
        proxy_set_header  Host $host;
        proxy_set_header  X-Real-IP $remote_addr;
        proxy_set_header  X-Forwarded-Proto https;
        proxy_set_header  X-Forwarded-Host $remote_addr;
        proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;

        # On définit la cible du proxying
        proxy_pass http://<IP_DE_NEXTCLOUD>:80;
    }

    # Deux sections location recommandés par la doc NextCloud
    location /.well-known/carddav {
      return 301 $scheme://$host/remote.php/dav;
    }

    location /.well-known/caldav {
      return 301 $scheme://$host/remote.php/dav;
      }
    }
    ```
  - NextCloud est un peu exigeant, et il demande à être informé si on le met derrière un reverse proxy
    - y'a donc un fichier de conf NextCloud à modifier
    - c'est un fichier appelé `config.php`
    - la clause à modifier dans ce fichier est `trusted_domains`
     ```bash
     [manon@web-tp6-linux config]$ sudo cat config.php
    <?php
    $CONFIG = array (
      'instanceid' => 'oc465yg1dcim',
      'passwordsalt' => 'xaDNsJJ0ZomQ9fs9bGq73M5NLP6L6Z',
      'secret' => 'c7MliOl2pFevAmIxHJ9o2zUEDcCgopi642Yhf9cdhoXK0    +f/',
      'trusted_domains' =>
      array (
              0 => 'web.tp5.linux',
              1 => '10.105.1.13',
      ),
      'datadirectory' => '/var/www/tp5_nextcloud/data',
      'dbtype' => 'mysql',
      'version' => '25.0.0.15',
      'overwrite.cli.url' => 'http://web.tp6.linux',
      'dbname' => 'nextcloud',
      'dbhost' => '10.105.1.12',
      'dbport' => '',
      'dbtableprefix' => 'oc_',
      'mysql.utf8mb4' => true,
      'dbuser' => 'nextcloud',
      'dbpassword' => 'pewpewpew',
      'installed' => true,
    );
    ```

➜ **Modifier votre fichier `hosts` de VOTRE PC**

  - `www.nextcloud.tp6` pointe vers l'IP du reverse proxy
  - `proxy.tp6.linux` ne pointe vers rien
  - taper `http://www.nextcloud.tp6` permet d'accéder au site (en passant de façon transparente par l'IP du proxy)

```bash
Manon@PC-Manon MINGW64 /c/Windows/System32/drivers/etc
$ cat hosts
10.105.1.11 web-tp6-linux
10.105.1.12 db-tp6-linux
10.105.1.13 www.nextcloud.tp6
```

🌞 **Faites en sorte de**

- rendre le serveur `web.tp6.linux` injoignable
- sauf depuis l'IP du reverse proxy
- en effet, les clients ne doivent pas joindre en direct le serveur web : notre reverse proxy est là pour servir de serveur frontal

```bash
[manon@web-tp6-linux ~]$ sudo firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" source address="10.105.1.13" accept'
success
[manon@web-tp6-linux ~]$ sudo firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" source not address="10.105.1.13" reject'
success
[manon@web-tp6-linux ~]$ sudo firewall-cmd --reload
success
```

🌞 **Une fois que c'est en place**

- faire un `ping` manuel vers l'IP de `proxy.tp6.linux` fonctionne
    ```bash
    PS C:\Users\Utilisateur> ping 10.105.1.13

    Envoi d’une requête 'Ping'  10.105.1.13 avec 32 octets de données :
    Réponse de 10.105.1.13 : octets=32 temps<1ms TTL=64
    Réponse de 10.105.1.13 : octets=32 temps<1ms TTL=64
    Réponse de 10.105.1.13 : octets=32 temps<1ms TTL=64

    Statistiques Ping pour 10.105.1.13:
        Paquets : envoyés = 3, reçus = 3, perdus = 0 (perte 0%),
    Durée approximative des boucles en millisecondes :
    Minimum = 0ms, Maximum = 0ms, Moyenne = 0ms
    ```
- faire un `ping` manuel vers l'IP de `web.tp6.linux` ne fonctionne pas
    ```bash
    PS C:\Users\Utilisateur> ping 10.105.1.11

    Envoi d’une requête 'Ping'  10.105.1.11 avec 32 octets de données :
    Réponse de 10.105.1.11 : Impossible de joindre le port de destination.
    Réponse de 10.105.1.11 : Impossible de joindre le port de destination.
    Réponse de 10.105.1.11 : Impossible de joindre le port de destination.

    Statistiques Ping pour 10.105.1.11:
    Paquets : envoyés = 3, reçus = 3, perdus = 0 (perte 0%),
    ```

# II. HTTPS

🌞 **Faire en sorte que NGINX force la connexion en HTTPS plutôt qu'HTTP**

Le principe :

- on génère une paire de clés sur le serveur `proxy.tp6.linux`
  - une des deux clés sera la clé privée : elle restera sur le serveur et ne bougera jamais
  - l'autre est la clé publique : elle sera stockée dans un fichier appelé *certificat*
    - le *certificat* est donné à chaque client qui se connecte au site
  ```bash
  [manon@proxy-tp6-linux ~]$  sudo openssl req -x509 -nodes -day  365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx.key -out /et  ssl/certs/certificate
  ```
- on ajuste la conf NGINX
  - on lui indique le chemin vers le certificat et la clé privée afin qu'il puisse les utiliser pour chiffrer le trafic
  - on lui demande d'écouter sur le port convetionnel pour HTTPS : 443 en TCP
  ```bash
  [manon@proxy-tp6-linux conf.d]$ cat rproxy.conf
  server {
    # On indique le nom que client va saisir pour accéder au service
    # Pas d'erreur ici, c'est bien le nom de web, et pas de proxy qu'on veut ici !
    server_name www.nextcloud.tp6;

    # Port d'écoute de NGINX
    listen 80;

    location / {
        # On définit des headers HTTP pour que le proxying se passe bien
        proxy_set_header  Host $host;
        proxy_set_header  X-Real-IP $remote_addr;
        proxy_set_header  X-Forwarded-Proto https;
        proxy_set_header  X-Forwarded-Host $remote_addr;
        proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;

        # On définit la cible du proxying
        proxy_pass http://10.105.1.11:80;
    }

    # Deux sections location recommandés par la doc NextCloud
    location /.well-known/carddav {
      return 301 $scheme://$host/remote.php/dav;
    }

    location /.well-known/caldav {
      return 301 $scheme://$host/remote.php/dav;
    }

    listen 443 http2 ssl;
    listen [::]:443 http2 ssl;
    ssl_certificate /etc/ssl/certs/certificate;
    ssl_certificate_key /etc/ssl/private/nginx.key;

  }
  ```
```bash
[manon@proxy-tp6-linux conf.d]$ sudo firewall-cmd --add-port=443/tcp --permanent
success
[manon@proxy-tp6-linux conf.d]$ sudo firewall-cmd --reload
success
[manon@proxy-tp6-linux conf.d]$ sudo firewall-cmd --list-all | grep ports
ports: 80/tcp 443/tcp
```