<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\RoomController;
use App\Http\Controllers\Api\TenantController;
use App\Http\Controllers\Api\PaymentController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\ReportController;
use Illuminate\Support\Facades\Route;

// Public routes
Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    // Auth routes
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);

    // Dashboard
    Route::get('/dashboard', [DashboardController::class, 'index']);

    // Rooms
    Route::apiResource('rooms', RoomController::class);
    
    // Tenants
    Route::apiResource('tenants', TenantController::class);
    
    // Payments
    Route::apiResource('payments', PaymentController::class);
    Route::post('/payments/{id}/verify', [PaymentController::class, 'verify']);
    Route::post('/payments/{id}/reject', [PaymentController::class, 'reject']);
    
    // Reports
    Route::get('/reports/payments', [ReportController::class, 'payments']);
    Route::get('/reports/late-payments', [ReportController::class, 'latePayments']);
    Route::get('/reports/financial', [ReportController::class, 'financial']);
    Route::get('/reports/export-payments', [ReportController::class, 'exportPayments']);
});
