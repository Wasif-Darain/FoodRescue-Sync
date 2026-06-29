import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Layout } from '../../components/layout/Layout';
import { Card } from '../../components/ui/Card';
import { Button } from '../../components/ui/Button';
import { Tag, Heart, MapPin, Clock, CheckCircle } from 'lucide-react';

const categories = ['Cooked Meals', 'Grains', 'Bakery', 'Dairy', 'Produce', 'Pulses', 'Beverages', 'Other'];

export function CreateListing() {
  const navigate = useNavigate();
  const [submitted, setSubmitted] = useState(false);
  const [listingType, setListingType] = useState<'donation' | 'flash_sale'>('donation');
  const [form, setForm] = useState({
    title: '', description: '', category: 'Cooked Meals',
    quantity: '', price: '', pickupStart: '', pickupEnd: '',
    address: '', latitude: '', longitude: '',
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitted(true);
    setTimeout(() => navigate('/donor'), 2000);
  };

  if (submitted) {
    return (
      <Layout title="Create Listing">
        <div className="max-w-md mx-auto text-center py-20">
          <div className="w-20 h-20 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-6">
            <CheckCircle size={40} className="text-green-600" />
          </div>
          <h2 className="text-2xl font-bold text-gray-900 mb-2">Listing Created!</h2>
          <p className="text-gray-500">Your food listing is now live and visible to nearby organizations and consumers.</p>
          <p className="text-sm text-gray-400 mt-4">Redirecting to dashboard...</p>
        </div>
      </Layout>
    );
  }

  return (
    <Layout title="Create Listing" subtitle="List surplus food as a donation or flash sale">
      <div className="max-w-2xl mx-auto">
        <div className="grid grid-cols-2 gap-4 mb-6">
          {[
            { type: 'donation' as const, icon: <Heart size={20} />, label: 'Donation', desc: 'Give food away for free to those in need', color: 'green' },
            { type: 'flash_sale' as const, icon: <Tag size={20} />, label: 'Flash Sale', desc: 'Sell at a discount to recover some cost', color: 'orange' },
          ].map(opt => (
            <button
              key={opt.type}
              onClick={() => setListingType(opt.type)}
              className={`p-4 rounded-xl border-2 text-left transition-all ${
                listingType === opt.type
                  ? opt.color === 'green'
                    ? 'border-green-500 bg-green-50'
                    : 'border-orange-500 bg-orange-50'
                  : 'border-gray-100 bg-white hover:border-gray-200'
              }`}
            >
              <div className={`w-10 h-10 rounded-lg flex items-center justify-center mb-3 ${
                listingType === opt.type
                  ? opt.color === 'green' ? 'bg-green-100 text-green-700' : 'bg-orange-100 text-orange-700'
                  : 'bg-gray-100 text-gray-500'
              }`}>
                {opt.icon}
              </div>
              <p className={`font-semibold text-sm ${listingType === opt.type ? 'text-gray-900' : 'text-gray-600'}`}>{opt.label}</p>
              <p className="text-xs text-gray-400 mt-0.5">{opt.desc}</p>
            </button>
          ))}
        </div>

        <Card>
          <form onSubmit={handleSubmit} className="space-y-5">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1.5">Listing Title *</label>
              <input required value={form.title} onChange={e => setForm({ ...form, title: e.target.value })}
                placeholder="e.g. Chicken Biryani (30 servings)"
                className="w-full px-3.5 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1.5">Description</label>
              <textarea value={form.description} onChange={e => setForm({ ...form, description: e.target.value })}
                rows={3} placeholder="Describe the food, condition, allergens, etc."
                className="w-full px-3.5 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500 resize-none"
              />
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1.5">Category *</label>
                <select required value={form.category} onChange={e => setForm({ ...form, category: e.target.value })}
                  className="w-full px-3.5 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500 bg-white"
                >
                  {categories.map(c => <option key={c}>{c}</option>)}
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1.5">Quantity Available *</label>
                <input required type="number" min="1" value={form.quantity}
                  onChange={e => setForm({ ...form, quantity: e.target.value })}
                  placeholder="e.g. 30"
                  className="w-full px-3.5 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500"
                />
              </div>
            </div>

            {listingType === 'flash_sale' && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1.5">
                  <Tag size={14} className="inline mr-1" />
                  Discounted Price (BDT) *
                </label>
                <input required={listingType === 'flash_sale'} type="number" min="0"
                  value={form.price} onChange={e => setForm({ ...form, price: e.target.value })}
                  placeholder="e.g. 80"
                  className="w-full px-3.5 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500"
                />
              </div>
            )}

            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1.5">
                  <Clock size={14} className="inline mr-1" />
                  Pickup Start *
                </label>
                <input required type="datetime-local" value={form.pickupStart}
                  onChange={e => setForm({ ...form, pickupStart: e.target.value })}
                  className="w-full px-3.5 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1.5">
                  <Clock size={14} className="inline mr-1" />
                  Pickup End *
                </label>
                <input required type="datetime-local" value={form.pickupEnd}
                  onChange={e => setForm({ ...form, pickupEnd: e.target.value })}
                  className="w-full px-3.5 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500"
                />
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1.5">
                <MapPin size={14} className="inline mr-1" />
                Pickup Address *
              </label>
              <input required value={form.address} onChange={e => setForm({ ...form, address: e.target.value })}
                placeholder="Full pickup address"
                className="w-full px-3.5 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500"
              />
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1.5">Latitude</label>
                <input type="number" step="any" value={form.latitude}
                  onChange={e => setForm({ ...form, latitude: e.target.value })}
                  placeholder="e.g. 23.8103"
                  className="w-full px-3.5 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1.5">Longitude</label>
                <input type="number" step="any" value={form.longitude}
                  onChange={e => setForm({ ...form, longitude: e.target.value })}
                  placeholder="e.g. 90.4125"
                  className="w-full px-3.5 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500"
                />
              </div>
            </div>

            <div className="flex gap-3 pt-2">
              <Button type="button" variant="outline" onClick={() => navigate('/donor')}>Cancel</Button>
              <Button type="submit" variant={listingType === 'donation' ? 'primary' : 'secondary'} icon={listingType === 'donation' ? <Heart size={16} /> : <Tag size={16} />}>
                {listingType === 'donation' ? 'Post as Donation' : 'Post Flash Sale'}
              </Button>
            </div>
          </form>
        </Card>
      </div>
    </Layout>
  );
}
