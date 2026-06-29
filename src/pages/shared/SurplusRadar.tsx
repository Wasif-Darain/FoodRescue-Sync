import { useState } from 'react';
import { Layout } from '../../components/layout/Layout';
import { Badge } from '../../components/ui/Badge';
import { Button } from '../../components/ui/Button';
import { Map, Filter, MapPin, Clock, Package, Tag, Heart } from 'lucide-react';
import { mockListings } from '../../data/mockData';

const categories = ['All', 'Cooked Meals', 'Bakery', 'Dairy', 'Produce', 'Grains'];
const types = ['All', 'Donation', 'Flash Sale'];

export function SurplusRadar() {
  const [selectedCategory, setSelectedCategory] = useState('All');
  const [selectedType, setSelectedType] = useState('All');
  const [radius, setRadius] = useState(5);
  const [selected, setSelected] = useState<number | null>(null);

  const filtered = mockListings.filter(l => {
    if (selectedCategory !== 'All' && l.category !== selectedCategory) return false;
    if (selectedType === 'Donation' && l.listingType !== 'donation') return false;
    if (selectedType === 'Flash Sale' && l.listingType !== 'flash_sale') return false;
    if ((l.distance ?? 0) > radius) return false;
    return true;
  });

  const dotPositions: Record<number, { top: string; left: string }> = {
    1: { top: '42%', left: '48%' },
    2: { top: '30%', left: '60%' },
    3: { top: '55%', left: '38%' },
    4: { top: '65%', left: '55%' },
    5: { top: '20%', left: '44%' },
  };

  return (
    <Layout title="Surplus Radar" subtitle="Real-time map of active surplus food listings near you">
      <div className="flex gap-3 mb-5 flex-wrap">
        <div className="flex items-center gap-2 bg-white border border-gray-200 rounded-xl px-3 py-2">
          <Filter size={16} className="text-gray-400" />
          <select value={selectedCategory} onChange={e => setSelectedCategory(e.target.value)}
            className="text-sm focus:outline-none bg-transparent">
            {categories.map(c => <option key={c}>{c}</option>)}
          </select>
        </div>
        <div className="flex items-center gap-2 bg-white border border-gray-200 rounded-xl px-3 py-2">
          <select value={selectedType} onChange={e => setSelectedType(e.target.value)}
            className="text-sm focus:outline-none bg-transparent">
            {types.map(t => <option key={t}>{t}</option>)}
          </select>
        </div>
        <div className="flex items-center gap-2 bg-white border border-gray-200 rounded-xl px-3 py-2">
          <MapPin size={16} className="text-gray-400" />
          <select value={radius} onChange={e => setRadius(Number(e.target.value))}
            className="text-sm focus:outline-none bg-transparent">
            {[1, 2, 5, 10, 20].map(r => <option key={r} value={r}>{r} km</option>)}
          </select>
        </div>
        <Badge variant="green" size="md">{filtered.length} listings found</Badge>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-5 gap-6">
        <div className="lg:col-span-3">
          <div className="bg-gradient-to-br from-green-100 to-blue-100 rounded-2xl h-96 relative overflow-hidden border border-gray-200">
            <div className="absolute inset-0 flex items-center justify-center">
              <Map size={64} className="text-gray-300 opacity-40" />
            </div>
            <div className="absolute top-4 left-4 bg-white/90 backdrop-blur rounded-lg px-3 py-2 text-xs font-medium text-gray-600 shadow-sm flex items-center gap-1.5">
              <MapPin size={12} className="text-green-600" /> Dhaka, Bangladesh
            </div>

            {filtered.map(listing => {
              const pos = dotPositions[listing.id] || { top: '50%', left: '50%' };
              return (
                <button
                  key={listing.id}
                  onClick={() => setSelected(listing.id === selected ? null : listing.id)}
                  style={{ top: pos.top, left: pos.left }}
                  className={`absolute transform -translate-x-1/2 -translate-y-1/2 transition-transform hover:scale-110`}
                >
                  <div className={`w-10 h-10 rounded-full flex items-center justify-center shadow-lg border-2 border-white ${
                    listing.listingType === 'donation' ? 'bg-green-500' : 'bg-orange-500'
                  } ${listing.id === selected ? 'ring-4 ring-green-300 scale-125' : ''}`}>
                    {listing.listingType === 'donation'
                      ? <Heart size={18} className="text-white" />
                      : <Tag size={18} className="text-white" />
                    }
                  </div>
                  {listing.id === selected && (
                    <div className="absolute bottom-full left-1/2 -translate-x-1/2 mb-2 bg-white rounded-lg shadow-lg p-2 min-w-36 text-left">
                      <p className="text-xs font-bold text-gray-900 leading-tight">{listing.title}</p>
                      <p className="text-xs text-gray-400">{listing.distance} km · {listing.quantity} units</p>
                    </div>
                  )}
                </button>
              );
            })}

            <div className="absolute bottom-4 right-4 flex flex-col gap-2">
              <div className="flex items-center gap-2 bg-white/90 backdrop-blur rounded-lg px-2.5 py-1.5 text-xs">
                <span className="w-3 h-3 rounded-full bg-green-500 inline-block"></span> Donation
              </div>
              <div className="flex items-center gap-2 bg-white/90 backdrop-blur rounded-lg px-2.5 py-1.5 text-xs">
                <span className="w-3 h-3 rounded-full bg-orange-500 inline-block"></span> Flash Sale
              </div>
            </div>

            <p className="absolute bottom-4 left-4 text-xs text-gray-500 bg-white/80 backdrop-blur px-2 py-1 rounded">
              Interactive map preview — real GPS integration in production
            </p>
          </div>
        </div>

        <div className="lg:col-span-2 space-y-3 max-h-96 overflow-y-auto pr-1">
          {filtered.map(listing => (
            <div
              key={listing.id}
              onClick={() => setSelected(listing.id === selected ? null : listing.id)}
              className={`p-4 rounded-xl border cursor-pointer transition-all ${
                listing.id === selected ? 'border-green-400 bg-green-50' : 'border-gray-100 bg-white hover:border-green-200'
              }`}
            >
              <div className="flex items-start justify-between mb-2">
                <p className="font-medium text-gray-900 text-sm leading-tight">{listing.title}</p>
                <Badge variant={listing.listingType === 'donation' ? 'green' : 'orange'} size="sm">
                  {listing.listingType === 'donation' ? 'Free' : `৳${listing.price}`}
                </Badge>
              </div>
              <p className="text-xs text-gray-500 mb-2">{listing.donorName}</p>
              <div className="flex items-center gap-3 text-xs text-gray-400 flex-wrap">
                <span><MapPin size={10} className="inline mr-1" />{listing.distance} km</span>
                <span><Package size={10} className="inline mr-1" />{listing.quantity} units</span>
                <span><Clock size={10} className="inline mr-1" />
                  Until {new Date(listing.pickupEnd).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                </span>
              </div>
              {listing.id === selected && (
                <div className="mt-3 pt-3 border-t border-gray-100">
                  <p className="text-xs text-gray-600 mb-3">{listing.description}</p>
                  <Button size="sm" fullWidth>
                    {listing.listingType === 'donation' ? 'Claim This Donation' : 'Purchase Now'}
                  </Button>
                </div>
              )}
            </div>
          ))}
          {filtered.length === 0 && (
            <div className="text-center py-12 text-gray-400">
              <MapPin size={36} className="mx-auto mb-2 opacity-40" />
              <p className="text-sm">No listings found for these filters</p>
            </div>
          )}
        </div>
      </div>
    </Layout>
  );
}
