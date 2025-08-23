#!/bin/bash

# ============================================
# Kost Payment - Deployment Tools & Utilities
# ============================================
# Tools untuk deployment dan maintenance
# Menggabungkan: deploy-cpanel.sh, install.sh
# ============================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Global variables
PROJECT_NAME="Kost Payment"
PROJECT_VERSION="1.0.0"
BACKUP_DIR="backups"

# ============================================
# UTILITY FUNCTIONS
# ============================================

show_banner() {
    echo "============================================"
    echo "   Kost Payment - Deployment Tools"
    echo "============================================"
    echo "Tools untuk deployment dan maintenance"
    echo "Version: ${PROJECT_VERSION}"
    echo "============================================"
    echo ""
}

show_menu() {
    echo "Pilih tool yang ingin digunakan:"
    echo ""
    echo "1. 🚀 Quick Deploy - Deploy cepat ke server"
    echo "2. 💾 Backup System - Backup aplikasi dan database"
    echo "3. 📥 Download Backup - Download backup dari server"
    echo "4. 🔄 Update Application - Update ke versi terbaru"
    echo "5. 🧹 Clean Cache - Bersihkan cache aplikasi"
    echo "6. 🔍 Health Check - Cek kesehatan aplikasi"
    echo "7. 📊 Performance Monitor - Monitor performa"
    echo "8. 🛠️  Fix Permissions - Perbaiki permission file"
    echo "9. 🗄️  Database Tools - Tools database"
    echo "10. 📝 Log Management - Kelola log aplikasi"
    echo "11. 🏗️  Installation Wizard - Wizard instalasi baru"
    echo "12. ❌ Exit"
    echo ""
    read -p "Masukkan pilihan (1-12): " choice
}

log_action() {
    local action="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $action" >> deployment.log
    echo "[$timestamp] $action"
}

# ============================================
# QUICK DEPLOY FUNCTIONS
# ============================================

quick_deploy() {
    echo "🚀 Quick Deploy to Server"
    echo ""
    
    # Check if we're in the right directory
    if [ ! -f "composer.json" ] || [ ! -f "artisan" ]; then
        echo "❌ Error: Tidak di dalam directory Laravel!"
        echo "Pastikan Anda berada di root directory project"
        return 1
    fi
    
    log_action "Starting quick deploy"
    
    # Get deployment target
    echo "Target deployment:"
    echo "1. cPanel Shared Hosting"
    echo "2. VPS/Dedicated Server"
    echo "3. Local Development"
    echo ""
    read -p "Pilih target (1-3): " target
    
    case $target in
        1)
            deploy_to_cpanel
            ;;
        2)
            deploy_to_vps
            ;;
        3)
            deploy_to_local
            ;;
        *)
            echo "❌ Pilihan tidak valid!"
            return 1
            ;;
    esac
    
    log_action "Quick deploy completed"
}

deploy_to_cpanel() {
    echo "🎯 Deploying to cPanel..."
    
    # Build production assets
    if command -v npm &> /dev/null; then
        echo "📦 Building production assets..."
        npm install --production
        npm run build
    else
        echo "⚠️  npm not found, skipping asset build"
    fi
    
    # Install PHP dependencies
    if command -v composer &> /dev/null; then
        echo "📦 Installing PHP dependencies..."
        composer install --optimize-autoloader --no-dev
    else
        echo "⚠️  composer not found, skipping dependency install"
    fi
    
    # Create deployment package
    create_cpanel_package
    
    echo "✅ cPanel deployment package ready!"
    echo "📤 Upload the generated .tar.gz file to your cPanel File Manager"
}

