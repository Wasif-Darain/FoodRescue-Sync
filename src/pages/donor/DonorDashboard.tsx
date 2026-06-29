import { Link } from 'react-router-dom';
import { Layout } from '../../components/layout/Layout';
import { Card, StatCard } from '../../components/ui/Card';
import { Badge } from '../../components/ui/Badge';
import { Button } from '../../components/ui/Button';
import { Package, Clock, TrendingUp, Heart, Plus, AlertTriangle, ArrowRight } from 'lucide-react';
import { mockInventory, mockListings, mockDonationLogs } from '../../data/mockData';

export function DonorDashboard() {
  const surplusItems = mockInventory.filter(i => i.isSurplus);
  const expiringToday = mockInventory.filter(i => {
    const diff = new Date(i.expiryDate).getTime() - Date.now();
    return diff < 86400000 && diff > 0;
  });
  const activeListings = mockListings.filter(l => l.status === 'active').slice(0, 3);

  return (
    <Layout
      title="Donor Dashboard"
      subtitle="Manage your inventory, listings, and track donations"
      actions={
        <Link to="/donor/create-listing">
          <Button icon={<Plus size={16} />}>New Listing</Button>
        </Link>
      }
    >
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        <StatCard label="Total Items" value={mockInventory.length} icon={<Package size={20} />} color="blue" />
        <StatCard label="Surplus Tagged" value={surplusItems.length} icon={<AlertTriangle size={20} />} color="orange" subtitle="Need redistribution" />
        <StatCard label="Active Listings" value={activeListings.length} icon={<TrendingUp size={20} />} color="green" />
        <StatCard label="Total Donated" value={mockDonationLogs.length} icon={<Heart size={20} />} color="red" subtitle="This month" />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2 space-y-6">
          {expiringToday.length > 0 && (
            <Card>
              <div className="flex items-center justify-between mb-4">
                <h2 className="font-semibold text-gray-900 flex items-center gap-2">
                  <AlertTriangle size={18} className="text-orange-500" />
                  Expiring Today
                </h2>
                <Link to="/donor/expiry" className="text-sm text-green-600 hover:underline flex items-center gap-1">
                  View all <ArrowRight size={14} />
                </Link>
              </div>
              <div className="space-y-3">
                {expiringToday.map(item => (
                  <div key={item.id} className="flex items-center justify-between p-3 bg-orange-50 rounded-lg border border-orange-100">
                    <div>
                      <p className="text-sm font-medium text-gray-900">{item.name}</p>
                      <p className="text-xs text-gray-500">Qty: {item.quantity} · Expires: {item.expiryDate}</p>
                    </div>
                    <Link to="/donor/create-listing">
                      <Button size="sm" variant="secondary">List Now</Button>
                    </Link>
                  </div>
                ))}
              </div>
            </Card>
          )}

          <Card>
            <div className="flex items-center justify-between mb-4">
              <h2 className="font-semibold text-gray-900">Active Listings</h2>
              <Link to="/donor/create-listing" className="text-sm text-green-600 hover:underline flex items-center gap-1">
                Add new <ArrowRight size={14} />
              </Link>
            </div>
            {activeListings.length === 0 ? (
              <div className="text-center py-8 text-gray-400">
                <Package size={40} className="mx-auto mb-2 opacity-40" />
                <p className="text-sm">No active listings yet</p>
              </div>
            ) : (
              <div className="space-y-3">
                {activeListings.map(l => (
                  <div key={l.id} className="flex items-start justify-between p-4 border border-gray-100 rounded-xl hover:bg-gray-50 transition-colors">
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2 mb-1">
                        <p className="font-medium text-gray-900 text-sm">{l.title}</p>
                        <Badge variant={l.listingType === 'donation' ? 'green' : 'orange'}>
                          {l.listingType === 'donation' ? 'Donation' : 'Flash Sale'}
                        </Badge>
                      </div>
                      <p className="text-xs text-gray-500">Qty: {l.quantity} · Pickup: {new Date(l.pickupStart).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</p>
                    </div>
                    <Badge variant="green">Active</Badge>
                  </div>
                ))}
              </div>
            )}
          </Card>
        </div>

        <div className="space-y-6">
          <Card>
            <h2 className="font-semibold text-gray-900 mb-4">Quick Actions</h2>
            <div className="space-y-2">
              {[
                { to: '/donor/inventory', label: 'Add Inventory', icon: <Plus size={16} />, variant: 'outline' as const },
                { to: '/donor/create-listing', label: 'Create Listing', icon: <TrendingUp size={16} />, variant: 'primary' as const },
                { to: '/donor/expiry', label: 'Check Expiry', icon: <Clock size={16} />, variant: 'outline' as const },
                { to: '/donor/donation-log', label: 'View Donation Log', icon: <Heart size={16} />, variant: 'ghost' as const },
              ].map(action => (
                <Link key={action.to} to={action.to}>
                  <Button variant={action.variant} icon={action.icon} fullWidth>{action.label}</Button>
                </Link>
              ))}
            </div>
          </Card>

          <Card className="bg-gradient-to-br from-green-600 to-green-700 border-0 text-white" padding={false}>
            <div className="p-5">
              <Heart size={28} className="text-green-200 mb-3" />
              <p className="text-lg font-bold mb-1">Impact This Month</p>
              <p className="text-green-100 text-sm mb-4">You've helped reduce food waste significantly</p>
              <div className="grid grid-cols-2 gap-3">
                {[
                  { value: '50 kg', label: 'Food Saved' },
                  { value: '120', label: 'Meals Rescued' },
                ].map(s => (
                  <div key={s.label} className="bg-white/10 rounded-lg p-3">
                    <p className="text-xl font-bold">{s.value}</p>
                    <p className="text-green-100 text-xs">{s.label}</p>
                  </div>
                ))}
              </div>
            </div>
          </Card>
        </div>
      </div>
    </Layout>
  );
}
