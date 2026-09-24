import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/layout/app_layout.dart';
import '../../providers/auth_provider.dart';
import '../../l10n/l10n_ext.dart';

/// Settings screen where the user controls notifications.
///
/// It has two sections:
///  1. A push-permission card showing the OS-level permission state and,
///     when possible, a button to request it.
///  2. A list of toggles for individual notification categories
///     (listings, requests, pickups, promotions), persisted via [AuthProvider].
class NotificationPreferences extends StatefulWidget {
  const NotificationPreferences({super.key});

  @override
  State<NotificationPreferences> createState() =>
      _NotificationPreferencesState();
}

class _NotificationPreferencesState extends State<NotificationPreferences> {
  /// Current OS-level push permission status. Null until the first check
  /// completes.
  AuthorizationStatus? _pushStatus;

  @override
  void initState() {
    super.initState();
    // Read the current permission state as soon as the screen opens.
    _refreshPushStatus();
  }

  /// Queries Firebase Messaging for the current permission status and
  /// updates the UI accordingly.
  Future<void> _refreshPushStatus() async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    // Guard against setState after the widget has been disposed.
    if (mounted) setState(() => _pushStatus = settings.authorizationStatus);
  }

  /// Shows the system permission prompt, then re-reads the resulting status.
  Future<void> _enablePush() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      // Ask for full permission rather than iOS "provisional" (quiet) delivery.
      provisional: false,
    );
    await _refreshPushStatus();
  }

  @override
  Widget build(BuildContext context) {
    // Theme-dependent colors shared by the cards and tiles below.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF121212);
    final subColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575);
    final cardColor = isDark
        ? const Color(0xFF1E1E1E)
        : const Color(0xFFFFFFFF);
    final borderColor = isDark
        ? const Color(0xFF3F3F46)
        : const Color(0xFFE2E2E2);
    // watch() so the switches rebuild when a preference changes.
    final auth = context.watch<AuthProvider>();
    final t = context.l10n;

    // Provisional permission still allows delivery, so it counts as enabled.
    final pushEnabled =
        _pushStatus == AuthorizationStatus.authorized ||
        _pushStatus == AuthorizationStatus.provisional;
    // Once denied, the app can't re-prompt; the user must use system settings.
    final pushDenied = _pushStatus == AuthorizationStatus.denied;

    return AppLayout(
      title: t.notifPrefsTitle,
      subtitle: t.notifPrefsSubtitle,
      currentRoute: '/profile',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---- Push permission card ----
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.fromBorderSide(BorderSide(color: borderColor)),
              // Hard-edged offset shadow (blurRadius 0) for the app's card style.
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14),
                  offset: const Offset(0, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon reflects state: active bell (green) vs. muted bell.
                Icon(
                  pushEnabled
                      ? Icons.notifications_active_outlined
                      : Icons.notifications_off_outlined,
                  color: pushEnabled ? const Color(0xFF16A34A) : subColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.notifPrefsPushEnable,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Status line: denied / enabled / not yet enabled.
                      Text(
                        pushDenied
                            ? t.notifPrefsPushDeniedSub
                            : (pushEnabled
                                  ? t.notifPrefsPushEnabled
                                  : t.notifPrefsPushDisabled),
                        style: TextStyle(fontSize: 12, color: subColor),
                      ),
                    ],
                  ),
                ),
                // Only offer the button when a prompt can actually be shown:
                // hidden if already enabled or permanently denied.
                if (!pushEnabled && !pushDenied)
                  ElevatedButton(
                    onPressed: _enablePush,
                    child: Text(t.notifPrefsPushButton),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // ---- Per-category preference toggles ----
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.fromBorderSide(BorderSide(color: borderColor)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14),
                  offset: const Offset(0, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                // New food listings nearby.
                _PreferenceTile(
                  icon: Icons.storefront_outlined,
                  title: t.notifPrefsNewListings,
                  subtitle: t.notifPrefsNewListingsSub,
                  value: auth.notifNewListings,
                  onChanged: auth.updateNotifNewListings,
                  textColor: textColor,
                  subColor: subColor,
                ),
                // Updates on requests.
                _PreferenceTile(
                  icon: Icons.assignment_outlined,
                  title: t.notifPrefsRequests,
                  subtitle: t.notifPrefsRequestsSub,
                  value: auth.notifRequests,
                  onChanged: auth.updateNotifRequests,
                  textColor: textColor,
                  subColor: subColor,
                ),
                // Pickup / delivery status updates.
                _PreferenceTile(
                  icon: Icons.local_shipping_outlined,
                  title: t.notifPrefsPickups,
                  subtitle: t.notifPrefsPickupsSub,
                  value: auth.notifPickups,
                  onChanged: auth.updateNotifPickups,
                  textColor: textColor,
                  subColor: subColor,
                ),
                // Marketing / promotional messages.
                _PreferenceTile(
                  icon: Icons.campaign_outlined,
                  title: t.notifPrefsPromotions,
                  subtitle: t.notifPrefsPromotionsSub,
                  value: auth.notifPromotions,
                  onChanged: auth.updateNotifPromotions,
                  textColor: textColor,
                  subColor: subColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A single labelled on/off switch row used in the preferences list.
///
/// Colors are passed in from the parent so all tiles stay consistent with
/// the current theme without each one re-reading it.
class _PreferenceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color textColor;
  final Color subColor;

  const _PreferenceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.textColor,
    required this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      // Leading icon in the brand green.
      secondary: Icon(icon, size: 20, color: const Color(0xFF16A34A)),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: subColor)),
      value: value,
      // Green track when the switch is on.
      activeTrackColor: const Color(0xFF16A34A),
      onChanged: onChanged,
    );
  }
}