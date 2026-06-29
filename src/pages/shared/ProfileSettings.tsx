import { useState } from 'react';
import { Layout } from '../../components/layout/Layout';
import { Card } from '../../components/ui/Card';
import { Button } from '../../components/ui/Button';
import { User, Bell, Shield, ChevronRight, CheckCircle, Camera } from 'lucide-react';
import { useAuth } from '../../context/AuthContext';

export function ProfileSettings() {
  const { user } = useAuth();
  const [activeTab, setActiveTab] = useState<'profile' | 'alerts' | 'security'>('profile');
  const [saved, setSaved] = useState(false);
  const [alerts, setAlerts] = useState({
    newListings: true, requestUpdates: true, pickupReminders: true,
    flashSales: false, weeklyDigest: true,
  });
  const [foodPrefs, setFoodPrefs] = useState(['Cooked Meals', 'Bakery']);

  const allCategories = ['Cooked Meals', 'Bakery', 'Dairy', 'Produce', 'Grains', 'Pulses', 'Beverages'];

  const togglePref = (cat: string) => {
    setFoodPrefs(prev => prev.includes(cat) ? prev.filter(c => c !== cat) : [...prev, cat]);
  };

  const handleSave = () => {
    setSaved(true);
    setTimeout(() => setSaved(false), 3000);
  };

  const tabs = [
    { id: 'profile' as const, label: 'Profile', icon: <User size={16} /> },
    { id: 'alerts' as const, label: 'Alerts', icon: <Bell size={16} /> },
    { id: 'security' as const, label: 'Security', icon: <Shield size={16} /> },
  ];

  return (
    <Layout title="Profile & Settings" subtitle="Manage your account, preferences, and notifications">
      {saved && (
        <div className="fixed top-6 right-6 z-50 flex items-center gap-2 bg-green-600 text-white px-4 py-3 rounded-xl shadow-lg">
          <CheckCircle size={18} />
          <p className="text-sm font-medium">Settings saved!</p>
        </div>
      )}

      <div className="max-w-2xl mx-auto">
        <Card className="mb-6">
          <div className="flex items-center gap-5">
            <div className="relative">
              <div className="w-20 h-20 bg-green-100 rounded-2xl flex items-center justify-center">
                <span className="text-3xl font-bold text-green-700">{user?.name.charAt(0)}</span>
              </div>
              <button className="absolute -bottom-1 -right-1 w-7 h-7 bg-green-600 rounded-full flex items-center justify-center shadow-md hover:bg-green-700 transition-colors">
                <Camera size={12} className="text-white" />
              </button>
            </div>
            <div>
              <h2 className="text-xl font-bold text-gray-900">{user?.name}</h2>
              <p className="text-sm text-gray-500 mt-0.5">{user?.email}</p>
              <p className="text-xs text-green-600 font-medium capitalize mt-1 bg-green-50 px-2 py-0.5 rounded-full inline-block">
                {user?.accountType?.replace('_', ' ')}
              </p>
            </div>
          </div>
        </Card>

        <div className="flex gap-2 mb-6">
          {tabs.map(tab => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              className={`flex items-center gap-2 px-4 py-2.5 rounded-xl text-sm font-medium transition-colors ${
                activeTab === tab.id ? 'bg-green-600 text-white' : 'bg-white text-gray-600 border border-gray-200 hover:bg-gray-50'
              }`}
            >
              {tab.icon}{tab.label}
            </button>
          ))}
        </div>

        {activeTab === 'profile' && (
          <Card>
            <h3 className="font-semibold text-gray-900 mb-5 flex items-center gap-2">
              <User size={18} className="text-gray-500" /> Personal Information
            </h3>
            <div className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1.5">Full Name</label>
                  <input defaultValue={user?.name}
                    className="w-full px-3.5 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500" />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1.5">Phone Number</label>
                  <input defaultValue="+880 1234 567890"
                    className="w-full px-3.5 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500" />
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1.5">Email Address</label>
                <input type="email" defaultValue={user?.email}
                  className="w-full px-3.5 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500" />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-3">Food Type Preferences</label>
                <div className="flex flex-wrap gap-2">
                  {allCategories.map(cat => (
                    <button
                      key={cat}
                      onClick={() => togglePref(cat)}
                      className={`px-3 py-1.5 rounded-lg text-sm font-medium border transition-all ${
                        foodPrefs.includes(cat)
                          ? 'bg-green-100 border-green-400 text-green-700'
                          : 'bg-white border-gray-200 text-gray-600 hover:border-green-300'
                      }`}
                    >
                      {cat}
                    </button>
                  ))}
                </div>
              </div>
              <Button onClick={handleSave}>Save Changes</Button>
            </div>
          </Card>
        )}

        {activeTab === 'alerts' && (
          <Card>
            <h3 className="font-semibold text-gray-900 mb-5 flex items-center gap-2">
              <Bell size={18} className="text-gray-500" /> Notification Settings
            </h3>
            <div className="space-y-4">
              {(Object.entries(alerts) as [keyof typeof alerts, boolean][]).map(([key, value]) => {
                const labels: Record<keyof typeof alerts, { title: string; desc: string }> = {
                  newListings: { title: 'New Listings', desc: 'Alert when matching food types are listed nearby' },
                  requestUpdates: { title: 'Request Updates', desc: 'Notify when your request status changes' },
                  pickupReminders: { title: 'Pickup Reminders', desc: '30-minute reminder before your scheduled pickup' },
                  flashSales: { title: 'Flash Sales', desc: 'Instant alerts for discounted surplus near you' },
                  weeklyDigest: { title: 'Weekly Digest', desc: 'Summary of your activity and impact each week' },
                };
                const info = labels[key];
                return (
                  <div key={key} className="flex items-center justify-between py-3 border-b border-gray-50 last:border-0">
                    <div>
                      <p className="text-sm font-medium text-gray-900">{info.title}</p>
                      <p className="text-xs text-gray-400 mt-0.5">{info.desc}</p>
                    </div>
                    <button
                      onClick={() => setAlerts(prev => ({ ...prev, [key]: !prev[key] }))}
                      className={`relative w-11 h-6 rounded-full transition-colors ${value ? 'bg-green-600' : 'bg-gray-200'}`}
                    >
                      <span className={`absolute top-1 w-4 h-4 bg-white rounded-full shadow transition-transform ${value ? 'translate-x-6' : 'translate-x-1'}`} />
                    </button>
                  </div>
                );
              })}
              <Button onClick={handleSave} className="mt-2">Save Preferences</Button>
            </div>
          </Card>
        )}

        {activeTab === 'security' && (
          <div className="space-y-4">
            <Card>
              <h3 className="font-semibold text-gray-900 mb-4 flex items-center gap-2">
                <Shield size={18} className="text-gray-500" /> Password & Security
              </h3>
              <div className="space-y-3">
                {[
                  { label: 'Change Password', desc: 'Update your account password' },
                  { label: 'Two-Factor Authentication', desc: 'Add extra security to your account' },
                  { label: 'Active Sessions', desc: 'Manage devices logged in to your account' },
                ].map(item => (
                  <button key={item.label} className="w-full flex items-center justify-between p-3 rounded-xl hover:bg-gray-50 transition-colors">
                    <div className="text-left">
                      <p className="text-sm font-medium text-gray-900">{item.label}</p>
                      <p className="text-xs text-gray-400">{item.desc}</p>
                    </div>
                    <ChevronRight size={16} className="text-gray-400" />
                  </button>
                ))}
              </div>
            </Card>
            <Card className="border-red-100">
              <h3 className="font-semibold text-red-600 mb-3">Danger Zone</h3>
              <p className="text-sm text-gray-500 mb-4">Permanently delete your account and all associated data.</p>
              <Button variant="danger" size="sm">Delete Account</Button>
            </Card>
          </div>
        )}
      </div>
    </Layout>
  );
}
