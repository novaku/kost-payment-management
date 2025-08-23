<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\OwnerController;
use App\Http\Controllers\TenantController;
use Illuminate\Foundation\Application;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "web" middleware group. Make something great!
|
*/

Route::get('/', function () {
    return Inertia::render('Welcome', [
        'canLogin' => Route::has('login'),
        'canRegister' => Route::has('register'),
        'laravelVersion' => Application::VERSION,
        'phpVersion' => PHP_VERSION,
    ]);
});

// Authentication Routes
Route::middleware('guest')->group(function () {
    Route::get('/login', [AuthController::class, 'showLogin'])->name('login');
    Route::post('/login', [AuthController::class, 'login']);
    Route::get('/register', [AuthController::class, 'showRegister'])->name('register');
    Route::post('/register', [AuthController::class, 'register']);
});

Route::post('/logout', [AuthController::class, 'logout'])->middleware('auth')->name('logout');

// Owner Routes
Route::middleware(['auth', 'role:owner'])->prefix('owner')->name('owner.')->group(function () {
    Route::get('/dashboard', [OwnerController::class, 'dashboard'])->name('dashboard');
    Route::get('/payments', [OwnerController::class, 'payments'])->name('payments');
    Route::post('/payments/{payment}/verify', [OwnerController::class, 'verifyPayment'])->name('payments.verify');
    Route::get('/reports', [OwnerController::class, 'reports'])->name('reports');
    Route::get('/reports/export-pdf', [OwnerController::class, 'exportPdf'])->name('reports.export-pdf');
    Route::get('/reports/export-excel', [OwnerController::class, 'exportExcel'])->name('reports.export-excel');
    Route::get('/kost-locations', [OwnerController::class, 'kostLocations'])->name('kost-locations');
    Route::post('/kost-locations', [OwnerController::class, 'storeKostLocation'])->name('kost-locations.store');
});

// Tenant Routes
Route::middleware(['auth', 'role:tenant'])->prefix('tenant')->name('tenant.')->group(function () {
    Route::get('/dashboard', [TenantController::class, 'dashboard'])->name('dashboard');
    Route::get('/payment/{assignment}', [TenantController::class, 'showPaymentForm'])->name('payment.form');
    Route::post('/payment/{assignment}', [TenantController::class, 'storePayment'])->name('payment.store');
    Route::get('/payment-history', [TenantController::class, 'paymentHistory'])->name('payment-history');
    Route::get('/available-kosts', [TenantController::class, 'availableKosts'])->name('available-kosts');
    Route::post('/join-kost/{kostLocation}', [TenantController::class, 'joinKost'])->name('join-kost');
});

// Default redirect after login
Route::middleware('auth')->get('/dashboard', function () {
    $user = auth()->user();
    
    if ($user->isOwner()) {
        return redirect()->route('owner.dashboard');
    } else {
        return redirect()->route('tenant.dashboard');
    }
})->name('dashboard');
