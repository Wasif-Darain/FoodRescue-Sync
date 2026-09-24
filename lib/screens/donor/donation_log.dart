import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import '../../services/listing_image_manager.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/app_button.dart';
import '../../widgets/ui/date_time_field.dart';
import '../../widgets/ui/photo_picker_row.dart';
import '../../widgets/ui/location_picker.dart';
import '../../models/models.dart';
import '../../providers/donor_provider.dart';
import '../../l10n/l10n_ext.dart';
import '../../l10n/gen/app_localizations.dart';

/// Form screen where a donor creates a new listing – either a free
/// "donation" or a paid "flash sale". Collects title, description, photos
/// (up to 5), category, quantity, optional price, pickup window and location.
class CreateListing extends StatefulWidget {
  const CreateListing({super.key});

  @override
  State<CreateListing> createState() => _CreateListingState();
}

class _CreateListingState extends State<CreateListing> {
  /// 'donation' (free) or 'flash_sale' (priced).
  String _listingType = 'donation';

  /// Selected category key (stored value, not the localized label).
  String _category = 'Cooked Meals';

  /// Photos chosen so far (saved as temp files until upload on submit).
  final List<File> _images = [];

  /// Pickup window. Defaults to "now" through three hours from now.
  DateTime _pickupStart = DateTime.now();
  DateTime _pickupEnd = DateTime.now().add(const Duration(hours: 3));

  // Text inputs.
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  /// Pickup location chosen via the map picker (all null until picked).
  double? _pickupLat;
  double? _pickupLng;
  String? _pickupAddress;

  /// Category options as (storedKey, localizedLabel) pairs.
  List<(String, String)> _categories(AppLocalizations t) => [
    ('Cooked Meals', t.catCookedMeals),
    ('Bakery', t.catBakery),
    ('Dairy', t.catDairy),
    ('Produce', t.catProduce),
    ('Grains', t.catGrains),
    ('Pulses', t.catPulses),
    ('Other', t.catOther),
  ];

