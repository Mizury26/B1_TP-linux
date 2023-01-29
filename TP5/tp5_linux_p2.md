# Partie 2 : Mise en place et maîtrise du serveur de base de données

🖥️ **VM db.tp5.linux**

| Machines        | IP            | Service                 |
|-----------------|---------------|-------------------------|
| `web.tp5.linux` | `10.105.1.11` | Serveur Web             |
| `db.tp5.linux`  | `10.105.1.12` | Serveur Base de Données |

🌞 **Install de MariaDB sur `db.tp5.linux`**

- déroulez [la doc d'install de Rocky](https://docs.rockylinux.org/guides/database/database_mariadb-server/)
- je veux dans le rendu **toutes** les commandes réalisées
    ```bash
    [manon@db-linux-tp5 ~]$ sudo dnf install mariadb-server -y
     ```
    - faites en sorte que le service de base de données démarre quand la machine s'allume

         ```bash
        [manon@db-linux-tp5 ~]$ sudo systemctl enable mariadb
        Created symlink /etc/systemd/system/mysql.service → /       usr/lib/systemd/system/mariadb.service.
        Created symlink /etc/systemd/system/mysqld.service → /      usr/  lib/systemd/system/mariadb.service.
        Created symlink /etc/systemd/system/multi-user.target.      wants/    mariadb.service → /usr/lib/systemd/system/    mariadb.service.
        ```
    ```bash
    [manon@db-linux-tp5 ~]$ sudo systemctl start mariadb
     ```
     ```bash
     [manon@db-linux-tp5 ~]$ systemctl status mariadb
     ● mariadb.service - MariaDB 10.5 database server
     Loaded: loaded (/usr/lib/systemd/system/mariadb.service; enabled; vend>     Active: active (running) since Tue 2023-01-17 12:19:42 CET; 21s ago
       Docs: man:mariadbd(8)
             https://mariadb.com/kb/en/library/systemd/
    Process: 12589 ExecStartPre=/usr/libexec/mariadb-check-socket (code=exi>    Process: 12611 ExecStartPre=/usr/libexec/mariadb-prepare-db-dir mariadb>    Process: 12705 ExecStartPost=/usr/libexec/mariadb-check-upgrade (code=e>   Main PID: 12692 (mariadbd)
     Status: "Taking your SQL requests now..."
      Tasks: 12 (limit: 2684)
     Memory: 66.9M
        CPU: 233ms
     CGroup: /system.slice/mariadb.service
             └─12692 /usr/libexec/mariadbd --basedir=/usr

    Jan 17 12:19:42 db-linux-tp5.lab.ingesup    mariadb-prepare-db-dir[12650]: you>Jan 17 12:19:42     db-linux-tp5.lab.ingesup mariadb-prepare-db-dir[12650]:     Aft>Jan 17 12:19:42 db-linux-tp5.lab.ingesup    mariadb-prepare-db-dir[12650]: abl>Jan 17 12:19:42     db-linux-tp5.lab.ingesup mariadb-prepare-db-dir[12650]:     See>Jan 17 12:19:42 db-linux-tp5.lab.ingesup    mariadb-prepare-db-dir[12650]: Ple>Jan 17 12:19:42     db-linux-tp5.lab.ingesup mariadb-prepare-db-dir[12650]:     The>Jan 17 12:19:42 db-linux-tp5.lab.ingesup    mariadb-prepare-db-dir[12650]: Con>Jan 17 12:19:42     db-linux-tp5.lab.ingesup mariadb-prepare-db-dir[12650]:     htt>Jan 17 12:19:42 db-linux-tp5.lab.ingesup mariadbd[12692]    : 2023-01-17 12:19:>Jan 17 12:19:42 db-linux-tp5.lab.   ingesup systemd[1]: Started MariaDB 10.5
    ```
    ```bash
    [manon@db-linux-tp5 ~]$ sudo mysql_secure_installation
    [sudo] password for manon:

    NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR   ALL MariaDB
          SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP     CAREFULLY!

    In order to log into MariaDB to secure it, we'll need the   current
    password for the root user. If you've just installed    MariaDB, and
    haven't set the root password yet, you should just press    enter here.

    Enter current password for root (enter for none):
    OK, successfully used password, moving on...

    Setting the root password or using the unix_socket ensures  that nobody
    can log into the MariaDB root user without the proper   authorisation.

    You already have your root account protected, so you can    safely answer 'n'.

    Switch to unix_socket authentication [Y/n] Y
    Enabled successfully!
    Reloading privilege tables..
     ... Success!


    You already have your root account protected, so you can    safely answer 'n'.

    Change the root password? [Y/n] Y
    New password:
    Re-enter new password:
    Password updated successfully!
    Reloading privilege tables..
     ... Success!


    By default, a MariaDB installation has an anonymous user,   allowing anyone
    to log into MariaDB without having to have a user account   created for
    them.  This is intended only for testing, and to make the   installation
    go a bit smoother.  You should remove them before moving    into a
    production environment.

    Remove anonymous users? [Y/n]
     ... Success!

    Normally, root should only be allowed to connect from   'localhost'.  This
    ensures that someone cannot guess at the root password from     the network.

    Disallow root login remotely? [Y/n] Y
     ... Success!

    By default, MariaDB comes with a database named 'test' that     anyone can
    access.  This is also intended only for testing, and should     be removed
    before moving into a production environment.

    Remove test database and access to it? [Y/n]
     - Dropping test database...
     ... Success!
     - Removing privileges on test database...
     ... Success!

    Reloading the privilege tables will ensure that all changes     made so far
    will take effect immediately.

    Reload privilege tables now? [Y/n]
     ... Success!

    Cleaning up...

    All done!  If you've completed all of the above steps, your     MariaDB
    installation should now be secure.

    Thanks for using MariaDB!
    ```


🌞 **Port utilisé par MariaDB**

- vous repérerez le port utilisé par MariaDB avec une commande `ss` exécutée sur `db.tp5.linux`
  - filtrez les infos importantes avec un `| grep`
    ```bash
    [manon@db-linux-tp5 ~]$ sudo ss -altpn | grep mariadb
    LISTEN 0      80                 *:3306            *:*      users:(("mariadbd",pid=12692,fd=19))
    ```

- il sera nécessaire de l'ouvrir dans le firewall
    ```bash	
    [manon@db-linux-tp5 ~]$ sudo firewall-cmd --add-port=3306/tcp --permanent
    success
    ```
    ```bash
    [manon@db-linux-tp5 ~]$ sudo firewall-cmd --reload
    success
    ```
    ```bash
    [manon@db-linux-tp5 ~]$ sudo firewall-cmd --list-all
    public (active)
      target: default
      icmp-block-inversion: no
      interfaces: enp0s3 enp0s8
      sources:
      services: cockpit dhcpv6-client ssh
      ports: 3306/tcp
      protocols:
      forward: yes
      masquerade: no
      forward-ports:
      source-ports:
      icmp-blocks:
      rich rules:
    ```

🌞 **Processus liés à MariaDB**

- repérez les processus lancés lorsque vous lancez le service MariaDB
- utilisz une commande `ps`
  - filtrez les infos importantes avec un `| grep`
  ```bash
  [manon@db-linux-tp5 ~]$ ps -ef | grep mariadb
  mysql      12692       1  0 12:19 ?        00:00:00 /usr/libexec/mariadbd --basedir=/usr
  ```

➜ **Une fois la db en place, go sur [la partie 3.](./tp5-linux-p3.md)**