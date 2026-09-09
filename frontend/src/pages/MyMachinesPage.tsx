import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { api } from '../services/api';
import { Machine } from '../types';
import { Wrench, PlusCircle, ShieldCheck, Star, MapPin, Clock, CheckCircle2, Edit, Calendar, Eye } from 'lucide-react';

export const MyMachinesPage: React.FC = () => {
  const [machines, setMachines] = useState<Machine[]>([]);
  const [loading, setLoading] = useState<boolean>(true);

  useEffect(() => {
    async function loadMachines() {
      const data = await api.getMachines();
      setMachines(data);
      setLoading(false);
    }
    loadMachines();
  }, []);

  return (
    <div className="min-h-screen bg-slate-900 text-slate-100 pb-20 font-sans">
      {/* Header Banner */}
      <div className="bg-gradient-to-r from-slate-950 via-slate-900 to-amber-950/40 border-b border-slate-800 py-8 px-4 sm:px-6 lg:px-8">
        <div className="max-w-7xl mx-auto flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
          <div>
            <div className="inline-flex items-center gap-2 px-3 py-1 bg-amber-500/10 border border-amber-500/20 rounded-full text-amber-400 text-xs font-semibold mb-2">
              <Wrench className="w-3.5 h-3.5" />
              <span>Machine Provider Portal</span>
            </div>
            <h1 className="text-3xl font-black text-white">My Listed Machines</h1>
            <p className="text-xs text-slate-400 mt-1">
              Manage the manufacturing capacity you provide to other MSMEs across Tamil Nadu.
            </p>
          </div>

          <Link
            to="/machines/add"
            className="px-5 py-3 bg-gradient-to-r from-amber-400 via-amber-500 to-yellow-500 hover:from-amber-300 hover:to-yellow-400 text-slate-950 font-black rounded-2xl text-xs flex items-center gap-2 shadow-lg shadow-amber-500/20 transition-all shrink-0"
          >
            <PlusCircle className="w-4 h-4 stroke-[2.5]" />
            <span>+ List New Machine</span>
          </Link>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 mt-8">
        
        {/* Machine Listings Grid */}
        {loading ? (
          <div className="text-center py-20 text-slate-400">Loading listed machinery...</div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {machines.map((machine) => (
              <div
                key={machine.id}
                className="bg-slate-950/80 rounded-3xl border border-slate-800 hover:border-amber-500/40 transition-all shadow-xl overflow-hidden flex flex-col justify-between group"
              >
                <div>
                  {/* Card Top */}
                  <div className="p-6 border-b border-slate-800/80 space-y-3">
                    <div className="flex justify-between items-start gap-2">
                      <span className="text-[10px] font-black uppercase tracking-wider text-amber-400 bg-amber-500/10 border border-amber-500/20 px-2.5 py-0.5 rounded-full font-mono">
                        {machine.machine_type}
                      </span>

                      {machine.verification_status === 'verified' && (
                        <span className="inline-flex items-center gap-1 text-[10px] font-bold text-emerald-400 bg-emerald-500/10 border border-emerald-500/20 px-2.5 py-0.5 rounded-full">
                          <ShieldCheck className="w-3 h-3 text-emerald-400" />
                          ✓ Verified
                        </span>
                      )}
                    </div>

                    <div>
                      <h3 className="text-base font-extrabold text-white group-hover:text-amber-400 transition-colors">
                        {machine.machine_name}
                      </h3>
                      <p className="text-xs text-slate-400 font-medium mt-0.5">
                        {machine.manufacturer || 'Haas'} {machine.model || 'VF-2SS'} ({machine.year || 2022})
                      </p>
                    </div>
                  </div>

                  {/* Capabilities & Stats */}
                  <div className="p-6 space-y-4 text-xs">
                    <div className="flex justify-between items-center text-slate-300">
                      <span className="flex items-center gap-1.5 text-slate-400">
                        <MapPin className="w-3.5 h-3.5 text-slate-500" />
                        <span>{machine.location || 'Coimbatore'}</span>
                      </span>
                      <span className="flex items-center gap-1 text-amber-400 font-bold">
                        <Star className="w-3.5 h-3.5 fill-amber-400 text-amber-400" />
                        <span>{machine.avg_rating || 4.9}</span>
                      </span>
                    </div>

                    <div className="flex flex-wrap gap-1.5">
                      {machine.capabilities && machine.capabilities.length > 0 ? (
                        machine.capabilities.slice(0, 3).map((cap, idx) => (
                          <span key={idx} className="text-[11px] bg-slate-900 border border-slate-800 text-slate-300 px-2.5 py-1 rounded-xl font-mono">
                            {cap.material} • {cap.process}
                          </span>
                        ))
                      ) : (
                        <span className="text-[11px] bg-slate-900 border border-slate-800 text-slate-300 px-2.5 py-1 rounded-xl font-mono">
                          Aluminium • SS • Mild Steel
                        </span>
                      )}
                    </div>

                    <div className="pt-3 border-t border-slate-800/80 flex items-center justify-between text-slate-400 text-[11px]">
                      <span className="flex items-center gap-1 text-emerald-400 font-semibold">
                        <CheckCircle2 className="w-3.5 h-3.5 text-emerald-400" />
                        Available for Rent
                      </span>
                      <span className="font-mono text-slate-400">68% Utilization</span>
                    </div>
                  </div>
                </div>

                {/* Footer Rate & Actions */}
                <div className="bg-slate-900/90 px-6 py-4 border-t border-slate-800 flex items-center justify-between">
                  <div>
                    <span className="text-[10px] uppercase font-bold text-slate-400 block tracking-wider">Slot Rate</span>
                    <span className="text-base font-black text-emerald-400 font-mono">
                      ₹{machine.hourly_rate}
                      <span className="text-xs text-slate-400 font-normal">/hr</span>
                    </span>
                  </div>

                  <div className="flex items-center gap-2">
                    <button
                      onClick={() => alert(`Edit ${machine.machine_name}`)}
                      className="p-2 text-slate-300 hover:text-white bg-slate-800 hover:bg-slate-700 rounded-xl border border-slate-700 transition-colors"
                      title="Edit Machine"
                    >
                      <Edit className="w-4 h-4" />
                    </button>
                    <button
                      onClick={() => alert(`Set Availability for ${machine.machine_name}`)}
                      className="p-2 text-slate-300 hover:text-white bg-slate-800 hover:bg-slate-700 rounded-xl border border-slate-700 transition-colors"
                      title="Set Availability"
                    >
                      <Calendar className="w-4 h-4" />
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};
