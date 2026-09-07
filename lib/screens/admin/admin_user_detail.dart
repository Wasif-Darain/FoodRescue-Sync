import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../widgets/ui/app_badge.dart';
import '../../widgets/ui/verified_badge.dart';
import '../../models/models.dart';
import '../../models/report.dart';
import '../../models/review.dart';
import '../../providers/admin_provider.dart';
import '../../l10n/l10n_ext.dart';

Map<AccountType, String> _accountTypeLabel(dynamic t) => {
  AccountType.restaurant: t.accountTypeRestaurant as String,
  AccountType.caterer: t.accountTypeCaterer as String,
  AccountType.store: t.accountTypeStore as String,
  AccountType.ngo: t.accountTypeNgo as String,
  AccountType.foodBank: t.accountTypeFoodBank as String,
  AccountType.shelter: t.accountTypeShelter as String,
  AccountType.individual: t.accountTypeIndividual as String,
  AccountType.rider: t.accountTypeRider as String,
};

class _RoleStats {
  final int completedPickups;
  final int cancelledPickups;
  final int donationCount;
  final double kgSaved;
  const _RoleStats({this.completedPickups = 0, this.cancelledPickups = 0, this.donationCount = 0, this.kgSaved = 0});
}

class AdminUserDetail extends StatefulWidget {
  final String uid;
  const AdminUserDetail({super.key, required this.uid});

  @override
  State<AdminUserDetail> createState() => _AdminUserDetailState();
}

class _AdminUserDetailState extends State<AdminUserDetail> {
  RegisteredAccount? _account;
  _RoleStats _stats = const _RoleStats();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final firestore = FirebaseFirestore.instance;
    final userDoc = await firestore.collection('users').doc(widget.uid).get();
    if (!userDoc.exists) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final account = registeredAccountFromDoc(userDoc);

    _RoleStats stats;
    switch (account.mode) {
      case UserMode.donor:
        final logs = await firestore.collection('donation_logs').where('donorId', isEqualTo: widget.uid).get();
        final completed = await firestore.collection('pickups').where('donorId', isEqualTo: widget.uid).where('status', isEqualTo: 'completed').get();
        final cancelled = await firestore.collection('pickups').where('donorId', isEqualTo: widget.uid).where('status', isEqualTo: 'cancelled').get();
        final kg = logs.docs.fold<double>(0, (total, d) => total + ((d.data()['totalWeight'] as num?)?.toDouble() ?? 0));
        stats = _RoleStats(donationCount: logs.docs.length, kgSaved: kg, completedPickups: completed.docs.length, cancelledPickups: cancelled.docs.length);
      case UserMode.rider:
        final completed = await firestore.collection('pickups').where('volunteerDriverId', isEqualTo: widget.uid).where('status', isEqualTo: 'completed').get();
        final cancelled = await firestore.collection('pickups').where('volunteerDriverId', isEqualTo: widget.uid).where('status', isEqualTo: 'cancelled').get();
        stats = _RoleStats(completedPickups: completed.docs.length, cancelledPickups: cancelled.docs.length);
      case UserMode.consumer:
        final completed = await firestore.collection('pickups').where('consumerId', isEqualTo: widget.uid).where('status', isEqualTo: 'completed').get();
        final cancelled = await firestore.collection('pickups').where('consumerId', isEqualTo: widget.uid).where('status', isEqualTo: 'cancelled').get();
        stats = _RoleStats(completedPickups: completed.docs.length, cancelledPickups: cancelled.docs.length);
      case UserMode.admin:
        stats = const _RoleStats();
    }

