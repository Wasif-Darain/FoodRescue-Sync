import { Layout } from '../../components/layout/Layout';
import { Card } from '../../components/ui/Card';
import { Badge } from '../../components/ui/Badge';
import { Button } from '../../components/ui/Button';
import { Truck, MapPin, Clock, Package, CheckCircle, Navigation } from 'lucide-react';
import { mockPickups } from '../../data/mockData';

const statusSteps = ['scheduled', 'en_route', 'completed'];

export function PickupCoordination() {
  return (
    <Layout title="Pickup Coordination" subtitle="Manage pickup logistics, addresses, and status updates">
      <div className="grid grid-cols-3 gap-4 mb-8">
        {[
          { label: 'Scheduled', value: 1, color: 'bg-blue-50 border-blue-200 text-blue-700' },
          { label: 'En Route', value: 1, color: 'bg-orange-50 border-orange-200 text-orange-700' },
          { label: 'Completed', value: 0, color: 'bg-green-50 border-green-200 text-green-700' },
        ].map(stat => (
          <div key={stat.label} className={`rounded-xl p-5 border ${stat.color}`}>
            <p className="text-3xl font-bold">{stat.value}</p>
            <p className="text-sm font-medium mt-1">{stat.label}</p>
          </div>
        ))}
      </div>

      <div className="space-y-6">
        {mockPickups.map(pickup => {
          const currentStep = statusSteps.indexOf(pickup.status);
          return (
            <Card key={pickup.id}>
              <div className="flex items-start justify-between mb-5">
                <div className="flex items-center gap-4">
                  <div className={`w-12 h-12 rounded-2xl flex items-center justify-center ${
                    pickup.status === 'en_route' ? 'bg-orange-100' :
                    pickup.status === 'completed' ? 'bg-green-100' : 'bg-blue-100'
                  }`}>
                    <Truck size={22} className={
                      pickup.status === 'en_route' ? 'text-orange-600' :
                      pickup.status === 'completed' ? 'text-green-600' : 'text-blue-600'
                    } />
                  </div>
                  <div>
                    <p className="font-semibold text-gray-900">{pickup.donorName}</p>
                    <p className="text-sm text-gray-500">Pickup #{pickup.id}</p>
                  </div>
                </div>
                <Badge variant={
                  pickup.status === 'en_route' ? 'orange' :
                  pickup.status === 'completed' ? 'green' : 'blue'
                } size="md">
                  {pickup.status === 'en_route' ? 'En Route' :
                   pickup.status === 'completed' ? 'Completed' : 'Scheduled'}
                </Badge>
              </div>

              <div className="flex gap-0 mb-5 relative">
                <div className="absolute top-4 left-4 right-4 h-0.5 bg-gray-200">
                  <div
                    className="h-full bg-green-500 transition-all"
                    style={{ width: `${(currentStep / (statusSteps.length - 1)) * 100}%` }}
                  />
                </div>
                {statusSteps.map((step, i) => (
                  <div key={step} className="flex-1 flex flex-col items-center relative z-10">
                    <div className={`w-8 h-8 rounded-full flex items-center justify-center border-2 ${
                      i <= currentStep ? 'border-green-500 bg-green-500' : 'border-gray-200 bg-white'
                    }`}>
                      {i <= currentStep
                        ? <CheckCircle size={16} className="text-white" />
                        : <span className="text-xs text-gray-400 font-medium">{i + 1}</span>
                      }
                    </div>
                    <p className={`text-xs mt-1.5 font-medium capitalize ${i <= currentStep ? 'text-green-600' : 'text-gray-400'}`}>
                      {step.replace('_', ' ')}
                    </p>
                  </div>
                ))}
              </div>

              <div className="grid grid-cols-3 gap-4 p-4 bg-gray-50 rounded-xl">
                <div className="flex items-start gap-2.5">
                  <MapPin size={16} className="text-gray-400 mt-0.5 shrink-0" />
                  <div>
                    <p className="text-xs text-gray-400 mb-0.5">Pickup Address</p>
                    <p className="text-sm font-medium text-gray-800">{pickup.address}</p>
                  </div>
                </div>
                <div className="flex items-start gap-2.5">
                  <Clock size={16} className="text-gray-400 mt-0.5 shrink-0" />
                  <div>
                    <p className="text-xs text-gray-400 mb-0.5">Scheduled Time</p>
                    <p className="text-sm font-medium text-gray-800">
                      {new Date(pickup.scheduledTime).toLocaleString([], {
                        month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit'
                      })}
                    </p>
                  </div>
                </div>
                <div className="flex items-start gap-2.5">
                  <Package size={16} className="text-gray-400 mt-0.5 shrink-0" />
                  <div>
                    <p className="text-xs text-gray-400 mb-0.5">Items</p>
                    {pickup.items.map((item, i) => (
                      <p key={i} className="text-sm font-medium text-gray-800">{item}</p>
                    ))}
                  </div>
                </div>
              </div>

              {pickup.status !== 'completed' && (
                <div className="flex gap-3 mt-4">
                  <Button variant="outline" size="sm" icon={<Navigation size={14} />}>
                    Get Directions
                  </Button>
                  {pickup.status === 'scheduled' && (
                    <Button size="sm" variant="secondary">Mark En Route</Button>
                  )}
                  {pickup.status === 'en_route' && (
                    <Button size="sm">Mark Completed</Button>
                  )}
                </div>
              )}
            </Card>
          );
        })}
      </div>
    </Layout>
  );
}
