<?php

namespace Database\Seeders;

use App\Models\Setting;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class SettingSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $settings = [
            [
                'key' => 'payment_due_date',
                'value' => '5',
                'type' => 'number',
                'group' => 'payment',
                'description' => 'Tanggal jatuh tempo pembayaran setiap bulan',
            ],
            [
                'key' => 'late_fee_type',
                'value' => 'per_day',
                'type' => 'string',
                'group' => 'payment',
                'description' => 'Tipe denda keterlambatan: per_day atau fixed',
            ],
            [
                'key' => 'late_fee_amount',
                'value' => '10000',
                'type' => 'number',
                'group' => 'payment',
                'description' => 'Jumlah denda keterlambatan dalam Rupiah',
            ],
            [
                'key' => 'reminder_days_before',
                'value' => '7',
                'type' => 'number',
                'group' => 'notification',
                'description' => 'Hari sebelum jatuh tempo untuk mengirim reminder',
            ],
            [
                'key' => 'app_name',
                'value' => 'Kosan Payment Management',
                'type' => 'string',
                'group' => 'general',
                'description' => 'Nama aplikasi',
            ],
        ];

        foreach ($settings as $setting) {
            Setting::create($setting);
        }
    }
}
