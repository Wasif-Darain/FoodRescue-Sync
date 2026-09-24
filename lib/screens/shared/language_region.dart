import 'package:flutter/material.dart';
// Provides the widget and material design APIs used by this screen.
import 'package:provider/provider.dart';
// Provides access to the application's locale state.
import 'package:shared_preferences/shared_preferences.dart';
// Provides local persistence for the non-language preferences.
import '../../widgets/layout/app_layout.dart';
// Supplies the shared page layout used by profile screens.
import '../../providers/locale_provider.dart';
// Supplies the active application locale and locale-changing behavior.
import '../../l10n/l10n_ext.dart';
// Adds the convenient localization extension used by the screen.
import '../../l10n/gen/app_localizations.dart';
// Provides the generated localization type for the language picker.

// Lists the regions available in the current product scope.
const _regionOptions = ['Bangladesh', 'India', 'Pakistan', 'Nepal'];
// Lists the time zones presented to the user.
const _timeZoneOptions = ['GMT+6 (Dhaka)', 'GMT+5:30 (Kolkata)', 'GMT+5 (Karachi)', 'GMT+0 (UTC)'];
// Lists the supported currencies and their display symbols.
const _currencyOptions = ['BDT (৳)', 'USD (\$)', 'INR (₹)', 'EUR (€)'];

// Displays the user's language, region, time zone, and currency preferences.
class LanguageRegion extends StatefulWidget {
  // Creates the language and regional preferences screen.
  const LanguageRegion({super.key});

  // Creates the mutable state that owns the preference values.
  @override
  State<LanguageRegion> createState() => _LanguageRegionState();
}

class _LanguageRegionState extends State<LanguageRegion> {
  // Holds the selected region shown by the region tile.
  String _region = _regionOptions.first;
  // Holds the selected time zone shown by the time zone tile.
  String _timeZone = _timeZoneOptions.first;
  // Holds the selected currency shown by the currency tile.
  String _currency = _currencyOptions.first;

  // Starts loading persisted values when the state enters the tree.
  @override
  void initState() {
    // Runs the framework's state initialization first.
    super.initState();
    // Restore saved preferences after the widget is initialized.
    _load();
  }

  // Reads saved regional settings from local device storage.
  Future<void> _load() async {
    // Opens the shared preferences store asynchronously.
    final prefs = await SharedPreferences.getInstance();
    // Stops if the screen was removed while storage was loading.
    if (!mounted) return;
    // Keep the current defaults when a preference has not been saved yet.
    setState(() {
      // Restores the saved region or keeps the first available option.
      _region = prefs.getString('pref_region') ?? _regionOptions.first;
      // Restores the saved time zone or keeps the first available option.
      _timeZone = prefs.getString('pref_timezone') ?? _timeZoneOptions.first;
      // Restores the saved currency or keeps the first available option.
      _currency = prefs.getString('pref_currency') ?? _currencyOptions.first;
    });
  }

