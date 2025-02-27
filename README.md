# rocky-linux-lamp-check

Check LAMP installation on Rocky Linux by running official playbook on virtual machine

# Dependencies

- Any Linux/MacOS box with x86_64 arch

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
create custom user-data and insert ssh public key into it

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

For example, on Mac OS:

```
curl https://rakubrew.org/install-on-macos.sh | sh
rakubrew download moar-2025.02
Downloading https://rakudo.org/dl/rakudo/rakudo-moar-2025.02-01-macos-arm64-clang.tar.gz
Extracting
Switching to moar-2025.02
Done, moar-2025.02 installed
raku -v
Welcome to Rakudo™ v2025.02.
Implementing the Raku® Programming Language v6.d.
Built on MoarVM version 2025.02.
```

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
git clone https://github.com/melezhik/rocky-linux-lamp-check.git
cd rocky-linux-lamp-check/
sparrowdo --host=127.0.0.1 --ssh_port=10022 --ssh_user=admin  --no_sudo --color
```

If test succeeds one will see no errors in test report, otherwise some errors will be shown.

## Test scenario

Sparrowdo test scenario is located in sparrowfile, right now it's invocation
of as accurate as possible copy of official LAMP playbook, see tasks/files/lamp/task.bash

Please also read comment inside task.bash file, some tweaks have been made to make scenario work on real VM

## Sample test report 

```
18:27:08 :: [repository] - index updated from http://sparrowhub.io/repo/api/v1/index
[task run: task.bash - files/tasks/lamp]
[task stdout]
18:27:24 :: Last metadata expiration check: 1:08:37 ago on Sat 22 Feb 2025 05:18:47 PM UTC.
18:27:30 :: Dependencies resolved.
18:27:30 :: Nothing to do.
18:27:30 :: Complete!
18:27:33 :: Last metadata expiration check: 1:08:46 ago on Sat 22 Feb 2025 05:18:47 PM UTC.
18:27:39 :: Package httpd-2.4.37-65.module+el8.10.0+1938+3b7755d4.3.x86_64 is already installed.
18:27:39 :: Dependencies resolved.
18:27:39 :: Nothing to do.
18:27:39 :: Complete!
18:27:44 :: Last metadata expiration check: 1:08:57 ago on Sat 22 Feb 2025 05:18:47 PM UTC.
18:27:49 :: Package mariadb-server-3:10.3.39-1.module+el8.8.0+1452+2a7eab68.x86_64 is already installed.
18:27:49 :: Dependencies resolved.
18:27:49 :: Nothing to do.
18:27:49 :: Complete!
18:27:50 :: mysql_secure_installation is already done, skip this step
18:27:54 :: Last metadata expiration check: 1:09:07 ago on Sat 22 Feb 2025 05:18:47 PM UTC.
18:27:59 :: Package php-7.2.24-1.module+el8.4.0+413+c9202dda.x86_64 is already installed.
18:27:59 :: Package php-mysqlnd-7.2.24-1.module+el8.4.0+413+c9202dda.x86_64 is already installed.
18:27:59 :: Package php-gd-7.2.24-1.module+el8.4.0+413+c9202dda.x86_64 is already installed.
18:27:59 :: Package php-xml-7.2.24-1.module+el8.4.0+413+c9202dda.x86_64 is already installed.
18:27:59 :: Package php-mbstring-7.2.24-1.module+el8.4.0+413+c9202dda.x86_64 is already installed.
18:27:59 :: Dependencies resolved.
18:27:59 :: Nothing to do.
18:27:59 :: Complete!
18:28:00 :: wp distro is copied, skip this step
18:28:04 :: Last metadata expiration check: 1:09:17 ago on Sat 22 Feb 2025 05:18:47 PM UTC.
18:28:09 :: Package firewalld-0.9.11-9.el8_10.noarch is already installed.
18:28:09 :: Dependencies resolved.
18:28:09 :: Nothing to do.
18:28:09 :: Complete!
[task stderr]
18:28:22 :: ++ sudo sed -i -e s/database_name_here/LOCALDEVELOPMENTENV/g /var/www/html/wp-config.php
18:28:22 :: ++ sudo sed -i -e s/username_here/admin/g /var/www/html/wp-config.php
18:28:22 :: ++ sudo sed -i -e s/password_here/wp_password/g /var/www/html/wp-config.php
18:28:22 :: ++ set -x
18:28:22 :: ++ sudo dnf install firewalld -y
18:28:22 :: ++ sudo chcon -R -t httpd_sys_rw_content_t /var/www/html/
18:28:22 :: ++ sudo setsebool -P httpd_can_network_connect true
[task run: task.bash - bash: http check for WP localhost]
[task stdout]
18:28:40 :: HTTP/1.1 302 Found
18:28:40 :: Date: Sat, 22 Feb 2025 18:28:39 GMT
18:28:40 :: Server: Apache/2.4.37 (Rocky Linux)
18:28:40 :: X-Powered-By: PHP/7.2.24
18:28:40 :: Expires: Wed, 11 Jan 1984 05:00:00 GMT
18:28:40 :: Cache-Control: no-cache, must-revalidate, max-age=0
18:28:40 :: X-Redirect-By: WordPress
18:28:40 :: Location: http://127.0.0.1/wp-admin/install.php
18:28:40 :: Content-Length: 0
18:28:40 :: Content-Type: text/html; charset=UTF-8
18:28:40 :: 
18:28:41 :: task exit status: 1
18:28:41 :: task bash: http check for WP localhost FAILED
The spawned command 'ssh -l admin -q -o ConnectionAttempts=1 -o ConnectTimeout=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o ServerAliveInterval=300 -o ServerAliveCountMax=2 -tt -p 10022  admin@127.0.0.1 bash --login .sparrowdo/env/default/.sparrowdo/sparrowrun.sh' exited unsuccessfully (exit code: 1, signal: 0)
  in block <unit> at /Users/user/projects/rakudo/rakudo-moar-2024.12-01-macos-arm64-clang/share/perl6/site/resources/E566A9246E95BAE38B1E9E4CB59A597B5F43B839 line 13
  in sub MAIN at /Users/user/projects/rakudo/rakudo-moar-2024.12-01-macos-arm64-clang/share/perl6/site/bin/sparrowdo line 3
  in block <unit> at /Users/user/projects/rakudo/rakudo-moar-2024.12-01-macos-arm64-clang/share/perl6/site/bin/sparrowdo line 1
```

# See also

https://docs.rockylinux.org/guides/cms/wordpress-on-lamp/
