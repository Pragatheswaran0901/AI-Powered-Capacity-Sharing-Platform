import React from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { Wrench, Search, PlusCircle, Calendar, Cpu, TrendingUp, ShieldCheck, CheckCircle2, ArrowRight, Star, Clock, Zap, DollarSign } from 'lucide-react';

export const Dashboard: React.FC = () => {
  const { user } = useAuth();
  const navigate = useNavigate();

  return (
    <div className="min-h-screen bg-slate-900 text-slate-100 pb-20 font-sans">
      {/* Welcome Banner Header */}
      <div className="bg-gradient-to-r from-slate-950 via-slate-900 to-blue-950 border-b border-slate-800 py-10 px-4 sm:px-6 lg:px-8">
        <div className="max-w-7xl mx-auto flex flex-col md:flex-row justify-between items-start md:items-center gap-6">
          <div>
            <div className="inline-flex items-center gap-2 px-3 py-1 bg-emerald-500/10 border border-emerald-500/20 rounded-full text-emerald-400 text-xs font-semibold mb-3">
              <ShieldCheck className="w-3.5 h-3.5" />
              <span>Verified MSME Platform Account</span>
            </div>
            <h1 className="text-3xl font-black text-white">
              Good Morning, {user?.name || 'Pragatheswaran'} 👋
            </h1>
            <p className="text-sm text-slate-400 mt-1 font-medium">
              {user?.company_name || 'Kongu Precision Components'} • Coimbatore Industrial Cluster
            </p>
            <p className="text-xs text-slate-400 mt-0.5">
              Manage your manufacturing capacity and find machines for your next order.
            </p>
          </div>

          <div className="flex items-center gap-3">
            <Link
              to="/machines/add"
              className="px-5 py-3 bg-gradient-to-r from-amber-400 via-amber-500 to-yellow-500 hover:from-amber-300 hover:to-yellow-400 text-slate-950 font-black rounded-2xl text-xs flex items-center gap-2 shadow-lg shadow-amber-500/20 transition-all transform hover:-translate-y-0.5"
            >
              <PlusCircle className="w-4 h-4 stroke-[2.5]" />
              <span>+ LIST CAPACITY</span>
            </Link>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 mt-8 space-y-8">
        
        {/* TWO PRIMARY ACTION CARDS (Provide vs Seek Capacity) */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          
          {/* CARD 1 — PROVIDE MACHINE CAPACITY */}
          <div className="bg-gradient-to-br from-slate-950 via-slate-900 to-amber-950/30 rounded-3xl border border-amber-500/30 p-8 shadow-2xl relative overflow-hidden group hover:border-amber-500/50 transition-all flex flex-col justify-between">
            <div className="absolute top-0 right-0 p-8 text-amber-500/10 group-hover:text-amber-500/20 transition-colors">
              <Wrench className="w-36 h-36 -mr-8 -mt-8" />
            </div>

            <div className="relative z-10 space-y-4">
              <div className="w-12 h-12 bg-amber-500/10 border border-amber-500/20 rounded-2xl flex items-center justify-center text-amber-400 text-2xl">
                🏭
              </div>
              <div>
                <span className="text-xs font-black uppercase tracking-wider text-amber-400 bg-amber-500/10 px-2.5 py-1 rounded-full border border-amber-500/20 font-mono">
                  MODE 1 • Machine Provider
                </span>
                <h2 className="text-2xl font-black text-white mt-2">Provide Machine Capacity</h2>
                <p className="text-xs text-slate-400 mt-2 leading-relaxed font-medium">
                  Have unused machine hours? List your VMC, CNC, Lathe, or Laser machinery and let other MSMEs book your spare capacity to earn additional revenue.
                </p>
              </div>

              <div className="pt-2 flex flex-wrap gap-2 text-[11px] font-mono text-amber-300/80">
                <span className="bg-slate-900/80 border border-slate-800 px-2.5 py-1 rounded-lg">✓ Hourly Rates</span>
                <span className="bg-slate-900/80 border border-slate-800 px-2.5 py-1 rounded-lg">✓ Booking Control</span>
                <span className="bg-slate-900/80 border border-slate-800 px-2.5 py-1 rounded-lg">✓ Escrow Earnings</span>
              </div>
            </div>

            <div className="relative z-10 pt-6 mt-6 border-t border-slate-800/80 flex items-center gap-3">
              <Link
                to="/machines/add"
                className="flex-1 py-3.5 px-4 bg-gradient-to-r from-amber-400 to-yellow-500 hover:from-amber-300 hover:to-yellow-400 text-slate-950 font-extrabold rounded-2xl text-xs flex items-center justify-center gap-2 transition-all shadow-lg shadow-amber-500/20"
              >
                <PlusCircle className="w-4 h-4 stroke-[2.5]" />
                <span>List a Machine</span>
              </Link>
              <Link
                to="/machines"
                className="py-3.5 px-5 bg-slate-900 hover:bg-slate-800 text-slate-200 font-bold rounded-2xl text-xs border border-slate-800 transition-colors"
              >
                My Machines (6)
              </Link>
            </div>
          </div>

          {/* CARD 2 — FIND MACHINE CAPACITY */}
          <div className="bg-gradient-to-br from-slate-950 via-slate-900 to-blue-950/40 rounded-3xl border border-blue-500/30 p-8 shadow-2xl relative overflow-hidden group hover:border-blue-500/50 transition-all flex flex-col justify-between">
            <div className="absolute top-0 right-0 p-8 text-blue-500/10 group-hover:text-blue-500/20 transition-colors">
              <Search className="w-36 h-36 -mr-8 -mt-8" />
            </div>

            <div className="relative z-10 space-y-4">
              <div className="w-12 h-12 bg-blue-500/10 border border-blue-500/20 rounded-2xl flex items-center justify-center text-blue-400 text-2xl">
                🔍
              </div>
              <div>
                <span className="text-xs font-black uppercase tracking-wider text-blue-400 bg-blue-500/10 px-2.5 py-1 rounded-full border border-blue-500/20 font-mono">
                  MODE 2 • Machine Seeker
                </span>
                <h2 className="text-2xl font-black text-white mt-2">Find Machine Capacity</h2>
                <p className="text-xs text-slate-400 mt-2 leading-relaxed font-medium">
                  Need manufacturing capacity for sudden order spikes? Search verified machines available near you in Tamil Nadu with Smart AI Capacity Matching.
                </p>
              </div>

              <div className="pt-2 flex flex-wrap gap-2 text-[11px] font-mono text-blue-300/80">
                <span className="bg-slate-900/80 border border-slate-800 px-2.5 py-1 rounded-lg">✓ Smart Match (95%)</span>
                <span className="bg-slate-900/80 border border-slate-800 px-2.5 py-1 rounded-lg">✓ Near Distance</span>
                <span className="bg-slate-900/80 border border-slate-800 px-2.5 py-1 rounded-lg">✓ Guaranteed Quality</span>
              </div>
            </div>

            <div className="relative z-10 pt-6 mt-6 border-t border-slate-800/80 flex items-center gap-3">
              <Link
                to="/find-capacity"
                className="flex-1 py-3.5 px-4 bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-500 hover:to-indigo-500 text-white font-extrabold rounded-2xl text-xs flex items-center justify-center gap-2 transition-all shadow-lg shadow-blue-600/20"
              >
                <Search className="w-4 h-4" />
                <span>Find a Machine</span>
              </Link>
              <Link
                to="/requirements/new"
                className="py-3.5 px-5 bg-slate-900 hover:bg-slate-800 text-slate-200 font-bold rounded-2xl text-xs border border-slate-800 transition-colors"
              >
                Post Requirement
              </Link>
            </div>
          </div>

        </div>

        {/* DASHBOARD KPIS (6 Core MSME Metrics) */}
        <div>
          <h3 className="text-xs font-black uppercase tracking-wider text-slate-400 mb-4 font-mono">
            MSME Capacity Metrics Overview
          </h3>
          
          <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-4">
            
            {/* KPI 1 */}
            <div className="bg-slate-950/80 p-5 rounded-2xl border border-slate-800 hover:border-slate-700 transition-all">
              <div className="w-8 h-8 bg-amber-500/10 rounded-xl flex items-center justify-center text-amber-400 mb-2 border border-amber-500/20">
                <Wrench className="w-4 h-4" />
              </div>
              <span className="text-[10px] text-slate-400 uppercase font-semibold block">My Machines</span>
              <span className="text-xl font-black text-white font-mono mt-0.5 block">6 Units</span>
            </div>

            {/* KPI 2 */}
            <div className="bg-slate-950/80 p-5 rounded-2xl border border-slate-800 hover:border-slate-700 transition-all">
              <div className="w-8 h-8 bg-blue-500/10 rounded-xl flex items-center justify-center text-blue-400 mb-2 border border-blue-500/20">
                <Clock className="w-4 h-4" />
              </div>
              <span className="text-[10px] text-slate-400 uppercase font-semibold block">Available Hours</span>
              <span className="text-xl font-black text-white font-mono mt-0.5 block">124 hrs</span>
            </div>

            {/* KPI 3 */}
            <div className="bg-slate-950/80 p-5 rounded-2xl border border-slate-800 hover:border-slate-700 transition-all">
              <div className="w-8 h-8 bg-purple-500/10 rounded-xl flex items-center justify-center text-purple-400 mb-2 border border-purple-500/20">
                <Search className="w-4 h-4" />
              </div>
              <span className="text-[10px] text-slate-400 uppercase font-semibold block">Active Requirements</span>
              <span className="text-xl font-black text-white font-mono mt-0.5 block">3 Jobs</span>
            </div>

            {/* KPI 4 */}
            <div className="bg-slate-950/80 p-5 rounded-2xl border border-slate-800 hover:border-slate-700 transition-all">
              <div className="w-8 h-8 bg-emerald-500/10 rounded-xl flex items-center justify-center text-emerald-400 mb-2 border border-emerald-500/20">
                <Calendar className="w-4 h-4" />
              </div>
              <span className="text-[10px] text-slate-400 uppercase font-semibold block">Active Bookings</span>
              <span className="text-xl font-black text-white font-mono mt-0.5 block">5 Orders</span>
            </div>

            {/* KPI 5 */}
            <div className="bg-slate-950/80 p-5 rounded-2xl border border-slate-800 hover:border-slate-700 transition-all">
              <div className="w-8 h-8 bg-emerald-500/10 rounded-xl flex items-center justify-center text-emerald-400 mb-2 border border-emerald-500/20">
                <DollarSign className="w-4 h-4" />
              </div>
              <span className="text-[10px] text-slate-400 uppercase font-semibold block">Monthly Earnings</span>
              <span className="text-xl font-black text-emerald-400 font-mono mt-0.5 block">₹86,500</span>
            </div>

            {/* KPI 6 */}
            <div className="bg-slate-950/80 p-5 rounded-2xl border border-slate-800 hover:border-slate-700 transition-all">
              <div className="w-8 h-8 bg-cyan-500/10 rounded-xl flex items-center justify-center text-cyan-400 mb-2 border border-cyan-500/20">
                <TrendingUp className="w-4 h-4" />
              </div>
              <span className="text-[10px] text-slate-400 uppercase font-semibold block">Utilization Rate</span>
              <span className="text-xl font-black text-cyan-400 font-mono mt-0.5 block">68%</span>
            </div>

          </div>
        </div>

        {/* RECENT ACTIVITY & QUICK MANAGE FLEET */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          
          {/* Active Capacity Fleet Summary */}
          <div className="lg:col-span-2 bg-slate-950/80 rounded-3xl border border-slate-800 p-6 space-y-4">
            <div className="flex justify-between items-center pb-3 border-b border-slate-800">
              <div>
                <h3 className="text-base font-black text-white">Kongu Precision Fleet Status</h3>
                <p className="text-xs text-slate-400">Available machines currently listed on Mach-Hunt</p>
              </div>
              <Link to="/machines" className="text-xs font-bold text-blue-400 hover:underline flex items-center gap-1">
                <span>View All 6 Machines</span>
                <ArrowRight className="w-3.5 h-3.5" />
              </Link>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              {/* Machine 1 */}
              <div className="p-4 bg-slate-900/90 rounded-2xl border border-slate-800 space-y-2">
                <div className="flex justify-between items-start">
                  <span className="text-[10px] font-bold uppercase tracking-wider text-amber-400 bg-amber-500/10 border border-amber-500/20 px-2 py-0.5 rounded-full font-mono">
                    VMC
                  </span>
                  <span className="text-xs font-mono font-bold text-emerald-400">₹750 / hr</span>
                </div>
                <h4 className="text-sm font-extrabold text-white">Haas VMC Milling Center</h4>
                <p className="text-[11px] text-slate-400">6061 Aluminium • SS 304 • Tolerances ±0.005mm</p>
                <div className="pt-2 flex items-center justify-between text-[11px] border-t border-slate-800/80">
                  <span className="text-emerald-400 font-medium">✓ Available Today</span>
                  <span className="text-slate-400 font-mono">68% Utilization</span>
                </div>
              </div>

              {/* Machine 2 */}
              <div className="p-4 bg-slate-900/90 rounded-2xl border border-slate-800 space-y-2">
                <div className="flex justify-between items-start">
                  <span className="text-[10px] font-bold uppercase tracking-wider text-blue-400 bg-blue-500/10 border border-blue-500/20 px-2 py-0.5 rounded-full font-mono">
                    CNC Turning
                  </span>
                  <span className="text-xs font-mono font-bold text-emerald-400">₹680 / hr</span>
                </div>
                <h4 className="text-sm font-extrabold text-white">Doosan CNC Turning Lathe</h4>
                <p className="text-[11px] text-slate-400">Brass • Stainless Steel • Shafts & Bushes</p>
                <div className="pt-2 flex items-center justify-between text-[11px] border-t border-slate-800/80">
                  <span className="text-amber-400 font-medium">● Booked (2 hrs left)</span>
                  <span className="text-slate-400 font-mono">82% Utilization</span>
                </div>
              </div>
            </div>
          </div>

          {/* Quick Active Bookings Tracker */}
          <div className="bg-slate-950/80 rounded-3xl border border-slate-800 p-6 space-y-4">
            <div className="flex justify-between items-center pb-3 border-b border-slate-800">
              <h3 className="text-base font-black text-white">Bookings Overview</h3>
              <Link to="/bookings" className="text-xs font-bold text-blue-400 hover:underline">
                View All (5)
              </Link>
            </div>

            <div className="space-y-3 text-xs">
              <div className="p-3 bg-slate-900 rounded-xl border border-slate-800 space-y-1">
                <div className="flex justify-between items-center">
                  <span className="font-bold text-white">500 Aluminium Brackets</span>
                  <span className="text-[10px] font-bold text-amber-400 bg-amber-500/10 px-2 py-0.5 rounded-full">Inbound Rental</span>
                </div>
                <p className="text-slate-400 text-[11px]">From Kovai Precision Works • Haas VMC</p>
                <span className="text-[10px] text-emerald-400 font-mono block">Status: Manufacturing In Progress</span>
              </div>

              <div className="p-3 bg-slate-900 rounded-xl border border-slate-800 space-y-1">
                <div className="flex justify-between items-center">
                  <span className="font-bold text-white">200 SS Shafts</span>
                  <span className="text-[10px] font-bold text-blue-400 bg-blue-500/10 px-2 py-0.5 rounded-full">Outbound Rental</span>
                </div>
                <p className="text-slate-400 text-[11px]">To TamilTech Components • Doosan Lathe</p>
                <span className="text-[10px] text-blue-400 font-mono block">Status: Owner Accepted</span>
              </div>
            </div>
          </div>

        </div>

      </div>
    </div>
  );
};
