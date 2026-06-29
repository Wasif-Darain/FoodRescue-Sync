import { useState } from 'react';
import { Layout } from '../../components/layout/Layout';
import { Card } from '../../components/ui/Card';
import { Badge } from '../../components/ui/Badge';
import { Button } from '../../components/ui/Button';
import { Bell, MapPin, Truck, ClipboardList, Settings, CheckCheck } from 'lucide-react';
import { mockNotifications } from '../../data/mockData';
import type { Notification } from '../../types';

const typeConfig = {
  listing: { icon: <MapPin size={16} />, color: 'bg-green-100 text-green-600', label: 'New Listing' },
  request: { icon: <ClipboardList size={16} />, color: 'bg-blue-100 text-blue-600', label: 'Request' },
  pickup: { icon: <Truck size={16} />, color: 'bg-orange-100 text-orange-600', label: 'Pickup' },
  system: { icon: <Bell size={16} />, color: 'bg-gray-100 text-gray-600', label: 'System' },
};

export function NotificationCenter() {
  const [notifications, setNotifications] = useState<Notification[]>(mockNotifications);
  const [filter, setFilter] = useState<'all' | Notification['type']>('all');

  const unreadCount = notifications.filter(n => !n.isRead).length;

  const markAllRead = () => setNotifications(prev => prev.map(n => ({ ...n, isRead: true })));
  const markRead = (id: number) => setNotifications(prev => prev.map(n => n.id === id ? { ...n, isRead: true } : n));

  const filtered = notifications.filter(n => filter === 'all' || n.type === filter);

  return (
    <Layout
      title="Notification Centre"
      subtitle="Stay updated on listings, requests, and pickups"
      actions={
        <div className="flex gap-2">
          {unreadCount > 0 && (
            <Button variant="outline" icon={<CheckCheck size={16} />} onClick={markAllRead}>
              Mark all read
            </Button>
          )}
          <Button variant="ghost" icon={<Settings size={16} />}>Preferences</Button>
        </div>
      }
    >
      <div className="max-w-2xl mx-auto">
        {unreadCount > 0 && (
          <div className="flex items-center justify-between mb-5 p-3 bg-green-50 border border-green-200 rounded-xl">
            <div className="flex items-center gap-2">
              <div className="w-6 h-6 bg-green-600 rounded-full flex items-center justify-center">
                <span className="text-white text-xs font-bold">{unreadCount}</span>
              </div>
              <p className="text-sm font-medium text-green-800">{unreadCount} unread notification{unreadCount > 1 ? 's' : ''}</p>
            </div>
            <button onClick={markAllRead} className="text-sm text-green-600 hover:text-green-700 font-medium">
              Mark all read
            </button>
          </div>
        )}

        <div className="flex gap-2 mb-5 flex-wrap">
          {(['all', 'listing', 'request', 'pickup', 'system'] as const).map(f => (
            <button
              key={f}
              onClick={() => setFilter(f)}
              className={`px-3 py-1.5 rounded-lg text-sm font-medium transition-colors capitalize ${
                filter === f ? 'bg-green-600 text-white' : 'bg-white text-gray-600 border border-gray-200 hover:bg-gray-50'
              }`}
            >
              {f === 'all' ? 'All' : typeConfig[f].label}
              {f !== 'all' && (
                <span className="ml-1.5 text-xs opacity-70">
                  {notifications.filter(n => n.type === f).length}
                </span>
              )}
            </button>
          ))}
        </div>

        <Card padding={false}>
          {filtered.length === 0 ? (
            <div className="py-16 text-center text-gray-400">
              <Bell size={40} className="mx-auto mb-3 opacity-40" />
              <p className="font-medium">No notifications</p>
              <p className="text-sm mt-1">You're all caught up!</p>
            </div>
          ) : (
            <div className="divide-y divide-gray-50">
              {filtered.map(notif => {
                const cfg = typeConfig[notif.type];
                return (
                  <div
                    key={notif.id}
                    onClick={() => markRead(notif.id)}
                    className={`px-5 py-4 flex items-start gap-4 cursor-pointer hover:bg-gray-50 transition-colors ${!notif.isRead ? 'bg-green-50/40' : ''}`}
                  >
                    <div className={`w-10 h-10 rounded-xl flex items-center justify-center shrink-0 ${cfg.color}`}>
                      {cfg.icon}
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-start justify-between gap-2">
                        <p className={`text-sm ${notif.isRead ? 'text-gray-600' : 'text-gray-900 font-medium'} leading-relaxed`}>
                          {notif.message}
                        </p>
                        {!notif.isRead && (
                          <span className="w-2 h-2 rounded-full bg-green-500 shrink-0 mt-1.5" />
                        )}
                      </div>
                      <div className="flex items-center gap-2 mt-1.5">
                        <Badge variant="gray">{cfg.label}</Badge>
                        <span className="text-xs text-gray-400">
                          {new Date(notif.createdAt).toLocaleString()}
                        </span>
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </Card>
      </div>
    </Layout>
  );
}
