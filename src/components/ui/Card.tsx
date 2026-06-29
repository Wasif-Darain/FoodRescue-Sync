import type { ReactNode } from 'react';

interface CardProps {
  children: ReactNode;
  className?: string;
  padding?: boolean;
}

export function Card({ children, className = '', padding = true }: CardProps) {
  return (
    <div className={`bg-white rounded-xl border border-gray-100 shadow-sm ${padding ? 'p-5' : ''} ${className}`}>
      {children}
    </div>
  );
}

interface StatCardProps {
  label: string;
  value: string | number;
  icon: ReactNode;
  color?: 'green' | 'orange' | 'blue' | 'red';
  subtitle?: string;
}

const colors = {
  green: { bg: 'bg-green-50', icon: 'bg-green-100 text-green-700', text: 'text-green-700' },
  orange: { bg: 'bg-orange-50', icon: 'bg-orange-100 text-orange-700', text: 'text-orange-700' },
  blue: { bg: 'bg-blue-50', icon: 'bg-blue-100 text-blue-700', text: 'text-blue-700' },
  red: { bg: 'bg-red-50', icon: 'bg-red-100 text-red-700', text: 'text-red-700' },
};

export function StatCard({ label, value, icon, color = 'green', subtitle }: StatCardProps) {
  const c = colors[color];
  return (
    <div className={`rounded-xl p-5 ${c.bg} border border-transparent`}>
      <div className="flex items-center justify-between mb-3">
        <div className={`p-2 rounded-lg ${c.icon}`}>{icon}</div>
      </div>
      <p className={`text-2xl font-bold ${c.text}`}>{value}</p>
      <p className="text-sm text-gray-600 mt-0.5">{label}</p>
      {subtitle && <p className="text-xs text-gray-400 mt-1">{subtitle}</p>}
    </div>
  );
}
