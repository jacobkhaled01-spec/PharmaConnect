<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\ReservationResource;
use App\Models\User;
use App\Services\ReservationService;
use Exception;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ReservationApiController extends Controller
{
    public function __construct(
        protected ReservationService $reservationService
    ) {}

    /**
     * إنشاء حجز مؤقت للدواء محمي بالتزامن وقفل الصفوف
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'pharmacy_medicine_id' => 'required|exists:pharmacy_medicines,id',
            'quantity' => 'nullable|integer|min:1|max:10',
            'ttl_minutes' => 'nullable|integer|min:10|max:60',
            'patient_name' => 'nullable|string|max:100',
            'patient_phone' => 'nullable|string|max:30',
        ]);

        $user = $request->user();
        if (! $user) {
            $patientName = ! empty($validated['patient_name']) ? trim($validated['patient_name']) : 'مريض مباشر';
            $patientPhone = ! empty($validated['patient_phone']) ? trim($validated['patient_phone']) : '+967 770 000 000';
            $phoneClean = preg_replace('/[^0-9]/', '', $patientPhone);
            $email = 'patient_'.($phoneClean ?: uniqid()).'@pharmaconnect.ye';

            $user = User::firstOrCreate(
                ['phone' => $patientPhone],
                [
                    'name' => $patientName,
                    'email' => $email,
                    'role' => 'patient',
                    'password' => bcrypt('password123'),
                ]
            );

            if (! empty($validated['patient_name']) && $user->name !== $patientName) {
                $user->update(['name' => $patientName]);
            }
        }
        $userId = $user->id;
        $pharmacyMedicineId = (int) $validated['pharmacy_medicine_id'];
        $quantity = (int) ($validated['quantity'] ?? 1);
        $ttlMinutes = (int) ($validated['ttl_minutes'] ?? 30);

        try {
            $reservation = $this->reservationService->createReservation(
                $userId,
                $pharmacyMedicineId,
                $quantity,
                $ttlMinutes
            );

            return response()->json([
                'success' => true,
                'message' => 'تم الحجز المؤقت بنجاح. يرجى التوجه للصيدلية قبل انتهاء المهلة الزمنية.',
                'data' => new ReservationResource($reservation),
            ], 201);
        } catch (Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 422);
        }
    }

    /**
     * استعراض قائمة حجوزات المريض الحالية والسابقة
     */
    public function myReservations(Request $request): JsonResponse
    {
        $user = $request->user() ?? User::where('role', 'patient')->first();
        $userId = $user ? $user->id : 0;
        $reservations = $this->reservationService->getUserReservations($userId);

        return response()->json([
            'success' => true,
            'count' => $reservations->count(),
            'data' => ReservationResource::collection($reservations),
        ]);
    }

    /**
     * إلغاء الحجز من قِبل المريض
     */
    public function cancel(int $id, Request $request): JsonResponse
    {
        try {
            $user = $request->user() ?? User::where('role', 'patient')->first();
            $userId = $user ? $user->id : 0;
            $reservation = $this->reservationService->cancelReservation($id, $userId);

            return response()->json([
                'success' => true,
                'message' => 'تم إلغاء الحجز وإعادة الكمية لمخزون الصيدلية.',
                'data' => new ReservationResource($reservation),
            ]);
        } catch (Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 422);
        }
    }
}
