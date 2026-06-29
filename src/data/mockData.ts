import type { InventoryItem, Listing, Request, Pickup, DonationLog, Notification } from '../types';

export const mockUser = {
  id: 1,
  name: 'Mehedi Hasan',
  email: 'mehedi@restaurant.com',
  role: 'donor' as const,
  phone: '+880 1234 567890',
};

export const mockInventory: InventoryItem[] = [
  { id: 1, name: 'Basmati Rice', barcode: '8901234567890', quantity: 50, expiryDate: '2026-07-02', isSurplus: true, category: 'Grains' },
  { id: 2, name: 'Chicken Biryani', barcode: '8901234567891', quantity: 30, expiryDate: '2026-06-30', isSurplus: true, category: 'Cooked Meals' },
  { id: 3, name: 'Fresh Vegetables', barcode: '', quantity: 20, expiryDate: '2026-07-05', isSurplus: false, category: 'Produce' },
  { id: 4, name: 'Bread Loaves', barcode: '8901234567892', quantity: 15, expiryDate: '2026-07-01', isSurplus: true, category: 'Bakery' },
  { id: 5, name: 'Milk Packets', barcode: '8901234567893', quantity: 40, expiryDate: '2026-07-03', isSurplus: false, category: 'Dairy' },
  { id: 6, name: 'Dal (Lentils)', barcode: '8901234567894', quantity: 25, expiryDate: '2026-08-15', isSurplus: false, category: 'Pulses' },
  { id: 7, name: 'Roti Bundle', barcode: '', quantity: 60, expiryDate: '2026-06-30', isSurplus: true, category: 'Bakery' },
  { id: 8, name: 'Fish Curry', barcode: '', quantity: 18, expiryDate: '2026-07-01', isSurplus: true, category: 'Cooked Meals' },
];

export const mockListings: Listing[] = [
  {
    id: 1, donorId: 1, donorName: 'Green Kitchen Restaurant', title: 'Chicken Biryani (30 servings)',
    description: 'Freshly cooked biryani from today\'s event. Best consumed today.', price: 0,
    quantity: 30, listingType: 'donation', pickupStart: '2026-06-29T18:00:00', pickupEnd: '2026-06-29T21:00:00',
    latitude: 23.8103, longitude: 90.4125, status: 'active', images: [], category: 'Cooked Meals', distance: 1.2,
  },
  {
    id: 2, donorId: 2, donorName: 'Dhaka Bakery House', title: 'Bread Loaves Bundle',
    description: 'End-of-day bread at 60% off. Pick up before closing.', price: 80,
    quantity: 15, listingType: 'flash_sale', pickupStart: '2026-06-29T20:00:00', pickupEnd: '2026-06-29T22:00:00',
    latitude: 23.8150, longitude: 90.4200, status: 'active', images: [], category: 'Bakery', distance: 2.5,
  },
  {
    id: 3, donorId: 3, donorName: 'Star Caterers', title: 'Vegetable Mixed Platter',
    description: 'Event leftovers – assorted vegetable dishes, enough for 20 people.', price: 0,
    quantity: 20, listingType: 'donation', pickupStart: '2026-06-29T19:00:00', pickupEnd: '2026-06-29T22:00:00',
    latitude: 23.8200, longitude: 90.4050, status: 'active', images: [], category: 'Produce', distance: 0.8,
  },
  {
    id: 4, donorId: 4, donorName: 'Honest Grocery', title: 'Mixed Dairy Products',
    description: 'Milk, yogurt, and paneer nearing expiry. 50% off.', price: 150,
    quantity: 25, listingType: 'flash_sale', pickupStart: '2026-06-29T17:00:00', pickupEnd: '2026-06-29T20:00:00',
    latitude: 23.8080, longitude: 90.4180, status: 'active', images: [], category: 'Dairy', distance: 3.1,
  },
  {
    id: 5, donorId: 5, donorName: 'Bismillah Catering', title: 'Roti & Dal Set',
    description: '60 rotis with dal – surplus from wedding catering today.', price: 0,
    quantity: 60, listingType: 'donation', pickupStart: '2026-06-29T21:00:00', pickupEnd: '2026-06-29T23:00:00',
    latitude: 23.8250, longitude: 90.4100, status: 'active', images: [], category: 'Bakery', distance: 4.0,
  },
];

export const mockRequests: Request[] = [
  { id: 1, listingId: 1, listingTitle: 'Chicken Biryani (30 servings)', donorName: 'Green Kitchen Restaurant', quantity: 30, status: 'accepted', createdAt: '2026-06-29T15:00:00' },
  { id: 2, listingId: 3, listingTitle: 'Vegetable Mixed Platter', donorName: 'Star Caterers', quantity: 20, status: 'pending', createdAt: '2026-06-29T16:30:00' },
  { id: 3, listingId: 2, listingTitle: 'Bread Loaves Bundle', donorName: 'Dhaka Bakery House', quantity: 10, status: 'completed', createdAt: '2026-06-28T18:00:00' },
  { id: 4, listingId: 5, listingTitle: 'Roti & Dal Set', donorName: 'Bismillah Catering', quantity: 30, status: 'rejected', createdAt: '2026-06-29T12:00:00' },
];

export const mockPickups: Pickup[] = [
  { id: 1, requestId: 1, address: 'House 12, Road 5, Dhanmondi, Dhaka', scheduledTime: '2026-06-29T18:30:00', status: 'scheduled', donorName: 'Green Kitchen Restaurant', items: ['Chicken Biryani x30'] },
  { id: 2, requestId: 3, address: 'Shop 4, New Market, Dhaka', scheduledTime: '2026-06-29T20:00:00', status: 'en_route', donorName: 'Dhaka Bakery House', items: ['Bread Loaves x10'] },
];

export const mockDonationLogs: DonationLog[] = [
  { id: 1, donorId: 1, requestId: 3, receiptUrl: '#', loggedAt: '2026-06-28T20:00:00', itemName: 'Bread Loaves', quantity: 10, recipientOrg: 'Dhaka Food Bank' },
  { id: 2, donorId: 1, requestId: 2, receiptUrl: '#', loggedAt: '2026-06-27T19:00:00', itemName: 'Mixed Rice', quantity: 25, recipientOrg: 'Hunger Help BD' },
  { id: 3, donorId: 1, requestId: 1, receiptUrl: '#', loggedAt: '2026-06-26T21:00:00', itemName: 'Vegetable Curry', quantity: 15, recipientOrg: 'Al-Amin Shelter' },
];

export const mockNotifications: Notification[] = [
  { id: 1, message: 'New donation listing nearby: Chicken Biryani (30 servings) from Green Kitchen Restaurant', isRead: false, createdAt: '2026-06-29T15:00:00', type: 'listing' },
  { id: 2, message: 'Your request for Vegetable Mixed Platter is pending approval', isRead: false, createdAt: '2026-06-29T16:30:00', type: 'request' },
  { id: 3, message: 'Pickup scheduled for Chicken Biryani at 6:30 PM today', isRead: false, createdAt: '2026-06-29T15:05:00', type: 'pickup' },
  { id: 4, message: 'Flash sale alert: Bread Loaves at 60% off – only 2 km away!', isRead: true, createdAt: '2026-06-29T14:00:00', type: 'listing' },
  { id: 5, message: 'Your request for Roti & Dal Set was rejected by donor', isRead: true, createdAt: '2026-06-29T12:30:00', type: 'request' },
  { id: 6, message: 'Donation receipt generated for Bread Loaves donation', isRead: true, createdAt: '2026-06-28T20:05:00', type: 'system' },
];
