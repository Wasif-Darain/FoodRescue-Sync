import { Layout } from '../../components/layout/Layout';
import { Card, StatCard } from '../../components/ui/Card';
import { Badge } from '../../components/ui/Badge';
import { FileText, Download, Heart, Package, Building2 } from 'lucide-react';
import { mockDonationLogs } from '../../data/mockData';

export function DonationLog() {
  const total = mockDonationLogs.reduce((s, l) => s + l.quantity, 0);

  return (
    <Layout title="Donation Log" subtitle="Complete history of your food donations with receipts">
      <div className="grid grid-cols-3 gap-4 mb-8">
        <StatCard label="Total Donations" value={mockDonationLogs.length} icon={<Heart size={20} />} color="red" />
        <StatCard label="Items Donated" value={total} icon={<Package size={20} />} color="green" subtitle="Units redistributed" />
        <StatCard label="Orgs Helped" value={3} icon={<Building2 size={20} />} color="blue" subtitle="Partner organizations" />
      </div>

      <Card padding={false}>
        <div className="px-5 py-4 border-b border-gray-100 flex items-center justify-between">
          <h2 className="font-semibold text-gray-900 flex items-center gap-2">
            <FileText size={18} className="text-gray-500" /> Donation Records
          </h2>
          <Badge variant="green">{mockDonationLogs.length} Total</Badge>
        </div>
        <div className="divide-y divide-gray-50">
          {mockDonationLogs.map(log => (
            <div key={log.id} className="px-5 py-4 flex items-center justify-between hover:bg-gray-50 transition-colors">
              <div className="flex items-center gap-4">
                <div className="w-10 h-10 bg-green-100 rounded-xl flex items-center justify-center">
                  <Heart size={18} className="text-green-600" />
                </div>
                <div>
                  <p className="font-medium text-gray-900 text-sm">{log.itemName}</p>
                  <p className="text-xs text-gray-400">
                    Donated to: <span className="text-gray-600 font-medium">{log.recipientOrg}</span>
                  </p>
                  <p className="text-xs text-gray-400">{new Date(log.loggedAt).toLocaleDateString('en-BD', { year: 'numeric', month: 'long', day: 'numeric' })}</p>
                </div>
              </div>
              <div className="flex items-center gap-4">
                <div className="text-right">
                  <p className="text-sm font-bold text-green-700">{log.quantity} units</p>
                  <Badge variant="green">Completed</Badge>
                </div>
                <a
                  href={log.receiptUrl}
                  className="flex items-center gap-1.5 px-3 py-2 border border-gray-200 rounded-lg text-sm text-gray-600 hover:bg-gray-50 transition-colors"
                >
                  <Download size={14} /> Receipt
                </a>
              </div>
            </div>
          ))}
        </div>
      </Card>

      <Card className="mt-6 bg-gradient-to-r from-green-50 to-green-100 border-green-200">
        <div className="flex items-center gap-4">
          <div className="w-12 h-12 bg-green-600 rounded-xl flex items-center justify-center">
            <Heart size={24} className="text-white" />
          </div>
          <div>
            <p className="font-bold text-gray-900">Tax Deduction Notice</p>
            <p className="text-sm text-gray-600 mt-0.5">Your food donations may be eligible for tax deductions. Download receipts above for your records.</p>
          </div>
        </div>
      </Card>
    </Layout>
  );
}
