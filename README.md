# rocky-linux-lamp-check

Check LAMP installation on Rocky Linux

# Prepare test image

```
touch meta-data
cat << DATA > user-data
#cloud-config
users:
  - default
  - name: admin
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    lock_passwd: false
    plain_text_passwd: password
    ssh_authorized_keys:
      ssh-rsa your_public_ssh_key
DATA
hdiutil makehybrid -o init.iso -hfs -joliet -iso -default-volume-name cidata {user-data,meta-data}
```

# Boot VM

```
wget https://dl.rockylinux.org/pub/rocky/8/images/x86_64/Rocky-8-GenericCloud-Base-8.10-20240528.0.x86_64.qcow2

qemu-system-x86_64 \
-net nic \
-net user,hostfwd=tcp::10022-:22 \
-m 6024M \
-smp 8 \
-vnc none \
-drive "file=Rocky-8-GenericCloud-Base-8.10-20240528.0.x86_64.qcow2,index=0,format=qcow2,media=disk" \
-drive file=init.iso,index=1,media=cdrom \
-nographic
```

# Run tests

## Install

* Rakudo 

See https://rakudo.org/downloads

* Sparrowdo

```
zef install Sparrowdo --/test
```

## Bootstrap ssh host

```
sparrowdo --host=127.0.0.1 --ssh_port=10022 --ssh_user=admin  --color --bootstrap
```

## Run test

```
sparrowdo --host=127.0.0.1 --ssh_port=10022 --ssh_user=admin  --color
```

# See also

https://docs.rockylinux.org/guides/cms/wordpress-on-lamp/
