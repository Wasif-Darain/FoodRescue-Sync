import 'package:flutter/foundation.dart';
import '../data/mock_data.dart';
import '../models/models.dart';

/// Owns the donor's mutable inventory + the listings derived from it.
/// Adding a surplus-tagged inventory item automatically creates a matching
/// donation listing, so it shows up (with its photo) on the consumer
/// marketplace immediately.
class DonorProvider extends ChangeNotifier {
  final List<InventoryItem> _inventory = List.of(mockInventory);
  final List<Listing> _listings = List.of(mockListings);
  int _nextInventoryId = mockInventory.length + 1;
  int _nextListingId = mockListings.length + 1;

  List<InventoryItem> get inventory => List.unmodifiable(_inventory);
  List<Listing> get listings => List.unmodifiable(_listings);

  void addInventoryItem({
    required String name,
    String? barcode,
    required int quantity,
    required DateTime expiryDate,
    required bool isSurplus,
    required String category,
    Uint8List? imageBytes,
    String donorName = 'You',
  }) {
    final item = InventoryItem(
      id: _nextInventoryId++,
      name: name,
      barcode: barcode,
      quantity: quantity,
      expiryDate: expiryDate,
      isSurplus: isSurplus,
      category: category,
      imageBytes: imageBytes,
    );
    _inventory.insert(0, item);

    if (isSurplus) {
      _listings.insert(
        0,
        Listing(
          id: _nextListingId++,
          donorId: 0,
          donorName: donorName,
          title: name,
          description: 'Surplus $category from inventory, ready for pickup.',
          price: 0,
          quantity: quantity,
          listingType: ListingType.donation,
          pickupStart: DateTime.now(),
          pickupEnd: DateTime.now().add(const Duration(hours: 6)),
          latitude: 23.81,
          longitude: 90.41,
          status: ListingStatus.active,
          category: category,
          distance: 0.1,
          imageBytes: imageBytes,
        ),
      );
    }
    notifyListeners();
  }

  void addListing({
    required String title,
    required String description,
    required String category,
    required int quantity,
    required ListingType listingType,
    double price = 0,
    required DateTime pickupStart,
    required DateTime pickupEnd,
    Uint8List? imageBytes,
    String donorName = 'You',
  }) {
    _listings.insert(
      0,
      Listing(
        id: _nextListingId++,
        donorId: 0,
        donorName: donorName,
        title: title,
        description: description,
        price: price,
        quantity: quantity,
        listingType: listingType,
        pickupStart: pickupStart,
        pickupEnd: pickupEnd,
        latitude: 23.81,
        longitude: 90.41,
        status: ListingStatus.active,
        category: category,
        distance: 0.1,
        imageBytes: imageBytes,
      ),
    );
    notifyListeners();
  }
}
