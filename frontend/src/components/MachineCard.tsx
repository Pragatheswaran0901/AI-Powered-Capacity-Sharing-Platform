import React from 'react';
import { Machine, MatchResult } from '../types';
import { MatchBadge } from './MatchBadge';
import { MapPin, Star, ShieldCheck, User, Wrench, CheckCircle2, Clock } from 'lucide-react';

interface MachineCardProps {
  machine: Machine;
  matchResult?: MatchResult;
  onSelectForCompare?: () => void;
  isCompared?: boolean;
  onBookClick?: () => void;
  onViewDetails?: () => void;
  onViewMatchBreakdown?: () => void;
}

export const MachineCard: React.FC<MachineCardProps> = ({
  machine,
  matchResult,
  onSelectForCompare,
  isCompared = false,
  onBookClick,
  onViewDetails,
  onViewMatchBreakdown
}) => {
  return (
    <div className="bg-slate-950/80 rounded-3xl border border-slate-800 hover:border-slate-700 shadow-xl transition-all flex flex-col justify-between overflow-hidden group">
      <div>
        {/* Top Header Card Info */}
        <div className="p-6 border-b border-slate-800/80 relative">
          <div className="flex justify-between items-start gap-3">
            <div>
              <div className="flex flex-wrap items-center gap-2 mb-1.5">
                <span className="text-[10px] font-black uppercase tracking-wider text-blue-400 bg-blue-500/10 border border-blue-500/20 px-2.5 py-0.5 rounded-full font-mono">
                  {machine.machine_type}
                </span>

                {machine.verification_status === 'verified' && (
                  <span className="inline-flex items-center gap-1 text-[10px] font-bold text-emerald-400 bg-emerald-500/10 px-2 py-0.5 rounded-full border border-emerald-500/20">
                    <ShieldCheck className="w-3 h-3 text-emerald-400" />
                    Verified Unit
                  </span>
                )}
              </div>

              <h3 className="text-base font-extrabold text-white group-hover:text-blue-400 transition-colors line-clamp-1">
                {machine.machine_name}
              </h3>
              <p className="text-xs text-slate-400 font-medium">
                {machine.manufacturer} {machine.model} ({machine.year || '2022'})
              </p>
            </div>

            {matchResult && (
              <MatchBadge
                percentage={matchResult.match_percentage}
                onClick={onViewMatchBreakdown}
                size="md"
              />
            )}
          </div>
        </div>

        {/* Details & Specifications */}
        <div className="p-6 space-y-4">
          {/* MSME Company & Location */}
          <div className="flex justify-between items-center text-xs">
            <div className="flex items-center gap-1.5 text-slate-300 font-medium">
              <User className="w-3.5 h-3.5 text-slate-500" />
              <span>{machine.msme_name || 'Kovai Precision Works'}</span>
            </div>
            <div className="flex items-center gap-1 text-slate-400 font-medium">
              <MapPin className="w-3.5 h-3.5 text-slate-500" />
              <span>{machine.location}</span>
              {matchResult && (
                <span className="text-slate-500 text-[11px] font-mono">({matchResult.distance_km} km)</span>
              )}
            </div>
          </div>

          {/* Capabilities Tags */}
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

          {/* Operator availability notice */}
          <div className="flex items-center justify-between text-xs text-slate-400 pt-3 border-t border-slate-800/80">
            <span className="flex items-center gap-1 text-slate-300 font-medium">
              <CheckCircle2 className="w-3.5 h-3.5 text-emerald-400" />
              {machine.operator_available ? 'Certified Operator' : 'Facility Managed'}
            </span>
            <div className="flex items-center gap-1 text-amber-400 font-bold">
              <Star className="w-3.5 h-3.5 fill-amber-400 text-amber-400" />
              <span>{machine.avg_rating || 4.9}</span>
              <span className="text-slate-500 font-normal">({machine.jobs_completed || 15} jobs)</span>
            </div>
          </div>
        </div>
      </div>

      {/* Pricing & Footer Actions */}
      <div className="bg-slate-900/90 px-6 py-4 border-t border-slate-800 flex items-center justify-between">
        <div>
          <span className="text-[10px] uppercase font-bold text-slate-400 block tracking-wider">Slot Rate</span>
          <span className="text-base font-black text-emerald-400 font-mono">
            ₹{machine.hourly_rate}
            <span className="text-xs text-slate-400 font-normal">/hr</span>
          </span>
        </div>

        <div className="flex items-center gap-2">
          {onSelectForCompare && (
            <button
              onClick={onSelectForCompare}
              className={`px-3 py-2 text-xs font-bold rounded-xl border transition-all ${
                isCompared
                  ? 'bg-blue-600 text-white border-blue-600 shadow-md'
                  : 'bg-slate-800 text-slate-300 border-slate-700 hover:bg-slate-700 hover:text-white'
              }`}
            >
              {isCompared ? 'Comparing' : 'Compare'}
            </button>
          )}

          {onBookClick && (
            <button
              onClick={onBookClick}
              className="px-4 py-2 text-xs font-bold text-white bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-500 hover:to-indigo-500 rounded-xl shadow-lg shadow-blue-600/20 transition-all"
            >
              Book Capacity
            </button>
          )}
        </div>
      </div>
    </div>
  );
};

