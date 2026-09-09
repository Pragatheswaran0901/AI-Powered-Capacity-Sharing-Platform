import React, { useEffect, useState } from 'react';
import { api } from '../services/api';
import { AdminStats, MSME, Machine } from '../types';
import {
  Shield,
  Building2,
  Wrench,
  CheckCircle,
  XCircle,
  DollarSign,
  TrendingUp,
  MapPin,
  BarChart3,
  Sparkles,
  ShieldCheck,
  CheckCircle2,
  Activity,
  UserCheck
} from 'lucide-react';

export const AdminDashboard: React.FC = () => {
  const [stats, setStats] = useState<AdminStats | null>(null);
  const [msmes, setMsmes] = useState<MSME[]>([]);
  const [machines, setMachines] = useState<Machine[]>([]);
  const [loading, setLoading] = useState<boolean>(true);

  useEffect(() => {
    loadData();
  }, []);

  async function loadData() {
    setLoading(true);
    const data = await api.getAdminStats();
    setStats(data);
    setLoading(false);
  }

  const handleVerifyMSME = async (id: number, status: string) => {
    await api.verifyMSME(id, status);
    loadData();
  };

  const handleVerifyMachine = async (id: number, status: string) => {
    await api.verifyMachine(id, status);
    loadData();
  };

  return (
    <div className="min-h-screen bg-slate-900 text-slate-100 pb-20 font-sans">
      {/* Top Banner Header */}
      <div className="bg-gradient-to-r from-slate-950 via-slate-900 to-amber-950/60 border-b border-slate-800 py-8 px-4 sm:px-6 lg:px-8">
        <div className="max-w-7xl mx-auto flex flex-col md:flex-row justify-between items-start md:items-center gap-6">
          <div className="space-y-1">
            <div className="flex items-center gap-2">
              <span className="text-[10px] font-black tracking-widest text-amber-400 uppercase bg-amber-500/10 px-3 py-1 rounded-full border border-amber-500/20">
                Super Admin Command Portal
              </span>
              <span className="text-xs text-slate-400 font-mono">Operator: Pragatheswaran</span>
            </div>
            <h1 className="text-2xl sm:text-3xl font-black text-white">Platform Operations & Compliance</h1>
            <p className="text-xs text-slate-400">
              Tamil Nadu MSME Capacity Network Monitoring, Governance & Escrow Clearance
            </p>
          </div>

          <div className="bg-slate-950 p-4 rounded-2xl border border-slate-800 text-right">
            <span className="text-[10px] text-slate-400 uppercase font-bold tracking-wider block">Platform Revenue (5%)</span>
            <span className="text-2xl font-black text-amber-400 font-mono">
              ₹{(stats?.platform_revenue || 9325).toLocaleString('en-IN')}
            </span>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 mt-8 space-y-8">
        
        {/* KPI Overview Cards Grid */}
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
          <div className="bg-slate-950/70 p-5 rounded-2xl border border-slate-800 space-y-1">
            <span className="text-[10px] uppercase font-bold text-slate-400 block">Total MSME Facilities</span>
            <span className="text-3xl font-black text-white font-mono block">
              {stats?.total_msmes || 20}
            </span>
            <span className="text-xs text-emerald-400 font-bold flex items-center gap-1">
              <ShieldCheck className="w-3.5 h-3.5" /> {stats?.verified_msmes || 18} Verified
            </span>
          </div>

          <div className="bg-slate-950/70 p-5 rounded-2xl border border-slate-800 space-y-1">
            <span className="text-[10px] uppercase font-bold text-slate-400 block">Listed Machinery Fleet</span>
            <span className="text-3xl font-black text-blue-400 font-mono block">
              {stats?.total_machines || 40}
            </span>
            <span className="text-xs text-slate-400">Across 8 Industrial Hubs</span>
          </div>

          <div className="bg-slate-950/70 p-5 rounded-2xl border border-slate-800 space-y-1">
            <span className="text-[10px] uppercase font-bold text-slate-400 block">Active Bookings</span>
            <span className="text-3xl font-black text-emerald-400 font-mono block">
              {stats?.active_bookings || 6}
            </span>
            <span className="text-xs text-slate-400">{stats?.completed_jobs || 9} Jobs Completed</span>
          </div>

          <div className="bg-slate-950/70 p-5 rounded-2xl border border-slate-800 space-y-1">
            <span className="text-[10px] uppercase font-bold text-slate-400 block">Escrow GMV Transacted</span>
            <span className="text-3xl font-black text-amber-400 font-mono block">
              ₹{(stats?.total_gmv || 186500).toLocaleString('en-IN')}
            </span>
            <span className="text-xs text-emerald-400 font-bold">100% Escrow Protection</span>
          </div>
        </div>

        {/* Analytics Breakdown Charts */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          
          {/* Machines by City */}
          <div className="bg-slate-950/80 p-6 rounded-3xl border border-slate-800 space-y-4 shadow-xl">
            <div className="flex justify-between items-center border-b border-slate-800 pb-3">
              <h3 className="text-sm font-bold text-white flex items-center gap-2">
                <MapPin className="w-4 h-4 text-blue-400" />
                Machines by Tamil Nadu Cluster
              </h3>
              <span className="text-xs font-mono font-bold text-blue-400 bg-blue-500/10 px-2.5 py-0.5 rounded-full border border-blue-500/20">
                Coimbatore Lead Hub
              </span>
            </div>

            <div className="space-y-3 text-xs">
              {Object.entries(stats?.machines_by_city || { Coimbatore: 16, Chennai: 8, Hosur: 4, Salem: 3, Tiruppur: 3, Erode: 2, Madurai: 2, Trichy: 2 }).map(([city, count]) => {
                const total = stats?.total_machines || 40;
                const pct = Math.round((count / total) * 100);
                return (
                  <div key={city} className="space-y-1">
                    <div className="flex justify-between font-medium text-slate-300">
                      <span>{city}</span>
                      <span className="font-mono font-bold text-white">{count} units ({pct}%)</span>
                    </div>
                    <div className="w-full h-2 bg-slate-900 rounded-full overflow-hidden border border-slate-800">
                      <div className="h-full bg-gradient-to-r from-blue-600 to-indigo-500 rounded-full" style={{ width: `${pct}%` }}></div>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>

          {/* Machines by Category */}
          <div className="bg-slate-950/80 p-6 rounded-3xl border border-slate-800 space-y-4 shadow-xl">
            <div className="flex justify-between items-center border-b border-slate-800 pb-3">
              <h3 className="text-sm font-bold text-white flex items-center gap-2">
                <BarChart3 className="w-4 h-4 text-emerald-400" />
                Process Capacity Breakdown
              </h3>
              <span className="text-xs font-mono font-bold text-emerald-400 bg-emerald-500/10 px-2.5 py-0.5 rounded-full border border-emerald-500/20">
                VMC & Milling Dominant
              </span>
            </div>

            <div className="space-y-3 text-xs">
              {Object.entries(stats?.machines_by_category || { VMC: 12, "CNC Milling": 10, "CNC Turning": 8, "Laser Cutting": 5, "Conventional Lathe": 3, "3D Printing": 2 }).map(([cat, count]) => {
                const total = stats?.total_machines || 40;
                const pct = Math.round((count / total) * 100);
                return (
                  <div key={cat} className="space-y-1">
                    <div className="flex justify-between font-medium text-slate-300">
                      <span>{cat}</span>
                      <span className="font-mono font-bold text-white">{count} units ({pct}%)</span>
                    </div>
                    <div className="w-full h-2 bg-slate-900 rounded-full overflow-hidden border border-slate-800">
                      <div className="h-full bg-gradient-to-r from-emerald-600 to-teal-500 rounded-full" style={{ width: `${pct}%` }}></div>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        </div>

        {/* Pending MSME & Machine Verification Audit Queue */}
        <div className="bg-slate-950/80 p-6 rounded-3xl border border-slate-800 space-y-4 shadow-xl">
          <div className="flex justify-between items-center border-b border-slate-800 pb-4">
            <div>
              <h3 className="text-base font-extrabold text-white">Pending Verification Audit Queue</h3>
              <p className="text-xs text-slate-400">Review MSME facility registration and machine capability compliance</p>
            </div>
            <span className="text-xs font-mono font-bold bg-amber-500/10 text-amber-300 px-3 py-1 rounded-full border border-amber-500/20">
              2 Pending Audits
            </span>
          </div>

          <div className="divide-y divide-slate-800/80 text-xs">
            <div className="py-4 flex flex-col sm:flex-row justify-between items-start sm:items-center gap-3">
              <div>
                <span className="font-bold text-white block text-sm">Avadi Defence Components</span>
                <span className="text-slate-400">High Alloy Steel Turning • Avadi, Tiruvallur, Tamil Nadu</span>
              </div>
              <div className="flex gap-2">
                <button
                  onClick={() => handleVerifyMSME(17, 'verified')}
                  className="px-4 py-2 bg-emerald-600 hover:bg-emerald-500 text-white rounded-xl font-bold transition-all shadow-md shadow-emerald-600/20"
                >
                  ✓ Approve MSME Verification
                </button>
                <button
                  onClick={() => handleVerifyMSME(17, 'rejected')}
                  className="px-4 py-2 bg-slate-800 text-slate-300 hover:bg-slate-700 rounded-xl font-semibold"
                >
                  Reject
                </button>
              </div>
            </div>

            <div className="py-4 flex flex-col sm:flex-row justify-between items-start sm:items-center gap-3">
              <div>
                <span className="font-bold text-white block text-sm">Chennai Additive Tech — EOS M 290 Metal 3D Printer</span>
                <span className="text-slate-400">SLS Metal DMLS • Guindy Industrial Estate, Chennai</span>
              </div>
              <div className="flex gap-2">
                <button
                  onClick={() => handleVerifyMachine(19, 'verified')}
                  className="px-4 py-2 bg-emerald-600 hover:bg-emerald-500 text-white rounded-xl font-bold transition-all shadow-md shadow-emerald-600/20"
                >
                  ✓ Approve Machine Listing
                </button>
                <button
                  onClick={() => handleVerifyMachine(19, 'rejected')}
                  className="px-4 py-2 bg-slate-800 text-slate-300 hover:bg-slate-700 rounded-xl font-semibold"
                >
                  Reject
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

