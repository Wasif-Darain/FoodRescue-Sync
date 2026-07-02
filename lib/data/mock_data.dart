import '../models/models.dart';

final mockInventory = [
  InventoryItem(id: 1, name: 'Basmati Rice', barcode: '8901234567890', quantity: 50, expiryDate: DateTime(2026, 7, 2), isSurplus: true, category: 'Grains'),
  InventoryItem(id: 2, name: 'Chicken Biryani', barcode: '8901234567891', quantity: 30, expiryDate: DateTime(2026, 6, 30), isSurplus: true, category: 'Cooked Meals'),
  InventoryItem(id: 3, name: 'Fresh Vegetables', quantity: 20, expiryDate: DateTime(2026, 7, 5), isSurplus: false, category: 'Produce'),
  InventoryItem(id: 4, name: 'Bread Loaves', barcode: '8901234567892', quantity: 15, expiryDate: DateTime(2026, 7, 1), isSurplus: true, category: 'Bakery'),
  InventoryItem(id: 5, name: 'Milk Packets', barcode: '8901234567893', quantity: 40, expiryDate: DateTime(2026, 7, 3), isSurplus: false, category: 'Dairy'),
  InventoryItem(id: 6, name: 'Dal (Lentils)', barcode: '8901234567894', quantity: 25, expiryDate: DateTime(2026, 8, 15), isSurplus: false, category: 'Pulses'),
  InventoryItem(id: 7, name: 'Roti Bundle', quantity: 60, expiryDate: DateTime(2026, 6, 30), isSurplus: true, category: 'Bakery'),
  InventoryItem(id: 8, name: 'Fish Curry', quantity: 18, expiryDate: DateTime(2026, 7, 1), isSurplus: true, category: 'Cooked Meals'),
];

final mockListings = [
  Listing(id: 1, donorId: 1, donorName: 'Green Kitchen Restaurant', title: 'Chicken Biryani (30 servings)', description: "Freshly cooked biryani from today's event. Best consumed today.", price: 0, quantity: 30, listingType: ListingType.donation, pickupStart: DateTime(2026, 6, 29, 18), pickupEnd: DateTime(2026, 6, 29, 21), latitude: 23.8103, longitude: 90.4125, status: ListingStatus.active, category: 'Cooked Meals', distance: 1.2),
  Listing(id: 2, donorId: 2, donorName: 'Dhaka Bakery House', title: 'Bread Loaves Bundle', description: 'End-of-day bread at 60% off. Pick up before closing.', price: 80, quantity: 15, listingType: ListingType.flashSale, pickupStart: DateTime(2026, 6, 29, 20), pickupEnd: DateTime(2026, 6, 29, 22), latitude: 23.815, longitude: 90.42, status: ListingStatus.active, category: 'Bakery', distance: 2.5),
  Listing(id: 3, donorId: 3, donorName: 'Star Caterers', title: 'Vegetable Mixed Platter', description: 'Event leftovers – assorted vegetable dishes, enough for 20 people.', price: 0, quantity: 20, listingType: ListingType.donation, pickupStart: DateTime(2026, 6, 29, 19), pickupEnd: DateTime(2026, 6, 29, 22), latitude: 23.82, longitude: 90.405, status: ListingStatus.active, category: 'Produce', distance: 0.8),
  Listing(id: 4, donorId: 4, donorName: 'Honest Grocery', title: 'Mixed Dairy Products', description: 'Milk, yogurt, and paneer nearing expiry. 50% off.', price: 150, quantity: 25, listingType: ListingType.flashSale, pickupStart: DateTime(2026, 6, 29, 17), pickupEnd: DateTime(2026, 6, 29, 20), latitude: 23.808, longitude: 90.418, status: ListingStatus.active, category: 'Dairy', distance: 3.1),
  Listing(id: 5, donorId: 5, donorName: 'Bismillah Catering', title: 'Roti & Dal Set', description: '60 rotis with dal – surplus from wedding catering today.', price: 0, quantity: 60, listingType: ListingType.donation, pickupStart: DateTime(2026, 6, 29, 21), pickupEnd: DateTime(2026, 6, 29, 23), latitude: 23.825, longitude: 90.41, status: ListingStatus.active, category: 'Bakery', distance: 4.0),
];

