import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/app_badge.dart';
import '../../widgets/ui/user_badge.dart';
import '../../widgets/ui/countdown_timer.dart';
import '../../widgets/ui/date_time_field.dart';
import 'package:latlong2/latlong.dart';
import '../../widgets/ui/location_picker.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/donor_provider.dart';

class DonorConsumers extends StatefulWidget {
  const DonorConsumers({super.key});

  @override
  State<DonorConsumers> createState() => _DonorConsumersState();
}

class _DonorConsumersState extends State<DonorConsumers> {
  String _search = '';
  String _availabilityFilter = 'All';
  final String _dummyLocation = 'Gulshan, Dhaka';

  DateTime _nextOccurrence(TimeOfDay time) {
    final now = DateTime.now();
    var candidate = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    if (!candidate.isAfter(now)) candidate = candidate.add(const Duration(days: 1));
    return candidate;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.watch<AuthProvider>().user!;
    final donor = context.watch<DonorProvider>();

    final consumersStream = FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'consumer')
        .snapshots()
        .map((snap) {
          final seen = <String>{};
          return snap.docs.map((doc) {
          final data = doc.data();
          final email = data['email'] as String? ?? '';
          if (email.isNotEmpty && !seen.add(email)) return null;
          return RegisteredAccount(
            id: 0,
            uid: doc.id,
            name: data['name'] as String? ?? '',
            email: data['email'] as String? ?? '',
            accountType: AccountType.ngo,
            mode: UserMode.consumer,
            status: AccountStatus.approved,
            joinedAt: DateTime.now(),
            isAvailable: data['isAvailable'] as bool? ?? true,
            latitude: (data['latitude'] as num?)?.toDouble(),
            longitude: (data['longitude'] as num?)?.toDouble(),
            address: data['address'] as String?,
          );
          }).whereType<RegisteredAccount>().toList();
        });

    final upcoming = donor.scheduledDonations.where((d) => d.status == DonationScheduleStatus.scheduled).toList();

