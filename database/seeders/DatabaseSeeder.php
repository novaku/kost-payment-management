<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $this->call([
            RoleSeeder::class,
            SettingSeeder::class,
        ]);

        // Create admin user
        User::create([
            'name' => 'Admin',
            'email' => 'admin@kosan.com',
            'password' => bcrypt('password'),
            'role_id' => 1, // Admin role
            'phone' => '081234567890',
            'is_active' => true,
        ]);

        // Create pengelola user
        User::create([
            'name' => 'Pengelola',
            'email' => 'pengelola@kosan.com',
            'password' => bcrypt('password'),
            'role_id' => 2, // Pengelola role
            'phone' => '081234567891',
            'is_active' => true,
        ]);
    }
}
