<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class Payment extends Model
{
    use HasFactory;

    protected $fillable = [
        'tenant_id',
        'kost_location_id',
        'assignment_id',
        'amount',
        'payment_date',
        'payment_month',
        'payment_year',
        'payment_proof',
        'status',
        'notes',
        'verified_at',
        'verified_by',
        'is_late',
        'days_late',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'payment_date' => 'date',
        'verified_at' => 'datetime',
        'is_late' => 'boolean',
    ];

    /**
     * Get the tenant who made this payment
     */
    public function tenant()
    {
        return $this->belongsTo(User::class, 'tenant_id');
    }

    /**
     * Get the kost location for this payment
     */
    public function kostLocation()
    {
        return $this->belongsTo(KostLocation::class);
    }

    /**
     * Get the assignment for this payment
     */
    public function assignment()
    {
        return $this->belongsTo(TenantKostAssignment::class, 'assignment_id');
    }

    /**
     * Get the user who verified this payment
     */
    public function verifiedBy()
    {
        return $this->belongsTo(User::class, 'verified_by');
    }

    /**
     * Check if payment is pending
     */
    public function isPending()
    {
        return $this->status === 'pending';
    }

    /**
     * Check if payment is verified
     */
    public function isVerified()
    {
        return $this->status === 'verified';
    }

    /**
     * Check if payment is rejected
     */
    public function isRejected()
    {
        return $this->status === 'rejected';
    }

    /**
     * Mark payment as verified
     */
    public function markAsVerified($verifiedBy)
    {
        $this->update([
            'status' => 'verified',
            'verified_at' => now(),
            'verified_by' => $verifiedBy,
        ]);
    }

    /**
     * Mark payment as rejected
     */
    public function markAsRejected($verifiedBy, $notes = null)
    {
        $this->update([
            'status' => 'rejected',
            'verified_at' => now(),
            'verified_by' => $verifiedBy,
            'notes' => $notes,
        ]);
    }

    /**
     * Calculate if payment is late and days late
     */
    public function calculateLateness()
    {
        $dueDate = Carbon::create($this->payment_year, $this->payment_month, 5);
        $paymentDate = $this->payment_date;

        if ($paymentDate->isAfter($dueDate)) {
            $this->update([
                'is_late' => true,
                'days_late' => $paymentDate->diffInDays($dueDate),
            ]);
        }
    }

    /**
     * Scope for verified payments
     */
    public function scopeVerified($query)
    {
        return $query->where('status', 'verified');
    }

    /**
     * Scope for pending payments
     */
    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }

    /**
     * Scope for rejected payments
     */
    public function scopeRejected($query)
    {
        return $query->where('status', 'rejected');
    }

    /**
     * Scope for late payments
     */
    public function scopeLate($query)
    {
        return $query->where('is_late', true);
    }
}
