export interface User {
    id: number;
    name: string;
    email: string;
    role: 'owner' | 'tenant';
    phone?: string;
    address?: string;
    email_verified_at?: string;
}

export interface KostLocation {
    id: number;
    owner_id: number;
    name: string;
    address: string;
    city: string;
    monthly_rate: number;
    total_rooms: number;
    description?: string;
    owner?: User;
    tenant_assignments?: TenantKostAssignment[];
    payments?: Payment[];
    available_rooms?: number;
}

export interface TenantKostAssignment {
    id: number;
    tenant_id: number;
    kost_location_id: number;
    room_number: string;
    monthly_quota: number;
    start_date: string;
    end_date?: string;
    is_active: boolean;
    tenant?: User;
    kost_location?: KostLocation;
    payments?: Payment[];
}

export interface Payment {
    id: number;
    tenant_id: number;
    kost_location_id: number;
    assignment_id: number;
    amount: number;
    payment_date: string;
    payment_month: string;
    payment_year: string;
    payment_proof?: string;
    status: 'pending' | 'verified' | 'rejected';
    notes?: string;
    verified_at?: string;
    verified_by?: number;
    is_late: boolean;
    days_late: number;
    tenant?: User;
    kost_location?: KostLocation;
    assignment?: TenantKostAssignment;
    verified_by_user?: User;
}

export interface PageProps<T extends Record<string, unknown> = Record<string, unknown>> {
    auth: {
        user: User;
    };
    flash?: {
        success?: string;
        error?: string;
    };
    errors: Record<string, string>;
    data?: T;
}
