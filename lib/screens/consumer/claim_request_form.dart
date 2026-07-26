import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../widgets/ui/app_badge.dart';

/// Full-screen form shown after tapping "Claim Free" or "Buy Now" on a
/// marketplace listing. Collects the requester's details (name, contact,
/// pickup place, quantity) before the claim/purchase is confirmed.
///
/// The restaurant/donor name is shown prominently at the top of the page,
/// both in the app bar and in the listing summary card, so the user always
/// knows exactly which restaurant they're dealing with.
///
/// Usage (e.g. from a listing card's button):
///   Navigator.push(context, MaterialPageRoute(
///     builder: (_) => ClaimRequestForm(listing: listing),
///   ));
class ClaimRequestForm extends StatefulWidget {
  final Listing listing;
  const ClaimRequestForm({super.key, required this.listing});

  @override
  State<ClaimRequestForm> createState() => _ClaimRequestFormState();
}

class _ClaimRequestFormState extends State<ClaimRequestForm> {
  // Key used to validate all fields in the form at once on submit.
  final _formKey = GlobalKey<FormState>();

  // Text controllers for the requester's details.
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _placeController = TextEditingController();
  final _notesController = TextEditingController();

  // How many portions/units the user wants to claim or buy, capped by
  // however many are actually left on this listing.
  int _quantity = 1;
  late final int _maxQuantity = widget.listing.quantity < 1 ? 1 : widget.listing.quantity;

  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _placeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool get _isDonation => widget.listing.listingType == ListingType.donation;
  Color get _accentColor => _isDonation ? const Color(0xFF16A34A) : const Color(0xFFEA580C);
  Color get _accentTint => _isDonation ? const Color(0xFFDCFCE7) : const Color(0xFFFFE3CC);

  // Runs form validation, and if everything checks out, simulates
  // submitting the request and shows a success confirmation.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    // TODO: replace with a real API call (e.g. POST /requests) once the
    // backend endpoint is wired up. For now we just simulate a short delay.
    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;
    setState(() => _submitting = false);

    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(color: _accentTint, shape: BoxShape.circle),
                child: Icon(Icons.check_rounded, color: _accentColor, size: 34),
              ),
              const SizedBox(height: 16),
              Text(
                _isDonation ? 'Claim confirmed!' : 'Order placed!',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF121212)),
              ),
              const SizedBox(height: 8),
              Text(
                _isDonation
                    ? 'Your request to claim "${widget.listing.title}" from ${widget.listing.donorName} has been sent.'
                    : 'Your order for "${widget.listing.title}" from ${widget.listing.donorName} has been placed.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Color(0xFF757575)),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(); // close the dialog
                    Navigator.of(context).pop(); // return to the marketplace
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;
    final totalPrice = listing.price * _quantity;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      // App bar leads with the restaurant/donor name, per the requirement
      // that it be visible at the top of the page.
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF121212),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              listing.donorName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF121212)),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              _isDonation ? 'Claiming free food' : 'Buying surplus food',
              style: const TextStyle(fontSize: 11, color: Color(0xFF757575)),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---- Listing summary card ----
                      _ListingSummaryCard(listing: listing, accentColor: _accentColor, accentTint: _accentTint),
                      const SizedBox(height: 24),

                      // ---- Requester details ----
                      const _SectionLabel('Your Information'),
                      const SizedBox(height: 10),
                      _FormField(
                        controller: _nameController,
                        label: 'Full name',
                        hint: 'e.g. Rafi Ahmed',
                        icon: Icons.person_outline,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
                      ),
                      const SizedBox(height: 12),
                      _FormField(
                        controller: _phoneController,
                        label: 'Phone number',
                        hint: 'e.g. 01XXXXXXXXX',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Please enter a phone number';
                          if (v.trim().length < 6) return 'Enter a valid phone number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // ---- Pickup details ----
                      const _SectionLabel('Pickup Details'),
                      const SizedBox(height: 10),
                      _FormField(
                        controller: _placeController,
                        label: 'Pickup place / address',
                        hint: 'e.g. House 12, Road 5, Gulshan 1',
                        icon: Icons.place_outlined,
                        maxLines: 2,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a pickup location' : null,
                      ),
                      const SizedBox(height: 24),

                      // ---- Quantity ----
                      const _SectionLabel('Quantity'),
                      const SizedBox(height: 10),
                      _QuantityStepper(
                        quantity: _quantity,
                        max: _maxQuantity,
                        accentColor: _accentColor,
                        onChanged: (q) => setState(() => _quantity = q),
                      ),
                      const SizedBox(height: 6),
                      Text('$_maxQuantity available from this listing', style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                      const SizedBox(height: 24),

                      // ---- Optional notes ----
                      const _SectionLabel('Additional Notes (optional)'),
                      const SizedBox(height: 10),
                      _FormField(
                        controller: _notesController,
                        label: 'Notes for the restaurant',
                        hint: 'e.g. Preferred pickup time, allergies, etc.',
                        icon: Icons.edit_note_outlined,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),

            // ---- Bottom action bar: total + submit button ----
            _BottomActionBar(
              isDonation: _isDonation,
              totalPrice: totalPrice,
              accentColor: _accentColor,
              submitting: _submitting,
              onSubmit: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

// Card summarising which listing/restaurant this request is for — image,
// title, donor name, badges, and distance — shown at the top of the form.
class _ListingSummaryCard extends StatelessWidget {
  final Listing listing;
  final Color accentColor;
  final Color accentTint;
  const _ListingSummaryCard({required this.listing, required this.accentColor, required this.accentTint});

  @override
  Widget build(BuildContext context) {
    final isDonation = listing.listingType == ListingType.donation;
    final imageUrl = listing.imageUrl ??
        (isDonation
            ? 'https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=900&q=80'
            : 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=900&q=80');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E2E2)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.14), offset: const Offset(0, 4), blurRadius: 0)],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Thumbnail image.
          SizedBox(
            width: 100,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: accentTint),
                listing.imageBytes != null
                    ? Image.memory(listing.imageBytes!, fit: BoxFit.cover)
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          isDonation ? Icons.favorite_outline : Icons.local_offer_outlined,
                          color: accentColor,
                        ),
                      ),
              ],
            ),
          ),
          // Title, donor, distance, and price/free badge.
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(listing.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF121212)), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.storefront_outlined, size: 12, color: Color(0xFF757575)),
                    const SizedBox(width: 4),
                    Expanded(child: Text(listing.donorName, style: const TextStyle(fontSize: 12, color: Color(0xFF757575)), overflow: TextOverflow.ellipsis)),
                  ]),
                  const SizedBox(height: 6),
                  Row(children: [
                    AppBadge(label: isDonation ? 'FREE' : '৳${listing.price.toInt()}', variant: isDonation ? BadgeVariant.green : BadgeVariant.orange),
                    const SizedBox(width: 8),
                    const Icon(Icons.location_on, size: 12, color: Color(0xFF757575)),
                    const SizedBox(width: 2),
                    Text('${listing.distance} km', style: const TextStyle(fontSize: 11, color: Color(0xFF757575))),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Small uppercase-ish section heading used above each group of fields.
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF121212)));
  }
}

