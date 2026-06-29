import { useNavigate } from 'react-router-dom';
import { Leaf, ArrowRight, CheckCircle, Utensils, ShoppingBag } from 'lucide-react';

export function WelcomeScreen() {
  const navigate = useNavigate();

  const modes = [
    {
      icon: <Utensils size={32} />,
      title: 'Donor Mode',
      subtitle: 'Restaurants · Caterers · Stores',
      description: 'List surplus food for donation or discounted sale. Manage inventory, track expiry, and log donations — all in one place.',
      features: ['Inventory management', 'Flash sales & donations', 'Expiry tracking', 'Donation log'],
      color: 'green',
    },
    {
      icon: <ShoppingBag size={32} />,
      title: 'Consumer Mode',
      subtitle: 'NGOs · Food Banks · Shelters · Individuals',
      description: 'Browse and claim surplus food nearby. Submit bulk requests, coordinate pickups, and track your food rescue impact.',
      features: ['Discount marketplace', 'Bulk food requests', 'Surplus radar map', 'Pickup coordination'],
      color: 'orange',
    },
  ];

  const colorMap = {
    green: {
      border: 'border-green-200 hover:border-green-400',
      icon: 'bg-green-100 text-green-700',
      check: 'text-green-600',
    },
    orange: {
      border: 'border-orange-200 hover:border-orange-400',
      icon: 'bg-orange-100 text-orange-700',
      check: 'text-orange-500',
    },
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 via-white to-orange-50">
      <div className="max-w-4xl mx-auto px-6 py-16">
        <div className="text-center mb-14">
          <div className="flex items-center justify-center gap-3 mb-6">
            <div className="w-14 h-14 bg-green-600 rounded-2xl flex items-center justify-center shadow-lg">
              <Leaf size={28} className="text-white" />
            </div>
            <div className="text-left">
              <h1 className="text-3xl font-bold text-gray-900 leading-none">FoodRescue</h1>
              <p className="text-green-600 font-semibold text-lg">Sync</p>
            </div>
          </div>
          <h2 className="text-4xl font-bold text-gray-900 mb-4">Fight Food Waste in Bangladesh</h2>
          <p className="text-lg text-gray-500 max-w-2xl mx-auto">
            A real-time logistics platform connecting food donors with organizations and consumers — ensuring surplus food reaches those who need it before it's wasted.
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-10">
          {modes.map((m) => {
            const c = colorMap[m.color as keyof typeof colorMap];
            return (
              <div
                key={m.title}
                className={`bg-white rounded-2xl border-2 ${c.border} p-6 transition-all hover:shadow-lg`}
              >
                <div className={`w-14 h-14 ${c.icon} rounded-xl flex items-center justify-center mb-4`}>
                  {m.icon}
                </div>
                <h3 className="text-xl font-bold text-gray-900 mb-1">{m.title}</h3>
                <p className="text-sm text-gray-400 mb-3">{m.subtitle}</p>
                <p className="text-gray-600 text-sm mb-5 leading-relaxed">{m.description}</p>
                <ul className="space-y-2">
                  {m.features.map((f) => (
                    <li key={f} className="flex items-center gap-2 text-sm text-gray-600">
                      <CheckCircle size={14} className={c.check} />
                      {f}
                    </li>
                  ))}
                </ul>
              </div>
            );
          })}
        </div>

        <div className="flex flex-col sm:flex-row gap-3 justify-center mb-12">
          <button
            onClick={() => navigate('/login')}
            className="bg-green-600 hover:bg-green-700 text-white font-semibold py-3 px-8 rounded-xl flex items-center justify-center gap-2 transition-colors"
          >
            Get Started <ArrowRight size={18} />
          </button>
          <button
            onClick={() => navigate('/login')}
            className="border-2 border-gray-200 hover:border-gray-300 text-gray-700 font-semibold py-3 px-8 rounded-xl transition-colors"
          >
            Sign In
          </button>
        </div>

        <div className="grid grid-cols-3 gap-6 text-center">
          {[
            { value: '500+', label: 'Meals Rescued Daily' },
            { value: '120+', label: 'Food Donors' },
            { value: '45+', label: 'Partner Organizations' },
          ].map((stat) => (
            <div key={stat.label} className="bg-white rounded-xl p-5 border border-gray-100 shadow-sm">
              <p className="text-3xl font-bold text-green-600">{stat.value}</p>
              <p className="text-sm text-gray-500 mt-1">{stat.label}</p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
