# Partie 1 : Partitionnement du serveur de stockage

> Cette partie est à réaliser sur 🖥️ **VM storage.tp4.linux**.



🌞 **Partitionner le disque à l'aide de LVM**

- créer un *physical volume (PV)* : le nouveau disque ajouté à la VM
```
    [manon@storagetp4linux ~]$ sudo pvcreate /dev/sdb
    [sudo] password for manon:
    Physical volume "/dev/sdb" successfully created.
```
- créer un nouveau *volume group (VG)*
```
    [manon@storagetp4linux ~]$ sudo vgcreate storage /dev/sdb
     Volume group "storage" successfully created
```   
 
- créer un nouveau *logical volume (LV)* :
```
    [manon@storagetp4linux ~]$ sudo lvcreate -l 100%FREE storage -n lvstorage
    [sudo] password for manon:
    Logical volume "lvstorage" created.
```

🌞 **Formater la partition**

- vous formaterez la partition en ext4 :
```
[manon@storagetp4linux ~]$ sudo mkfs -t ext4 /dev/storage/lvstorage
mke2fs 1.46.5 (30-Dec-2021)
Creating filesystem with 523264 4k blocks and 130816 inodes
Filesystem UUID: 458bf7d1-1f2b-4a52-b6fd-dba30f34b2e4
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912

Allocating group tables: done
Writing inode tables: done
Creating journal (8192 blocks): done
Writing superblocks and filesystem accounting information: done
```

🌞 **Monter la partition**

- montage de la partition (avec la commande `mount`)
  - la partition doit être montée dans le dossier `/storage`
     ```
     [manon@storagetp4linux ~]$ sudo mkdir /storage
     [manon@storagetp4linux ~]$ sudo mount /dev/storage/  lvstorage /storage
     ```
  - preuve avec une commande `df -h` que la partition est bien montée
    - utilisez un `| grep` pour isoler les lignes intéressantes
    ```
    [manon@storagetp4linux ~]$ df -h | grep storage
    /dev/mapper/storage-lvstorage  2.0G   24K  1.9G   1% /storage
    ```
  - prouvez que vous pouvez lire et écrire des données sur cette partition
    ```
    [manon@storagetp4linux storage]$ sudo nano hello
    [sudo] password for manon:
    [manon@storagetp4linux storage]$ cat hello
    hello !!
    ```
- définir un montage automatique de la partition (fichier `/etc/fstab`)
  ```
  [manon@storagetp4linux storage]$ cat /etc/fstab

  #
  # /etc/fstab
  # Created by anaconda on Thu Oct 13 09:03:58 2022
  #
  # Accessible filesystems, by reference, are maintained under  '/dev/disk/'.
  # See man pages fstab(5), findfs(8), mount(8) and/or blkid(8)   for more info.
  #
  # After editing this file, run 'systemctl daemon-reload' to   update systemd
  # units generated from this file.
  #
  /dev/mapper/rl-root     /                       xfs       defaults        0 0
  UUID=3a82558c-8817-489e-9d0a-42517504a6a7 / boot                   xfs     defaults        0 0
  /dev/mapper/rl-swap     none                    swap      defaults        0 0

  ```
  - vous vérifierez que votre fichier `/etc/fstab` fonctionne correctement
  
  ```
  [manon@storagetp4linux ~]$ sudo umount /storage
  [manon@storagetp4linux ~]$ sudo mount -av
  /                        : ignored
  /boot                    : already mounted
  none                     : ignored
  mount: /storage does not contain SELinux labels.
         You just mounted a file system that supports labels  which does not
         contain labels, onto an SELinux box. It is likely that   confined
         applications will generate AVC messages and not be   allowed access to
         this file system.  For more details see restorecon(8)  and mount(8).
  /storage                 : successfully mounted
  ```


**Passons à [la partie 2 : installation du serveur de partage de fichiers](tp4_linux_p2.md).**