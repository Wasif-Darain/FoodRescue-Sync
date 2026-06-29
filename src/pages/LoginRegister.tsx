import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import {
  Leaf, Eye, EyeOff, UtensilsCrossed, ChefHat, Store,
  Building2, Heart, Home, User,
} from 'lucide-react';
import type { AccountType } from '../types';
import { useAuth } from '../context/AuthContext';
import { Button } from '../components/ui/Button';

interface TypeConfig {
  label: string;
  icon: React.ReactNode;
  nameLabel: string;
  needsAddress: boolean;
  extraField?: { label: string; placeholder: string };
}

const accountTypeConfig: Record<AccountType, TypeConfig> = {
  restaurant: {
    label: 'Restaurant',
    icon: <UtensilsCrossed size={16} />,
    nameLabel: 'Restaurant Name',
    needsAddress: true,
    extraField: { label: 'Cuisine Type', placeholder: 'e.g. Bangladeshi, Italian' },
  },
  caterer: {
    label: 'Caterer',
    icon: <ChefHat size={16} />,
    nameLabel: 'Business Name',
    needsAddress: true,
    extraField: { label: 'Service Area', placeholder: 'e.g. Dhaka, Chittagong' },
  },
  store: {
    label: 'Store',
    icon: <Store size={16} />,
    nameLabel: 'Store Name',
    needsAddress: true,
    extraField: { label: 'Store Type', placeholder: 'e.g. Grocery, Bakery' },
  },
  ngo: {
    label: 'NGO',
    icon: <Building2 size={16} />,
    nameLabel: 'Organization Name',
    needsAddress: true,
    extraField: { label: 'Registration No.', placeholder: 'NGO registration number' },
  },
  food_bank: {
    label: 'Food Bank',
    icon: <Heart size={16} />,
    nameLabel: 'Food Bank Name',
    needsAddress: true,
    extraField: { label: 'Storage Capacity', placeholder: 'e.g. 500 kg' },
  },
  shelter: {
    label: 'Shelter',
    icon: <Home size={16} />,
    nameLabel: 'Shelter Name',
    needsAddress: true,
    extraField: { label: 'Capacity (people)', placeholder: 'Number of people served' },
  },
  individual: {
    label: 'Individual',
    icon: <User size={16} />,
    nameLabel: 'Full Name',
    needsAddress: false,
  },
};

const inputCls = 'w-full px-3.5 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent';
const labelCls = 'block text-sm font-medium text-gray-700 mb-1.5';

export function LoginRegister() {
  const [mode, setMode] = useState<'login' | 'register'>('login');
  const [accountType, setAccountType] = useState<AccountType>('restaurant');
  const [showPassword, setShowPassword] = useState(false);
  const [form, setForm] = useState({ name: '', email: '', password: '', phone: '', address: '', extra: '' });
  const navigate = useNavigate();
  const { login } = useAuth();

  const cfg = accountTypeConfig[accountType];

  const set = (key: string) => (e: React.ChangeEvent<HTMLInputElement>) =>
    setForm(f => ({ ...f, [key]: e.target.value }));

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    login(form.email, form.password, accountType, form.name || 'User');
    navigate('/donor');
  };

  const switchMode = () => {
    setMode(m => m === 'login' ? 'register' : 'login');
    setForm({ name: '', email: '', password: '', phone: '', address: '', extra: '' });
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 via-white to-orange-50 flex items-center justify-center px-4 py-8">
      <div className="w-full max-w-md">
        <div className="text-center mb-8">
          <Link to="/" className="inline-flex items-center gap-2.5 mb-6">
            <div className="w-10 h-10 bg-green-600 rounded-xl flex items-center justify-center">
              <Leaf size={20} className="text-white" />
            </div>
            <div className="text-left">
              <p className="font-bold text-gray-900 leading-none">FoodRescue</p>
              <p className="text-green-600 font-semibold text-sm">Sync</p>
            </div>
          </Link>
          <h1 className="text-2xl font-bold text-gray-900">
            {mode === 'login' ? 'Welcome back!' : 'Create your account'}
          </h1>
          <p className="text-gray-500 text-sm mt-1">
            {mode === 'login' ? 'Sign in to continue' : 'Join FoodRescue Sync today'}
          </p>
        </div>

        <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
          {mode === 'register' && (
            <div className="mb-5">
              <p className="text-xs font-semibold text-gray-400 uppercase tracking-wider mb-3">Account Type</p>
              <div className="grid grid-cols-4 gap-2">
                {(Object.entries(accountTypeConfig) as [AccountType, TypeConfig][]).map(([type, c]) => (
                  <button
                    key={type}
                    type="button"
                    onClick={() => { setAccountType(type); setForm(f => ({ ...f, name: '', address: '', extra: '' })); }}
                    className={`flex flex-col items-center gap-1.5 p-2.5 rounded-xl border-2 text-xs font-medium transition-all ${
                      accountType === type
                        ? 'border-green-500 text-green-600 bg-green-50'
                        : 'border-gray-100 text-gray-500 hover:border-gray-200'
                    }`}
                  >
                    {c.icon}
                    <span className="leading-tight text-center">{c.label}</span>
                  </button>
                ))}
              </div>
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-4">
            {mode === 'register' && (
              <div>
                <label className={labelCls}>{cfg.nameLabel}</label>
                <input
                  type="text" required
                  value={form.name} onChange={set('name')}
                  placeholder={`Enter ${cfg.nameLabel.toLowerCase()}`}
                  className={inputCls}
                />
              </div>
            )}

            <div>
              <label className={labelCls}>Email</label>
              <input
                type="email" required
                value={form.email} onChange={set('email')}
                placeholder="you@example.com"
                className={inputCls}
              />
            </div>

            {mode === 'register' && (
              <div>
                <label className={labelCls}>Phone Number</label>
                <input
                  type="tel"
                  value={form.phone} onChange={set('phone')}
                  placeholder="+880 XXXX XXXXXX"
                  className={inputCls}
                />
              </div>
            )}

            {mode === 'register' && cfg.needsAddress && (
              <div>
                <label className={labelCls}>Address</label>
                <input
                  type="text"
                  value={form.address} onChange={set('address')}
                  placeholder="Business / organization address"
                  className={inputCls}
                />
              </div>
            )}

            {mode === 'register' && cfg.extraField && (
              <div>
                <label className={labelCls}>{cfg.extraField.label}</label>
                <input
                  type="text"
                  value={form.extra} onChange={set('extra')}
                  placeholder={cfg.extraField.placeholder}
                  className={inputCls}
                />
              </div>
            )}

            <div>
              <label className={labelCls}>Password</label>
              <div className="relative">
                <input
                  type={showPassword ? 'text' : 'password'} required
                  value={form.password} onChange={set('password')}
                  placeholder="Enter your password"
                  className={`${inputCls} pr-10`}
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(s => !s)}
                  className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                >
                  {showPassword ? <EyeOff size={16} /> : <Eye size={16} />}
                </button>
              </div>
            </div>

            <Button type="submit" fullWidth size="lg" className="mt-2 bg-green-600 hover:opacity-90">
              {mode === 'login' ? 'Sign In' : 'Create Account'}
            </Button>
          </form>

          <p className="text-center text-sm text-gray-500 mt-5">
            {mode === 'login' ? "Don't have an account? " : 'Already have an account? '}
            <button onClick={switchMode} className="text-green-600 font-semibold hover:underline">
              {mode === 'login' ? 'Sign up' : 'Sign in'}
            </button>
          </p>
        </div>
      </div>
    </div>
  );
}
