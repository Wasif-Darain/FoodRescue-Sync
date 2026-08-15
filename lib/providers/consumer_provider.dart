import 'package:flutter/foundation.dart';
import '../models/models.dart';

/// Owns the consumer's placed orders for paid (flash sale) listings.
class ConsumerProvider extends ChangeNotifier {
  final List<PaidOrder> _orders = [];
  int _nextOrderId = 1;

  List<PaidOrder> get orders => List.unmodifiable(_orders);

  PaidOrder placeOrder({
    required Listing listing,
    required int consumerId,
    required String consumerName,
    required PaymentMethod paymentMethod,
    required PickupPreference deliveryOption,
    required String deliveryLocation,
  }) {
    final order = PaidOrder(
      id: _nextOrderId++,
      listingId: listing.id,
      listingTitle: listing.title,
      donorName: listing.donorName,
      consumerId: consumerId,
      consumerName: consumerName,
      quantity: listing.quantity,
      unitPrice: listing.price,
      paymentMethod: paymentMethod,
      deliveryOption: deliveryOption,
      deliveryLocation: deliveryLocation,
      placedAt: DateTime.now(),
    );
    _orders.insert(0, order);
    notifyListeners();
    return order;
  }
}
