import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/app_badge.dart';
import '../../widgets/ui/app_button.dart';
import '../../widgets/ui/date_time_field.dart';
import '../../widgets/ui/image_thumbnail.dart';
import '../../widgets/ui/photo_picker_row.dart';
import '../../models/models.dart';
import '../../providers/donor_provider.dart';

class AddInventory extends StatelessWidget {
  const AddInventory({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inventory = context.watch<DonorProvider>().inventory;

    return AppLayout(
      title: 'Inventory',
      subtitle: 'Manage your food stock and mark surplus items',
      currentRoute: '/donor/inventory',
      action: AppButton(
        label: 'Add Item',
        icon: const Icon(Icons.add, size: 16),
        onPressed: () => _showAddDialog(context),
      ),
      child: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14), offset: const Offset(0, 4), blurRadius: 0)],),
            child: Row(
              children: [
                Icon(Icons.search, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575), size: 18),
                const SizedBox(width: 10),
                Expanded(child: TextField(
                  decoration: InputDecoration(hintText: 'Search inventory...', border: InputBorder.none, hintStyle: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFFBFBFBF), fontSize: 13)),
                )),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(8), border: Border.all(color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2))),
                  child: Row(children: [Icon(Icons.filter_list, size: 14, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)), const SizedBox(width: 4), Text('Filter', style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF525252)))]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // List
          Container(
            decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14), offset: const Offset(0, 4), blurRadius: 0)],),
            child: Column(
              children: [
                for (final item in inventory) _InventoryRow(item: item),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => const _AddItemDialog());
  }
}

class _InventoryRow extends StatelessWidget {
  final InventoryItem item;
  const _InventoryRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final diff = item.expiryDate.difference(now);
    final isExpiringSoon = diff.inDays < 2 && diff.inSeconds > 0;
    final expiry = '${item.expiryDate.year}-${item.expiryDate.month.toString().padLeft(2, '0')}-${item.expiryDate.day.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2)))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ImageThumbnail(imageUrl: item.imageUrl, imageBytes: item.imageBytes),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(item.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF121212)), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    AppBadge(
                      label: item.isSurplus ? 'Surplus' : 'Normal',
                      variant: item.isSurplus ? BadgeVariant.orange : BadgeVariant.green,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.category} · Qty: ${item.quantity} · Exp: $expiry',
                  style: TextStyle(fontSize: 12, color: isExpiringSoon ? const Color(0xFFEF4444) : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575))),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddItemDialog extends StatefulWidget {
  const _AddItemDialog();

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  final _nameCtrl = TextEditingController();
  final _barcodeCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  bool _isSurplus = false;
  Uint8List? _imageBytes;
  DateTime? _expiryDate;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _barcodeCtrl.dispose();
    _quantityCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickExpiry() async {
    final picked = await pickDateTime(context, initial: _expiryDate);
    if (picked != null) setState(() => _expiryDate = picked);
  }

  void _submit() {
    if (_nameCtrl.text.trim().isEmpty) return;
    final expiry = _expiryDate ?? DateTime.now().add(const Duration(days: 3));

    context.read<DonorProvider>().addInventoryItem(
      name: _nameCtrl.text.trim(),
      barcode: _barcodeCtrl.text.trim().isEmpty ? null : _barcodeCtrl.text.trim(),
      quantity: int.tryParse(_quantityCtrl.text.trim()) ?? 1,
      category: _categoryCtrl.text.trim().isEmpty ? 'Other' : _categoryCtrl.text.trim(),
      expiryDate: expiry,
      isSurplus: _isSurplus,
      imageBytes: _imageBytes,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Add Inventory Item', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    content: SizedBox(
      width: MediaQuery.of(context).size.width < 460 ? double.maxFinite : 400,
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _DialogField(label: 'Item Name', placeholder: 'e.g. Basmati Rice', controller: _nameCtrl),
          const SizedBox(height: 12),
          _DialogField(label: 'Barcode (optional)', placeholder: 'Scan or enter barcode', controller: _barcodeCtrl),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _DialogField(label: 'Quantity', placeholder: '0', keyboardType: TextInputType.number, controller: _quantityCtrl)),
            const SizedBox(width: 12),
            Expanded(child: _DialogField(label: 'Category', placeholder: 'e.g. Grains', controller: _categoryCtrl)),
          ]),
          const SizedBox(height: 12),
          DateTimeField(label: 'Expiry Date & Time', value: _expiryDate, onTap: _pickExpiry),
          const SizedBox(height: 12),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Photo (optional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF525252))),
          ),
          const SizedBox(height: 6),
          PhotoPickerRow(imageBytes: _imageBytes, onChanged: (bytes) => setState(() => _imageBytes = bytes)),
          const SizedBox(height: 4),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Shown on this item and on the consumer marketplace if marked surplus.', style: TextStyle(fontSize: 11, color: Color(0xFF757575))),
          ),
          const SizedBox(height: 12),
          Material(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => setState(() => _isSurplus = !_isSurplus),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(children: [
                  Checkbox(
                    value: _isSurplus,
                    activeColor: const Color(0xFF16A34A),
                    onChanged: (v) => setState(() => _isSurplus = v ?? false),
                  ),
                  const Expanded(
                    child: Text('Mark as surplus — instantly lists it (with photo) on the consumer marketplace', style: TextStyle(fontSize: 12, color: Color(0xFF525252))),
                  ),
                ]),
              ),
            ),
          ),
        ]),
      ),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      ElevatedButton(
        onPressed: _submit,
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF121212), foregroundColor: Colors.white, elevation: 0),
        child: const Text('Add Item'),
      ),
    ],
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  );
}

class _DialogField extends StatelessWidget {
  final String label;
  final String placeholder;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  const _DialogField({required this.label, required this.placeholder, this.keyboardType, this.controller});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF525252))),
      const SizedBox(height: 4),
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: const TextStyle(color: Color(0xFFBFBFBF), fontSize: 12),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E2E2))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E2E2))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF16A34A), width: 2)),
        ),
        style: const TextStyle(fontSize: 13),
      ),
    ],
  );
}