final mockRequests = [
  FoodRequest(id: 1, listingId: 1, listingTitle: 'Chicken Biryani (30 servings)', donorName: 'Green Kitchen Restaurant', quantity: 30, status: RequestStatus.accepted, createdAt: DateTime(2026, 6, 29, 15)),
  FoodRequest(id: 2, listingId: 3, listingTitle: 'Vegetable Mixed Platter', donorName: 'Star Caterers', quantity: 20, status: RequestStatus.pending, createdAt: DateTime(2026, 6, 29, 16, 30)),
  FoodRequest(id: 3, listingId: 2, listingTitle: 'Bread Loaves Bundle', donorName: 'Dhaka Bakery House', quantity: 10, status: RequestStatus.completed, createdAt: DateTime(2026, 6, 28, 18)),
  FoodRequest(id: 4, listingId: 5, listingTitle: 'Roti & Dal Set', donorName: 'Bismillah Catering', quantity: 30, status: RequestStatus.rejected, createdAt: DateTime(2026, 6, 29, 12)),
];

final mockPickups = [
  Pickup(id: 1, requestId: 1, address: 'House 12, Road 5, Dhanmondi, Dhaka', scheduledTime: DateTime(2026, 6, 29, 18, 30), status: PickupStatus.scheduled, donorName: 'Green Kitchen Restaurant', items: ['Chicken Biryani x30']),
  Pickup(id: 2, requestId: 3, address: 'Shop 4, New Market, Dhaka', scheduledTime: DateTime(2026, 6, 29, 20), status: PickupStatus.enRoute, donorName: 'Dhaka Bakery House', items: ['Bread Loaves x10']),
];

final mockDonationLogs = [
  DonationLog(id: 1, donorId: 1, requestId: 3, loggedAt: DateTime(2026, 6, 28, 20), itemName: 'Bread Loaves', quantity: 10, recipientOrg: 'Dhaka Food Bank'),
  DonationLog(id: 2, donorId: 1, requestId: 2, loggedAt: DateTime(2026, 6, 27, 19), itemName: 'Mixed Rice', quantity: 25, recipientOrg: 'Hunger Help BD'),
  DonationLog(id: 3, donorId: 1, requestId: 1, loggedAt: DateTime(2026, 6, 26, 21), itemName: 'Vegetable Curry', quantity: 15, recipientOrg: 'Al-Amin Shelter'),
];

final mockNotifications = [
  AppNotification(id: 1, message: 'New donation listing nearby: Chicken Biryani (30 servings) from Green Kitchen Restaurant', isRead: false, createdAt: DateTime(2026, 6, 29, 15), type: NotificationType.listing),
  AppNotification(id: 2, message: 'Your request for Vegetable Mixed Platter is pending approval', isRead: false, createdAt: DateTime(2026, 6, 29, 16, 30), type: NotificationType.request),
  AppNotification(id: 3, message: 'Pickup scheduled for Chicken Biryani at 6:30 PM today', isRead: false, createdAt: DateTime(2026, 6, 29, 15, 5), type: NotificationType.pickup),
  AppNotification(id: 4, message: 'Flash sale alert: Bread Loaves at 60% off – only 2 km away!', isRead: true, createdAt: DateTime(2026, 6, 29, 14), type: NotificationType.listing),
  AppNotification(id: 5, message: 'Your request for Roti & Dal Set was rejected by donor', isRead: true, createdAt: DateTime(2026, 6, 29, 12, 30), type: NotificationType.request),
  AppNotification(id: 6, message: 'Donation receipt generated for Bread Loaves donation', isRead: true, createdAt: DateTime(2026, 6, 28, 20, 5), type: NotificationType.system),
];
