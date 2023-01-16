# Partie 3 : Serveur web

- [Partie 3 : Serveur web](#partie-3--serveur-web)
  - [1. Intro NGINX](#1-intro-nginx)
  - [2. Install](#2-install)
  - [3. Analyse](#3-analyse)
  - [4. Visite du service web](#4-visite-du-service-web)
  - [5. Modif de la conf du serveur web](#5-modif-de-la-conf-du-serveur-web)
  - [6. Deux sites web sur un seul serveur](#6-deux-sites-web-sur-un-seul-serveur)

## 1. Intro NGINX

## 2. Install

🖥️ **VM web.tp4.linux**

🌞 **Installez NGINX**
```bahs
[manon@webtp4linux site_web_1]$ sudo dnf install nginx
```

## 3. Analyse

Avant de config des truks 2 ouf étou, on va lancer à l'aveugle et inspecter ce qu'il se passe, inspecter avec les outils qu'on connaît ce que fait NGINX à notre OS.

Commencez donc par démarrer le service NGINX :

```bash
[manon@webtp4linux site_web_1]$ sudo systemctl start nginx
[manon@webtp4linux site_web_1]$ sudo systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
     Active: active (running) since Mon 2023-01-16 16:25:12 CET; 39s ago
    Process: 1156 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
    Process: 1157 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
    Process: 1158 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
   Main PID: 1159 (nginx)
      Tasks: 2 (limit: 2684)
     Memory: 1.9M
        CPU: 14ms
     CGroup: /system.slice/nginx.service
             ├─1159 "nginx: master process /usr/sbin/nginx"
             └─1160 "nginx: worker process"

Jan 16 16:25:12 webtp4linux.lab.ingesup systemd[1]: Starting The nginx HTTP and reverse proxy server...
Jan 16 16:25:12 webtp4linux.lab.ingesup nginx[1157]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Jan 16 16:25:12 webtp4linux.lab.ingesup nginx[1157]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Jan 16 16:25:12 webtp4linux.lab.ingesup systemd[1]: Started The nginx HTTP and reverse proxy server.
```

🌞 **Analysez le service NGINX**

- avec une commande `ps`, déterminer sous quel utilisateur tourne le processus du service NGINX
  - utilisez un `| grep` pour isoler les lignes intéressantes
    ```bash
    [manon@webtp4linux site_web_1]$ sudo ps -ef | grep nginx
    root        1159       1  0 16:25 ?         00:00:0nginx:     master process /usr/sbin/nginx
    nginx       1160    1159  0 16:25 ?         00:00:0nginx:     worker process
    manon       1180     857  0 16:31 pts/0     00:00:0grep       --color=auto nginx
    ```
- avec une commande `ss`, déterminer derrière quel port écoute actuellement le serveur web
  - utilisez un `| grep` pour isoler les lignes intéressantes
    ```bash
    [manon@webtp4linux site_web_1]$ sudo ss -alutnp4 | grep nginx
    tcp   LISTEN 0      511          0.0.0.0:80        0.0.0.   0:*    users:(("nginx",pid=1160,fd=6),("nginx",pid=1159,   fd=6))
    ```
- en regardant la conf, déterminer dans quel dossier se trouve la racine web
  - utilisez un `| grep` pour isoler les lignes intéressantes
    ```bash
    [manon@webtp4linux ~]$ cat /etc/nginx/nginx.conf | grep root
        root         /usr/share/nginx/html;
    ```
- inspectez les fichiers de la racine web, et vérifier qu'ils sont bien accessibles en lecture par l'utilisateur qui lance le processus
  - ça va se faire avec un `ls` et les options appropriées
    ```bash
    manon@webtp4linux html]$ ls -l
      total 12
      -rw-r--r--. 1 root root 3332 Oct 31 16:35 404.html
      -rw-r--r--. 1 root root 3404 Oct 31 16:35 50x.html
      drwxr-xr-x. 2 root root   27 Jan 16 16:25 icons
      lrwxrwxrwx. 1 root root   25 Oct 31 16:37 index.html -> ../../  testpage/index.html
      -rw-r--r--. 1 root root  368 Oct 31 16:35 nginx-logo.png
      lrwxrwxrwx. 1 root root   14 Oct 31 16:37 poweredby.png ->  nginx-logo.png
      lrwxrwxrwx. 1 root root   37 Oct 31 16:37 system_noindex_logo.  png -> ../../pixmaps/system-noindex-logo.png
    ```

## 4. Visite du service web

🌞 **Configurez le firewall pour autoriser le trafic vers le service NGINX**

```bash
[manon@webtp4linux html]$ sudo firewall-cmd --add-port=80/tcp --permanent
[sudo] password for manon:
success
[manon@webtp4linux html]$ sudo firewall-cmd --reload
success
```

🌞 **Accéder au site web**

```html
[manon@webtp4linux html]$ curl http://10.3.2.5:80
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
🌞 **Vérifier les logs d'accès**

```bash
[manon@webtp4linux log]$ sudo cat /var/log/nginx/access.log | tail -n 3
10.3.2.1 - - [16/Jan/2023:16:55:57 +0100] "GET /poweredby.png HTTP/1.1" 200 368 "http://10.3.2.5/" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36 OPR/93.0.0.0" "-"
10.3.2.1 - - [16/Jan/2023:16:55:58 +0100] "GET /favicon.ico HTTP/1.1" 404 3332 "http://10.3.2.5/" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36 OPR/93.0.0.0" "-"
10.3.2.5 - - [16/Jan/2023:16:56:53 +0100] "GET / HTTP/1.1" 200 7620 "-" "curl/7.76.1" "-"
```

## 5. Modif de la conf du serveur web

🌞 **Changer le port d'écoute**

- une simple ligne à modifier, vous me la montrerez dans le compte rendu
  - faites écouter NGINX sur le port 8080
  ```bash 
  [manon@webtp4linux ~]$ sudo cat /etc/nginx/nginx.conf | grep listen
        listen       8080;
        listen       [::]:8080;
  ```
- redémarrer le service pour que le changement prenne effet
  - `sudo systemctl restart nginx`
  ```bash
  [manon@webtp4linux ~]$ sudo systemctl restart nginx
  ```
  - vérifiez qu'il tourne toujours avec un ptit `systemctl status nginx`
  ```bash 
  [manon@webtp4linux ~]$ systemctl status nginx
    ● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
     Active: active (running) since Mon 2023-01-16 17:07:06 CET; 2min 28s ago
    Process: 1315 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
    Process: 1316 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
    Process: 1317 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
   Main PID: 1318 (nginx)
      Tasks: 2 (limit: 2684)
     Memory: 1.9M
        CPU: 16ms
     CGroup: /system.slice/nginx.service
             ├─1318 "nginx: master process /usr/sbin/nginx"
             └─1319 "nginx: worker process"

    Jan 16 17:07:06 webtp4linux.lab.ingesup systemd[1]: Starting    The nginx HTTP and reverse proxy server...
    Jan 16 17:07:06 webtp4linux.lab.ingesup nginx[1316]: nginx:     the configuration file /etc/nginx/nginx.conf syntax is ok
    Jan 16 17:07:06 webtp4linux.lab.ingesup nginx[1316]: nginx:     configuration file /etc/nginx/nginx.conf test is successful
    Jan 16 17:07:06 webtp4linux.lab.ingesup systemd[1]: Started     The nginx HTTP and reverse proxy server.
    ```
- prouvez-moi que le changement a pris effet avec une commande `ss`
  - utilisez un `| grep` pour isoler les lignes intéressantes
  ```bash
  [manon@webtp4linux ~]$ sudo ss -alutnp4 | grep nginx
  tcp   LISTEN 0      511          0.0.0.0:8080      0.0.0.    0:*    users:(("nginx",pid=1319,fd=6),("nginx",pid=1318,fd=6))
  ```
- n'oubliez pas de fermer l'ancien port dans le firewall, et d'ouvrir le nouveau
    ```bash
    [manon@webtp4linux ~]$ sudo firewall-cmd --remove-port=80/tcp   --permanent
    success
    [manon@webtp4linux ~]$ sudo firewall-cmd --add-port=8080/tcp    --permanent
    success
    [manon@webtp4linux site_web_1]$ sudo firewall-cmd --reload
    success
    ```
- prouvez avec une commande `curl` sur votre machine que vous pouvez désormais visiter le port 8080

    ```bash	
    [manon@webtp4linux ~]$ curl http://10.3.2.5:8080
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
        .col-md-7, .col-md-8, .col-md-9, .col-md-10, .col-md-11, .  col-md-12 {
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
        .col-sm-7, .col-sm-8, .col-sm-9, .col-sm-10, .col-sm-11, .  col-sm-12 {
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
    
              <p>If you would like the let the administrators of    this website know
              that you've seen this page instead of the page    you've expected, you
              should send them an email. In general, mail sent to   the name
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
              "hacked" this webserver: This test page is included   with the
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
            <a href="https://httpd.apache.org/">Apache Webserver</  strong></a>:
            You can add content to the directory <code>/var/www/    html/</code>.
            Until you do so, people visiting your website will  see this page. If
            you would like this page to not be shown, follow the    instructions in:
            <code>/etc/httpd/conf.d/welcome.conf</code>.</p>
    
            <p><strong>For systems using
            <a href="https://nginx.org">Nginx</strong></a>:
            You can add your content in a location of your
            choice and edit the <code>root</code> configuration     directive
            in <code>/etc/nginx/nginx.conf</code>.</p>
    
            <div id="logos">
              <a href="https://rockylinux.org/"     id="rocky-poweredby"><img src="icons/poweredby.png"     alt="[ Powered by Rocky Linux ]" /></a> <!-- Rocky  -->
              <img src="poweredby.png" /> <!-- webserver -->
            </div>
          </div>
          </div>
    
          <footer class="col-sm-12">
          <a href="https://apache.org">Apache&trade;</a> is a   registered trademark of <a href="https://apache.  org">the Apache Software Foundation</a> in the United     States and/or other countries.<br />
          <a href="https://nginx.org">NGINX&trade;</a> is a     registered trademark of <a href="https://">F5 Networks,     Inc.</a>.
          </footer>
    
      </body>
    </html>
    ```


🌞 **Changer l'utilisateur qui lance le service**

- pour ça, vous créerez vous-même un nouvel utilisateur sur le système : `web`
```bash
[manon@webtp4linux ~]$ sudo useradd web
```
  - l'utilisateur devra avoir un mot de passe, et un homedir défini explicitement à `/home/web`
  ```bash
  [manon@webtp4linux ~]$ sudo passwd web
  passwd: all authentication tokens updated successfully.
  ```
- modifiez la conf de NGINX pour qu'il soit lancé avec votre nouvel utilisateur
  - utilisez `grep` pour me montrer dans le fichier de conf la ligne que vous avez modifié
    ```bash
    [manon@webtp4linux ~]$ sudo cat /etc/nginx/nginx.conf | grep user
    [sudo] password for manon:
    Sorry, try again.
    [sudo] password for manon:
    user web;
    ```
- n'oubliez pas de redémarrer le service pour que le changement prenne effet
    ```bash
    [manon@webtp4linux ~]$ sudo systemctl restart nginx
    ```
- vous prouverez avec une commande `ps` que le service tourne bien sous ce nouveau utilisateur
  - utilisez un `| grep` pour isoler les lignes intéressantes
    ```bash
    [manon@webtp4linux ~]$ sudo ps -ef | grep nginx
    root        1415       1  0 17:39 ?        00:00:00 nginx:  master process /usr/sbin/nginx
    web         1416    1415  0 17:39 ?        00:00:00 nginx:  worker process
    manon       1421     857  0 17:41 pts/0    00:00:00 grep    --color=auto nginx
    ```

🌞 **Changer l'emplacement de la racine Web**

- configurez NGINX pour qu'il utilise une autre racine web que celle par défaut
  - avec un `nano` ou `vim`, créez un fichiez `/var/www/site_web_1/index.html` avec un contenu texte bidon
  ```bash
  [manon@webtp4linux site_web_1]$ echo contenu bidon | sudo tee /var/www/site_web_1/index.html
  contenu bidon
  ```
  - dans la conf de NGINX, configurez la racine Web sur `/var/www/site_web_1/`
  - vous me montrerez la conf effectuée dans le compte-rendu, avec un `grep`
    ```bash
    [manon@webtp4linux site_web_1]$ cat /etc/nginx/nginx.conf |   grep include
    include             /var/www/site_web_1/;
    ```
- n'oubliez pas de redémarrer le service pour que le changement prenne effet
    ```bash
    [manon@webtp4linux site_web_1]$ sudo systemctl restart  nginx
    ```
- prouvez avec un `curl` depuis votre hôte que vous accédez bien au nouveau site
    ```bash
    [manon@webtp4linux site_web_1]$ curl http://10.3.2.5:8080
    contenu bidon
    ```

## 6. Deux sites web sur un seul serveur

🌞 **Repérez dans le fichier de conf**

- la ligne qui inclut des fichiers additionels contenus dans un dossier nommé `conf.d`
- vous la mettrez en évidence avec un `grep`
    ```bash
    [manon@webtp4linux ~]$ sudo cat /etc/nginx/nginx.conf | grep conf.d
    include /etc/nginx/conf.d/*.conf;
    ```


🌞 **Créez le fichier de configuration pour le premier site**

- le bloc `server` du fichier de conf principal, vous le sortez
- et vous le mettez dans un fichier dédié
- ce fichier dédié doit se trouver dans le dossier `conf.d`
- ce fichier dédié doit porter un nom adéquat : `site_web_1.conf`

🌞 **Créez le fichier de configuration pour le deuxième site**

- un nouveau fichier dans le dossier `conf.d`
- il doit porter un nom adéquat : `site_web_2.conf`
- copiez-collez le bloc `server { }` de l'autre fichier de conf
- changez la racine web vers `/var/www/site_web_2/`
- et changez le port d'écoute pour 8888

> N'oubliez pas d'ouvrir le port 8888 dans le firewall. Vous pouvez constater si vous le souhaitez avec un `ss` que NGINX écoute bien sur ce nouveau port.

🌞 **Prouvez que les deux sites sont disponibles**

- depuis votre PC, deux commandes `curl`
- pour choisir quel site visitez, vous choisissez un port spécifique