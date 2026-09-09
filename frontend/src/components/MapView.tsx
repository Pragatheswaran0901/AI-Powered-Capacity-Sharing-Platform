import React, { useEffect, useState } from 'react';
import { Machine, MatchResult } from '../types';
import { MapPin, Navigation, ExternalLink, ShieldCheck, Sparkles } from 'lucide-react';

interface MapViewProps {
  machines: Machine[];
  matches?: MatchResult[];
  selectedMachineId?: number;
  onSelectMachine?: (machine: Machine) => void;
}

export const MapView: React.FC<MapViewProps> = ({
  machines,
  matches,
  selectedMachineId,
  onSelectMachine
}) => {
  const [mapLoaded, setMapLoaded] = useState(false);

  // Tamil Nadu Manufacturing Hubs
  const hubs = [
    { name: 'Coimbatore (Pilot Hub)', count: '16 Machines', lat: 11.0168, lng: 76.9558 },
    { name: 'Chennai & Ambattur', count: '8 Machines', lat: 13.0827, lng: 80.2707 },
    { name: 'Hosur Auto Cluster', count: '4 Machines', lat: 12.7409, lng: 77.8253 },
    { name: 'Salem Industrial Hub', count: '3 Machines', lat: 11.6643, lng: 78.1460 },
    { name: 'Tiruppur & Erode', count: '5 Machines', lat: 11.1085, lng: 77.3411 },
  ];

  return (
    <div className="bg-slate-900 rounded-xl border border-slate-800 text-white overflow-hidden shadow-md">
      {/* Map Header */}
      <div className="p-4 bg-slate-950 border-b border-slate-800 flex flex-wrap items-center justify-between gap-3">
        <div className="flex items-center gap-2">
          <div className="p-1.5 bg-blue-500/20 text-blue-400 rounded-lg border border-blue-500/30">
            <Navigation className="w-4 h-4" />
          </div>
          <div>
            <h4 className="text-sm font-bold text-white">Tamil Nadu Capacity Map</h4>
            <p className="text-[11px] text-slate-400">Coimbatore Industrial Pilot Cluster & Regional Hubs</p>
          </div>
        </div>

        {/* Legend */}
        <div className="flex items-center gap-3 text-xs text-slate-300">
          <span className="flex items-center gap-1">
            <span className="w-2.5 h-2.5 rounded-full bg-emerald-500"></span>
            Verified Machine
          </span>
          <span className="flex items-center gap-1">
            <span className="w-2.5 h-2.5 rounded-full bg-blue-500"></span>
            High Match (&gt;85%)
          </span>
        </div>
      </div>

      {/* Visual Interactive Map Canvas / Grid Representation */}
      <div className="p-6 relative min-h-[340px] bg-slate-900 flex flex-col justify-between">
        {/* Hub Quick Select Chips */}
        <div className="flex flex-wrap gap-2 z-10">
          {hubs.map((hub, idx) => (
            <div
              key={idx}
              className="bg-slate-800/90 hover:bg-slate-800 text-slate-200 border border-slate-700 px-3 py-1.5 rounded-lg text-xs flex items-center gap-2 cursor-pointer transition-colors shadow-2xs"
            >
              <MapPin className="w-3.5 h-3.5 text-blue-400" />
              <div>
                <span className="font-bold block leading-tight">{hub.name}</span>
                <span className="text-[10px] text-slate-400">{hub.count}</span>
              </div>
            </div>
          ))}
        </div>

        {/* Interactive Pins Display */}
        <div className="my-6 grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-3 z-10">
          {machines.slice(0, 6).map((m) => {
            const match = matches?.find(x => x.machine.id === m.id);
            const isSelected = m.id === selectedMachineId;

            return (
              <div
                key={m.id}
                onClick={() => onSelectMachine && onSelectMachine(m)}
                className={`p-3.5 rounded-xl border transition-all cursor-pointer ${
                  isSelected
                    ? 'bg-blue-950/80 border-blue-500 shadow-md ring-1 ring-blue-500'
                    : 'bg-slate-800/70 hover:bg-slate-800 border-slate-700/80'
                }`}
              >
                <div className="flex justify-between items-start mb-1.5">
                  <span className="text-[10px] font-bold uppercase text-blue-400 bg-blue-950 px-2 py-0.5 rounded border border-blue-800">
                    {m.machine_type}
                  </span>
                  {match && (
                    <span className="text-[10px] font-extrabold text-emerald-400 bg-emerald-950 px-2 py-0.5 rounded border border-emerald-800 font-mono">
                      {match.match_percentage}% Match
                    </span>
                  )}
                </div>

                <h5 className="font-bold text-xs text-white truncate">{m.machine_name}</h5>
                <p className="text-[11px] text-slate-400 truncate">{m.msme_name || 'Kovai Precision Works'}</p>

                <div className="mt-2.5 pt-2 border-t border-slate-700/60 flex items-center justify-between text-[11px]">
                  <span className="text-slate-300 flex items-center gap-1">
                    <MapPin className="w-3 h-3 text-slate-400" />
                    {m.location}
                  </span>
                  <span className="font-mono font-bold text-white">₹{m.hourly_rate}/hr</span>
                </div>
              </div>
            );
          })}
        </div>

        {/* Map Background Grid Visual */}
        <div className="absolute inset-0 opacity-10 bg-[radial-gradient(#3b82f6_1px,transparent_1px)] [background-size:16px_16px] pointer-events-none"></div>
      </div>
    </div>
  );
};
