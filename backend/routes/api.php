<?php

use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\MedicineSearchController;
use App\Http\Controllers\Api\V1\ReservationApiController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| PharmaConnect RESTful API - Version 1
|--------------------------------------------------------------------------
*/

Route::prefix('v1')->group(function () {
    // 1. المسارات العامة (البحث والاستعلام)
    Route::get('/medicines/search', [MedicineSearchController::class, 'search']);
    Route::get('/pharmacies/{id}/stock', [MedicineSearchController::class, 'pharmacyStock']);

    // 2. مصادقة المستخدمين وتطبيق الهاتف
    Route::post('/auth/register', [AuthController::class, 'register']);
    Route::post('/auth/login', [AuthController::class, 'login']);

    // 3. المسارات المحمية بـ Sanctum (الحجوزات والملف الشخصي)
    Route::middleware('auth:sanctum')->group(function () {
        Route::get('/auth/profile', [AuthController::class, 'profile']);
        Route::post('/auth/logout', [AuthController::class, 'logout']);

        Route::post('/reservations', [ReservationApiController::class, 'store']);
        Route::get('/reservations/my', [ReservationApiController::class, 'myReservations']);
        Route::post('/reservations/{id}/cancel', [ReservationApiController::class, 'cancel']);
    });
});
