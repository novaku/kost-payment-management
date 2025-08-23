<?php

// Konfigurasi khusus untuk cPanel hosting
// File ini akan di-include oleh bootstrap/app.php untuk setup khusus cPanel

// Set timezone jika belum diset
if (!ini_get('date.timezone')) {
    date_default_timezone_set('Asia/Jakarta');
}

// Increase memory limit if possible
if (function_exists('ini_set')) {
    ini_set('memory_limit', '256M');
    ini_set('max_execution_time', 300);
}

// Set upload limits
if (function_exists('ini_set')) {
    ini_set('upload_max_filesize', '10M');
    ini_set('post_max_size', '10M');
}

// Error reporting untuk production
if (app()->environment('production')) {
    error_reporting(E_ALL & ~E_NOTICE & ~E_STRICT & ~E_DEPRECATED);
    ini_set('display_errors', 0);
    ini_set('log_errors', 1);
}

// Custom error handler untuk cPanel
if (!app()->runningInConsole()) {
    set_error_handler(function($severity, $message, $file, $line) {
        if (!(error_reporting() & $severity)) {
            return false;
        }
        
        $logMessage = sprintf(
            "[%s] %s in %s on line %d",
            date('Y-m-d H:i:s'),
            $message,
            $file,
            $line
        );
        
        error_log($logMessage, 3, storage_path('logs/cpanel-errors.log'));
        
        if (app()->environment('production')) {
            return true; // Don't display error
        }
        
        return false; // Display error in development
    });
}

// Helper untuk mengecek apakah assets sudah ter-compile
if (!function_exists('checkCompiledAssets')) {
    function checkCompiledAssets() {
        $manifestPath = public_path('build/manifest.json');
        
        if (!file_exists($manifestPath)) {
            if (app()->environment('production')) {
                // Dalam production, buat file placeholder
                $buildDir = public_path('build');
                if (!is_dir($buildDir)) {
                    mkdir($buildDir, 0755, true);
                }
                
                file_put_contents($manifestPath, json_encode([
                    'resources/js/app.tsx' => [
                        'file' => 'assets/app-placeholder.js',
                        'isEntry' => true
                    ],
                    'resources/css/app.css' => [
                        'file' => 'assets/app-placeholder.css'
                    ]
                ]));
                
                // Buat file CSS placeholder
                $cssDir = public_path('build/assets');
                if (!is_dir($cssDir)) {
                    mkdir($cssDir, 0755, true);
                }
                
                file_put_contents($cssDir . '/app-placeholder.css', '/* Placeholder CSS - Please compile frontend assets */');
                file_put_contents($cssDir . '/app-placeholder.js', '// Placeholder JS - Please compile frontend assets');
            }
        }
        
        return file_exists($manifestPath);
    }
}

// Auto-check compiled assets
checkCompiledAssets();

return [
    'cpanel_configured' => true,
    'assets_check' => file_exists(public_path('build/manifest.json')),
    'storage_writable' => is_writable(storage_path()),
    'cache_writable' => is_writable(base_path('bootstrap/cache')),
];
