#!/bin/bash

# ============================================
# Kost Payment - cPanel Deployment Suite
# ============================================
# Script lengkap untuk deployment ke cPanel
# Menggabungkan: setup-cpanel.sh, install-cpanel.sh, 
# configure-cpanel.sh, build-frontend.sh
# ============================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Global variables
DOMAIN_NAME=""
CPANEL_USERNAME=""
MYSQL_HOST="localhost"
MYSQL_DATABASE=""
MYSQL_USERNAME=""
MYSQL_PASSWORD=""

# ============================================
# UTILITY FUNCTIONS
# ============================================

show_banner() {
    echo "============================================"
    echo "   Kost Payment - cPanel Deployment Suite"
    echo "============================================"
    echo "Script lengkap untuk deploy ke cPanel hosting"
    echo "============================================"
    echo ""
}

show_menu() {
    echo "Pilih operasi yang ingin dilakukan:"
    echo ""
    echo "1. 🎯 Complete Setup - Setup lengkap dari awal"
    echo "2. 🔧 Configure Only - Konfigurasi untuk cPanel"
    echo "3. 🎨 Build Frontend - Compile React assets"
    echo "4. 🚀 Install to cPanel - Proses instalasi"
    echo "5. 📦 Create Package - Buat package deployment"
    echo "6. ✅ Validate - Test deployment"
    echo "7. 🛠️  Maintenance Tools - Buat tools maintenance"
    echo "8. 📖 Help - Bantuan dan dokumentasi"
    echo "9. ❌ Exit"
    echo ""
    read -p "Masukkan pilihan (1-9): " choice
}

