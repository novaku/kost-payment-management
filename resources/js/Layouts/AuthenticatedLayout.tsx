import { ReactNode } from 'react';
import { Link, usePage } from '@inertiajs/react';
import { User } from '../types';

interface Props {
    children: ReactNode;
    header?: ReactNode;
}

interface PageProps {
    auth: {
        user: User;
    };
}

export default function AuthenticatedLayout({ children, header }: Props) {
    const { auth } = usePage<PageProps>().props;

    return (
        <div className="min-h-screen bg-gray-100">
            <nav className="bg-white border-b border-gray-100">
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                    <div className="flex justify-between h-16">
                        <div className="flex">
                            <div className="shrink-0 flex items-center">
                                <Link href="/">
                                    <h1 className="text-xl font-bold text-gray-900">
                                        Kost Payment
                                    </h1>
                                </Link>
                            </div>

                            <div className="hidden space-x-8 sm:-my-px sm:ml-10 sm:flex">
                                {auth.user.role === 'owner' ? (
                                    <>
                                        <Link
                                            href="/owner/dashboard"
                                            className="border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 whitespace-nowrap py-2 px-1 border-b-2 font-medium text-sm"
                                        >
                                            Dashboard
                                        </Link>
                                        <Link
                                            href="/owner/payments"
                                            className="border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 whitespace-nowrap py-2 px-1 border-b-2 font-medium text-sm"
                                        >
                                            Payments
                                        </Link>
                                        <Link
                                            href="/owner/reports"
                                            className="border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 whitespace-nowrap py-2 px-1 border-b-2 font-medium text-sm"
                                        >
                                            Reports
                                        </Link>
                                        <Link
                                            href="/owner/kost-locations"
                                            className="border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 whitespace-nowrap py-2 px-1 border-b-2 font-medium text-sm"
                                        >
                                            Kost Locations
                                        </Link>
                                    </>
                                ) : (
                                    <>
                                        <Link
                                            href="/tenant/dashboard"
                                            className="border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 whitespace-nowrap py-2 px-1 border-b-2 font-medium text-sm"
                                        >
                                            Dashboard
                                        </Link>
                                        <Link
                                            href="/tenant/payment-history"
                                            className="border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 whitespace-nowrap py-2 px-1 border-b-2 font-medium text-sm"
                                        >
                                            Payment History
                                        </Link>
                                        <Link
                                            href="/tenant/available-kosts"
                                            className="border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 whitespace-nowrap py-2 px-1 border-b-2 font-medium text-sm"
                                        >
                                            Available Kosts
                                        </Link>
                                    </>
                                )}
                            </div>
                        </div>

                        <div className="hidden sm:flex sm:items-center sm:ml-6">
                            <div className="ml-3 relative">
                                <div className="flex items-center space-x-4">
                                    <span className="text-sm text-gray-700">
                                        {auth.user.name}
                                    </span>
                                    <Link
                                        href="/logout"
                                        method="post"
                                        as="button"
                                        className="text-sm text-gray-500 hover:text-gray-700"
                                    >
                                        Logout
                                    </Link>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </nav>

            {header && (
                <header className="bg-white shadow">
                    <div className="max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8">
                        {header}
                    </div>
                </header>
            )}

            <main>{children}</main>
        </div>
    );
}
