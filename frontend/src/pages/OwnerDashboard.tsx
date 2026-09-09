import React, { useEffect, useState } from 'react';
import { api } from '../services/api';
import { Machine, Booking, OwnerAnalytics } from '../types';
import {
  Wrench,
  Clock,
  DollarSign,
  Star,
  CheckCircle,
  XCircle,
  PlusCircle,
  ShieldCheck,
  Activity,
  BarChart2,
  Cpu,
  Sparkles,
  CheckCircle2,
  TrendingUp,
  MapPin,
  X
} from 'lucide-react';

export const OwnerDashboard: React.FC = () => {
  const [machines, setMachines] = useState<Machine[]>([]);
  const [bookings, setBookings] = useState<Booking[]>([]);
  const [analytics, setAnalytics] = useState<OwnerAnalytics | null>(null);
  const [loading, setLoading] = useState<boolean>(true);

  // Add Machine modal state
  const [showAddModal, setShowAddModal] = useState<boolean>(false);
  const [newMName, setNewMName] = useState('');
  const [newMType, setNewMType] = useState('VMC');
  const [newRate, setNewRate] = useState(750);
  const [newLocation, setNewLocation] = useState('Ganapathy, Coimbatore');

  useEffect(() => {
    loadData();
  }, []);

  async function loadData() {
    setLoading(true);
    const mList = await api.getMachines({ city: 'Coimbatore' });
    const bList = await api.getBookings();
    const stats = await api.getOwnerAnalytics();

    setMachines(mList.filter(m => m.msme_id === 1 || m.msme_name?.includes('Kovai')));
    setBookings(bList);
    setAnalytics(stats);
    setLoading(false);
  }

  const handleUpdateStatus = async (bookingId: number, newStatus: string) => {
    await api.updateBookingStatus(bookingId, newStatus);
    loadData();
  };

  const handleAddMachine = async (e: React.FormEvent) => {
    e.preventDefault();
    await api.createMachine({
      machine_name: newMName,
      machine_type: newMType,
      manufacturer: 'Doosan',
      model: 'VMC-200',
      hourly_rate: Number(newRate),
      minimum_booking_hours: 2,
      location: newLocation,
      operator_available: true,
      capabilities: [
        { process: newMType, material: 'Aluminium', capacity_description: 'Precision machining' }
      ]
    });
    setShowAddModal(false);
    loadData();
  };

  return (
    <div className="min-h-screen bg-slate-900 text-slate-100 pb-20 font-sans">
      {/* Top Banner Header */}
      <div className="bg-gradient-to-r from-slate-950 via-slate-900 to-emerald-950 border-b border-slate-800 py-8 px-4 sm:px-6 lg:px-8">
        <div className="max-w-7xl mx-auto flex flex-col md:flex-row justify-between items-start md:items-center gap-6">
          <div className="space-y-1">
            <div className="flex items-center gap-2">
              <span className="text-[10px] font-black tracking-widest text-emerald-400 uppercase bg-emerald-500/10 px-3 py-1 rounded-full border border-emerald-500/20">
                Machine Owner Dashboard
              </span>
              <span className="text-xs text-slate-400 flex items-center gap-1 font-semibold">
                <ShieldCheck className="w-3.5 h-3.5 text-emerald-400" /> Verified Facility
              </span>
            </div>
            <h1 className="text-2xl sm:text-3xl font-black text-white">Janika — Kovai Precision Works</h1>
            <p className="text-xs text-slate-400">
              Ganapathy Industrial Cluster, Coimbatore • Facility ID: MSME-TN-641006
            </p>
          </div>

          <button
            onClick={() => setShowAddModal(true)}
            className="px-5 py-3 bg-gradient-to-r from-emerald-600 to-teal-600 hover:from-emerald-500 hover:to-teal-500 text-white font-bold rounded-2xl text-xs flex items-center gap-2 transition-all shadow-lg shadow-emerald-600/25 shrink-0"
          >
            <PlusCircle className="w-4 h-4" />
            List Spare Machine Capacity
          </button>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 mt-8 space-y-8">
        
        {/* KPI Cards Grid */}
        <div className="grid grid-cols-2 lg:grid-cols-5 gap-4">
          <div className="bg-slate-950/70 p-4 rounded-2xl border border-slate-800 space-y-1">
            <span className="text-[10px] uppercase font-bold text-slate-400 block">Facility Machines</span>
            <span className="text-2xl font-black text-white font-mono block">
              {analytics?.total_machines || 3} Units
            </span>
            <span className="text-[10px] text-emerald-400 font-bold flex items-center gap-1">
              <CheckCircle2 className="w-3 h-3" /> 100% Verified
            </span>
          </div>

          <div className="bg-slate-950/70 p-4 rounded-2xl border border-slate-800 space-y-1">
            <span className="text-[10px] uppercase font-bold text-slate-400 block">Available Hours</span>
            <span className="text-2xl font-black text-blue-400 font-mono block">
              {analytics?.available_hours || 124} hrs
            </span>
            <span className="text-[10px] text-slate-400">Next 14 Days</span>
          </div>

          <div className="bg-slate-950/70 p-4 rounded-2xl border border-slate-800 space-y-1">
            <span className="text-[10px] uppercase font-bold text-slate-400 block">Monthly Revenue</span>
            <span className="text-2xl font-black text-emerald-400 font-mono block">
              ₹{(analytics?.monthly_earnings || 86500).toLocaleString('en-IN')}
            </span>
            <span className="text-[10px] text-emerald-400 font-bold">+18% vs last month</span>
          </div>

          <div className="bg-slate-950/70 p-4 rounded-2xl border border-slate-800 space-y-1">
            <span className="text-[10px] uppercase font-bold text-slate-400 block">Utilization Rate</span>
            <span className="text-2xl font-black text-white font-mono block">
              {analytics?.utilization_rate || 65}%
            </span>
            <span className="text-[10px] text-slate-400">156 Booked / 84 Idle</span>
          </div>

          <div className="bg-slate-950/70 p-4 rounded-2xl border border-slate-800 space-y-1">
            <span className="text-[10px] uppercase font-bold text-slate-400 block">Trust Rating</span>
            <span className="text-2xl font-black text-amber-400 font-mono block flex items-center gap-1">
              <Star className="w-5 h-5 fill-amber-400 text-amber-400" />
              {analytics?.average_rating || 4.9}
            </span>
            <span className="text-[10px] text-slate-400">15 Completed Jobs</span>
          </div>
        </div>

        {/* Live IoT Telemetry Monitoring Card */}
        <div className="bg-slate-950/80 p-6 rounded-3xl border border-slate-800 space-y-4 shadow-xl">
          <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-2 border-b border-slate-800 pb-3">
            <div className="flex items-center gap-2">
              <div className="w-3 h-3 bg-emerald-400 rounded-full animate-ping"></div>
              <h3 className="text-base font-extrabold text-white">Facility Telemetry Telematics</h3>
            </div>
            <span className="text-xs text-blue-400 font-mono font-bold bg-blue-500/10 px-3 py-1 rounded-full border border-blue-500/20">
              Live Sensor Bus Connected
            </span>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="bg-slate-900/90 p-4 rounded-2xl border border-slate-800/80 space-y-2">
              <div className="flex justify-between text-xs text-slate-400">
                <span>Haas VMC 3-Axis</span>
                <span className="text-emerald-400 font-bold">RUNNING</span>
              </div>
              <div className="flex justify-between items-end">
                <div>
                  <span className="text-2xl font-black text-white font-mono">8,420</span>
                  <span className="text-xs text-slate-500 font-mono ml-1">RPM</span>
                </div>
                <span className="text-xs text-slate-400">Temp: <strong className="text-amber-400">42°C</strong></span>
              </div>
            </div>

            <div className="bg-slate-900/90 p-4 rounded-2xl border border-slate-800/80 space-y-2">
              <div className="flex justify-between text-xs text-slate-400">
                <span>Mazak CNC Lathe</span>
                <span className="text-blue-400 font-bold">STANDBY</span>
              </div>
              <div className="flex justify-between items-end">
                <div>
                  <span className="text-2xl font-black text-slate-300 font-mono">0</span>
                  <span className="text-xs text-slate-500 font-mono ml-1">RPM</span>
                </div>
                <span className="text-xs text-slate-400">Temp: <strong className="text-emerald-400">28°C</strong></span>
              </div>
            </div>

            <div className="bg-slate-900/90 p-4 rounded-2xl border border-slate-800/80 space-y-2">
              <div className="flex justify-between text-xs text-slate-400">
                <span>Trumpf Fiber Laser</span>
                <span className="text-emerald-400 font-bold">RUNNING</span>
              </div>
              <div className="flex justify-between items-end">
                <div>
                  <span className="text-2xl font-black text-white font-mono">4.2 kW</span>
                  <span className="text-xs text-slate-500 font-mono ml-1">Power</span>
                </div>
                <span className="text-xs text-slate-400">Temp: <strong className="text-emerald-400">34°C</strong></span>
              </div>
            </div>
          </div>
        </div>

        {/* Incoming Capacity Requests Queue */}
        <div className="bg-slate-950/80 p-6 rounded-3xl border border-slate-800 space-y-4 shadow-xl">
          <div className="flex justify-between items-center border-b border-slate-800 pb-4">
            <div>
              <h3 className="text-base font-extrabold text-white">Incoming Capacity Booking Requests</h3>
              <p className="text-xs text-slate-400">Review job orders matched with your Coimbatore facility</p>
            </div>
            <span className="text-xs font-mono font-bold bg-blue-500/10 text-blue-400 px-3 py-1 rounded-full border border-blue-500/20">
              {bookings.length} Requests Total
            </span>
          </div>

          <div className="divide-y divide-slate-800/80">
            {bookings.map((b) => (
              <div key={b.id} className="py-4 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
                <div className="space-y-1">
                  <div className="flex items-center gap-2">
                    <span className="text-sm font-bold text-white">{b.seeker_company_name || 'TamilTech Components'}</span>
                    <span className={`text-[10px] font-bold px-2.5 py-0.5 rounded-full font-mono uppercase ${
                      b.status === 'accepted' || b.status === 'confirmed'
                        ? 'bg-emerald-500/20 text-emerald-300 border border-emerald-500/30'
                        : b.status === 'pending'
                        ? 'bg-amber-500/20 text-amber-300 border border-amber-500/30'
                        : 'bg-slate-800 text-slate-400'
                    }`}>
                      {b.status}
                    </span>
                  </div>
                  <p className="text-xs text-slate-300">
                    Requested <span className="font-bold text-white">{b.machine_name || 'Haas VMC CNC Machine'}</span> for {b.quantity} parts.
                  </p>
                  <div className="flex gap-4 text-xs text-slate-400 font-mono">
                    <span>Schedule: {b.booking_date} ({b.start_time} - {b.end_time})</span>
                    <span>Payout: <strong className="text-emerald-400 font-bold">₹{b.agreed_price.toLocaleString('en-IN')}</strong></span>
                  </div>
                </div>

                <div className="flex items-center gap-2">
                  {b.status === 'pending' ? (
                    <>
                      <button
                        onClick={() => handleUpdateStatus(b.id, 'accepted')}
                        className="px-4 py-2 bg-emerald-600 hover:bg-emerald-500 text-white rounded-xl font-bold text-xs flex items-center gap-1.5 transition-all shadow-md shadow-emerald-600/20"
                      >
                        <CheckCircle className="w-4 h-4" /> Accept Order
                      </button>
                      <button
                        onClick={() => handleUpdateStatus(b.id, 'rejected')}
                        className="px-4 py-2 bg-slate-800 hover:bg-slate-700 text-slate-300 rounded-xl font-semibold text-xs flex items-center gap-1.5 transition-colors"
                      >
                        <XCircle className="w-4 h-4" /> Decline
                      </button>
                    </>
                  ) : (
                    <span className="text-xs font-semibold text-emerald-400 bg-emerald-500/10 px-3.5 py-1.5 rounded-xl border border-emerald-500/20">
                      ● Active Production Order
                    </span>
                  )}
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Registered Fleet Grid */}
        <div className="space-y-4">
          <h3 className="text-base font-extrabold text-white">Your Listed Facility Machinery</h3>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {machines.map((m) => (
              <div key={m.id} className="bg-slate-950/80 p-6 rounded-3xl border border-slate-800 space-y-4 shadow-xl">
                <div className="flex justify-between items-start">
                  <div>
                    <span className="text-[10px] font-bold uppercase text-blue-400 bg-blue-500/10 border border-blue-500/20 px-2.5 py-0.5 rounded-full">
                      {m.machine_type}
                    </span>
                    <h4 className="font-extrabold text-sm text-white mt-2">{m.machine_name}</h4>
                    <p className="text-xs text-slate-400">{m.manufacturer} {m.model}</p>
                  </div>
                  <span className="text-xs font-mono font-black text-emerald-400 bg-slate-900 px-3 py-1.5 rounded-xl border border-slate-800">
                    ₹{m.hourly_rate}/hr
                  </span>
                </div>

                <p className="text-xs text-slate-400 line-clamp-2 leading-relaxed">{m.description}</p>

                <div className="pt-3 border-t border-slate-800/80 flex justify-between items-center text-xs">
                  <span className="text-emerald-400 font-semibold flex items-center gap-1">
                    <CheckCircle className="w-3.5 h-3.5" /> Verified Unit
                  </span>
                  <span className="text-slate-500 font-mono text-[11px]">{m.location}</span>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Add Machine Modal */}
      {showAddModal && (
        <div className="fixed inset-0 z-50 bg-slate-950/80 backdrop-blur-md flex items-center justify-center p-4">
          <div className="bg-slate-900 text-white rounded-3xl max-w-md w-full p-6 sm:p-8 space-y-5 shadow-2xl border border-slate-800">
            <div className="flex justify-between items-center border-b border-slate-800 pb-3">
              <h3 className="text-lg font-black">List New Machine Capacity</h3>
              <button onClick={() => setShowAddModal(false)} className="text-slate-400 hover:text-white">
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleAddMachine} className="space-y-4 text-xs">
              <div className="space-y-1">
                <label className="font-semibold text-slate-300 block">Machine Name / ID</label>
                <input
                  type="text"
                  value={newMName}
                  onChange={(e) => setNewMName(e.target.value)}
                  placeholder="e.g. Mazak VMC 5-Axis Machine"
                  className="w-full p-3 bg-slate-950 border border-slate-800 rounded-xl text-white focus:ring-2 focus:ring-emerald-500 focus:outline-none"
                  required
                />
              </div>

              <div className="space-y-1">
                <label className="font-semibold text-slate-300 block">Machining Process Category</label>
                <select
                  value={newMType}
                  onChange={(e) => setNewMType(e.target.value)}
                  className="w-full p-3 bg-slate-950 border border-slate-800 rounded-xl text-white focus:ring-2 focus:ring-emerald-500 focus:outline-none"
                >
                  <option value="VMC">VMC Vertical Milling</option>
                  <option value="CNC Turning">CNC Turning Center</option>
                  <option value="Laser Cutting">Laser Cutting</option>
                  <option value="Conventional Lathe">Conventional Lathe</option>
                </select>
              </div>

              <div className="space-y-1">
                <label className="font-semibold text-slate-300 block">Hourly Rate (₹ INR)</label>
                <input
                  type="number"
                  value={newRate}
                  onChange={(e) => setNewRate(Number(e.target.value))}
                  className="w-full p-3 bg-slate-950 border border-slate-800 rounded-xl text-white font-mono focus:ring-2 focus:ring-emerald-500 focus:outline-none"
                  required
                />
              </div>

              <div className="space-y-1">
                <label className="font-semibold text-slate-300 block">Location Cluster (TN)</label>
                <input
                  type="text"
                  value={newLocation}
                  onChange={(e) => setNewLocation(e.target.value)}
                  className="w-full p-3 bg-slate-950 border border-slate-800 rounded-xl text-white focus:ring-2 focus:ring-emerald-500 focus:outline-none"
                  required
                />
              </div>

              <div className="flex gap-3 pt-2">
                <button
                  type="button"
                  onClick={() => setShowAddModal(false)}
                  className="flex-1 py-3 bg-slate-800 text-slate-300 font-bold rounded-xl"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="flex-1 py-3 bg-emerald-600 hover:bg-emerald-500 text-white font-bold rounded-xl shadow-lg shadow-emerald-600/25"
                >
                  Publish Capacity
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

