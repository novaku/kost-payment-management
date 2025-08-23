<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
        'role',
        'phone',
        'address',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
    ];

    /**
     * Check if user is owner
     */
    public function isOwner(): bool
    {
        return $this->role === 'owner';
    }

    /**
     * Check if user is tenant
     */
    public function isTenant(): bool
    {
        return $this->role === 'tenant';
    }

    /**
     * Get kost locations owned by this user
     */
    public function ownedKostLocations()
    {
        return $this->hasMany(KostLocation::class, 'owner_id');
    }

    /**
     * Get tenant assignments for this user
     */
    public function tenantAssignments()
    {
        return $this->hasMany(TenantKostAssignment::class, 'tenant_id');
    }

    /**
     * Get payments made by this user
     */
    public function payments()
    {
        return $this->hasMany(Payment::class, 'tenant_id');
    }

    /**
     * Get payments verified by this user
     */
    public function verifiedPayments()
    {
        return $this->hasMany(Payment::class, 'verified_by');
    }
}