deploy_to_vps() {
    echo "🖥️  Deploying to VPS..."
    
    read -p "Server IP/hostname: " server_host
    read -p "Username: " server_user
    read -p "Deployment path: " deploy_path
    
    # Create deployment script
    cat > deploy-to-vps.sh << EOF
#!/bin/bash
set -e

echo "Deploying to VPS: ${server_host}"

# Upload files
rsync -avz --exclude-from=.deployignore ./ ${server_user}@${server_host}:${deploy_path}/

# Run remote commands
ssh ${server_user}@${server_host} << 'REMOTE_COMMANDS'
cd ${deploy_path}
composer install --optimize-autoloader --no-dev
npm install --production
npm run build
php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan view:cache
sudo systemctl reload nginx
REMOTE_COMMANDS

echo "✅ VPS deployment completed!"
EOF
    
    chmod +x deploy-to-vps.sh
    
    echo "🔧 Deploy script created: deploy-to-vps.sh"
    read -p "Run deployment now? (y/n): " run_now
    
    if [[ $run_now =~ ^[Yy] ]]; then
        ./deploy-to-vps.sh
    fi
}

deploy_to_local() {
    echo "💻 Setting up local development..."
    
    # Copy .env.example to .env if not exists
    if [ ! -f ".env" ] && [ -f ".env.example" ]; then
        cp .env.example .env
        echo "📝 .env file created from .env.example"
    fi
    
    # Install dependencies
    if command -v composer &> /dev/null; then
        composer install
    fi
    
    if command -v npm &> /dev/null; then
        npm install
    fi
    
    # Generate app key
    if command -v php &> /dev/null; then
        php artisan key:generate
        php artisan migrate
        php artisan db:seed
    fi
    
    echo "✅ Local development setup completed!"
    echo "🚀 Run: php artisan serve"
}

create_cpanel_package() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local package_name="kost-payment-deploy-${timestamp}.tar.gz"
    
    echo "📦 Creating cPanel deployment package..."
    
    # Create temporary directory
    local temp_dir="temp_deploy_${timestamp}"
    mkdir -p "$temp_dir"
    
    # Copy necessary files
    rsync -av --exclude-from=- . "$temp_dir"/ << 'EOF'
node_modules/
.git/
.env
.env.*
tests/
.phpunit.result.cache
vendor/
storage/logs/*
bootstrap/cache/*
temp_deploy_*/
*.log
*.tar.gz
deploy-*.sh
EOF
    
    # Create directory structure
    mkdir -p "$temp_dir/storage"/{app/{public},framework/{cache,sessions,views},logs}
    mkdir -p "$temp_dir/bootstrap/cache"
    
    # Create archive
    tar -czf "$package_name" -C "$temp_dir" .
    
    # Cleanup
    rm -rf "$temp_dir"
    
    echo "✅ Package created: $package_name"
}

# ============================================
# BACKUP FUNCTIONS
# ============================================

backup_system() {
    echo "💾 Backup System"
    echo ""
    
    local timestamp=$(date +%Y%m%d_%H%M%S)
    mkdir -p "$BACKUP_DIR"
    
    echo "Jenis backup:"
    echo "1. Full Backup (aplikasi + database)"
    echo "2. Application Only"
    echo "3. Database Only"
    echo "4. Configuration Only"
    echo ""
    read -p "Pilih jenis backup (1-4): " backup_type
    
    case $backup_type in
        1)
            backup_full "$timestamp"
            ;;
        2)
            backup_application "$timestamp"
            ;;
        3)
            backup_database "$timestamp"
            ;;
        4)
            backup_configuration "$timestamp"
            ;;
        *)
            echo "❌ Pilihan tidak valid!"
            return 1
            ;;
    esac
    
    log_action "Backup completed: $backup_type"
}

backup_full() {
    local timestamp="$1"
    local backup_name="full_backup_${timestamp}"
    
    echo "📦 Creating full backup..."
    
    # Backup application files
    tar -czf "$BACKUP_DIR/${backup_name}_app.tar.gz" \
        --exclude='vendor' \
        --exclude='node_modules' \
        --exclude='storage/logs/*' \
        --exclude='bootstrap/cache/*' \
        --exclude="$BACKUP_DIR" \
        .
    
    # Backup database
    backup_database_file "$timestamp"
    
    # Create info file
    cat > "$BACKUP_DIR/${backup_name}_info.txt" << EOF
Backup Information
==================
Date: $(date)
Type: Full Backup
Files: ${backup_name}_app.tar.gz
Database: backup_${timestamp}_database.sql
PHP Version: $(php --version 2>/dev/null | head -n 1 || echo "Not available")
Laravel Version: $(php artisan --version 2>/dev/null || echo "Not available")
EOF
    
    echo "✅ Full backup completed!"
    echo "📁 Files saved in: $BACKUP_DIR/"
}

