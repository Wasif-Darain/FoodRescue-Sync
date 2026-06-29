import { NavLink, useNavigate } from 'react-router-dom';
import {
  LayoutDashboard, Package, Clock, Plus, Image, FileText,
  Map, ClipboardList, Truck, ShoppingBag, List,
  Bell, User, LogOut, Leaf, Repeat2,
} from 'lucide-react';
import { useAuth } from '../../context/AuthContext';

interface NavItem {
  to: string;
  icon: React.ReactNode;
  label: string;
}

const donorNav: NavItem[] = [
  { to: '/donor', icon: <LayoutDashboard size={18} />, label: 'Dashboard' },
  { to: '/donor/inventory', icon: <Package size={18} />, label: 'Inventory' },
  { to: '/donor/expiry', icon: <Clock size={18} />, label: 'Expiry Tracker' },
  { to: '/donor/create-listing', icon: <Plus size={18} />, label: 'Create Listing' },
  { to: '/donor/images', icon: <Image size={18} />, label: 'Image Manager' },
  { to: '/donor/donation-log', icon: <FileText size={18} />, label: 'Donation Log' },
];

const consumerNav: NavItem[] = [
  { to: '/consumer', icon: <ShoppingBag size={18} />, label: 'Marketplace' },
  { to: '/consumer/radar', icon: <Map size={18} />, label: 'Surplus Radar' },
  { to: '/consumer/bulk-request', icon: <List size={18} />, label: 'Bulk Request' },
  { to: '/consumer/requests', icon: <ClipboardList size={18} />, label: 'My Requests' },
  { to: '/consumer/pickups', icon: <Truck size={18} />, label: 'Pickups' },
];

const sharedBottom: NavItem[] = [
  { to: '/notifications', icon: <Bell size={18} />, label: 'Notifications' },
  { to: '/profile', icon: <User size={18} />, label: 'Profile & Settings' },
];

const accountTypeLabel: Record<string, string> = {
  restaurant: 'Restaurant',
  caterer: 'Caterer',
  store: 'Store',
  ngo: 'NGO',
  food_bank: 'Food Bank',
  shelter: 'Shelter',
  individual: 'Individual',
};

export function Sidebar() {
  const { user, logout, toggleMode } = useAuth();
  const navigate = useNavigate();

  const isDonorMode = user?.mode === 'donor';
  const navItems = isDonorMode ? donorNav : consumerNav;

  const handleLogout = () => {
    logout();
    navigate('/');
  };

  return (
    <aside className="fixed left-0 top-0 h-full w-60 bg-white border-r border-gray-100 flex flex-col z-40">
      <div className="p-5 border-b border-gray-100">
        <div className="flex items-center gap-2.5">
          <div className="w-9 h-9 bg-green-600 rounded-xl flex items-center justify-center">
            <Leaf size={18} className="text-white" />
          </div>
          <div>
            <p className="font-bold text-gray-900 text-sm leading-tight">FoodRescue</p>
            <p className="text-xs text-green-600 font-medium">Sync</p>
          </div>
        </div>
      </div>

      <div className="p-4 border-b border-gray-100">
        <div className="flex items-center gap-3 mb-3">
          <div className="w-9 h-9 rounded-full bg-green-100 flex items-center justify-center shrink-0">
            <span className="text-green-700 font-semibold text-sm">{user?.name.charAt(0)}</span>
          </div>
          <div className="min-w-0">
            <p className="text-sm font-semibold text-gray-900 truncate">{user?.name}</p>
            <p className="text-xs text-gray-400">
              {user?.accountType ? accountTypeLabel[user.accountType] : ''}
            </p>
          </div>
        </div>

        <button
          onClick={toggleMode}
          className={`w-full flex items-center justify-between px-3 py-2 rounded-lg text-xs font-semibold transition-all border ${
            isDonorMode
              ? 'bg-green-50 text-green-700 border-green-200 hover:bg-green-100'
              : 'bg-orange-50 text-orange-600 border-orange-200 hover:bg-orange-100'
          }`}
        >
          <span>{isDonorMode ? 'Donor Mode' : 'Consumer Mode'}</span>
          <Repeat2 size={14} />
        </button>
        <p className="text-xs text-gray-400 text-center mt-1.5">Tap to switch mode</p>
      </div>

      <nav className="flex-1 overflow-y-auto py-3 px-3">
        <div className="space-y-0.5">
          {navItems.map((item) => (
            <NavLink
              key={item.to}
              to={item.to}
              end={item.to === '/donor' || item.to === '/consumer'}
              className={({ isActive }) =>
                `flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-colors ${
                  isActive
                    ? isDonorMode ? 'bg-green-50 text-green-700' : 'bg-orange-50 text-orange-600'
                    : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
                }`
              }
            >
              {item.icon}
              {item.label}
            </NavLink>
          ))}
        </div>

        <div className="mt-4 pt-4 border-t border-gray-100 space-y-0.5">
          {sharedBottom.map((item) => (
            <NavLink
              key={item.to}
              to={item.to}
              className={({ isActive }) =>
                `flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-colors ${
                  isActive
                    ? 'bg-green-50 text-green-700'
                    : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
                }`
              }
            >
              {item.icon}
              {item.label}
              {item.label === 'Notifications' && (
                <span className="ml-auto bg-red-500 text-white text-xs rounded-full w-4 h-4 flex items-center justify-center">3</span>
              )}
            </NavLink>
          ))}
        </div>
      </nav>

      <div className="p-3 border-t border-gray-100">
        <button
          onClick={handleLogout}
          className="flex items-center gap-3 w-full px-3 py-2.5 rounded-lg text-sm font-medium text-red-500 hover:bg-red-50 transition-colors"
        >
          <LogOut size={18} />
          Logout
        </button>
      </div>
    </aside>
  );
}
