<?php

namespace App\Services;

use App\Models\Payment;
use App\Models\Setting;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Storage;

class PaymentService
{
    public function generatePaymentCode()
    {
        return 'PAY-' . date('Ymd') . '-' . strtoupper(Str::random(6));
    }

    public function calculateLateFee($dueDate, $paidDate = null)
    {
        $paidDate = $paidDate ?? now();
        $dueDate = \Carbon\Carbon::parse($dueDate);
        $paidDate = \Carbon\Carbon::parse($paidDate);

        if ($paidDate->lte($dueDate)) {
            return 0;
        }

        $daysLate = $paidDate->diffInDays($dueDate);
        $lateFeeType = Setting::get('late_fee_type', 'per_day'); // per_day or fixed
        $lateFeeAmount = (float) Setting::get('late_fee_amount', 10000);

        if ($lateFeeType === 'per_day') {
            return $daysLate * $lateFeeAmount;
        }

        return $lateFeeAmount;
    }

    public function submitPayment(array $data)
    {
        $paymentCode = $this->generatePaymentCode();
        $lateFee = $this->calculateLateFee($data['due_date']);

        $paymentData = [
            'payment_code' => $paymentCode,
            'tenant_id' => $data['tenant_id'],
            'room_id' => $data['room_id'],
            'payment_for_month' => $data['payment_for_month'],
            'amount' => $data['amount'],
            'late_fee' => $lateFee,
            'total_amount' => $data['amount'] + $lateFee,
            'payment_method' => $data['payment_method'],
            'bank_name' => $data['bank_name'] ?? null,
            'notes' => $data['notes'] ?? null,
            'due_date' => $data['due_date'],
            'status' => 'pending',
        ];

        // Handle file upload
        if (isset($data['proof_of_payment'])) {
            $file = $data['proof_of_payment'];
            $filename = time() . '_' . uniqid() . '.' . $file->getClientOriginalExtension();
            $path = $file->storeAs('payments', $filename, 'public');
            $paymentData['proof_of_payment'] = $path;
        }

        return Payment::create($paymentData);
    }

    public function verifyPayment($paymentId, $userId)
    {
        $payment = Payment::findOrFail($paymentId);

        $payment->update([
            'status' => 'approved',
            'verified_by' => $userId,
            'verified_at' => now(),
            'paid_date' => now(),
        ]);

        // Send notification to tenant
        // TODO: Implement notification

        return $payment;
    }

    public function rejectPayment($paymentId, $reason, $userId)
    {
        $payment = Payment::findOrFail($paymentId);

        $payment->update([
            'status' => 'rejected',
            'rejection_reason' => $reason,
            'verified_by' => $userId,
            'verified_at' => now(),
        ]);

        // Send notification to tenant
        // TODO: Implement notification

        return $payment;
    }

    public function deleteProofOfPayment($paymentId)
    {
        $payment = Payment::findOrFail($paymentId);

        if ($payment->proof_of_payment && Storage::disk('public')->exists($payment->proof_of_payment)) {
            Storage::disk('public')->delete($payment->proof_of_payment);
        }
    }
}
