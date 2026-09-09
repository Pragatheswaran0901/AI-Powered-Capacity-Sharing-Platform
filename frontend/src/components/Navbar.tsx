import React, { useState } from 'react';
import { Link, useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { Wrench, Shield, Search, Bell, LogOut, Cpu, LayoutDashboard, Calendar, PlusCircle, BarChart3, MapPin, ChevronDown, UserCheck } from 'lucide-react';

interface NavbarProps {
  onOpenIoTModal: () => void;
}

export const Navbar: React.FC<NavbarProps> = ({ onOpenIoTModal }) => {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  const [showNotifs, setShowNotifs] = useState(false);
  const [showProfileMenu, setShowProfileMenu] = useState(false);
  const [selectedCity, setSelectedCity] = useState('Coimbatore');
  const [searchQuery, setSearchQuery] = useState('');

  const isActive = (path: string) => location.pathname === path;

  const handleSearchSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    navigate(`/find-capacity?q=${encodeURIComponent(searchQuery)}&city=${encodeURIComponent(selectedCity)}`);
  };

  return (
    <header className="bg-slate-950 border-b border-slate-800 sticky top-0 z-40 shadow-xl font-sans text-slate-100">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        {/* Top Header Row */}
        <div className="flex justify-between h-16 items-center gap-4">
          
          {/* Logo & Platform Title */}
          <Link to={user ? "/dashboard" : "/login"} className="flex items-center gap-2.5 shrink-0 group">
            <div className="w-10 h-10 bg-gradient-to-br from-blue-600 to-indigo-600 rounded-xl flex items-center justify-center text-white font-black text-xl shadow-lg shadow-blue-500/20 group-hover:scale-105 transition-transform">
              MH
            </div>
            <div>
              <span className="text-xl font-black tracking-tight text-white block leading-none">
                Mach<span className="text-blue-400">-Hunt</span>
              </span>
              <span className="text-[10px] font-bold tracking-wider text-slate-400 uppercase block mt-1">
                MSME Capacity Sharing
              </span>
            </div>
          </Link>

          {/* OLX-Style Location Selector & Search Input Bar */}
          {user && (
            <form onSubmit={handleSearchSubmit} className="hidden md:flex items-center flex-1 max-w-xl bg-slate-900 border border-slate-800 rounded-2xl overflow-hidden focus-within:border-blue-500/50 transition-colors">
              {/* Location dropdown */}
              <div className="flex items-center gap-1.5 px-3 border-r border-slate-800 shrink-0 text-slate-400 text-xs font-semibold">
                <MapPin className="w-3.5 h-3.5 text-blue-400" />
                <select
                  value={selectedCity}
                  onChange={(e) => setSelectedCity(e.target.value)}
                  className="bg-transparent text-slate-200 text-xs font-semibold outline-none cursor-pointer py-2 pr-1"
                >
                  <option value="Coimbatore" className="bg-slate-900 text-white">Coimbatore</option>
                  <option value="Chennai" className="bg-slate-900 text-white">Chennai</option>
                  <option value="Hosur" className="bg-slate-900 text-white">Hosur</option>
                  <option value="Salem" className="bg-slate-900 text-white">Salem</option>
                  <option value="Tiruppur" className="bg-slate-900 text-white">Tiruppur</option>
                  <option value="Erode" className="bg-slate-900 text-white">Erode</option>
                  <option value="Madurai" className="bg-slate-900 text-white">Madurai</option>
                  <option value="Trichy" className="bg-slate-900 text-white">Trichy</option>
                </select>
              </div>

              {/* Search text input */}
              <div className="flex-1 flex items-center px-3 gap-2">
                <Search className="w-4 h-4 text-slate-500 shrink-0" />
                <input
                  type="text"
                  placeholder="Search VMC, CNC Milling, Laser Cutting near you..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="w-full bg-transparent text-xs text-white placeholder-slate-500 outline-none py-2 font-medium"
                />
              </div>

              <button type="submit" className="px-4 py-2 bg-blue-600 hover:bg-blue-500 text-white text-xs font-bold transition-colors shrink-0">
                Search
              </button>
            </form>
          )}

          {/* Right Section: OLX "+ LIST CAPACITY" Button & User Profile */}
          <div className="flex items-center gap-3 shrink-0">
            {user ? (
              <>
                {/* OLX-Style Bold "+ LIST CAPACITY" Button */}
                <Link
                  to="/machines/add"
                  className="px-4 py-2 bg-gradient-to-r from-amber-400 via-amber-500 to-yellow-500 hover:from-amber-300 hover:to-yellow-400 text-slate-950 font-black rounded-xl text-xs flex items-center gap-1.5 transition-all shadow-lg shadow-amber-500/20 transform hover:-translate-y-0.5"
                >
                  <PlusCircle className="w-4 h-4 stroke-[2.5]" />
                  <span>+ LIST CAPACITY</span>
                </Link>

                {/* Phase 2 IoT Telematics Button */}
                <button
                  onClick={onOpenIoTModal}
                  className="hidden lg:flex items-center gap-1.5 px-3 py-2 text-xs font-semibold rounded-xl border border-slate-800 text-slate-300 bg-slate-900 hover:bg-slate-800 transition-all"
                >
                  <Cpu className="w-3.5 h-3.5 text-blue-400" />
                  <span>IoT Telemetry</span>
                </button>

                {/* Notifications Bell */}
                <div className="relative">
                  <button
                    onClick={() => setShowNotifs(!showNotifs)}
                    className="p-2 text-slate-400 hover:text-white hover:bg-slate-900 rounded-xl transition-colors relative"
                  >
                    <Bell className="w-5 h-5" />
                    <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-blue-500 rounded-full ring-2 ring-slate-950"></span>
                  </button>

                  {showNotifs && (
                    <div className="absolute right-0 mt-2 w-80 bg-slate-900 rounded-2xl shadow-2xl border border-slate-800 py-3 z-50 text-xs">
                      <div className="px-4 py-2 border-b border-slate-800 font-bold text-white flex justify-between items-center">
                        <span>Notifications</span>
                        <span className="text-[10px] bg-blue-500/20 text-blue-400 px-2 py-0.5 rounded-full font-mono">2 New</span>
                      </div>
                      <div className="divide-y divide-slate-800 max-h-60 overflow-y-auto">
                        <div className="p-3 hover:bg-slate-800/50 transition-colors">
                          <p className="font-bold text-slate-200">New Capacity Booking Request</p>
                          <p className="text-slate-400 text-[11px] mt-0.5">TamilTech requested Haas VMC (500 Qty).</p>
                          <span className="text-[10px] text-slate-500 mt-1 block">10 mins ago</span>
                        </div>
                        <div className="p-3 hover:bg-slate-800/50 transition-colors">
                          <p className="font-bold text-slate-200">Smart Match Recommended (95%)</p>
                          <p className="text-slate-400 text-[11px] mt-0.5">Kovai Precision Works ready in Coimbatore.</p>
                          <span className="text-[10px] text-slate-500 mt-1 block">1 hour ago</span>
                        </div>
                      </div>
                    </div>
                  )}
                </div>

                {/* Profile Menu Dropdown */}
                <div className="relative">
                  <button
                    onClick={() => setShowProfileMenu(!showProfileMenu)}
                    className="flex items-center gap-2 p-1.5 bg-slate-900 border border-slate-800 hover:border-slate-700 rounded-xl transition-all"
                  >
                    <div className="w-7 h-7 bg-blue-600/20 border border-blue-500/30 rounded-lg flex items-center justify-center text-blue-400 font-extrabold text-xs">
                      {user.name.charAt(0)}
                    </div>
                    <div className="text-left hidden sm:block">
                      <span className="text-xs font-bold text-white block leading-tight">{user.name}</span>
                      <span className="text-[10px] text-slate-400 block truncate max-w-[110px]">{user.company_name || 'Kongu Components'}</span>
                    </div>
                    <ChevronDown className="w-3.5 h-3.5 text-slate-400" />
                  </button>

                  {showProfileMenu && (
                    <div className="absolute right-0 mt-2 w-56 bg-slate-900 rounded-2xl shadow-2xl border border-slate-800 py-2 z-50 text-xs">
                      <div className="px-4 py-2.5 border-b border-slate-800">
                        <p className="font-bold text-white">{user.name}</p>
                        <p className="text-[11px] text-slate-400">{user.email}</p>
                        <span className="inline-block mt-1 text-[10px] font-bold text-emerald-400 bg-emerald-500/10 border border-emerald-500/20 px-2 py-0.5 rounded-full">
                          ✓ Verified MSME Account
                        </span>
                      </div>

                      <div className="py-1">
                        <Link to="/dashboard" onClick={() => setShowProfileMenu(false)} className="px-4 py-2 text-slate-300 hover:text-white hover:bg-slate-800 flex items-center gap-2">
                          <LayoutDashboard className="w-4 h-4 text-blue-400" />
                          <span>MSME Dashboard</span>
                        </Link>
                        <Link to="/machines" onClick={() => setShowProfileMenu(false)} className="px-4 py-2 text-slate-300 hover:text-white hover:bg-slate-800 flex items-center gap-2">
                          <Wrench className="w-4 h-4 text-amber-400" />
                          <span>My Machines</span>
                        </Link>
                        <Link to="/requirements" onClick={() => setShowProfileMenu(false)} className="px-4 py-2 text-slate-300 hover:text-white hover:bg-slate-800 flex items-center gap-2">
                          <Search className="w-4 h-4 text-purple-400" />
                          <span>My Requirements</span>
                        </Link>
                        <Link to="/analytics" onClick={() => setShowProfileMenu(false)} className="px-4 py-2 text-slate-300 hover:text-white hover:bg-slate-800 flex items-center gap-2">
                          <BarChart3 className="w-4 h-4 text-emerald-400" />
                          <span>Analytics & Revenue</span>
                        </Link>
                        {user.role === 'admin' && (
                          <Link to="/admin-dashboard" onClick={() => setShowProfileMenu(false)} className="px-4 py-2 text-slate-300 hover:text-white hover:bg-slate-800 flex items-center gap-2">
                            <Shield className="w-4 h-4 text-amber-400" />
                            <span>Admin Portal</span>
                          </Link>
                        )}
                      </div>

                      <div className="border-t border-slate-800 pt-1">
                        <button
                          onClick={() => {
                            setShowProfileMenu(false);
                            logout();
                          }}
                          className="w-full px-4 py-2 text-rose-400 hover:bg-rose-500/10 flex items-center gap-2 font-bold"
                        >
                          <LogOut className="w-4 h-4" />
                          <span>Sign Out</span>
                        </button>
                      </div>
                    </div>
                  )}
                </div>
              </>
            ) : (
              <div className="flex items-center gap-2">
                <Link
                  to="/login"
                  className="px-4 py-2 text-xs font-bold text-slate-300 hover:text-white hover:bg-slate-900 rounded-xl transition-colors"
                >
                  Log In
                </Link>
                <Link
                  to="/register"
                  className="px-4 py-2 text-xs font-bold text-white bg-blue-600 hover:bg-blue-500 rounded-xl transition-all shadow-lg shadow-blue-600/20"
                >
                  Register MSME
                </Link>
              </div>
            )}
          </div>
        </div>

        {/* Global Navigation Link Tabs */}
        {user && (
          <nav className="flex items-center gap-1 overflow-x-auto py-2 border-t border-slate-800/80 text-xs font-semibold no-scrollbar">
            <Link
              to="/dashboard"
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-xl transition-all shrink-0 ${
                isActive('/dashboard') ? 'bg-blue-600 text-white font-bold shadow-md' : 'text-slate-400 hover:text-white hover:bg-slate-900'
              }`}
            >
              <LayoutDashboard className="w-3.5 h-3.5" />
              <span>Dashboard</span>
            </Link>

            <Link
              to="/find-capacity"
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-xl transition-all shrink-0 ${
                isActive('/find-capacity') ? 'bg-blue-600 text-white font-bold shadow-md' : 'text-slate-400 hover:text-white hover:bg-slate-900'
              }`}
            >
              <Search className="w-3.5 h-3.5 text-blue-400" />
              <span>Find Capacity</span>
            </Link>

            <Link
              to="/machines"
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-xl transition-all shrink-0 ${
                isActive('/machines') ? 'bg-blue-600 text-white font-bold shadow-md' : 'text-slate-400 hover:text-white hover:bg-slate-900'
              }`}
            >
              <Wrench className="w-3.5 h-3.5 text-amber-400" />
              <span>My Machines</span>
            </Link>

            <Link
              to="/requirements"
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-xl transition-all shrink-0 ${
                isActive('/requirements') ? 'bg-blue-600 text-white font-bold shadow-md' : 'text-slate-400 hover:text-white hover:bg-slate-900'
              }`}
            >
              <PlusCircle className="w-3.5 h-3.5 text-purple-400" />
              <span>My Requirements</span>
            </Link>

            <Link
              to="/bookings"
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-xl transition-all shrink-0 ${
                isActive('/bookings') ? 'bg-blue-600 text-white font-bold shadow-md' : 'text-slate-400 hover:text-white hover:bg-slate-900'
              }`}
            >
              <Calendar className="w-3.5 h-3.5 text-emerald-400" />
              <span>Bookings Hub</span>
            </Link>

            <Link
              to="/analytics"
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-xl transition-all shrink-0 ${
                isActive('/analytics') ? 'bg-blue-600 text-white font-bold shadow-md' : 'text-slate-400 hover:text-white hover:bg-slate-900'
              }`}
            >
              <BarChart3 className="w-3.5 h-3.5 text-cyan-400" />
              <span>Analytics</span>
            </Link>
          </nav>
        )}

      </div>
    </header>
  );
};

