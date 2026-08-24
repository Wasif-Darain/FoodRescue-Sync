import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/layout/app_layout.dart';
import '../../providers/locale_provider.dart';
import '../../l10n/l10n_ext.dart';
import '../../l10n/gen/app_localizations.dart';

const _regionOptions = ['Bangladesh', 'India', 'Pakistan', 'Nepal'];
const _timeZoneOptions = ['GMT+6 (Dhaka)', 'GMT+5:30 (Kolkata)', 'GMT+5 (Karachi)', 'GMT+0 (UTC)'];
const _currencyOptions = ['BDT (৳)', 'USD (\$)', 'INR (₹)', 'EUR (€)'];

class LanguageRegion extends StatefulWidget {
  const LanguageRegion({super.key});

  @override
  State<LanguageRegion> createState() => _LanguageRegionState();
}

class _LanguageRegionState extends State<LanguageRegion> {
  String _region = _regionOptions.first;
  String _timeZone = _timeZoneOptions.first;
  String _currency = _currencyOptions.first;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _region = prefs.getString('pref_region') ?? _regionOptions.first;
      _timeZone = prefs.getString('pref_timezone') ?? _timeZoneOptions.first;
      _currency = prefs.getString('pref_currency') ?? _currencyOptions.first;
    });
  }

  Future<void> _pick({
    required String title,
    required List<String> options,
    required String current,
    required String prefsKey,
    required void Function(String) apply,
  }) async {
    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(title),
        children: [
          RadioGroup<String>(
            groupValue: current,
            onChanged: (v) => Navigator.pop(dialogContext, v),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final option in options)
                  RadioListTile<String>(
                    value: option,
                    title: Text(option),
                    activeColor: const Color(0xFF16A34A),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    if (selected == null || selected == current) return;
    apply(selected);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefsKey, selected);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.langSaved), backgroundColor: const Color(0xFF16A34A)),
    );
  }

  Future<void> _pickLanguage(AppLocalizations t) async {
    final localeProvider = context.read<LocaleProvider>();
    final current = localeProvider.locale.languageCode;
    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(t.langChooseLanguage),
        children: [
          RadioGroup<String>(
            groupValue: current,
            onChanged: (v) => Navigator.pop(dialogContext, v),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  value: 'en',
                  title: Text(t.langEnglish),
                  activeColor: const Color(0xFF16A34A),
                ),
                RadioListTile<String>(
                  value: 'bn',
                  title: Text(t.langBangla),
                  activeColor: const Color(0xFF16A34A),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    if (selected == null || selected == current) return;
    await localeProvider.setLocale(Locale(selected));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.langSaved), backgroundColor: const Color(0xFF16A34A)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF121212);
    final subColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
    final borderColor = isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2);
    final t = context.l10n;
    final languageLabel = context.watch<LocaleProvider>().locale.languageCode == 'bn' ? t.langBangla : t.langEnglish;

    return AppLayout(
      title: t.langTitle,
      subtitle: t.langSubtitle,
      currentRoute: '/profile',
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.fromBorderSide(BorderSide(color: borderColor)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14), offset: const Offset(0, 4), blurRadius: 0)],
        ),
        child: Column(
          children: [
            _RegionTile(
              icon: Icons.language_outlined,
              title: t.langLanguage,
              subtitle: languageLabel,
              textColor: textColor,
              subColor: subColor,
              isDark: isDark,
              onTap: () => _pickLanguage(t),
            ),
            _RegionTile(
              icon: Icons.place_outlined,
              title: t.langRegion,
              subtitle: _region,
              textColor: textColor,
              subColor: subColor,
              isDark: isDark,
              onTap: () => _pick(
                title: t.langChooseRegion,
                options: _regionOptions,
                current: _region,
                prefsKey: 'pref_region',
                apply: (v) => setState(() => _region = v),
              ),
            ),
            _RegionTile(
              icon: Icons.schedule_outlined,
              title: t.langTimeZone,
              subtitle: _timeZone,
              textColor: textColor,
              subColor: subColor,
              isDark: isDark,
              onTap: () => _pick(
                title: t.langChooseTimeZone,
                options: _timeZoneOptions,
                current: _timeZone,
                prefsKey: 'pref_timezone',
                apply: (v) => setState(() => _timeZone = v),
              ),
            ),
            _RegionTile(
              icon: Icons.currency_exchange_outlined,
              title: t.langCurrency,
              subtitle: _currency,
              textColor: textColor,
              subColor: subColor,
              isDark: isDark,
              onTap: () => _pick(
                title: t.langChooseCurrency,
                options: _currencyOptions,
                current: _currency,
                prefsKey: 'pref_currency',
                apply: (v) => setState(() => _currency = v),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color textColor;
  final Color subColor;
  final bool isDark;
  final VoidCallback onTap;

  const _RegionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.textColor,
    required this.subColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 20, color: const Color(0xFF16A34A)),
      title: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textColor)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: subColor)),
      trailing: Icon(Icons.arrow_forward_ios, size: 12, color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFBFBFBF)),
      dense: true,
      onTap: onTap,
    );
  }
}
