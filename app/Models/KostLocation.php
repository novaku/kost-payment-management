<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class KostLocation extends Model
{
    use HasFactory;

    protected $fillable = [
        'owner_id',
        'name',
        'address',
        'city',
        'monthly_rate',
        'total_rooms',
        'description',
    ];

    protected $casts = [
        'monthly_rate' => 'decimal:2',
    ];

    /**
     * Get the owner of this kost location
     */
    public function owner()
    {
        return $this->belongsTo(User::class, 'owner_id');
    }

    /**
     * Get tenant assignments for this kost location
     */
    public function tenantAssignments()
    {
        return $this->hasMany(TenantKostAssignment::class);
    }

    /**
     * Get payments for this kost location
     */
    public function payments()
    {
        return $this->hasMany(Payment::class);
    }

    /**
     * Get active tenants for this kost location
     */
    public function activeTenants()
    {
        return $this->tenantAssignments()->where('is_active', true)->with('tenant');
    }

    /**
     * Get monthly revenue for this kost location
     */
    public function getMonthlyRevenue($month = null, $year = null)
    {
        $month = $month ?? date('m');
        $year = $year ?? date('Y');

        return $this->payments()
            ->where('status', 'verified')
            ->where('payment_month', $month)
            ->where('payment_year', $year)
            ->sum('amount');
    }
}
