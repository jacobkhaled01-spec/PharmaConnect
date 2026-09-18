@extends('layouts.pharmacy')

@section('title', 'طلبات الحجز الواردة - ' . $pharmacy->name)

@section('content')
    <div class="card">
        <h2 style="color: var(--primary-dark); margin-bottom: 0.5rem;">⏱️ طلبات الحجز المؤقت الواردة</h2>
        <p style="color: var(--text-muted); font-size: 0.95rem; margin-bottom: 1.5rem;">
            تظهر هنا طلبات الحجز المؤقت التي قام المرضى بإرسالها من تطبيق الموبايل، مع حفظ الكميات لهم لمدة 30 دقيقة.
        </p>

        <div class="table-responsive">
            <table>
                <thead>
                    <tr>
                        <th>رمز الحجز</th>
                        <th>اسم المريض والهاتف</th>
                        <th>الأدوية المطلوبة والكمية</th>
                        <th>الإجمالي</th>
                        <th>المهلة المتبقية (TTL)</th>
                        <th>حالة الحجز</th>
                        <th>الإجراء</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($reservations as $res)
                        <tr>
                            <td>
                                <strong style="color: var(--primary); font-size: 1.05rem;">{{ $res->reservation_code }}</strong>
                                <div style="font-size: 0.75rem; color: var(--text-muted);">{{ $res->created_at->format('Y-m-d H:i') }}</div>
                            </td>
                            <td>
                                <strong>{{ $res->user->name }}</strong>
                                <div style="font-size: 0.85rem; color: var(--text-muted);">{{ $res->user->phone ?? 'بدون هاتف' }}</div>
                            </td>
                            <td>
                                @foreach($res->reservationItems as $item)
                                    <div>
                                        • {{ $item->pharmacyMedicine?->medicine?->trade_name }} 
                                        <strong>× {{ $item->quantity }}</strong>
                                    </div>
                                @endforeach
                            </td>
                            <td><strong>{{ number_format($res->total_amount, 2) }} ريال</strong></td>
                            <td>
                                @if($res->status === 'pending')
                                    @if($res->expires_at->isPast())
                                        <span class="badge badge-danger">منتهي الصلاحية</span>
                                    @else
                                        <span class="badge badge-warning">
                                            متبقي {{ $res->expires_at->diffInMinutes(now()) }} دقيقة
                                        </span>
                                    @endif
                                @else
                                    <span style="color: var(--text-muted);">-</span>
                                @endif
                            </td>
                            <td>
                                @if($res->status === 'pending')
                                    <span class="badge badge-warning">قيد الانتظار</span>
                                @elseif($res->status === 'completed')
                                    <span class="badge badge-success">تم التسليم والمحاسبة</span>
                                @elseif($res->status === 'expired')
                                    <span class="badge badge-danger">ملغي (انتهاء المهلة)</span>
                                @else
                                    <span class="badge badge-danger">{{ $res->status }}</span>
                                @endif
                            </td>
                            <td>
                                @if($res->status === 'pending' && ! $res->expires_at->isPast())
                                    <form action="{{ route('pharmacy.reservations.confirm', $res->id) }}" method="POST" onsubmit="return confirm('هل حضر المريض وتم تسليمه الدواء واستلام المبلغ؟')">
                                        @csrf
                                        <button type="submit" class="btn btn-primary" style="padding: 6px 14px; font-size: 0.85rem;">
                                            ✅ تأكيد التسليم
                                        </button>
                                    </form>
                                @else
                                    <span style="color: var(--text-muted); font-size: 0.85rem;">مكتمل</span>
                                @endif
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="7" style="text-align: center; padding: 3rem; color: var(--text-muted);">
                                لا توجد حجوزات واردة حالياً. ستظهر هنا فور قيام أي مريض بالحجز عبر تطبيق الموبايل.
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>
@endsection
