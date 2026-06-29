interface BadgeProps {
  children: React.ReactNode;
  variant?: 'green' | 'orange' | 'red' | 'blue' | 'gray' | 'yellow';
  size?: 'sm' | 'md';
}

const variants = {
  green: 'bg-green-100 text-green-800',
  orange: 'bg-orange-100 text-orange-800',
  red: 'bg-red-100 text-red-800',
  blue: 'bg-blue-100 text-blue-800',
  gray: 'bg-gray-100 text-gray-700',
  yellow: 'bg-yellow-100 text-yellow-800',
};

export function Badge({ children, variant = 'gray', size = 'sm' }: BadgeProps) {
  return (
    <span className={`inline-flex items-center font-medium rounded-full ${variants[variant]} ${size === 'sm' ? 'px-2.5 py-0.5 text-xs' : 'px-3 py-1 text-sm'}`}>
      {children}
    </span>
  );
}
