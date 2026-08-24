import 'dart:typed_data';

enum AccountType { restaurant, caterer, store, ngo, foodBank, shelter, individual }

enum UserMode { donor, consumer, admin }

enum AccountStatus { pending, approved, suspended }

enum ListingType { donation, flashSale }

enum ListingStatus { active, claimed, expired }

enum RequestStatus { pending, accepted, rejected, completed }

enum PickupStatus { scheduled, enRoute, completed }

enum PickupPreference { self, management, rider }

enum NotificationType { listing, request, pickup, system }

enum DonorTier { novice, contributor, provider, patron, master, legend }

enum ConsumerTier { novice, scout, saver, rescuer, master, legend }

class AppUser {
  final int id;
  final String name;
  final String email;
  final AccountType accountType;
  final UserMode mode;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.accountType,
    required this.mode,
  });

  AppUser copyWith({UserMode? mode, String? name}) =>
      AppUser(id: id, name: name ?? this.name, email: email, accountType: accountType, mode: mode ?? this.mode);
}

class InventoryItem {
  final int id;
  final String? docId;
  final String name;
  final String? barcode;
  final int quantity;
  final DateTime expiryDate;
  final bool isSurplus;
  final String category;
  final String? imageUrl;
  final Uint8List? imageBytes;

  InventoryItem({
    required this.id,
    this.docId,
    required this.name,
    this.barcode,
    required this.quantity,
    required this.expiryDate,
    required this.isSurplus,
    required this.category,
    this.imageUrl,
    this.imageBytes,
  });
}

class Listing {
  final int id;
  final String? docId;
  final int donorId;
  final String donorName;
  final String title;
  final String description;
  final double price;
  final int quantity;
  final ListingType listingType;
  final DateTime pickupStart;
  final DateTime pickupEnd;
  final double latitude;
  final double longitude;
  final ListingStatus status;
  final String category;
  final double? distance;
  final String? imageUrl;
  final Uint8List? imageBytes;
  final String? address;

  Listing({
    required this.id,
    this.docId,
    required this.donorId,
    required this.donorName,
    required this.title,
    required this.description,
    required this.price,
    required this.quantity,
    required this.listingType,
    required this.pickupStart,
    required this.pickupEnd,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.category,
    this.distance,
    this.imageUrl,
    this.imageBytes,
    this.address,
  });

  Listing copyWith({ListingStatus? status}) => Listing(
    id: id,
    docId: docId,
    donorId: donorId,
    donorName: donorName,
    title: title,
    description: description,
    price: price,
    quantity: quantity,
    listingType: listingType,
    pickupStart: pickupStart,
    pickupEnd: pickupEnd,
    latitude: latitude,
    longitude: longitude,
    status: status ?? this.status,
    category: category,
    distance: distance,
    imageUrl: imageUrl,
    imageBytes: imageBytes,
    address: address,
  );
}

class FoodRequest {
  final int id;
  final int listingId;
  final String listingTitle;
  final String donorName;
  final int quantity;
  final RequestStatus status;
  final DateTime createdAt;

  FoodRequest({
    required this.id,
    required this.listingId,
    required this.listingTitle,
    required this.donorName,
    required this.quantity,
    required this.status,
    required this.createdAt,
  });
}

class Pickup {
  final int id;
  final int requestId;
  final String address;
  final DateTime scheduledTime;
  final PickupStatus status;
  final String donorName;
  final List<String> items;

  Pickup({
    required this.id,
    required this.requestId,
    required this.address,
    required this.scheduledTime,
    required this.status,
    required this.donorName,
    required this.items,
  });
}

class DonationLog {
  final int id;
  final int donorId;
  final int requestId;
  final DateTime loggedAt;
  final String itemName;
  final int quantity;
  final String recipientOrg;

  DonationLog({
    required this.id,
    required this.donorId,
    required this.requestId,
    required this.loggedAt,
    required this.itemName,
    required this.quantity,
    required this.recipientOrg,
  });
}

