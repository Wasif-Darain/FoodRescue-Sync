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
  Listing(id: 1, donorId: 1, donorName: 'Green Kitchen Restaurant', title: 'Chicken Biryani (30 servings)', description: "Freshly cooked biryani from today's event. Best consumed today.", price: 0, quantity: 30, listingType: ListingType.donation, pickupStart: DateTime.now().add(const Duration(hours: 1)), pickupEnd: DateTime.now().add(const Duration(hours: 4)), latitude: 23.8103, longitude: 90.4125, status: ListingStatus.active, category: 'Cooked Meals', distance: 1.2, address: 'Banani, Dhaka'),
  Listing(id: 2, donorId: 2, donorName: 'Dhaka Bakery House', title: 'Bread Loaves Bundle', description: 'End-of-day bread at 60% off. Pick up before closing.', price: 80, quantity: 15, listingType: ListingType.flashSale, pickupStart: DateTime.now().add(const Duration(hours: 2)), pickupEnd: DateTime.now().add(const Duration(hours: 5)), latitude: 23.815, longitude: 90.42, status: ListingStatus.active, category: 'Bakery', distance: 2.5, address: 'Gulshan 2, Dhaka'),
  Listing(id: 3, donorId: 3, donorName: 'Star Caterers', title: 'Vegetable Mixed Platter', description: 'Event leftovers – assorted vegetable dishes, enough for 20 people.', price: 0, quantity: 20, listingType: ListingType.donation, pickupStart: DateTime.now().add(const Duration(hours: 3)), pickupEnd: DateTime.now().add(const Duration(hours: 8)), latitude: 23.82, longitude: 90.405, status: ListingStatus.active, category: 'Produce', distance: 0.8, address: 'Baridhara, Dhaka'),
  Listing(id: 4, donorId: 4, donorName: 'Honest Grocery', title: 'Mixed Dairy Products', description: 'Milk, yogurt, and paneer nearing expiry. 50% off.', price: 150, quantity: 25, listingType: ListingType.flashSale, pickupStart: DateTime.now().add(const Duration(hours: 1)), pickupEnd: DateTime.now().add(const Duration(hours: 2)), latitude: 23.808, longitude: 90.418, status: ListingStatus.active, category: 'Dairy', distance: 3.1, address: 'Mohakhali, Dhaka'),
  Listing(id: 5, donorId: 5, donorName: 'Bismillah Catering', title: 'Roti & Dal Set', description: '60 rotis with dal – surplus from wedding catering today.', price: 0, quantity: 60, listingType: ListingType.donation, pickupStart: DateTime.now().add(const Duration(hours: 4)), pickupEnd: DateTime.now().add(const Duration(hours: 10)), latitude: 23.825, longitude: 90.41, status: ListingStatus.active, category: 'Bakery', distance: 4.0, address: 'Uttara, Dhaka'),
  Listing(id: 6, donorId: 1, donorName: 'Green Kitchen Restaurant', title: 'Fish Curry (18 servings)', description: 'Leftover fish curry from lunch service.', price: 0, quantity: 18, listingType: ListingType.donation, pickupStart: DateTime.now().subtract(const Duration(hours: 3)), pickupEnd: DateTime.now().subtract(const Duration(hours: 1)), latitude: 23.8103, longitude: 90.4125, status: ListingStatus.active, category: 'Cooked Meals', distance: 1.5, address: 'Banani, Dhaka'),
  Listing(id: 7, donorId: 2, donorName: 'Dhaka Bakery House', title: 'Pastry Assortment', description: 'Assorted pastries from this morning.', price: 60, quantity: 20, listingType: ListingType.flashSale, pickupStart: DateTime.now().subtract(const Duration(hours: 5)), pickupEnd: DateTime.now().subtract(const Duration(hours: 2)), latitude: 23.815, longitude: 90.42, status: ListingStatus.active, category: 'Bakery', distance: 2.8, address: 'Gulshan 2, Dhaka'),
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