check_prerequisites() {
    echo "🔍 Memeriksa prerequisite..."
    
    # Check required files
    required_files=("composer.json" "package.json" "app" "resources")
    missing_files=()
    
    for file in "${required_files[@]}"; do
        if [ ! -e "$file" ]; then
            missing_files+=("$file")
        fi
    done
    
    if [ ${#missing_files[@]} -gt 0 ]; then
        echo "❌ File/folder berikut tidak ditemukan:"
        printf '%s\n' "${missing_files[@]}"
        echo ""
        echo "Pastikan Anda menjalankan script di root directory Laravel."
        exit 1
    fi
    
    echo "✅ Prerequisite check passed!"
    echo ""
}

# ============================================
# CONFIGURATION FUNCTIONS
# ============================================

get_config() {
    echo "📝 Konfigurasi cPanel:"
    
    if [ -z "$DOMAIN_NAME" ]; then
        read -p "Domain name (contoh: yourdomain.com): " DOMAIN_NAME
    fi
    
    if [ -z "$MYSQL_DATABASE" ]; then
        read -p "MySQL database name: " MYSQL_DATABASE
    fi
    
    if [ -z "$MYSQL_USERNAME" ]; then
        read -p "MySQL username: " MYSQL_USERNAME
    fi
    
    if [ -z "$MYSQL_PASSWORD" ]; then
        read -s -p "MySQL password: " MYSQL_PASSWORD
        echo
    fi
}

create_env_file() {
    echo "📝 Membuat file .env..."
    
    cat > .env << EOF
APP_NAME="Kost Payment"
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=https://${DOMAIN_NAME}

LOG_CHANNEL=stack
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=error

DB_CONNECTION=mysql
DB_HOST=${MYSQL_HOST}
DB_PORT=3306
DB_DATABASE=${MYSQL_DATABASE}
DB_USERNAME=${MYSQL_USERNAME}
DB_PASSWORD=${MYSQL_PASSWORD}

BROADCAST_DRIVER=log
CACHE_DRIVER=file
FILESYSTEM_DISK=local
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120

MEMCACHED_HOST=127.0.0.1

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_MAILER=smtp
MAIL_HOST=mailhog
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS="hello@example.com"
MAIL_FROM_NAME="\${APP_NAME}"

AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=
AWS_USE_PATH_STYLE_ENDPOINT=false

PUSHER_APP_ID=
PUSHER_APP_KEY=
PUSHER_APP_SECRET=
PUSHER_HOST=
PUSHER_PORT=443
PUSHER_SCHEME=https
PUSHER_APP_CLUSTER=mt1

VITE_PUSHER_APP_KEY="\${PUSHER_APP_KEY}"
VITE_PUSHER_HOST="\${PUSHER_HOST}"
VITE_PUSHER_PORT="\${PUSHER_PORT}"
VITE_PUSHER_SCHEME="\${PUSHER_SCHEME}"
VITE_PUSHER_APP_CLUSTER="\${PUSHER_APP_CLUSTER}"
EOF

    echo "✅ File .env berhasil dibuat!"
}

# ============================================
# cPanel CONFIGURATION FUNCTIONS
# ============================================

configure_for_cpanel() {
    echo "🔧 Mengkonfigurasi Laravel untuk cPanel..."
    
    # Update composer.json untuk production
    echo "📝 Updating composer.json for production..."
    
    # Backup original composer.json
    cp composer.json composer.json.backup
    
    # Create production composer.json
    cat > composer-cpanel.json << 'EOF'
{
    "name": "kost-payment/kost-payment-app",
    "type": "project",
    "description": "Kost Payment Management System",
    "keywords": ["laravel", "framework", "kost", "payment"],
    "license": "MIT",
    "require": {
        "php": "^8.1",
        "guzzlehttp/guzzle": "^7.2",
        "inertiajs/inertia-laravel": "^2.0",
        "laravel/framework": "^10.10",
        "laravel/sanctum": "^3.2",
        "laravel/tinker": "^2.8",
        "maatwebsite/excel": "^3.1",
        "barryvdh/laravel-dompdf": "^2.0",
        "intervention/image": "^2.7"
    },
    "autoload": {
        "psr-4": {
            "App\\": "app/",
            "Database\\Factories\\": "database/factories/",
            "Database\\Seeders\\": "database/seeders/"
        }
    },
    "scripts": {
        "post-autoload-dump": [
            "Illuminate\\Foundation\\ComposerScripts::postAutoloadDump",
            "@php artisan package:discover --ansi"
        ],
        "post-update-cmd": [
            "@php artisan vendor:publish --tag=laravel-assets --ansi --force"
        ],
        "post-root-package-install": [
            "@php -r \"file_exists('.env') || copy('.env.example', '.env');\""
        ],
        "post-create-project-cmd": [
            "@php artisan key:generate --ansi"
        ]
    },
    "extra": {
        "laravel": {
            "dont-discover": []
        }
    },
    "config": {
        "optimize-autoloader": true,
        "preferred-install": "dist",
        "sort-packages": true,
        "allow-plugins": {
            "pestphp/pest-plugin": true,
            "php-http/discovery": true
        }
    },
    "minimum-stability": "stable",
    "prefer-stable": true
}
EOF
    
    # Create optimized .htaccess
    create_htaccess
    
    # Create robots.txt
    create_robots_txt
    
    # Create maintenance page
    create_maintenance_page
    
    # Create performance check script
    create_performance_check
    
    echo "✅ Konfigurasi cPanel selesai!"
}

create_htaccess() {
    echo "📝 Creating optimized .htaccess..."
    
    cat > public/.htaccess << 'EOF'
<IfModule mod_rewrite.c>
    <IfModule mod_negotiation.c>
        Options -MultiViews -Indexes
    </IfModule>

    RewriteEngine On

    # Force HTTPS (uncomment if you have SSL)
    # RewriteCond %{HTTPS} off
    # RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]

    # Handle Authorization Header
    RewriteCond %{HTTP:Authorization} .
    RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]

    # Redirect Trailing Slashes If Not A Folder...
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_URI} (.+)/$
    RewriteRule ^ %1 [L,R=301]

    # Send Requests To Front Controller...
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteRule ^ index.php [L]
</IfModule>

# Security Headers
<IfModule mod_headers.c>
    Header always set X-Content-Type-Options nosniff
    Header always set X-Frame-Options DENY
    Header always set X-XSS-Protection "1; mode=block"
    Header always set Referrer-Policy "strict-origin-when-cross-origin"
</IfModule>

# Compression
<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE text/plain
    AddOutputFilterByType DEFLATE text/html
    AddOutputFilterByType DEFLATE text/xml
    AddOutputFilterByType DEFLATE text/css
    AddOutputFilterByType DEFLATE application/xml
    AddOutputFilterByType DEFLATE application/xhtml+xml
    AddOutputFilterByType DEFLATE application/rss+xml
    AddOutputFilterByType DEFLATE application/javascript
    AddOutputFilterByType DEFLATE application/x-javascript
</IfModule>

# Browser Caching
<IfModule mod_expires.c>
    ExpiresActive On
    ExpiresByType text/css "access plus 1 year"
    ExpiresByType application/javascript "access plus 1 year"
    ExpiresByType image/png "access plus 1 year"
    ExpiresByType image/jpg "access plus 1 year"
    ExpiresByType image/jpeg "access plus 1 year"
    ExpiresByType image/gif "access plus 1 year"
    ExpiresByType image/svg+xml "access plus 1 year"
    ExpiresByType application/pdf "access plus 1 year"
    ExpiresByType text/javascript "access plus 1 year"
</IfModule>

# Hide sensitive files
<FilesMatch "^(\.env|\.git|composer\.(json|lock)|package\.(json|lock)|\.htaccess)$">
    Order allow,deny
    Deny from all
</FilesMatch>

# Prevent access to vendor directory
<IfModule mod_rewrite.c>
    RewriteRule ^vendor(/.*)?$ - [F,L]
    RewriteRule ^storage(/.*)?$ - [F,L]
    RewriteRule ^bootstrap(/.*)?$ - [F,L]
</IfModule>

# Prevent script execution in uploads
<Directory "storage">
    php_flag engine off
</Directory>
EOF
}