backup_application() {
    local timestamp="$1"
    local backup_name="app_backup_${timestamp}.tar.gz"
    
    echo "📦 Creating application backup..."
    
    tar -czf "$BACKUP_DIR/$backup_name" \
        --exclude='vendor' \
        --exclude='node_modules' \
        --exclude='storage/logs/*' \
        --exclude='bootstrap/cache/*' \
        --exclude="$BACKUP_DIR" \
        .
    
    echo "✅ Application backup completed: $BACKUP_DIR/$backup_name"
}

backup_database() {
    local timestamp="$1"
    backup_database_file "$timestamp"
}

backup_database_file() {
    local timestamp="$1"
    local backup_name="backup_${timestamp}_database.sql"
    
    if [ ! -f ".env" ]; then
        echo "❌ .env file not found!"
        return 1
    fi
    
    # Load database config
    source .env
    
    if [ -z "$DB_DATABASE" ]; then
        echo "❌ Database configuration not found in .env"
        return 1
    fi
    
    echo "🗄️  Creating database backup..."
    
    if command -v mysqldump &> /dev/null; then
        mysqldump -h"${DB_HOST:-localhost}" \
                  -P"${DB_PORT:-3306}" \
                  -u"$DB_USERNAME" \
                  -p"$DB_PASSWORD" \
                  "$DB_DATABASE" > "$BACKUP_DIR/$backup_name"
        
        echo "✅ Database backup completed: $BACKUP_DIR/$backup_name"
    else
        echo "❌ mysqldump not found!"
        echo "Please backup database manually"
        return 1
    fi
}

backup_configuration() {
    local timestamp="$1"
    local backup_name="config_backup_${timestamp}.tar.gz"
    
    echo "⚙️  Creating configuration backup..."
    
    tar -czf "$BACKUP_DIR/$backup_name" \
        .env \
        config/ \
        database/migrations/ \
        database/seeders/ \
        routes/ \
        2>/dev/null
    
    echo "✅ Configuration backup completed: $BACKUP_DIR/$backup_name"
}

# ============================================
# UPDATE FUNCTIONS
# ============================================

update_application() {
    echo "🔄 Update Application"
    echo ""
    
    # Check git status
    if [ -d ".git" ]; then
        echo "📡 Checking for updates..."
        git fetch origin
        
        local_commit=$(git rev-parse HEAD)
        remote_commit=$(git rev-parse origin/main 2>/dev/null || git rev-parse origin/master 2>/dev/null)
        
        if [ "$local_commit" != "$remote_commit" ]; then
            echo "🆕 Updates available!"
            echo "Local:  $local_commit"
            echo "Remote: $remote_commit"
            echo ""
            read -p "Update now? (y/n): " update_now
            
            if [[ $update_now =~ ^[Yy] ]]; then
                update_from_git
            fi
        else
            echo "✅ Application is up to date!"
        fi
    else
        echo "📥 Manual update mode"
        manual_update
    fi
}

update_from_git() {
    echo "🔄 Updating from Git..."
    
    # Create backup before update
    echo "💾 Creating backup before update..."
    backup_application "pre_update_$(date +%Y%m%d_%H%M%S)"
    
    # Pull changes
    git pull origin main 2>/dev/null || git pull origin master
    
    # Update dependencies
    if command -v composer &> /dev/null; then
        echo "📦 Updating PHP dependencies..."
        composer install --optimize-autoloader --no-dev
    fi
    
    if command -v npm &> /dev/null; then
        echo "📦 Updating Node dependencies..."
        npm install --production
        npm run build
    fi
    
    # Run migrations
    read -p "Run database migrations? (y/n): " run_migrations
    if [[ $run_migrations =~ ^[Yy] ]]; then
        php artisan migrate --force
    fi
    
    # Clear cache
    if command -v php &> /dev/null; then
        php artisan config:cache
        php artisan route:cache
        php artisan view:cache
    fi
    
    echo "✅ Update completed!"
    log_action "Application updated from Git"
}