    return StreamBuilder<List<RegisteredAccount>>(
      stream: consumersStream,
      builder: (context, snapshot) {
        final allConsumers = snapshot.data ?? [];
        final consumers = allConsumers.where((a) {
          final searchMatch = _search.isEmpty || a.name.toLowerCase().contains(_search.toLowerCase());
          final availMatch = _availabilityFilter == 'All' ||
              (_availabilityFilter == 'Available' && a.isAvailable) ||
              (_availabilityFilter == 'Unavailable' && !a.isAvailable);
          return searchMatch && availMatch;
        }).toList()
          ..sort((a, b) => donor.donationCountFor(b.name).compareTo(donor.donationCountFor(a.name)));

        return AppLayout(
          title: 'Consumers',
          subtitle: 'Donate directly to consumers',
          currentRoute: '/donor/consumers',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14), offset: const Offset(0, 4), blurRadius: 0)],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hi, ${user.name.split(' ').first}!', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF121212), fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(
                            '${consumers.length} consumer${consumers.length == 1 ? '' : 's'} available.',
                            style: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5), borderRadius: BorderRadius.all(Radius.circular(14))),
                      child: const Icon(Icons.groups_outlined, color: Color(0xFF16A34A), size: 26),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2)),
                ),
                child: Wrap(
                  spacing: 20,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: donor.isAvailable,
                          activeTrackColor: const Color(0xFF16A34A),
                          onChanged: (value) {
                            final message = donor.setAvailability(value);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(message),
                              backgroundColor: value ? const Color(0xFF16A34A) : const Color(0xFFEA580C),
                            ));
                          },
                        ),
                        Text('Available for donations', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: isDark ? Colors.white : const Color(0xFF121212))),
                      ],
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () async {
                        final picked = await showTimePicker(context: context, initialTime: donor.preferredPickupTime);
                        if (picked != null) donor.setPreferredPickupTime(picked);
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.schedule, size: 16, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)),
                          const SizedBox(width: 6),
                          Text(
                            'Default pickup time: ${donor.preferredPickupTime.format(context)}',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: isDark ? Colors.white : const Color(0xFF121212)),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.edit_outlined, size: 13, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              if (upcoming.isNotEmpty) ...[
                _SectionCard(
                  title: 'Upcoming Donations',
                  icon: Icons.event_available_outlined,
                  child: Column(
                    children: upcoming
                        .map((d) => _UpcomingDonationRow(
                              donation: d,
                              onEdit: () => _showScheduleSheet(
                                context,
                                consumerLabel: d.consumerName,
                                initialTime: d.scheduledTime,
                                initialLocation: d.location,
                                confirmLabel: 'Save Changes',
                                onConfirm: (time, location) {
                                  final error = context.read<DonorProvider>().rescheduleDonation(
                                        d.id,
                                        time,
                                        location.isEmpty ? d.location : location,
                                      );
                                  if (error == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                      content: Text('Pickup rescheduled — the consumer has been notified.'),
                                      backgroundColor: Color(0xFF16A34A),
                                    ));
                                  }
                                  return error;
                                },
                              ),
                              onCancel: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (dialogContext) => AlertDialog(
                                    title: const Text('Cancel donation?'),
                                    content: Text('Cancel the donation scheduled for ${d.consumerName}?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Keep it')),
                                      TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Cancel donation')),
                                    ],
                                  ),
                                );
                                if (confirmed != true || !context.mounted) return;
                                final error = context.read<DonorProvider>().cancelDonation(d.id);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(error ?? 'Donation cancelled — the consumer has been notified.'),
                                  backgroundColor: error == null ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                                ));
                              },
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(10), border: Border.all(color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2))),
                child: Row(children: [
                  Icon(Icons.search, size: 18, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(
                    onChanged: (value) => setState(() => _search = value),
                    decoration: InputDecoration(hintText: 'Search consumers...', border: InputBorder.none, hintStyle: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFFBFBFBF))),
                  )),
                ]),
              ),
              const SizedBox(height: 14),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'Available', 'Unavailable'].map((avail) {
                    final isSelected = _availabilityFilter == avail;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _HoverScale(
                        child: GestureDetector(
                          onTap: () => setState(() => _availabilityFilter = avail),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF16A34A) : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFFFFFFF)),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: isSelected ? const Color(0xFF16A34A) : (isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2))),
                            ),
                            child: Row(children: [
                              Icon(
                                avail == 'Available' ? Icons.check_circle_outline : (avail == 'Unavailable' ? Icons.cancel_outlined : Icons.filter_list),
                                size: 13,
                                color: isSelected ? Colors.white : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF525252)),
                              ),
                              const SizedBox(width: 4),
                              Text(avail, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF525252)))),
                            ]),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              if (consumers.isEmpty)
                Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.groups_outlined, size: 48, color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFBFBFBF)),
                      const SizedBox(height: 12),
                      Text('No consumers found', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF121212))),
                      const SizedBox(height: 4),
                      Text('Try a different search or filter.', style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575))),
                    ],
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 320,
                    mainAxisExtent: 300,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: consumers.length,
                  itemBuilder: (_, i) {
                    final account = consumers[i];
                    final count = donor.donationCountFor(account.name);
                    return _ConsumerCard(
                      account: account,
                      streak: count,
                       onDonate: () => _showDonateSheet(
                         context,
                         consumerLabel: account.name,
                         initialTime: _nextOccurrence(donor.preferredPickupTime),
                         initialLocation: account.address ?? _dummyLocation,
                         onConfirm: (itemName, description, category, quantity, time, location) {
                           context.read<DonorProvider>().donateToConsumer(
                                 consumerId: account.uid,
                                 consumerName: account.name,
                                 itemName: itemName,
                                 description: description,
                                 category: category,
                                 quantity: quantity,
                                 scheduledTime: time,
                                 location: location.isEmpty ? _dummyLocation : location,
                               );
                           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                             content: Text('Donation scheduled for ${account.name}'),
                             backgroundColor: const Color(0xFF16A34A),
                           ));
                           return null;
                         },
                       ),
                     );
                   },
                 ),
            ],
          ),
        );
      },
    );
  }
}

const _donationCategories = ['Cooked Meals', 'Bakery', 'Dairy', 'Produce', 'Grains', 'Other'];

