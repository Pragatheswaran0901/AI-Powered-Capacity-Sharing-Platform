import React, { useState, useEffect } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import { api } from '../services/api';
import { Machine, MatchResult } from '../types';
import { MachineCard } from '../components/MachineCard';
import { Sparkles, Search, MapPin, Filter, Layers, CheckCircle2, ArrowRight, ShieldCheck, RefreshCw } from 'lucide-react';

export const FindCapacityPage: React.FC = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const queryParams = new URLSearchParams(location.search);

  // Form State
  const [reqTitle, setReqTitle] = useState('500 Aluminium Components');
  const [process, setProcess] = useState(queryParams.get('process') || 'CNC Milling');
  const [material, setMaterial] = useState('Aluminium');
  const [quantity, setQuantity] = useState(500);
  const [deadline, setDeadline] = useState('3 days');
  const [budget, setBudget] = useState(25000);
  const [city, setCity] = useState(queryParams.get('city') || 'Coimbatore');
  
  // Natural Language Prompt State
  const [nlPrompt, setNlPrompt] = useState('I need 500 aluminium brackets machined within 3 days in Coimbatore with ₹25,000 budget.');
  const [isParsing, setIsParsing] = useState(false);

  // Results State
  const [matches, setMatches] = useState<MatchResult[]>([]);
  const [comparedMachineIds, setComparedMachineIds] = useState<number[]>([]);
  const [showCompareModal, setShowCompareModal] = useState(false);
  const [loading, setLoading] = useState(false);

  // Selected Category Pill
  const [selectedCategory, setSelectedCategory] = useState<string>('All');

  const categories = [
    { label: 'All', icon: '🌐' },
    { label: 'CNC Milling', icon: '⚙️' },
    { label: 'VMC', icon: '🌀' },
    { label: 'CNC Turning', icon: '🔩' },
    { label: 'Laser Cutting', icon: '⚡' },
    { label: 'Press Brake', icon: '📐' },
    { label: 'Welding', icon: '🛠️' },
    { label: 'Conventional Lathe', icon: '🔧' },
    { label: '3D Printing', icon: '🖨️' }
  ];

  const fetchMatches = async () => {
    setLoading(true);
    const results = await api.getMatches(1); // Default demo requirement
    setMatches(results);
    setLoading(false);
  };

  useEffect(() => {
    fetchMatches();
  }, []);

  const handleParseNL = async () => {
    if (!nlPrompt.trim()) return;
    setIsParsing(true);
    const parsed = await api.parseNLRequirement(nlPrompt);
    setReqTitle(parsed.title);
    setProcess(parsed.process);
    setMaterial(parsed.material);
    setQuantity(parsed.quantity);
    setDeadline(parsed.deadline);
    setBudget(parsed.budget);
    setCity(parsed.preferred_city);
    setIsParsing(false);
    fetchMatches();
  };

  const handleSearchSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    fetchMatches();
  };

  const toggleCompare = (id: number) => {
    if (comparedMachineIds.includes(id)) {
      setComparedMachineIds(comparedMachineIds.filter(item => item !== id));
    } else {
      if (comparedMachineIds.length >= 3) {
        alert('You can compare up to 3 machines at once.');
        return;
      }
      setComparedMachineIds([...comparedMachineIds, id]);
    }
  };

  const filteredMatches = matches.filter((m) => {
    if (selectedCategory !== 'All' && !m.machine.machine_type.toLowerCase().includes(selectedCategory.toLowerCase())) {
      return false;
    }
    return true;
  });

  return (
    <div className="min-h-screen bg-slate-900 text-slate-100 pb-20 font-sans">
      {/* Top Banner Header */}
      <div className="bg-gradient-to-r from-slate-950 via-slate-900 to-blue-950 border-b border-slate-800 py-8 px-4 sm:px-6 lg:px-8">
        <div className="max-w-7xl mx-auto flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
          <div>
            <div className="inline-flex items-center gap-2 px-3 py-1 bg-blue-500/10 border border-blue-500/20 rounded-full text-blue-400 text-xs font-semibold mb-2">
              <Sparkles className="w-3.5 h-3.5" />
              <span>Smart Capacity Matching Engine</span>
            </div>
            <h1 className="text-3xl font-black text-white">Find Manufacturing Capacity</h1>
            <p className="text-xs text-slate-400 mt-1">
              Search verified machines available near you in Tamil Nadu using 5-factor weighted capability matching.
            </p>
          </div>

          {comparedMachineIds.length > 0 && (
            <button
              onClick={() => setShowCompareModal(true)}
              className="px-5 py-3 bg-blue-600 hover:bg-blue-500 text-white font-bold rounded-2xl text-xs flex items-center gap-2 shadow-lg shadow-blue-600/25 transition-all"
            >
              <Layers className="w-4 h-4" />
              <span>Compare ({comparedMachineIds.length}) Machines</span>
            </button>
          )}
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 mt-6 space-y-6">
        
        {/* OLX-STYLE CATEGORY ICON PILLS BAR */}
        <div className="flex items-center gap-2 overflow-x-auto pb-2 text-xs font-semibold no-scrollbar">
          {categories.map((cat, idx) => (
            <button
              key={idx}
              onClick={() => setSelectedCategory(cat.label)}
              className={`flex items-center gap-2 px-4 py-2.5 rounded-2xl border transition-all shrink-0 cursor-pointer ${
                selectedCategory === cat.label
                  ? 'bg-blue-600 border-blue-500 text-white font-bold shadow-lg shadow-blue-600/25'
                  : 'bg-slate-950/80 border-slate-800 text-slate-300 hover:border-slate-700 hover:bg-slate-900'
              }`}
            >
              <span className="text-base">{cat.icon}</span>
              <span>{cat.label}</span>
            </button>
          ))}
        </div>

        {/* AI NATURAL LANGUAGE EXTRACTION ASSISTANT */}
        <div className="bg-slate-950/90 rounded-3xl p-5 border border-blue-500/30 space-y-3 shadow-xl">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2 text-xs font-extrabold text-blue-400">
              <Sparkles className="w-4 h-4 animate-pulse" />
              <span>Natural Language Requirement Assistant</span>
            </div>
            <span className="text-[10px] text-slate-400 font-mono">Auto Entity Spec Extraction</span>
          </div>

          <div className="flex flex-col sm:flex-row gap-2">
            <input
              type="text"
              value={nlPrompt}
              onChange={(e) => setNlPrompt(e.target.value)}
              placeholder="e.g. I need 500 aluminium brackets machined within 3 days in Coimbatore with ₹25,000 budget."
              className="flex-1 p-3 bg-slate-900 border border-slate-800 rounded-xl text-xs text-white placeholder-slate-500 focus:ring-2 focus:ring-blue-500 focus:outline-none"
            />
            <button
              type="button"
              onClick={handleParseNL}
              disabled={isParsing}
              className="px-5 py-3 bg-blue-600 hover:bg-blue-500 text-white font-bold rounded-xl text-xs transition-all shrink-0 flex items-center justify-center gap-1.5"
            >
              {isParsing ? 'Extracting...' : 'Extract Specs & Search'}
            </button>
          </div>
        </div>

        {/* REQUIREMENT SPECIFICATION FORM */}
        <form onSubmit={handleSearchSubmit} className="bg-slate-950/80 p-6 rounded-3xl border border-slate-800 space-y-4 text-xs">
          <div className="grid grid-cols-1 sm:grid-cols-3 lg:grid-cols-6 gap-3">
            <div className="space-y-1">
              <label className="font-semibold text-slate-400 block">Requirement</label>
              <input
                type="text"
                value={reqTitle}
                onChange={(e) => setReqTitle(e.target.value)}
                className="w-full p-2.5 bg-slate-900 border border-slate-800 rounded-xl text-white focus:outline-none focus:border-blue-500"
              />
            </div>

            <div className="space-y-1">
              <label className="font-semibold text-slate-400 block">Process</label>
              <select
                value={process}
                onChange={(e) => setProcess(e.target.value)}
                className="w-full p-2.5 bg-slate-900 border border-slate-800 rounded-xl text-white focus:outline-none focus:border-blue-500"
              >
                <option value="CNC Milling">CNC Milling</option>
                <option value="VMC">VMC Vertical</option>
                <option value="CNC Turning">CNC Turning</option>
                <option value="Laser Cutting">Laser Cutting</option>
                <option value="Press Brake">Press Brake</option>
                <option value="Welding">Welding</option>
                <option value="3D Printing">3D Printing</option>
              </select>
            </div>

            <div className="space-y-1">
              <label className="font-semibold text-slate-400 block">Material</label>
              <select
                value={material}
                onChange={(e) => setMaterial(e.target.value)}
                className="w-full p-2.5 bg-slate-900 border border-slate-800 rounded-xl text-white focus:outline-none focus:border-blue-500"
              >
                <option value="Aluminium">Aluminium</option>
                <option value="Stainless Steel">Stainless Steel</option>
                <option value="Mild Steel">Mild Steel</option>
                <option value="Brass">Brass</option>
                <option value="Copper">Copper</option>
                <option value="Nylon">Nylon / ABS</option>
              </select>
            </div>

            <div className="space-y-1">
              <label className="font-semibold text-slate-400 block">Quantity</label>
              <input
                type="number"
                value={quantity}
                onChange={(e) => setQuantity(Number(e.target.value))}
                className="w-full p-2.5 bg-slate-900 border border-slate-800 rounded-xl text-white font-mono focus:outline-none focus:border-blue-500"
              />
            </div>

            <div className="space-y-1">
              <label className="font-semibold text-slate-400 block">Budget (₹)</label>
              <input
                type="number"
                value={budget}
                onChange={(e) => setBudget(Number(e.target.value))}
                className="w-full p-2.5 bg-slate-900 border border-slate-800 rounded-xl text-emerald-400 font-mono font-bold focus:outline-none focus:border-blue-500"
              />
            </div>

            <div className="space-y-1">
              <label className="font-semibold text-slate-400 block">Location</label>
              <select
                value={city}
                onChange={(e) => setCity(e.target.value)}
                className="w-full p-2.5 bg-slate-900 border border-slate-800 rounded-xl text-white focus:outline-none focus:border-blue-500"
              >
                <option value="Coimbatore">Coimbatore</option>
                <option value="Chennai">Chennai</option>
                <option value="Hosur">Hosur</option>
                <option value="Salem">Salem</option>
                <option value="Tiruppur">Tiruppur</option>
                <option value="Erode">Erode</option>
                <option value="Madurai">Madurai</option>
              </select>
            </div>
          </div>

          <button
            type="submit"
            className="w-full py-3 bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-500 hover:to-indigo-500 text-white font-extrabold rounded-xl transition-all shadow-md flex items-center justify-center gap-2"
          >
            <Search className="w-4 h-4" />
            <span>Find Matching Machines</span>
          </button>
        </form>

        {/* MATCH RESULTS SECTION */}
        <div>
          <div className="flex justify-between items-center mb-4">
            <div>
              <h2 className="text-lg font-extrabold text-white">Recommended Manufacturing Capacity</h2>
              <p className="text-xs text-slate-400 font-mono">
                Ranked formula: Capability (40%) + Availability (20%) + Distance (15%) + Cost (15%) + Reliability (10%)
              </p>
            </div>

            <span className="text-xs text-slate-400 font-mono">
              Found {filteredMatches.length} Matches
            </span>
          </div>

          {loading ? (
            <div className="text-center py-20 text-slate-400">Evaluating capacity algorithms...</div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {filteredMatches.map((match) => (
                <MachineCard
                  key={match.machine.id}
                  machine={match.machine}
                  matchResult={match}
                  isCompared={comparedMachineIds.includes(match.machine.id)}
                  onSelectForCompare={() => toggleCompare(match.machine.id)}
                  onBookClick={() => navigate('/bookings')}
                  onViewDetails={() => alert(`Machine specs for ${match.machine.machine_name}`)}
                  onViewMatchBreakdown={() => alert(`Score breakdown: Total ${(match.match_percentage).toFixed(0)}%`)}
                />
              ))}
            </div>
          )}
        </div>

      </div>

      {/* COMPARE MACHINES MODAL */}
      {showCompareModal && (
        <div className="fixed inset-0 bg-slate-950/80 backdrop-blur-md z-50 flex items-center justify-center p-4">
          <div className="bg-slate-900 border border-slate-800 rounded-3xl max-w-4xl w-full p-6 space-y-6 max-h-[90vh] overflow-y-auto">
            <div className="flex justify-between items-center pb-3 border-b border-slate-800">
              <div>
                <h3 className="text-lg font-black text-white">Side-by-Side Machine Comparison</h3>
                <p className="text-xs text-slate-400">Comparing technical specs, distance, rates, and reliability</p>
              </div>
              <button
                onClick={() => setShowCompareModal(false)}
                className="px-3 py-1 bg-slate-800 hover:bg-slate-700 text-slate-300 rounded-xl text-xs font-bold"
              >
                Close
              </button>
            </div>

            <div className="overflow-x-auto text-xs">
              <table className="w-full text-left border-collapse">
                <thead>
                  <tr className="border-b border-slate-800 text-slate-400">
                    <th className="p-3">Feature Factor</th>
                    {comparedMachineIds.map(id => {
                      const m = matches.find(item => item.machine.id === id);
                      return (
                        <th key={id} className="p-3 font-bold text-white">
                          {m?.machine.machine_name}
                        </th>
                      );
                    })}
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-800 text-slate-300 font-mono">
                  <tr>
                    <td className="p-3 font-semibold text-slate-400 font-sans">Match Score</td>
                    {comparedMachineIds.map(id => {
                      const m = matches.find(item => item.machine.id === id);
                      return <td key={id} className="p-3 font-bold text-emerald-400">{m?.match_percentage}% Match</td>;
                    })}
                  </tr>
                  <tr>
                    <td className="p-3 font-semibold text-slate-400 font-sans">Location / Distance</td>
                    {comparedMachineIds.map(id => {
                      const m = matches.find(item => item.machine.id === id);
                      return <td key={id} className="p-3">{m?.machine.location} ({m?.distance_km} km)</td>;
                    })}
                  </tr>
                  <tr>
                    <td className="p-3 font-semibold text-slate-400 font-sans">Hourly Rate</td>
                    {comparedMachineIds.map(id => {
                      const m = matches.find(item => item.machine.id === id);
                      return <td key={id} className="p-3 text-emerald-400 font-bold">₹{m?.machine.hourly_rate}/hr</td>;
                    })}
                  </tr>
                  <tr>
                    <td className="p-3 font-semibold text-slate-400 font-sans">Rating & Reliability</td>
                    {comparedMachineIds.map(id => {
                      const m = matches.find(item => item.machine.id === id);
                      return <td key={id} className="p-3">⭐ {m?.machine.avg_rating || 4.9} (96/100)</td>;
                    })}
                  </tr>
                  <tr>
                    <td className="p-3 font-semibold text-slate-400 font-sans">Verification Status</td>
                    {comparedMachineIds.map(id => {
                      const m = matches.find(item => item.machine.id === id);
                      return <td key={id} className="p-3 text-emerald-400">✓ Verified MSME Unit</td>;
                    })}
                  </tr>
                </tbody>
              </table>
            </div>

            <div className="pt-3 border-t border-slate-800 flex justify-end gap-3">
              <button
                onClick={() => {
                  setShowCompareModal(false);
                  navigate('/bookings');
                }}
                className="px-6 py-3 bg-blue-600 hover:bg-blue-500 text-white font-bold rounded-xl text-xs shadow-lg shadow-blue-600/25"
              >
                Proceed to Request Booking
              </button>
            </div>
          </div>
        </div>
      )}

    </div>
  );
};
