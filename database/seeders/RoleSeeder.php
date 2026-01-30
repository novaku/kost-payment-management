<?php

namespace Database\Seeders;

use App\Models\Role;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class RoleSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $roles = [
            [
                'name' => 'admin',
                'display_name' => 'Administrator',
                'description' => 'Full access to the system',
            ],
            [
                'name' => 'pengelola',
                'display_name' => 'Pengelola',
                'description' => 'Manage tenants, verify payments, view reports',
            ],
            [
                'name' => 'penghuni',
                'display_name' => 'Penghuni',
                'description' => 'Submit payments, view payment history',
            ],
        ];

        foreach ($roles as $role) {
            Role::create($role);
        }
    }
}
