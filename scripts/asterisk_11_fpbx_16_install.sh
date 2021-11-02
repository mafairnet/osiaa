#!/bin/bash
#Instalando dependencias
yum install epel-release -y
yum update -y
#instalando software adicional
yum install wget nano htop httpd mariadb-server -y
#Bajando en indtalando asterisk
mkdir -p /opt/asterisk
cd /opt/asterisk
wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-18-current.tar.gz
tar -xf asterisk-*
cd asterisk-18*
/opt/asterisk/contrib/scripts/install_prereq install
dnf -y install dnf-plugins-core
dnf config-manager --set-enabled powertools
yum install libedit-devel -y
/opt/asterisk/configure --with-jansson-bundled
#checar make menuselect con app_macro y sonidos de espera
make menuselect
make
make install
make config

#Crear grupo y usuarios de asterisk
groupadd asterisk
useradd -r -d /var/lib/asterisk -g asterisk asterisk
usermod -aG audio,dialout asterisk
chown -R asterisk.asterisk /etc/asterisk
chown -R asterisk.asterisk /var/{lib,log,spool}/asterisk
chown -R asterisk.asterisk /usr/lib/asterisk

#edit asterisk files to users
echo 'AST_USER="asterisk"' > /etc/default/asterisk
echo 'AST_GROUP="asterisk"' >> /etc/default/asterisk

#edit asterisk files to users
echo 'runuser = asterisk ; The user to run as.' >> /etc/asterisk/asterisk.conf
echo 'rungroup = asterisk ; The group to run as.' >> /etc/asterisk/asterisk.conf

systemctl enable asterisk
systemctl start asterisk

#modificar selinux to disabled
sed -i s/^SELINUX=.*$/SELINUX=disabled/ /etc/selinux/config

#Bajar FReePBX e Instalar
mkdir -p /opt/freepbx
cd /opt/freepbx/
wget http://mirror.freepbx.org/modules/packages/freepbx/7.4/freepbx-16.0-latest.tgz

#Instalar PHP 7.4 y dependencias
dnf module enable php:7.4 -y
dnf install php php-cli php-gd php-curl php-zip php-mbstring -y
dnf -y groupinstall  "Development Tools"
dnf install -y @php wget ncurses-devel sendmail sendmail-cf newt-devel libxml2-devel libtiff-devel gtk2-devel subversion kernel-devel git crontabs cronie cronie-anacron wget vim php-xml sqlite-devel net-tools gnutls-devel unixODBC

dnf module install nodejs -y
dnf install -y wget @php php-pear php-cgi php-common php-curl php-mbstring php-gd php-mysqlnd php-gettext php-bcmath php-zip php-xml  php-json php-process php-snmp -y

#Permisos en archivos web para asterisk
chown -R asterisk. /var/www/*

systemctl enable httpd
systemctl start httpd
systemctl enable mariadb
systemctl start mariadb

#Habilitar los puertos entrantes en el firewall de HTTP  SIP

firewall-cmd --add-service={http,https} --permanent
firewall-cmd --reload

PORTS=('5060/tcp' '5060/udp' '5061/tcp' '5061/udp' '4569/udp' '5038/tcp' '10000-20000/udp')
SERVICE_FILE="/etc/firewalld/services/asterisk.xml"

if [ ! -e "${SERVICE_FILE}" ]; then
    firewall-cmd --permanent --new-service=asterisk
fi

for PORT in ${PORTS[@]}; do
    firewall-cmd --permanent --service=asterisk --add-port=${PORT}
done

firewall-cmd --permanent --zone=public --add-service=asterisk
firewall-cmd --reload
firewall-cmd --list-all-zones

#Modificar permisos de archivos de conf de httpd y php-pm

sed -i 's/\(^memory_limit = \).*/\156M/' /etc/php.ini
sed -i 's/^\(User\|Group\).*/\1 asterisk/' /etc/httpd/conf/httpd.conf
sed -i 's/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf
sed -i 's/\(^user = \).*/\1asterisk/' /etc/php-fpm.d/www.conf
sed -i 's/\(^group = \).*/\1asterisk/' /etc/php-fpm.d/www.conf
sed -i 's/\(^listen.acl_users = apache,nginx\).*/\1,asterisk/' /etc/php-fpm.d/www.conf

systemctl restart httpd
systemctl restart php-fpm

#PAro temporalmente asterisk
systemctl stop asterisk

#Inicio asterisk con este script para validar qye permisos y conf esten bien
/opt/freepbx/freepbx/start_asterisk start

#Inicio asistente de instalacion de FREEPBX
/opt/freepbx/freepbx/install -n --dbuser root

systemctl restart httpd

#Reinicio para que se aliquen cambios de SELINUX
reboot


