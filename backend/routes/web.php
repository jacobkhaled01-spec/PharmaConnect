<?php

use App\Http\Controllers\Web\PharmacyInventoryController;
use App\Http\Controllers\Web\WebAuthController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| PharmaConnect Web Portal Routes (Pharmacy Inventory Management)
|--------------------------------------------------------------------------
*/

// توجيه الصفحة الرئيسية إلى تسجيل الدخول أو المخزون
Route::get('/', function () {
    return redirect()->route('login');
});

// مسارات المصادقة للويب
Route::get('/login', [WebAuthController::class, 'showLogin'])->name('login');
Route::post('/login', [WebAuthController::class, 'login'])->name('login.post');
Route::post('/logout', [WebAuthController::class, 'logout'])->name('logout');

// مسارات إدارة المخزون وبوابة الصيدلية (محمية بالجلسات)
Route::middleware('auth')->prefix('pharmacy')->name('pharmacy.')->group(function () {
    Route::get('/inventory', [PharmacyInventoryController::class, 'index'])->name('inventory');
    Route::post('/inventory/add', [PharmacyInventoryController::class, 'addMedicine'])->name('inventory.add');
    Route::post('/inventory/{id}/update', [PharmacyInventoryController::class, 'updateStock'])->name('inventory.update');

    Route::get('/reservations', [PharmacyInventoryController::class, 'reservations'])->name('reservations');
    Route::post('/reservations/{id}/confirm', [PharmacyInventoryController::class, 'confirmPickup'])->name('reservations.confirm');
});
