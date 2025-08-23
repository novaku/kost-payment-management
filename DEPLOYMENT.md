# 🚀 Kost Payment - Deployment Guide

Panduan lengkap untuk deploy aplikasi Kost Payment Management System ke berbagai environment.

## 📋 Overview Deployment Methods

| Method | Environment | Complexity | Best For |
|--------|-------------|------------|----------|
| **[cPanel](#-cpanel-shared-hosting)** | Shared Hosting | ⭐⭐ Easy | Production, Budget hosting |
| **[Local Development](#-local-development)** | Development | ⭐⭐⭐ Medium | Testing, Development |
| **[VPS/Cloud](#-vpscloud-server)** | VPS/Cloud | ⭐⭐⭐⭐ Advanced | Production, Full control |
| **[Docker](#-docker-deployment)** | Containerized | ⭐⭐⭐⭐⭐ Expert | Scalability, DevOps |

---

## 🌐 cPanel Shared Hosting

> **Untuk shared hosting tanpa Node.js dan akses terminal terbatas**

### Prerequisites
- **cPanel hosting** dengan PHP 8.1+
- **MySQL database** access
- **Local machine** dengan Node.js (untuk compile assets)

### 🎯 Automated Setup (Recommended)

```bash
# 1. Clone project
git clone [repository] kost-payment
cd kost-payment

# 2. Jalankan setup wizard
./setup-cpanel.sh
```

**Setup Wizard Steps:**
1. **🔧 Configure** - Setup konfigurasi cPanel
2. **🎨 Build Frontend** - Compile React assets
3. **📦 Prepare Deployment** - Package file untuk upload
4. **🚀 Install** - Deploy ke cPanel
5. **✅ Validate** - Test deployment

### 🔧 Manual cPanel Setup

#### Step 1: Local Preparation
```bash
# Install dependencies
npm install
composer install

# Build production assets
npm run build

# Configure for cPanel
./configure-cpanel.sh
```

#### Step 2: Database Setup
1. **Login ke cPanel**
2. **MySQL Databases** → Create new database
3. **Create database user** dengan strong password
4. **Assign user** ke database (ALL PRIVILEGES)
5. **Import** `database/database.sql` via phpMyAdmin

#### Step 3: File Upload
```bash
# Prepare deployment package
./deploy-cpanel.sh prepare
./deploy-cpanel.sh package

# Upload kost-payment-cpanel-[timestamp].tar.gz ke cPanel
# Extract di root directory (bukan public_html)
```

#### Step 4: cPanel Configuration
1. **Move public folder** → `public_html/`
2. **Update .env** dengan database credentials:
```env
APP_ENV=production
APP_DEBUG=false
APP_URL=https://yourdomain.com

DB_HOST=localhost
DB_DATABASE=your_db_name
DB_USERNAME=your_db_user
DB_PASSWORD=your_db_password
```

#### Step 5: Final Setup
```bash
# Via cPanel Terminal atau SSH (jika tersedia)
composer install --optimize-autoloader --no-dev
php artisan key:generate --force
php artisan migrate --force
php artisan config:cache
```

#### Step 6: Set Permissions
```bash
chmod -R 755 .
chmod -R 775 storage bootstrap/cache
```

### 🛠️ cPanel Maintenance Tools

Tools yang otomatis dibuat untuk maintenance:

| Tool | URL | Function |
|------|-----|----------|
| Performance Check | `/check-performance.php` | System status & requirements |
| Maintenance Toggle | `/toggle-maintenance.php` | Enable/disable maintenance mode |
| Log Viewer | `/view-logs.php` | View Laravel logs |

### Default Login (cPanel)
- **Owner**: owner@example.com / password
- **Tenant**: tenant@example.com / password

---

## 💻 Local Development

> **Untuk development dan testing di local machine**

### Prerequisites
- **PHP 8.1+** dengan extensions: pdo, pdo_mysql, mbstring, openssl, tokenizer, xml, ctype, json, bcmath
- **Node.js 16+** dan npm
- **MySQL 5.7+** atau MariaDB
- **Composer 2.x**

### Step 1: Project Setup
```bash
# Clone repository
git clone [repository-url] kost-payment
cd kost-payment

# Install PHP dependencies
composer install

# Install Node.js dependencies
npm install
```

### Step 2: Environment Configuration
```bash
# Copy environment file
cp .env.example .env

# Generate application key
php artisan key:generate
```

### Step 3: Database Setup
```bash
# Create database
mysql -u root -p
CREATE DATABASE kost_payment CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'kost_user'@'localhost' IDENTIFIED BY 'strong_password';
GRANT ALL PRIVILEGES ON kost_payment.* TO 'kost_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### Step 4: Environment Variables
Update `.env` file:
```env
APP_NAME="Kost Payment"
APP_ENV=local
APP_KEY=base64:generated_key
APP_DEBUG=true
APP_URL=http://localhost:8000

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=kost_payment
DB_USERNAME=kost_user
DB_PASSWORD=strong_password

# File storage
FILESYSTEM_DISK=local
```

### Step 5: Database Migration & Seeding
```bash
# Run migrations
php artisan migrate

# Seed with sample data
php artisan db:seed
```

### Step 6: Build & Serve
```bash
# Build frontend assets
npm run build

# Start development server
php artisan serve

# For development with hot reload
npm run dev
```

**Access:** http://localhost:8000

### Default Login (Local)
- **Owner**: owner@kost.com / password
- **Tenant**: tenant@kost.com / password

---

## 🖥️ VPS/Cloud Server

> **Untuk production environment dengan full control**

### Prerequisites
- **Ubuntu 20.04+** / CentOS 8+ / Debian 11+
- **Root access** atau sudo privileges
- **Domain name** pointed to server IP

### Step 1: Server Preparation
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install -y curl wget git unzip software-properties-common

# Add PHP repository
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update

# Install PHP 8.1
sudo apt install -y php8.1 php8.1-fpm php8.1-mysql php8.1-mbstring \
    php8.1-xml php8.1-curl php8.1-zip php8.1-gd php8.1-intl \
    php8.1-bcmath php8.1-tokenizer

# Install Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Install Nginx
sudo apt install -y nginx

# Install MySQL
sudo apt install -y mysql-server
sudo mysql_secure_installation
```

### Step 2: Database Setup
```bash
# Login to MySQL
sudo mysql -u root -p

# Create database and user
CREATE DATABASE kost_payment CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'kost_user'@'localhost' IDENTIFIED BY 'strong_password_here';
GRANT ALL PRIVILEGES ON kost_payment.* TO 'kost_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### Step 3: Application Deployment
```bash
# Clone to web directory
sudo git clone [repository-url] /var/www/kost-payment
cd /var/www/kost-payment

# Set ownership
sudo chown -R www-data:www-data /var/www/kost-payment
sudo chmod -R 755 /var/www/kost-payment
sudo chmod -R 775 /var/www/kost-payment/storage
sudo chmod -R 775 /var/www/kost-payment/bootstrap/cache

# Install dependencies
sudo -u www-data composer install --optimize-autoloader --no-dev
sudo -u www-data npm install
sudo -u www-data npm run build
```

### Step 4: Environment Configuration
```bash
# Copy and configure environment
sudo -u www-data cp .env.example .env
sudo -u www-data php artisan key:generate

# Edit .env file
sudo nano .env
```

```env
APP_NAME="Kost Payment"
APP_ENV=production
APP_DEBUG=false
APP_URL=https://yourdomain.com

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=kost_payment
DB_USERNAME=kost_user
DB_PASSWORD=strong_password_here
```

### Step 5: Database Migration
```bash
sudo -u www-data php artisan migrate --force
sudo -u www-data php artisan db:seed --force
```

### Step 6: Nginx Configuration
```bash
# Create Nginx config
sudo nano /etc/nginx/sites-available/kost-payment
```

```nginx
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;
    root /var/www/kost-payment/public;

    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }

    # Additional security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
}
```

```bash
# Enable site
sudo ln -s /etc/nginx/sites-available/kost-payment /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### Step 7: SSL Certificate (Let's Encrypt)
```bash
# Install Certbot
sudo apt install -y certbot python3-certbot-nginx

# Obtain certificate
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com

# Auto-renewal
sudo crontab -e
# Add: 0 12 * * * /usr/bin/certbot renew --quiet
```

### Step 8: Production Optimization
```bash
sudo -u www-data php artisan config:cache
sudo -u www-data php artisan route:cache
sudo -u www-data php artisan view:cache
```

---

## 🐳 Docker Deployment

> **Untuk containerized deployment dan scalability**

### Prerequisites
- **Docker** dan **Docker Compose** installed
- **Git** untuk clone repository

### Step 1: Project Setup
```bash
git clone [repository-url] kost-payment
cd kost-payment
```

### Step 2: Docker Configuration
Create `docker-compose.yml`:
```yaml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: kost-payment-app
    restart: unless-stopped
    working_dir: /var/www
    volumes:
      - ./:/var/www
    networks:
      - kost-payment

  webserver:
    image: nginx:alpine
    container_name: kost-payment-nginx
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./:/var/www
      - ./docker/nginx:/etc/nginx/conf.d
    networks:
      - kost-payment

  database:
    image: mysql:8.0
    container_name: kost-payment-db
    restart: unless-stopped
    environment:
      MYSQL_DATABASE: kost_payment
      MYSQL_ROOT_PASSWORD: root_password
      MYSQL_USER: kost_user
      MYSQL_PASSWORD: user_password
    volumes:
      - dbdata:/var/lib/mysql
    networks:
      - kost-payment

volumes:
  dbdata:

networks:
  kost-payment:
    driver: bridge
```

Create `Dockerfile`:
```dockerfile
FROM php:8.1-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    nodejs \
    npm

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy application files
COPY . /var/www

# Install dependencies
RUN composer install --optimize-autoloader --no-dev
RUN npm install && npm run build

# Set permissions
RUN chown -R www-data:www-data /var/www \
    && chmod -R 755 /var/www/storage \
    && chmod -R 755 /var/www/bootstrap/cache

EXPOSE 9000
CMD ["php-fpm"]
```

### Step 3: Deploy
```bash
# Build and start containers
docker-compose up -d --build

# Run migrations
docker-compose exec app php artisan migrate --force
docker-compose exec app php artisan db:seed --force

# Cache configuration
docker-compose exec app php artisan config:cache
```

---

## 🔧 Post-Deployment Configuration

### Performance Optimization
```bash
# Enable OPcache (PHP configuration)
echo "opcache.enable=1" >> /etc/php/8.1/fpm/conf.d/10-opcache.ini
echo "opcache.memory_consumption=128" >> /etc/php/8.1/fpm/conf.d/10-opcache.ini

# Laravel optimization
php artisan config:cache
php artisan route:cache
php artisan view:cache
composer dump-autoload --optimize
```

### Security Hardening
```bash
# File permissions
find . -type f -exec chmod 644 {} \;
find . -type d -exec chmod 755 {} \;
chmod -R 775 storage bootstrap/cache

# Hide sensitive files
echo "RewriteRule ^\.env$ - [F,L]" >> public/.htaccess
```

### Monitoring & Logging
```bash
# Setup log rotation
sudo nano /etc/logrotate.d/laravel

# Content:
# /var/www/kost-payment/storage/logs/*.log {
#     daily
#     rotate 14
#     compress
#     missingok
#     notifempty
#     create 644 www-data www-data
# }
```

### Backup Strategy
```bash
# Database backup script
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
mysqldump -u kost_user -p kost_payment > backup_${DATE}.sql
```

---

## 🚨 Troubleshooting

### Common Issues & Solutions

| Issue | Diagnosis | Solution |
|-------|-----------|----------|
| **500 Internal Server Error** | Check error logs | Verify file permissions, .env config |
| **Database Connection Failed** | Test DB credentials | Update .env, check MySQL service |
| **Missing Assets (CSS/JS)** | Check build folder | Run `npm run build`, upload to cPanel |
| **File Upload Fails** | Check PHP limits | Increase `upload_max_filesize` |
| **CSRF Token Mismatch** | Domain mismatch | Verify `APP_URL` in .env |
| **Performance Issues** | Check caching | Enable config/route/view cache |

### Debug Commands
```bash
# Check application status
php artisan about

# View configuration
php artisan config:show

# Check routes
php artisan route:list

# Clear all cache
php artisan optimize:clear

# View real-time logs
tail -f storage/logs/laravel.log
```

### Health Check Endpoints
- **Status**: `/check-performance.php` (cPanel)
- **Logs**: `/view-logs.php` (cPanel)
- **Maintenance**: `/toggle-maintenance.php` (cPanel)

---

## 📊 Performance Benchmarks

### Recommended Server Specs

| Environment | CPU | RAM | Storage | Concurrent Users |
|-------------|-----|-----|---------|------------------|
| **Development** | 2 cores | 4GB | 20GB SSD | 1-5 |
| **Small Production** | 2 cores | 8GB | 50GB SSD | 50-100 |
| **Medium Production** | 4 cores | 16GB | 100GB SSD | 200-500 |
| **Large Production** | 8+ cores | 32GB+ | 200GB+ SSD | 1000+ |

### Optimization Checklist
- ✅ **OPcache enabled** for PHP
- ✅ **Laravel caching** (config, route, view)
- ✅ **Database indexing** optimized
- ✅ **CDN** for static assets
- ✅ **Gzip compression** enabled
- ✅ **Browser caching** configured
- ✅ **SSL/TLS** enabled
- ✅ **Monitoring** setup

---

**💡 Quick Setup**: Untuk cPanel hosting, gunakan `./setup-cpanel.sh` untuk automated deployment!

**📞 Support**: Check README.md untuk troubleshooting guide atau buat issue di repository.
If your hosting supports terminal access:
```bash
composer install --optimize-autoloader --no-dev
npm install
npm run build
php artisan key:generate
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

If no terminal access, run the install script:
```bash
chmod +x install.sh
./install.sh
```

### Step 6: Storage Link
Create symbolic link for file uploads:
```bash
php artisan storage:link
```

## 🔐 Default Login Credentials

After successful installation:

**Owner Account:**
- Email: `owner@kost.com`
- Password: `password123`

**Tenant Account:**
- Email: `tenant@kost.com`  
- Password: `password123`

⚠️ **Important**: Change these credentials after first login!

## 📁 Directory Structure in cPanel

```
public_html/
├── app/
├── bootstrap/
├── config/
├── database/
├── public/          ← Laravel public files (accessible via web)
├── resources/
├── routes/
├── storage/         ← Must be writable
├── vendor/
├── .env            ← Configure this file
├── artisan
├── composer.json
└── install.sh
```

## 🛠️ Troubleshooting

### Common Issues:

1. **500 Internal Server Error**
   - Check `.env` file exists and is configured
   - Ensure `storage/` and `bootstrap/cache/` are writable
   - Check error logs in cPanel

2. **Database Connection Error**
   - Verify database credentials in `.env`
   - Ensure database exists and user has privileges

3. **Assets Not Loading**
   - Run `npm run build` to compile assets
   - Check if `public/build/` directory exists

4. **File Upload Issues**
   - Ensure `storage/app/public/` is writable
   - Check if symbolic link exists: `public/storage`

## 🎯 Features Included

✅ **For Tenants:**
- Payment submission with proof upload
- Payment history tracking
- Late payment notifications
- Join available kost locations

✅ **For Owners:**
- Payment verification system
- Multiple kost location management
- Monthly revenue reports
- Export to PDF/Excel
- Tenant management
- Late payment tracking

✅ **System Features:**
- Responsive design (mobile-friendly)
- Role-based access control
- File upload with validation
- Automatic late payment detection
- Monthly quota management

## 📊 Sample Data

The installation includes sample data:
- 1 Owner with 2 kost locations
- 1 Tenant with payment history
- 3 sample payments (verified, late, pending)

## 🔧 Configuration Options

### File Upload Settings
In `.env`, you can configure:
```env
# Maximum file size for payment proofs (in KB)
UPLOAD_MAX_FILESIZE=2048

# Allowed file types
UPLOAD_ALLOWED_TYPES=jpeg,png,jpg
```

### Application Settings
```env
# Application timezone
APP_TIMEZONE=Asia/Jakarta

# Default language
APP_LOCALE=id
```

## 📞 Support

For technical support or issues:
1. Check Laravel logs in `storage/logs/`
2. Verify all file permissions
3. Ensure all dependencies are installed
4. Check cPanel error logs

---

**Version**: 1.0.0  
**Laravel**: 10.x  
**PHP**: 8.1+  
**Database**: MySQL 5.7+
