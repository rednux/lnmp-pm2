#!/bin/bash
# Skrip pengganti mysql_secure_installation – oleh wooworks / chatGPT

echo "🔒 Mengamankan MariaDB..."

# Ganti ini sesuai keinginan
ROOT_PASS="gantiPasswordKuat123!"

echo "➡️ Setting password root..."
mysql -u root <<MYSQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASS}';
MYSQL

echo "❌ Menghapus user anonymous..."
mysql -u root -p${ROOT_PASS} <<MYSQL
DELETE FROM mysql.user WHERE User='';
MYSQL

echo "🔒 Menonaktifkan akses root dari remote host..."
mysql -u root -p${ROOT_PASS} <<MYSQL
DELETE FROM mysql.user WHERE User='root' AND Host!='localhost';
MYSQL

echo "🧹 Menghapus database test dan hak aksesnya..."
mysql -u root -p${ROOT_PASS} <<MYSQL
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
MYSQL

echo "💾 Flush privileges..."
mysql -u root -p${ROOT_PASS} -e "FLUSH PRIVILEGES;"

echo "✅ MariaDB berhasil diamankan!"
echo "➡️ Simpan password root kamu: ${ROOT_PASS}"