create_robots_txt() {
    cat > public/robots.txt << 'EOF'
User-agent: *
Disallow: /storage/
Disallow: /vendor/
Disallow: /bootstrap/
Disallow: /.env
Allow: /

Sitemap: https://yourdomain.com/sitemap.xml
EOF
}

create_maintenance_page() {
    cat > public/maintenance.html << 'EOF'
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Maintenance - Kost Payment</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            color: white;
        }
        .container {
            text-align: center;
            padding: 2rem;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 10px;
            backdrop-filter: blur(10px);
            box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
        }
        h1 {
            font-size: 2.5rem;
            margin-bottom: 1rem;
        }
        p {
            font-size: 1.2rem;
            margin-bottom: 2rem;
        }
        .spinner {
            border: 4px solid rgba(255, 255, 255, 0.3);
            border-top: 4px solid white;
            border-radius: 50%;
            width: 50px;
            height: 50px;
            animation: spin 1s linear infinite;
            margin: 0 auto 2rem;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="spinner"></div>
        <h1>Maintenance Mode</h1>
        <p>Sistem sedang dalam maintenance.<br>Mohon tunggu beberapa saat.</p>
        <p><small>Kost Payment System</small></p>
    </div>
</body>
</html>
EOF
}

create_performance_check() {
    cat > check-performance.php << 'EOF'
<?php

// Performance check script untuk cPanel
echo "<h1>Kost Payment - Performance Check</h1>";

// Check PHP version
echo "<h2>PHP Information</h2>";
echo "<p>PHP Version: " . phpversion() . "</p>";
echo "<p>Memory Limit: " . ini_get('memory_limit') . "</p>";
echo "<p>Max Execution Time: " . ini_get('max_execution_time') . "</p>";
echo "<p>Upload Max Filesize: " . ini_get('upload_max_filesize') . "</p>";

// Check required extensions
echo "<h2>Required Extensions</h2>";
$required_extensions = ['pdo', 'pdo_mysql', 'mbstring', 'openssl', 'tokenizer', 'xml', 'ctype', 'json', 'bcmath'];

foreach ($required_extensions as $ext) {
    $status = extension_loaded($ext) ? '✅ Loaded' : '❌ Missing';
    echo "<p>{$ext}: {$status}</p>";
}

// Check file permissions
echo "<h2>File Permissions</h2>";
$paths_to_check = [
    'storage' => __DIR__ . '/storage',
    'bootstrap/cache' => __DIR__ . '/bootstrap/cache',
    'public' => __DIR__ . '/public',
];

foreach ($paths_to_check as $name => $path) {
    if (file_exists($path)) {
        $writable = is_writable($path) ? '✅ Writable' : '❌ Not Writable';
        echo "<p>{$name}: {$writable}</p>";
    } else {
        echo "<p>{$name}: ❌ Not Found</p>";
    }
}

// Check Laravel installation
echo "<h2>Laravel Status</h2>";
if (file_exists(__DIR__ . '/vendor/autoload.php')) {
    echo "<p>Composer Dependencies: ✅ Installed</p>";
    
    // Try to load Laravel
    try {
        require_once __DIR__ . '/vendor/autoload.php';
        echo "<p>Laravel Autoloader: ✅ Working</p>";
    } catch (Exception $e) {
        echo "<p>Laravel Autoloader: ❌ Error - " . $e->getMessage() . "</p>";
    }
} else {
    echo "<p>Composer Dependencies: ❌ Not Installed</p>";
}

// Check .env file
if (file_exists(__DIR__ . '/.env')) {
    echo "<p>Environment File: ✅ Found</p>";
} else {
    echo "<p>Environment File: ❌ Missing</p>";
}

// Check compiled assets
if (file_exists(__DIR__ . '/public/build/manifest.json')) {
    echo "<p>Frontend Assets: ✅ Compiled</p>";
} else {
    echo "<p>Frontend Assets: ❌ Not Compiled</p>";
}

echo "<hr>";
echo "<p><small>Generated at: " . date('Y-m-d H:i:s') . "</small></p>";
?>
EOF
}

