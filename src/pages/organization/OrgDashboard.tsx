import { Link } from 'react-router-dom';
import { Layout } from '../../components/layout/Layout';
import { Card, StatCard } from '../../components/ui/Card';
import { Badge } from '../../components/ui/Badge';
import { Button } from '../../components/ui/Button';
import { Package, Truck, ClipboardList, Heart, ArrowRight, MapPin } from 'lucide-react';
import { mockListings, mockRequests, mockPickups } from '../../data/mockData';

export function OrgDashboard() {
  const donations = mockListings.filter(l => l.listingType === 'donation' && l.status === 'active');
  const pendingRequests = mockRequests.filter(r => r.status === 'pending');
  const upcomingPickups = mockPickups.filter(p => p.status !== 'completed');

  return (
    <Layout
      title="Organization Dashboard"
      subtitle="Find available donations and manage your food requests"
      actions={
        <Link to="/org/bulk-request">
          <Button icon={<Package size={16} />}>Bulk Request</Button>
        </Link>
      }
    >
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        <StatCard label="Available Donations" value={donations.length} icon={<Heart size={20} />} color="green" />
        <StatCard label="Pending Requests" value={pendingRequests.length} icon={<ClipboardList size={20} />} color="orange" />
        <StatCard label="Upcoming Pickups" value={upcomingPickups.length} icon={<Truck size={20} />} color="blue" />
        <StatCard label="Meals Received" value="1,240" icon={<Package size={20} />} color="red" subtitle="This month" />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2 space-y-6">
          <Card>
            <div className="flex items-center justify-between mb-4">
              <h2 className="font-semibold text-gray-900">Available Donations Nearby</h2>
              <Link to="/org/radar" className="text-sm text-green-600 hover:underline flex items-center gap-1">
                View map <ArrowRight size={14} />
              </Link>
            </div>
            <div className="space-y-3">
              {donations.map(listing => (
                <div key={listing.id} className="flex items-start justify-between p-4 border border-gray-100 rounded-xl hover:bg-gray-50 transition-colors">
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2 mb-1 flex-wrap">
                      <p className="font-medium text-gray-900 text-sm">{listing.title}</p>
                      <Badge variant="green">Donation</Badge>
                    </div>
                    <p className="text-xs text-gray-500 mb-1">{listing.donorName}</p>
                    <div className="flex items-center gap-3 text-xs text-gray-400">
                      <span><MapPin size={10} className="inline mr-1" />{listing.distance} km away</span>
                      <span>Qty: {listing.quantity}</span>
                      <span>Pickup by {new Date(listing.pickupEnd).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</span>
                    </div>
                  </div>
                  <Link to="/org/bulk-request">
                    <Button size="sm">Claim</Button>
                  </Link>
                </div>
              ))}
            </div>
          </Card>

          <Card>
            <div className="flex items-center justify-between mb-4">
              <h2 className="font-semibold text-gray-900">Upcoming Pickups</h2>
              <Link to="/org/pickups" className="text-sm text-green-600 hover:underline flex items-center gap-1">
                View all <ArrowRight size={14} />
              </Link>
            </div>
            {upcomingPickups.length === 0 ? (
              <div className="text-center py-6 text-gray-400">
                <Truck size={36} className="mx-auto mb-2 opacity-40" />
                <p className="text-sm">No pickups scheduled</p>
              </div>
            ) : (
              <div className="space-y-3">
                {upcomingPickups.map(pickup => (
                  <div key={pickup.id} className="flex items-center justify-between p-4 border border-gray-100 rounded-xl">
                    <div className="flex items-center gap-3">
                      <div className={`w-10 h-10 rounded-xl flex items-center justify-center ${pickup.status === 'en_route' ? 'bg-blue-100' : 'bg-green-100'}`}>
                        <Truck size={18} className={pickup.status === 'en_route' ? 'text-blue-600' : 'text-green-600'} />
                      </div>
                      <div>
                        <p className="text-sm font-medium text-gray-900">{pickup.donorName}</p>
                        <p className="text-xs text-gray-400">{pickup.address}</p>
                        <p className="text-xs text-gray-400">{new Date(pickup.scheduledTime).toLocaleString()}</p>
                      </div>
                    </div>
                    <Badge variant={pickup.status === 'en_route' ? 'blue' : 'green'}>
                      {pickup.status === 'en_route' ? 'En Route' : 'Scheduled'}
                    </Badge>
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
                { to: '/org/radar', label: 'Surplus Radar Map', variant: 'outline' as const },
                { to: '/org/bulk-request', label: 'Submit Bulk Request', variant: 'primary' as const },
                { to: '/org/requests', label: 'Track Requests', variant: 'outline' as const },
                { to: '/org/pickups', label: 'Pickup Schedule', variant: 'ghost' as const },
              ].map(a => (
                <Link key={a.to} to={a.to}>
                  <Button variant={a.variant} fullWidth>{a.label}</Button>
                </Link>
              ))}
            </div>
          </Card>

          <Card>
            <h2 className="font-semibold text-gray-900 mb-4">Request Status</h2>
            <div className="space-y-3">
              {mockRequests.map(req => (
                <div key={req.id} className="flex items-center justify-between">
                  <p className="text-sm text-gray-700 truncate flex-1 mr-2">{req.listingTitle}</p>
                  <Badge variant={
                    req.status === 'accepted' ? 'green' :
                    req.status === 'rejected' ? 'red' :
                    req.status === 'completed' ? 'blue' : 'yellow'
                  }>
                    {req.status.charAt(0).toUpperCase() + req.status.slice(1)}
                  </Badge>
                </div>
              ))}
            </div>
          </Card>
        </div>
      </div>
    </Layout>
  );
}
