<?php

require __DIR__.'/vendor/autoload.php';

// Create a minimal Laravel application
$app = require_once __DIR__.'/bootstrap/app.php';

// Create the kernel but skip package discovery for now
$kernel = $app->make(\Illuminate\Contracts\Console\Kernel::class);

// Manually set up environment if possible
if (file_exists(__DIR__.'/.env')) {
    $dotenv = \Dotenv\Dotenv::createImmutable(__DIR__);
    $dotenv->load();
}

// Set configuration manually to avoid the 'env' service issue
config(['database.default' => 'mysql']);
config(['database.connections.mysql' => [
    'driver' => 'mysql',
    'host' => $_ENV['DB_HOST'] ?? '127.0.0.1',
    'port' => $_ENV['DB_PORT'] ?? '3306',
    'database' => $_ENV['DB_DATABASE'] ?? 'kost-payment',
    'username' => $_ENV['DB_USERNAME'] ?? 'root',
    'password' => $_ENV['DB_PASSWORD'] ?? 'root',
    'charset' => 'utf8mb4',
    'collation' => 'utf8mb4_unicode_ci',
    'prefix' => '',
    'strict' => true,
    'engine' => null,
]]);

try {
    echo "Testing database connection...\n";
    
    // Get database connection
    $db = \Illuminate\Support\Facades\DB::connection();
    
    // Test connection
    $db->getPdo();
    echo "Database connection successful!\n";
    
    // Check if migrations table exists
    if (!\Illuminate\Support\Facades\Schema::hasTable('migrations')) {
        echo "Creating migrations table...\n";
        \Illuminate\Support\Facades\Schema::create('migrations', function ($table) {
            $table->id();
            $table->string('migration');
            $table->integer('batch');
        });
        echo "Migrations table created!\n";
    }
    
    // List migration files
    $migrationFiles = glob(__DIR__ . '/database/migrations/*.php');
    sort($migrationFiles);
    
    echo "Found " . count($migrationFiles) . " migration files\n";
    
    // Get the current migration batch
    $currentBatch = $db->table('migrations')->max('batch') ?? 0;
    $nextBatch = $currentBatch + 1;
    
    foreach ($migrationFiles as $file) {
        $migrationName = basename($file, '.php');
        
        // Check if migration already ran
        $alreadyRan = $db->table('migrations')
            ->where('migration', $migrationName)
            ->exists();
            
        if ($alreadyRan) {
            echo "Skipping migration: $migrationName (already ran)\n";
            continue;
        }
        
        echo "Running migration: $migrationName\n";
        
        // Include the migration file and run it
        $migration = require $file;
        
        if ($migration instanceof \Illuminate\Database\Migrations\Migration) {
            $migration->up();
            
            // Record the migration
            $db->table('migrations')->insert([
                'migration' => $migrationName,
                'batch' => $nextBatch
            ]);
            
            echo "Migration completed: $migrationName\n";
        } else {
            echo "Invalid migration file: $migrationName\n";
        }
    }
    
    echo "All migrations completed!\n";
    
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
    echo "Trace: " . $e->getTraceAsString() . "\n";
}
