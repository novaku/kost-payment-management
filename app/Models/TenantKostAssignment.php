<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TenantKostAssignment extends Model
{
    use HasFactory;

    protected $fillable = [
        'tenant_id',
        'kost_location_id',
        'room_number',
        'monthly_quota',
        'start_date',
        'end_date',
        'is_active',
    ];

    protected $casts = [
        'monthly_quota' => 'decimal:2',
        'start_date' => 'date',
        'end_date' => 'date',
        'is_active' => 'boolean',
    ];

    /**
     * Get the tenant for this assignment
     */
    public function tenant()
    {
        return $this->belongsTo(User::class, 'tenant_id');
    }

    /**
     * Get the kost location for this assignment
     */
    public function kostLocation()
    {
        return $this->belongsTo(KostLocation::class);
    }

    /**
     * Get payments for this assignment
     */
    public function payments()
    {
        return $this->hasMany(Payment::class, 'assignment_id');
    }

    /**
     * Check if payment is late for current month
     */
    public function isPaymentLate($month = null, $year = null)
    {
        $month = $month ?? date('m');
        $year = $year ?? date('Y');

        $payment = $this->payments()
            ->where('payment_month', $month)
            ->where('payment_year', $year)
            ->where('status', '!=', 'rejected')
            ->first();

        if (!$payment) {
            // Check if we're past the 5th of the month
            $currentDate = now();
            $dueDate = now()->setYear($year)->setMonth($month)->setDay(5);
            
            return $currentDate->isAfter($dueDate);
        }

        return $payment->is_late;
    }

    /**
     * Get days late for payment
     */
    public function getDaysLate($month = null, $year = null)
    {
        $month = $month ?? date('m');
        $year = $year ?? date('Y');

        $payment = $this->payments()
            ->where('payment_month', $month)
            ->where('payment_year', $year)
            ->first();

        if ($payment) {
            return $payment->days_late;
        }

        $currentDate = now();
        $dueDate = now()->setYear($year)->setMonth($month)->setDay(5);
        
        if ($currentDate->isAfter($dueDate)) {
            return $currentDate->diffInDays($dueDate);
        }

        return 0;
    }
}