# ============================================
# FRONTEND BUILD FUNCTIONS
# ============================================

build_frontend() {
    echo "🎨 Building frontend assets..."
    
    # Check if Node.js is available
    if ! command -v node &> /dev/null; then
        echo "❌ Node.js tidak terinstall!"
        echo ""
        echo "Untuk build frontend assets, Anda perlu:"
        echo "1. Install Node.js dari https://nodejs.org/"
        echo "2. Jalankan script ini lagi"
        echo ""
        echo "Atau gunakan environment lain yang sudah ada Node.js"
        return 1
    fi
    
    # Check if npm is available
    if ! command -v npm &> /dev/null; then
        echo "❌ npm tidak terinstall!"
        echo "Please install npm (usually comes with Node.js)"
        return 1
    fi
    
    echo "Node.js version: $(node --version)"
    echo "npm version: $(npm --version)"
    
    # Install dependencies
    echo "📦 Installing frontend dependencies..."
    npm install
    
    # Build for production
    echo "🏗️  Building frontend assets for production..."
    npm run build
    
    # Create deployment package
    echo "📦 Creating frontend deployment package..."
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    PACKAGE_NAME="frontend-assets-${TIMESTAMP}.zip"
    
    if command -v zip &> /dev/null; then
        cd public
        zip -r "../${PACKAGE_NAME}" build/
        cd ..
        
        echo "✅ Frontend package created: ${PACKAGE_NAME}"
        echo ""
        echo "Upload instructions for cPanel:"
        echo "1. Extract ${PACKAGE_NAME}"
        echo "2. Upload 'build' folder contents to public_html/build/ in cPanel"
    else
        echo "⚠️  zip command not found. Please manually upload public/build/ to cPanel"
    fi
    
    echo "✅ Frontend build completed!"
}

# ============================================
# cPanel STRUCTURE FUNCTIONS
# ============================================

