import React from 'react';
import { MatchResult } from '../types';
import { X, CheckCircle, MapPin, Clock, DollarSign, Award, HelpCircle } from 'lucide-react';

interface MatchDetailModalProps {
  match: MatchResult | null;
  onClose: () => void;
}

export const MatchDetailModal: React.FC<MatchDetailModalProps> = ({ match, onClose }) => {
  if (!match) return null;

  const factors = [
    {
      name: 'Capability Match',
      weight: '40%',
      score: Math.round(match.capability_score * 100),
      desc: 'Machine supports process, tolerance & material requirements.',
      icon: CheckCircle,
      color: 'bg-emerald-500'
    },
    {
      name: 'Slot Availability',
      weight: '20%',
      score: Math.round(match.availability_score * 100),
      desc: 'Operator & machine ready before job deadline.',
      icon: Clock,
      color: 'bg-blue-500'
    },
    {
      name: 'Proximity Distance',
      weight: '15%',
      score: Math.round(match.distance_score * 100),
      desc: `${match.distance_km} km from seeker cluster location.`,
      icon: MapPin,
      color: 'bg-indigo-500'
    },
    {
      name: 'Cost & Budget Fit',
      weight: '15%',
      score: Math.round(match.cost_score * 100),
      desc: 'Hourly rate aligned with requested target budget.',
      icon: DollarSign,
      color: 'bg-amber-500'
    },
    {
      name: 'Reliability & Rating',
      weight: '10%',
      score: Math.round(match.reliability_score * 100),
      desc: 'Based on MSME verification badge and past user ratings.',
      icon: Award,
      color: 'bg-purple-500'
    }
  ];

  return (
    <div className="fixed inset-0 z-50 bg-slate-900/60 backdrop-blur-xs flex items-center justify-center p-4">
      <div className="bg-white rounded-xl max-w-lg w-full shadow-2xl border border-slate-200 overflow-hidden">
        {/* Header */}
        <div className="bg-slate-900 text-white p-5 flex items-center justify-between">
          <div>
            <span className="text-[10px] font-bold tracking-widest text-blue-400 uppercase block">
              Smart Capacity Matching Engine
            </span>
            <h3 className="text-lg font-bold">
              {match.machine.machine_name}
            </h3>
            <p className="text-xs text-slate-300 mt-0.5">{match.machine.msme_name} • {match.machine.location}</p>
          </div>
          <button
            onClick={onClose}
            className="p-1 rounded-lg text-slate-400 hover:text-white hover:bg-slate-800 transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Content */}
        <div className="p-6 space-y-6">
          {/* Total Score Header */}
          <div className="bg-blue-50 border border-blue-100 rounded-lg p-4 flex items-center justify-between">
            <div>
              <span className="text-xs font-semibold text-blue-900 block">Total Match Score</span>
              <span className="text-2xl font-black text-blue-600 font-mono">{match.match_percentage}%</span>
            </div>
            <div className="text-right">
              <span className="inline-block text-[11px] bg-blue-600 text-white font-bold px-2.5 py-1 rounded-full">
                Rank #1 Recommendation
              </span>
            </div>
          </div>

          {/* Formula breakdown notice */}
          <div className="text-xs text-slate-500 bg-slate-50 p-3 rounded border border-slate-200 flex items-start gap-2">
            <HelpCircle className="w-4 h-4 text-slate-400 shrink-0 mt-0.5" />
            <div>
              <span className="font-semibold text-slate-700 block mb-0.5">Transparent Formula Weighting:</span>
              <span>Match = Capability (40%) + Availability (20%) + Distance (15%) + Cost (15%) + Reliability (10%)</span>
            </div>
          </div>

          {/* Individual Factor Progress Bars */}
          <div className="space-y-4">
            {factors.map((f, i) => {
              const Icon = f.icon;
              return (
                <div key={i} className="space-y-1">
                  <div className="flex justify-between items-center text-xs font-semibold">
                    <div className="flex items-center gap-1.5 text-slate-800">
                      <Icon className="w-3.5 h-3.5 text-slate-500" />
                      <span>{f.name}</span>
                      <span className="text-[10px] text-slate-400 bg-slate-100 px-1.5 py-0.2 rounded font-mono">
                        Weight: {f.weight}
                      </span>
                    </div>
                    <span className="font-mono text-slate-900 font-bold">{f.score}%</span>
                  </div>
                  
                  {/* Progress bar */}
                  <div className="w-full h-2 bg-slate-100 rounded-full overflow-hidden">
                    <div
                      className={`h-full ${f.color} transition-all duration-500`}
                      style={{ width: `${f.score}%` }}
                    ></div>
                  </div>
                  
                  <p className="text-[11px] text-slate-500 font-normal">{f.desc}</p>
                </div>
              );
            })}
          </div>
        </div>

        {/* Footer */}
        <div className="bg-slate-50 px-6 py-4 border-t border-slate-200 flex justify-end">
          <button
            onClick={onClose}
            className="px-4 py-2 bg-slate-900 text-white rounded-lg text-xs font-semibold hover:bg-blue-600 transition-colors"
          >
            Close Breakdown
          </button>
        </div>
      </div>
    </div>
  );
};