class RegisteredAccount {
  final int id;
  final String name;
  final String email;
  final AccountType accountType;
  final UserMode mode;
  final AccountStatus status;
  final DateTime joinedAt;
  final bool isAvailable;
  final int listingsCreated;
  final double kgSaved;
  final int mealsRescued;
  final double fulfillmentRate;
  final double onTimePickupRate;
  final double rating;
  final int reviewCount;
  final PickupPreference pickupPreference;
  final double? latitude;
  final double? longitude;
  final String? address;

  RegisteredAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.accountType,
    required this.mode,
    required this.status,
    required this.joinedAt,
    this.isAvailable = true,
    this.listingsCreated = 0,
    this.kgSaved = 0,
    this.mealsRescued = 0,
    this.fulfillmentRate = 0,
    this.onTimePickupRate = 0,
    this.rating = 0,
    this.reviewCount = 0,
    this.pickupPreference = PickupPreference.self,
    this.latitude,
    this.longitude,
    this.address,
  });

  RegisteredAccount copyWith({
    AccountStatus? status,
    bool? isAvailable,
    PickupPreference? pickupPreference,
    double? latitude,
    double? longitude,
    String? address,
  }) => RegisteredAccount(
    id: id,
    name: name,
    email: email,
    accountType: accountType,
    mode: mode,
    status: status ?? this.status,
    joinedAt: joinedAt,
    isAvailable: isAvailable ?? this.isAvailable,
    listingsCreated: listingsCreated,
    kgSaved: kgSaved,
    mealsRescued: mealsRescued,
    fulfillmentRate: fulfillmentRate,
    onTimePickupRate: onTimePickupRate,
    rating: rating,
    reviewCount: reviewCount,
    pickupPreference: pickupPreference ?? this.pickupPreference,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    address: address ?? this.address,
  );
}

class AppNotification {
  final int id;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final NotificationType type;

  AppNotification({
    required this.id,
    required this.message,
    required this.isRead,
    required this.createdAt,
    required this.type,
  });
}

enum DonationScheduleStatus { scheduled, completed, cancelled }

class ScheduledDonation {
  final int id;
  final int consumerId;
  final String consumerName;
  final String donorName;
  final String itemName;
  final String category;
  final int quantity;
  final DateTime scheduledTime;
  final String location;
  final DonationScheduleStatus status;
  final DateTime createdAt;
  final DateTime lastModifiedAt;

  ScheduledDonation({
    required this.id,
    required this.consumerId,
    required this.consumerName,
    required this.donorName,
    required this.itemName,
    required this.category,
    required this.quantity,
    required this.scheduledTime,
    required this.location,
    required this.status,
    required this.createdAt,
    required this.lastModifiedAt,
  });

  ScheduledDonation copyWith({
    DateTime? scheduledTime,
    String? location,
    DonationScheduleStatus? status,
    DateTime? lastModifiedAt,
  }) => ScheduledDonation(
    id: id,
    consumerId: consumerId,
    consumerName: consumerName,
    donorName: donorName,
    itemName: itemName,
    category: category,
    quantity: quantity,
    scheduledTime: scheduledTime ?? this.scheduledTime,
    location: location ?? this.location,
    status: status ?? this.status,
    createdAt: createdAt,
    lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
  );
}

enum PaymentMethod { cashOnDelivery, bkash, nagad, card }

class PaidOrder {
  final int id;
  final int listingId;
  final String listingTitle;
  final String donorName;
  final int consumerId;
  final String consumerName;
  final int quantity;
  final double unitPrice;
  final PaymentMethod paymentMethod;
  final PickupPreference deliveryOption;
  final String deliveryLocation;
  final DateTime placedAt;

  double get total => unitPrice * quantity;

  PaidOrder({
    required this.id,
    required this.listingId,
    required this.listingTitle,
    required this.donorName,
    required this.consumerId,
    required this.consumerName,
    required this.quantity,
    required this.unitPrice,
    required this.paymentMethod,
    required this.deliveryOption,
    required this.deliveryLocation,
    required this.placedAt,
  });
}
