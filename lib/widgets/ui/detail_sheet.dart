import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailRow {
  final IconData icon;
  final String label;
  final String value;
  const DetailRow(this.icon, this.label, this.value);
}

/// Bottom sheet showing all public info about an entity, with clickable
/// phone (tel:) and email (mailto:) actions when provided.
Future<void> showDetailSheet(
  BuildContext context, {
  required String title,
  String? subtitle,
  String? imageUrl,
  required List<DetailRow> rows,
  String? phone,
  String? email,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (sheetContext) => Container(
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
            Row(
              children: [
                Expanded(
                  child: Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF121212))),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 18, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)),
                  onPressed: () => Navigator.pop(sheetContext),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575))),
            ],
            const SizedBox(height: 14),
            for (final row in rows) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(row.icon, size: 16, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(row.label, style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF9CA3AF))),
                        const SizedBox(height: 2),
                        Text(row.value, style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF121212))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            if (phone != null || email != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  if (phone != null)
                    Expanded(
                      child: _ContactButton(
                        icon: Icons.phone_outlined,
                        label: 'Call',
                        color: const Color(0xFF16A34A),
                        onTap: () => launchUrl(Uri.parse('tel:$phone')),
                      ),
                    ),
                  if (phone != null && email != null) const SizedBox(width: 10),
                  if (email != null)
                    Expanded(
                      child: _ContactButton(
                        icon: Icons.mail_outline,
                        label: 'Email',
                        color: const Color(0xFF2563EB),
                        onTap: () => launchUrl(Uri.parse('mailto:$email')),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ContactButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

/// Fetches the donor's public contact info from Firestore and shows the
/// detail sheet for a listing.
Future<void> showListingDetailSheet(
  BuildContext context, {
  required String title,
  String? subtitle,
  required String donorId,
  required List<DetailRow> rows,
}) async {
  String? phone;
  String? email;
  try {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(donorId).get();
    email = userDoc.data()?['email'] as String?;
    final profileRef = userDoc.data()?['profileRef'] as DocumentReference?;
    if (profileRef != null) {
      final profile = await profileRef.get();
      phone = profile.data() != null ? (profile.data() as Map<String, dynamic>)['contactPhone'] as String? : null;
    }
  } catch (_) {}
  if (!context.mounted) return;
  await showDetailSheet(context, title: title, subtitle: subtitle, rows: rows, phone: phone, email: email);
}