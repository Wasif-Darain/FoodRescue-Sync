export type AccountType = 'restaurant' | 'caterer' | 'store' | 'ngo' | 'food_bank' | 'shelter' | 'individual';
export type UserMode = 'donor' | 'consumer';

export interface User {
  id: number;
  name: string;
  email: string;
  accountType: AccountType;
  mode: UserMode;
  phone: string;
}

export interface InventoryItem {
  id: number;
  name: string;
  barcode?: string;
  quantity: number;
  expiryDate: string;
  isSurplus: boolean;
  category: string;
}

export interface Listing {
  id: number;
  donorId: number;
  donorName: string;
  title: string;
  description: string;
  price: number;
  quantity: number;
  listingType: 'donation' | 'flash_sale';
  pickupStart: string;
  pickupEnd: string;
  latitude: number;
  longitude: number;
  status: 'active' | 'claimed' | 'expired';
  images: string[];
  category: string;
  distance?: number;
}

export interface Request {
  id: number;
  listingId: number;
  listingTitle: string;
  donorName: string;
  quantity: number;
  status: 'pending' | 'accepted' | 'rejected' | 'completed';
  createdAt: string;
}

export interface Pickup {
  id: number;
  requestId: number;
  address: string;
  scheduledTime: string;
  status: 'scheduled' | 'en_route' | 'completed';
  donorName: string;
  items: string[];
}

export interface DonationLog {
  id: number;
  donorId: number;
  requestId: number;
  receiptUrl: string;
  loggedAt: string;
  itemName: string;
  quantity: number;
  recipientOrg: string;
}

export interface Notification {
  id: number;
  message: string;
  isRead: boolean;
  createdAt: string;
  type: 'listing' | 'request' | 'pickup' | 'system';
}
