import React from 'react';
import { useAuth } from '../context/AuthContext';
import { UserCheck, Shield, Wrench, Search, Sparkles } from 'lucide-react';

export const DemoBanner: React.FC = () => {
  const { user, switchDemoUser } = useAuth();

  return (
    <div className="bg-slate-900 text-white border-b border-slate-800 text-xs py-2 px-4">
      <div className="max-w-7xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-2">
        <div className="flex items-center gap-2">
          <span className="inline-flex items-center px-2 py-0.5 rounded text-[10px] font-semibold bg-blue-500/20 text-blue-300 border border-blue-500/30">
            <Sparkles className="w-3 h-3 mr-1 text-blue-400" />
            HACKATHON DEMO MODE
          </span>
          <span className="text-slate-300 hidden md:inline">
            Tamil Nadu MSME Capacity Sharing Platform (Coimbatore Pilot)
          </span>
        </div>

        <div className="flex items-center gap-3">
          <span className="text-slate-400 font-medium">Demo MSME Account:</span>
          <div className="flex items-center gap-1.5 bg-slate-800 p-1 rounded-lg border border-slate-700">
            <button
              onClick={() => switchDemoUser('msme')}
              className={`flex items-center gap-1 px-3 py-1 rounded text-xs transition-all ${
                user?.email?.includes('pragatheswaran')
                  ? 'bg-amber-500 text-slate-950 font-black shadow-sm'
                  : 'text-slate-300 hover:text-white hover:bg-slate-700'
              }`}
            >
              <Sparkles className="w-3 h-3 text-amber-400" />
              Pragatheswaran (Kongu Components)
            </button>

            <button
              onClick={() => switchDemoUser('owner')}
              className={`flex items-center gap-1 px-3 py-1 rounded text-xs transition-all ${
                user?.email?.includes('janika')
                  ? 'bg-emerald-600 text-white font-bold shadow-sm'
                  : 'text-slate-300 hover:text-white hover:bg-slate-700'
              }`}
            >
              <Wrench className="w-3 h-3" />
              Janika (Kovai Precision)
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};
