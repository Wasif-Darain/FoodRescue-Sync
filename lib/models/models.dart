import 'dart:typed_data';

enum AccountType { restaurant, caterer, store, ngo, foodBank, shelter, individual }

enum UserMode { donor, consumer, admin }

enum AccountStatus { pending, approved, suspended }

enum ListingType { donation, flashSale }

enum ListingStatus { active, claimed, expired }

enum RequestStatus { pending, accepted, rejected, completed }

enum PickupStatus { scheduled, enRoute, completed }

enum NotificationType { listing, request, pickup, system }

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

  AppUser copyWith({UserMode? mode}) =>
      AppUser(id: id, name: name, email: email, accountType: accountType, mode: mode ?? this.mode);
}

class InventoryItem {
  final int id;
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

  Listing({
    required this.id,
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
  });
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

  RegisteredAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.accountType,
    required this.mode,
    required this.status,
    required this.joinedAt,
    this.isAvailable = true,
  });

  RegisteredAccount copyWith({AccountStatus? status, bool? isAvailable}) => RegisteredAccount(
    id: id,
    name: name,
    email: email,
    accountType: accountType,
    mode: mode,
    status: status ?? this.status,
    joinedAt: joinedAt,
    isAvailable: isAvailable ?? this.isAvailable,
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