manual_update() {
    echo "📥 Manual Update Process"
    echo ""
    echo "1. Download latest version from repository"
    echo "2. Backup current application"
    echo "3. Replace files (except .env and storage/)"
    echo "4. Update dependencies"
    echo "5. Run migrations"
    echo ""
    read -p "Continue with manual update? (y/n): " continue_update
    
    if [[ $continue_update =~ ^[Yy] ]]; then
        # Create backup
        backup_application "manual_update_$(date +%Y%m%d_%H%M%S)"
        
        echo "📋 Manual update checklist:"
        echo "□ Download latest version"
        echo "□ Extract to temporary folder"
        echo "□ Copy new files (preserve .env, storage/, vendor/)"
        echo "□ Run: composer install --optimize-autoloader --no-dev"
        echo "□ Run: npm install && npm run build"
        echo "□ Run: php artisan migrate"
        echo "□ Run: php artisan config:cache"
        echo ""
        echo "💾 Backup created for safety"
    fi
}

# ============================================
# MAINTENANCE FUNCTIONS
# ============================================

clean_cache() {
    echo "🧹 Cleaning Application Cache"
    
    if command -v php &> /dev/null; then
        echo "🗑️  Clearing Laravel cache..."
        php artisan cache:clear
        php artisan config:clear
        php artisan route:clear
        php artisan view:clear
        
        echo "🔧 Rebuilding optimized cache..."
        php artisan config:cache
        php artisan route:cache
        php artisan view:cache
        
        echo "✅ Cache cleaned and optimized!"
    else
        echo "❌ PHP not found!"
        echo "Manual cache cleanup:"
        echo "rm -rf bootstrap/cache/*.php"
        echo "rm -rf storage/framework/cache/*"
        echo "rm -rf storage/framework/views/*"
    fi
    
    log_action "Cache cleaned"
}

health_check() {
    echo "🔍 Application Health Check"
    echo ""
    
    local issues=0
    
    # Check PHP version
    if command -v php &> /dev/null; then
        local php_version=$(php -v | head -n 1 | cut -d ' ' -f 2)
        echo "✅ PHP Version: $php_version"
    else
        echo "❌ PHP not found"
        ((issues++))
    fi
    
    # Check Laravel installation
    if [ -f "artisan" ]; then
        echo "✅ Laravel installation found"
        
        if command -v php &> /dev/null; then
            local laravel_version=$(php artisan --version 2>/dev/null || echo "Unknown")
            echo "ℹ️  Laravel Version: $laravel_version"
        fi
    else
        echo "❌ Laravel installation not found"
        ((issues++))
    fi
    
    # Check .env file
    if [ -f ".env" ]; then
        echo "✅ Environment file found"
        
        # Check APP_KEY
        if grep -q "APP_KEY=" .env && ! grep -q "APP_KEY=$" .env; then
            echo "✅ Application key configured"
        else
            echo "⚠️  Application key missing or empty"
            ((issues++))
        fi
    else
        echo "❌ Environment file missing"
        ((issues++))
    fi
    
    # Check vendor directory
    if [ -d "vendor" ]; then
        echo "✅ Composer dependencies installed"
    else
        echo "❌ Composer dependencies missing"
        ((issues++))
    fi
    
    # Check compiled assets
    if [ -f "public/build/manifest.json" ]; then
        echo "✅ Frontend assets compiled"
    else
        echo "⚠️  Frontend assets not compiled"
    fi
    
    # Check permissions
    check_permissions_health
    
    # Check database connection
    check_database_connection
    
    echo ""
    if [ $issues -eq 0 ]; then
        echo "🎉 Health check passed! Application is healthy."
    else
        echo "⚠️  Found $issues issue(s) that need attention."
    fi
    
    log_action "Health check completed: $issues issues found"
}

