import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../services/api';
import { Wrench, ArrowRight, Upload, ShieldCheck, CheckCircle2, MapPin, DollarSign, Clock } from 'lucide-react';

export const AddMachinePage: React.FC = () => {
  const navigate = useNavigate();

  // Form Fields
  const [machineName, setMachineName] = useState('Haas VF-4SS VMC Milling Machine');
  const [machineType, setMachineType] = useState('VMC');
  const [manufacturer, setManufacturer] = useState('Haas');
  const [model, setModel] = useState('VF-4SS');
  const [year, setYear] = useState(2023);
  const [description, setDescription] = useState('High precision 12,000 RPM spindle 4-axis VMC machining center available for spare capacity rental.');

  const [process, setProcess] = useState('VMC');
  const [material, setMaterial] = useState('Aluminium');
  const [maxDimension, setMaxDimension] = useState('1270 x 508 x 635 mm');
  const [tolerance, setTolerance] = useState('±0.005 mm');

  const [hourlyRate, setHourlyRate] = useState(850);
  const [minBookingHours, setMinBookingHours] = useState(2);
  const [operatorAvailable, setOperatorAvailable] = useState(true);

  const [city, setCity] = useState('Coimbatore');
  const [district, setDistrict] = useState('Coimbatore');
  const [location, setLocation] = useState('SIDCO Industrial Estate, Kurichi, Coimbatore');

  const [availableDate, setAvailableDate] = useState('2026-08-15');
  const [startTime, setStartTime] = useState('08:00');
  const [endTime, setEndTime] = useState('18:00');

  const [fileName, setFileName] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);
    try {
      await api.createMachine({
        machine_name: machineName,
        machine_type: machineType,
        manufacturer,
        model,
        year: Number(year),
        description,
        hourly_rate: Number(hourlyRate),
        minimum_booking_hours: Number(minBookingHours),
        location,
        operator_available: operatorAvailable
      });
      navigate('/machines');
    } catch (e) {
      navigate('/machines');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="min-h-screen bg-slate-900 text-slate-100 py-10 font-sans">
      <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="bg-slate-950/80 rounded-3xl shadow-2xl border border-slate-800 overflow-hidden">
          
          {/* Header */}
          <div className="bg-gradient-to-r from-slate-950 via-slate-900 to-amber-950/50 p-6 sm:p-8 border-b border-slate-800">
            <div className="inline-flex items-center gap-2 px-3 py-1 bg-amber-500/10 border border-amber-500/20 rounded-full text-amber-400 text-xs font-semibold mb-2">
              <Wrench className="w-3.5 h-3.5" />
              <span>List Machine Capacity</span>
            </div>
            <h1 className="text-2xl font-black text-white">List Your Machine</h1>
            <p className="text-xs text-slate-400 mt-1">
              Turn unused machine hours into additional revenue by sharing your machinery with verified MSMEs.
            </p>
          </div>

          <form onSubmit={handleSubmit} className="p-6 sm:p-8 space-y-6 text-xs">
            
            {/* 1. BASIC DETAILS */}
            <div className="space-y-4">
              <h3 className="text-xs font-black uppercase tracking-wider text-amber-400 font-mono pb-2 border-b border-slate-800">
                1. Basic Machine Details
              </h3>

              <div className="space-y-1.5">
                <label className="font-semibold text-slate-300 block">Machine Display Name</label>
                <input
                  type="text"
                  value={machineName}
                  onChange={(e) => setMachineName(e.target.value)}
                  className="w-full p-3 bg-slate-900 border border-slate-800 rounded-xl text-white focus:ring-2 focus:ring-amber-500 focus:outline-none font-medium"
                  required
                />
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                <div className="space-y-1.5">
                  <label className="font-semibold text-slate-300 block">Machine Type</label>
                  <select
                    value={machineType}
                    onChange={(e) => setMachineType(e.target.value)}
                    className="w-full p-3 bg-slate-900 border border-slate-800 rounded-xl text-white focus:ring-2 focus:ring-amber-500 focus:outline-none"
                  >
                    <option value="VMC">VMC Vertical Machining</option>
                    <option value="CNC Milling">CNC Milling</option>
                    <option value="CNC Turning">CNC Turning Lathe</option>
                    <option value="Conventional Lathe">Conventional Lathe</option>
                    <option value="Laser Cutting">Laser Cutting</option>
                    <option value="Press Brake">Press Brake Bending</option>
                    <option value="Welding">Welding & Fabrication</option>
                    <option value="3D Printing">Industrial 3D Printing</option>
                  </select>
                </div>

                <div className="space-y-1.5">
                  <label className="font-semibold text-slate-300 block">Manufacturer</label>
                  <input
                    type="text"
                    value={manufacturer}
                    onChange={(e) => setManufacturer(e.target.value)}
                    className="w-full p-3 bg-slate-900 border border-slate-800 rounded-xl text-white focus:ring-2 focus:ring-amber-500 focus:outline-none"
                    required
                  />
                </div>

                <div className="space-y-1.5">
                  <label className="font-semibold text-slate-300 block">Model & Year</label>
                  <input
                    type="text"
                    value={`${model} (${year})`}
                    onChange={(e) => setModel(e.target.value)}
                    className="w-full p-3 bg-slate-900 border border-slate-800 rounded-xl text-white focus:ring-2 focus:ring-amber-500 focus:outline-none font-mono"
                    required
                  />
                </div>
              </div>

              <div className="space-y-1.5">
                <label className="font-semibold text-slate-300 block">Machine Specifications & Description</label>
                <textarea
                  rows={2}
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  className="w-full p-3 bg-slate-900 border border-slate-800 rounded-xl text-white focus:ring-2 focus:ring-amber-500 focus:outline-none"
                />
              </div>
            </div>

            {/* 2. CAPABILITY & TECHNICAL SPECS */}
            <div className="space-y-4 pt-2">
              <h3 className="text-xs font-black uppercase tracking-wider text-amber-400 font-mono pb-2 border-b border-slate-800">
                2. Machining Capabilities & Materials
              </h3>

              <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                <div className="space-y-1.5">
                  <label className="font-semibold text-slate-300 block">Compatible Material</label>
                  <select
                    value={material}
                    onChange={(e) => setMaterial(e.target.value)}
                    className="w-full p-3 bg-slate-900 border border-slate-800 rounded-xl text-white focus:ring-2 focus:ring-amber-500 focus:outline-none"
                  >
                    <option value="Aluminium">Aluminium (6061/7075)</option>
                    <option value="Stainless Steel">Stainless Steel (304/316)</option>
                    <option value="Mild Steel">Mild Steel</option>
                    <option value="Brass">Brass / Bronze</option>
                    <option value="Copper">Copper</option>
                    <option value="Nylon">Nylon / ABS</option>
                  </select>
                </div>

                <div className="space-y-1.5">
                  <label className="font-semibold text-slate-300 block">Max Dimensions (X x Y x Z)</label>
                  <input
                    type="text"
                    value={maxDimension}
                    onChange={(e) => setMaxDimension(e.target.value)}
                    className="w-full p-3 bg-slate-900 border border-slate-800 rounded-xl text-white font-mono focus:ring-2 focus:ring-amber-500 focus:outline-none"
                  />
                </div>

                <div className="space-y-1.5">
                  <label className="font-semibold text-slate-300 block">Achievable Tolerance</label>
                  <input
                    type="text"
                    value={tolerance}
                    onChange={(e) => setTolerance(e.target.value)}
                    className="w-full p-3 bg-slate-900 border border-slate-800 rounded-xl text-white font-mono focus:ring-2 focus:ring-amber-500 focus:outline-none"
                  />
                </div>
              </div>
            </div>

            {/* 3. COMMERCIAL DETAILS */}
            <div className="space-y-4 pt-2">
              <h3 className="text-xs font-black uppercase tracking-wider text-amber-400 font-mono pb-2 border-b border-slate-800">
                3. Commercial Pricing & Operator
              </h3>

              <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                <div className="space-y-1.5">
                  <label className="font-semibold text-slate-300 block">Hourly Rate (₹ INR)</label>
                  <input
                    type="number"
                    value={hourlyRate}
                    onChange={(e) => setHourlyRate(Number(e.target.value))}
                    className="w-full p-3 bg-slate-900 border border-slate-800 rounded-xl text-emerald-400 font-mono font-bold text-sm focus:ring-2 focus:ring-amber-500 focus:outline-none"
                    required
                  />
                </div>

                <div className="space-y-1.5">
                  <label className="font-semibold text-slate-300 block">Minimum Booking (Hours)</label>
                  <input
                    type="number"
                    value={minBookingHours}
                    onChange={(e) => setMinBookingHours(Number(e.target.value))}
                    className="w-full p-3 bg-slate-900 border border-slate-800 rounded-xl text-white font-mono focus:ring-2 focus:ring-amber-500 focus:outline-none"
                  />
                </div>

                <div className="space-y-1.5">
                  <label className="font-semibold text-slate-300 block">Certified Operator Provided?</label>
                  <select
                    value={operatorAvailable ? 'yes' : 'no'}
                    onChange={(e) => setOperatorAvailable(e.target.value === 'yes')}
                    className="w-full p-3 bg-slate-900 border border-slate-800 rounded-xl text-white focus:ring-2 focus:ring-amber-500 focus:outline-none font-medium"
                  >
                    <option value="yes">Yes — Certified Operator Included</option>
                    <option value="no">No — Facility Managed / Self-Operated</option>
                  </select>
                </div>
              </div>
            </div>

            {/* 4. LOCATION & AVAILABILITY */}
            <div className="space-y-4 pt-2">
              <h3 className="text-xs font-black uppercase tracking-wider text-amber-400 font-mono pb-2 border-b border-slate-800">
                4. Industrial Hub & Available Schedule
              </h3>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div className="space-y-1.5">
                  <label className="font-semibold text-slate-300 block">Industrial City (TN)</label>
                  <select
                    value={city}
                    onChange={(e) => setCity(e.target.value)}
                    className="w-full p-3 bg-slate-900 border border-slate-800 rounded-xl text-white focus:ring-2 focus:ring-amber-500 focus:outline-none"
                  >
                    <option value="Coimbatore">Coimbatore (SIDCO / Ganapathy / Peelamedu)</option>
                    <option value="Chennai">Chennai & Ambattur</option>
                    <option value="Hosur">Hosur Auto Cluster</option>
                    <option value="Salem">Salem</option>
                    <option value="Tiruppur">Tiruppur</option>
                    <option value="Erode">Erode</option>
                    <option value="Madurai">Madurai</option>
                  </select>
                </div>

                <div className="space-y-1.5">
                  <label className="font-semibold text-slate-300 block">Full Facility Address</label>
                  <input
                    type="text"
                    value={location}
                    onChange={(e) => setLocation(e.target.value)}
                    className="w-full p-3 bg-slate-900 border border-slate-800 rounded-xl text-white focus:ring-2 focus:ring-amber-500 focus:outline-none"
                  />
                </div>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                <div className="space-y-1.5">
                  <label className="font-semibold text-slate-300 block">Available Date</label>
                  <input
                    type="date"
                    value={availableDate}
                    onChange={(e) => setAvailableDate(e.target.value)}
                    className="w-full p-3 bg-slate-900 border border-slate-800 rounded-xl text-white font-mono focus:ring-2 focus:ring-amber-500 focus:outline-none"
                  />
                </div>

                <div className="space-y-1.5">
                  <label className="font-semibold text-slate-300 block">Shift Start Time</label>
                  <input
                    type="time"
                    value={startTime}
                    onChange={(e) => setStartTime(e.target.value)}
                    className="w-full p-3 bg-slate-900 border border-slate-800 rounded-xl text-white font-mono focus:ring-2 focus:ring-amber-500 focus:outline-none"
                  />
                </div>

                <div className="space-y-1.5">
                  <label className="font-semibold text-slate-300 block">Shift End Time</label>
                  <input
                    type="time"
                    value={endTime}
                    onChange={(e) => setEndTime(e.target.value)}
                    className="w-full p-3 bg-slate-900 border border-slate-800 rounded-xl text-white font-mono focus:ring-2 focus:ring-amber-500 focus:outline-none"
                  />
                </div>
              </div>
            </div>

            {/* 5. VERIFICATION UPLOAD */}
            <div className="p-5 border-2 border-dashed border-slate-800 hover:border-amber-500/50 rounded-2xl bg-slate-900/60 text-center space-y-2 transition-all">
              <Upload className="w-6 h-6 text-amber-400 mx-auto" />
              <span className="font-bold text-slate-200 block">Machine Photo & Calibration Certificate (Optional)</span>
              <span className="text-[10px] text-slate-400 block">Supports JPG, PNG, PDF up to 15MB for verification check</span>
              <input
                type="file"
                onChange={(e) => setFileName(e.target.files?.[0]?.name || 'Machine_Cert_2026.pdf')}
                className="hidden"
                id="machine-cert-file"
              />
              <label
                htmlFor="machine-cert-file"
                className="inline-block mt-2 px-4 py-2 bg-slate-800 hover:bg-slate-700 text-white rounded-xl text-xs font-bold cursor-pointer transition-colors"
              >
                {fileName ? `Attached: ${fileName}` : 'Choose File'}
              </label>
            </div>

            <button
              type="submit"
              disabled={isSubmitting}
              className="w-full py-4 bg-gradient-to-r from-amber-400 via-amber-500 to-yellow-500 hover:from-amber-300 hover:to-yellow-400 text-slate-950 font-black rounded-2xl text-xs transition-all shadow-lg shadow-amber-500/20 flex items-center justify-center gap-2"
            >
              {isSubmitting ? 'Publishing Machine...' : 'Publish Machine to Mach-Hunt Network'}
              <ArrowRight className="w-4 h-4" />
            </button>
          </form>

        </div>
      </div>
    </div>
  );
};
