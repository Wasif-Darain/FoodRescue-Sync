import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/app_button.dart';
import '../../widgets/ui/date_time_field.dart';

class BulkRequest extends StatefulWidget {
  const BulkRequest({super.key});

  @override
  State<BulkRequest> createState() => _BulkRequestState();
}

class _BulkRequestState extends State<BulkRequest> {
  final _items = <_RequestItem>[_RequestItem()];
  DateTime _requiredDate = DateTime.now();

  Future<void> _pickRequiredDate() async {
    final picked = await pickDateTime(context, initial: _requiredDate);
    if (picked != null) setState(() => _requiredDate = picked);
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
                  _FormField(label: 'Organization Name', placeholder: 'Your NGO or food bank name'),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _FormField(label: 'Contact Person', placeholder: 'Full name')),
                    const SizedBox(width: 12),
                    Expanded(child: _FormField(label: 'Phone', placeholder: '+880 XXXX XXXXXX', keyboardType: TextInputType.phone)),
                  ]),
                  const SizedBox(height: 12),
                  _FormField(label: 'Delivery / Pickup Address', placeholder: 'Full address'),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: DateTimeField(label: 'Required Date & Time', value: _requiredDate, onTap: _pickRequiredDate)),
                    const SizedBox(width: 12),
                    Expanded(child: _FormField(label: 'People to Feed', placeholder: '0', keyboardType: TextInputType.number)),
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
                      Expanded(flex: 3, child: _FormField(label: '', placeholder: 'Food item name')),
                      const SizedBox(width: 10),
                      Expanded(child: _FormField(label: '', placeholder: 'Qty', keyboardType: TextInputType.number)),
                      const SizedBox(width: 10),
                      Expanded(child: _FormField(label: '', placeholder: 'Unit (kg/pcs)')),
                      if (_items.length > 1) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => setState(() => _items.removeAt(e.key)),
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
                  _FormField(label: '', placeholder: 'Any dietary restrictions, special requirements, or notes...', maxLines: 4),
                ]),
              ),
            ),
            const SizedBox(height: 24),
            Row(children: [
              _HoverScale(child: AppButton(label: 'Cancel', outlined: true, onPressed: () => context.go('/consumer'))),
              const SizedBox(width: 12),
              _HoverScale(
                child: AppButton(
                  label: 'Submit Request',
                  icon: const Icon(Icons.send, size: 16),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Bulk request submitted successfully!'),
                      backgroundColor: Color(0xFF16A34A),
                    ));
                    context.go('/consumer/requests');
                  },
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _RequestItem {}

class _FormField extends StatelessWidget {
  final String label;
  final String placeholder;
  final int maxLines;
  final TextInputType? keyboardType;
  const _FormField({required this.label, required this.placeholder, this.maxLines = 1, this.keyboardType});

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
