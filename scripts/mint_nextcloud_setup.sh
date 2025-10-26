#!/bin/bash

# ==============================================
# Linux Mint XFCE + KDE + Nextcloud Setup Script
# Author: Katherine Dendekker
# Updated: Uses command-line installation instead of web UI
# ==============================================

set -e

echo "=== Linux Mint XFCE + KDE + Nextcloud Setup ==="
echo "This will install KDE, Nextcloud, and mount an external drive for storage."
echo "-----------------------------------------------"
read -p "Enter your external drive device path (e.g., /dev/sdb1): " DRIVE
read -p "Enter a label name for the drive (e.g., nextcloud_data): " LABEL

# 1. System Update
echo ">>> Updating system..."
apt-add-repository universe
apt update && apt upgrade -y

# 2. Install KDE Plasma minimal with LightDM
echo ">>> Installing KDE Plasma Desktop..."
apt install -y kde-plasma-desktop lightdm

# Ensure LightDM is the active display manager
echo ">>> Configuring LightDM as default display manager..."
echo "/usr/sbin/lightdm" | tee /etc/X11/default-display-manager > /dev/null
DEBIAN_FRONTEND=noninteractive dpkg-reconfigure lightdm

systemctl enable lightdm
echo "KDE Installed. You can switch between XFCE and KDE at login"

# 3. Create mount point and format drive if needed
echo ">>> Preparing external drive..."
mkdir -p /mnt/$LABEL
UUID=$(blkid -s UUID -o value $DRIVE)

if [ -z "$UUID" ]; then
    echo "Drive not found! Make sure $DRIVE exists."
    exit 1
fi

# Backup fstab first
cp /etc/fstab /etc/fstab.bak

# Add to fstab for persistent mount
echo "UUID=$UUID /mnt/$LABEL ext4 defaults 0 2" >> /etc/fstab
mount -a

chown -R www-data:www-data /mnt/$LABEL
echo "Drive mounted at /mnt/$LABEL."

# 4. Install Apache, PHP, MariaDB
echo ">>> Installing Apache, PHP, and MariaDB..."
apt install -y apache2 mariadb-server libapache2-mod-php php-cli php-gd php-json php-mysql php-curl php-mbstring php-intl php-imagick php-xml php-zip php-pdo php-pdo-mysql unzip wget curl

# 5. Secure MariaDB
echo ">>> Securing MariaDB..."
mysql_secure_installation

# 6. Create Nextcloud DB and User
echo ">>> Creating Nextcloud database..."
read -p "Enter Nextcloud DB name [nextcloud]: " DB_NAME
DB_NAME=${DB_NAME:-nextcloud}
read -p "Enter Nextcloud DB username [ncuser]: " DB_USER
DB_USER=${DB_USER:-ncuser}
read -s -p "Enter Nextcloud DB password: " DB_PASS
echo ""

mysql -u root -p <<MYSQL_SCRIPT
CREATE DATABASE $DB_NAME;
CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

# 7. Download and extract Nextcloud
echo ">>> Downloading Nextcloud..."
cd /tmp
wget https://download.nextcloud.com/server/releases/latest.zip
unzip -q latest.zip
mv nextcloud /var/www/html/nextcloud

# 8. Set permissions
echo ">>> Setting permissions..."
chown -R www-data:www-data /var/www/html/nextcloud
chmod -R 755 /var/www/html/nextcloud

# 9. Configure Apache
echo ">>> Configuring Apache..."
APACHE_CONF="/etc/apache2/sites-available/nextcloud.conf"
tee $APACHE_CONF > /dev/null <<EOL
<VirtualHost *:80>
    DocumentRoot /var/www/html/nextcloud/
    ServerName localhost
    
    <Directory /var/www/html/nextcloud/>
        Require all granted
        AllowOverride All
        Options FollowSymlinks MultiViews
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/nextcloud_error.log
    CustomLog \${APACHE_LOG_DIR}/nextcloud_access.log combined
</VirtualHost>
EOL

a2enmod rewrite headers env dir mime php*
a2ensite nextcloud
systemctl restart apache2

# 10. Install Nextcloud via command line (avoids web UI issues)
echo ">>> Installing Nextcloud via command line..."
read -p "Enter admin username [admin]: " ADMIN_USER
ADMIN_USER=${ADMIN_USER:-admin}
read -s -p "Enter admin password: " ADMIN_PASS
echo ""

sudo -u www-data /var/www/html/nextcloud/occ maintenance:install \
    --database=mysql \
    --database-name=$DB_NAME \
    --database-user=$DB_USER \
    --database-pass="$DB_PASS" \
    --database-host=localhost \
    --admin-user=$ADMIN_USER \
    --admin-pass="$ADMIN_PASS" \
    --data-dir=/mnt/$LABEL

# 11. Configure Nextcloud to use external storage
echo ">>> Configuring Nextcloud data directory..."
chown -R www-data:www-data /mnt/$LABEL

# 12. Firewall
echo ">>> Configuring firewall..."
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw enable
ufw status verbose

# 13. Cleanup and Summary
echo "-----------------------------------------------------"
echo "Setup Complete!"
echo "Nextcloud running at: http://localhost/nextcloud"
echo "Admin user: $ADMIN_USER"
echo "Data stored in: /mnt/$LABEL"
echo "XFCE and KDE are available at the LightDM login screen."
echo "Firewall & auto updates configured."
echo "-----------------------------------------------------"
echo "You can reboot now to ensure all services start cleanly."