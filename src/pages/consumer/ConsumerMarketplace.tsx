import { useState } from 'react';
import { Layout } from '../../components/layout/Layout';
import { Card } from '../../components/ui/Card';
import { Badge } from '../../components/ui/Badge';
import { Button } from '../../components/ui/Button';
import { Search, Filter, MapPin, Clock, Tag, Heart, ShoppingCart, Star } from 'lucide-react';
import { mockListings } from '../../data/mockData';
import type { Listing } from '../../types';

const categories = ['All', 'Cooked Meals', 'Bakery', 'Dairy', 'Produce', 'Grains'];

function ListingCard({ listing, onClaim }: { listing: Listing; onClaim: (id: number) => void }) {
  const isDonation = listing.listingType === 'donation';

  return (
    <div className="bg-white rounded-xl border border-gray-100 overflow-hidden hover:shadow-md transition-shadow">
      <div className="h-40 bg-gradient-to-br from-gray-100 to-gray-200 relative overflow-hidden">
        {isDonation ? (
          <div className="absolute inset-0 bg-gradient-to-br from-green-100 to-green-200 flex items-center justify-center">
            <Heart size={40} className="text-green-400 opacity-60" />
          </div>
        ) : (
          <div className="absolute inset-0 bg-gradient-to-br from-orange-100 to-orange-200 flex items-center justify-center">
            <Tag size={40} className="text-orange-400 opacity-60" />
          </div>
        )}
        <div className="absolute top-3 left-3">
          <Badge variant={isDonation ? 'green' : 'orange'} size="md">
            {isDonation ? 'FREE' : `৳${listing.price}`}
          </Badge>
        </div>
        <div className="absolute top-3 right-3 bg-white/90 backdrop-blur rounded-lg px-2 py-1 text-xs font-medium text-gray-600">
          <MapPin size={10} className="inline mr-1" />{listing.distance} km
        </div>
      </div>
      <div className="p-4">
        <h3 className="font-semibold text-gray-900 text-sm leading-tight mb-1">{listing.title}</h3>
        <p className="text-xs text-gray-500 mb-2">{listing.donorName}</p>
        <p className="text-xs text-gray-400 line-clamp-2 mb-3">{listing.description}</p>
        <div className="flex items-center gap-3 text-xs text-gray-400 mb-4">
          <span className="flex items-center gap-1"><Star size={10} className="text-yellow-400" /> 4.8</span>
          <span>{listing.quantity} available</span>
          <span className="flex items-center gap-1">
            <Clock size={10} />
            Until {new Date(listing.pickupEnd).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
          </span>
        </div>
        <Button
          fullWidth
          variant={isDonation ? 'primary' : 'secondary'}
          size="sm"
          icon={isDonation ? <Heart size={14} /> : <ShoppingCart size={14} />}
          onClick={() => onClaim(listing.id)}
        >
          {isDonation ? 'Claim Free' : `Buy for ৳${listing.price}`}
        </Button>
      </div>
    </div>
  );
}

export function ConsumerMarketplace() {
  const [search, setSearch] = useState('');
  const [category, setCategory] = useState('All');
  const [typeFilter, setTypeFilter] = useState<'all' | 'donation' | 'flash_sale'>('all');
  const [sortBy, setSortBy] = useState<'distance' | 'price'>('distance');
  const [claimed, setClaimed] = useState<number | null>(null);

  const filtered = mockListings
    .filter(l => {
      if (search && !l.title.toLowerCase().includes(search.toLowerCase()) && !l.donorName.toLowerCase().includes(search.toLowerCase())) return false;
      if (category !== 'All' && l.category !== category) return false;
      if (typeFilter !== 'all' && l.listingType !== typeFilter) return false;
      return l.status === 'active';
    })
    .sort((a, b) => sortBy === 'distance' ? (a.distance ?? 0) - (b.distance ?? 0) : a.price - b.price);

  if (claimed) {
    const listing = mockListings.find(l => l.id === claimed);
    return (
      <Layout title="Marketplace">
        <div className="max-w-md mx-auto text-center py-20">
          <div className="w-20 h-20 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-6">
            <Heart size={40} className="text-green-600" />
          </div>
          <h2 className="text-2xl font-bold text-gray-900 mb-2">
            {listing?.listingType === 'donation' ? 'Claimed!' : 'Order Placed!'}
          </h2>
          <p className="text-gray-500">{listing?.title} has been reserved for you.</p>
          <p className="text-gray-400 text-sm mt-1">
            Pickup: {listing && new Date(listing.pickupStart).toLocaleString()}
          </p>
          <div className="mt-8 flex gap-3 justify-center">
            <Button variant="outline" onClick={() => setClaimed(null)}>Back to Marketplace</Button>
            <Button>Track Request</Button>
          </div>
        </div>
      </Layout>
    );
  }

  return (
    <Layout title="Consumer Marketplace" subtitle="Browse discounted surplus food from nearby vendors">
      <div className="flex flex-col sm:flex-row gap-3 mb-6">
        <div className="flex-1 relative">
          <Search size={16} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-400" />
          <input
            type="text" value={search} onChange={e => setSearch(e.target.value)}
            placeholder="Search food or restaurant..."
            className="w-full pl-10 pr-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-green-500 bg-white"
          />
        </div>
        <div className="flex gap-2 flex-wrap">
          <div className="flex items-center gap-2 bg-white border border-gray-200 rounded-xl px-3 py-2">
            <Filter size={14} className="text-gray-400" />
            <select value={category} onChange={e => setCategory(e.target.value)}
              className="text-sm focus:outline-none bg-transparent">
              {categories.map(c => <option key={c}>{c}</option>)}
            </select>
          </div>
          <div className="flex gap-1 bg-white border border-gray-200 rounded-xl p-1">
            {([['all', 'All'], ['donation', 'Free'], ['flash_sale', 'Sale']] as const).map(([val, label]) => (
              <button key={val} onClick={() => setTypeFilter(val)}
                className={`px-3 py-1.5 rounded-lg text-xs font-medium transition-colors ${
                  typeFilter === val ? 'bg-green-600 text-white' : 'text-gray-600 hover:bg-gray-100'
                }`}
              >
                {label}
              </button>
            ))}
          </div>
          <select value={sortBy} onChange={e => setSortBy(e.target.value as typeof sortBy)}
            className="text-sm border border-gray-200 rounded-xl px-3 py-2 focus:outline-none bg-white">
            <option value="distance">Sort: Distance</option>
            <option value="price">Sort: Price</option>
          </select>
        </div>
      </div>

      <div className="flex items-center gap-3 mb-4">
        <p className="text-sm text-gray-500">{filtered.length} items found</p>
        {typeFilter === 'donation' && <Badge variant="green">Showing free donations only</Badge>}
        {typeFilter === 'flash_sale' && <Badge variant="orange">Showing flash sales only</Badge>}
      </div>

      {filtered.length === 0 ? (
        <Card>
          <div className="text-center py-12 text-gray-400">
            <Search size={40} className="mx-auto mb-3 opacity-40" />
            <p className="font-medium">No listings match your search</p>
            <p className="text-sm mt-1">Try adjusting filters or search terms</p>
          </div>
        </Card>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-5">
          {filtered.map(listing => (
            <ListingCard key={listing.id} listing={listing} onClaim={setClaimed} />
          ))}
        </div>
      )}
    </Layout>
  );
}
