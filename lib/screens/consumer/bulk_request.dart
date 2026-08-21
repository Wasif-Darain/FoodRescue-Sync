import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/app_button.dart';
import '../../widgets/ui/date_time_field.dart';
import '../../providers/consumer_provider.dart';

class BulkRequest extends StatefulWidget {
  const BulkRequest({super.key});

  @override
  State<BulkRequest> createState() => _BulkRequestState();
}

class _BulkRequestState extends State<BulkRequest> {
  final _orgCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _peopleCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _items = <_RequestItem>[_RequestItem()];
  DateTime _requiredDate = DateTime.now();
  bool _submitting = false;

  @override
  void dispose() {
    _orgCtrl.dispose();
    _contactCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _peopleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickRequiredDate() async {
    final picked = await pickDateTime(context, initial: _requiredDate);
    if (picked != null) setState(() => _requiredDate = picked);
  }

  Future<void> _submit() async {
    final org = _orgCtrl.text.trim();
    final contact = _contactCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final address = _addressCtrl.text.trim();
    final people = int.tryParse(_peopleCtrl.text.trim()) ?? 0;

    if (org.isEmpty || contact.isEmpty || phone.isEmpty || address.isEmpty || people <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fill in all required fields.'),
        backgroundColor: Color(0xFFDC2626),
      ));
      return;
    }

    final items = _items
        .where((i) => i.nameCtrl.text.trim().isNotEmpty)
        .map((i) => {
              'name': i.nameCtrl.text.trim(),
              'quantity': i.qtyCtrl.text.trim(),
              'unit': i.unitCtrl.text.trim(),
            })
        .toList();

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Add at least one food item.'),
        backgroundColor: Color(0xFFDC2626),
      ));
      return;
    }

    setState(() => _submitting = true);
    final consumer = context.read<ConsumerProvider>();
    final error = await consumer.submitBulkRequest(
      orgName: org,
      contactPerson: contact,
      phone: phone,
      address: address,
      requiredDate: _requiredDate,
      peopleToFeed: people,
      items: items,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error),
        backgroundColor: const Color(0xFFDC2626),
      ));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Bulk request submitted successfully!'),
      backgroundColor: Color(0xFF16A34A),
    ));
    context.go('/consumer/requests');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppLayout(
      title: 'Bulk Request',
      subtitle: 'Submit large-scale food requests for your organization',
      currentRoute: '/consumer/bulk-request',
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HoverScale(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14), offset: const Offset(0, 4), blurRadius: 0)],),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Organization Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF121212))),
                  const SizedBox(height: 16),
                  _FormField(label: 'Organization Name', placeholder: 'Your NGO or food bank name', controller: _orgCtrl),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _FormField(label: 'Contact Person', placeholder: 'Full name', controller: _contactCtrl)),
                    const SizedBox(width: 12),
                    Expanded(child: _FormField(label: 'Phone', placeholder: '+880 XXXX XXXXXX', keyboardType: TextInputType.phone, controller: _phoneCtrl)),
                  ]),
                  const SizedBox(height: 12),
                  _FormField(label: 'Delivery / Pickup Address', placeholder: 'Full address', controller: _addressCtrl),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: DateTimeField(label: 'Required Date & Time', value: _requiredDate, onTap: _pickRequiredDate)),
                    const SizedBox(width: 12),
                    Expanded(child: _FormField(label: 'People to Feed', placeholder: '0', keyboardType: TextInputType.number, controller: _peopleCtrl)),
                  ]),
                ]),
              ),
            ),
            const SizedBox(height: 20),
            _HoverScale(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14), offset: const Offset(0, 4), blurRadius: 0)],),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Food Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF121212))),
                    _HoverScale(
                      child: TextButton.icon(
                        onPressed: () => setState(() => _items.add(_RequestItem())),
                        icon: const Icon(Icons.add, size: 14),
                        label: const Text('Add Item', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  ..._items.asMap().entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(children: [
                      Expanded(flex: 3, child: _FormField(label: '', placeholder: 'Food item name', controller: e.value.nameCtrl)),
                      const SizedBox(width: 10),
                      Expanded(child: _FormField(label: '', placeholder: 'Qty', keyboardType: TextInputType.number, controller: e.value.qtyCtrl)),
                      const SizedBox(width: 10),
                      Expanded(child: _FormField(label: '', placeholder: 'Unit (kg/pcs)', controller: e.value.unitCtrl)),
                      if (_items.length > 1) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            e.value.dispose();
                            setState(() => _items.removeAt(e.key));
                          },
                          icon: const Icon(Icons.remove_circle_outline, color: Color(0xFFEF4444), size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ]),
                  )),
                ]),
              ),
            ),
            const SizedBox(height: 20),
            _HoverScale(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14), offset: const Offset(0, 4), blurRadius: 0)],),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Additional Notes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF121212))),
                  const SizedBox(height: 12),
                  _FormField(label: '', placeholder: 'Any dietary restrictions, special requirements, or notes...', maxLines: 4, controller: _notesCtrl),
                ]),
              ),
            ),
            const SizedBox(height: 24),
            Row(children: [
              _HoverScale(child: AppButton(label: 'Cancel', outlined: true, onPressed: () => context.go('/consumer'))),
              const SizedBox(width: 12),
              _HoverScale(
                child: AppButton(
                  label: _submitting ? 'Submitting...' : 'Submit Request',
                  icon: const Icon(Icons.send, size: 16),
                  onPressed: _submitting ? null : _submit,
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _RequestItem {
  final nameCtrl = TextEditingController();
  final qtyCtrl = TextEditingController();
  final unitCtrl = TextEditingController();

  void dispose() {
    nameCtrl.dispose();
    qtyCtrl.dispose();
    unitCtrl.dispose();
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final String placeholder;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  const _FormField({required this.label, required this.placeholder, this.maxLines = 1, this.keyboardType, this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF525252))),
          const SizedBox(height: 4),
        ],
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFFBFBFBF), fontSize: 12),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: true,
            fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF16A34A), width: 2)),
          ),
          style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF121212)),
        ),
      ],
    );
  }
}

class _HoverScale extends StatefulWidget {
  final Widget child;
  const _HoverScale({required this.child});

  @override
  State<_HoverScale> createState() => _HoverScaleState();
}

class _HoverScaleState extends State<_HoverScale> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          scale: (_hovered || _pressed) ? 1.02 : 1.0,
          child: widget.child,
        ),
      ),
    );
  }
}