import React, { useEffect, useState } from 'react';
import { api } from '../services/api';
import { OwnerAnalytics } from '../types';
import { BarChart3, Clock, DollarSign, Activity, PieChart, TrendingUp, CheckCircle2 } from 'lucide-react';

export const AnalyticsPage: React.FC = () => {
  const [stats, setStats] = useState<OwnerAnalytics | null>(null);

  useEffect(() => {
    async function loadStats() {
      const res = await api.getOwnerAnalytics();
      setStats(res);
    }
    loadStats();
  }, []);

  return (
    <div className="min-h-screen bg-slate-50 pb-16">
      <div className="bg-slate-900 text-white py-8 border-b border-slate-800">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <h1 className="text-2xl font-extrabold">Capacity Utilization & Revenue Analytics</h1>
          <p className="text-xs text-slate-300 mt-1">Machine activity monitoring, idle hours, and earnings performance for Kovai Precision Works.</p>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 mt-8 space-y-8">
        {/* KPI Cards */}
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
          <div className="bg-white p-5 rounded-xl border border-slate-200 shadow-2xs">
            <span className="text-[10px] uppercase font-bold text-slate-400 block">Total Capacity</span>
            <span className="text-3xl font-black text-slate-900 font-mono mt-1 block">240 hrs</span>
            <span className="text-xs text-slate-500">Monthly Operating Target</span>
          </div>

          <div className="bg-white p-5 rounded-xl border border-slate-200 shadow-2xs">
            <span className="text-[10px] uppercase font-bold text-blue-600 block">Booked Capacity</span>
            <span className="text-3xl font-black text-blue-600 font-mono mt-1 block">
              {stats?.booked_hours || 156} hrs
            </span>
            <span className="text-xs text-emerald-600 font-semibold">65% Utilization Rate</span>
          </div>

          <div className="bg-white p-5 rounded-xl border border-slate-200 shadow-2xs">
            <span className="text-[10px] uppercase font-bold text-amber-600 block">Unmonetized Idle Hours</span>
            <span className="text-3xl font-black text-amber-600 font-mono mt-1 block">
              {stats?.idle_hours || 84} hrs
            </span>
            <span className="text-xs text-slate-500">Available for Seeker Match</span>
          </div>

          <div className="bg-white p-5 rounded-xl border border-slate-200 shadow-2xs">
            <span className="text-[10px] uppercase font-bold text-emerald-700 block">Gross Capacity Earnings</span>
            <span className="text-3xl font-black text-emerald-700 font-mono mt-1 block">
              ₹{(stats?.monthly_earnings || 86500).toLocaleString('en-IN')}
            </span>
            <span className="text-xs text-emerald-600 font-semibold">+18% MoM Growth</span>
          </div>
        </div>

        {/* Machine Breakdown */}
        <div className="bg-white p-6 rounded-xl border border-slate-200 shadow-xs space-y-4">
          <div className="flex justify-between items-center border-b border-slate-100 pb-3">
            <h3 className="text-base font-bold text-slate-900">Machine-by-Machine Utilization Breakdown</h3>
            <span className="text-xs font-mono font-bold text-blue-700 bg-blue-50 px-2.5 py-1 rounded">
              Haas VMC Lead Producer
            </span>
          </div>

          <div className="space-y-4 text-xs">
            {/* Haas VMC */}
            <div className="space-y-1">
              <div className="flex justify-between font-bold text-slate-900">
                <span>Haas VMC CNC Milling Machine (VMC-01)</span>
                <span className="font-mono text-emerald-700">72% Utilized (172 hrs booked / 68 hrs idle)</span>
              </div>
              <div className="w-full h-3 bg-slate-100 rounded-full overflow-hidden flex">
                <div className="h-full bg-emerald-500 rounded-l-full" style={{ width: '72%' }}></div>
                <div className="h-full bg-amber-200 rounded-r-full" style={{ width: '28%' }}></div>
              </div>
              <p className="text-[11px] text-slate-500">Monthly Revenue: ₹54,000 • 9 Completed Jobs</p>
            </div>

            {/* Doosan CNC Turning */}
            <div className="space-y-1">
              <div className="flex justify-between font-bold text-slate-900">
                <span>Doosan CNC Turning Center (Lynx 220)</span>
                <span className="font-mono text-blue-700">58% Utilized (139 hrs booked / 101 hrs idle)</span>
              </div>
              <div className="w-full h-3 bg-slate-100 rounded-full overflow-hidden flex">
                <div className="h-full bg-blue-500 rounded-l-full" style={{ width: '58%' }}></div>
                <div className="h-full bg-amber-200 rounded-r-full" style={{ width: '42%' }}></div>
              </div>
              <p className="text-[11px] text-slate-500">Monthly Revenue: ₹32,500 • 6 Completed Jobs</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
