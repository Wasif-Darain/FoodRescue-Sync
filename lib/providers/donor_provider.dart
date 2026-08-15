import 'dart:typed_data';
import 'package:flutter/material.dart';
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

  void markListingClaimed(int listingId) {
    final i = _listings.indexWhere((l) => l.id == listingId);
    if (i == -1) return;
    _listings[i] = _listings[i].copyWith(status: ListingStatus.claimed);
    notifyListeners();
  }

  TimeOfDay _preferredPickupTime = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay get preferredPickupTime => _preferredPickupTime;
  void setPreferredPickupTime(TimeOfDay time) {
    _preferredPickupTime = time;
    notifyListeners();
  }

  bool _isAvailable = true;
  bool get isAvailable => _isAvailable;

  final List<ScheduledDonation> _scheduledDonations = [];
  int _nextScheduledDonationId = 1;
  List<ScheduledDonation> get scheduledDonations =>
      List.unmodifiable(_scheduledDonations);

  /// Total times this donor has donated (or has an active pending donation)
  /// to [consumerName] — the sole source for card sort order and the
  /// "reception streak" badge. A simple running count; the app has no
  /// concept of broken/gap streaks elsewhere so none is modeled here.
  int donationCountFor(String consumerName) =>
      mockDonationLogs.where((l) => l.recipientOrg == consumerName).length +
      _scheduledDonations
          .where(
            (d) =>
                d.consumerName == consumerName &&
                d.status != DonationScheduleStatus.cancelled,
          )
          .length;

  void donateToConsumer({
    required int consumerId,
    required String consumerName,
    required String itemName,
    required String category,
    required int quantity,
    required DateTime scheduledTime,
    required String location,
    String donorName = 'You',
  }) {
    final now = DateTime.now();
    _scheduledDonations.insert(
      0,
      ScheduledDonation(
        id: _nextScheduledDonationId++,
        consumerId: consumerId,
        consumerName: consumerName,
        donorName: donorName,
        itemName: itemName,
        category: category,
        quantity: quantity,
        scheduledTime: scheduledTime,
        location: location,
        status: DonationScheduleStatus.scheduled,
        createdAt: now,
        lastModifiedAt: now,
      ),
    );
    notifyListeners();
  }

  void _notifyConsumer(String message) {
    mockNotifications.insert(
      0,
      AppNotification(
        id: mockNotifications.length + 1,
        message: message,
        isRead: false,
        createdAt: DateTime.now(),
        type: NotificationType.pickup,
      ),
    );
  }

  /// Returns null on success, or a user-facing error string if blocked.
  String? rescheduleDonation(int id, DateTime newTime, String newLocation) {
    final i = _scheduledDonations.indexWhere((d) => d.id == id);
    if (i == -1) return 'Donation not found.';
    final d = _scheduledDonations[i];
    if (d.status != DonationScheduleStatus.scheduled) {
      return 'This donation can no longer be edited.';
    }
    if (d.scheduledTime.difference(DateTime.now()).inHours < 12) {
      return 'Changes must be made at least 12 hours before the scheduled pickup time.';
    }
    _scheduledDonations[i] = d.copyWith(
      scheduledTime: newTime,
      location: newLocation,
      lastModifiedAt: DateTime.now(),
    );
    _notifyConsumer(
      '${d.donorName} rescheduled your donation pickup to '
      '${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')} '
      'on ${newTime.day}/${newTime.month}/${newTime.year} at $newLocation.',
    );
    notifyListeners();
    return null;
  }

  /// Returns null on success, or a user-facing error string if blocked.
  String? cancelDonation(int id) {
    final i = _scheduledDonations.indexWhere((d) => d.id == id);
    if (i == -1) return 'Donation not found.';
    final d = _scheduledDonations[i];
    if (d.status != DonationScheduleStatus.scheduled) {
      return 'This donation can no longer be cancelled.';
    }
    if (d.scheduledTime.difference(DateTime.now()).inHours < 12) {
      return 'Cancellations must be made at least 12 hours before the scheduled pickup time.';
    }
    _scheduledDonations[i] = d.copyWith(
      status: DonationScheduleStatus.cancelled,
      lastModifiedAt: DateTime.now(),
    );
    _notifyConsumer(
      '${d.donorName} cancelled the donation scheduled for '
      '${d.scheduledTime.day}/${d.scheduledTime.month}/${d.scheduledTime.year}.',
    );
    notifyListeners();
    return null;
  }

  /// Toggles the donor's global availability. Going unavailable cancels
  /// every scheduled donation that still has >=12 hours remaining
  /// (notifying each recipient); donations inside the 12-hour window are
  /// left untouched. Returns a summary string for the caller to display.
  String setAvailability(bool available) {
    _isAvailable = available;
    if (!available) {
      final now = DateTime.now();
      var cancelled = 0;
      var blocked = 0;
      for (var i = 0; i < _scheduledDonations.length; i++) {
        final d = _scheduledDonations[i];
        if (d.status != DonationScheduleStatus.scheduled) continue;
        if (d.scheduledTime.difference(now).inHours < 12) {
          blocked++;
          continue;
        }
        _scheduledDonations[i] = d.copyWith(
          status: DonationScheduleStatus.cancelled,
          lastModifiedAt: now,
        );
        _notifyConsumer(
          '${d.donorName} has marked themselves unavailable and cancelled '
          'the donation scheduled for '
          '${d.scheduledTime.day}/${d.scheduledTime.month}/${d.scheduledTime.year}.',
        );
        cancelled++;
      }
      notifyListeners();
      if (cancelled == 0 && blocked == 0) return 'Marked unavailable.';
      if (blocked > 0) {
        return 'Marked unavailable. $cancelled donation(s) cancelled and '
            'recipients notified. $blocked donation(s) starting within 12 '
            'hours could not be cancelled.';
      }
      return 'Marked unavailable. $cancelled donation(s) cancelled and '
          'recipients notified.';
    }
    notifyListeners();
    return 'You are now marked as available.';
  }

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
    double? latitude,
    double? longitude,
    String? address,
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
        latitude: latitude ?? 23.81,
        longitude: longitude ?? 90.41,
        status: ListingStatus.active,
        category: category,
        distance: 0.1,
        imageBytes: imageBytes,
        address: address,
      ),
    );
    notifyListeners();
  }
}
