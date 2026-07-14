import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/app_button.dart';

class BulkRequest extends StatefulWidget {
  const BulkRequest({super.key});

  @override
  State<BulkRequest> createState() => _BulkRequestState();
}

class _BulkRequestState extends State<BulkRequest> {
  final _items = <_RequestItem>[_RequestItem()];

  @override
  Widget build(BuildContext context) {
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
                decoration: BoxDecoration(color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.14), offset: const Offset(0, 4), blurRadius: 0)],),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Organization Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF121212))),
                  const SizedBox(height: 16),
                  const _FormField(label: 'Organization Name', placeholder: 'Your NGO or food bank name'),
                  const SizedBox(height: 12),
                  Row(children: const [
                    Expanded(child: _FormField(label: 'Contact Person', placeholder: 'Full name')),
                    SizedBox(width: 12),
                    Expanded(child: _FormField(label: 'Phone', placeholder: '+880 XXXX XXXXXX', keyboardType: TextInputType.phone)),
                  ]),
                  const SizedBox(height: 12),
                  const _FormField(label: 'Delivery / Pickup Address', placeholder: 'Full address'),
                  const SizedBox(height: 12),
                  Row(children: const [
                    Expanded(child: _FormField(label: 'Required Date', placeholder: 'YYYY-MM-DD')),
                    SizedBox(width: 12),
                    Expanded(child: _FormField(label: 'People to Feed', placeholder: '0', keyboardType: TextInputType.number)),
                  ]),
                ]),
              ),
            ),
            const SizedBox(height: 20),
            _HoverScale(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.14), offset: const Offset(0, 4), blurRadius: 0)],),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Food Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF121212))),
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
                      Expanded(flex: 3, child: const _FormField(label: '', placeholder: 'Food item name')),
                      const SizedBox(width: 10),
                      Expanded(child: const _FormField(label: '', placeholder: 'Qty', keyboardType: TextInputType.number)),
                      const SizedBox(width: 10),
                      Expanded(child: const _FormField(label: '', placeholder: 'Unit (kg/pcs)')),
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
                decoration: BoxDecoration(color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.14), offset: const Offset(0, 4), blurRadius: 0)],),
                child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Additional Notes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF121212))),
                  SizedBox(height: 12),
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
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (label.isNotEmpty) ...[
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF525252))),
        const SizedBox(height: 4),
      ],
      TextField(
        maxLines: maxLines,
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
