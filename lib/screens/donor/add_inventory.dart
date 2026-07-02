import 'package:flutter/material.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/app_badge.dart';
import '../../widgets/ui/app_button.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';

class AddInventory extends StatelessWidget {
  const AddInventory({super.key});

  @override
  Widget build(BuildContext context) {
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
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF3F4F6))),
            child: Row(
              children: [
                const Icon(Icons.search, color: Color(0xFF9CA3AF), size: 18),
                const SizedBox(width: 10),
                const Expanded(child: TextField(
                  decoration: InputDecoration(hintText: 'Search inventory...', border: InputBorder.none, hintStyle: TextStyle(color: Color(0xFFD1D5DB), fontSize: 13)),
                )),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE5E7EB))),
                  child: const Row(children: [Icon(Icons.filter_list, size: 14, color: Color(0xFF6B7280)), SizedBox(width: 4), Text('Filter', style: TextStyle(fontSize: 12, color: Color(0xFF374151)))]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Table
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF3F4F6))),
            child: Column(
              children: [
                _TableHeader(),
                ...mockInventory.map((item) => _InventoryRow(item: item)),
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

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    decoration: const BoxDecoration(color: Color(0xFFF9FAFB), borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))),
    child: const Row(
      children: [
        Expanded(flex: 3, child: Text('Item Name', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)))),
        Expanded(flex: 2, child: Text('Category', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)))),
        Expanded(child: Text('Qty', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)))),
        Expanded(flex: 2, child: Text('Expiry Date', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)))),
        Expanded(child: Text('Status', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)))),
      ],
    ),
  );
}

class _InventoryRow extends StatelessWidget {
  final InventoryItem item;
  const _InventoryRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final diff = item.expiryDate.difference(now);
    final isExpiringSoon = diff.inDays < 2 && diff.inSeconds > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFF3F4F6)))),
      child: Row(
        children: [
          Expanded(flex: 3, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF111827))),
              if (item.barcode != null && item.barcode!.isNotEmpty)
                Text(item.barcode!, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
            ],
          )),
          Expanded(flex: 2, child: Text(item.category, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)))),
          Expanded(child: Text('${item.quantity}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
          Expanded(flex: 2, child: Text(
            '${item.expiryDate.year}-${item.expiryDate.month.toString().padLeft(2, '0')}-${item.expiryDate.day.toString().padLeft(2, '0')}',
            style: TextStyle(fontSize: 13, color: isExpiringSoon ? const Color(0xFFEF4444) : const Color(0xFF374151)),
          )),
          Expanded(child: AppBadge(
            label: item.isSurplus ? 'Surplus' : 'Normal',
            variant: item.isSurplus ? BadgeVariant.orange : BadgeVariant.green,
          )),
        ],
      ),
    );
  }
}

class _AddItemDialog extends StatelessWidget {
  const _AddItemDialog();

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Add Inventory Item', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    content: SizedBox(
      width: 400,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _DialogField(label: 'Item Name', placeholder: 'e.g. Basmati Rice'),
        const SizedBox(height: 12),
        _DialogField(label: 'Barcode (optional)', placeholder: 'Scan or enter barcode'),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _DialogField(label: 'Quantity', placeholder: '0', keyboardType: TextInputType.number)),
          const SizedBox(width: 12),
          Expanded(child: _DialogField(label: 'Category', placeholder: 'e.g. Grains')),
        ]),
        const SizedBox(height: 12),
        _DialogField(label: 'Expiry Date', placeholder: 'YYYY-MM-DD'),
      ]),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white, elevation: 0),
        child: const Text('Add Item'),
      ),
    ],
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );
}

class _DialogField extends StatelessWidget {
  final String label;
  final String placeholder;
  final TextInputType? keyboardType;
  const _DialogField({required this.label, required this.placeholder, this.keyboardType});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF374151))),
      const SizedBox(height: 4),
      TextField(
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 12),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF16A34A), width: 2)),
        ),
        style: const TextStyle(fontSize: 13),
      ),
    ],
  );
}
