import { Layout } from '../../components/layout/Layout';
import { Card } from '../../components/ui/Card';
import { Badge } from '../../components/ui/Badge';
import { ClipboardList, Clock, CheckCircle, XCircle, Package } from 'lucide-react';
import { mockRequests } from '../../data/mockData';

const statusConfig = {
  pending: { icon: <Clock size={16} />, label: 'Pending', variant: 'yellow' as const, color: 'bg-yellow-50 border-yellow-200' },
  accepted: { icon: <CheckCircle size={16} />, label: 'Accepted', variant: 'green' as const, color: 'bg-green-50 border-green-200' },
  rejected: { icon: <XCircle size={16} />, label: 'Rejected', variant: 'red' as const, color: 'bg-red-50 border-red-200' },
  completed: { icon: <CheckCircle size={16} />, label: 'Completed', variant: 'blue' as const, color: 'bg-blue-50 border-blue-200' },
};

export function RequestStatusTracker() {
  const counts = {
    pending: mockRequests.filter(r => r.status === 'pending').length,
    accepted: mockRequests.filter(r => r.status === 'accepted').length,
    rejected: mockRequests.filter(r => r.status === 'rejected').length,
    completed: mockRequests.filter(r => r.status === 'completed').length,
  };

  return (
    <Layout title="Request Status" subtitle="Track the real-time approval status of your food requests">
      <div className="grid grid-cols-4 gap-4 mb-8">
        {(Object.entries(counts) as [keyof typeof counts, number][]).map(([status, count]) => {
          const cfg = statusConfig[status];
          return (
            <div key={status} className={`rounded-xl p-4 border ${cfg.color}`}>
              <p className="text-2xl font-bold text-gray-900">{count}</p>
              <p className="text-sm text-gray-600 mt-1 flex items-center gap-1.5">{cfg.icon}{cfg.label}</p>
            </div>
          );
        })}
      </div>

      <Card padding={false}>
        <div className="px-5 py-4 border-b border-gray-100 flex items-center gap-2">
          <ClipboardList size={18} className="text-gray-500" />
          <h2 className="font-semibold text-gray-900">All Requests ({mockRequests.length})</h2>
        </div>
        <div className="divide-y divide-gray-50">
          {mockRequests.map(req => {
            const cfg = statusConfig[req.status];
            return (
              <div key={req.id} className="px-5 py-4 flex items-center justify-between hover:bg-gray-50 transition-colors">
                <div className="flex items-center gap-4">
                  <div className={`w-10 h-10 rounded-xl flex items-center justify-center ${cfg.color}`}>
                    <Package size={18} className={
                      req.status === 'accepted' || req.status === 'completed' ? 'text-green-600' :
                      req.status === 'rejected' ? 'text-red-600' : 'text-yellow-600'
                    } />
                  </div>
                  <div>
                    <p className="font-medium text-gray-900 text-sm">{req.listingTitle}</p>
                    <p className="text-xs text-gray-400">From: <span className="text-gray-600">{req.donorName}</span></p>
                    <p className="text-xs text-gray-400">{new Date(req.createdAt).toLocaleString()}</p>
                  </div>
                </div>
                <div className="flex items-center gap-4 text-right">
                  <div>
                    <p className="text-sm font-semibold text-gray-900">{req.quantity} units</p>
                    <p className="text-xs text-gray-400">requested</p>
                  </div>
                  <Badge variant={cfg.variant}>{cfg.label}</Badge>
                </div>
              </div>
            );
          })}
        </div>
      </Card>

      <div className="mt-6 grid grid-cols-1 md:grid-cols-2 gap-4">
        <Card className="bg-green-50 border-green-200">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-green-100 rounded-xl flex items-center justify-center">
              <CheckCircle size={20} className="text-green-600" />
            </div>
            <div>
              <p className="font-medium text-gray-900 text-sm">Acceptance Rate</p>
              <p className="text-2xl font-bold text-green-700 mt-0.5">
                {Math.round((counts.accepted / mockRequests.length) * 100)}%
              </p>
            </div>
          </div>
        </Card>
        <Card className="bg-blue-50 border-blue-200">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-blue-100 rounded-xl flex items-center justify-center">
              <Package size={20} className="text-blue-600" />
            </div>
            <div>
              <p className="font-medium text-gray-900 text-sm">Total Items Requested</p>
              <p className="text-2xl font-bold text-blue-700 mt-0.5">
                {mockRequests.reduce((s, r) => s + r.quantity, 0)} units
              </p>
            </div>
          </div>
        </Card>
      </div>
    </Layout>
  );
}
