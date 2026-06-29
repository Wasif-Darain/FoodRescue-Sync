import { useState } from 'react';
import { Layout } from '../../components/layout/Layout';
import { Card } from '../../components/ui/Card';
import { Badge } from '../../components/ui/Badge';
import { Button } from '../../components/ui/Button';
import { Package, MapPin, Clock, CheckCircle, ShoppingCart } from 'lucide-react';
import { mockListings } from '../../data/mockData';

export function BulkRequest() {
  const donations = mockListings.filter(l => l.listingType === 'donation' && l.status === 'active');
  const [selected, setSelected] = useState<Set<number>>(new Set());
  const [submitted, setSubmitted] = useState(false);
  const [quantities, setQuantities] = useState<Record<number, number>>({});

  const toggle = (id: number) => {
    setSelected(prev => {
      const next = new Set(prev);
      if (next.has(id)) { next.delete(id); }
      else {
        next.add(id);
        const listing = donations.find(d => d.id === id);
        if (listing) setQuantities(q => ({ ...q, [id]: listing.quantity }));
      }
      return next;
    });
  };

  const totalItems = Array.from(selected).reduce((s, id) => s + (quantities[id] || 0), 0);

  const handleSubmit = () => {
    if (selected.size === 0) return;
    setSubmitted(true);
  };

  if (submitted) {
    return (
      <Layout title="Bulk Request">
        <div className="max-w-md mx-auto text-center py-20">
          <div className="w-20 h-20 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-6">
            <CheckCircle size={40} className="text-green-600" />
          </div>
          <h2 className="text-2xl font-bold text-gray-900 mb-2">Request Submitted!</h2>
          <p className="text-gray-500">Your bulk request for {selected.size} listings ({totalItems} total items) has been sent to the donors.</p>
          <p className="text-gray-400 text-sm mt-2">You'll receive notifications as donors approve your requests.</p>
          <div className="mt-8">
            <Button onClick={() => { setSubmitted(false); setSelected(new Set()); }}>Submit Another Request</Button>
          </div>
        </div>
      </Layout>
    );
  }

  return (
    <Layout
      title="Bulk Request"
      subtitle="Select multiple food donation listings to request in one step"
      actions={
        <div className="flex items-center gap-3">
          {selected.size > 0 && (
            <Badge variant="green" size="md">{selected.size} selected · {totalItems} items</Badge>
          )}
          <Button icon={<ShoppingCart size={16} />} onClick={handleSubmit} disabled={selected.size === 0}>
            Submit Request ({selected.size})
          </Button>
        </div>
      }
    >
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2 space-y-4">
          {donations.map(listing => {
            const isSelected = selected.has(listing.id);
            return (
              <div
                key={listing.id}
                className={`bg-white rounded-xl border-2 transition-all cursor-pointer ${
                  isSelected ? 'border-green-500 shadow-md' : 'border-gray-100 hover:border-green-200'
                }`}
                onClick={() => toggle(listing.id)}
              >
                <div className="p-5">
                  <div className="flex items-start justify-between mb-3">
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2 mb-1">
                        <div className={`w-5 h-5 rounded border-2 flex items-center justify-center shrink-0 ${
                          isSelected ? 'border-green-500 bg-green-500' : 'border-gray-300'
                        }`}>
                          {isSelected && <CheckCircle size={14} className="text-white" />}
                        </div>
                        <p className="font-semibold text-gray-900">{listing.title}</p>
                      </div>
                      <p className="text-sm text-gray-500 ml-7">{listing.donorName}</p>
                    </div>
                    <Badge variant="green">Donation</Badge>
                  </div>
                  <p className="text-sm text-gray-600 mb-3 ml-7">{listing.description}</p>
                  <div className="flex items-center gap-4 text-xs text-gray-400 ml-7 flex-wrap">
                    <span><Package size={12} className="inline mr-1" />Available: {listing.quantity} units</span>
                    <span><MapPin size={12} className="inline mr-1" />{listing.distance} km away</span>
                    <span><Clock size={12} className="inline mr-1" />
                      Pickup: {new Date(listing.pickupStart).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })} – {new Date(listing.pickupEnd).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                    </span>
                  </div>
                  {isSelected && (
                    <div className="mt-4 ml-7 pt-4 border-t border-gray-100" onClick={e => e.stopPropagation()}>
                      <label className="block text-sm font-medium text-gray-700 mb-2">Quantity to Request</label>
                      <div className="flex items-center gap-3">
                        <input
                          type="number" min="1" max={listing.quantity}
                          value={quantities[listing.id] || listing.quantity}
                          onChange={e => setQuantities(q => ({ ...q, [listing.id]: Number(e.target.value) }))}
                          className="w-28 px-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500"
                        />
                        <span className="text-sm text-gray-400">of {listing.quantity} available</span>
                      </div>
                    </div>
                  )}
                </div>
              </div>
            );
          })}
        </div>

        <div>
          <Card className={`sticky top-6 ${selected.size === 0 ? '' : 'border-green-200 bg-green-50'}`}>
            <h3 className="font-semibold text-gray-900 mb-4 flex items-center gap-2">
              <ShoppingCart size={18} className="text-gray-500" /> Request Summary
            </h3>
            {selected.size === 0 ? (
              <div className="text-center py-6 text-gray-400">
                <Package size={32} className="mx-auto mb-2 opacity-40" />
                <p className="text-sm">Select listings to request</p>
              </div>
            ) : (
              <>
                <div className="space-y-3 mb-4">
                  {Array.from(selected).map(id => {
                    const listing = donations.find(d => d.id === id);
                    if (!listing) return null;
                    return (
                      <div key={id} className="flex items-center justify-between text-sm">
                        <p className="text-gray-700 flex-1 min-w-0 truncate">{listing.title}</p>
                        <span className="text-green-700 font-medium ml-2">{quantities[id] || listing.quantity} units</span>
                      </div>
                    );
                  })}
                </div>
                <div className="border-t border-green-200 pt-3 mb-4">
                  <div className="flex justify-between text-sm font-semibold">
                    <span>Total Items</span>
                    <span className="text-green-700">{totalItems} units</span>
                  </div>
                  <div className="flex justify-between text-sm font-semibold mt-1">
                    <span>Total Cost</span>
                    <span className="text-green-700">FREE</span>
                  </div>
                </div>
                <Button fullWidth onClick={handleSubmit}>
                  Submit Bulk Request
                </Button>
              </>
            )}
          </Card>
        </div>
      </div>
    </Layout>
  );
}