check_permissions_health() {
    local perm_issues=0
    
    # Check storage permissions
    if [ -w "storage" ]; then
        echo "✅ Storage directory writable"
    else
        echo "❌ Storage directory not writable"
        ((perm_issues++))
    fi
    
    # Check bootstrap/cache permissions
    if [ -w "bootstrap/cache" ]; then
        echo "✅ Bootstrap cache writable"
    else
        echo "❌ Bootstrap cache not writable"
        ((perm_issues++))
    fi
    
    if [ $perm_issues -gt 0 ]; then
        echo "🔧 Fix permissions with: chmod -R 775 storage bootstrap/cache"
    fi
    
    return $perm_issues
}

check_database_connection() {
    if [ -f ".env" ] && command -v php &> /dev/null; then
        local db_check=$(php artisan tinker --execute="try { DB::connection()->getPdo(); echo 'connected'; } catch(Exception \$e) { echo 'failed'; }" 2>/dev/null || echo "failed")
        
        if [[ $db_check == *"connected"* ]]; then
            echo "✅ Database connection successful"
        else
            echo "❌ Database connection failed"
            return 1
        fi
    else
        echo "⚠️  Cannot test database connection"
        return 1
    fi
}

performance_monitor() {
    echo "📊 Performance Monitor"
    echo ""
    
    # Check memory usage
    if command -v free &> /dev/null; then
        echo "💾 Memory Usage:"
        free -h
        echo ""
    fi
    
    # Check disk usage
    if command -v df &> /dev/null; then
        echo "💿 Disk Usage:"
        df -h .
        echo ""
    fi
    
    # Check PHP memory limit
    if command -v php &> /dev/null; then
        local memory_limit=$(php -r "echo ini_get('memory_limit');")
        echo "🐘 PHP Memory Limit: $memory_limit"
        
        local max_execution=$(php -r "echo ini_get('max_execution_time');")
        echo "⏱️  Max Execution Time: ${max_execution}s"
        echo ""
    fi
    
    # Check log file sizes
    echo "📝 Log File Sizes:"
    if [ -d "storage/logs" ]; then
        find storage/logs -name "*.log" -exec ls -lh {} \; 2>/dev/null || echo "No log files found"
    fi
    echo ""
    
    # Check cache sizes
    echo "🗂️  Cache Directory Sizes:"
    if [ -d "storage/framework/cache" ]; then
        du -sh storage/framework/cache 2>/dev/null || echo "Cache directory empty"
    fi
    if [ -d "bootstrap/cache" ]; then
        du -sh bootstrap/cache 2>/dev/null || echo "Bootstrap cache directory empty"
    fi
}

fix_permissions() {
    echo "🛠️  Fixing File Permissions"
    
    read -p "Fix permissions now? This will modify file permissions. (y/n): " fix_now
    
    if [[ $fix_now =~ ^[Yy] ]]; then
        echo "🔧 Setting directory permissions (755)..."
        find . -type d -exec chmod 755 {} \; 2>/dev/null || true
        
        echo "🔧 Setting file permissions (644)..."
        find . -type f -exec chmod 644 {} \; 2>/dev/null || true
        
        echo "🔧 Setting storage permissions (775)..."
        chmod -R 775 storage 2>/dev/null || true
        
        echo "🔧 Setting bootstrap/cache permissions (775)..."
        chmod -R 775 bootstrap/cache 2>/dev/null || true
        
        echo "🔧 Setting script permissions (755)..."
        chmod 755 *.sh 2>/dev/null || true
        
        echo "✅ Permissions fixed!"
        log_action "File permissions fixed"
    else
        echo "❌ Permission fix cancelled"
    fi
}

# ============================================
# DATABASE TOOLS
# ============================================

