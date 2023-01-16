```bash
[manon@storagetp4linux storage]$sudo dnf install nfs-utils
```
```bash
[manon@storagetp4linux storage]$ sudo mkdir site_web_1 -p
[manon@storagetp4linux storage]$ sudo chown nobody site_web_1/
```
```bash
[manon@storagetp4linux storage]$ sudo mkdir site_web_2 -p
[manon@storagetp4linux storage]$ sudo chown nobody site_web_2/
```
```bash
[manon@storagetp4linux etc]$ cat exports
/storage/site_web_1/     10.3.2.5 (rw,sync,no_subtree_check)
/storage/site_web_2/     10.3.2.5 (rw,sync,no_subtree_check)
```
```bash
[manon@storagetp4linux etc]$ sudo systemctl enable nfs-server
[sudo] password for manon:
Created symlink /etc/systemd/system/multi-user.target.wants/nfs-server.service → /usr/lib/systemd/system/nfs-server.service.
[manon@storagetp4linux etc]$ sudo systemctl start nfs-server
```
```bash
[manon@storagetp4linux etc]$ sudo systemctl status nfs-server
● nfs-server.service - NFS server and services
     Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; enabled; vendor preset: disabled)
    Drop-In: /run/systemd/generator/nfs-server.service.d
             └─order-with-mounts.conf
     Active: active (exited) since Mon 2023-01-16 14:58:08 CET; 3min 29s ago
    Process: 11276 ExecStartPre=/usr/sbin/exportfs -r (code=exited, status=0/SUCCESS)
    Process: 11277 ExecStart=/usr/sbin/rpc.nfsd (code=exited, status=0/SUCCESS)
    Process: 11295 ExecStart=/bin/sh -c if systemctl -q is-active gssproxy; then systemctl reload gssproxy ; fi (code=exited, status=0/SUCCESS)
   Main PID: 11295 (code=exited, status=0/SUCCESS)
        CPU: 18ms

Jan 16 14:58:08 storagetp4linux.lab.ingesup systemd[1]: Starting NFS server and services...
Jan 16 14:58:08 storagetp4linux.lab.ingesup exportfs[11276]: exportfs: No options for /storage/site_web_1/ 10.3.2.5: suggest 10.3.2.5(sync) to avoid warning
Jan 16 14:58:08 storagetp4linux.lab.ingesup exportfs[11276]: exportfs: No host name given with /storage/site_web_1/ (rw,sync,no_root_squash,no_subtree_check), suggest *(>
Jan 16 14:58:08 storagetp4linux.lab.ingesup exportfs[11276]: exportfs: No options for /storage/site_web_2/ 10.3.2.5: suggest 10.3.2.5(sync) to avoid warning
Jan 16 14:58:08 storagetp4linux.lab.ingesup exportfs[11276]: exportfs: No host name given with /storage/site_web_2/ (rw,sync,no_root_squash,no_subtree_check), suggest *(>
Jan 16 14:58:08 storagetp4linux.lab.ingesup systemd[1]: Finished NFS server and services.
```
```bash
[manon@storagetp4linux etc]$ sudo firewall-cmd --permanent --add-service=nfs
success
[manon@storagetp4linux etc]$ sudo firewall-cmd --permanent --add-service=mountd
success
[manon@storagetp4linux etc]$ sudo firewall-cmd --permanent --add-service=rpc-bind
success
[manon@storagetp4linux etc]$
```
```bash
[manon@storagetp4linux etc]$ sudo firewall-cmd --permanent --list-all | grep services
  services: cockpit dhcpv6-client mountd nfs rpc-bind ssh
```