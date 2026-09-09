import React, { useEffect, useState } from 'react';
import { api } from '../services/api';
import { Booking } from '../types';
import { RatingModal } from '../components/RatingModal';
import {
  Calendar,
  CheckCircle2,
  Clock,
  Star,
  ArrowRight,
  ShieldCheck,
  User,
  FileText,
  Activity,
  Cpu,
  Download,
  Printer,
  CreditCard,
  Building2,
  MapPin,
  Wrench,
  AlertCircle,
  Sparkles,
  Filter,
  Check,
  X
} from 'lucide-react';

export const BookingsPage: React.FC = () => {
  const [bookings, setBookings] = useState<Booking[]>([]);
  const [loading, setLoading] = useState(true);
  const [activeModeTab, setActiveModeTab] = useState<'seeking' | 'providing'>('seeking');
  const [filterTab, setFilterTab] = useState<'all' | 'pending' | 'in_progress' | 'completed'>('all');

  // Modals state
  const [ratingBookingTarget, setRatingBookingTarget] = useState<Booking | null>(null);
  const [invoiceBookingTarget, setInvoiceBookingTarget] = useState<Booking | null>(null);
  const [telemetryBookingTarget, setTelemetryBookingTarget] = useState<Booking | null>(null);
  const [payEscrowTarget, setPayEscrowTarget] = useState<Booking | null>(null);

  useEffect(() => {
    loadBookings();
  }, []);

  async function loadBookings() {
    setLoading(true);
    const data = await api.getBookings();
    setBookings(data);
    setLoading(false);
  }

  const handleUpdateStatus = async (bookingId: number, status: string) => {
    await api.updateBookingStatus(bookingId, status);
    loadBookings();
  };

  const handleReviewSubmit = async (reviewData: any) => {
    await api.createReview(reviewData);
    setRatingBookingTarget(null);
    loadBookings();
  };

  const handleSimulatePayment = async (bookingId: number) => {
    await api.updateBookingStatus(bookingId, 'confirmed');
    setPayEscrowTarget(null);
    loadBookings();
  };

  const filteredBookings = bookings.filter((b) => {
    if (filterTab === 'pending') return b.status === 'pending';
    if (filterTab === 'in_progress') return b.status === 'confirmed' || b.status === 'accepted' || b.status === 'in_progress';
    if (filterTab === 'completed') return b.status === 'completed';
    return true;
  });

  const totalValue = bookings.reduce((sum, b) => sum + (b.agreed_price || 0), 0);
  const activeCount = bookings.filter((b) => b.status !== 'completed' && b.status !== 'cancelled').length;
  const completedCount = bookings.filter((b) => b.status === 'completed').length;

  return (
    <div className="min-h-screen bg-slate-900 text-slate-100 pb-20 font-sans">
      {/* Top Banner Header */}
      <div className="bg-gradient-to-r from-slate-950 via-slate-900 to-blue-950 border-b border-slate-800 py-8 px-4 sm:px-6 lg:px-8">
        <div className="max-w-7xl mx-auto flex flex-col md:flex-row justify-between items-start md:items-center gap-6">
          <div className="space-y-1">
            <div className="inline-flex items-center gap-2 px-3 py-1 bg-blue-500/10 border border-blue-500/20 rounded-full text-blue-400 text-xs font-semibold">
              <Sparkles className="w-3.5 h-3.5" />
              <span>Production Order Lifecycle & Escrow Manager</span>
            </div>
            <h1 className="text-2xl sm:text-3xl font-black text-white">Capacity Booking Hub</h1>
            <p className="text-xs text-slate-400">
              Track manufacturing job stages, inspect live IoT machine telemetry, download GST invoices, and verify escrow milestones.
            </p>
          </div>

          {/* Quick Stats Cards */}
          <div className="flex items-center gap-3 w-full md:w-auto">
            <div className="bg-slate-800/80 p-3 rounded-2xl border border-slate-700/80 flex-1 md:flex-none min-w-[120px]">
              <span className="text-[10px] text-slate-400 uppercase font-bold tracking-wider block">Total Orders</span>
              <span className="text-xl font-black text-white font-mono">{bookings.length}</span>
            </div>
            <div className="bg-slate-800/80 p-3 rounded-2xl border border-slate-700/80 flex-1 md:flex-none min-w-[120px]">
              <span className="text-[10px] text-slate-400 uppercase font-bold tracking-wider block">Active Jobs</span>
              <span className="text-xl font-black text-blue-400 font-mono">{activeCount}</span>
            </div>
            <div className="bg-slate-800/80 p-3 rounded-2xl border border-slate-700/80 flex-1 md:flex-none min-w-[140px]">
              <span className="text-[10px] text-slate-400 uppercase font-bold tracking-wider block">Escrow Capital</span>
              <span className="text-xl font-black text-emerald-400 font-mono">₹{totalValue.toLocaleString('en-IN')}</span>
            </div>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 mt-8 space-y-6">
        
        {/* MUTUALLY INCLUSIVE DUAL SECTIONS TAB (Capacity I am Booking vs Capacity I am Providing) */}
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <button
            onClick={() => setActiveModeTab('seeking')}
            className={`p-5 rounded-3xl border text-left transition-all flex items-center justify-between cursor-pointer ${
              activeModeTab === 'seeking'
                ? 'bg-blue-950/60 border-blue-500 shadow-xl text-white'
                : 'bg-slate-950/80 border-slate-800 text-slate-400 hover:border-slate-700'
            }`}
          >
            <div className="space-y-1">
              <span className="text-[10px] font-black uppercase tracking-wider text-blue-400 bg-blue-500/10 border border-blue-500/20 px-2.5 py-0.5 rounded-full font-mono">
                OUTBOUND • Rented Capacity
              </span>
              <h3 className="text-base font-extrabold text-white">🔷 Capacity I am Booking</h3>
              <p className="text-xs text-slate-400">Machines rented from other MSMEs for your production requirements</p>
            </div>
            <div className="w-8 h-8 rounded-2xl bg-blue-600/20 border border-blue-500/30 text-blue-400 flex items-center justify-center font-bold text-sm shrink-0">
              3
            </div>
          </button>

          <button
            onClick={() => setActiveModeTab('providing')}
            className={`p-5 rounded-3xl border text-left transition-all flex items-center justify-between cursor-pointer ${
              activeModeTab === 'providing'
                ? 'bg-amber-950/60 border-amber-500 shadow-xl text-white'
                : 'bg-slate-950/80 border-slate-800 text-slate-400 hover:border-slate-700'
            }`}
          >
            <div className="space-y-1">
              <span className="text-[10px] font-black uppercase tracking-wider text-amber-400 bg-amber-500/10 border border-amber-500/20 px-2.5 py-0.5 rounded-full font-mono">
                INBOUND • Provided Capacity
              </span>
              <h3 className="text-base font-extrabold text-white">🟩 Capacity I am Providing</h3>
              <p className="text-xs text-slate-400">Incoming bookings from other MSMEs renting your machine hours</p>
            </div>
            <div className="w-8 h-8 rounded-2xl bg-amber-500/20 border border-amber-500/30 text-amber-400 flex items-center justify-center font-bold text-sm shrink-0">
              2
            </div>
          </button>
        </div>
        
        {/* Navigation & Filter Bar */}
        <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 bg-slate-950/60 p-2 rounded-2xl border border-slate-800">
          <div className="flex items-center gap-1 overflow-x-auto w-full sm:w-auto">
            <button
              onClick={() => setFilterTab('all')}
              className={`px-4 py-2 rounded-xl text-xs font-bold transition-all flex items-center gap-2 shrink-0 ${
                filterTab === 'all'
                  ? 'bg-blue-600 text-white shadow-lg shadow-blue-600/25'
                  : 'text-slate-400 hover:text-white hover:bg-slate-800'
              }`}
            >
              <span>All Bookings</span>
              <span className="px-1.5 py-0.2 bg-slate-900/50 rounded text-[10px]">{bookings.length}</span>
            </button>

            <button
              onClick={() => setFilterTab('pending')}
              className={`px-4 py-2 rounded-xl text-xs font-bold transition-all flex items-center gap-2 shrink-0 ${
                filterTab === 'pending'
                  ? 'bg-amber-600 text-white shadow-lg shadow-amber-600/25'
                  : 'text-slate-400 hover:text-white hover:bg-slate-800'
              }`}
            >
              <span>Pending Action</span>
              <span className="px-1.5 py-0.2 bg-slate-900/50 rounded text-[10px]">
                {bookings.filter(b => b.status === 'pending').length}
              </span>
            </button>

            <button
              onClick={() => setFilterTab('in_progress')}
              className={`px-4 py-2 rounded-xl text-xs font-bold transition-all flex items-center gap-2 shrink-0 ${
                filterTab === 'in_progress'
                  ? 'bg-emerald-600 text-white shadow-lg shadow-emerald-600/25'
                  : 'text-slate-400 hover:text-white hover:bg-slate-800'
              }`}
            >
              <span>In Production & Escrow</span>
              <span className="px-1.5 py-0.2 bg-slate-900/50 rounded text-[10px]">{activeCount}</span>
            </button>

            <button
              onClick={() => setFilterTab('completed')}
              className={`px-4 py-2 rounded-xl text-xs font-bold transition-all flex items-center gap-2 shrink-0 ${
                filterTab === 'completed'
                  ? 'bg-indigo-600 text-white shadow-lg shadow-indigo-600/25'
                  : 'text-slate-400 hover:text-white hover:bg-slate-800'
              }`}
            >
              <span>Completed</span>
              <span className="px-1.5 py-0.2 bg-slate-900/50 rounded text-[10px]">{completedCount}</span>
            </button>
          </div>

          <div className="text-xs text-slate-400 px-3 py-1 font-mono">
            Filter: <span className="text-white font-bold uppercase">{filterTab}</span>
          </div>
        </div>

        {/* Bookings List Container */}
        {loading ? (
          <div className="text-center py-20 bg-slate-950/40 rounded-3xl border border-slate-800">
            <div className="w-8 h-8 border-2 border-blue-500 border-t-transparent rounded-full animate-spin mx-auto mb-3"></div>
            <p className="text-xs text-slate-400">Loading booking telemetry contracts...</p>
          </div>
        ) : filteredBookings.length === 0 ? (
          <div className="text-center py-20 bg-slate-950/40 rounded-3xl border border-slate-800 space-y-3">
            <Calendar className="w-12 h-12 text-slate-600 mx-auto" />
            <h3 className="text-base font-bold text-white">No Bookings Found</h3>
            <p className="text-xs text-slate-400 max-w-sm mx-auto">
              There are no capacity bookings matching the selected filter tab.
            </p>
          </div>
        ) : (
          <div className="space-y-4">
            {filteredBookings.map((b) => {
              const isCompleted = b.status === 'completed';
              const isConfirmed = b.status === 'confirmed' || b.status === 'accepted';
              const isPending = b.status === 'pending';

              return (
                <div
                  key={b.id}
                  className="bg-slate-950/80 border border-slate-800/90 hover:border-slate-700/90 rounded-3xl p-6 transition-all space-y-6 shadow-xl relative overflow-hidden group"
                >
                  {/* Top Row Header */}
                  <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 border-b border-slate-800/80 pb-4">
                    <div className="space-y-1">
                      <div className="flex flex-wrap items-center gap-2">
                        <span className="text-xs font-black text-blue-400 bg-blue-500/10 border border-blue-500/20 px-3 py-1 rounded-full font-mono">
                          BOOKING #{b.id}
                        </span>
                        <span className="text-xs font-bold text-white bg-slate-800 px-3 py-1 rounded-full border border-slate-700 flex items-center gap-1.5">
                          <Cpu className="w-3.5 h-3.5 text-blue-400" />
                          {b.machine_name || 'Haas VMC CNC Milling Machine'}
                        </span>
                        <span className={`text-[10px] font-black px-2.5 py-1 rounded-full uppercase tracking-wider font-mono ${
                          isCompleted
                            ? 'bg-emerald-500/20 text-emerald-300 border border-emerald-500/30'
                            : isConfirmed
                            ? 'bg-blue-500/20 text-blue-300 border border-blue-500/30'
                            : 'bg-amber-500/20 text-amber-300 border border-amber-500/30'
                        }`}>
                          ● {b.status.replace('_', ' ')}
                        </span>
                      </div>

                      <h3 className="text-base font-bold text-white pt-1">
                        {b.seeker_company_name || 'TamilTech Components'} → Provider: {b.owner_company_name || 'Kovai Precision Works'}
                      </h3>
                    </div>

                    {/* Contract Value & Escrow Badge */}
                    <div className="text-left md:text-right bg-slate-900/90 p-3 rounded-2xl border border-slate-800 flex md:block items-center justify-between w-full md:w-auto gap-4">
                      <div>
                        <span className="text-[10px] text-slate-400 font-semibold block uppercase tracking-wider">Agreed Contract Price</span>
                        <span className="text-xl font-black text-emerald-400 font-mono">
                          ₹{b.agreed_price ? b.agreed_price.toLocaleString('en-IN') : '25,000'}
                        </span>
                      </div>
                      <span className="text-[10px] text-blue-400 font-semibold flex items-center gap-1 mt-0.5 justify-end">
                        <ShieldCheck className="w-3 h-3 text-blue-400" /> Escrow Protected
                      </span>
                    </div>
                  </div>

                  {/* 5-Stage Visual Stepper */}
                  <div className="bg-slate-900/60 p-5 rounded-2xl border border-slate-800/80">
                    <div className="grid grid-cols-5 gap-2 text-center relative">
                      {/* Line connector */}
                      <div className="absolute top-4 left-6 right-6 h-0.5 bg-slate-800 -z-0"></div>

                      <div className="space-y-2 relative z-10">
                        <div className="w-8 h-8 bg-emerald-600 text-white font-bold rounded-full flex items-center justify-center mx-auto text-xs ring-4 ring-slate-900">
                          ✓
                        </div>
                        <span className="text-[11px] font-bold text-emerald-400 block">Requested</span>
                        <span className="text-[9px] text-slate-500 font-mono block">Order Created</span>
                      </div>

                      <div className="space-y-2 relative z-10">
                        <div className={`w-8 h-8 rounded-full font-bold flex items-center justify-center mx-auto text-xs ring-4 ring-slate-900 ${
                          b.status !== 'pending' ? 'bg-emerald-600 text-white' : 'bg-amber-500 text-white animate-pulse'
                        }`}>
                          {b.status !== 'pending' ? '✓' : '2'}
                        </div>
                        <span className={`text-[11px] font-bold block ${b.status !== 'pending' ? 'text-emerald-400' : 'text-amber-400'}`}>
                          Owner Confirmed
                        </span>
                        <span className="text-[9px] text-slate-500 font-mono block">Capacity Locked</span>
                      </div>

                      <div className="space-y-2 relative z-10">
                        <div className={`w-8 h-8 rounded-full font-bold flex items-center justify-center mx-auto text-xs ring-4 ring-slate-900 ${
                          isConfirmed || isCompleted ? 'bg-emerald-600 text-white' : 'bg-slate-800 text-slate-500'
                        }`}>
                          {isConfirmed || isCompleted ? '✓' : '3'}
                        </div>
                        <span className={`text-[11px] font-bold block ${isConfirmed || isCompleted ? 'text-emerald-400' : 'text-slate-500'}`}>
                          Escrow Deposited
                        </span>
                        <span className="text-[9px] text-slate-500 font-mono block">Funds Secured</span>
                      </div>

                      <div className="space-y-2 relative z-10">
                        <div className={`w-8 h-8 rounded-full font-bold flex items-center justify-center mx-auto text-xs ring-4 ring-slate-900 ${
                          isConfirmed || isCompleted ? 'bg-emerald-600 text-white animate-pulse' : 'bg-slate-800 text-slate-500'
                        }`}>
                          {isConfirmed || isCompleted ? '✓' : '4'}
                        </div>
                        <span className={`text-[11px] font-bold block ${isConfirmed || isCompleted ? 'text-emerald-400' : 'text-slate-500'}`}>
                          Machining IoT
                        </span>
                        <span className="text-[9px] text-slate-500 font-mono block">Telemetry Active</span>
                      </div>

                      <div className="space-y-2 relative z-10">
                        <div className={`w-8 h-8 rounded-full font-bold flex items-center justify-center mx-auto text-xs ring-4 ring-slate-900 ${
                          isCompleted ? 'bg-emerald-600 text-white' : 'bg-slate-800 text-slate-500'
                        }`}>
                          {isCompleted ? '✓' : '5'}
                        </div>
                        <span className={`text-[11px] font-bold block ${isCompleted ? 'text-emerald-400' : 'text-slate-500'}`}>
                          QC & Delivered
                        </span>
                        <span className="text-[9px] text-slate-500 font-mono block">Rated MSME</span>
                      </div>
                    </div>
                  </div>

                  {/* Details Bar & Action Controls */}
                  <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 pt-2 text-xs border-t border-slate-800/60">
                    <div className="flex flex-wrap items-center gap-4 text-slate-400 font-medium">
                      <span className="flex items-center gap-1.5 font-mono">
                        <Calendar className="w-3.5 h-3.5 text-slate-500" />
                        {b.booking_date} ({b.start_time} - {b.end_time})
                      </span>
                      <span className="flex items-center gap-1 font-mono text-slate-300">
                        Batch Qty: <strong className="text-white">{b.quantity} Nos</strong>
                      </span>
                    </div>

                    <div className="flex flex-wrap items-center gap-2.5 w-full sm:w-auto">
                      {/* Telemetry Drawer trigger */}
                      <button
                        onClick={() => setTelemetryBookingTarget(b)}
                        className="px-3 py-2 bg-slate-900 hover:bg-slate-800 border border-slate-700 text-blue-400 font-bold rounded-xl text-xs flex items-center gap-1.5 transition-all shadow-sm"
                      >
                        <Activity className="w-3.5 h-3.5 text-blue-400" />
                        <span>IoT Telemetry</span>
                      </button>

                      {/* GST Invoice Drawer trigger */}
                      <button
                        onClick={() => setInvoiceBookingTarget(b)}
                        className="px-3 py-2 bg-slate-900 hover:bg-slate-800 border border-slate-700 text-slate-200 font-bold rounded-xl text-xs flex items-center gap-1.5 transition-all shadow-sm"
                      >
                        <FileText className="w-3.5 h-3.5 text-slate-400" />
                        <span>GST Invoice</span>
                      </button>

                      {/* Actions based on state */}
                      {isPending && (
                        <button
                          onClick={() => setPayEscrowTarget(b)}
                          className="px-4 py-2 bg-amber-600 hover:bg-amber-500 text-white font-bold rounded-xl text-xs flex items-center gap-1.5 transition-all shadow-lg shadow-amber-600/25"
                        >
                          <CreditCard className="w-3.5 h-3.5" />
                          <span>Deposit Escrow</span>
                        </button>
                      )}

                      {isConfirmed && (
                        <button
                          onClick={() => handleUpdateStatus(b.id, 'completed')}
                          className="px-4 py-2 bg-emerald-600 hover:bg-emerald-500 text-white font-bold rounded-xl text-xs flex items-center gap-1.5 transition-all shadow-lg shadow-emerald-600/25"
                        >
                          <CheckCircle2 className="w-3.5 h-3.5" />
                          <span>Confirm Completion & Release Escrow</span>
                        </button>
                      )}

                      {isCompleted && (
                        <button
                          onClick={() => setRatingBookingTarget(b)}
                          className="px-4 py-2 bg-amber-500 hover:bg-amber-400 text-slate-950 font-black rounded-xl text-xs flex items-center gap-1.5 transition-all shadow-lg shadow-amber-500/25"
                        >
                          <Star className="w-3.5 h-3.5 fill-slate-950" />
                          <span>Rate Provider</span>
                        </button>
                      )}
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>

      {/* --- MODAL 1: Rating Modal --- */}
      {ratingBookingTarget && (
        <RatingModal
          bookingId={ratingBookingTarget.id}
          ownerName={ratingBookingTarget.owner_company_name || 'Kovai Precision Works'}
          onSubmit={handleReviewSubmit}
          onClose={() => setRatingBookingTarget(null)}
        />
      )}

      {/* --- MODAL 2: GST Invoice Drawer --- */}
      {invoiceBookingTarget && (
        <div className="fixed inset-0 z-50 bg-slate-950/80 backdrop-blur-md flex items-center justify-center p-4">
          <div className="bg-white text-slate-900 max-w-xl w-full rounded-3xl shadow-2xl border border-slate-200 overflow-hidden font-sans space-y-6 p-6 sm:p-8 animate-in fade-in zoom-in-95 duration-150">
            <div className="flex justify-between items-start border-b border-slate-200 pb-4">
              <div>
                <div className="flex items-center gap-2">
                  <div className="w-8 h-8 bg-slate-900 rounded-lg flex items-center justify-center text-blue-600 font-black text-sm">MH</div>
                  <h3 className="text-xl font-black text-slate-900">TAX INVOICE</h3>
                </div>
                <p className="text-xs text-slate-500 mt-1">GSTIN: 33AAAAA0000A1Z5 • Mach-Hunt MSME Platform</p>
              </div>
              <button
                onClick={() => setInvoiceBookingTarget(null)}
                className="p-2 text-slate-400 hover:text-slate-700 rounded-full"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="grid grid-cols-2 gap-4 bg-slate-50 p-4 rounded-2xl text-xs border border-slate-200">
              <div>
                <span className="text-[10px] uppercase font-bold text-slate-400 block">Billed To (Seeker)</span>
                <span className="font-bold text-slate-800 block text-sm">{invoiceBookingTarget.seeker_company_name || 'TamilTech Components'}</span>
                <span className="text-slate-500">Coimbatore Industrial Estate, TN</span>
              </div>
              <div>
                <span className="text-[10px] uppercase font-bold text-slate-400 block">Provided By (Facility)</span>
                <span className="font-bold text-slate-800 block text-sm">{invoiceBookingTarget.owner_company_name || 'Kovai Precision Works'}</span>
                <span className="text-slate-500">Peelamedu CNC Cluster, Coimbatore</span>
              </div>
            </div>

            <div className="space-y-3 text-xs">
              <div className="border border-slate-200 rounded-xl overflow-hidden">
                <table className="w-full text-left">
                  <thead className="bg-slate-100 font-bold text-slate-700 border-b border-slate-200">
                    <tr>
                      <th className="p-3">Description</th>
                      <th className="p-3 text-right">Hours/Qty</th>
                      <th className="p-3 text-right">Amount</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100">
                    <tr>
                      <td className="p-3 font-medium">
                        {invoiceBookingTarget.machine_name || 'Haas VMC CNC Machine Slot Booking'}
                      </td>
                      <td className="p-3 text-right font-mono">{invoiceBookingTarget.quantity || 500} Nos</td>
                      <td className="p-3 text-right font-mono font-bold">₹{((invoiceBookingTarget.agreed_price || 25000) * 0.82).toLocaleString('en-IN')}</td>
                    </tr>
                    <tr>
                      <td className="p-3 text-slate-600">Platform Convenience & AI Match Fee (3%)</td>
                      <td className="p-3 text-right font-mono">-</td>
                      <td className="p-3 text-right font-mono">₹{((invoiceBookingTarget.agreed_price || 25000) * 0.03).toLocaleString('en-IN')}</td>
                    </tr>
                    <tr>
                      <td className="p-3 text-slate-600">CGST (9%) + SGST (9%)</td>
                      <td className="p-3 text-right font-mono">18%</td>
                      <td className="p-3 text-right font-mono">₹{((invoiceBookingTarget.agreed_price || 25000) * 0.15).toLocaleString('en-IN')}</td>
                    </tr>
                  </tbody>
                </table>
              </div>

              <div className="flex justify-between items-center bg-slate-900 text-white p-4 rounded-2xl">
                <div>
                  <span className="text-xs text-slate-400 block">Total Invoice Amount (Paid via Escrow)</span>
                  <span className="text-xs font-mono text-emerald-400 font-semibold">● Verified Digital Receipt</span>
                </div>
                <span className="text-2xl font-black font-mono text-white">
                  ₹{(invoiceBookingTarget.agreed_price || 25000).toLocaleString('en-IN')}
                </span>
              </div>
            </div>

            <div className="flex justify-end gap-3 pt-2">
              <button
                onClick={() => alert('Printing Invoice...')}
                className="px-4 py-2 bg-slate-100 hover:bg-slate-200 text-slate-800 font-bold rounded-xl text-xs flex items-center gap-1.5"
              >
                <Printer className="w-4 h-4" /> Print Invoice
              </button>
              <button
                onClick={() => setInvoiceBookingTarget(null)}
                className="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-xl text-xs"
              >
                Close View
              </button>
            </div>
          </div>
        </div>
      )}

      {/* --- MODAL 3: Live IoT Telemetry Drawer --- */}
      {telemetryBookingTarget && (
        <div className="fixed inset-0 z-50 bg-slate-950/80 backdrop-blur-md flex items-center justify-center p-4">
          <div className="bg-slate-900 text-white max-w-xl w-full rounded-3xl shadow-2xl border border-slate-800 overflow-hidden font-sans space-y-6 p-6 sm:p-8 animate-in fade-in zoom-in-95 duration-150">
            <div className="flex justify-between items-start border-b border-slate-800 pb-4">
              <div>
                <div className="inline-flex items-center gap-2 px-2.5 py-0.5 bg-emerald-500/10 border border-emerald-500/30 rounded-full text-emerald-400 text-xs font-bold mb-1">
                  <span className="w-2 h-2 bg-emerald-400 rounded-full animate-ping"></span> Live Sensor Feed
                </div>
                <h3 className="text-xl font-extrabold">IoT Telemetry & Job Monitor</h3>
                <p className="text-xs text-slate-400">Machine: {telemetryBookingTarget.machine_name || 'Haas VMC 3-Axis CNC'}</p>
              </div>
              <button
                onClick={() => setTelemetryBookingTarget(null)}
                className="p-2 text-slate-400 hover:text-white rounded-full"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="grid grid-cols-3 gap-3 text-center">
              <div className="bg-slate-950 p-4 rounded-2xl border border-slate-800">
                <span className="text-[10px] text-slate-400 uppercase font-semibold block">Spindle Speed</span>
                <span className="text-xl font-black text-blue-400 font-mono mt-1 block">8,450 RPM</span>
                <span className="text-[9px] text-emerald-400">Normal Range</span>
              </div>
              <div className="bg-slate-950 p-4 rounded-2xl border border-slate-800">
                <span className="text-[10px] text-slate-400 uppercase font-semibold block">Coolant Temp</span>
                <span className="text-xl font-black text-amber-400 font-mono mt-1 block">42.8 °C</span>
                <span className="text-[9px] text-emerald-400">Optimal</span>
              </div>
              <div className="bg-slate-950 p-4 rounded-2xl border border-slate-800">
                <span className="text-[10px] text-slate-400 uppercase font-semibold block">Vibration Level</span>
                <span className="text-xl font-black text-emerald-400 font-mono mt-1 block">0.12 mm/s</span>
                <span className="text-[9px] text-emerald-400">Low RMS</span>
              </div>
            </div>

            {/* Progress Bar */}
            <div className="bg-slate-950 p-4 rounded-2xl border border-slate-800 space-y-2">
              <div className="flex justify-between text-xs">
                <span className="font-bold text-slate-300">Batch Job Completion</span>
                <span className="font-mono text-emerald-400 font-bold">78.4% (392/500 Parts)</span>
              </div>
              <div className="w-full h-3 bg-slate-900 rounded-full overflow-hidden p-0.5 border border-slate-800">
                <div className="h-full bg-gradient-to-r from-blue-500 to-emerald-400 rounded-full w-[78%] transition-all duration-1000"></div>
              </div>
            </div>

            <div className="bg-slate-950 p-4 rounded-2xl border border-slate-800 font-mono text-[11px] text-slate-300 space-y-1 max-h-36 overflow-y-auto">
              <p className="text-slate-500">[09:15:02] Machine started program O1004.NC</p>
              <p className="text-slate-500">[09:30:45] Tool #3 Endmill 10mm engaged - Feed 1200 mm/min</p>
              <p className="text-emerald-400">[09:48:12] Part batch #350 passed inline laser dimension scan</p>
              <p className="text-slate-400">[10:02:55] Spindle active - Load 42%</p>
            </div>

            <div className="flex justify-end">
              <button
                onClick={() => setTelemetryBookingTarget(null)}
                className="px-5 py-2.5 bg-blue-600 hover:bg-blue-500 text-white font-bold rounded-xl text-xs"
              >
                Close Telemetry View
              </button>
            </div>
          </div>
        </div>
      )}

      {/* --- MODAL 4: Pay Escrow Modal --- */}
      {payEscrowTarget && (
        <div className="fixed inset-0 z-50 bg-slate-950/80 backdrop-blur-md flex items-center justify-center p-4">
          <div className="bg-slate-900 text-white max-w-md w-full rounded-3xl shadow-2xl border border-slate-800 overflow-hidden font-sans space-y-6 p-6 sm:p-8 animate-in fade-in zoom-in-95 duration-150">
            <div className="text-center space-y-2">
              <div className="w-12 h-12 bg-blue-500/10 border border-blue-500/30 rounded-2xl flex items-center justify-center mx-auto text-blue-400">
                <ShieldCheck className="w-6 h-6" />
              </div>
              <h3 className="text-xl font-extrabold">Escrow Deposit Confirmation</h3>
              <p className="text-xs text-slate-400">
                Funds are held in neutral Escrow until production is completed & quality is approved.
              </p>
            </div>

            <div className="bg-slate-950 p-4 rounded-2xl border border-slate-800 space-y-2 text-xs">
              <div className="flex justify-between">
                <span className="text-slate-400">Booking Target</span>
                <span className="font-bold text-white">{payEscrowTarget.machine_name || 'Haas VMC'}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-slate-400">Facility Provider</span>
                <span className="font-bold text-white">{payEscrowTarget.owner_company_name || 'Kovai Precision Works'}</span>
              </div>
              <div className="flex justify-between pt-2 border-t border-slate-800 font-bold text-sm">
                <span className="text-slate-300">Total Escrow Amount</span>
                <span className="text-emerald-400 font-mono">₹{(payEscrowTarget.agreed_price || 25000).toLocaleString('en-IN')}</span>
              </div>
            </div>

            <div className="grid grid-cols-2 gap-3">
              <button
                onClick={() => setPayEscrowTarget(null)}
                className="py-3 bg-slate-800 hover:bg-slate-700 text-slate-300 font-bold rounded-xl text-xs"
              >
                Cancel
              </button>
              <button
                onClick={() => handleSimulatePayment(payEscrowTarget.id)}
                className="py-3 bg-gradient-to-r from-emerald-600 to-teal-600 hover:from-emerald-500 hover:to-teal-500 text-white font-bold rounded-xl text-xs shadow-lg shadow-emerald-600/25"
              >
                Pay Escrow Now
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

