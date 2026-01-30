<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Room extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'room_number',
        'room_name',
        'monthly_price',
        'status',
        'description',
        'photos',
    ];

    protected $casts = [
        'photos' => 'array',
        'monthly_price' => 'decimal:2',
    ];

    // Relationships
    public function tenants()
    {
        return $this->hasMany(Tenant::class);
    }

    public function currentTenant()
    {
        return $this->hasOne(Tenant::class)->where('status', 'active')->latest();
    }

    public function payments()
    {
        return $this->hasMany(Payment::class);
    }

    // Scopes
    public function scopeAvailable($query)
    {
        return $query->where('status', 'available');
    }

    public function scopeOccupied($query)
    {
        return $query->where('status', 'occupied');
    }
}
