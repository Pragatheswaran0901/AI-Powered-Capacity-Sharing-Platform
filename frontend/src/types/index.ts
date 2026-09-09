export type UserRole = 'admin' | 'msme' | 'machine_owner' | 'machine_seeker';

export interface User {
  id: number;
  name: string;
  email: string;
  role: UserRole;
  msme_id?: number;
  company_name?: string;
}

export interface MSME {
  id: number;
  owner_user_id: number;
  company_name: string;
  business_type: string;
  description?: string;
  city: string;
  district: string;
  state: string;
  pincode?: string;
  latitude?: number;
  longitude?: number;
  verification_status: 'verified' | 'pending' | 'rejected';
  created_at: string;
}

export interface Capability {
  id?: number;
  machine_id?: number;
  process: string;
  material: string;
  max_dimension?: string;
  tolerance?: string;
  capacity_description?: string;
}

export interface Machine {
  id: number;
  msme_id: number;
  msme_name?: string;
  msme_city?: string;
  machine_name: string;
  machine_type: string;
  manufacturer?: string;
  model?: string;
  year?: number;
  description?: string;
  hourly_rate: number;
  minimum_booking_hours: number;
  location: string;
  latitude?: number;
  longitude?: number;
  operator_available: boolean;
  verification_status: 'verified' | 'pending' | 'rejected';
  created_at: string;
  capabilities: Capability[];
  avg_rating?: number;
  jobs_completed?: number;
}

export interface Requirement {
  id: number;
  seeker_msme_id: number;
  seeker_company_name?: string;
  title: string;
  description?: string;
  process: string;
  material: string;
  quantity: number;
  deadline: string;
  budget: number;
  preferred_city: string;
  latitude?: number;
  longitude?: number;
  status: 'open' | 'matched' | 'in_progress' | 'completed' | 'cancelled';
  created_at: string;
}

export interface MatchResult {
  match_id?: number;
  machine: Machine;
  capability_score: number;
  availability_score: number;
  distance_score: number;
  cost_score: number;
  reliability_score: number;
  total_score: number;
  match_percentage: number;
  distance_km: number;
}

export interface Booking {
  id: number;
  requirement_id: number;
  machine_id: number;
  seeker_msme_id: number;
  owner_msme_id: number;
  machine_name?: string;
  seeker_company_name?: string;
  owner_company_name?: string;
  booking_date: string;
  start_time: string;
  end_time: string;
  quantity: number;
  agreed_price: number;
  status: 'pending' | 'accepted' | 'rejected' | 'confirmed' | 'in_progress' | 'completed' | 'cancelled';
  created_at: string;
}

export interface Review {
  id: number;
  booking_id: number;
  reviewer_id: number;
  reviewer_name?: string;
  reviewed_msme_id: number;
  rating: number;
  quality_rating: number;
  reliability_rating: number;
  communication_rating: number;
  comment?: string;
  created_at: string;
}

export interface AdminStats {
  total_msmes: number;
  verified_msmes: number;
  pending_msmes: number;
  total_machines: number;
  verified_machines: number;
  total_bookings: number;
  active_bookings: number;
  completed_jobs: number;
  total_gmv: number;
  platform_revenue: number;
  machines_by_city: Record<string, number>;
  machines_by_category: Record<string, number>;
  average_utilization: number;
}

export interface OwnerAnalytics {
  total_machines: number;
  available_hours: number;
  booked_hours: number;
  idle_hours: number;
  utilization_rate: number;
  monthly_earnings: number;
  pending_requests: number;
  average_rating: number;
  completed_jobs: number;
}