void _showDonateSheet(
  BuildContext context, {
  required String consumerLabel,
  required DateTime initialTime,
  required String initialLocation,
  required String? Function(String itemName, String description, String category, int quantity, DateTime time, String location) onConfirm,
}) {
  var selectedTime = initialTime;
  var selectedCategory = _donationCategories.first;
  final itemCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final quantityCtrl = TextEditingController(text: '1');
  final locationCtrl = TextEditingController(text: initialLocation);
  String? error;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (sheetContext) => StatefulBuilder(
      builder: (sheetContext, setSheetState) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        Widget label(String text) => Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF525252)));
        InputDecoration fieldDecoration() => InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2))),
            );

        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(20),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(child: Text('Donate to $consumerLabel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF121212)))),
                      IconButton(
                        icon: Icon(Icons.close, size: 18, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)),
                        onPressed: () => Navigator.pop(sheetContext),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    label('What are you donating?'),
                    const SizedBox(height: 4),
                    TextField(
                      controller: itemCtrl,
                      style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF121212)),
                      decoration: fieldDecoration().copyWith(hintText: 'e.g. Chicken Biryani (10 servings)'),
                    ),
                    const SizedBox(height: 12),
                    label('Description'),
                    const SizedBox(height: 4),
                    TextField(
                      controller: descCtrl,
                      maxLines: 2,
                      style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF121212)),
                      decoration: fieldDecoration().copyWith(hintText: 'Freshness, allergens, packaging details...'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              label('Category'),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                initialValue: selectedCategory,
                                decoration: fieldDecoration(),
                                style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF121212)),
                                items: _donationCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                                onChanged: (value) {
                                  if (value != null) setSheetState(() => selectedCategory = value);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              label('Quantity'),
                              const SizedBox(height: 4),
                              TextField(
                                controller: quantityCtrl,
                                keyboardType: TextInputType.number,
                                style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF121212)),
                                decoration: fieldDecoration(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DateTimeField(
                      label: 'Collection time',
                      value: selectedTime,
                      onTap: () async {
                        final picked = await pickDateTime(sheetContext, initial: selectedTime, defaultTime: TimeOfDay.fromDateTime(selectedTime));
                        if (picked != null) setSheetState(() => selectedTime = picked);
                      },
                    ),
                    const SizedBox(height: 12),
                    label('Collection location'),
                    const SizedBox(height: 4),
                    TextField(
                      controller: locationCtrl,
                      style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF121212)),
                      decoration: fieldDecoration(),
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 10),
                      Text(error!, style: const TextStyle(fontSize: 12, color: Color(0xFFDC2626))),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final itemName = itemCtrl.text.trim();
                          final quantity = int.tryParse(quantityCtrl.text.trim());
                          if (itemName.isEmpty) {
                            setSheetState(() => error = 'Please describe what you are donating.');
                            return;
                          }
                          if (quantity == null || quantity <= 0) {
                            setSheetState(() => error = 'Enter a valid quantity.');
                            return;
                          }
                          final result = onConfirm(itemName, descCtrl.text.trim(), selectedCategory, quantity, selectedTime, locationCtrl.text.trim());
                          if (result == null) {
                            Navigator.pop(sheetContext);
                          } else {
                            setSheetState(() => error = result);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Confirm Donation', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

void _showScheduleSheet(
  BuildContext context, {
  required String consumerLabel,
  required DateTime initialTime,
  required String initialLocation,
  required String confirmLabel,
  required String? Function(DateTime time, String location) onConfirm,
}) {
  var selectedTime = initialTime;
  final locationCtrl = TextEditingController(text: initialLocation);
  String? error;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (sheetContext) => StatefulBuilder(
      builder: (sheetContext, setSheetState) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(20),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(child: Text(consumerLabel, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF121212)))),
                    IconButton(
                      icon: Icon(Icons.close, size: 18, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)),
                      onPressed: () => Navigator.pop(sheetContext),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  DateTimeField(
                    label: 'Collection time',
                    value: selectedTime,
                    onTap: () async {
                      final picked = await pickDateTime(sheetContext, initial: selectedTime, defaultTime: TimeOfDay.fromDateTime(selectedTime));
                      if (picked != null) setSheetState(() => selectedTime = picked);
                    },
                  ),
                  const SizedBox(height: 12),
                  Text('Collection location', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF525252))),
                  const SizedBox(height: 4),
                  TextField(
                    controller: locationCtrl,
                    style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF121212)),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2))),
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 10),
                    Text(error!, style: const TextStyle(fontSize: 12, color: Color(0xFFDC2626))),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final result = onConfirm(selectedTime, locationCtrl.text.trim());
                        if (result == null) {
                          Navigator.pop(sheetContext);
                        } else {
                          setSheetState(() => error = result);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(confirmLabel, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget child;

  const _SectionCard({required this.title, required this.child, this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? Colors.white : const Color(0xFF121212);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14), offset: const Offset(0, 4), blurRadius: 0),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
              ],
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _UpcomingDonationRow extends StatelessWidget {
  final ScheduledDonation donation;
  final VoidCallback onEdit;
  final VoidCallback onCancel;

  const _UpcomingDonationRow({required this.donation, required this.onEdit, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = donation.scheduledTime;
    final formatted = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} · ${t.day}/${t.month}/${t.year}';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(donation.consumerName, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF121212))),
                const SizedBox(height: 3),
                Row(children: [
                  Icon(Icons.inventory_2_outlined, size: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)),
                  const SizedBox(width: 4),
                  Expanded(child: Text('${donation.itemName} · ${donation.category} · Qty: ${donation.quantity}', style: TextStyle(fontSize: 11.5, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)), overflow: TextOverflow.ellipsis)),
                ]),
                const SizedBox(height: 2),
                Row(children: [
                  Icon(Icons.access_time, size: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)),
                  const SizedBox(width: 4),
                  Text(formatted, style: TextStyle(fontSize: 11.5, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575))),
                ]),
                const SizedBox(height: 2),
                Row(children: [
                  Icon(Icons.location_on_outlined, size: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)),
                  const SizedBox(width: 4),
                  Expanded(child: Text(donation.location, style: TextStyle(fontSize: 11.5, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)), overflow: TextOverflow.ellipsis)),
                ]),
                const SizedBox(height: 6),
                CountdownTimer(expiry: donation.scheduledTime, fontSize: 9),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: onEdit, tooltip: 'Edit'),
          IconButton(icon: const Icon(Icons.close, size: 18), onPressed: onCancel, tooltip: 'Cancel'),
        ],
      ),
    );
  }
}

