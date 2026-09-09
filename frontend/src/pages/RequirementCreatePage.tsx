import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../services/api';
import { Sparkles, ArrowRight, Upload, FileText, CheckCircle2, Cpu, ShieldCheck } from 'lucide-react';

export const RequirementCreatePage: React.FC = () => {
  const navigate = useNavigate();

  // Natural Language Prompt State
  const [nlPrompt, setNlPrompt] = useState('I need 500 aluminium brackets machined within 3 days in Coimbatore with ₹25,000 budget.');
  const [isParsing, setIsParsing] = useState(false);

  // Form Fields State
  const [title, setTitle] = useState('500 Aluminium Components');
  const [description, setDescription] = useState('Precision VMC CNC milling required for 500 nos aircraft grade 6061 aluminium mounting brackets.');
  const [process, setProcess] = useState('CNC Milling');
  const [material, setMaterial] = useState('Aluminium');
  const [quantity, setQuantity] = useState(500);
  const [deadline, setDeadline] = useState('3 days');
  const [budget, setBudget] = useState(25000);
  const [preferredCity, setPreferredCity] = useState('Coimbatore');
  const [fileName, setFileName] = useState<string | null>(null);

  const handleParsePrompt = async () => {
    if (!nlPrompt.trim()) return;
    setIsParsing(true);
    const parsed = await api.parseNLRequirement(nlPrompt);
    setTitle(parsed.title);
    setDescription(parsed.description);
    setProcess(parsed.process);
    setMaterial(parsed.material);
    setQuantity(parsed.quantity);
    setDeadline(parsed.deadline);
    setBudget(parsed.budget);
    setPreferredCity(parsed.preferred_city);
    setIsParsing(false);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    await api.createRequirement({
      title,
      description,
      process,
      material,
      quantity: Number(quantity),
      deadline,
      budget: Number(budget),
      preferred_city: preferredCity
    });
    navigate('/seeker-dashboard');
  };

  return (
    <div className="min-h-screen bg-slate-900 text-slate-100 py-10 font-sans">
      <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="bg-slate-950/80 rounded-3xl shadow-2xl border border-slate-800 overflow-hidden">
          
          {/* Header */}
          <div className="bg-gradient-to-r from-slate-950 via-slate-900 to-blue-950 p-6 sm:p-8 border-b border-slate-800">
            <div className="inline-flex items-center gap-2 px-3 py-1 bg-blue-500/10 border border-blue-500/20 rounded-full text-blue-400 text-xs font-semibold mb-2">
              <Sparkles className="w-3.5 h-3.5" />
              <span>Smart Capacity Posting Wizard</span>
            </div>
            <h1 className="text-2xl font-black text-white">Post Manufacturing Requirement</h1>
            <p className="text-xs text-slate-400 mt-1">
              Specify part geometry, tolerances, batch quantity, and target budget to match verified Tamil Nadu MSME capacity.
            </p>
          </div>

          <div className="p-6 sm:p-8 space-y-6">
            
            {/* Natural Language Prompt Assistant Box */}
            <div className="bg-slate-900 p-5 rounded-2xl border border-blue-500/30 space-y-3 relative overflow-hidden">
              <div className="flex items-center gap-2 text-xs font-bold text-blue-400">
                <Sparkles className="w-4 h-4 text-blue-400 animate-pulse" />
                <span>AI Natural Language Requirement Extraction</span>
              </div>
              <p className="text-xs text-slate-400">
                Type your manufacturing request in plain text and click "Extract Specs" to auto-fill the parameters.
              </p>

              <div className="flex flex-col sm:flex-row gap-2">
                <input
                  type="text"
                  value={nlPrompt}
                  onChange={(e) => setNlPrompt(e.target.value)}
                  placeholder="e.g. I need 500 aluminium brackets machined within 3 days in Coimbatore with ₹25,000 budget."
                  className="flex-1 p-3 bg-slate-950 border border-slate-800 rounded-xl text-xs text-white placeholder-slate-500 focus:ring-2 focus:ring-blue-500 focus:outline-none"
                />
                <button
                  type="button"
                  onClick={handleParsePrompt}
                  disabled={isParsing}
                  className="px-5 py-3 bg-blue-600 hover:bg-blue-500 text-white font-bold rounded-xl text-xs transition-all shadow-lg shadow-blue-600/25 shrink-0 flex items-center justify-center gap-1.5"
                >
                  {isParsing ? (
                    <div className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin"></div>
                  ) : (
                    <>
                      <Sparkles className="w-3.5 h-3.5" />
                      <span>Extract Specs</span>
                    </>
                  )}
                </button>
              </div>
            </div>

            {/* Standard Form */}
            <form onSubmit={handleSubmit} className="space-y-4 text-xs">
              <div className="space-y-1.5">
                <label className="font-semibold text-slate-300 block">Requirement Title</label>
                <input
                  type="text"
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  className="w-full p-3 bg-slate-900 border border-slate-800 rounded-xl text-white focus:ring-2 focus:ring-blue-500 focus:outline-none font-medium"
                  required
                />
              </div>

              <div className="space-y-1.5">
                <label className="font-semibold text-slate-300 block">Detailed Job Description</label>
                <textarea
                  rows={3}
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  className="w-full p-3 bg-slate-900 border border-slate-800 rounded-xl text-white focus:ring-2 focus:ring-blue-500 focus:outline-none font-medium"
                  required
                />
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div className="space-y-1.5">
                  <label className="font-semibold text-slate-300 block">Manufacturing Process</label>
                  <select
                    value={process}
                    onChange={(e) => setProcess(e.target.value)}
                    className="w-full p-3 bg-slate-900 border border-slate-800 rounded-xl text-white focus:ring-2 focus:ring-blue-500 focus:outline-none font-medium"
                  >
                    <option value="CNC Milling">CNC Milling</option>
                    <option value="VMC">VMC Vertical Machining</option>
                    <option value="CNC Turning">CNC Turning</option>
                    <option value="Conventional Lathe">Conventional Lathe</option>
                    <option value="Laser Cutting">Laser Cutting</option>
                    <option value="Press Brake">Press Brake Bending</option>
                    <option value="Welding">Welding & Fabrication</option>
                    <option value="3D Printing">Industrial 3D Printing</option>
                  </select>
                </div>

                <div className="space-y-1.5">
                  <label className="font-semibold text-slate-300 block">Material Required</label>
                  <select
                    value={material}
                    onChange={(e) => setMaterial(e.target.value)}
                    className="w-full p-3 bg-slate-900 border border-slate-800 rounded-xl text-white focus:ring-2 focus:ring-blue-500 focus:outline-none font-medium"
                  >
                    <option value="Aluminium">Aluminium (6061/7075)</option>
                    <option value="Stainless Steel">Stainless Steel (304/316)</option>
                    <option value="Mild Steel">Mild Steel</option>
                    <option value="Carbon Steel">Carbon Steel</option>
                    <option value="Brass">Brass</option>
                    <option value="Copper">Copper</option>
                    <option value="Nylon">Nylon / ABS</option>
                  </select>
                </div>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                <div className="space-y-1.5">
                  <label className="font-semibold text-slate-300 block">Batch Quantity (Nos)</label>
                  <input
                    type="number"
                    value={quantity}
                    onChange={(e) => setQuantity(Number(e.target.value))}
                    className="w-full p-3 bg-slate-900 border border-slate-800 rounded-xl text-white font-mono focus:ring-2 focus:ring-blue-500 focus:outline-none"
                    required
                  />
                </div>

                <div className="space-y-1.5">
                  <label className="font-semibold text-slate-300 block">Required SLA Deadline</label>
                  <input
                    type="text"
                    value={deadline}
                    onChange={(e) => setDeadline(e.target.value)}
                    placeholder="e.g. 3 days"
                    className="w-full p-3 bg-slate-900 border border-slate-800 rounded-xl text-white focus:ring-2 focus:ring-blue-500 focus:outline-none"
                    required
                  />
                </div>

                <div className="space-y-1.5">
                  <label className="font-semibold text-slate-300 block">Target Budget (₹ INR)</label>
                  <input
                    type="number"
                    value={budget}
                    onChange={(e) => setBudget(Number(e.target.value))}
                    className="w-full p-3 bg-slate-900 border border-slate-800 rounded-xl text-emerald-400 font-mono font-bold focus:ring-2 focus:ring-blue-500 focus:outline-none"
                    required
                  />
                </div>
              </div>

              <div className="space-y-1.5">
                <label className="font-semibold text-slate-300 block">Preferred Industrial Hub (TN)</label>
                <select
                  value={preferredCity}
                  onChange={(e) => setPreferredCity(e.target.value)}
                  className="w-full p-3 bg-slate-900 border border-slate-800 rounded-xl text-white focus:ring-2 focus:ring-blue-500 focus:outline-none font-medium"
                >
                  <option value="Coimbatore">Coimbatore (Primary Pilot Cluster)</option>
                  <option value="Chennai">Chennai & Ambattur</option>
                  <option value="Hosur">Hosur Auto Cluster</option>
                  <option value="Salem">Salem</option>
                  <option value="Tiruppur">Tiruppur</option>
                  <option value="Erode">Erode</option>
                  <option value="Madurai">Madurai</option>
                </select>
              </div>

              {/* Upload CAD/Drawing mockup */}
              <div className="p-5 border-2 border-dashed border-slate-800 hover:border-blue-500/50 rounded-2xl bg-slate-900/60 text-center space-y-2 transition-all">
                <Upload className="w-6 h-6 text-blue-400 mx-auto" />
                <span className="font-bold text-slate-200 block">Attach Technical CAD Drawing / Part Blueprint</span>
                <span className="text-[10px] text-slate-400 block">Supports STEP, IGES, DXF, DWG, PDF up to 25MB</span>
                <input
                  type="file"
                  onChange={(e) => setFileName(e.target.files?.[0]?.name || 'Drawing_6061_Al.pdf')}
                  className="hidden"
                  id="drawing-file"
                />
                <label
                  htmlFor="drawing-file"
                  className="inline-block mt-2 px-4 py-2 bg-slate-800 hover:bg-slate-700 text-white rounded-xl text-xs font-bold cursor-pointer transition-colors"
                >
                  {fileName ? `Attached: ${fileName}` : 'Select File from Computer'}
                </label>
              </div>

              <button
                type="submit"
                className="w-full py-4 bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-500 hover:to-indigo-500 text-white font-bold rounded-2xl text-xs transition-all shadow-lg shadow-blue-600/25 flex items-center justify-center gap-2"
              >
                <span>Trigger AI Capacity Matching Algorithm</span>
                <ArrowRight className="w-4 h-4" />
              </button>
            </form>
          </div>
        </div>
      </div>
    </div>
  );
};

