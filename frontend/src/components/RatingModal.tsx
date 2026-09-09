import React, { useState } from 'react';
import { X, Star, CheckCircle } from 'lucide-react';

interface RatingModalProps {
  bookingId: number;
  ownerName: string;
  onSubmit: (ratingData: any) => void;
  onClose: () => void;
}

export const RatingModal: React.FC<RatingModalProps> = ({ bookingId, ownerName, onSubmit, onClose }) => {
  const [rating, setRating] = useState(5);
  const [qualityRating, setQualityRating] = useState(5);
  const [reliabilityRating, setReliabilityRating] = useState(5);
  const [comment, setComment] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSubmit({
      booking_id: bookingId,
      rating,
      quality_rating: qualityRating,
      reliability_rating: reliabilityRating,
      communication_rating: 5,
      comment
    });
  };

  return (
    <div className="fixed inset-0 z-50 bg-slate-900/60 backdrop-blur-xs flex items-center justify-center p-4">
      <div className="bg-white rounded-xl max-w-md w-full shadow-2xl border border-slate-200 overflow-hidden">
        <div className="bg-slate-900 text-white p-5 flex items-center justify-between">
          <div>
            <h3 className="text-base font-bold">Rate & Review MSME Capacity</h3>
            <p className="text-xs text-slate-300">Feedback for {ownerName}</p>
          </div>
          <button onClick={onClose} className="p-1 text-slate-400 hover:text-white">
            <X className="w-5 h-5" />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="p-6 space-y-4 text-xs">
          {/* Star selection */}
          <div className="text-center space-y-2 py-2">
            <span className="text-xs font-semibold text-slate-700 block">Overall Performance Rating</span>
            <div className="flex justify-center gap-1">
              {[1, 2, 3, 4, 5].map((star) => (
                <button
                  type="button"
                  key={star}
                  onClick={() => setRating(star)}
                  className="p-1 hover:scale-110 transition-transform"
                >
                  <Star className={`w-8 h-8 ${star <= rating ? 'fill-amber-400 text-amber-400' : 'text-slate-300'}`} />
                </button>
              ))}
            </div>
          </div>

          <div className="space-y-2">
            <label className="font-semibold text-slate-700 block">Job Experience Review</label>
            <textarea
              rows={3}
              value={comment}
              onChange={(e) => setComment(e.target.value)}
              placeholder="e.g. Outstanding precision milling quality and on-time delivery by Janika's Kovai Precision Works team!"
              className="w-full p-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:outline-none"
              required
            />
          </div>

          <button
            type="submit"
            className="w-full py-2.5 bg-slate-900 hover:bg-blue-600 text-white font-bold rounded-lg text-xs transition-colors shadow-2xs"
          >
            Submit Review & Update MSME Trust Score
          </button>
        </form>
      </div>
    </div>
  );
};