  @override
  void dispose() {
    // Release the text controllers.
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _quantityCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  /// Opens the map picker (pre-filled with any earlier choice) and stores the
  /// selected coordinates and address. Cancelling leaves values untouched.
  Future<void> _pickPickupLocation() async {
    final picked = await pickLocation(
      context,
      initial: _pickupLat != null && _pickupLng != null
          ? LatLng(_pickupLat!, _pickupLng!)
          : null,
      initialAddress: _pickupAddress,
    );
    if (picked == null) return;
    setState(() {
      _pickupLat = picked.lat;
      _pickupLng = picked.lng;
      _pickupAddress = picked.address;
    });
  }

  /// Picks the pickup start. If the end is no longer after the new start,
  /// the end is pushed to start + 3 hours to keep the window valid.
  Future<void> _pickPickupStart() async {
    final picked = await pickDateTime(context, initial: _pickupStart, defaultTime: const TimeOfDay(hour: 18, minute: 0));
    if (picked == null) return;
    setState(() {
      _pickupStart = picked;
      if (!_pickupEnd.isAfter(picked)) {
        _pickupEnd = picked.add(const Duration(hours: 3));
      }
    });
  }

  /// Picks the pickup end. An end that isn't after the start is replaced by
  /// start + 3 hours.
  Future<void> _pickPickupEnd() async {
    final picked = await pickDateTime(context, initial: _pickupEnd.isAfter(_pickupStart) ? _pickupEnd : _pickupStart.add(const Duration(hours: 3)), defaultTime: const TimeOfDay(hour: 21, minute: 0));
    if (picked == null) return;
    setState(() => _pickupEnd = picked.isAfter(_pickupStart) ? picked : _pickupStart.add(const Duration(hours: 3)));
  }

  /// Validates (title is required), creates the listing, uploads any photos
  /// and attaches their URLs, then confirms and returns to the donor home.
  Future<void> _submit() async {
    // Only the title is mandatory; silently ignore the tap without it.
    if (_titleCtrl.text.trim().isEmpty) return;

    final donor = context.read<DonorProvider>();
    final t = context.l10n;
    final listingId = await donor.createListing(
      title: _titleCtrl.text.trim(),
      // Use a placeholder text when the description is left empty.
      description: _descCtrl.text.trim().isEmpty
          ? t.createListingNoDetails
          : _descCtrl.text.trim(),
      category: _category,
      // Non-numeric / empty quantity falls back to 1.
      quantity: int.tryParse(_quantityCtrl.text.trim()) ?? 1,
      listingType: _listingType == 'donation'
          ? ListingType.donation
          : ListingType.flashSale,
      // Donations are always free; flash sales use the entered price (or 0).
      price: _listingType == 'flash_sale'
          ? (double.tryParse(_priceCtrl.text.trim()) ?? 0)
          : 0,
      pickupStart: _pickupStart,
      pickupEnd: _pickupEnd,
      latitude: _pickupLat,
      longitude: _pickupLng,
      address: _pickupAddress,
    );

    // Photos are uploaded after the listing exists, then linked to it.
    if (listingId != null && _images.isNotEmpty) {
      final imageManager = ListingImageManager();
      final urls = <String>[];
      for (final image in _images) {
        urls.add(await imageManager.uploadListingImage(image));
      }
      await donor.updateListingPhotoUrls(listingId, urls);
    }

    // Screen may have been closed during the async work above.
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t.createListingSuccess),
        backgroundColor: const Color(0xFF16A34A),
      ),
    );
    context.go('/donor');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = context.l10n;
    return AppLayout(
      title: t.createListingTitle,
      subtitle: t.createListingSubtitle,
      currentRoute: '/donor/create-listing',
      // Cap the form width so it stays readable on wide screens.
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(16),
            // Hard-edged offset shadow (blurRadius 0): the app's card style.
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14),
                offset: const Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Listing type toggle (donation vs flash sale)
              _Label(t.createListingType),
              const SizedBox(height: 8),
              Row(
                children: [
                  _TypeToggle(
                    label: t.createListingDonationFree,
                    icon: Icons.favorite_outline,
                    value: 'donation',
                    selected: _listingType,
                    onTap: (v) => setState(() => _listingType = v),
                  ),
                  const SizedBox(width: 12),
                  _TypeToggle(
                    label: t.createListingFlashSale,
                    icon: Icons.local_offer_outlined,
                    value: 'flash_sale',
                    selected: _listingType,
                    onTap: (v) => setState(() => _listingType = v),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Title (required).
              _FormField(
                label: t.createListingTitleLabel,
                placeholder: t.createListingTitleHint,
                controller: _titleCtrl,
              ),
              const SizedBox(height: 16),
              // Description (optional, multi-line).
              _FormField(
                label: t.createListingDescription,
                placeholder: t.createListingDescriptionHint,
                maxLines: 3,
                controller: _descCtrl,
              ),
              const SizedBox(height: 16),
              // ---- Photos (optional, max 5) ----
              _Label(t.createListingPhotoOptional),
              const SizedBox(height: 6),
              // Thumbnails of chosen photos, each with a remove button.
              if (_images.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (var i = 0; i < _images.length; i++)
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(_images[i], width: 56, height: 56, fit: BoxFit.cover),
                            ),
                            // Small red "x" in the top-right corner.
                            Positioned(
                              top: -6,
                              right: -6,
                              child: IconButton(
                                icon: const Icon(Icons.cancel, size: 18, color: Color(0xFFDC2626)),
                                onPressed: () => setState(() => _images.removeAt(i)),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              // The picker is hidden once the 5-photo limit is reached.
              if (_images.length < 5)
                PhotoPickerRow(
                  imageBytes: null,
                  onChanged: (bytes) {
                    if (bytes == null) return;
                    // Write the picked bytes to a temp .jpg so the upload
                    // manager can work with a File later.
                    final tempDir = Directory.systemTemp;
                    final tempFile = File(
                      '${tempDir.path}/listing_${DateTime.now().millisecondsSinceEpoch}.jpg',
                    );
                    tempFile.writeAsBytesSync(bytes);
                    setState(() => _images.add(tempFile));
                  },
                ),
              const SizedBox(height: 4),
              Text(
                t.createListingPhotoHint,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF757575),
                ),
              ),
              const SizedBox(height: 16),
              // ---- Category dropdown + quantity, side by side ----
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Label(t.createListingCategory),
                        const SizedBox(height: 6),
                        // Bordered box so the dropdown matches the text fields.
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF3F3F46)
                                  : const Color(0xFFE2E2E2),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButton<String>(
                            value: _category,
                            isExpanded: true,
                            underline: const SizedBox(),
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? const Color(0xFF9CA3AF)
                                  : const Color(0xFF525252),
                            ),
                            dropdownColor: isDark
                                ? const Color(0xFF2A2A2A)
                                : Colors.white,
                            items: _categories(t)
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c.$1,
                                    child: Text(c.$2),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _category = v ?? _category),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _FormField(
                      label: t.createListingQuantity,
                      placeholder: '0',
                      keyboardType: TextInputType.number,
                      controller: _quantityCtrl,
                    ),
                  ),
                ],
              ),
              // Price field only appears for flash sales.
              if (_listingType == 'flash_sale') ...[
                const SizedBox(height: 16),
                _FormField(
                  label: t.createListingPrice,
                  placeholder: '0',
                  keyboardType: TextInputType.number,
                  controller: _priceCtrl,
                ),
              ],
              const SizedBox(height: 16),
              // ---- Pickup window (start / end) ----
              Row(
                children: [
                  Expanded(
                    child: DateTimeField(
                      label: t.createListingPickupStart,
                      value: _pickupStart,
                      onTap: _pickPickupStart,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DateTimeField(
                      label: t.createListingPickupEnd,
                      value: _pickupEnd,
                      onTap: _pickPickupEnd,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // ---- Pickup location: tap to open the map picker ----
              _Label(t.createListingPickupLocation),
              const SizedBox(height: 6),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: _pickPickupLocation,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF3F3F46)
                          : const Color(0xFFE2E2E2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: isDark
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF757575),
                      ),
                      const SizedBox(width: 8),
                      // Chosen address, or a grey "tap to pick" placeholder.
                      Expanded(
                        child: Text(
                          _pickupAddress ?? t.editProfileNotSetTapToPick,
                          style: TextStyle(
                            fontSize: 13,
                            color: _pickupAddress == null
                                ? const Color(0xFFBFBFBF)
                                : (isDark
                                      ? Colors.white
                                      : const Color(0xFF121212)),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.edit_outlined,
                        size: 15,
                        color: isDark
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF757575),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              // ---- Actions: Cancel + Post ----
              Row(
                children: [
                  AppButton(
                    label: t.createListingCancel,
                    outlined: true,
                    onPressed: () => context.go('/donor'),
                  ),
                  const SizedBox(width: 12),
                  // Label changes with the selected listing type.
                  AppButton(
                    label: _listingType == 'donation'
                        ? t.createListingPostDonation
                        : t.createListingPostFlashSale,
                    icon: const Icon(Icons.check, size: 16),
                    onPressed: _submit,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One option of the donation / flash-sale switch. The selected option is
/// tinted with its color (green for donation, orange for flash sale).
class _TypeToggle extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final String selected;
  final ValueChanged<String> onTap;
  const _TypeToggle({
    required this.label,
    required this.icon,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = value == selected;
    final color = value == 'donation'
        ? const Color(0xFF16A34A)
        : const Color(0xFFEA580C);
    // Neutral colors for the unselected state, adapted to the theme.
    final idleBg = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0F0);
    final idleBorder = isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2);
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(value),
        // AnimatedContainer gives a smooth transition when switching.
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.08)
                : idleBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color : idleBorder,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? color : const Color(0xFF757575),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? color : const Color(0xFF757575),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small field label shown above inputs.
class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: Color(0xFF525252),
    ),
  );
}

/// Labelled text input with the app's rounded outline style; the border turns
/// green (thicker) when focused.
class _FormField extends StatelessWidget {
  final String label;
  final String placeholder;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  const _FormField({
    required this.label,
    required this.placeholder,
    this.maxLines = 1,
    this.keyboardType,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Idle border adapts to the theme so it stays visible in dark mode.
    final idleBorder = isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(color: Color(0xFFBFBFBF), fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: idleBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: idleBorder),
            ),
            // Green highlight while the field has focus.
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF16A34A), width: 2),
            ),
          ),
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }
}