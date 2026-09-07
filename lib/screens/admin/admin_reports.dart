import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../widgets/layout/app_layout.dart';
import '../../models/report.dart';
import '../../models/review.dart';
import '../../providers/admin_provider.dart';
import '../../l10n/l10n_ext.dart';

/// Admin-only inbox of every negative report and every review (positive or
/// negative) filed across the platform, each linking through to the
/// reported/reviewed user's full profile.
class AdminReports extends StatefulWidget {
  const AdminReports({super.key});

  @override
  State<AdminReports> createState() => _AdminReportsState();
}

class _AdminReportsState extends State<AdminReports> {
  bool _showReports = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = context.l10n;
    final admin = context.watch<AdminProvider>();
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2);
    final subColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575);
    final textColor = isDark ? Colors.white : const Color(0xFF121212);

    return AppLayout(
      title: t.adminReportsTitle,
      subtitle: t.adminReportsSubtitle,
      currentRoute: '/admin/reports',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: _Toggle(label: t.adminReports, selected: _showReports, onTap: () => setState(() => _showReports = true))),
            const SizedBox(width: 8),
            Expanded(child: _Toggle(label: t.adminReviews, selected: !_showReports, onTap: () => setState(() => _showReports = false))),
          ]),
          const SizedBox(height: 16),
          if (_showReports)
            StreamBuilder<List<ReportModel>>(
              stream: admin.reportsStream,
              builder: (context, snap) {
                final reports = snap.data ?? [];
                if (reports.isEmpty) return _Empty(text: t.adminNoReports, color: subColor);
                return Column(
                  children: reports
                      .map((r) => _ReportCard(report: r, cardColor: cardColor, borderColor: borderColor, textColor: textColor, subColor: subColor))
                      .toList(),
                );
              },
            )
          else
            StreamBuilder<List<ReviewModel>>(
              stream: admin.reviewsStream,
              builder: (context, snap) {
                final reviews = snap.data ?? [];
                if (reviews.isEmpty) return _Empty(text: t.adminNoReviews, color: subColor);
                return Column(
                  children: reviews
                      .map((r) => _ReviewCard(review: r, cardColor: cardColor, borderColor: borderColor, textColor: textColor, subColor: subColor))
                      .toList(),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Toggle({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: selected ? const Color(0xFF16A34A) : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5)),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? Colors.white : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF525252)))),
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final String text;
  final Color color;
  const _Empty({required this.text, required this.color});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Center(child: Text(text, style: TextStyle(color: color))),
  );
}

class _ReportCard extends StatelessWidget {
  final ReportModel report;
  final Color cardColor;
  final Color borderColor;
  final Color textColor;
  final Color subColor;
  const _ReportCard({required this.report, required this.cardColor, required this.borderColor, required this.textColor, required this.subColor});

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final date = '${report.createdAt.year}-${report.createdAt.month.toString().padLeft(2, '0')}-${report.createdAt.day.toString().padLeft(2, '0')}';
    return InkWell(
      onTap: () => context.go('/admin/user/${report.reportedUid}'),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(14), border: Border.all(color: borderColor)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.flag_outlined, size: 16, color: Color(0xFFDC2626)),
              const SizedBox(width: 6),
              Expanded(child: Text(t.adminReportAgainst(report.reportedLabel), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor))),
              Text(report.status, style: TextStyle(fontSize: 11, color: subColor)),
            ]),
            const SizedBox(height: 6),
            Text(report.reason, style: TextStyle(fontSize: 12.5, color: textColor)),
            const SizedBox(height: 6),
            Text(date, style: TextStyle(fontSize: 10.5, color: subColor)),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final Color cardColor;
  final Color borderColor;
  final Color textColor;
  final Color subColor;
  const _ReviewCard({required this.review, required this.cardColor, required this.borderColor, required this.textColor, required this.subColor});

  @override
  Widget build(BuildContext context) {
    final date = '${review.createdAt.year}-${review.createdAt.month.toString().padLeft(2, '0')}-${review.createdAt.day.toString().padLeft(2, '0')}';
    return InkWell(
      onTap: () => context.go('/admin/user/${review.targetUid}'),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(14), border: Border.all(color: borderColor)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.star, size: 16, color: Color(0xFFF59E0B)),
              const SizedBox(width: 6),
              Text('${review.rating}/5', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
              const SizedBox(width: 8),
              Expanded(child: Text(review.raterName, style: TextStyle(fontSize: 11, color: subColor))),
            ]),
            if (review.reviewText != null && review.reviewText!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(review.reviewText!, style: TextStyle(fontSize: 12.5, color: textColor)),
            ],
            const SizedBox(height: 6),
            Text(date, style: TextStyle(fontSize: 10.5, color: subColor)),
          ],
        ),
      ),
    );
  }
}
