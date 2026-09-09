import React, { useState, useEffect } from 'react';
import { X, Cpu, Activity, Zap, Radio, RefreshCw, AlertTriangle } from 'lucide-react';

interface IoTMockModalProps {
  onClose: () => void;
}

export const IoTMockModal: React.FC<IoTMockModalProps> = ({ onClose }) => {
  const [currentAmps, setCurrentAmps] = useState(18.4);
  const [vibrationG, setVibrationG] = useState(0.42);
  const [spindleRpm, setSpindleRpm] = useState(8450);

  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentAmps(+(17.5 + Math.random() * 2.2).toFixed(1));
      setVibrationG(+(0.38 + Math.random() * 0.12).toFixed(2));
      setSpindleRpm(Math.floor(8300 + Math.random() * 300));
    }, 1500);
    return () => clearInterval(interval);
  }, []);

  return (
    <div className="fixed inset-0 z-50 bg-slate-900/60 backdrop-blur-xs flex items-center justify-center p-4">
      <div className="bg-slate-950 text-white rounded-xl max-w-xl w-full shadow-2xl border border-slate-800 overflow-hidden">
        {/* Header */}
        <div className="p-5 bg-slate-900 border-b border-slate-800 flex items-center justify-between">
          <div className="flex items-center gap-2.5">
            <div className="p-2 bg-blue-600/20 text-blue-400 rounded-lg border border-blue-500/30">
              <Cpu className="w-5 h-5" />
            </div>
            <div>
              <div className="flex items-center gap-2">
                <span className="text-[10px] font-bold uppercase tracking-wider text-blue-400 bg-blue-950 px-2 py-0.5 rounded border border-blue-800">
                  Phase 2 Roadmap
                </span>
                <span className="text-[10px] font-semibold text-amber-400 flex items-center gap-1">
                  <Radio className="w-3 h-3 animate-pulse" /> Live Telemetry Mock
                </span>
              </div>
              <h3 className="text-base font-bold text-white mt-0.5">ESP32 Hardware Sensor Integration</h3>
            </div>
          </div>
          <button onClick={onClose} className="p-1 rounded text-slate-400 hover:text-white hover:bg-slate-800">
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Content */}
        <div className="p-6 space-y-6">
          <div className="bg-amber-500/10 border border-amber-500/20 rounded-lg p-3 text-xs text-amber-300 flex items-start gap-2">
            <AlertTriangle className="w-4 h-4 text-amber-400 shrink-0 mt-0.5" />
            <div>
              <span className="font-bold block">Future Hardware Scope:</span>
              <span>ESP32 Wi-Fi microcontrollers attached to CT current transformers and ADXL345 vibration sensors enable automatic idle vs active machine hour tracking.</span>
            </div>
          </div>

          {/* Machine Under Monitoring */}
          <div className="bg-slate-900 p-4 rounded-xl border border-slate-800 space-y-4">
            <div className="flex justify-between items-center border-b border-slate-800 pb-3">
              <div>
                <span className="text-xs text-slate-400 block">Monitored Device</span>
                <span className="font-bold text-white text-sm">Haas VMC-01 (Kovai Precision Works)</span>
              </div>
              <span className="px-2.5 py-1 rounded-full text-xs font-bold bg-emerald-500/20 text-emerald-400 border border-emerald-500/30 flex items-center gap-1.5">
                <span className="w-2 h-2 rounded-full bg-emerald-400 animate-ping"></span>
                CUTTING IN PROGRESS
              </span>
            </div>

            {/* Sensor Telemetry Grid */}
            <div className="grid grid-cols-3 gap-3">
              {/* Amperage */}
              <div className="bg-slate-950 p-3 rounded-lg border border-slate-800 text-center">
                <Zap className="w-4 h-4 text-amber-400 mx-auto mb-1" />
                <span className="text-[10px] text-slate-400 uppercase block font-semibold">Motor Current</span>
                <span className="text-lg font-black text-white font-mono">{currentAmps} A</span>
              </div>

              {/* Vibration */}
              <div className="bg-slate-950 p-3 rounded-lg border border-slate-800 text-center">
                <Activity className="w-4 h-4 text-blue-400 mx-auto mb-1" />
                <span className="text-[10px] text-slate-400 uppercase block font-semibold">Vibration</span>
                <span className="text-lg font-black text-white font-mono">{vibrationG} g</span>
              </div>

              {/* Spindle */}
              <div className="bg-slate-950 p-3 rounded-lg border border-slate-800 text-center">
                <RefreshCw className="w-4 h-4 text-emerald-400 mx-auto mb-1" />
                <span className="text-[10px] text-slate-400 uppercase block font-semibold">Spindle Speed</span>
                <span className="text-lg font-black text-white font-mono">{spindleRpm} RPM</span>
              </div>
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="bg-slate-900 px-6 py-4 border-t border-slate-800 flex justify-end">
          <button
            onClick={onClose}
            className="px-4 py-2 bg-blue-600 text-white rounded-lg text-xs font-semibold hover:bg-blue-500 transition-colors"
          >
            Close Telemetry Drawer
          </button>
        </div>
      </div>
    </div>
  );
};
