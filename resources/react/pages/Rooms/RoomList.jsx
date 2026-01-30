import React from 'react';
import { useAuth } from '../../contexts/AuthContext';
import { FiLogOut, FiArrowLeft } from 'react-icons/fi';

const RoomList = () => {
  const { logout } = useAuth();

  return (
    <div className="min-h-screen bg-gray-100">
      <header className="bg-white shadow">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex justify-between items-center">
          <div className="flex items-center gap-4">
            <a
              href="/dashboard"
              className="p-2 text-gray-600 hover:bg-gray-100 rounded-lg transition-colors"
            >
              <FiArrowLeft size={20} />
            </a>
            <h1 className="text-2xl font-bold text-gray-900">Manajemen Kamar</h1>
          </div>
          <button
            onClick={logout}
            className="p-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors"
          >
            <FiLogOut size={20} />
          </button>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="bg-white rounded-lg shadow p-8 text-center">
          <h2 className="text-2xl font-bold text-gray-900 mb-4">
            Halaman Manajemen Kamar
          </h2>
          <p className="text-gray-600">
            Fitur ini akan segera hadir. Anda dapat menambahkan CRUD kamar di sini.
          </p>
        </div>
      </main>
    </div>
  );
};

export default RoomList;
