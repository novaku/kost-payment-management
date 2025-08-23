import { Head } from '@inertiajs/react';
import AuthenticatedLayout from '../../Layouts/AuthenticatedLayout';
import { KostLocation, PageProps } from '../../types';

interface Props extends PageProps {
    kostLocations: KostLocation[];
    statistics: {
        totalRevenue: number;
        pendingPayments: number;
        totalTenants: number;
        latePayments: number;
    };
}

export default function Dashboard({ auth, kostLocations, statistics }: Props) {
    return (
        <AuthenticatedLayout>
            <Head title="Owner Dashboard" />

            <div className="py-12">
                <div className="max-w-7xl mx-auto sm:px-6 lg:px-8">
                    <div className="bg-white overflow-hidden shadow-sm sm:rounded-lg">
                        <div className="p-6 text-gray-900">
                            <h1 className="text-2xl font-semibold mb-6">Dashboard</h1>

                            {/* Statistics Cards */}
                            <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
                                <div className="bg-blue-50 p-6 rounded-lg">
                                    <div className="flex items-center">
                                        <div className="p-2 bg-blue-500 rounded-md">
                                            <svg className="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1" />
                                            </svg>
                                        </div>
                                        <div className="ml-4">
                                            <p className="text-sm font-medium text-gray-600">Total Revenue</p>
                                            <p className="text-2xl font-semibold text-gray-900">
                                                Rp {statistics.totalRevenue.toLocaleString('id-ID')}
                                            </p>
                                        </div>
                                    </div>
                                </div>

                                <div className="bg-yellow-50 p-6 rounded-lg">
                                    <div className="flex items-center">
                                        <div className="p-2 bg-yellow-500 rounded-md">
                                            <svg className="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                                            </svg>
                                        </div>
                                        <div className="ml-4">
                                            <p className="text-sm font-medium text-gray-600">Pending Payments</p>
                                            <p className="text-2xl font-semibold text-gray-900">{statistics.pendingPayments}</p>
                                        </div>
                                    </div>
                                </div>

                                <div className="bg-green-50 p-6 rounded-lg">
                                    <div className="flex items-center">
                                        <div className="p-2 bg-green-500 rounded-md">
                                            <svg className="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
                                            </svg>
                                        </div>
                                        <div className="ml-4">
                                            <p className="text-sm font-medium text-gray-600">Total Tenants</p>
                                            <p className="text-2xl font-semibold text-gray-900">{statistics.totalTenants}</p>
                                        </div>
                                    </div>
                                </div>

                                <div className="bg-red-50 p-6 rounded-lg">
                                    <div className="flex items-center">
                                        <div className="p-2 bg-red-500 rounded-md">
                                            <svg className="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z" />
                                            </svg>
                                        </div>
                                        <div className="ml-4">
                                            <p className="text-sm font-medium text-gray-600">Late Payments</p>
                                            <p className="text-2xl font-semibold text-gray-900">{statistics.latePayments}</p>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            {/* Kost Locations Overview */}
                            <div className="bg-white shadow rounded-lg">
                                <div className="px-6 py-4 border-b border-gray-200">
                                    <h3 className="text-lg font-medium text-gray-900">Kost Locations Overview</h3>
                                </div>
                                <div className="p-6">
                                    {kostLocations.length === 0 ? (
                                        <p className="text-gray-500 text-center py-8">
                                            No kost locations found. Create your first kost location to get started.
                                        </p>
                                    ) : (
                                        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                                            {kostLocations.map((kost) => (
                                                <div key={kost.id} className="border border-gray-200 rounded-lg p-4">
                                                    <h4 className="font-medium text-gray-900 mb-2">{kost.name}</h4>
                                                    <p className="text-sm text-gray-600 mb-2">{kost.city}</p>
                                                    <div className="flex justify-between text-sm">
                                                        <span>Monthly Rate:</span>
                                                        <span className="font-medium">Rp {kost.monthly_rate.toLocaleString('id-ID')}</span>
                                                    </div>
                                                    <div className="flex justify-between text-sm">
                                                        <span>Total Rooms:</span>
                                                        <span className="font-medium">{kost.total_rooms}</span>
                                                    </div>
                                                    <div className="flex justify-between text-sm">
                                                        <span>Occupied:</span>
                                                        <span className="font-medium">
                                                            {kost.tenant_assignments?.filter(t => t.is_active).length || 0}
                                                        </span>
                                                    </div>
                                                </div>
                                            ))}
                                        </div>
                                    )}
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </AuthenticatedLayout>
    );
}
