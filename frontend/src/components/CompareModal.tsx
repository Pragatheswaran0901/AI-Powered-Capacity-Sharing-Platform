import React from 'react';
import { MatchResult } from '../types';
import { X, Check, ShieldCheck, MapPin, DollarSign, Star } from 'lucide-react';

interface CompareModalProps {
  items: MatchResult[];
  onClose: () => void;
  onBookMachine: (match: MatchResult) => void;
}

export const CompareModal: React.FC<CompareModalProps> = ({ items, onClose, onBookMachine }) => {
  if (!items || items.length === 0) return null;

  return (
    <div className="fixed inset-0 z-50 bg-slate-900/60 backdrop-blur-xs flex items-center justify-center p-4">
      <div className="bg-white rounded-xl max-w-4xl w-full shadow-2xl border border-slate-200 overflow-hidden flex flex-col max-h-[90vh]">
        {/* Header */}
        <div className="bg-slate-900 text-white p-5 flex items-center justify-between">
          <div>
            <h3 className="text-lg font-bold">Side-by-Side Machine Capacity Comparison</h3>
            <p className="text-xs text-slate-300">Comparing {items.length} selected manufacturing capacity providers</p>
          </div>
          <button
            onClick={onClose}
            className="p-1 rounded-lg text-slate-400 hover:text-white hover:bg-slate-800 transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Comparison Matrix Table */}
        <div className="p-6 overflow-x-auto overflow-y-auto custom-scrollbar">
          <table className="w-full text-left border-collapse text-xs">
            <thead>
              <tr className="border-b border-slate-200">
                <th className="p-3 bg-slate-50 font-bold text-slate-700 w-44">Factor / Spec</th>
                {items.map((item, idx) => (
                  <th key={idx} className="p-3 font-bold text-slate-900 min-w-[200px]">
                    <div className="text-sm font-extrabold text-blue-700">{item.machine.machine_name}</div>
                    <div className="text-slate-500 text-[11px] font-normal">{item.machine.msme_name}</div>
                  </th>
                ))}
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {/* Match Score */}
              <tr>
                <td className="p-3 bg-slate-50 font-semibold text-slate-700">Smart Match %</td>
                {items.map((item, idx) => (
                  <td key={idx} className="p-3">
                    <span className="inline-block px-2.5 py-1 rounded-full text-xs font-black bg-blue-100 text-blue-800 font-mono">
                      {item.match_percentage}% Match
                    </span>
                  </td>
                ))}
              </tr>

              {/* Location & Distance */}
              <tr>
                <td className="p-3 bg-slate-50 font-semibold text-slate-700">Distance & City</td>
                {items.map((item, idx) => (
                  <td key={idx} className="p-3 font-medium text-slate-800">
                    <div className="flex items-center gap-1">
                      <MapPin className="w-3.5 h-3.5 text-slate-400" />
                      <span>{item.distance_km} km ({item.machine.location})</span>
                    </div>
                  </td>
                ))}
              </tr>

              {/* Hourly Rate */}
              <tr>
                <td className="p-3 bg-slate-50 font-semibold text-slate-700">Hourly Rate</td>
                {items.map((item, idx) => (
                  <td key={idx} className="p-3 font-mono font-bold text-slate-900 text-sm">
                    ₹{item.machine.hourly_rate} / hr
                  </td>
                ))}
              </tr>

              {/* Rating */}
              <tr>
                <td className="p-3 bg-slate-50 font-semibold text-slate-700">Rating & Reviews</td>
                {items.map((item, idx) => (
                  <td key={idx} className="p-3">
                    <div className="flex items-center gap-1 font-bold text-slate-800">
                      <Star className="w-3.5 h-3.5 fill-amber-400 text-amber-400" />
                      <span>{item.machine.avg_rating || 4.8} / 5.0</span>
                    </div>
                  </td>
                ))}
              </tr>

              {/* Process & Materials */}
              <tr>
                <td className="p-3 bg-slate-50 font-semibold text-slate-700">Machine Category</td>
                {items.map((item, idx) => (
                  <td key={idx} className="p-3 font-semibold text-blue-700">
                    {item.machine.machine_type}
                  </td>
                ))}
              </tr>

              {/* Verification */}
              <tr>
                <td className="p-3 bg-slate-50 font-semibold text-slate-700">Verification</td>
                {items.map((item, idx) => (
                  <td key={idx} className="p-3">
                    <span className="inline-flex items-center gap-1 text-emerald-700 font-semibold">
                      <ShieldCheck className="w-3.5 h-3.5 text-emerald-600" />
                      Verified MSME
                    </span>
                  </td>
                ))}
              </tr>

              {/* Operator */}
              <tr>
                <td className="p-3 bg-slate-50 font-semibold text-slate-700">Operator Available</td>
                {items.map((item, idx) => (
                  <td key={idx} className="p-3">
                    {item.machine.operator_available ? (
                      <span className="text-emerald-600 font-medium flex items-center gap-1">
                        <Check className="w-3.5 h-3.5" /> Included
                      </span>
                    ) : (
                      <span className="text-slate-400">Self-Operated</span>
                    )}
                  </td>
                ))}
              </tr>

              {/* Action Buttons */}
              <tr>
                <td className="p-3 bg-slate-50 font-semibold text-slate-700">Action</td>
                {items.map((item, idx) => (
                  <td key={idx} className="p-3">
                    <button
                      onClick={() => onBookMachine(item)}
                      className="w-full py-2 bg-slate-900 text-white rounded font-bold hover:bg-blue-600 transition-colors shadow-2xs"
                    >
                      Book Capacity
                    </button>
                  </td>
                ))}
              </tr>
            </tbody>
          </table>
        </div>

        {/* Footer */}
        <div className="bg-slate-50 px-6 py-4 border-t border-slate-200 flex justify-end">
          <button
            onClick={onClose}
            className="px-4 py-2 bg-slate-200 text-slate-800 rounded text-xs font-semibold hover:bg-slate-300 transition-colors"
          >
            Close Comparison
          </button>
        </div>
      </div>
    </div>
  );
};
