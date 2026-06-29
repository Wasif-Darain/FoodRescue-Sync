import { useState } from 'react';
import { Layout } from '../../components/layout/Layout';
import { Card } from '../../components/ui/Card';
import { Button } from '../../components/ui/Button';
import { Badge } from '../../components/ui/Badge';
import { ScanLine, Plus, Package, Trash2, AlertTriangle } from 'lucide-react';
import { mockInventory } from '../../data/mockData';
import type { InventoryItem } from '../../types';

const categories = ['Cooked Meals', 'Grains', 'Bakery', 'Dairy', 'Produce', 'Pulses', 'Beverages', 'Other'];

export function AddInventory() {
  const [items, setItems] = useState<InventoryItem[]>(mockInventory);
  const [showForm, setShowForm] = useState(false);
  const [scanMode, setScanMode] = useState(false);
  const [form, setForm] = useState({ name: '', barcode: '', quantity: '', expiryDate: '', category: 'Cooked Meals' });

  const daysUntilExpiry = (date: string) => {
    return Math.ceil((new Date(date).getTime() - Date.now()) / 86400000);
  };

  const handleAdd = (e: React.FormEvent) => {
    e.preventDefault();
    const newItem: InventoryItem = {
      id: items.length + 1,
      name: form.name,
      barcode: form.barcode,
      quantity: Number(form.quantity),
      expiryDate: form.expiryDate,
      isSurplus: daysUntilExpiry(form.expiryDate) <= 3,
      category: form.category,
    };
    setItems([newItem, ...items]);
    setForm({ name: '', barcode: '', quantity: '', expiryDate: '', category: 'Cooked Meals' });
    setShowForm(false);
  };

  const handleDelete = (id: number) => setItems(items.filter(i => i.id !== id));

  return (
    <Layout
      title="Inventory Management"
      subtitle="Track and manage your food inventory"
      actions={
        <div className="flex gap-2">
          <Button variant="outline" icon={<ScanLine size={16} />} onClick={() => setScanMode(!scanMode)}>
            Scan Barcode
          </Button>
          <Button icon={<Plus size={16} />} onClick={() => setShowForm(!showForm)}>
            Add Item
          </Button>
        </div>
      }
    >
      {scanMode && (
        <Card className="mb-6 border-2 border-dashed border-green-300 bg-green-50">
          <div className="text-center py-8">
            <ScanLine size={48} className="mx-auto text-green-400 mb-3" />
            <p className="font-semibold text-gray-700">Barcode Scanner Active</p>
            <p className="text-sm text-gray-500 mt-1">Point your camera at a product barcode</p>
            <p className="text-xs text-gray-400 mt-3">(Camera integration would activate here in production)</p>
            <Button variant="outline" size="sm" className="mt-4" onClick={() => setScanMode(false)}>Cancel Scan</Button>
          </div>
        </Card>
      )}

      {showForm && (
        <Card className="mb-6 border-2 border-green-100">
          <h3 className="font-semibold text-gray-900 mb-4 flex items-center gap-2">
            <Plus size={18} className="text-green-600" /> Add New Item
          </h3>
          <form onSubmit={handleAdd} className="grid grid-cols-2 gap-4">
            <div className="col-span-2 md:col-span-1">
              <label className="block text-sm font-medium text-gray-700 mb-1.5">Item Name *</label>
              <input required value={form.name} onChange={e => setForm({ ...form, name: e.target.value })}
                placeholder="e.g. Chicken Biryani"
                className="w-full px-3.5 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1.5">Barcode</label>
              <input value={form.barcode} onChange={e => setForm({ ...form, barcode: e.target.value })}
                placeholder="Scan or enter barcode"
                className="w-full px-3.5 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1.5">Category *</label>
              <select required value={form.category} onChange={e => setForm({ ...form, category: e.target.value })}
                className="w-full px-3.5 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500 bg-white"
              >
                {categories.map(c => <option key={c}>{c}</option>)}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1.5">Quantity *</label>
              <input required type="number" min="1" value={form.quantity} onChange={e => setForm({ ...form, quantity: e.target.value })}
                placeholder="0"
                className="w-full px-3.5 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1.5">Expiry Date *</label>
              <input required type="date" value={form.expiryDate} onChange={e => setForm({ ...form, expiryDate: e.target.value })}
                className="w-full px-3.5 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500"
              />
            </div>
            <div className="col-span-2 flex gap-3 justify-end">
              <Button variant="outline" type="button" onClick={() => setShowForm(false)}>Cancel</Button>
              <Button type="submit">Add to Inventory</Button>
            </div>
          </form>
        </Card>
      )}

      <Card padding={false}>
        <div className="px-5 py-4 border-b border-gray-100 flex items-center justify-between">
          <h2 className="font-semibold text-gray-900 flex items-center gap-2">
            <Package size={18} className="text-gray-500" /> All Items ({items.length})
          </h2>
          <div className="flex gap-2">
            <Badge variant="orange">{items.filter(i => i.isSurplus).length} Surplus</Badge>
            <Badge variant="gray">{items.filter(i => !i.isSurplus).length} Normal</Badge>
          </div>
        </div>
        <div className="divide-y divide-gray-50">
          {items.map(item => {
            const days = daysUntilExpiry(item.expiryDate);
            return (
              <div key={item.id} className="px-5 py-4 flex items-center justify-between hover:bg-gray-50 transition-colors">
                <div className="flex items-center gap-4 flex-1 min-w-0">
                  <div className={`w-10 h-10 rounded-xl flex items-center justify-center shrink-0 ${item.isSurplus ? 'bg-orange-100' : 'bg-green-100'}`}>
                    <Package size={18} className={item.isSurplus ? 'text-orange-600' : 'text-green-600'} />
                  </div>
                  <div className="min-w-0">
                    <div className="flex items-center gap-2 flex-wrap">
                      <p className="font-medium text-gray-900 text-sm">{item.name}</p>
                      {item.isSurplus && <Badge variant="orange"><AlertTriangle size={10} className="mr-1" />Surplus</Badge>}
                    </div>
                    <p className="text-xs text-gray-400 mt-0.5">{item.category} · Barcode: {item.barcode || 'N/A'}</p>
                  </div>
                </div>
                <div className="flex items-center gap-6 text-sm">
                  <div className="text-center">
                    <p className="font-semibold text-gray-900">{item.quantity}</p>
                    <p className="text-xs text-gray-400">units</p>
                  </div>
                  <div className="text-center">
                    <p className={`font-semibold ${days <= 1 ? 'text-red-600' : days <= 3 ? 'text-orange-600' : 'text-gray-900'}`}>
                      {days <= 0 ? 'Expired' : `${days}d`}
                    </p>
                    <p className="text-xs text-gray-400">expires</p>
                  </div>
                  <button onClick={() => handleDelete(item.id)} className="text-red-400 hover:text-red-600 transition-colors p-1">
                    <Trash2 size={16} />
                  </button>
                </div>
              </div>
            );
          })}
        </div>
      </Card>
    </Layout>
  );
}
