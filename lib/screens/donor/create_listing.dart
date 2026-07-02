import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/app_button.dart';

class CreateListing extends StatefulWidget {
  const CreateListing({super.key});

  @override
  State<CreateListing> createState() => _CreateListingState();
}

class _CreateListingState extends State<CreateListing> {
  String _listingType = 'donation';
  String _category = 'Cooked Meals';

  final _categories = ['Cooked Meals', 'Bakery', 'Dairy', 'Produce', 'Grains', 'Pulses', 'Other'];

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'Create Listing',
      subtitle: 'List your surplus food for donation or flash sale',
      currentRoute: '/donor/create-listing',
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF3F4F6))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Listing type toggle
              const _Label('Listing Type'),
              const SizedBox(height: 8),
              Row(children: [
                _TypeToggle(label: 'Donation (Free)', icon: Icons.favorite_outline, value: 'donation', selected: _listingType, onTap: (v) => setState(() => _listingType = v)),
                const SizedBox(width: 12),
                _TypeToggle(label: 'Flash Sale', icon: Icons.local_offer_outlined, value: 'flash_sale', selected: _listingType, onTap: (v) => setState(() => _listingType = v)),
              ]),
              const SizedBox(height: 20),
              const _FormField(label: 'Title', placeholder: 'e.g. Chicken Biryani (30 servings)'),
              const SizedBox(height: 16),
              const _FormField(label: 'Description', placeholder: 'Describe the food, quantity, freshness...', maxLines: 3),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Label('Category'),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        value: _category,
                        isExpanded: true,
                        underline: const SizedBox(),
                        style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
                        items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (v) => setState(() => _category = v ?? _category),
                      ),
                    ),
                  ],
                )),
                const SizedBox(width: 16),
                const Expanded(child: _FormField(label: 'Quantity', placeholder: '0', keyboardType: TextInputType.number)),
              ]),
              if (_listingType == 'flash_sale') ...[
                const SizedBox(height: 16),
                const _FormField(label: 'Price (৳)', placeholder: '0', keyboardType: TextInputType.number),
              ],
              const SizedBox(height: 16),
              Row(children: const [
                Expanded(child: _FormField(label: 'Pickup Start', placeholder: 'e.g. 6:00 PM')),
                SizedBox(width: 16),
                Expanded(child: _FormField(label: 'Pickup End', placeholder: 'e.g. 9:00 PM')),
              ]),
              const SizedBox(height: 16),
              const _FormField(label: 'Pickup Address', placeholder: 'House/Road/Area, City'),
              const SizedBox(height: 28),
              Row(children: [
                AppButton(label: 'Cancel', outlined: true, onPressed: () => context.go('/donor')),
                const SizedBox(width: 12),
                AppButton(
                  label: _listingType == 'donation' ? 'Post Donation' : 'Post Flash Sale',
                  icon: const Icon(Icons.check, size: 16),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Listing created successfully!'), backgroundColor: Color(0xFF16A34A)),
                    );
                    context.go('/donor');
                  },
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeToggle extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final String selected;
  final ValueChanged<String> onTap;
  const _TypeToggle({required this.label, required this.icon, required this.value, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    final color = value == 'donation' ? const Color(0xFF16A34A) : const Color(0xFFEA580C);
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.08) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? color : const Color(0xFFE5E7EB), width: isSelected ? 2 : 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isSelected ? color : const Color(0xFF6B7280)),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? color : const Color(0xFF6B7280))),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF374151)));
}

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
      _Label(label),
      const SizedBox(height: 6),
      TextField(
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 13),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF16A34A), width: 2)),
        ),
        style: const TextStyle(fontSize: 13),
      ),
    ],
  );
}
