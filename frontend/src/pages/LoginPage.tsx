import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import {
  Shield,
  Wrench,
  Search,
  Lock,
  Mail,
  ArrowRight,
  Eye,
  EyeOff,
  Sparkles,
  Cpu,
  CheckCircle2,
  Check,
  Building2,
  MapPin,
  TrendingUp,
  Activity
} from 'lucide-react';

export const LoginPage: React.FC = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [rememberMe, setRememberMe] = useState(true);
  const [error, setError] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [activeTab, setActiveTab] = useState<string>('msme');

  const { login, switchDemoUser } = useAuth();
  const navigate = useNavigate();

  const handleLoginSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setIsSubmitting(true);
    try {
      await login(email, password);
      if (email.includes('admin')) navigate('/admin-dashboard');
      else navigate('/dashboard');
    } catch (err: any) {
      setError('Invalid credentials. Please check your email or use One-Click Demo below.');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleQuickDemo = (role: 'msme' | 'admin' | 'owner' | 'seeker' | 'machine_owner' | 'machine_seeker') => {
    switchDemoUser(role);
    if (role === 'admin') navigate('/admin-dashboard');
    else navigate('/dashboard');
  };

  return (
    <div className="min-h-screen bg-slate-950 flex flex-col justify-center items-center p-4 lg:p-8 relative overflow-hidden font-sans">
      {/* Dynamic Background Effects */}
      <div className="absolute top-0 left-1/4 w-[600px] h-[600px] bg-blue-600/10 rounded-full blur-3xl pointer-events-none -translate-y-1/2"></div>
      <div className="absolute bottom-0 right-1/4 w-[600px] h-[600px] bg-emerald-600/10 rounded-full blur-3xl pointer-events-none translate-y-1/2"></div>
      <div className="absolute inset-0 bg-[linear-gradient(to_right,#1e293b15_1px,transparent_1px),linear-gradient(to_bottom,#1e293b15_1px,transparent_1px)] bg-[size:4rem_4rem] [mask-image:radial-gradient(ellipse_60%_50%_at_50%_50%,#000_70%,transparent_100%)] pointer-events-none"></div>

      <div className="max-w-5xl w-full grid grid-cols-1 lg:grid-cols-12 bg-slate-900/90 rounded-3xl border border-slate-800 shadow-2xl overflow-hidden backdrop-blur-xl relative z-10">
        
        {/* Left Side: Brand Hero Banner */}
        <div className="lg:col-span-5 bg-gradient-to-br from-slate-900 via-slate-900 to-blue-950 p-8 lg:p-10 flex flex-col justify-between border-b lg:border-b-0 lg:border-r border-slate-800 relative">
          <div className="space-y-6">
            <div className="flex items-center gap-3">
              <div className="w-11 h-11 bg-gradient-to-tr from-blue-600 to-indigo-500 rounded-xl flex items-center justify-center font-black text-white text-xl shadow-lg shadow-blue-500/25">
                MH
              </div>
              <div>
                <h1 className="text-xl font-black text-white tracking-tight">Mach-Hunt</h1>
                <span className="text-[11px] font-bold text-blue-400 uppercase tracking-widest block">Capacity Platform • TN</span>
              </div>
            </div>

            <div className="space-y-3 pt-4">
              <div className="inline-flex items-center gap-2 px-3 py-1 bg-blue-500/10 border border-blue-500/20 rounded-full text-blue-300 text-xs font-semibold">
                <Sparkles className="w-3.5 h-3.5 text-blue-400" />
                <span>Find. Share. Manufacture.</span>
              </div>
              <h2 className="text-2xl font-extrabold text-white leading-tight">
                Welcome to Mach-Hunt
              </h2>
              <p className="text-xs text-slate-400 leading-relaxed">
                Connect with verified MSMEs and access manufacturing capacity when you need it.
              </p>
            </div>

            <div className="space-y-3 pt-2">
              <div className="flex items-center gap-3 text-slate-300 text-xs font-medium">
                <div className="w-5 h-5 rounded-full bg-emerald-500/10 border border-emerald-500/30 flex items-center justify-center text-emerald-400 shrink-0">
                  <Check className="w-3 h-3 stroke-[3]" />
                </div>
                <span>Provide Spare Machine Capacity & Earn Revenue</span>
              </div>
              <div className="flex items-center gap-3 text-slate-300 text-xs font-medium">
                <div className="w-5 h-5 rounded-full bg-emerald-500/10 border border-emerald-500/30 flex items-center justify-center text-emerald-400 shrink-0">
                  <Check className="w-3 h-3 stroke-[3]" />
                </div>
                <span>Find Nearby Machine Capacity & Smart Matching</span>
              </div>
              <div className="flex items-center gap-3 text-slate-300 text-xs font-medium">
                <div className="w-5 h-5 rounded-full bg-emerald-500/10 border border-emerald-500/30 flex items-center justify-center text-emerald-400 shrink-0">
                  <Check className="w-3 h-3 stroke-[3]" />
                </div>
                <span>Escrow Payment Guarantee & Milestone Tracking</span>
              </div>
            </div>
          </div>

          {/* Live Platform Stats Footer */}
          <div className="mt-8 pt-6 border-t border-slate-800/80 grid grid-cols-3 gap-2 text-center">
            <div className="bg-slate-800/40 p-2.5 rounded-xl border border-slate-700/50">
              <span className="block text-base font-black text-white font-mono">140+</span>
              <span className="text-[10px] text-slate-400 font-semibold uppercase">CNC Machines</span>
            </div>
            <div className="bg-slate-800/40 p-2.5 rounded-xl border border-slate-700/50">
              <span className="block text-base font-black text-emerald-400 font-mono">98.6%</span>
              <span className="text-[10px] text-slate-400 font-semibold uppercase">On-Time SLA</span>
            </div>
            <div className="bg-slate-800/40 p-2.5 rounded-xl border border-slate-700/50">
              <span className="block text-base font-black text-blue-400 font-mono">Coimbatore</span>
              <span className="text-[10px] text-slate-400 font-semibold uppercase">Pilot Hub</span>
            </div>
          </div>
        </div>

        {/* Right Side: Auth Card */}
        <div className="lg:col-span-7 p-6 sm:p-8 lg:p-10 flex flex-col justify-center space-y-6 bg-slate-900/60">
          
          {/* Quick Evaluator One-Click Persona Bar */}
          <div className="bg-slate-800/60 p-4 rounded-2xl border border-slate-700/80 space-y-3">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-1.5">
                <Sparkles className="w-4 h-4 text-amber-400 animate-pulse" />
                <span className="text-xs font-bold text-slate-200 uppercase tracking-wide">
                  Evaluator One-Click Demo Access
                </span>
              </div>
              <span className="text-[10px] bg-amber-500/10 text-amber-300 font-semibold px-2 py-0.5 rounded-full border border-amber-500/20">
                Primary Demo
              </span>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
              <button
                type="button"
                onClick={() => {
                  setActiveTab('pragatheswaran');
                  setEmail('pragatheswaran@machhunt.demo');
                  setPassword('password123');
                  handleQuickDemo('msme');
                }}
                className={`p-3.5 rounded-2xl border text-left transition-all flex flex-col justify-between gap-1.5 group ${
                  activeTab === 'pragatheswaran'
                    ? 'bg-amber-500/10 border-amber-500 text-white ring-1 ring-amber-500'
                    : 'bg-slate-800/80 border-slate-700 text-slate-300 hover:border-slate-600 hover:bg-slate-800'
                }`}
              >
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <Sparkles className="w-4 h-4 text-amber-400" />
                    <span className="text-[10px] font-black uppercase text-amber-400 bg-amber-500/10 px-2 py-0.5 rounded-full border border-amber-500/20">Dual MSME Account</span>
                  </div>
                  <ArrowRight className="w-3.5 h-3.5 text-slate-500 group-hover:text-amber-400 group-hover:translate-x-0.5 transition-all" />
                </div>
                <div>
                  <span className="block text-sm font-extrabold text-white">Pragatheswaran</span>
                  <span className="text-xs text-slate-400 block">Kongu Precision Components (Provide & Seek Capacity)</span>
                </div>
              </button>

              <button
                type="button"
                onClick={() => {
                  setActiveTab('janika');
                  setEmail('janika@machhunt.demo');
                  setPassword('password123');
                  handleQuickDemo('owner');
                }}
                className={`p-3.5 rounded-2xl border text-left transition-all flex flex-col justify-between gap-1.5 group ${
                  activeTab === 'janika'
                    ? 'bg-emerald-600/20 border-emerald-500 text-white ring-1 ring-emerald-500'
                    : 'bg-slate-800/80 border-slate-700 text-slate-300 hover:border-slate-600 hover:bg-slate-800'
                }`}
              >
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <Wrench className="w-4 h-4 text-emerald-400" />
                    <span className="text-[10px] font-black uppercase text-emerald-400 bg-emerald-500/10 px-2 py-0.5 rounded-full border border-emerald-500/20">Capacity Provider</span>
                  </div>
                  <ArrowRight className="w-3.5 h-3.5 text-slate-500 group-hover:text-emerald-400 group-hover:translate-x-0.5 transition-all" />
                </div>
                <div>
                  <span className="block text-sm font-extrabold text-white">Janika</span>
                  <span className="text-xs text-slate-400 block">Kovai Precision Works (Machine Owner)</span>
                </div>
              </button>
            </div>
          </div>

          <div className="relative flex items-center justify-center">
            <div className="border-t border-slate-800 w-full"></div>
            <span className="bg-slate-900 px-3 text-[10px] uppercase font-mono font-bold text-slate-500 absolute">
              Or Sign In with Credentials
            </span>
          </div>

          {/* Login Form */}
          <form onSubmit={handleLoginSubmit} className="space-y-4 text-xs">
            {error && (
              <div className="p-3.5 bg-red-500/10 border border-red-500/30 text-red-300 rounded-xl font-medium text-xs flex items-center justify-between">
                <span>{error}</span>
                <button type="button" onClick={() => setError('')} className="text-red-400 hover:text-white font-bold ml-2">✕</button>
              </div>
            )}

            <div className="space-y-1.5">
              <label className="font-semibold text-slate-300 block">Email Address</label>
              <div className="relative">
                <Mail className="w-4 h-4 text-slate-500 absolute left-3.5 top-3.5" />
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="e.g. janika@machhunt.demo"
                  className="w-full pl-10 pr-4 py-3 bg-slate-950/80 border border-slate-800 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent text-white placeholder-slate-500 transition-all font-medium"
                  required
                />
              </div>
            </div>

            <div className="space-y-1.5">
              <div className="flex justify-between items-center">
                <label className="font-semibold text-slate-300 block">Password</label>
                <a href="#forgot" onClick={(e) => { e.preventDefault(); alert('Demo Mode: Click any demo button above or use password123'); }} className="text-blue-400 hover:underline text-[11px]">
                  Forgot password?
                </a>
              </div>
              <div className="relative">
                <Lock className="w-4 h-4 text-slate-500 absolute left-3.5 top-3.5" />
                <input
                  type={showPassword ? 'text' : 'password'}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="••••••••"
                  className="w-full pl-10 pr-10 py-3 bg-slate-950/80 border border-slate-800 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent text-white placeholder-slate-500 transition-all font-medium"
                  required
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-3.5 top-3.5 text-slate-500 hover:text-slate-300"
                >
                  {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                </button>
              </div>
            </div>

            <div className="flex items-center justify-between pt-1">
              <label className="flex items-center gap-2 cursor-pointer text-slate-400">
                <input
                  type="checkbox"
                  checked={rememberMe}
                  onChange={(e) => setRememberMe(e.target.checked)}
                  className="w-4 h-4 rounded border-slate-800 bg-slate-950 text-blue-600 focus:ring-blue-500 focus:ring-offset-slate-900"
                />
                <span>Remember this device</span>
              </label>
            </div>

            <button
              type="submit"
              disabled={isSubmitting}
              className="w-full py-3.5 bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-500 hover:to-indigo-500 text-white font-bold rounded-xl text-xs transition-all shadow-lg shadow-blue-600/25 flex items-center justify-center gap-2"
            >
              {isSubmitting ? (
                <div className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin"></div>
              ) : (
                <>
                  <span>Sign In to Platform</span>
                  <ArrowRight className="w-4 h-4" />
                </>
              )}
            </button>
          </form>

          <div className="pt-2 text-center border-t border-slate-800/80">
            <p className="text-slate-400 text-xs">
              Don't have an MSME account?{' '}
              <Link to="/register" className="text-blue-400 hover:text-blue-300 font-bold transition-colors">
                Register Your Capacity Facility
              </Link>
            </p>
          </div>
        </div>

      </div>
    </div>
  );
};