setup_cpanel_structure() {
    echo "🏗️  Setting up cPanel folder structure..."
    
    # Backup public_html if exists
    if [ -d "public_html" ]; then
        echo "📦 Backing up existing public_html..."
        mv public_html public_html_backup_$(date +%Y%m%d_%H%M%S)
    fi
    
    # Copy public folder to public_html
    echo "📁 Copying public folder to public_html..."
    cp -r public public_html
    
    # Update public_html/index.php for correct path
    if [ -f "public_html/index.php" ]; then
        echo "🔧 Updating index.php paths..."
        # This is for cPanel where Laravel root is one level up from public_html
        sed -i.bak 's|__DIR__.\x27/../vendor/autoload.php\x27|__DIR__.\x27/../vendor/autoload.php\x27|g' public_html/index.php
        sed -i.bak 's|__DIR__.\x27/../bootstrap/app.php\x27|__DIR__.\x27/../bootstrap/app.php\x27|g' public_html/index.php
    fi
    
    echo "✅ cPanel structure ready!"
}

# ============================================
# INSTALLATION FUNCTIONS
# ============================================

set_permissions() {
    echo "🔐 Setting file permissions..."
    
    # Set permission untuk folder
    find . -type d -exec chmod 755 {} \; 2>/dev/null || true
    
    # Set permission untuk file
    find . -type f -exec chmod 644 {} \; 2>/dev/null || true
    
    # Set permission khusus untuk storage dan bootstrap/cache
    chmod -R 775 storage 2>/dev/null || true
    chmod -R 775 bootstrap/cache 2>/dev/null || true
    
    echo "✅ Permissions set successfully!"
}

install_dependencies() {
    echo "📦 Installing Composer dependencies..."
    
    # Check if composer is available
    if command -v composer &> /dev/null; then
        composer install --optimize-autoloader --no-dev
    else
        echo "⚠️  Composer not found!"
        echo "Please install dependencies manually:"
        echo "composer install --optimize-autoloader --no-dev"
    fi
}

generate_app_key() {
    echo "🔑 Generating application key..."
    
    if command -v php &> /dev/null; then
        php artisan key:generate --force
    else
        echo "⚠️  PHP not found in PATH!"
        echo "Please generate app key manually:"
        echo "php artisan key:generate --force"
    fi
}

migrate_database() {
    echo "🗄️  Running database migrations..."
    
    if command -v php &> /dev/null; then
        php artisan migrate --force
        php artisan db:seed --force
    else
        echo "⚠️  PHP not found in PATH!"
        echo "Please run migrations manually:"
        echo "php artisan migrate --force"
        echo "php artisan db:seed --force"
    fi
}

optimize_application() {
    echo "⚡ Optimizing application for production..."
    
    if command -v php &> /dev/null; then
        php artisan config:cache
        php artisan route:cache
        php artisan view:cache
    else
        echo "⚠️  PHP not found in PATH!"
        echo "Please optimize manually:"
        echo "php artisan config:cache"
        echo "php artisan route:cache"
        echo "php artisan view:cache"
    fi
}

# ============================================
# PACKAGE CREATION FUNCTIONS
# ============================================

