import React, { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { api } from '../services/api';
import { Requirement } from '../types';
import { Search, PlusCircle, Calendar, Sparkles, CheckCircle2, Clock, MapPin } from 'lucide-react';

export const MyRequirementsPage: React.FC = () => {
  const navigate = useNavigate();
  const [requirements, setRequirements] = useState<Requirement[]>([]);
  const [loading, setLoading] = useState<boolean>(true);

  useEffect(() => {
    async function loadRequirements() {
      const data = await api.getRequirements();
      setRequirements(data);
      setLoading(false);
    }
    loadRequirements();
  }, []);

  return (
    <div className="min-h-screen bg-slate-900 text-slate-100 pb-20 font-sans">
      {/* Header */}
      <div className="bg-gradient-to-r from-slate-950 via-slate-900 to-purple-950/40 border-b border-slate-800 py-8 px-4 sm:px-6 lg:px-8">
        <div className="max-w-7xl mx-auto flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
          <div>
            <div className="inline-flex items-center gap-2 px-3 py-1 bg-purple-500/10 border border-purple-500/20 rounded-full text-purple-400 text-xs font-semibold mb-2">
              <Search className="w-3.5 h-3.5" />
              <span>Machine Seeker Portal</span>
            </div>
            <h1 className="text-3xl font-black text-white">My Requirements</h1>
            <p className="text-xs text-slate-400 mt-1">
              Track active manufacturing job posts and matched capacity recommendations.
            </p>
          </div>

          <Link
            to="/requirements/new"
            className="px-5 py-3 bg-blue-600 hover:bg-blue-500 text-white font-bold rounded-2xl text-xs flex items-center gap-2 shadow-lg shadow-blue-600/25 transition-all shrink-0"
          >
            <PlusCircle className="w-4 h-4" />
            <span>Post New Requirement</span>
          </Link>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 mt-8">
        {loading ? (
          <div className="text-center py-20 text-slate-400">Loading requirements...</div>
        ) : requirements.length === 0 ? (
          <div className="text-center py-20 bg-slate-950/40 rounded-3xl border border-slate-800 space-y-3">
            <Search className="w-12 h-12 text-slate-600 mx-auto" />
            <h3 className="text-base font-bold text-white">No Requirements Posted</h3>
            <p className="text-xs text-slate-400">Post your manufacturing job to get smart AI capacity matches.</p>
          </div>
        ) : (
          <div className="space-y-4">
            {requirements.map((req) => (
              <div
                key={req.id}
                className="bg-slate-950/80 rounded-3xl border border-slate-800 hover:border-slate-700 p-6 transition-all flex flex-col md:flex-row justify-between items-start md:items-center gap-4 shadow-xl"
              >
                <div className="space-y-2">
                  <div className="flex flex-wrap items-center gap-2">
                    <span className="text-[10px] font-black uppercase tracking-wider text-purple-400 bg-purple-500/10 border border-purple-500/20 px-2.5 py-0.5 rounded-full font-mono">
                      {req.process}
                    </span>
                    <span className="text-[10px] font-bold text-slate-300 bg-slate-800 px-2.5 py-0.5 rounded-full border border-slate-700 font-mono">
                      {req.material}
                    </span>
                    <span className="text-[10px] font-bold text-emerald-400 bg-emerald-500/10 px-2.5 py-0.5 rounded-full border border-emerald-500/20">
                      ✓ 3 Matches Found
                    </span>
                  </div>

                  <h3 className="text-lg font-black text-white">{req.title}</h3>
                  <p className="text-xs text-slate-400 leading-relaxed max-w-2xl">{req.description}</p>

                  <div className="flex flex-wrap items-center gap-4 text-xs font-mono text-slate-400 pt-1">
                    <span>Batch: <strong className="text-white">{req.quantity} Nos</strong></span>
                    <span>Deadline: <strong className="text-white">{req.deadline}</strong></span>
                    <span>Location: <strong className="text-white">{req.preferred_city}</strong></span>
                  </div>
                </div>

                <div className="flex flex-col sm:flex-row items-stretch sm:items-center gap-3 w-full md:w-auto shrink-0 pt-4 md:pt-0 border-t md:border-t-0 border-slate-800">
                  <div className="text-right hidden md:block mr-2">
                    <span className="text-[10px] text-slate-400 uppercase font-semibold block">Target Budget</span>
                    <span className="text-lg font-black text-emerald-400 font-mono">₹{req.budget ? req.budget.toLocaleString('en-IN') : '25,000'}</span>
                  </div>

                  <button
                    onClick={() => navigate('/find-capacity')}
                    className="px-4 py-2.5 bg-blue-600 hover:bg-blue-500 text-white font-bold rounded-xl text-xs flex items-center justify-center gap-1.5 transition-all shadow-md"
                  >
                    <Sparkles className="w-3.5 h-3.5" />
                    <span>View Matches</span>
                  </button>

                  <button
                    onClick={() => alert(`Edit ${req.title}`)}
                    className="px-3 py-2.5 bg-slate-900 hover:bg-slate-800 text-slate-300 rounded-xl text-xs font-bold border border-slate-800 transition-colors"
                  >
                    Edit
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};