// Reusable styled text field with a label, leading icon, and validator,
// matching the rounded/bordered look used across the rest of the app.
class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF525252))),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 13, color: Color(0xFF121212)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFBFBFBF)),
            prefixIcon: Padding(
              padding: EdgeInsets.only(bottom: maxLines > 1 ? (maxLines - 1) * 20.0 : 0),
              child: Icon(icon, size: 18, color: const Color(0xFF757575)),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E2E2))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E2E2))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF16A34A), width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.redAccent)),
          ),
        ),
      ],
    );
  }
}

// Plus/minus quantity picker used to choose how many portions to claim/buy.
class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final int max;
  final Color accentColor;
  final ValueChanged<int> onChanged;

  const _QuantityStepper({required this.quantity, required this.max, required this.accentColor, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E2E2)),
      ),
      child: Row(
        children: [
          _StepperButton(
            icon: Icons.remove,
            enabled: quantity > 1,
            accentColor: accentColor,
            onTap: () => onChanged(quantity - 1),
          ),
          Expanded(
            child: Center(
              child: Text('$quantity', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF121212))),
            ),
          ),
          _StepperButton(
            icon: Icons.add,
            enabled: quantity < max,
            accentColor: accentColor,
            onTap: () => onChanged(quantity + 1),
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final Color accentColor;
  final VoidCallback onTap;
  const _StepperButton({required this.icon, required this.enabled, required this.accentColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: enabled ? onTap : null,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: enabled ? accentColor.withValues(alpha: 0.1) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: enabled ? accentColor : const Color(0xFFBFBFBF)),
      ),
    );
  }
}

// Sticky bottom bar showing the running total (or "Free") and the final
// confirm button, so it's always visible while scrolling the form.
class _BottomActionBar extends StatelessWidget {
  final bool isDonation;
  final double totalPrice;
  final Color accentColor;
  final bool submitting;
  final VoidCallback onSubmit;

  const _BottomActionBar({
    required this.isDonation,
    required this.totalPrice,
    required this.accentColor,
    required this.submitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total', style: TextStyle(fontSize: 11, color: Color(0xFF757575))),
                  Text(
                    isDonation ? 'Free' : '৳${totalPrice.toInt()}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: accentColor),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 180,
              child: ElevatedButton(
                onPressed: submitting ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: submitting
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(isDonation ? 'Confirm Claim' : 'Confirm Order', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}