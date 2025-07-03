#!/bin/bash
# Auto LNMP Setup – by wooworks

set -e

echo "🔄 Melakukan update sistem..."
dnf update -y

echo "🔧 Memperbaiki dnf.conf..."
sed -i '/^exclude=/d' /etc/dnf/dnf.conf

echo "🧹 Membersihkan cache DNF..."
dnf clean all
rm -rf /var/cache/dnf
dnf makecache

echo "📦 Menginstall tools dasar..."
dnf install -y epel-release wget curl nano unzip tar git net-tools firewalld policycoreutils-python-utils

echo "🔥 Mengaktifkan firewall..."
systemctl enable firewalld --now
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --reload

# ============ NGINX ============ #
echo "🌐 Menambahkan repo NGINX resmi..."
cat > /etc/yum.repos.d/nginx.repo <<EOF
[nginx-stable]
name=nginx stable repo
baseurl=https://nginx.org/packages/centos/8/\$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
EOF

echo "🌐 Menginstall NGINX 1.24..."
dnf install -y nginx
systemctl enable nginx --now

# ============ MARIADB ============ #
echo "🐬 Menambahkan repo MariaDB 10.6..."
curl -LsS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | bash -s -- --mariadb-server-version=10.6

echo "🐬 Menginstall MariaDB 10.6..."
dnf install -y MariaDB-server MariaDB-client
systemctl enable mariadb --now
echo "➡️ Jalankan 'mysql_secure_installation' setelah skrip selesai untuk amankan MariaDB."

# ============ PHP ============ #
echo "🐘 Menambahkan repo PHP 8.2 (Remi)..."
dnf install -y https://rpms.remirepo.net/enterprise/remi-release-9.rpm
dnf module reset php -y
dnf module enable php:remi-8.2 -y

echo "🐘 Menginstall PHP 8.2 + FPM..."
dnf install -y php php-cli php-fpm php-mysqlnd php-gd php-mbstring php-xml php-curl php-bcmath php-json php-opcache
systemctl enable php-fpm --now

echo "⚙️ Konfigurasi PHP-FPM untuk NGINX..."
sed -i 's/user = apache/user = nginx/' /etc/php-fpm.d/www.conf
sed -i 's/group = apache/group = nginx/' /etc/php-fpm.d/www.conf
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php.ini
systemctl restart php-fpm

# ============ DONE ============ #
echo ""
echo "✅ INSTALL SELESAI! SEMUA KOMPONEN TERPASANG:"
echo "✔️ NGINX    : $(nginx -v 2>&1)"
echo "✔️ PHP      : $(php -v | head -n1)"
echo "✔️ MariaDB  : $(mysql -V)"
echo ""
echo "➡️ Gunakan 'mysql_secure_installation' untuk mengamankan MariaDB"
echo ""
