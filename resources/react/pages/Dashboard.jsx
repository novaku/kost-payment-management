import React, { useEffect, useState } from 'react';
import { useAuth } from '../contexts/AuthContext';
import axios from 'axios';
import { FiHome, FiUsers, FiDollarSign, FiLogOut } from 'react-icons/fi';

const Dashboard = () => {
  const { user, logout } = useAuth();
  const [stats, setStats] = useState({
    totalRooms: 0,
    occupiedRooms: 0,
    totalTenants: 0,
    pendingPayments: 0,
  });

  useEffect(() => {
    // TODO: Fetch dashboard stats from API
    // For now, using mock data
    setStats({
      totalRooms: 20,
      occupiedRooms: 15,
      totalTenants: 15,
      pendingPayments: 3,
    });
  }, []);

  return (
    <div className="min-h-screen bg-gray-100">
      {/* Header */}
      <header className="bg-white shadow">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex justify-between items-center">
          <h1 className="text-2xl font-bold text-gray-900">Dashboard</h1>
          <div className="flex items-center gap-4">
            <div className="text-right">
              <p className="text-sm font-medium text-gray-900">{user?.name}</p>
              <p className="text-xs text-gray-500">{user?.role?.display_name}</p>
            </div>
            <button
              onClick={logout}
              className="p-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors"
              title="Logout"
            >
              <FiLogOut size={20} />
            </button>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Welcome Message */}
        <div className="mb-8">
          <h2 className="text-3xl font-bold text-gray-900">
            Selamat Datang, {user?.name}!
          </h2>
          <p className="text-gray-600 mt-2">
            Berikut adalah ringkasan sistem manajemen pembayaran kosan Anda
          </p>
        </div>

        {/* Stats Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <div className="bg-white rounded-lg shadow p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600">Total Kamar</p>
                <p className="text-3xl font-bold text-gray-900 mt-2">
                  {stats.totalRooms}
                </p>
              </div>
              <div className="p-3 bg-blue-100 rounded-full">
                <FiHome className="text-blue-600" size={24} />
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg shadow p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600">Kamar Terisi</p>
                <p className="text-3xl font-bold text-gray-900 mt-2">
                  {stats.occupiedRooms}
                </p>
              </div>
              <div className="p-3 bg-green-100 rounded-full">
                <FiHome className="text-green-600" size={24} />
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg shadow p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600">Total Penghuni</p>
                <p className="text-3xl font-bold text-gray-900 mt-2">
                  {stats.totalTenants}
                </p>
              </div>
              <div className="p-3 bg-purple-100 rounded-full">
                <FiUsers className="text-purple-600" size={24} />
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg shadow p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600">Pending Payment</p>
                <p className="text-3xl font-bold text-gray-900 mt-2">
                  {stats.pendingPayments}
                </p>
              </div>
              <div className="p-3 bg-yellow-100 rounded-full">
                <FiDollarSign className="text-yellow-600" size={24} />
              </div>
            </div>
          </div>
        </div>

        {/* Quick Links */}
        <div className="bg-white rounded-lg shadow p-6">
          <h3 className="text-xl font-bold text-gray-900 mb-4">Menu</h3>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <a
              href="/rooms"
              className="p-4 border border-gray-200 rounded-lg hover:border-blue-500 hover:bg-blue-50 transition-colors"
            >
              <h4 className="font-medium text-gray-900">Manage Kamar</h4>
              <p className="text-sm text-gray-600 mt-1">
                Kelola data kamar kosan
              </p>
            </a>
            <a
              href="/tenants"
              className="p-4 border border-gray-200 rounded-lg hover:border-blue-500 hover:bg-blue-50 transition-colors"
            >
              <h4 className="font-medium text-gray-900">Manage Penghuni</h4>
              <p className="text-sm text-gray-600 mt-1">
                Kelola data penghuni kosan
              </p>
            </a>
            <a
              href="/payments"
              className="p-4 border border-gray-200 rounded-lg hover:border-blue-500 hover:bg-blue-50 transition-colors"
            >
              <h4 className="font-medium text-gray-900">Pembayaran</h4>
              <p className="text-sm text-gray-600 mt-1">
                Kelola dan verifikasi pembayaran
              </p>
            </a>
          </div>
        </div>
      </main>
    </div>
  );
};

export default Dashboard;
