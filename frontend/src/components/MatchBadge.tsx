import React from 'react';
import { Sparkles } from 'lucide-react';

interface MatchBadgeProps {
  percentage: number;
  onClick?: () => void;
  size?: 'sm' | 'md' | 'lg';
}

export const MatchBadge: React.FC<MatchBadgeProps> = ({ percentage, onClick, size = 'md' }) => {
  let colorStyle = 'bg-emerald-500/10 text-emerald-700 border-emerald-500/30';
  if (percentage < 85 && percentage >= 75) {
    colorStyle = 'bg-blue-500/10 text-blue-700 border-blue-500/30';
  } else if (percentage < 75) {
    colorStyle = 'bg-amber-500/10 text-amber-800 border-amber-500/30';
  }

  const padding = size === 'sm' ? 'px-2 py-0.5 text-xs' : size === 'lg' ? 'px-3.5 py-1.5 text-base font-extrabold' : 'px-2.5 py-1 text-sm font-bold';

  return (
    <button
      onClick={onClick}
      className={`inline-flex items-center gap-1.5 rounded-full border ${colorStyle} ${padding} transition-all hover:scale-105 active:scale-95 shadow-2xs font-mono`}
      title="Click to view transparent weighted score breakdown"
    >
      <Sparkles className={size === 'sm' ? 'w-3 h-3' : 'w-3.5 h-3.5'} />
      <span>{percentage}% Match</span>
    </button>
  );
};