create_deployment_package() {
    echo "📦 Creating deployment package..."
    
    DEPLOY_DIR="cpanel-deployment"
    rm -rf ${DEPLOY_DIR}
    mkdir -p ${DEPLOY_DIR}
    
    # Copy necessary files (exclude development files)
    echo "📁 Copying application files..."
    
    rsync -av --exclude-from=- . ${DEPLOY_DIR}/ << 'EOF'
node_modules/
.git/
.env
.env.*
.gitignore
.gitattributes
tests/
*.md
package.json
package-lock.json
webpack.mix.js
vite.config.js
tailwind.config.js
postcss.config.js
jsconfig.json
tsconfig.json
.eslintrc.js
.eslintignore
.prettierrc
storage/logs/*
bootstrap/cache/*
vendor/
cpanel-deployment/
cpanel-deploy.sh
deploy-tools.sh
EOF
    
    # Copy production composer.json if exists
    if [ -f "composer-cpanel.json" ]; then
        cp composer-cpanel.json ${DEPLOY_DIR}/composer.json
        echo "📝 Using production composer.json"
    fi
    
    # Create directory structure
    mkdir -p ${DEPLOY_DIR}/storage/{app/{public},framework/{cache,sessions,views},logs}
    mkdir -p ${DEPLOY_DIR}/bootstrap/cache
    
    # Set basic permissions
    chmod -R 755 ${DEPLOY_DIR}
    chmod -R 775 ${DEPLOY_DIR}/storage 2>/dev/null || true
    chmod -R 775 ${DEPLOY_DIR}/bootstrap/cache 2>/dev/null || true
    
    # Create compressed package
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    PACKAGE_NAME="kost-payment-cpanel-${TIMESTAMP}.tar.gz"
    
    tar -czf ${PACKAGE_NAME} -C cpanel-deployment .
    
    echo "✅ Package created: ${PACKAGE_NAME}"
    echo "📤 Upload this file to cPanel File Manager and extract it"
}

# ============================================
# MAINTENANCE TOOLS FUNCTIONS
# ============================================

create_maintenance_tools() {
    echo "🛠️  Creating maintenance tools..."
    
    # Maintenance mode toggle
    cat > toggle-maintenance.php << 'EOF'
<?php
// Simple maintenance mode toggle for cPanel

$maintenanceFile = __DIR__ . '/storage/framework/maintenance.php';
$action = $_GET['action'] ?? 'status';

switch ($action) {
    case 'enable':
        $content = '<?php return ["except" => [], "secret" => "' . bin2hex(random_bytes(16)) . '"];';
        file_put_contents($maintenanceFile, $content);
        echo "Maintenance mode ENABLED";
        break;
        
    case 'disable':
        if (file_exists($maintenanceFile)) {
            unlink($maintenanceFile);
        }
        echo "Maintenance mode DISABLED";
        break;
        
    case 'status':
    default:
        $status = file_exists($maintenanceFile) ? 'ENABLED' : 'DISABLED';
        echo "Maintenance mode: $status";
        break;
}

echo "<br><br>";
echo "<a href='?action=enable'>Enable Maintenance</a> | ";
echo "<a href='?action=disable'>Disable Maintenance</a> | ";
echo "<a href='?action=status'>Check Status</a>";
?>
EOF
    
    # Log viewer
    cat > view-logs.php << 'EOF'
<?php
// Simple log viewer for cPanel

$logFile = __DIR__ . '/storage/logs/laravel.log';
$lines = $_GET['lines'] ?? 50;

echo "<h1>Laravel Logs (Last $lines lines)</h1>";

if (file_exists($logFile)) {
    $logs = file($logFile);
    $totalLines = count($logs);
    $startLine = max(0, $totalLines - $lines);
    
    echo "<p>Showing lines " . ($startLine + 1) . " to $totalLines of $totalLines total</p>";
    echo "<pre style='background: #f4f4f4; padding: 10px; overflow: auto; max-height: 500px;'>";
    
    for ($i = $startLine; $i < $totalLines; $i++) {
        echo htmlspecialchars($logs[$i]);
    }
    
    echo "</pre>";
    
    echo "<p><a href='?lines=25'>25 lines</a> | ";
    echo "<a href='?lines=50'>50 lines</a> | ";
    echo "<a href='?lines=100'>100 lines</a> | ";
    echo "<a href='?lines=500'>500 lines</a></p>";
} else {
    echo "<p>Log file not found: $logFile</p>";
}
?>
EOF
    
    # Backup script
    cat > backup.sh << 'EOF'
#!/bin/bash

# Backup script for Kost Payment application
BACKUP_DIR="backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="kost_payment_backup_${TIMESTAMP}"

# Create backup directory
mkdir -p ${BACKUP_DIR}

# Create backup
echo "Creating backup: ${BACKUP_NAME}"

# Backup files (exclude vendor and node_modules)
tar -czf ${BACKUP_DIR}/${BACKUP_NAME}_files.tar.gz \
    --exclude='vendor' \
    --exclude='node_modules' \
    --exclude='storage/logs/*' \
    --exclude='bootstrap/cache/*' \
    --exclude='backups' \
    .

# Backup database (if mysqldump is available)
if command -v mysqldump &> /dev/null && [ -f .env ]; then
    source .env
    mysqldump -h${DB_HOST} -u${DB_USERNAME} -p${DB_PASSWORD} ${DB_DATABASE} > ${BACKUP_DIR}/${BACKUP_NAME}_database.sql
    echo "Database backup created: ${BACKUP_DIR}/${BACKUP_NAME}_database.sql"
fi

echo "Backup completed: ${BACKUP_DIR}/${BACKUP_NAME}_files.tar.gz"
EOF
    
    chmod +x backup.sh
    
    echo "✅ Maintenance tools created:"
    echo "- toggle-maintenance.php (enable/disable maintenance mode)"
    echo "- view-logs.php (view Laravel logs)"
    echo "- backup.sh (backup script)"
}

# ============================================
# VALIDATION FUNCTIONS
# ============================================

validate_deployment() {
    echo "✅ Validating deployment..."
    
    if [ -z "$1" ]; then
        read -p "Enter your domain (e.g., yourdomain.com): " DOMAIN
    else
        DOMAIN=$1
    fi
    
    echo "🔍 Checking ${DOMAIN}..."
    
    # Check if site is accessible
    if command -v curl &> /dev/null; then
        HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://${DOMAIN}" || echo "000")
        
        if [ "$HTTP_STATUS" = "200" ]; then
            echo "✅ Site is accessible (HTTP $HTTP_STATUS)"
        else
            echo "❌ Site is not accessible (HTTP $HTTP_STATUS)"
        fi
        
        # Check performance endpoint if exists
        PERF_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://${DOMAIN}/check-performance.php" || echo "000")
        
        if [ "$PERF_STATUS" = "200" ]; then
            echo "✅ Performance check available at https://${DOMAIN}/check-performance.php"
        else
            echo "ℹ️  Performance check not found"
        fi
    else
        echo "⚠️  curl not found, please check manually: https://${DOMAIN}"
    fi
    
    echo ""
    echo "Manual checks to perform:"
    echo "1. Login functionality"
    echo "2. Database connectivity"
    echo "3. File upload features"
    echo "4. Asset loading (CSS/JS)"
}

# ============================================
# HELP FUNCTIONS
# ============================================

show_help() {
    echo "📖 Bantuan cPanel Deployment Suite"
    echo ""
    echo "🎯 Complete Setup:"
    echo "   - Konfigurasi lengkap dari awal sampai siap deploy"
    echo "   - Termasuk build frontend dan create package"
    echo ""
    echo "🔧 Configure Only:"
    echo "   - Setup konfigurasi Laravel untuk cPanel"
    echo "   - Buat file .htaccess, robots.txt, dll"
    echo ""
    echo "🎨 Build Frontend:"
    echo "   - Compile React/TypeScript assets"
    echo "   - Buat package frontend untuk upload"
    echo ""
    echo "🚀 Install to cPanel:"
    echo "   - Proses instalasi setelah file di-upload"
    echo "   - Generate key, migrate DB, optimize"
    echo ""
    echo "📦 Create Package:"
    echo "   - Buat package deployment untuk upload ke cPanel"
    echo ""
    echo "✅ Validate:"
    echo "   - Test apakah deployment berhasil"
    echo ""
    echo "🛠️  Maintenance Tools:"
    echo "   - Buat tools untuk maintenance (logs, backup, dll)"
    echo ""
    echo "📚 Dokumentasi lengkap:"
    echo "   - README.md - Overview & quick start"
    echo "   - DEPLOYMENT.md - Panduan deployment lengkap"
    echo ""
    read -p "Tekan Enter untuk kembali ke menu..."
}

# ============================================
# MAIN WORKFLOW FUNCTIONS
# ============================================

complete_setup() {
    echo "🎯 Memulai complete setup..."
    
    # Get configuration
    get_config
    
    # Configure for cPanel
    configure_for_cpanel
    
    # Create .env file
    create_env_file
    
    # Build frontend if Node.js available
    if command -v node &> /dev/null; then
        build_frontend
    else
        echo "⚠️  Node.js not found. Frontend assets harus di-compile di environment lain."
    fi
    
    # Create deployment package
    create_deployment_package
    
    # Create maintenance tools
    create_maintenance_tools
    
    echo ""
    echo "✅ Complete setup finished!"
    echo ""
    echo "Next steps:"
    echo "1. Upload package kost-payment-cpanel-*.tar.gz ke cPanel"
    echo "2. Extract di root directory cPanel"
    echo "3. Setup database MySQL di cPanel"
    echo "4. Jalankan option 'Install to cPanel' untuk finalisasi"
    echo ""
}

install_to_cpanel() {
    echo "🚀 Installing to cPanel..."
    echo ""
    echo "⚠️  Pastikan sudah:"
    echo "   1. Upload file ke cPanel"
    echo "   2. Setup database MySQL"
    echo "   3. Compile frontend assets"
    echo ""
    read -p "Lanjutkan instalasi? (y/n): " continue_install
    
    if [[ $continue_install =~ ^[Yy] ]]; then
        # Setup cPanel structure
        setup_cpanel_structure
        
        # Set permissions
        set_permissions
        
        # Install dependencies
        install_dependencies
        
        # Generate app key
        generate_app_key
        
        # Ask for database migration
        read -p "Jalankan database migration? (y/n): " run_migration
        if [[ $run_migration =~ ^[Yy] ]]; then
            migrate_database
        fi
        
        # Optimize application
        optimize_application
        
        echo ""
        echo "✅ Installation completed!"
        echo ""
        echo "Test your application:"
        if [ -n "$DOMAIN_NAME" ]; then
            echo "- Website: https://${DOMAIN_NAME}"
            echo "- Performance Check: https://${DOMAIN_NAME}/check-performance.php"
        else
            echo "- Performance Check: /check-performance.php"
        fi
    else
        echo "❌ Installation dibatalkan."
    fi
}

# ============================================
# MAIN FUNCTION
# ============================================

main() {
    show_banner
    check_prerequisites
    
    while true; do
        echo ""
        show_menu
        
        case $choice in
            1)
                complete_setup
                ;;
            2)
                configure_for_cpanel
                echo "✅ Konfigurasi selesai!"
                read -p "Tekan Enter untuk kembali ke menu..."
                ;;
            3)
                build_frontend
                read -p "Tekan Enter untuk kembali ke menu..."
                ;;
            4)
                install_to_cpanel
                read -p "Tekan Enter untuk kembali ke menu..."
                ;;
            5)
                create_deployment_package
                read -p "Tekan Enter untuk kembali ke menu..."
                ;;
            6)
                echo "Domain untuk validasi:"
                read -p "Masukkan domain (contoh: yourdomain.com): " domain
                if [ -n "$domain" ]; then
                    validate_deployment "$domain"
                fi
                read -p "Tekan Enter untuk kembali ke menu..."
                ;;
            7)
                create_maintenance_tools
                read -p "Tekan Enter untuk kembali ke menu..."
                ;;
            8)
                show_help
                ;;
            9)
                echo "👋 Terima kasih telah menggunakan cPanel Deployment Suite!"
                echo "📚 Baca README.md dan DEPLOYMENT.md untuk panduan lengkap"
                exit 0
                ;;
            *)
                echo "❌ Pilihan tidak valid!"
                read -p "Tekan Enter untuk coba lagi..."
                ;;
        esac
    done
}

# Run main function
main "$@"