database_tools() {
    echo "🗄️  Database Tools"
    echo ""
    echo "1. 🔄 Run Migrations"
    echo "2. 🌱 Run Seeders"
    echo "3. ↩️  Rollback Migration"
    echo "4. 🔄 Fresh Migration (Reset & Migrate)"
    echo "5. 📊 Database Status"
    echo "6. 💾 Export Database"
    echo "7. 📥 Import Database"
    echo "8. ↩️  Back to main menu"
    echo ""
    read -p "Pilih option (1-8): " db_choice
    
    case $db_choice in
        1)
            run_migrations
            ;;
        2)
            run_seeders
            ;;
        3)
            rollback_migration
            ;;
        4)
            fresh_migration
            ;;
        5)
            database_status
            ;;
        6)
            export_database
            ;;
        7)
            import_database
            ;;
        8)
            return
            ;;
        *)
            echo "❌ Pilihan tidak valid!"
            database_tools
            ;;
    esac
}

run_migrations() {
    echo "🔄 Running Migrations..."
    
    if command -v php &> /dev/null; then
        php artisan migrate --force
        echo "✅ Migrations completed!"
    else
        echo "❌ PHP not found!"
    fi
    
    log_action "Database migrations executed"
}

run_seeders() {
    echo "🌱 Running Seeders..."
    
    if command -v php &> /dev/null; then
        php artisan db:seed --force
        echo "✅ Seeders completed!"
    else
        echo "❌ PHP not found!"
    fi
    
    log_action "Database seeders executed"
}

rollback_migration() {
    echo "↩️  Rollback Migration"
    echo ""
    echo "⚠️  WARNING: This will rollback the last batch of migrations!"
    read -p "Continue? (y/n): " confirm_rollback
    
    if [[ $confirm_rollback =~ ^[Yy] ]]; then
        if command -v php &> /dev/null; then
            php artisan migrate:rollback --force
            echo "✅ Migration rollback completed!"
        else
            echo "❌ PHP not found!"
        fi
    else
        echo "❌ Rollback cancelled"
    fi
    
    log_action "Database migration rollback"
}

fresh_migration() {
    echo "🔄 Fresh Migration (Reset & Migrate)"
    echo ""
    echo "⚠️  WARNING: This will DROP ALL TABLES and recreate them!"
    echo "All data will be lost!"
    read -p "Continue? Type 'YES' to confirm: " confirm_fresh
    
    if [ "$confirm_fresh" = "YES" ]; then
        if command -v php &> /dev/null; then
            php artisan migrate:fresh --force
            
            read -p "Run seeders? (y/n): " run_seed
            if [[ $run_seed =~ ^[Yy] ]]; then
                php artisan db:seed --force
            fi
            
            echo "✅ Fresh migration completed!"
        else
            echo "❌ PHP not found!"
        fi
    else
        echo "❌ Fresh migration cancelled"
    fi
    
    log_action "Database fresh migration"
}

database_status() {
    echo "📊 Database Status"
    
    if command -v php &> /dev/null; then
        echo ""
        echo "Migration Status:"
        php artisan migrate:status
        echo ""
        
        # Check connection
        check_database_connection
    else
        echo "❌ PHP not found!"
    fi
}

export_database() {
    echo "💾 Export Database"
    
    if [ ! -f ".env" ]; then
        echo "❌ .env file not found!"
        return 1
    fi
    
    source .env
    
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local export_file="database_export_${timestamp}.sql"
    
    if command -v mysqldump &> /dev/null; then
        echo "📤 Exporting database..."
        mysqldump -h"${DB_HOST:-localhost}" \
                  -P"${DB_PORT:-3306}" \
                  -u"$DB_USERNAME" \
                  -p"$DB_PASSWORD" \
                  "$DB_DATABASE" > "$export_file"
        
        echo "✅ Database exported to: $export_file"
        log_action "Database exported: $export_file"
    else
        echo "❌ mysqldump not found!"
    fi
}

