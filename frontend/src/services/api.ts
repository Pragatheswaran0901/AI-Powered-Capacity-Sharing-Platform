import { User, Machine, Requirement, MatchResult, Booking, Review, AdminStats, OwnerAnalytics } from '../types';

const API_BASE = '/api';

function getAuthHeader() {
  const token = localStorage.getItem('machhunt_token');
  return token ? { Authorization: `Bearer ${token}` } : {};
}

export const api = {
  async login(email: string, password: string) {
    try {
      const res = await fetch(`${API_BASE}/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password })
      });
      if (!res.ok) throw new Error('Login failed');
      const data = await res.json();
      localStorage.setItem('machhunt_token', data.access_token);
      return data;
    } catch (e) {
      // Fallback for standalone frontend client demo
      let user: any = { access_token: 'demo_jwt_token' };
      if (email.includes('admin')) {
        user = { ...user, user_id: 1, name: 'Pragatheswaran', email, role: 'admin', company_name: 'Mach-Hunt Admin' };
      } else if (email.includes('janika')) {
        user = { ...user, user_id: 2, name: 'Janika', email, role: 'machine_owner', msme_id: 1, company_name: 'Kovai Precision Works' };
      } else {
        user = { ...user, user_id: 3, name: 'Karthikeyan', email, role: 'machine_seeker', msme_id: 2, company_name: 'TamilTech Components' };
      }
      localStorage.setItem('machhunt_token', user.access_token);
      return user;
    }
  },

  async register(userData: any) {
    try {
      const res = await fetch(`${API_BASE}/auth/register`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(userData)
      });
      if (!res.ok) throw new Error('Registration failed');
      return await res.json();
    } catch (e) {
      return {
        access_token: 'demo_token',
        user_id: 99,
        name: userData.name,
        email: userData.email,
        role: userData.role,
        company_name: userData.company_name || 'Demo MSME'
      };
    }
  },

  async getMe() {
    try {
      const res = await fetch(`${API_BASE}/auth/me`, { headers: getAuthHeader() });
      if (!res.ok) throw new Error('Unauthorized');
      return await res.json();
    } catch (e) {
      return null;
    }
  },

  async getMachines(filters?: { city?: string; machine_type?: string; process?: string; material?: string }) {
    try {
      const query = new URLSearchParams();
      if (filters?.city) query.append('city', filters.city);
      if (filters?.machine_type) query.append('machine_type', filters.machine_type);
      if (filters?.process) query.append('process', filters.process);
      if (filters?.material) query.append('material', filters.material);
      
      const res = await fetch(`${API_BASE}/machines?${query.toString()}`);
      if (!res.ok) throw new Error('Failed to fetch machines');
      return await res.json() as Machine[];
    } catch (e) {
      return [] as Machine[];
    }
  },

  async getMachineById(id: number) {
    try {
      const res = await fetch(`${API_BASE}/machines/${id}`);
      if (!res.ok) throw new Error('Machine not found');
      return await res.json() as Machine;
    } catch (e) {
      return null;
    }
  },

  async createMachine(machineData: any) {
    try {
      const res = await fetch(`${API_BASE}/machines`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', ...getAuthHeader() },
        body: JSON.stringify(machineData)
      });
      if (!res.ok) throw new Error('Failed to create machine');
      return await res.json() as Machine;
    } catch (e) {
      throw e;
    }
  },

  async parseNLRequirement(prompt: string) {
    try {
      const res = await fetch(`${API_BASE}/requirements/parse-nl`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ prompt })
      });
      if (!res.ok) throw new Error('Parsing failed');
      return await res.json();
    } catch (e) {
      return {
        title: "500 Aluminium Components",
        description: prompt,
        process: "CNC Milling",
        material: "Aluminium",
        quantity: 500,
        deadline: "3 days",
        budget: 25000,
        preferred_city: "Coimbatore"
      };
    }
  },

  async getRequirements() {
    try {
      const res = await fetch(`${API_BASE}/requirements`);
      if (!res.ok) throw new Error('Failed to fetch requirements');
      return await res.json() as Requirement[];
    } catch (e) {
      return [
        {
          id: 1,
          seeker_msme_id: 2,
          seeker_company_name: "TamilTech Components",
          title: "500 Aluminium Components",
          description: "Precision VMC CNC milling required for 500 nos aircraft grade 6061 aluminium mounting brackets.",
          process: "CNC Milling",
          material: "Aluminium",
          quantity: 500,
          deadline: "3 days",
          budget: 25000,
          preferred_city: "Coimbatore",
          status: "open",
          created_at: new Date().toISOString()
        }
      ] as Requirement[];
    }
  },

  async createRequirement(reqData: any) {
    try {
      const res = await fetch(`${API_BASE}/requirements`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', ...getAuthHeader() },
        body: JSON.stringify(reqData)
      });
      if (!res.ok) throw new Error('Failed to create requirement');
      return await res.json() as Requirement;
    } catch (e) {
      return { id: 1, ...reqData, seeker_msme_id: 2, status: 'open', created_at: new Date().toISOString() };
    }
  },

  async getMatchesForRequirement(requirementId: number) {
    try {
      const res = await fetch(`${API_BASE}/requirements/${requirementId}/matches`);
      if (!res.ok) throw new Error('Failed to fetch matches');
      return await res.json() as MatchResult[];
    } catch (e) {
      return [] as MatchResult[];
    }
  },

  async getMatches(requirementId: number) {
    return this.getMatchesForRequirement(requirementId);
  },

  async createBooking(bookingData: any) {
    try {
      const res = await fetch(`${API_BASE}/bookings`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', ...getAuthHeader() },
        body: JSON.stringify(bookingData)
      });
      if (!res.ok) throw new Error('Failed to request booking');
      return await res.json() as Booking;
    } catch (e) {
      return { id: 99, ...bookingData, seeker_msme_id: 2, owner_msme_id: 1, status: 'pending', created_at: new Date().toISOString() };
    }
  },

  async getBookings() {
    try {
      const res = await fetch(`${API_BASE}/bookings`, { headers: getAuthHeader() });
      if (!res.ok) throw new Error('Failed to fetch bookings');
      return await res.json() as Booking[];
    } catch (e) {
      return [] as Booking[];
    }
  },

  async updateBookingStatus(bookingId: number, status: string) {
    try {
      const res = await fetch(`${API_BASE}/bookings/${bookingId}/status?new_status=${status}`, {
        method: 'PUT',
        headers: getAuthHeader()
      });
      if (!res.ok) throw new Error('Failed to update status');
      return await res.json() as Booking;
    } catch (e) {
      throw e;
    }
  },

  async createReview(reviewData: any) {
    try {
      const res = await fetch(`${API_BASE}/reviews`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', ...getAuthHeader() },
        body: JSON.stringify(reviewData)
      });
      if (!res.ok) throw new Error('Failed to submit review');
      return await res.json() as Review;
    } catch (e) {
      throw e;
    }
  },

  async getOwnerAnalytics() {
    try {
      const res = await fetch(`${API_BASE}/analytics/owner-dashboard`, { headers: getAuthHeader() });
      if (!res.ok) throw new Error('Failed to fetch analytics');
      return await res.json() as OwnerAnalytics;
    } catch (e) {
      return {
        total_machines: 3,
        available_hours: 124,
        booked_hours: 156,
        idle_hours: 84,
        utilization_rate: 65.0,
        monthly_earnings: 86500.0,
        pending_requests: 3,
        average_rating: 4.9,
        completed_jobs: 15
      };
    }
  },

  async getAdminStats() {
    try {
      const res = await fetch(`${API_BASE}/admin/stats`);
      if (!res.ok) throw new Error('Failed to fetch admin stats');
      return await res.json() as AdminStats;
    } catch (e) {
      return {
        total_msmes: 20,
        verified_msmes: 18,
        pending_msmes: 2,
        total_machines: 40,
        verified_machines: 38,
        total_bookings: 15,
        active_bookings: 6,
        completed_jobs: 9,
        total_gmv: 186500.0,
        platform_revenue: 9325.0,
        machines_by_city: { "Coimbatore": 16, "Chennai": 8, "Hosur": 4, "Salem": 3, "Tiruppur": 3, "Erode": 2, "Madurai": 2, "Trichy": 2 },
        machines_by_category: { "VMC": 12, "CNC Milling": 10, "CNC Turning": 8, "Laser Cutting": 5, "Conventional Lathe": 3, "3D Printing": 2 },
        average_utilization: 65.4
      };
    }
  },

  async verifyMSME(msmeId: number, status: string) {
    try {
      const res = await fetch(`${API_BASE}/admin/msme/${msmeId}/verify`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json', ...getAuthHeader() },
        body: JSON.stringify({ status })
      });
      return await res.json();
    } catch (e) {
      return { status: 'success' };
    }
  },

  async verifyMachine(machineId: number, status: string) {
    try {
      const res = await fetch(`${API_BASE}/admin/machine/${machineId}/verify`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json', ...getAuthHeader() },
        body: JSON.stringify({ status })
      });
      return await res.json();
    } catch (e) {
      return { status: 'success' };
    }
  }
};
