import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { Layout } from '../../components/layout/Layout';
import { Card } from '../../components/ui/Card';
import { Badge } from '../../components/ui/Badge';
import { Button } from '../../components/ui/Button';
import { Clock, AlertTriangle, CheckCircle, Plus } from 'lucide-react';
import { mockInventory } from '../../data/mockData';

function CountdownTimer({ expiryDate }: { expiryDate: string }) {
  const [timeLeft, setTimeLeft] = useState('');

  useEffect(() => {
    const update = () => {
      const diff = new Date(expiryDate).getTime() - Date.now();
      if (diff <= 0) { setTimeLeft('Expired'); return; }
      const h = Math.floor(diff / 3600000);
      const m = Math.floor((diff % 3600000) / 60000);
      if (h > 24) {
        const d = Math.floor(h / 24);
        setTimeLeft(`${d}d ${h % 24}h`);
      } else {
        setTimeLeft(`${h}h ${m}m`);
      }
    };
    update();
    const t = setInterval(update, 60000);
    return () => clearInterval(t);
  }, [expiryDate]);

  return <span>{timeLeft}</span>;
}

export function ExpiryTracker() {
  const sorted = [...mockInventory].sort(
    (a, b) => new Date(a.expiryDate).getTime() - new Date(b.expiryDate).getTime()
  );

  const daysUntil = (date: string) => Math.ceil((new Date(date).getTime() - Date.now()) / 86400000);

  const getStatus = (date: string) => {
    const d = daysUntil(date);
    if (d <= 0) return { label: 'Expired', variant: 'red' as const, color: 'border-red-200 bg-red-50' };
    if (d === 1) return { label: 'Today', variant: 'red' as const, color: 'border-red-200 bg-red-50' };
    if (d <= 3) return { label: 'Soon', variant: 'orange' as const, color: 'border-orange-200 bg-orange-50' };
    return { label: 'OK', variant: 'green' as const, color: 'border-gray-100 bg-white' };
  };

  const expiredCount = sorted.filter(i => daysUntil(i.expiryDate) <= 0).length;
  const todayCount = sorted.filter(i => daysUntil(i.expiryDate) === 1).length;
  const soonCount = sorted.filter(i => { const d = daysUntil(i.expiryDate); return d > 1 && d <= 3; }).length;

  return (
    <Layout
      title="Expiry Tracker"
      subtitle="Monitor items approaching their expiry date"
      actions={
        <Link to="/donor/create-listing">
          <Button icon={<Plus size={16} />}>Create Listing</Button>
        </Link>
      }
    >
      <div className="grid grid-cols-3 gap-4 mb-8">
        <div className="bg-red-50 border border-red-200 rounded-xl p-4 text-center">
          <p className="text-3xl font-bold text-red-600">{expiredCount}</p>
          <p className="text-sm text-red-700 font-medium mt-1">Expired</p>
        </div>
        <div className="bg-orange-50 border border-orange-200 rounded-xl p-4 text-center">
          <p className="text-3xl font-bold text-orange-600">{todayCount}</p>
          <p className="text-sm text-orange-700 font-medium mt-1">Expires Today</p>
        </div>
        <div className="bg-yellow-50 border border-yellow-200 rounded-xl p-4 text-center">
          <p className="text-3xl font-bold text-yellow-700">{soonCount}</p>
          <p className="text-sm text-yellow-700 font-medium mt-1">Expires in 3 days</p>
        </div>
      </div>

      <Card padding={false}>
        <div className="px-5 py-4 border-b border-gray-100 flex items-center gap-2">
          <Clock size={18} className="text-gray-500" />
          <h2 className="font-semibold text-gray-900">Items sorted by expiry (soonest first)</h2>
        </div>
        <div className="divide-y divide-gray-50">
          {sorted.map(item => {
            const status = getStatus(item.expiryDate);
            const days = daysUntil(item.expiryDate);
            const urgent = days <= 3;
            return (
              <div key={item.id} className={`px-5 py-4 flex items-center justify-between border-l-4 ${urgent ? (days <= 0 ? 'border-red-400' : days <= 1 ? 'border-orange-400' : 'border-yellow-400') : 'border-transparent'}`}>
                <div className="flex items-center gap-4">
                  <div className={`w-10 h-10 rounded-xl flex items-center justify-center ${urgent ? 'bg-orange-100' : 'bg-green-100'}`}>
                    {urgent
                      ? <AlertTriangle size={18} className={days <= 1 ? 'text-red-600' : 'text-orange-600'} />
                      : <CheckCircle size={18} className="text-green-600" />
                    }
                  </div>
                  <div>
                    <p className="font-medium text-gray-900 text-sm">{item.name}</p>
                    <p className="text-xs text-gray-400">{item.category} · Qty: {item.quantity}</p>
                  </div>
                </div>
                <div className="flex items-center gap-4">
                  <div className="text-right">
                    <p className={`text-sm font-bold ${days <= 1 ? 'text-red-600' : days <= 3 ? 'text-orange-600' : 'text-gray-700'}`}>
                      <CountdownTimer expiryDate={item.expiryDate} />
                    </p>
                    <p className="text-xs text-gray-400">{item.expiryDate}</p>
                  </div>
                  <Badge variant={status.variant}>{status.label}</Badge>
                  {urgent && (
                    <Link to="/donor/create-listing">
                      <Button size="sm" variant={days <= 1 ? 'danger' : 'secondary'}>List Now</Button>
                    </Link>
                  )}
                </div>
              </div>
            );
          })}
        </div>
      </Card>
    </Layout>
  );
}