import_database() {
    echo "📥 Import Database"
    echo ""
    
    read -p "SQL file path: " sql_file
    
    if [ ! -f "$sql_file" ]; then
        echo "❌ File not found: $sql_file"
        return 1
    fi
    
    if [ ! -f ".env" ]; then
        echo "❌ .env file not found!"
        return 1
    fi
    
    source .env
    
    echo "⚠️  WARNING: This will overwrite existing database data!"
    read -p "Continue? (y/n): " confirm_import
    
    if [[ $confirm_import =~ ^[Yy] ]]; then
        if command -v mysql &> /dev/null; then
            echo "📥 Importing database..."
            mysql -h"${DB_HOST:-localhost}" \
                  -P"${DB_PORT:-3306}" \
                  -u"$DB_USERNAME" \
                  -p"$DB_PASSWORD" \
                  "$DB_DATABASE" < "$sql_file"
            
            echo "✅ Database imported successfully!"
            log_action "Database imported from: $sql_file"
        else
            echo "❌ mysql command not found!"
        fi
    else
        echo "❌ Import cancelled"
    fi
}

# ============================================
# LOG MANAGEMENT
# ============================================

log_management() {
    echo "📝 Log Management"
    echo ""
    echo "1. 👀 View Recent Logs"
    echo "2. 🗑️  Clear Logs"
    echo "3. 📊 Log Statistics"
    echo "4. 📥 Download Logs"
    echo "5. ↩️  Back to main menu"
    echo ""
    read -p "Pilih option (1-5): " log_choice
    
    case $log_choice in
        1)
            view_logs
            ;;
        2)
            clear_logs
            ;;
        3)
            log_statistics
            ;;
        4)
            download_logs
            ;;
        5)
            return
            ;;
        *)
            echo "❌ Pilihan tidak valid!"
            log_management
            ;;
    esac
}

view_logs() {
    echo "👀 View Recent Logs"
    
    if [ -f "storage/logs/laravel.log" ]; then
        echo ""
        echo "Last 20 lines of laravel.log:"
        echo "================================"
        tail -n 20 storage/logs/laravel.log
        echo "================================"
        echo ""
        read -p "View more lines? Enter number (or press Enter to skip): " more_lines
        
        if [[ $more_lines =~ ^[0-9]+$ ]]; then
            tail -n "$more_lines" storage/logs/laravel.log
        fi
    else
        echo "❌ No log file found"
    fi
}

