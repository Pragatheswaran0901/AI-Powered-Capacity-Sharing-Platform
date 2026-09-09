import React, { useEffect, useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { api } from '../services/api';
import { Machine, Requirement, MatchResult } from '../types';
import { MachineCard } from '../components/MachineCard';
import { MatchDetailModal } from '../components/MatchDetailModal';
import { CompareModal } from '../components/CompareModal';
import { MapView } from '../components/MapView';
import { PaymentMockModal } from '../components/PaymentMockModal';
import {
  Search,
  PlusCircle,
  Filter,
  SlidersHorizontal,
  MapPin,
  Sparkles,
  AlertCircle,
  ArrowRight,
  Cpu,
  ShieldCheck,
  CheckCircle2,
  TrendingUp,
  X
} from 'lucide-react';

export const SeekerDashboard: React.FC = () => {
  const navigate = useNavigate();
  const [requirements, setRequirements] = useState<Requirement[]>([]);
  const [selectedReq, setSelectedReq] = useState<Requirement | null>(null);
  const [matches, setMatches] = useState<MatchResult[]>([]);
  const [loading, setLoading] = useState<boolean>(true);

  // Modals state
  const [selectedMatchForBreakdown, setSelectedMatchForBreakdown] = useState<MatchResult | null>(null);
  const [comparedMatches, setComparedMatches] = useState<MatchResult[]>([]);
  const [showCompareModal, setShowCompareModal] = useState<boolean>(false);
  const [bookingMatchTarget, setBookingMatchTarget] = useState<MatchResult | null>(null);

  // Filter controls
  const [cityFilter, setCityFilter] = useState<string>('all');
  const [processFilter, setProcessFilter] = useState<string>('all');
  const [searchQuery, setSearchQuery] = useState<string>('');

  useEffect(() => {
    loadData();
  }, []);

  async function loadData() {
    setLoading(true);
    const reqs = await api.getRequirements();
    setRequirements(reqs);

    if (reqs.length > 0) {
      const activeReq = reqs[0];
      setSelectedReq(activeReq);
      const matchItems = await api.getMatchesForRequirement(activeReq.id);
      setMatches(matchItems);
    }
    setLoading(false);
  }

  const handleSelectRequirement = async (req: Requirement) => {
    setSelectedReq(req);
    setLoading(true);
    const matchItems = await api.getMatchesForRequirement(req.id);
    setMatches(matchItems);
    setLoading(false);
  };

  const toggleCompare = (match: MatchResult) => {
    if (comparedMatches.some(x => x.machine.id === match.machine.id)) {
      setComparedMatches(comparedMatches.filter(x => x.machine.id !== match.machine.id));
    } else {
      if (comparedMatches.length >= 3) return;
      setComparedMatches([...comparedMatches, match]);
    }
  };

  const handleCreateBooking = async (match: MatchResult) => {
    if (!selectedReq) return;
    try {
      await api.createBooking({
        requirement_id: selectedReq.id,
        machine_id: match.machine.id,
        booking_date: new Date().toISOString().split('T')[0],
        start_time: '09:00',
        end_time: '17:00',
        quantity: selectedReq.quantity,
        agreed_price: match.machine.hourly_rate * 25
      });
      setBookingMatchTarget(match);
    } catch (e) {
      setBookingMatchTarget(match);
    }
  };

  const filteredMatches = matches.filter((m) => {
    const city = m.machine.msme_city || m.machine.location || '';
    if (cityFilter !== 'all' && !city.toLowerCase().includes(cityFilter.toLowerCase())) return false;
    if (processFilter !== 'all' && !m.machine.machine_type.toLowerCase().includes(processFilter.toLowerCase())) return false;
    if (searchQuery && !m.machine.machine_name.toLowerCase().includes(searchQuery.toLowerCase()) && !(m.machine.msme_name || '').toLowerCase().includes(searchQuery.toLowerCase())) return false;
    return true;
  });

  return (
    <div className="min-h-screen bg-slate-900 text-slate-100 pb-20 font-sans">
      {/* Top Banner Header */}
      <div className="bg-gradient-to-r from-slate-950 via-slate-900 to-blue-950 border-b border-slate-800 py-8 px-4 sm:px-6 lg:px-8">
        <div className="max-w-7xl mx-auto flex flex-col lg:flex-row justify-between items-start lg:items-center gap-6">
          <div className="space-y-1">
            <div className="inline-flex items-center gap-2 px-3 py-1 bg-blue-500/10 border border-blue-500/20 rounded-full text-blue-400 text-xs font-semibold">
              <Sparkles className="w-3.5 h-3.5" />
              <span>AI-Powered MSME Capacity Match Engine</span>
            </div>
            <h1 className="text-2xl sm:text-3xl font-black text-white">Find Manufacturing Capacity</h1>
            <p className="text-xs text-slate-400">
              Browse verified CNC machinery in Tamil Nadu, compare weighted capability scores, and reserve slot schedules.
            </p>
          </div>

          <div className="flex flex-wrap items-center gap-3 w-full lg:w-auto">
            <Link
              to="/requirements/new"
              className="px-5 py-3 bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-500 hover:to-indigo-500 text-white font-bold rounded-2xl text-xs flex items-center gap-2 transition-all shadow-lg shadow-blue-600/25 shrink-0"
            >
              <PlusCircle className="w-4 h-4" />
              Post Manufacturing Requirement
            </Link>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 mt-8">
        
        {/* KPI Stats Strip */}
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
          <div className="bg-slate-950/70 p-4 rounded-2xl border border-slate-800 flex items-center gap-4">
            <div className="w-10 h-10 bg-blue-500/10 rounded-xl flex items-center justify-center text-blue-400 border border-blue-500/20">
              <Cpu className="w-5 h-5" />
            </div>
            <div>
              <span className="text-[10px] text-slate-400 uppercase font-semibold block">Available Fleet</span>
              <span className="text-lg font-black text-white font-mono">{matches.length} CNC Units</span>
            </div>
          </div>

          <div className="bg-slate-950/70 p-4 rounded-2xl border border-slate-800 flex items-center gap-4">
            <div className="w-10 h-10 bg-emerald-500/10 rounded-xl flex items-center justify-center text-emerald-400 border border-emerald-500/20">
              <Sparkles className="w-5 h-5" />
            </div>
            <div>
              <span className="text-[10px] text-slate-400 uppercase font-semibold block">Top Match Score</span>
              <span className="text-lg font-black text-emerald-400 font-mono">
                {matches.length > 0 ? `${Math.round(matches[0].match_percentage || matches[0].total_score * 100)}% Match` : '96% Match'}
              </span>
            </div>
          </div>

          <div className="bg-slate-950/70 p-4 rounded-2xl border border-slate-800 flex items-center gap-4">
            <div className="w-10 h-10 bg-amber-500/10 rounded-xl flex items-center justify-center text-amber-400 border border-amber-500/20">
              <MapPin className="w-5 h-5" />
            </div>
            <div>
              <span className="text-[10px] text-slate-400 uppercase font-semibold block">Industrial Hubs</span>
              <span className="text-lg font-black text-white font-mono">Coimbatore & TN</span>
            </div>
          </div>

          <div className="bg-slate-950/70 p-4 rounded-2xl border border-slate-800 flex items-center gap-4">
            <div className="w-10 h-10 bg-indigo-500/10 rounded-xl flex items-center justify-center text-indigo-400 border border-indigo-500/20">
              <ShieldCheck className="w-5 h-5" />
            </div>
            <div>
              <span className="text-[10px] text-slate-400 uppercase font-semibold block">Security Level</span>
              <span className="text-lg font-black text-indigo-300 font-mono">Verified MSMEs</span>
            </div>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8">
          
          {/* Left Column: Active Requirements Selector */}
          <div className="lg:col-span-4 space-y-4">
            <div className="flex justify-between items-center bg-slate-950/80 p-3 rounded-2xl border border-slate-800">
              <h3 className="text-xs font-bold text-slate-300 uppercase tracking-wider">Your Active Requirements</h3>
              <span className="text-[10px] bg-blue-500/10 text-blue-400 px-2 py-0.5 rounded-full border border-blue-500/20 font-mono font-bold">
                {requirements.length} Active
              </span>
            </div>

            <div className="space-y-3">
              {requirements.map((req) => {
                const isSelected = selectedReq?.id === req.id;
                return (
                  <div
                    key={req.id}
                    onClick={() => handleSelectRequirement(req)}
                    className={`p-5 rounded-2xl border transition-all cursor-pointer space-y-3 ${
                      isSelected
                        ? 'bg-blue-950/40 border-blue-500/80 shadow-lg shadow-blue-500/10 ring-1 ring-blue-500/50'
                        : 'bg-slate-950/60 border-slate-800 hover:border-slate-700'
                    }`}
                  >
                    <div className="flex justify-between items-start gap-2">
                      <h4 className="font-extrabold text-sm text-white line-clamp-1">{req.title}</h4>
                      <span className="text-[10px] font-mono font-bold px-2 py-0.5 rounded-full bg-blue-500/20 text-blue-300 border border-blue-500/30 shrink-0">
                        Qty: {req.quantity}
                      </span>
                    </div>

                    <p className="text-xs text-slate-400 line-clamp-2 leading-relaxed">{req.description}</p>

                    <div className="pt-3 border-t border-slate-800/80 flex items-center justify-between text-xs">
                      <span className="font-semibold text-slate-300">{req.process} • {req.material}</span>
                      <span className="font-mono font-black text-emerald-400">₹{req.budget.toLocaleString('en-IN')}</span>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>

          {/* Right Column: Search, Filters, Map & Machine Cards */}
          <div className="lg:col-span-8 space-y-6">
            
            {/* Filter Bar */}
            <div className="bg-slate-950/80 p-4 rounded-2xl border border-slate-800 space-y-3">
              <div className="flex flex-col sm:flex-row items-center gap-3">
                <div className="relative flex-1 w-full">
                  <Search className="w-4 h-4 text-slate-500 absolute left-3.5 top-3" />
                  <input
                    type="text"
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                    placeholder="Search by Machine name or MSME facility..."
                    className="w-full pl-10 pr-4 py-2.5 bg-slate-900 border border-slate-800 rounded-xl text-xs text-white placeholder-slate-500 focus:ring-2 focus:ring-blue-500 focus:outline-none"
                  />
                </div>

                <div className="flex items-center gap-2 w-full sm:w-auto">
                  <select
                    value={cityFilter}
                    onChange={(e) => setCityFilter(e.target.value)}
                    className="px-3 py-2.5 bg-slate-900 border border-slate-800 rounded-xl text-xs text-slate-300 font-semibold focus:ring-2 focus:ring-blue-500 focus:outline-none flex-1 sm:flex-none"
                  >
                    <option value="all">All Cities (TN)</option>
                    <option value="Coimbatore">Coimbatore</option>
                    <option value="Chennai">Chennai</option>
                    <option value="Hosur">Hosur</option>
                    <option value="Salem">Salem</option>
                  </select>

                  <select
                    value={processFilter}
                    onChange={(e) => setProcessFilter(e.target.value)}
                    className="px-3 py-2.5 bg-slate-900 border border-slate-800 rounded-xl text-xs text-slate-300 font-semibold focus:ring-2 focus:ring-blue-500 focus:outline-none flex-1 sm:flex-none"
                  >
                    <option value="all">All Machining Processes</option>
                    <option value="VMC">VMC Milling</option>
                    <option value="CNC Turning">CNC Turning</option>
                    <option value="5-Axis">5-Axis CNC</option>
                    <option value="Laser">Laser Cutting</option>
                  </select>
                </div>
              </div>
            </div>

            {/* Selected Requirement Detail Header */}
            {selectedReq && (
              <div className="bg-gradient-to-br from-slate-950 via-slate-950 to-blue-950/60 p-5 rounded-2xl border border-slate-800 space-y-3">
                <div className="flex justify-between items-start">
                  <div>
                    <span className="text-[10px] font-bold text-blue-400 bg-blue-500/10 px-2.5 py-0.5 rounded-full border border-blue-500/20 uppercase tracking-wide">
                      Target Requirement Selected
                    </span>
                    <h2 className="text-lg font-black text-white mt-1">{selectedReq.title}</h2>
                    <p className="text-xs text-slate-400 mt-0.5">{selectedReq.description}</p>
                  </div>
                  <div className="text-right">
                    <span className="text-[10px] text-slate-400 block uppercase font-semibold">Target Budget</span>
                    <span className="text-xl font-black text-emerald-400 font-mono">
                      ₹{selectedReq.budget.toLocaleString('en-IN')}
                    </span>
                  </div>
                </div>

                <div className="flex flex-wrap gap-4 pt-3 text-xs border-t border-slate-800/80">
                  <div><span className="text-slate-500">Process:</span> <span className="font-bold text-white">{selectedReq.process}</span></div>
                  <div><span className="text-slate-500">Material:</span> <span className="font-bold text-white">{selectedReq.material}</span></div>
                  <div><span className="text-slate-500">Deadline:</span> <span className="font-bold text-blue-400">{selectedReq.deadline}</span></div>
                  <div><span className="text-slate-500">Location:</span> <span className="font-bold text-white">{selectedReq.preferred_city}</span></div>
                </div>
              </div>
            )}

            {/* Compare Bar */}
            {comparedMatches.length > 0 && (
              <div className="bg-blue-950/90 text-white p-4 rounded-2xl border border-blue-500/50 flex justify-between items-center shadow-xl backdrop-blur-md">
                <div className="flex items-center gap-2 text-xs font-semibold">
                  <Sparkles className="w-4 h-4 text-blue-400" />
                  <span>{comparedMatches.length} machines queued for capability comparison.</span>
                </div>
                <div className="flex items-center gap-2">
                  <button
                    onClick={() => setComparedMatches([])}
                    className="px-3 py-1.5 text-xs text-slate-300 hover:text-white font-medium"
                  >
                    Clear
                  </button>
                  <button
                    onClick={() => setShowCompareModal(true)}
                    className="px-4 py-2 bg-blue-600 hover:bg-blue-500 text-white font-bold rounded-xl text-xs shadow-lg shadow-blue-600/25"
                  >
                    Compare Specs Side-by-Side
                  </button>
                </div>
              </div>
            )}

            {/* Map View */}
            <MapView
              machines={filteredMatches.map(m => m.machine)}
              matches={filteredMatches}
            />

            {/* Recommended Capacity Grid */}
            <div className="space-y-4">
              <div className="flex justify-between items-center">
                <div>
                  <h3 className="text-base font-extrabold text-white">Recommended Capacity Providers</h3>
                  <p className="text-xs text-slate-400">Ranked by AI Match Score (Capability, Rate, SLA, Proximity)</p>
                </div>
                <span className="text-xs text-emerald-400 bg-emerald-500/10 border border-emerald-500/20 px-3 py-1 rounded-full font-mono font-bold">
                  {filteredMatches.length} Compatible Units
                </span>
              </div>

              {loading ? (
                <div className="py-16 text-center text-slate-400 text-xs font-mono bg-slate-950/40 rounded-2xl border border-slate-800">
                  <div className="w-6 h-6 border-2 border-blue-500 border-t-transparent rounded-full animate-spin mx-auto mb-2"></div>
                  Calculating match scores across industrial clusters...
                </div>
              ) : filteredMatches.length === 0 ? (
                <div className="py-16 text-center text-slate-400 text-xs bg-slate-950/40 rounded-2xl border border-slate-800">
                  No capacity machines match the selected filter criteria.
                </div>
              ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  {filteredMatches.map((matchItem) => (
                    <MachineCard
                      key={matchItem.machine.id}
                      machine={matchItem.machine}
                      matchResult={matchItem}
                      onSelectForCompare={() => toggleCompare(matchItem)}
                      isCompared={comparedMatches.some(x => x.machine.id === matchItem.machine.id)}
                      onBookClick={() => handleCreateBooking(matchItem)}
                      onViewMatchBreakdown={() => setSelectedMatchForBreakdown(matchItem)}
                    />
                  ))}
                </div>
              )}
            </div>

          </div>
        </div>
      </div>

      {/* Modals */}
      {selectedMatchForBreakdown && (
        <MatchDetailModal
          match={selectedMatchForBreakdown}
          onClose={() => setSelectedMatchForBreakdown(null)}
        />
      )}

      {showCompareModal && (
        <CompareModal
          items={comparedMatches}
          onClose={() => setShowCompareModal(false)}
          onBookMachine={(m) => {
            setShowCompareModal(false);
            handleCreateBooking(m);
          }}
        />
      )}

      {bookingMatchTarget && (
        <PaymentMockModal
          agreedPrice={bookingMatchTarget.machine.hourly_rate * 25}
          machineName={bookingMatchTarget.machine.machine_name}
          ownerName={bookingMatchTarget.machine.msme_name || 'Kovai Precision Works'}
          onSuccess={() => {
            setBookingMatchTarget(null);
            navigate('/bookings');
          }}
          onClose={() => setBookingMatchTarget(null)}
        />
      )}
    </div>
  );
};