  // Shows a generic picker and persists the selected non-language value.
  Future<void> _pick({
    // Supplies the dialog heading.
    required String title,
    // Supplies the radio choices displayed in the dialog.
    required List<String> options,
    // Identifies the currently selected radio choice.
    required String current,
    // Identifies the preferences key used for persistence.
    required String prefsKey,
    // Applies the selected value to the corresponding state field.
    required void Function(String) apply,
  }) async {
    // Show the supplied options in a reusable radio-selection dialog.
    final selected = await showDialog<String>(
      context: context,
      // Builds the dialog in the route-local dialog context.
      builder: (dialogContext) => SimpleDialog(
        // Displays the localized or caller-provided picker title.
        title: Text(title),
        children: [
          // Groups all choices so exactly one value is selected.
          RadioGroup<String>(
            groupValue: current,
            // Closes the dialog and returns the chosen value.
            onChanged: (v) => Navigator.pop(dialogContext, v),
            child: Column(
              // Lets the dialog size itself to the available choices.
              mainAxisSize: MainAxisSize.min,
              children: [
                // Creates one radio tile for each supplied option.
                for (final option in options)
                  RadioListTile<String>(
                    // Uses the option text as the radio value.
                    value: option,
                    // Displays the option as the tile label.
                    title: Text(option),
                    // Keeps selection accents aligned with the app's green color.
                    activeColor: const Color(0xFF16A34A),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    // Ignores cancellation and avoids unnecessary writes for the current value.
    if (selected == null || selected == current) return;
    // Updates the visible state immediately after selection.
    apply(selected);
    // Persist the new value so it is restored on the next visit.
    final prefs = await SharedPreferences.getInstance();
    // Writes the chosen value under the caller's preference key.
    await prefs.setString(prefsKey, selected);
    // Avoids showing feedback after the screen has been disposed.
    if (!mounted) return;
    // Confirms that the preference was saved successfully.
    ScaffoldMessenger.of(context).showSnackBar(
      // Uses the localized saved message and the success color.
      SnackBar(content: Text(context.l10n.langSaved), backgroundColor: const Color(0xFF16A34A)),
    );
  }

  // Shows the language choices and delegates the change to the locale provider.
  Future<void> _pickLanguage(AppLocalizations t) async {
    // Reads the provider without rebuilding this method's caller.
    final localeProvider = context.read<LocaleProvider>();
    // Uses the language code as the radio group's current value.
    final current = localeProvider.locale.languageCode;
    // Language selection is handled by LocaleProvider rather than preferences.
    final selected = await showDialog<String>(
      context: context,
      // Builds the language dialog using the supplied translations.
      builder: (dialogContext) => SimpleDialog(
        // Displays the localized language-picker title.
        title: Text(t.langChooseLanguage),
        children: [
          // Ensures the language choices behave as one radio group.
          RadioGroup<String>(
            groupValue: current,
            // Returns the selected language code to the caller.
            onChanged: (v) => Navigator.pop(dialogContext, v),
            child: Column(
              // Keeps the language list compact.
              mainAxisSize: MainAxisSize.min,
              children: [
                // Provides the English language choice.
                RadioListTile<String>(
                  value: 'en',
                  title: Text(t.langEnglish),
                  activeColor: const Color(0xFF16A34A),
                ),
                // Provides the Bangla language choice.
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
    // Leaves the current locale unchanged when the dialog is cancelled.
    if (selected == null || selected == current) return;
    // Applies the new locale through the central locale provider.
    await localeProvider.setLocale(Locale(selected));
    // Avoids accessing the scaffold after disposal.
    if (!mounted) return;
    // Confirms the language preference change to the user.
    ScaffoldMessenger.of(context).showSnackBar(
      // Reuses the same localized success message as other preferences.
      SnackBar(content: Text(context.l10n.langSaved), backgroundColor: const Color(0xFF16A34A)),
    );
  }

  // Builds the complete preferences screen from the current state.
  @override
  Widget build(BuildContext context) {
    // Derive the screen colors from the active theme.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Chooses the primary text color for the active brightness.
    final textColor = isDark ? Colors.white : const Color(0xFF121212);
    // Chooses the secondary text color for supporting values.
    final subColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575);
    // Chooses the surface color for the settings container.
    final cardColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
    // Chooses a border color that remains visible in either theme.
    final borderColor = isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2);
    // Reads all translated labels used by this screen.
    final t = context.l10n;
    // Converts the active locale code into the displayed language label.
    final languageLabel = context.watch<LocaleProvider>().locale.languageCode == 'bn' ? t.langBangla : t.langEnglish;

    // Places the preference content inside the shared application shell.
    return AppLayout(
      title: t.langTitle,
      subtitle: t.langSubtitle,
      currentRoute: '/profile',
      // Provides the bordered surface that contains all preference rows.
      child: Container(
        decoration: BoxDecoration(
          // Applies the theme-aware surface color.
          color: cardColor,
          // Rounds the outer corners of the preference surface.
          borderRadius: BorderRadius.circular(16),
          // Adds a subtle outline around the surface.
          border: Border.fromBorderSide(BorderSide(color: borderColor)),
          // Adds a small shadow to separate the surface from the page.
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14), offset: const Offset(0, 4), blurRadius: 0)],
        ),
        // Stacks each preference row vertically.
        child: Column(
          children: [
            // Renders the language preference row.
            _RegionTile(
              icon: Icons.language_outlined,
              title: t.langLanguage,
              subtitle: languageLabel,
              textColor: textColor,
              subColor: subColor,
              isDark: isDark,
              onTap: () => _pickLanguage(t),
            ),
            // Renders the region preference row.
            _RegionTile(
              icon: Icons.place_outlined,
              title: t.langRegion,
              subtitle: _region,
              textColor: textColor,
              subColor: subColor,
              isDark: isDark,
              onTap: () => _pick(
                // Supplies the translated region dialog title.
                title: t.langChooseRegion,
                options: _regionOptions,
                current: _region,
                prefsKey: 'pref_region',
                apply: (v) => setState(() => _region = v),
              ),
            ),
            // Renders the time zone preference row.
            _RegionTile(
              icon: Icons.schedule_outlined,
              title: t.langTimeZone,
              subtitle: _timeZone,
              textColor: textColor,
              subColor: subColor,
              isDark: isDark,
              onTap: () => _pick(
                // Supplies the translated time zone dialog title.
                title: t.langChooseTimeZone,
                options: _timeZoneOptions,
                current: _timeZone,
                prefsKey: 'pref_timezone',
                apply: (v) => setState(() => _timeZone = v),
              ),
            ),
            // Renders the currency preference row.
            _RegionTile(
              icon: Icons.currency_exchange_outlined,
              title: t.langCurrency,
              subtitle: _currency,
              textColor: textColor,
              subColor: subColor,
              isDark: isDark,
              onTap: () => _pick(
                // Supplies the translated currency dialog title.
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
  // Stores the leading icon for the preference row.
  final IconData icon;
  // Stores the primary row label.
  final String title;
  // Stores the currently selected value shown below the label.
  final String subtitle;
  // Stores the theme-aware primary text color.
  final Color textColor;
  // Stores the theme-aware secondary text color.
  final Color subColor;
  // Indicates whether the active theme is dark.
  final bool isDark;
  // Stores the action invoked when the row is tapped.
  final VoidCallback onTap;

  // Creates a reusable row for one language or regional preference.
  const _RegionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.textColor,
    required this.subColor,
    required this.isDark,
    required this.onTap,
  });

  // Builds the consistent visual representation of a preference row.
  @override
  Widget build(BuildContext context) {
    // Keep each preference row visually consistent and independently tappable.
    return ListTile(
      // Shows the category icon at the start of the row.
      leading: Icon(icon, size: 20, color: const Color(0xFF16A34A)),
      // Shows the preference name using the primary text style.
      title: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textColor)),
      // Shows the selected value using the secondary text style.
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: subColor)),
      // Shows a forward indicator using a theme-aware muted color.
      trailing: Icon(Icons.arrow_forward_ios, size: 12, color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFBFBFBF)),
      // Uses compact vertical spacing for the settings list.
      dense: true,
      // Delegates taps to the action supplied by the parent screen.
      onTap: onTap,
    );
  }
}
