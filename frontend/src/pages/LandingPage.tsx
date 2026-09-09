import React from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { Search, Wrench, ShieldCheck, Zap, ArrowRight, CheckCircle2, Building2, MapPin, Sparkles, Cpu, BarChart2 } from 'lucide-react';

export const LandingPage: React.FC = () => {
  const { switchDemoUser } = useAuth();
  const navigate = useNavigate();

  const handleLaunchSeekerDemo = () => {
    switchDemoUser('machine_seeker');
    navigate('/seeker-dashboard');
  };

  const handleLaunchOwnerDemo = () => {
    switchDemoUser('machine_owner');
    navigate('/owner-dashboard');
  };

  return (
    <div className="min-h-screen bg-slate-50 text-slate-900">
      {/* Hero Section */}
      <section className="relative bg-slate-900 text-white pt-16 pb-24 overflow-hidden border-b border-slate-800">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
          <div className="max-w-3xl space-y-6">
            <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-blue-500/10 border border-blue-500/30 text-blue-400 text-xs font-semibold">
              <Sparkles className="w-3.5 h-3.5" />
              <span>Manufacturing Capacity-as-a-Service • Tamil Nadu, India</span>
            </div>

            <h1 className="text-4xl sm:text-5xl font-black tracking-tight leading-tight text-white">
              Turn Idle Machines into <span className="text-blue-500">Manufacturing Opportunities</span>
            </h1>

            <p className="text-base sm:text-lg text-slate-300 leading-relaxed font-normal">
              Mach-Hunt connects MSMEs with verified manufacturing capacity nearby—helping machine owners monetize idle hours and seekers fulfill urgent orders without unnecessary capital investment.
            </p>

            {/* Main Action Buttons */}
            <div className="flex flex-wrap gap-4 pt-2">
              <button
                onClick={handleLaunchSeekerDemo}
                className="px-6 py-3 bg-blue-600 hover:bg-blue-500 text-white rounded-lg font-bold text-sm flex items-center gap-2 transition-all shadow-lg hover:shadow-blue-600/20"
              >
                <Search className="w-4 h-4" />
                Find Manufacturing Capacity
              </button>

              <button
                onClick={handleLaunchOwnerDemo}
                className="px-6 py-3 bg-slate-800 hover:bg-slate-700 text-white border border-slate-700 rounded-lg font-bold text-sm flex items-center gap-2 transition-all"
              >
                <Wrench className="w-4 h-4 text-emerald-400" />
                Monetize Idle Machine Hours
              </button>
            </div>

            {/* Quick Demo Accounts Banner */}
            <div className="bg-slate-800/80 border border-slate-700 p-4 rounded-xl text-xs space-y-2 mt-6">
              <span className="font-bold text-slate-200 block">Try Evaluator Demo Flows:</span>
              <div className="flex flex-wrap gap-2 text-slate-300">
                <button onClick={handleLaunchSeekerDemo} className="bg-blue-950 hover:bg-blue-900 border border-blue-800 px-3 py-1.5 rounded font-mono text-blue-300">
                  Seeker Demo: Karthikeyan (500 Aluminium Parts)
                </button>
                <button onClick={handleLaunchOwnerDemo} className="bg-emerald-950 hover:bg-emerald-900 border border-emerald-800 px-3 py-1.5 rounded font-mono text-emerald-300">
                  Owner Demo: Janika (Kovai Precision Works)
                </button>
              </div>
            </div>
          </div>
        </div>

        {/* Decorative Grid Background */}
        <div className="absolute inset-0 opacity-15 bg-[radial-gradient(#3b82f6_1px,transparent_1px)] [background-size:24px_24px] pointer-events-none"></div>
      </section>

      {/* Problem & Solution Dual Column Section */}
      <section className="py-16 bg-white border-b border-slate-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center max-w-2xl mx-auto mb-12">
            <h2 className="text-2xl font-extrabold text-slate-900">Why Tamil Nadu MSMEs Need Mach-Hunt</h2>
            <p className="text-xs text-slate-500 mt-1">Bridging the gap between capacity deficit and unutilized machinery in industrial clusters.</p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
            {/* For Owners */}
            <div className="bg-slate-50 rounded-2xl p-8 border border-slate-200 space-y-4">
              <div className="w-12 h-12 bg-emerald-100 text-emerald-700 rounded-xl flex items-center justify-center">
                <Wrench className="w-6 h-6" />
              </div>
              <h3 className="text-lg font-bold text-slate-900">For Machine Owners / Providers</h3>
              <p className="text-xs text-slate-600 leading-relaxed">
                An MSME owns a CNC, VMC, lathe, laser cutting or welding machine but has unused capacity.
              </p>
              <blockquote className="bg-emerald-50 border-l-4 border-emerald-500 p-3 rounded text-xs text-emerald-900 italic">
                “My CNC machine is available for 8 hours/day for the next 10 days.”
              </blockquote>
              <ul className="space-y-2 text-xs text-slate-700 font-medium">
                <li className="flex items-center gap-2">
                  <CheckCircle2 className="w-4 h-4 text-emerald-600" />
                  Monetize idle hours & increase machine ROI
                </li>
                <li className="flex items-center gap-2">
                  <CheckCircle2 className="w-4 h-4 text-emerald-600" />
                  Set flexible hourly rates and shift availability
                </li>
                <li className="flex items-center gap-2">
                  <CheckCircle2 className="w-4 h-4 text-emerald-600" />
                  Direct verified payments upon job completion
                </li>
              </ul>
            </div>

            {/* For Seekers */}
            <div className="bg-slate-50 rounded-2xl p-8 border border-slate-200 space-y-4">
              <div className="w-12 h-12 bg-blue-100 text-blue-700 rounded-xl flex items-center justify-center">
                <Search className="w-6 h-6" />
              </div>
              <h3 className="text-lg font-bold text-slate-900">For Machine Seekers</h3>
              <p className="text-xs text-slate-600 leading-relaxed">
                An MSME has a manufacturing requirement but lacks sufficient machinery or capacity.
              </p>
              <blockquote className="bg-blue-50 border-l-4 border-blue-500 p-3 rounded text-xs text-blue-900 italic">
                “I need 500 aluminium components manufactured within 3 days in Coimbatore.”
              </blockquote>
              <ul className="space-y-2 text-xs text-slate-700 font-medium">
                <li className="flex items-center gap-2">
                  <CheckCircle2 className="w-4 h-4 text-blue-600" />
                  Access nearby capacity without Capex expansion
                </li>
                <li className="flex items-center gap-2">
                  <CheckCircle2 className="w-4 h-4 text-blue-600" />
                  Smart transparent matching score (Capability, Distance, Cost)
                </li>
                <li className="flex items-center gap-2">
                  <CheckCircle2 className="w-4 h-4 text-blue-600" />
                  Side-by-side machine comparison tool
                </li>
              </ul>
            </div>
          </div>
        </div>
      </section>

      {/* Core Concept: Discovery + Matching + Booking Platform */}
      <section className="py-16 bg-slate-900 text-white border-b border-slate-800">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center max-w-3xl mx-auto mb-12">
            <span className="text-xs font-bold uppercase tracking-widest text-blue-400 block mb-1">Core Platform Philosophy</span>
            <h2 className="text-2xl sm:text-3xl font-extrabold">Find the Right Manufacturing Capacity, Not Just the Right Machine</h2>
            <p className="text-xs text-slate-400 mt-2">Mach-Hunt is a Capacity Discovery + Matching + Booking Engine for Tamil Nadu's industrial ecosystem.</p>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-6">
            <div className="bg-slate-800 p-6 rounded-xl border border-slate-700 space-y-2">
              <span className="text-blue-400 font-mono font-bold text-sm">01. DISCOVER</span>
              <h4 className="font-bold text-white text-base">Capacity Requirement</h4>
              <p className="text-xs text-slate-400">Seeker posts job spec or types natural language prompt.</p>
            </div>

            <div className="bg-slate-800 p-6 rounded-xl border border-slate-700 space-y-2">
              <span className="text-blue-400 font-mono font-bold text-sm">02. MATCH</span>
              <h4 className="font-bold text-white text-base">Weighted Engine</h4>
              <p className="text-xs text-slate-400">Score based on Capability (40%), Distance, Cost & Reliability.</p>
            </div>

            <div className="bg-slate-800 p-6 rounded-xl border border-slate-700 space-y-2">
              <span className="text-blue-400 font-mono font-bold text-sm">03. COMPARE</span>
              <h4 className="font-bold text-white text-base">Side-by-Side Tool</h4>
              <p className="text-xs text-slate-400">Compare rates, location distance, ratings, and operator status.</p>
            </div>

            <div className="bg-slate-800 p-6 rounded-xl border border-slate-700 space-y-2">
              <span className="text-blue-400 font-mono font-bold text-sm">04. BOOK</span>
              <h4 className="font-bold text-white text-base">Capacity Booking</h4>
              <p className="text-xs text-slate-400">Owner accepts job, escrow holds funds, and job completes.</p>
            </div>
          </div>
        </div>
      </section>

      {/* Target Region: Tamil Nadu Industrial Clusters */}
      <section className="py-16 bg-slate-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex flex-col md:flex-row justify-between items-start md:items-end mb-10 gap-4">
            <div>
              <span className="text-xs font-bold uppercase tracking-wider text-blue-600">Regional Pilot</span>
              <h2 className="text-2xl font-extrabold text-slate-900">Tamil Nadu Industrial Hubs</h2>
              <p className="text-xs text-slate-500 mt-1">Pre-seeded with 20 MSMEs and 40+ machines across key manufacturing centers.</p>
            </div>
            <div className="flex gap-2">
              <span className="px-3 py-1 bg-blue-100 text-blue-800 rounded-full text-xs font-bold">Coimbatore (Primary Pilot)</span>
              <span className="px-3 py-1 bg-slate-200 text-slate-700 rounded-full text-xs font-semibold">Chennai</span>
              <span className="px-3 py-1 bg-slate-200 text-slate-700 rounded-full text-xs font-semibold">Hosur</span>
              <span className="px-3 py-1 bg-slate-200 text-slate-700 rounded-full text-xs font-semibold">Salem</span>
            </div>
          </div>

          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-5 gap-4 text-center">
            {['Coimbatore', 'Chennai', 'Hosur', 'Salem', 'Tiruppur', 'Erode', 'Madurai', 'Trichy', 'Sriperumbudur', 'Karur'].map((city, idx) => (
              <div key={idx} className="bg-white p-4 rounded-xl border border-slate-200 shadow-2xs hover:shadow-xs transition-all">
                <MapPin className="w-5 h-5 text-blue-600 mx-auto mb-1" />
                <h4 className="font-bold text-xs text-slate-800">{city}</h4>
                <span className="text-[10px] text-slate-400">Manufacturing Cluster</span>
              </div>
            ))}
          </div>
        </div>
      </section>
    </div>
  );
};
