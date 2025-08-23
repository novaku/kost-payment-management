<?php

namespace App\Http\Controllers;

use App\Models\KostLocation;
use App\Models\Payment;
use App\Models\TenantKostAssignment;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Inertia\Inertia;
use Carbon\Carbon;

class OwnerController extends Controller
{
    /**
     * Show owner dashboard
     */
    public function dashboard()
    {
        $user = Auth::user();
        $kostLocations = $user->ownedKostLocations()->with(['tenantAssignments.tenant', 'payments'])->get();
        
        // Calculate statistics
        $totalRevenue = 0;
        $pendingPayments = 0;
        $totalTenants = 0;
        $latePayments = 0;

        foreach ($kostLocations as $location) {
            $totalRevenue += $location->getMonthlyRevenue();
            $pendingPayments += $location->payments()->pending()->count();
            $totalTenants += $location->activeTenants()->count();
            $latePayments += $location->payments()->late()->count();
        }

        return Inertia::render('Owner/Dashboard', [
            'kostLocations' => $kostLocations,
            'statistics' => [
                'totalRevenue' => $totalRevenue,
                'pendingPayments' => $pendingPayments,
                'totalTenants' => $totalTenants,
                'latePayments' => $latePayments,
            ]
        ]);
    }

    /**
     * Show payments management
     */
    public function payments(Request $request)
    {
        $user = Auth::user();
        $kostLocationId = $request->get('kost_location_id');
        $status = $request->get('status');
        
        $query = Payment::whereHas('kostLocation', function ($q) use ($user) {
            $q->where('owner_id', $user->id);
        })->with(['tenant', 'kostLocation', 'assignment']);

        if ($kostLocationId) {
            $query->where('kost_location_id', $kostLocationId);
        }

        if ($status) {
            $query->where('status', $status);
        }

        $payments = $query->latest()->paginate(20);
        $kostLocations = $user->ownedKostLocations()->get();

        return Inertia::render('Owner/Payments', [
            'payments' => $payments,
            'kostLocations' => $kostLocations,
            'filters' => [
                'kost_location_id' => $kostLocationId,
                'status' => $status,
            ]
        ]);
    }

    /**
     * Verify payment
     */
    public function verifyPayment(Request $request, Payment $payment)
    {
        $user = Auth::user();
        
        // Check if user owns this kost location
        if ($payment->kostLocation->owner_id !== $user->id) {
            abort(403);
        }

        $validated = $request->validate([
            'status' => 'required|in:verified,rejected',
            'notes' => 'nullable|string|max:500',
        ]);

        if ($validated['status'] === 'verified') {
            $payment->markAsVerified($user->id);
        } else {
            $payment->markAsRejected($user->id, $validated['notes']);
        }

        return redirect()->back()->with('success', 'Payment status updated successfully.');
    }

    /**
     * Show reports
     */
    public function reports(Request $request)
    {
        $user = Auth::user();
        $kostLocationId = $request->get('kost_location_id');
        $startDate = $request->get('start_date', now()->startOfMonth()->format('Y-m-d'));
        $endDate = $request->get('end_date', now()->endOfMonth()->format('Y-m-d'));

        $query = Payment::whereHas('kostLocation', function ($q) use ($user) {
            $q->where('owner_id', $user->id);
        })->with(['tenant', 'kostLocation'])
        ->verified()
        ->whereBetween('payment_date', [$startDate, $endDate]);

        if ($kostLocationId) {
            $query->where('kost_location_id', $kostLocationId);
        }

        $payments = $query->get();
        $kostLocations = $user->ownedKostLocations()->get();

        // Calculate summary
        $summary = [
            'total_revenue' => $payments->sum('amount'),
            'total_payments' => $payments->count(),
            'average_payment' => $payments->avg('amount'),
            'late_payments' => $payments->where('is_late', true)->count(),
        ];

        return Inertia::render('Owner/Reports', [
            'payments' => $payments,
            'kostLocations' => $kostLocations,
            'summary' => $summary,
            'filters' => [
                'kost_location_id' => $kostLocationId,
                'start_date' => $startDate,
                'end_date' => $endDate,
            ]
        ]);
    }

    /**
     * Export reports to PDF
     */
    public function exportPdf(Request $request)
    {
        // Implementation for PDF export
        // This would use DomPDF to generate PDF reports
    }

    /**
     * Export reports to Excel
     */
    public function exportExcel(Request $request)
    {
        // Implementation for Excel export
        // This would use Maatwebsite Excel to generate Excel reports
    }

    /**
     * Show kost locations management
     */
    public function kostLocations()
    {
        $user = Auth::user();
        $kostLocations = $user->ownedKostLocations()->with(['tenantAssignments.tenant'])->get();

        return Inertia::render('Owner/KostLocations', [
            'kostLocations' => $kostLocations,
        ]);
    }

    /**
     * Store new kost location
     */
    public function storeKostLocation(Request $request)
    {
        $user = Auth::user();

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'address' => 'required|string',
            'city' => 'required|string|max:100',
            'monthly_rate' => 'required|numeric|min:0',
            'total_rooms' => 'required|integer|min:1',
            'description' => 'nullable|string',
        ]);

        $kostLocation = $user->ownedKostLocations()->create($validated);

        return redirect()->back()->with('success', 'Kost location created successfully.');
    }
}
