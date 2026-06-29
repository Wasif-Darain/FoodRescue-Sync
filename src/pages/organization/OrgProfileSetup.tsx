import { useState } from 'react';
import { Layout } from '../../components/layout/Layout';
import { Card } from '../../components/ui/Card';
import { Button } from '../../components/ui/Button';
import { Badge } from '../../components/ui/Badge';
import { Building2, CheckCircle, Upload, Phone, Mail, MapPin, FileText } from 'lucide-react';

export function OrgProfileSetup() {
  const [saved, setSaved] = useState(false);
  const [form, setForm] = useState({
    name: 'Dhaka Food Bank', type: 'NGO', regNumber: 'BD-NGO-2021-0045',
    email: 'info@dhakafoodbank.org', phone: '+880 1700 000001',
    address: 'House 8, Road 12, Dhanmondi, Dhaka-1209',
    description: 'Dhaka Food Bank redistributes surplus food to underserved communities across Dhaka.',
    verificationStatus: true,
  });

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault();
    setSaved(true);
    setTimeout(() => setSaved(false), 3000);
  };

  return (
    <Layout title="Organization Profile" subtitle="Manage your institutional details and verification status">
      <div className="max-w-2xl mx-auto">
        <Card className="mb-6">
          <div className="flex items-center gap-5">
            <div className="w-20 h-20 bg-blue-100 rounded-2xl flex items-center justify-center shrink-0">
              <Building2 size={36} className="text-blue-600" />
            </div>
            <div className="flex-1">
              <div className="flex items-center gap-3 mb-1">
                <h2 className="text-xl font-bold text-gray-900">{form.name}</h2>
                {form.verificationStatus && (
                  <Badge variant="green"><CheckCircle size={12} className="mr-1" />Verified</Badge>
                )}
              </div>
              <p className="text-gray-500 text-sm">{form.type} · Reg: {form.regNumber}</p>
              <button className="mt-3 flex items-center gap-2 text-sm text-blue-600 hover:text-blue-700">
                <Upload size={14} /> Change logo
              </button>
            </div>
          </div>
        </Card>

        {saved && (
          <div className="mb-6 p-4 bg-green-50 border border-green-200 rounded-xl flex items-center gap-3">
            <CheckCircle size={20} className="text-green-600 shrink-0" />
            <p className="text-green-800 text-sm font-medium">Profile saved successfully!</p>
          </div>
        )}

        <form onSubmit={handleSave}>
          <Card className="mb-5">
            <h3 className="font-semibold text-gray-900 mb-4 flex items-center gap-2">
              <Building2 size={18} className="text-gray-500" /> Institution Details
            </h3>
            <div className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1.5">Institution Name</label>
                  <input value={form.name} onChange={e => setForm({ ...form, name: e.target.value })}
                    className="w-full px-3.5 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500" />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1.5">Organization Type</label>
                  <select value={form.type} onChange={e => setForm({ ...form, type: e.target.value })}
                    className="w-full px-3.5 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500 bg-white">
                    {['NGO', 'Shelter', 'Food Bank', 'Religious Organization', 'Government Agency', 'Other'].map(t => (
                      <option key={t}>{t}</option>
                    ))}
                  </select>
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1.5">
                  <FileText size={14} className="inline mr-1" /> Registration Number
                </label>
                <input value={form.regNumber} onChange={e => setForm({ ...form, regNumber: e.target.value })}
                  className="w-full px-3.5 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500" />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1.5">Description</label>
                <textarea rows={3} value={form.description} onChange={e => setForm({ ...form, description: e.target.value })}
                  className="w-full px-3.5 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500 resize-none" />
              </div>
            </div>
          </Card>

          <Card className="mb-5">
            <h3 className="font-semibold text-gray-900 mb-4 flex items-center gap-2">
              <Phone size={18} className="text-gray-500" /> Contact Information
            </h3>
            <div className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1.5">
                    <Mail size={14} className="inline mr-1" /> Email
                  </label>
                  <input type="email" value={form.email} onChange={e => setForm({ ...form, email: e.target.value })}
                    className="w-full px-3.5 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500" />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1.5">
                    <Phone size={14} className="inline mr-1" /> Phone
                  </label>
                  <input value={form.phone} onChange={e => setForm({ ...form, phone: e.target.value })}
                    className="w-full px-3.5 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500" />
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1.5">
                  <MapPin size={14} className="inline mr-1" /> Address
                </label>
                <textarea rows={2} value={form.address} onChange={e => setForm({ ...form, address: e.target.value })}
                  className="w-full px-3.5 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500 resize-none" />
              </div>
            </div>
          </Card>

          <Card className={`mb-6 ${form.verificationStatus ? 'bg-green-50 border-green-200' : 'bg-yellow-50 border-yellow-200'}`}>
            <div className="flex items-center gap-3">
              <CheckCircle size={20} className={form.verificationStatus ? 'text-green-600' : 'text-yellow-600'} />
              <div>
                <p className="font-medium text-gray-900 text-sm">
                  Verification Status: <span className={form.verificationStatus ? 'text-green-600' : 'text-yellow-600'}>
                    {form.verificationStatus ? 'Verified' : 'Pending'}
                  </span>
                </p>
                <p className="text-xs text-gray-500 mt-0.5">
                  {form.verificationStatus
                    ? 'Your organization is verified and can access all donation features.'
                    : 'Submit your registration documents to complete verification.'}
                </p>
              </div>
              {!form.verificationStatus && (
                <Button size="sm" className="ml-auto">Submit Docs</Button>
              )}
            </div>
          </Card>

          <Button type="submit" size="lg">Save Profile</Button>
        </form>
      </div>
    </Layout>
  );
}