    if (!mounted) return;
    setState(() {
      _account = account;
      _stats = stats;
      _loading = false;
    });
  }

  Future<void> _runAndReload(Future<void> Function() action) async {
    await action();
    if (!mounted) return;
    setState(() => _loading = true);
    await _load();
  }

  void _viewImage(String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: InteractiveViewer(child: Image.network(url)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = context.l10n;
    final admin = context.read<AdminProvider>();

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final account = _account;
    if (account == null) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text(t.adminUserNotFound)));
    }

    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2);
    final subColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575);
    final textColor = isDark ? Colors.white : const Color(0xFF121212);

    final (statusLabel, statusVariant) = switch (account.status) {
      AccountStatus.pending => (t.acctMgmtStatusPending, BadgeVariant.orange),
      AccountStatus.approved => (t.acctMgmtStatusApproved, BadgeVariant.green),
      AccountStatus.suspended => (t.acctMgmtStatusSuspended, BadgeVariant.red),
    };

    return Scaffold(
      appBar: AppBar(title: Text(account.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Card(
              cardColor: cardColor,
              borderColor: borderColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(child: Text(account.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor))),
                      if (account.isVerified) ...[const SizedBox(width: 6), VerifiedBadge(mode: account.mode)],
                      const Spacer(),
                      AppBadge(label: statusLabel, variant: statusVariant),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(account.email, style: TextStyle(fontSize: 13, color: subColor)),
                  if (account.phone != null && account.phone!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(account.phone!, style: TextStyle(fontSize: 13, color: subColor)),
                  ],
                  if (account.address != null && account.address!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(account.address!, style: TextStyle(fontSize: 13, color: subColor)),
                  ],
                  const SizedBox(height: 10),
                  Wrap(spacing: 6, runSpacing: 6, children: [
                    _Tag(_roleLabel(t, account.mode), subColor),
                    _Tag(_accountTypeLabel(t)[account.accountType] ?? '', subColor),
                    _Tag(t.acctMgmtJoinedTag('${account.joinedAt.year}-${account.joinedAt.month.toString().padLeft(2, '0')}-${account.joinedAt.day.toString().padLeft(2, '0')}'), subColor),
                  ]),
                  const SizedBox(height: 14),
                  Row(children: [
                    if (account.status != AccountStatus.approved)
                      Expanded(child: _Action(label: t.acctMgmtApprove, color: const Color(0xFF16A34A), onTap: () => _runAndReload(() => admin.approve(account.uid)))),
                    if (account.status == AccountStatus.approved)
                      Expanded(child: _Action(label: t.acctMgmtSuspend, color: const Color(0xFFD97706), onTap: () => _runAndReload(() => admin.setStatus(account.uid, AccountStatus.suspended)))),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _Action(
                        label: t.acctMgmtRemove,
                        color: const Color(0xFFEF4444),
                        outlined: true,
                        onTap: () async {
                          await admin.removeAccount(account.uid);
                          if (context.mounted) context.pop();
                        },
                      ),
                    ),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _Card(
              cardColor: cardColor,
              borderColor: borderColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.adminVerificationDocs, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
                  const SizedBox(height: 10),
                  if (!account.hasSubmittedDocuments)
                    Text(t.acctMgmtNoDocuments, style: const TextStyle(fontSize: 12, color: Color(0xFFD97706)))
                  else if (account.verificationDocUrl != null)
                    _DocThumb(label: t.authVerificationDocLabel, url: account.verificationDocUrl!, onTap: _viewImage)
                  else
                    Row(children: [
                      if (account.nidFrontUrl != null) Expanded(child: _DocThumb(label: t.authNidFront, url: account.nidFrontUrl!, onTap: _viewImage)),
                      if (account.nidFrontUrl != null && account.nidBackUrl != null) const SizedBox(width: 10),
                      if (account.nidBackUrl != null) Expanded(child: _DocThumb(label: t.authNidBack, url: account.nidBackUrl!, onTap: _viewImage)),
                    ]),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _Card(
              cardColor: cardColor,
              borderColor: borderColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.adminActivityStats, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
                  const SizedBox(height: 10),
                  Wrap(spacing: 20, runSpacing: 10, children: [
                    if (account.mode == UserMode.donor) _Stat(t.adminStatDonations, '${_stats.donationCount}', textColor, subColor),
                    if (account.mode == UserMode.donor) _Stat(t.adminStatKgSaved, _stats.kgSaved.toStringAsFixed(1), textColor, subColor),
                    _Stat(t.adminStatCompleted, '${_stats.completedPickups}', textColor, subColor),
                    _Stat(t.adminStatCancelled, '${_stats.cancelledPickups}', textColor, subColor),
                    _Stat(t.adminStatRating, account.reviewCount == 0 ? '—' : account.rating.toStringAsFixed(1), textColor, subColor),
                    _Stat(t.adminStatReviewCount, '${account.reviewCount}', textColor, subColor),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _Card(
              cardColor: cardColor,
              borderColor: borderColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.adminReviews, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
                  const SizedBox(height: 8),
                  StreamBuilder<List<ReviewModel>>(
                    stream: admin.reviewsFor(account.uid),
                    builder: (context, snap) {
                      final reviews = snap.data ?? [];
                      if (reviews.isEmpty) return Text(t.adminNoReviews, style: TextStyle(fontSize: 12, color: subColor));
                      return Column(children: reviews.map((r) => _ReviewRow(review: r, textColor: textColor, subColor: subColor)).toList());
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _Card(
              cardColor: cardColor,
              borderColor: borderColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.adminReports, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
                  const SizedBox(height: 8),
                  StreamBuilder<List<ReportModel>>(
                    stream: admin.reportsFor(account.uid),
                    builder: (context, snap) {
                      final reports = snap.data ?? [];
                      if (reports.isEmpty) return Text(t.adminNoReports, style: TextStyle(fontSize: 12, color: subColor));
                      return Column(children: reports.map((r) => _ReportRow(report: r, textColor: textColor, subColor: subColor)).toList());
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _roleLabel(dynamic t, UserMode mode) => switch (mode) {
    UserMode.donor => t.acctMgmtDonor as String,
    UserMode.rider => t.acctMgmtRider as String,
    UserMode.admin => t.navAdministrator as String,
    UserMode.consumer => t.acctMgmtConsumer as String,
  };
}

class _Card extends StatelessWidget {
  final Color cardColor;
  final Color borderColor;
  final Widget child;
  const _Card({required this.cardColor, required this.borderColor, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
    child: child,
  );
}

class _Tag extends StatelessWidget {
  final String text;
  final Color color;
  const _Tag(this.text, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
    child: Text(text, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500)),
  );
}

class _Action extends StatelessWidget {
  final String label;
  final Color color;
  final bool outlined;
  final VoidCallback onTap;
  const _Action({required this.label, required this.color, required this.onTap, this.outlined = false});

  @override
  Widget build(BuildContext context) => Material(
    color: outlined ? Colors.transparent : color,
    borderRadius: BorderRadius.circular(10),
    child: InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: outlined ? Border.all(color: color) : null),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: outlined ? color : Colors.white)),
      ),
    ),
  );
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color textColor;
  final Color subColor;
  const _Stat(this.label, this.value, this.textColor, this.subColor);

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
      Text(label, style: TextStyle(fontSize: 11, color: subColor)),
    ],
  );
}

class _DocThumb extends StatelessWidget {
  final String label;
  final String url;
  final ValueChanged<String> onTap;
  const _DocThumb({required this.label, required this.url, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => onTap(url),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575))),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(url, height: 120, width: double.infinity, fit: BoxFit.cover),
          ),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final ReviewModel review;
  final Color textColor;
  final Color subColor;
  const _ReviewRow({required this.review, required this.textColor, required this.subColor});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(Icons.star, size: 14, color: const Color(0xFFF59E0B)),
          const SizedBox(width: 4),
          Text('${review.rating}/5', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor)),
          const SizedBox(width: 8),
          Text(review.raterName, style: TextStyle(fontSize: 11, color: subColor)),
        ]),
        if (review.reviewText != null && review.reviewText!.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(review.reviewText!, style: TextStyle(fontSize: 12, color: subColor)),
        ],
      ],
    ),
  );
}

class _ReportRow extends StatelessWidget {
  final ReportModel report;
  final Color textColor;
  final Color subColor;
  const _ReportRow({required this.report, required this.textColor, required this.subColor});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Icon(Icons.flag_outlined, size: 14, color: Color(0xFFDC2626)),
          const SizedBox(width: 4),
          Expanded(child: Text(report.reason, style: TextStyle(fontSize: 12, color: textColor))),
        ]),
        const SizedBox(height: 2),
        Text(
          '${report.createdAt.year}-${report.createdAt.month.toString().padLeft(2, '0')}-${report.createdAt.day.toString().padLeft(2, '0')} · ${report.status}',
          style: TextStyle(fontSize: 10.5, color: subColor),
        ),
      ],
    ),
  );
}
