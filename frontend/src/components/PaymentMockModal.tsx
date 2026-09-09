import React, { useState } from 'react';
import { X, CreditCard, ShieldCheck, CheckCircle2, ArrowRight } from 'lucide-react';

interface PaymentMockModalProps {
  agreedPrice: number;
  machineName: string;
  ownerName: string;
  onSuccess: () => void;
  onClose: () => void;
}

export const PaymentMockModal: React.FC<PaymentMockModalProps> = ({
  agreedPrice,
  machineName,
  ownerName,
  onSuccess,
  onClose
}) => {
  const [processing, setProcessing] = useState(false);
  const [paid, setPaid] = useState(false);

  const platformFee = roundTwoDecimals(agreedPrice * 0.05);
  const grandTotal = roundTwoDecimals(agreedPrice + platformFee);

  function roundTwoDecimals(num: number) {
    return Math.round(num * 100) / 100;
  }

  const handlePay = () => {
    setProcessing(true);
    setTimeout(() => {
      setProcessing(false);
      setPaid(true);
      setTimeout(() => {
        onSuccess();
      }, 1500);
    }, 1200);
  };

  return (
    <div className="fixed inset-0 z-50 bg-slate-900/60 backdrop-blur-xs flex items-center justify-center p-4">
      <div className="bg-white rounded-xl max-w-md w-full shadow-2xl border border-slate-200 overflow-hidden">
        {/* Header */}
        <div className="bg-slate-900 text-white p-5 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <CreditCard className="w-5 h-5 text-blue-400" />
            <h3 className="text-base font-bold">Razorpay Mock Payment Gateway</h3>
          </div>
          <button onClick={onClose} className="p-1 text-slate-400 hover:text-white">
            <X className="w-5 h-5" />
          </button>
        </div>

        {paid ? (
          <div className="p-8 text-center space-y-4">
            <div className="w-16 h-16 bg-emerald-100 text-emerald-600 rounded-full flex items-center justify-center mx-auto">
              <CheckCircle2 className="w-10 h-10" />
            </div>
            <h4 className="text-xl font-extrabold text-slate-900">Payment Successful!</h4>
            <p className="text-xs text-slate-500 font-mono">Ref: PAY_MH_TN_98741235</p>
            <p className="text-xs text-slate-600">Booking confirmed with {ownerName}. Production schedule activated.</p>
          </div>
        ) : (
          <div className="p-6 space-y-5">
            <div className="bg-slate-50 p-4 rounded-lg border border-slate-200 space-y-2 text-xs">
              <div className="flex justify-between">
                <span className="text-slate-500">Machine Capacity:</span>
                <span className="font-bold text-slate-800">{machineName}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-slate-500">Capacity Provider:</span>
                <span className="font-bold text-slate-800">{ownerName}</span>
              </div>
              <div className="border-t border-slate-200 pt-2 flex justify-between">
                <span className="text-slate-600">Manufacturing Job Value:</span>
                <span className="font-mono font-bold text-slate-900">₹{agreedPrice.toLocaleString('en-IN')}</span>
              </div>
              <div className="flex justify-between text-slate-500">
                <span>Platform Assurance Fee (5%):</span>
                <span className="font-mono">₹{platformFee.toLocaleString('en-IN')}</span>
              </div>
              <div className="border-t border-slate-300 pt-2 flex justify-between font-bold text-sm text-blue-700">
                <span>Total Payable Amount:</span>
                <span className="font-mono text-base">₹{grandTotal.toLocaleString('en-IN')}</span>
              </div>
            </div>

            <div className="flex items-center gap-2 text-xs text-slate-500 bg-emerald-50 text-emerald-800 p-2.5 rounded border border-emerald-100">
              <ShieldCheck className="w-4 h-4 text-emerald-600 shrink-0" />
              <span>Escrow protection: Funds held securely until job inspection completion.</span>
            </div>

            <button
              onClick={handlePay}
              disabled={processing}
              className="w-full py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-lg text-sm font-bold flex items-center justify-center gap-2 transition-all shadow-md"
            >
              {processing ? (
                <span>Processing Escrow Authorization...</span>
              ) : (
                <>
                  <span>Confirm Escrow Payment (₹{grandTotal.toLocaleString('en-IN')})</span>
                  <ArrowRight className="w-4 h-4" />
                </>
              )}
            </button>
          </div>
        )}
      </div>
    </div>
  );
};
