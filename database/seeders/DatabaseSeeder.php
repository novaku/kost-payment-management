<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\KostLocation;
use App\Models\TenantKostAssignment;
use App\Models\Payment;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Create Owner
        $owner = User::create([
            'name' => 'Kost Owner',
            'email' => 'owner@kost.com',
            'password' => Hash::make('password123'),
            'role' => 'owner',
            'phone' => '081234567890',
            'address' => 'Jl. Owner Street No. 1, Jakarta',
        ]);

        // Create Tenant
        $tenant = User::create([
            'name' => 'Kost Tenant',
            'email' => 'tenant@kost.com',
            'password' => Hash::make('password123'),
            'role' => 'tenant',
            'phone' => '081234567891',
            'address' => 'Jl. Tenant Street No. 2, Jakarta',
        ]);

        // Create Kost Locations
        $kost1 = KostLocation::create([
            'owner_id' => $owner->id,
            'name' => 'Kost Merdeka',
            'address' => 'Jl. Merdeka No. 123, Jakarta Pusat',
            'city' => 'Jakarta',
            'monthly_rate' => 1500000,
            'total_rooms' => 20,
            'description' => 'Kost nyaman di pusat kota dengan fasilitas lengkap',
        ]);

        $kost2 = KostLocation::create([
            'owner_id' => $owner->id,
            'name' => 'Kost Sudirman',
            'address' => 'Jl. Sudirman No. 456, Jakarta Selatan',
            'city' => 'Jakarta',
            'monthly_rate' => 2000000,
            'total_rooms' => 15,
            'description' => 'Kost premium dengan lokasi strategis',
        ]);

        // Create Tenant Assignment
        $assignment = TenantKostAssignment::create([
            'tenant_id' => $tenant->id,
            'kost_location_id' => $kost1->id,
            'room_number' => 'A101',
            'monthly_quota' => $kost1->monthly_rate,
            'start_date' => now()->subMonths(3),
            'is_active' => true,
        ]);

        // Create Sample Payments
        Payment::create([
            'tenant_id' => $tenant->id,
            'kost_location_id' => $kost1->id,
            'assignment_id' => $assignment->id,
            'amount' => 1500000,
            'payment_date' => now()->subMonths(2)->day(3),
            'payment_month' => now()->subMonths(2)->format('m'),
            'payment_year' => now()->subMonths(2)->format('Y'),
            'status' => 'verified',
            'verified_at' => now()->subMonths(2)->addDays(1),
            'verified_by' => $owner->id,
            'is_late' => false,
            'days_late' => 0,
        ]);

        Payment::create([
            'tenant_id' => $tenant->id,
            'kost_location_id' => $kost1->id,
            'assignment_id' => $assignment->id,
            'amount' => 1500000,
            'payment_date' => now()->subMonths(1)->day(7),
            'payment_month' => now()->subMonths(1)->format('m'),
            'payment_year' => now()->subMonths(1)->format('Y'),
            'status' => 'verified',
            'verified_at' => now()->subMonths(1)->addDays(1),
            'verified_by' => $owner->id,
            'is_late' => true,
            'days_late' => 2,
        ]);

        Payment::create([
            'tenant_id' => $tenant->id,
            'kost_location_id' => $kost1->id,
            'assignment_id' => $assignment->id,
            'amount' => 1500000,
            'payment_date' => now()->day(4),
            'payment_month' => now()->format('m'),
            'payment_year' => now()->format('Y'),
            'status' => 'pending',
            'is_late' => false,
            'days_late' => 0,
        ]);
    }
}
