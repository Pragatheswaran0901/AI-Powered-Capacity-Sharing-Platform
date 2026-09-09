import React from 'react';
import { ShieldCheck, MapPin, Cpu, CheckCircle2 } from 'lucide-react';

export const Footer: React.FC = () => {
  return (
    <footer className="bg-slate-900 text-slate-400 text-xs border-t border-slate-800 pt-10 pb-8 mt-16">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-8 pb-8 border-b border-slate-800">
          {/* Col 1 */}
          <div className="space-y-3">
            <div className="flex items-center gap-2">
              <div className="w-7 h-7 bg-blue-600 text-white rounded font-bold flex items-center justify-center text-sm">
                MH
              </div>
              <span className="text-base font-bold text-white tracking-tight">Mach-Hunt</span>
            </div>
            <p className="text-slate-400 text-xs leading-relaxed">
              Manufacturing Capacity-as-a-Service for MSMEs in Tamil Nadu. Connecting idle CNC, VMC, lathe, and laser capacity with active seekers.
            </p>
            <div className="flex items-center gap-1.5 text-[11px] text-emerald-400 font-medium">
              <ShieldCheck className="w-4 h-4 text-emerald-500" />
              <span>Verified MSME Network • Tamil Nadu</span>
            </div>
          </div>

          {/* Col 2 */}
          <div>
            <h4 className="font-semibold text-white uppercase text-[11px] tracking-wider mb-3">TN Manufacturing Hubs</h4>
            <ul className="space-y-1.5 text-slate-400">
              <li className="flex items-center gap-1"><MapPin className="w-3 h-3 text-blue-400" /> Coimbatore (Pilot Cluster)</li>
              <li className="flex items-center gap-1"><MapPin className="w-3 h-3 text-blue-400" /> Chennai & Ambattur</li>
              <li className="flex items-center gap-1"><MapPin className="w-3 h-3 text-blue-400" /> Hosur Auto Cluster</li>
              <li className="flex items-center gap-1"><MapPin className="w-3 h-3 text-blue-400" /> Salem Industrial Area</li>
              <li className="flex items-center gap-1"><MapPin className="w-3 h-3 text-blue-400" /> Tiruppur & Erode</li>
            </ul>
          </div>

          {/* Col 3 */}
          <div>
            <h4 className="font-semibold text-white uppercase text-[11px] tracking-wider mb-3">Capacity Types</h4>
            <ul className="space-y-1.5 text-slate-400">
              <li>VMC Vertical Machining (3 & 5-Axis)</li>
              <li>CNC Turning & Automatic Lathes</li>
              <li>Fiber Laser Cutting & Press Brake</li>
              <li>Robotic TIG/MIG Welding Cells</li>
              <li>Industrial SLS 3D Printing</li>
            </ul>
          </div>

          {/* Col 4 */}
          <div className="space-y-3">
            <h4 className="font-semibold text-white uppercase text-[11px] tracking-wider mb-1">Architecture Note</h4>
            <div className="bg-slate-800/80 p-3 rounded border border-slate-700 space-y-1.5">
              <div className="flex items-center gap-1 text-blue-300 font-semibold">
                <Cpu className="w-3.5 h-3.5" />
                <span>Phase 2 IoT Integration</span>
              </div>
              <p className="text-[11px] text-slate-400 leading-tight">
                ESP32 current & vibration telemetry for automated machine utilization tracking is under future roadmap.
              </p>
            </div>
            <p className="text-[10px] text-slate-500">
              All demo data is fictional and representative of Tamil Nadu MSMEs.
            </p>
          </div>
        </div>

        <div className="pt-6 flex flex-col sm:flex-row items-center justify-between gap-4 text-slate-500">
          <p>© 2026 Mach-Hunt Platform. From Idle Machines to Shared Capacity.</p>
          <div className="flex gap-4">
            <span className="hover:text-slate-400 cursor-pointer">Privacy Policy</span>
            <span className="hover:text-slate-400 cursor-pointer">MSME Code of Conduct</span>
            <span className="hover:text-slate-400 cursor-pointer">Matching Algorithm</span>
          </div>
        </div>
      </div>
    </footer>
  );
};
