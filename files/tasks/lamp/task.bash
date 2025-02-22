set -e

sudo dnf upgrade -y

sudo dnf install httpd -y

sudo systemctl enable --now httpd

sudo dnf install mariadb-server -y

sudo systemctl enable --now mariadb

sudo mysql_secure_installation --use-default