clear_logs() {
    echo "🗑️  Clear Logs"
    echo ""
    echo "⚠️  This will delete all log files!"
    read -p "Continue? (y/n): " confirm_clear
    
    if [[ $confirm_clear =~ ^[Yy] ]]; then
        if [ -d "storage/logs" ]; then
            rm -f storage/logs/*.log
            echo "✅ Logs cleared!"
            log_action "Application logs cleared"
        else
            echo "❌ Log directory not found"
        fi
    else
        echo "❌ Log clear cancelled"
    fi
}

log_statistics() {
    echo "📊 Log Statistics"
    
    if [ -d "storage/logs" ]; then
        echo ""
        echo "Log Files:"
        ls -lh storage/logs/*.log 2>/dev/null || echo "No log files found"
        echo ""
        
        if [ -f "storage/logs/laravel.log" ]; then
            local total_lines=$(wc -l < storage/logs/laravel.log)
            echo "Total lines in laravel.log: $total_lines"
            
            echo ""
            echo "Error count (last 1000 lines):"
            tail -n 1000 storage/logs/laravel.log | grep -c "ERROR" || echo "0"
            
            echo "Warning count (last 1000 lines):"
            tail -n 1000 storage/logs/laravel.log | grep -c "WARNING" || echo "0"
        fi
    else
        echo "❌ Log directory not found"
    fi
}

download_logs() {
    echo "📥 Download Logs"
    
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local archive_name="logs_${timestamp}.tar.gz"
    
    if [ -d "storage/logs" ]; then
        tar -czf "$archive_name" storage/logs/
        echo "✅ Logs archived: $archive_name"
        log_action "Logs downloaded: $archive_name"
    else
        echo "❌ Log directory not found"
    fi
}

# ============================================
# INSTALLATION WIZARD
# ============================================

installation_wizard() {
    echo "🏗️  Installation Wizard"
    echo ""
    echo "Setting up Kost Payment application..."
    echo ""
    
    # Check prerequisites
    echo "🔍 Checking prerequisites..."
    local missing_deps=()
    
    if ! command -v php &> /dev/null; then
        missing_deps+=("PHP")
    fi
    
    if ! command -v composer &> /dev/null; then
        missing_deps+=("Composer")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo "❌ Missing dependencies: ${missing_deps[*]}"
        echo "Please install missing dependencies first."
        return 1
    fi
    
    echo "✅ Prerequisites check passed!"
    echo ""
    
    # Install dependencies
    echo "📦 Installing dependencies..."
    composer install --optimize-autoloader
    
    # Setup environment
    if [ ! -f ".env" ]; then
        if [ -f ".env.example" ]; then
            cp .env.example .env
            echo "📝 .env file created from .env.example"
        else
            echo "❌ .env.example not found!"
            return 1
        fi
    fi
    
    # Generate app key
    echo "🔑 Generating application key..."
    php artisan key:generate
    
    # Setup database
    echo ""
    echo "🗄️  Database Setup"
    echo "Please configure your database in .env file"
    read -p "Open .env file for editing? (y/n): " edit_env
    
    if [[ $edit_env =~ ^[Yy] ]]; then
        if command -v nano &> /dev/null; then
            nano .env
        elif command -v vim &> /dev/null; then
            vim .env
        else
            echo "Please edit .env file manually"
        fi
    fi
    
    # Test database connection
    echo "🔌 Testing database connection..."
    if check_database_connection; then
        echo "✅ Database connection successful!"
        
        read -p "Run database migrations? (y/n): " run_migrations
        if [[ $run_migrations =~ ^[Yy] ]]; then
            php artisan migrate
            
            read -p "Run database seeders? (y/n): " run_seeders
            if [[ $run_seeders =~ ^[Yy] ]]; then
                php artisan db:seed
            fi
        fi
    else
        echo "❌ Database connection failed!"
        echo "Please check your database configuration in .env"
    fi
    
    # Frontend setup
    echo ""
    echo "🎨 Frontend Setup"
    if command -v npm &> /dev/null; then
        read -p "Install frontend dependencies? (y/n): " install_frontend
        if [[ $install_frontend =~ ^[Yy] ]]; then
            npm install
            npm run build
        fi
    else
        echo "⚠️  npm not found. Frontend setup skipped."
    fi
    
    # Set permissions
    echo "🔧 Setting file permissions..."
    fix_permissions
    
    # Final check
    echo ""
    echo "🔍 Running final health check..."
    health_check
    
    echo ""
    echo "🎉 Installation completed!"
    echo ""
    echo "Next steps:"
    echo "1. Configure your web server to point to public/ directory"
    echo "2. Set up SSL certificate"
    echo "3. Configure cron jobs if needed"
    echo "4. Test the application"
    
    log_action "Installation wizard completed"
}

# ============================================
# MAIN FUNCTION
# ============================================

main() {
    show_banner
    
    while true; do
        echo ""
        show_menu
        
        case $choice in
            1)
                quick_deploy
                read -p "Tekan Enter untuk kembali ke menu..."
                ;;
            2)
                backup_system
                read -p "Tekan Enter untuk kembali ke menu..."
                ;;
            3)
                echo "📥 Download Backup feature - Coming soon!"
                read -p "Tekan Enter untuk kembali ke menu..."
                ;;
            4)
                update_application
                read -p "Tekan Enter untuk kembali ke menu..."
                ;;
            5)
                clean_cache
                read -p "Tekan Enter untuk kembali ke menu..."
                ;;
            6)
                health_check
                read -p "Tekan Enter untuk kembali ke menu..."
                ;;
            7)
                performance_monitor
                read -p "Tekan Enter untuk kembali ke menu..."
                ;;
            8)
                fix_permissions
                read -p "Tekan Enter untuk kembali ke menu..."
                ;;
            9)
                database_tools
                ;;
            10)
                log_management
                ;;
            11)
                installation_wizard
                read -p "Tekan Enter untuk kembali ke menu..."
                ;;
            12)
                echo "👋 Terima kasih telah menggunakan Deployment Tools!"
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
