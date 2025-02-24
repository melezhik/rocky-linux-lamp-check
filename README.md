# rocky-linux-lamp-check

Check LAMP installation on Rocky Linux by running official playbook on virtual machine

# Dependencies

- Any linux/MAC box with x86_64 arch

- Test Rockylinux image in qcow2 format, x86_64 arch, ssh server should be installed 

- qemu

- Rakudo

- Sparrowdo

# Installation

## Download image

```
wget https://dl.rockylinux.org/pub/rocky/8/images/x86_64/Rocky-8-GenericCloud-Base-8.10-20240528.0.x86_64.qcow2
```

## Prepare test image

To override cloud init file and enable ssh passwordless access, one need to
create custom user-data and insert ssh public to it

Generate ssh key, copy public part

```
ssh-keygen
```

Create user-data, insert ssh key public part

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
      ssh-rsa <your_public_ssh_key> # e.g. usually the content of ~/.ssh/id_rsa.pub file
DATA

# on MAC OS I use hdiutil to create iso image
# use proper tool that comes with your OS

hdiutil makehybrid -o init.iso -hfs -joliet -iso -default-volume-name cidata {user-data,meta-data}
```

## Install Rakudo

The most convenient way to install Rakudo is [rakubrew.org](http://rakubrew.org)

## Install Sparrowdo

Once rakudo is installed it comes with zef package manager - tool to install Raku modules.

Install Sparrowdo as Raku module

```
zef install --/test Sparrowdo
```

To check that sparrowdo is successfully installed, run this:

```
s6 --help
```

The command above should succeed. In case you get an error that s6 is not found in PATH,
consider adjusting PATH variable, by adding Raku modules bin/ path to it. 

## Install qemu

Choose proper tool available in your OS

## Boot VM

In separate console, run following command that launch VM with ssh port forwarding

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

Check that VM is available by ssh from localhost by running

```
ssh 127.0.0.1 -p 10022 -l admin
```

No password is required if user-data on previous step was set correctly. 

In case any issues try to log to VM  and troubleshoot, in using following creds:

- login

admin

- password

password

# Run tests

## Bootstrap ssh host

Bootstrap command will install Sparrow client on VM machine, this is required to
run all further tests. Bootstrap needs to be executed only once. Be patient, for
some slow VMs bootstrap might take a while

```
sparrowdo --host=127.0.0.1 --ssh_port=10022 --ssh_user=admin  --color --bootstrap
```

## Run test

To run test just execute test scenario on VM using sparrowdo cli, provide proper ssh user
and ssh port parameters.

```
sparrowdo --host=127.0.0.1 --ssh_port=10022 --ssh_user=admin  --no_sudo --color
```

If test succeeds one will see no errors in test report, otherwise some errors will be shown.

## Test scenario

Sparrowdo test scenario is located in sparrowfile, right now it's invocation
of as accurate as possible copy of official LAMP playbook, see tasks/files/lamp/task.bash

Please also read comment inside task.bash file, some tweaks have been made to make scenario work on real VM

## Sample test report 

```
08:19:22 :: [repository] - index updated from http://sparrowhub.io/repo/api/v1/index
[task run: task.bash - install package(s): nano.perl]
[task stdout]
08:19:39 :: trying to install nano ...
08:19:39 :: os - rocky
08:19:39 :: installer - yum
08:19:41 :: Installed Packages
08:19:41 :: nano.x86_64                        2.9.8-3.el8_10                        @baseos
```

# See also

https://docs.rockylinux.org/guides/cms/wordpress-on-lamp/
