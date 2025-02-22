set -e

mysql_root_password=$(config mysql_root_password)
mysql_wp_password=$(config mysql_wp_password)

sudo dnf upgrade -y

sudo dnf install httpd -y

sudo systemctl enable --now httpd

sudo dnf install mariadb-server -y

sudo systemctl enable --now mariadb

#sudo mysql_secure_installation --use-default

# because mysql_secure_installation  is hard to do
# in unattended way
# this is technical equivalent

if test -f /var/lib/mysql/mysql_secure_installation.done; then
  echo "mysql_secure_installation is already done, skip this step"
else
sudo mysql -sfu root <<EOS
-- set root password
UPDATE mysql.user SET Password=PASSWORD("${mysql_root_password}") WHERE User='root';
-- delete anonymous users
DELETE FROM mysql.user WHERE User='';
-- delete remote root capabilities
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
-- drop database 'test'
DROP DATABASE IF EXISTS test;
-- also make sure there are lingering permissions to it
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
-- make changes immediately
FLUSH PRIVILEGES;
EOS
  sudo touch /var/lib/mysql/mysql_secure_installation.done
fi

sudo dnf install php php-mysqlnd php-gd php-xml php-mbstring -y

sudo systemctl restart httpd

if test -d /var/www/html/wp-admin/; then

  echo "wp distro is copied, skip this step"

else

  curl -O https://wordpress.org/latest.tar.gz

  tar -xzvf latest.tar.gz

  sudo cp -r wordpress/* /var/www/html

  sudo chown -R apache:apache /var/www/html/

  sudo chmod -R 755 /var/www/html/

fi 

sudo mysql -u root --password="$mysql_root_password" <<EOS
CREATE DATABASE IF NOT EXISTS LOCALDEVELOPMENTENV;
CREATE USER IF NOT EXISTS 'admin'@'localhost' IDENTIFIED BY "$mysql_wp_password";
GRANT ALL PRIVILEGES ON LOCALDEVELOPMENTENV.* TO 'admin'@'localhost';
FLUSH PRIVILEGES;
EOS
