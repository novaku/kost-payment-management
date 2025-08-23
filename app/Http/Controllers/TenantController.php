<?php

namespace App\Http\Controllers;

use App\Models\Payment;
use App\Models\TenantKostAssignment;
use App\Models\KostLocation;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use Inertia\Inertia;
use Carbon\Carbon;

class TenantController extends Controller
{
    /**
     * Show tenant dashboard
     */
    public function dashboard()
    {
        $user = Auth::user();
        $assignments = $user->tenantAssignments()->with(['kostLocation', 'payments'])->where('is_active', true)->get();
        
        // Get latest payments status
        $currentMonth = date('m');
        $currentYear = date('Y');
        
        $assignmentData = $assignments->map(function ($assignment) use ($currentMonth, $currentYear) {
            $latestPayment = $assignment->payments()
                ->where('payment_month', $currentMonth)
                ->where('payment_year', $currentYear)
                ->first();
                
            return [
                'assignment' => $assignment,
                'current_payment' => $latestPayment,
                'is_late' => $assignment->isPaymentLate($currentMonth, $currentYear),
                'days_late' => $assignment->getDaysLate($currentMonth, $currentYear),
            ];
        });

        return Inertia::render('Tenant/Dashboard', [
            'assignments' => $assignmentData,
            'currentMonth' => $currentMonth,
            'currentYear' => $currentYear,
        ]);
    }

    /**
     * Show payment form
     */
    public function showPaymentForm(TenantKostAssignment $assignment)
    {
        $user = Auth::user();
        
        // Check if user owns this assignment
        if ($assignment->tenant_id !== $user->id) {
            abort(403);
        }

        return Inertia::render('Tenant/PaymentForm', [
            'assignment' => $assignment->load('kostLocation'),
        ]);
    }

    /**
     * Store payment
     */
    public function storePayment(Request $request, TenantKostAssignment $assignment)
    {
        $user = Auth::user();
        
        // Check if user owns this assignment
        if ($assignment->tenant_id !== $user->id) {
            abort(403);
        }

        $validated = $request->validate([
            'amount' => 'required|numeric|min:0',
            'payment_date' => 'required|date',
            'payment_month' => 'required|string|size:2',
            'payment_year' => 'required|string|size:4',
            'payment_proof' => 'required|image|mimes:jpeg,png,jpg|max:2048',
            'notes' => 'nullable|string|max:500',
        ]);

        // Check if payment already exists for this month/year
        $existingPayment = $assignment->payments()
            ->where('payment_month', $validated['payment_month'])
            ->where('payment_year', $validated['payment_year'])
            ->where('status', '!=', 'rejected')
            ->first();

        if ($existingPayment) {
            return redirect()->back()->withErrors(['payment_month' => 'Payment for this month already exists.']);
        }

        // Store payment proof image
        $paymentProofPath = null;
        if ($request->hasFile('payment_proof')) {
            $paymentProofPath = $request->file('payment_proof')->store('payment-proofs', 'public');
        }

        // Create payment
        $payment = Payment::create([
            'tenant_id' => $user->id,
            'kost_location_id' => $assignment->kost_location_id,
            'assignment_id' => $assignment->id,
            'amount' => $validated['amount'],
            'payment_date' => $validated['payment_date'],
            'payment_month' => $validated['payment_month'],
            'payment_year' => $validated['payment_year'],
            'payment_proof' => $paymentProofPath,
            'notes' => $validated['notes'],
        ]);

        // Calculate lateness
        $payment->calculateLateness();

        return redirect()->route('tenant.dashboard')->with('success', 'Payment submitted successfully. Waiting for verification.');
    }

    /**
     * Show payment history
     */
    public function paymentHistory()
    {
        $user = Auth::user();
        $payments = $user->payments()->with(['kostLocation', 'assignment', 'verifiedBy'])->latest()->paginate(20);

        return Inertia::render('Tenant/PaymentHistory', [
            'payments' => $payments,
        ]);
    }

    /**
     * Show available kost locations for joining
     */
    public function availableKosts()
    {
        $kostLocations = KostLocation::with(['owner', 'tenantAssignments'])
            ->get()
            ->map(function ($kost) {
                $occupiedRooms = $kost->tenantAssignments()->where('is_active', true)->count();
                $kost->available_rooms = $kost->total_rooms - $occupiedRooms;
                return $kost;
            })
            ->filter(function ($kost) {
                return $kost->available_rooms > 0;
            });

        return Inertia::render('Tenant/AvailableKosts', [
            'kostLocations' => $kostLocations,
        ]);
    }

    /**
     * Join a kost location
     */
    public function joinKost(Request $request, KostLocation $kostLocation)
    {
        $user = Auth::user();

        $validated = $request->validate([
            'room_number' => 'required|string|max:10',
            'start_date' => 'required|date|after_or_equal:today',
        ]);

        // Check if room is available
        $existingAssignment = $kostLocation->tenantAssignments()
            ->where('room_number', $validated['room_number'])
            ->where('is_active', true)
            ->first();

        if ($existingAssignment) {
            return redirect()->back()->withErrors(['room_number' => 'This room is already occupied.']);
        }

        // Check if user already has active assignment in this kost
        $userAssignment = $user->tenantAssignments()
            ->where('kost_location_id', $kostLocation->id)
            ->where('is_active', true)
            ->first();

        if ($userAssignment) {
            return redirect()->back()->withErrors(['general' => 'You are already assigned to this kost location.']);
        }

        // Create assignment
        TenantKostAssignment::create([
            'tenant_id' => $user->id,
            'kost_location_id' => $kostLocation->id,
            'room_number' => $validated['room_number'],
            'monthly_quota' => $kostLocation->monthly_rate,
            'start_date' => $validated['start_date'],
            'is_active' => true,
        ]);

        return redirect()->route('tenant.dashboard')->with('success', 'Successfully joined kost location.');
    }
}