final mockAccounts = [
  RegisteredAccount(id: 1, name: 'Green Kitchen Restaurant', email: 'contact@greenkitchen.com', accountType: AccountType.restaurant, mode: UserMode.donor, status: AccountStatus.approved, joinedAt: DateTime(2026, 5, 12), listingsCreated: 45, kgSaved: 320, fulfillmentRate: 92, rating: 4.3, reviewCount: 6, latitude: 23.8103, longitude: 90.4125, address: 'Banani, Dhaka'),
  RegisteredAccount(id: 2, name: 'Dhaka Bakery House', email: 'info@dhakabakery.com', accountType: AccountType.store, mode: UserMode.donor, status: AccountStatus.approved, joinedAt: DateTime(2026, 5, 20), listingsCreated: 8, kgSaved: 40, fulfillmentRate: 85, rating: 3.9, reviewCount: 4, latitude: 23.815, longitude: 90.42, address: 'Gulshan 2, Dhaka'),
  RegisteredAccount(id: 3, name: 'Star Caterers', email: 'hello@starcaterers.com', accountType: AccountType.caterer, mode: UserMode.donor, status: AccountStatus.pending, joinedAt: DateTime(2026, 6, 25), listingsCreated: 2, kgSaved: 10, fulfillmentRate: 75, latitude: 23.82, longitude: 90.405, address: 'Baridhara, Dhaka'),
  RegisteredAccount(id: 4, name: 'Dhaka Food Bank', email: 'admin@dhakafoodbank.org', accountType: AccountType.foodBank, mode: UserMode.consumer, status: AccountStatus.approved, joinedAt: DateTime(2026, 4, 3), isAvailable: true, mealsRescued: 65, onTimePickupRate: 96, rating: 4.6, reviewCount: 12, pickupPreference: PickupPreference.management, latitude: 23.7806, longitude: 90.4193, address: 'Motijheel, Dhaka'),
  RegisteredAccount(id: 5, name: 'Hunger Help BD', email: 'contact@hungerhelp.bd', accountType: AccountType.ngo, mode: UserMode.consumer, status: AccountStatus.approved, joinedAt: DateTime(2026, 4, 15), isAvailable: false, mealsRescued: 12, onTimePickupRate: 88, rating: 3.9, reviewCount: 4, pickupPreference: PickupPreference.rider, latitude: 23.7461, longitude: 90.3742, address: 'Mohammadpur, Dhaka'),
  RegisteredAccount(id: 6, name: 'Al-Amin Shelter', email: 'alamin.shelter@gmail.com', accountType: AccountType.shelter, mode: UserMode.consumer, status: AccountStatus.pending, joinedAt: DateTime(2026, 6, 27), isAvailable: true, mealsRescued: 4, onTimePickupRate: 80, pickupPreference: PickupPreference.self, latitude: 23.8759, longitude: 90.3795, address: 'Uttara, Dhaka'),
  RegisteredAccount(id: 7, name: 'Bismillah Catering', email: 'bismillah.catering@gmail.com', accountType: AccountType.caterer, mode: UserMode.donor, status: AccountStatus.suspended, joinedAt: DateTime(2026, 3, 8), listingsCreated: 130, kgSaved: 800, fulfillmentRate: 96, rating: 4.6, reviewCount: 12, latitude: 23.825, longitude: 90.41, address: 'Uttara Sector 7, Dhaka'),
  RegisteredAccount(id: 8, name: 'Rahim Uddin', email: 'rahim.uddin@gmail.com', accountType: AccountType.individual, mode: UserMode.consumer, status: AccountStatus.pending, joinedAt: DateTime(2026, 6, 29), isAvailable: false, mealsRescued: 1, onTimePickupRate: 60, pickupPreference: PickupPreference.self, latitude: 23.7104, longitude: 90.4074, address: 'Old Dhaka'),
];

final mockNotifications = [
  AppNotification(id: 1, message: 'New donation listing nearby: Chicken Biryani (30 servings) from Green Kitchen Restaurant', isRead: false, createdAt: DateTime(2026, 6, 29, 15), type: NotificationType.listing),
  AppNotification(id: 2, message: 'Your request for Vegetable Mixed Platter is pending approval', isRead: false, createdAt: DateTime(2026, 6, 29, 16, 30), type: NotificationType.request),
  AppNotification(id: 3, message: 'Pickup scheduled for Chicken Biryani at 6:30 PM today', isRead: false, createdAt: DateTime(2026, 6, 29, 15, 5), type: NotificationType.pickup),
  AppNotification(id: 4, message: 'Flash sale alert: Bread Loaves at 60% off – only 2 km away!', isRead: true, createdAt: DateTime(2026, 6, 29, 14), type: NotificationType.listing),
  AppNotification(id: 5, message: 'Your request for Roti & Dal Set was rejected by donor', isRead: true, createdAt: DateTime(2026, 6, 29, 12, 30), type: NotificationType.request),
  AppNotification(id: 6, message: 'Donation receipt generated for Bread Loaves donation', isRead: true, createdAt: DateTime(2026, 6, 28, 20, 5), type: NotificationType.system),
];
