# Partie 1 : Mise en place et maîtrise du serveur Web

- [Partie 1 : Mise en place et maîtrise du serveur Web](#partie-1--mise-en-place-et-maîtrise-du-serveur-web)
  - [1. Installation](#1-installation)
  - [2. Avancer vers la maîtrise du service](#2-avancer-vers-la-maîtrise-du-service)


## 1. Installation

🖥️ **VM web.tp5.linux**

| Machine         | IP            | Service     |
|-----------------|---------------|-------------|
| `web.tp5.linux` | `10.105.1.11` | Serveur Web |

🌞 **Installer le serveur Apache**

- paquet `httpd`
    ```bash
    [manon@web-linux-tp5 ~]$ sudo dnf install httpd -y
    ```
- la conf se trouve dans `/etc/httpd/`
  - le fichier de conf principal est `/etc/httpd/conf/httpd.conf`
  - je vous conseille **vivement** de virer tous les commentaire du fichier, à défaut de les lire, vous y verrez plus clair
    - avec `vim` vous pouvez tout virer avec `:g/^ *#.*/d`
    ```bash
    [manon@web-linux-tp5 conf]$ cat httpd.conf

    ServerRoot "/etc/httpd"

    Listen 80

    Include conf.modules.d/*.conf

    User apache
    Group apache


    ServerAdmin root@localhost


    <Directory />
        AllowOverride none
        Require all denied
    </Directory>


    DocumentRoot "/var/www/html"

    <Directory "/var/www">
        AllowOverride None
        Require all granted
    </Directory>

    <Directory "/var/www/html">
        Options Indexes FollowSymLinks

        AllowOverride None

        Require all granted
    </Directory>

    <IfModule dir_module>
        DirectoryIndex index.html
    </IfModule>

    <Files ".ht*">
        Require all denied
    </Files>

    ErrorLog "logs/error_log"

    LogLevel warn

    <IfModule log_config_module>
        LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%    {User-Agent}i\"" combined
        LogFormat "%h %l %u %t \"%r\" %>s %b" common

        <IfModule logio_module>
          LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\"  \"%{User-Agent}i\" %I %O" combinedio
        </IfModule>


        CustomLog "logs/access_log" combined
    </IfModule>

    <IfModule alias_module>


        ScriptAlias /cgi-bin/ "/var/www/cgi-bin/"

    </IfModule>

    <Directory "/var/www/cgi-bin">
        AllowOverride None
        Options None
        Require all granted
    </Directory>

    <IfModule mime_module>
        TypesConfig /etc/mime.types

        AddType application/x-compress .Z
        AddType application/x-gzip .gz .tgz



        AddType text/html .shtml
        AddOutputFilter INCLUDES .shtml
    </IfModule>

    AddDefaultCharset UTF-8

    <IfModule mime_magic_module>
        MIMEMagicFile conf/magic
    </IfModule>


    EnableSendfile on

    IncludeOptional conf.d/*.conf
    ```
🌞 **Démarrer le service Apache**

- le service s'appelle `httpd` (raccourci pour `httpd.service` en réalité)
  - démarrez-le
  ```bash
  [manon@web-linux-tp5 conf]$ sudo systemctl start httpd
  ```
  - faites en sorte qu'Apache démarre automatiquement au démarrage de la machine
  ```bash
  [manon@web-linux-tp5 conf]$ sudo systemctl enable httpd
  Created symlink /etc/systemd/system/multi-user.target.wants/     httpd.service → /usr/lib/systemd/system/httpd.service.
  ```
  - ouvrez le port firewall nécessaire
    - utiliser une commande `ss` pour savoir sur quel port tourne actuellement Apache
    ```bash
    [manon@web-linux-tp5 conf]$ sudo ss -altpn | grep httpd
    LISTEN 0      511                *:80              *:*      users:(("httpd",pid=11092,fd=4),("httpd",pid=11091,fd=4), ("httpd",pid=11090,fd=4),("httpd",pid=11088,fd=4))
    ``` 
    ```bash
    [manon@web-linux-tp5 conf]$ sudo firewall-cmd --add-port=80/tcp --permanent
    success
    [manon@web-linux-tp5 conf]$ sudo firewall-cmd --reload
    success
    ```

🌞 **TEST**

- vérifier que le service est démarré
    ```bash
    [manon@web-linux-tp5 conf]$ sudo systemctl status httpd
    ● httpd.service - The Apache HTTP Server
         Loaded: loaded (/usr/lib/systemd/system/httpd.   service; enabled;     vendor preset: disabled)
         Active: active (running) since Tue 2023-01-17    10:49:02 CET; 2min    53s ago
           Docs: man:httpd.service(8)
       Main PID: 11088 (httpd)
         Status: "Total requests: 0; Idle/Busy workers 100/0; Requests/sec:   0; Bytes served/sec:   0 B/sec"
          Tasks: 213 (limit: 2684)
         Memory: 15.2M
            CPU: 113ms
         CGroup: /system.slice/httpd.service
                 ├─11088 /usr/sbin/httpd -DFOREGROUND
                 ├─11089 /usr/sbin/httpd -DFOREGROUND
                 ├─11090 /usr/sbin/httpd -DFOREGROUND
                 ├─11091 /usr/sbin/httpd -DFOREGROUND
                 └─11092 /usr/sbin/httpd -DFOREGROUND
    
    Jan 17 10:49:01 web-linux-tp5.lab.ingesup systemd[1]:     Starting The   Apache HTTP Server...
    Jan 17 10:49:02 web-linux-tp5.lab.ingesup systemd[1]:     Started The    Apache HTTP Server.
    Jan 17 10:49:02 web-linux-tp5.lab.ingesup httpd[11088]:   Server   configured, listening on: port 80
    ```
- vérifier qu'il est configuré pour démarrer automatiquement
    ```bash
    [manon@web-linux-tp5 conf]$ sudo systemctl is-enabled httpd
    enabled
    ```
- vérifier avec une commande `curl localhost` que vous joignez votre serveur web localement
    ```bash
    [manon@web-linux-tp5 conf]$ curl localhost:80
    <!doctype html>
    <html>
      <head>
        <meta charset='utf-8'>
        <meta name='viewport' content='width=device-width,  initial-scale=1'>
        <>HTTP Server Test Page powered by: Rocky Linux</  title>
        <style type="text/css">
          /*<![CDATA[*/
    
          html {
            height: 100%;
            width: 100%;
          }
            body {
      background: rgb(20,72,50);
      background: -moz-linear-gradient(180deg, rgba(23,43,70,1)     30%, rgba(0,0,0,1) 90%)  ;
      background: -webkit-linear-gradient(180deg, rgba(23,43,70,    1) 30%, rgba(0,0,0,1) 90%) ;
      background: linear-gradient(180deg, rgba(23,43,70,1) 30%,     rgba(0,0,0,1) 90%);
      background-repeat: no-repeat;
      background-attachment: fixed;
      filter: progid:DXImageTransform.Microsoft.gradient    (startColorstr="#3c6eb4",endColorstr="#3c95b4", GradientType=1);
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
    
        .col-md-1, .col-md-2, .col-md-3, .col-md-4, .col-md-5, .    col-md-6,
        .col-md-7, .col-md-8, .col-md-9, .col-md-10, .  col-md-11, .col-md-12 {
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
        .col-sm-1, .col-sm-2, .col-sm-3, .col-sm-4, .col-sm-5, .    col-sm-6,
        .col-sm-7, .col-sm-8, .col-sm-9, .col-sm-10, .  col-sm-11, .col-sm-12 {
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
              <p class="summary">This page is used to test the  proper operation of
                an HTTP server after it has been installed on a     Rocky Linux system.
                If you can read this page, it means that the    software is working
                correctly.</p>
          </div>
    
          <div class='col-sm-12 col-md-6 col-md-6   col-md-offset-12'>
    
    
            <div class='section'>
              <h2>Just visiting?</h2>
    
              <p>This website you are visiting is either    experiencing problems or
              could be going through maintenance.</p>
    
              <p>If you would like the let the administrators   of this website know
              that you've seen this page instead of the page    you've expected, you
              should send them an email. In general, mail sent  to the name
              "webmaster" and directed to the website's domain  should reach the
              appropriate person.</p>
    
              <p>The most common email address to send to is:
              <strong>"webmaster@example.com"</strong></p>
    
              <h2>Note:</h2>
              <p>The Rocky Linux distribution is a stable and   reproduceable platform
              based on the sources of Red Hat Enterprise Linux  (RHEL). With this in
              mind, please understand that:
    
            <ul>
              <li>Neither the <>Rocky Linux Project</ strong> nor the
              <>Rocky Enterprise Software Foundation</    strong> have anything to
              do with this website or its content.</li>
              <li>The Rocky Linux Project nor the <>RESF</    strong> have
              "hacked" this webserver: This test page is    included with the
              distribution.</li>
            </ul>
            <p>For more information about Rocky Linux, please   visit the
              <a href="https://rockylinux.org/"><strong>Rocky   Linux
              website</strong></a>.
            </p>
            </div>
          </div>
          <div class='col-sm-12 col-md-6 col-md-6   col-md-offset-12'>
            <div class='section'>
    
              <h2>I am the admin, what do I do?</h2>
    
            <p>You may now add content to the webroot directory     for your
            software.</p>
    
            <p><strong>For systems using the
            <a href="https://httpd.apache.org/">Apache  Webserver</strong></a>:
            You can add content to the directory <code>/var/www/    html/</code>.
            Until you do so, people visiting your website will  see this page. If
            you would like this page to not be shown, follow    the instructions in:
            <code>/etc/httpd/conf.d/welcome.conf</code>.</p>
    
            <p><strong>For systems using
            <a href="https://nginx.org">Nginx</strong></a>:
            You can add your content in a location of your
            choice and edit the <code>root</code> configuration     directive
            in <code>/etc/nginx/nginx.conf</code>.</p>
    
            <div id="logos">
              <a href="https://rockylinux.org/"     id="rocky-poweredby"><img src="icons/poweredby. png" alt="[ Powered by Rocky Linux ]" /></a> <!--    Rocky -->
              <img src="poweredby.png" /> <!-- webserver -->
            </div>
          </div>
          </div>
    
          <footer class="col-sm-12">
          <a href="https://apache.org">Apache&trade;</a> is a   registered trademark of <a href="https://apache.  org">the Apache Software Foundation</a> in the United     States and/or other countries.<br />
          <a href="https://nginx.org">NGINX&trade;</a> is a     registered trademark of <a href="https://">F5   Networks, Inc.</a>.
          </footer>
    
      </body>
    </html>
    ```
- vérifier depuis votre PC que vous accéder à la page par défaut
  - avec votre navigateur (sur votre PC) \
  --> OK
  - avec une commande `curl` depuis un terminal de votre PC
    ```bash
    PS C:\Users\Utilisateur> curl 10.105.1.11:80
    curl : <!doctype html>
    <html>
      <head>
        <meta charset='utf-8'>
        <meta name='viewport' content='width=device-width,  initial-scale=1'>
        <>HTTP Server Test Page powered by: Rocky Linux</  title>
        <style type="text/css">
          /*<![CDATA[*/
    
          html {
            height: 100%;
            width: 100%;
          }
            body {
      background: rgb(20,72,50);
      background: -moz-linear-gradient(180deg, rgba(23,43,70,1)     30%, rgba(0,0,0,1) 90%)  ;
      background: -webkit-linear-gradient(180deg, rgba(23,43,70,    1) 30%, rgba(0,0,0,1) 90%) ;
      background: linear-gradient(180deg, rgba(23,43,70,1) 30%,     rgba(0,0,0,1) 90%);
      background-repeat: no-repeat;
      background-attachment: fixed;
      filter: progid:DXImageTransform.Microsoft.gradient    (startColorstr="#3c6eb4",endColorstr="#3c95b4", GradientType=1);
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
    
        .col-md-1, .col-md-2, .col-md-3, .col-md-4, .col-md-5, .    col-md-6,
        .col-md-7, .col-md-8, .col-md-9, .col-md-10, .  col-md-11, .col-md-12 {
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
        .col-sm-1, .col-sm-2, .col-sm-3, .col-sm-4, .col-sm-5, .    col-sm-6,
        .col-sm-7, .col-sm-8, .col-sm-9, .col-sm-10, .  col-sm-11, .col-sm-12 {
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
              <p class="summary">This page is used to test the  proper operation of
                an HTTP server after it has been installed on a     Rocky Linux system.
                If you can read this page, it means that the    software is working
                correctly.</p>
          </div>
    
          <div class='col-sm-12 col-md-6 col-md-6   col-md-offset-12'>
    
    
            <div class='section'>
              <h2>Just visiting?</h2>
              <p>This website you are visiting is either    experiencing problems or
              could be going through maintenance.</p>
              <p>If you would like the let the administrators   of this website know
              that you've seen this page instead of the page    you've expected, you
              should send them an email. In general, mail sent  to the name
              "webmaster" and directed to the website's domain  should reach the
              appropriate person.</p>
              <p>The most common email address to send to is:
              <strong>"webmaster@example.com"</strong></p>
    
              <h2>Note:</h2>
              <p>The Rocky Linux distribution is a stable and   reproduceable platform
              based on the sources of Red Hat Enterprise Linux  (RHEL). With this in
              mind, please understand that:
            <ul>
              <li>Neither the <>Rocky Linux Project</ strong> nor the
              <>Rocky Enterprise Software Foundation</    strong> have anything to
              do with this website or its content.</li>
              <li>The Rocky Linux Project nor the <>RESF</    strong> have
              "hacked" this webserver: This test page is    included with the
              distribution.</li>
            </ul>
            <p>For more information about Rocky Linux, please   visit the
              <a href="https://rockylinux.org/"><strong>Rocky   Linux
              website</strong></a>.
            </p>
            </div>
          </div>
          <div class='col-sm-12 col-md-6 col-md-6   col-md-offset-12'>
            <div class='section'>
    
              <h2>I am the admin, what do I do?</h2>
            <p>You may now add content to the webroot directory     for your
            software.</p>
            <p><strong>For systems using the
            <a href="https://httpd.apache.org/">Apache  Webserver</strong></a>:
            You can add content to the directory <code>/var/www/    html/</code>.
            Until you do so, people visiting your website will  see this page. If
            you would like this page to not be shown, follow    the instructions in:
            <code>/etc/httpd/conf.d/welcome.conf</code>.</p>
            <p><strong>For systems using
            <a href="https://nginx.org">Nginx</strong></a>:
            You can add your content in a location of your
            choice and edit the <code>root</code> configuration     directive
            in <code>/etc/nginx/nginx.conf</code>.</p>
    
            <div id="logos">
              <a href="https://rockylinux.org/"     id="rocky-poweredby"><img src="icons/poweredby. png" alt="[ Powered by Rocky Linux ]" /></a> <!--    Rocky -->
              <img src="poweredby.png" /> <!-- webserver -->
            </div>
          </div>
          </div>
    
          <footer class="col-sm-12">
          <a href="https://apache.org">Apache&trade;</a> is a   registered trademark of <a href="https://apache.  org">the Apache Software Foundation</a> in the
    United States and/or other countries.<br />
          <a href="https://nginx.org">NGINX&trade;</a> is a     registered trademark of <a href="https://">F5   Networks, Inc.</a>.
          </footer>
    
      </body>
    </html>
    ```

## 2. Avancer vers la maîtrise du service

🌞 **Le service Apache...**

- affichez le contenu du fichier `httpd.service` qui contient la définition du service Apache
    ```bash
    [manon@web-linux-tp5 conf]$  cat /usr/lib/systemd/system/httpd.service | grep Description
    Description=The Apache HTTP Server
    ```
🌞 **Déterminer sous quel utilisateur tourne le processus Apache**

- mettez en évidence la ligne dans le fichier de conf principal d'Apache (`httpd.conf`) qui définit quel user est utilisé
    ```bash
    [manon@web-linux-tp5 conf]$ cat httpd.conf | grep User
    User apache
    ```
    ```bash
    - utilisez la commande `ps -ef` pour visualiser les     processus en cours d'exécution et confirmer que apache  tourne bien sous l'utilisateur mentionné dans le fichier de  conf
      - filtrez les infos importantes avec un `| grep`
      ```bash
      apache     11473   11472  0 11:15 ?        00:00:00 /usr/ sbin/httpd -DFOREGROUND
    apache     11474   11472  0 11:15 ?        00:00:00 /usr/   sbin/httpd -DFOREGROUND
    apache     11475   11472  0 11:15 ?        00:00:00 /usr/   sbin/httpd -DFOREGROUND
    apache     11476   11472  0 11:15 ?        00:00:00 /usr/   sbin/httpd -DFOREGROUND
    ```
- la page d'accueil d'Apache se trouve dans `/usr/share/testpage/`
  - vérifiez avec un `ls -al` que tout son contenu est **accessible en lecture** à l'utilisateur mentionné dans le fichier de conf
    ```bash
    [manon@web-linux-tp5 testpage]$ ls -al
    -rw-r--r--.  1 root root 7620 Jul 27 20:05 index.html
    ```

🌞 **Changer l'utilisateur utilisé par Apache**

- créez un nouvel utilisateur
  - pour les options de création, inspirez-vous de l'utilisateur Apache existant
    - le fichier `/etc/passwd` contient les informations relatives aux utilisateurs existants sur la machine
    - servez-vous en pour voir la config actuelle de l'utilisateur Apache par défaut (son homedir et son shell en particulier)
    ```bash
    [manon@web-linux-tp5 testpage]$ sudo useradd -m -d /usr/share/httpd -s /sbin/nologin userofapache
    [manon@web-linux-tp5 testpage]$ cat /etc/passwd | grep userofapache
    userofapache:x:1001:1001::/usr/share/httpd:/sbin/nologin
    ```
- modifiez la configuration d'Apache pour qu'il utilise ce nouvel utilisateur
  - montrez la ligne de conf dans le compte rendu, avec un `grep` pour ne montrer que la ligne importante
  ```bash
  [manon@web-linux-tp5 testpage]$ cat /etc/httpd/conf/httpd.conf | grep user
  User userofapache
  ```
- redémarrez Apache
    ```bash
    [manon@web-linux-tp5 testpage]$ sudo systemctl restart httpd
    ```
- utilisez une commande `ps` pour vérifier que le changement a pris effet
  - vous devriez voir un processus au moins qui tourne sous l'identité de votre nouvel utilisateur
  ```bash
  [manon@web-linux-tp5 testpage]$ ps -ef | grep userofa
  userofa+   11784   11783  0 11:59 ?        00:00:00 /usr/  sbin/httpd -DFOREGROUND
  userofa+   11785   11783  0 11:59 ?        00:00:00 /usr/  sbin/httpd -DFOREGROUND
  userofa+   11786   11783  0 11:59 ?        00:00:00 /usr/  sbin/httpd -DFOREGROUND
  userofa+   11787   11783  0 11:59 ?        00:00:00 /usr/  sbin/httpd -DFOREGROUND
  ```

🌞 **Faites en sorte que Apache tourne sur un autre port**

- modifiez la configuration d'Apache pour lui demander d'écouter sur un autre port de votre choix
  - montrez la ligne de conf dans le compte rendu, avec un `grep` pour ne montrer que la ligne importante
  ```bash
  [manon@web-linux-tp5 testpage]$ cat /etc/httpd/conf/httpd.conf | grep Listen
  Listen 8080
  ```
- ouvrez ce nouveau port dans le firewall, et fermez l'ancien
    ```bash
    [manon@web-linux-tp5 testpage]$ sudo firewall-cmd    --add-port=8080/tcp --permanent
    success
    [manon@web-linux-tp5 testpage]$ sudo firewall-cmd   --remove-port=80/tcp --permanent
    success
    [manon@web-linux-tp5 testpage]$ sudo firewall-cmd --reload
    success
    ```
- redémarrez Apache
    ```bash
    [manon@web-linux-tp5 testpage]$ sudo systemctl restart httpd
    ```
- prouvez avec une commande `ss` que Apache tourne bien sur le nouveau port choisi
    ```bash
    [manon@web-linux-tp5 testpage]$ sudo ss -altpn | grep httpd
    LISTEN 0      511                *:8080            *:*    users:    (("httpd",pid=12062,fd=4),("httpd",pid=12061,fd=4),("httpd",pid=12060,  fd=4),("httpd",pid=12058,fd=4))
    ```
- vérifiez avec `curl` en local que vous pouvez joindre Apache sur le nouveau port
```bash
PS C:\Users\Utilisateur> curl http://10.105.1.11:8080
curl : <!doctype html>
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
      <a href="https://apache.org">Apache&trade;</a> is a registered trademark of <a href="https://apache.org">the Apache Software Foundation</a> in the
United States and/or other countries.<br />
      <a href="https://nginx.org">NGINX&trade;</a> is a registered trademark of <a href="https://">F5 Networks, Inc.</a>.
      </footer>

  </body>
</html>
```
- vérifiez avec votre navigateur que vous pouvez joindre le serveur sur le nouveau port \
--> OK

📁 **Fichier `/etc/httpd/conf/httpd.conf`**

➜ **Si c'est tout bon vous pouvez passer à [la partie 2.](./tp5_linux_p2.md)