class _ConsumerCard extends StatelessWidget {
  final RegisteredAccount account;
  final int streak;
  final VoidCallback onDonate;

  const _ConsumerCard({required this.account, required this.streak, required this.onDonate});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAvailable = account.isAvailable;
    final tierLabel = consumerTierLabel(consumerTierFor(account));
    final auth = context.watch<AuthProvider>();
    String? distanceLabel;
    if (auth.latitude != null && auth.longitude != null && account.latitude != null && account.longitude != null) {
      final km = haversineKm(auth.latitude!, auth.longitude!, account.latitude!, account.longitude!);
      distanceLabel = '${km.toStringAsFixed(1)} km away';
    }

    return _HoverScale(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFDCFCE7),
                  child: Text(account.name[0], style: const TextStyle(color: Color(0xFF15803D), fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(account.name, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF121212)), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 3),
                      UserBadge(label: tierLabel, isLegend: tierLabel == 'Legend', fontSize: 8),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ...List.generate(5, (i) => Icon(
                      i < account.rating.round() ? Icons.star : Icons.star_border,
                      size: 13,
                      color: const Color(0xFFF59E0B),
                    )),
                const SizedBox(width: 4),
                Text('(${account.reviewCount})', style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575))),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(pickupPreferenceIcon(account.pickupPreference), size: 13, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)),
                const SizedBox(width: 4),
                Text(pickupPreferenceLabel(account.pickupPreference), style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575))),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 13, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    [if (distanceLabel != null) distanceLabel, if (account.address != null) account.address!].join(' · ').isEmpty
                        ? 'Location not set'
                        : [if (distanceLabel != null) distanceLabel, if (account.address != null) account.address!].join(' · '),
                    style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                AppBadge(
                  label: isAvailable ? 'Available' : 'Unavailable',
                  variant: isAvailable ? BadgeVariant.green : BadgeVariant.orange,
                ),
                AppBadge(
                  label: streak > 0 ? '${streak}x donated' : 'New',
                  variant: streak > 0 ? BadgeVariant.blue : BadgeVariant.gray,
                ),
              ],
            ),
            const Spacer(),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onDonate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.volunteer_activism_outlined, size: 14),
                    SizedBox(width: 6),
                    Text('Donate', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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