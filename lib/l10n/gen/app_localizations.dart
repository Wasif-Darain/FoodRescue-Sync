import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'FoodRescue Sync'**
  String get appTitle;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navConsumers.
  ///
  /// In en, this message translates to:
  /// **'Consumers'**
  String get navConsumers;

  /// No description provided for @navExpiry.
  ///
  /// In en, this message translates to:
  /// **'Expiry'**
  String get navExpiry;

  /// No description provided for @navDonations.
  ///
  /// In en, this message translates to:
  /// **'Donations'**
  String get navDonations;

  /// No description provided for @navProfileSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile & Settings'**
  String get navProfileSettings;

  /// No description provided for @navMarketplace.
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get navMarketplace;

  /// No description provided for @navRadar.
  ///
  /// In en, this message translates to:
  /// **'Radar'**
  String get navRadar;

  /// No description provided for @navRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get navRequests;

  /// No description provided for @navPickups.
  ///
  /// In en, this message translates to:
  /// **'Pickups'**
  String get navPickups;

  /// No description provided for @navOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get navOverview;

  /// No description provided for @navAccounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get navAccounts;

  /// No description provided for @navAdministrator.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get navAdministrator;

  /// No description provided for @navMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get navMember;

  /// No description provided for @navSwitchToLightMode.
  ///
  /// In en, this message translates to:
  /// **'Switch to Light Mode'**
  String get navSwitchToLightMode;

  /// No description provided for @navSwitchToDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Switch to Dark Mode'**
  String get navSwitchToDarkMode;

  /// No description provided for @navSwitchToConsumerMode.
  ///
  /// In en, this message translates to:
  /// **'Switch to Consumer Mode'**
  String get navSwitchToConsumerMode;

  /// No description provided for @navSwitchToDonorMode.
  ///
  /// In en, this message translates to:
  /// **'Switch to Donor Mode'**
  String get navSwitchToDonorMode;

  /// No description provided for @navLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get navLogout;

  /// No description provided for @accountTypeRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get accountTypeRestaurant;

  /// No description provided for @accountTypeCaterer.
  ///
  /// In en, this message translates to:
  /// **'Caterer'**
  String get accountTypeCaterer;

  /// No description provided for @accountTypeStore.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get accountTypeStore;

  /// No description provided for @accountTypeNgo.
  ///
  /// In en, this message translates to:
  /// **'NGO'**
  String get accountTypeNgo;

  /// No description provided for @accountTypeFoodBank.
  ///
  /// In en, this message translates to:
  /// **'Food Bank'**
  String get accountTypeFoodBank;

  /// No description provided for @accountTypeShelter.
  ///
  /// In en, this message translates to:
  /// **'Shelter'**
  String get accountTypeShelter;

  /// No description provided for @accountTypeIndividual.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get accountTypeIndividual;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get commonSaveChanges;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get commonLoading;

  /// No description provided for @commonNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get commonNotSet;

  /// No description provided for @commonComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get commonComingSoon;

  /// No description provided for @profileSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile & Settings'**
  String get profileSettingsTitle;

  /// No description provided for @profileSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your account information'**
  String get profileSettingsSubtitle;

  /// No description provided for @profileQuickLinks.
  ///
  /// In en, this message translates to:
  /// **'Quick Links'**
  String get profileQuickLinks;

  /// No description provided for @profileEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEditProfile;

  /// No description provided for @profileNotificationPreferences.
  ///
  /// In en, this message translates to:
  /// **'Notification Preferences'**
  String get profileNotificationPreferences;

  /// No description provided for @profilePrivacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get profilePrivacySecurity;

  /// No description provided for @profileLanguageRegion.
  ///
  /// In en, this message translates to:
  /// **'Language & Region'**
  String get profileLanguageRegion;

  /// No description provided for @profileHelpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get profileHelpSupport;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @editProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your personal information'**
  String get editProfileSubtitle;

  /// No description provided for @editProfilePersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get editProfilePersonalInfo;

  /// No description provided for @editProfileFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get editProfileFullName;

  /// No description provided for @editProfileEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get editProfileEmailAddress;

  /// No description provided for @editProfilePhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get editProfilePhoneNumber;

  /// No description provided for @editProfileAccountType.
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get editProfileAccountType;

  /// No description provided for @editProfileLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get editProfileLocation;

  /// No description provided for @editProfileNotSetTapToPick.
  ///
  /// In en, this message translates to:
  /// **'Not set — tap to pick on map'**
  String get editProfileNotSetTapToPick;

  /// No description provided for @editProfileLocationUpdated.
  ///
  /// In en, this message translates to:
  /// **'Location updated!'**
  String get editProfileLocationUpdated;

  /// No description provided for @editProfileRadarNotifications.
  ///
  /// In en, this message translates to:
  /// **'Radar & Notifications'**
  String get editProfileRadarNotifications;

  /// No description provided for @editProfileRadarLabel.
  ///
  /// In en, this message translates to:
  /// **'Surplus Radar Radius'**
  String get editProfileRadarLabel;

  /// No description provided for @editProfileRadarHint.
  ///
  /// In en, this message translates to:
  /// **'Listings within this radius appear on the Radar map and trigger nearby notifications.'**
  String get editProfileRadarHint;

  /// No description provided for @editProfileUnattendedLabel.
  ///
  /// In en, this message translates to:
  /// **'Unattended Listing Alert'**
  String get editProfileUnattendedLabel;

  /// No description provided for @editProfileUnattendedHint.
  ///
  /// In en, this message translates to:
  /// **'Listings outside your radius that remain unclaimed for longer than this will still notify you.'**
  String get editProfileUnattendedHint;

  /// No description provided for @editProfileChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get editProfileChangePassword;

  /// No description provided for @editProfileCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get editProfileCurrentPassword;

  /// No description provided for @editProfileNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get editProfileNewPassword;

  /// No description provided for @editProfileProfileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated!'**
  String get editProfileProfileUpdated;

  /// No description provided for @editProfileNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name can\'t be empty.'**
  String get editProfileNameRequired;

  /// No description provided for @editProfileEnterCurrentAndNew.
  ///
  /// In en, this message translates to:
  /// **'Enter both your current and new password to change it.'**
  String get editProfileEnterCurrentAndNew;

  /// No description provided for @editProfilePasswordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully.'**
  String get editProfilePasswordChanged;

  /// No description provided for @editProfileWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'New password should be at least 8 characters.'**
  String get editProfileWeakPassword;

  /// No description provided for @editProfileWrongCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password is incorrect.'**
  String get editProfileWrongCurrentPassword;

  /// No description provided for @notifPrefsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification Preferences'**
  String get notifPrefsTitle;

  /// No description provided for @notifPrefsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose what you want to be notified about'**
  String get notifPrefsSubtitle;

  /// No description provided for @notifPrefsNewListings.
  ///
  /// In en, this message translates to:
  /// **'New Listings'**
  String get notifPrefsNewListings;

  /// No description provided for @notifPrefsNewListingsSub.
  ///
  /// In en, this message translates to:
  /// **'Get notified when new food listings are posted'**
  String get notifPrefsNewListingsSub;

  /// No description provided for @notifPrefsRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get notifPrefsRequests;

  /// No description provided for @notifPrefsRequestsSub.
  ///
  /// In en, this message translates to:
  /// **'Get notified about new donation requests'**
  String get notifPrefsRequestsSub;

  /// No description provided for @notifPrefsPickups.
  ///
  /// In en, this message translates to:
  /// **'Pickups'**
  String get notifPrefsPickups;

  /// No description provided for @notifPrefsPickupsSub.
  ///
  /// In en, this message translates to:
  /// **'Get notified about pickup coordination updates'**
  String get notifPrefsPickupsSub;

  /// No description provided for @notifPrefsPromotions.
  ///
  /// In en, this message translates to:
  /// **'Promotions'**
  String get notifPrefsPromotions;

  /// No description provided for @notifPrefsPromotionsSub.
  ///
  /// In en, this message translates to:
  /// **'Get notified about campaigns and promotions'**
  String get notifPrefsPromotionsSub;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacyTitle;

  /// No description provided for @privacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your account security settings'**
  String get privacySubtitle;

  /// No description provided for @privacyVisibility.
  ///
  /// In en, this message translates to:
  /// **'Profile Visibility'**
  String get privacyVisibility;

  /// No description provided for @privacyVisibilitySub.
  ///
  /// In en, this message translates to:
  /// **'Make your profile visible to other users'**
  String get privacyVisibilitySub;

  /// No description provided for @privacyLoginAlerts.
  ///
  /// In en, this message translates to:
  /// **'Login Alerts'**
  String get privacyLoginAlerts;

  /// No description provided for @privacyLoginAlertsSub.
  ///
  /// In en, this message translates to:
  /// **'Get notified about new device logins'**
  String get privacyLoginAlertsSub;

  /// No description provided for @privacyDataSharing.
  ///
  /// In en, this message translates to:
  /// **'Data Sharing'**
  String get privacyDataSharing;

  /// No description provided for @privacyDataSharingSub.
  ///
  /// In en, this message translates to:
  /// **'Allow anonymous usage data collection'**
  String get privacyDataSharingSub;

  /// No description provided for @langTitle.
  ///
  /// In en, this message translates to:
  /// **'Language & Region'**
  String get langTitle;

  /// No description provided for @langSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set your preferred language and region'**
  String get langSubtitle;

  /// No description provided for @langLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get langLanguage;

  /// No description provided for @langRegion.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get langRegion;

  /// No description provided for @langTimeZone.
  ///
  /// In en, this message translates to:
  /// **'Time Zone'**
  String get langTimeZone;

  /// No description provided for @langCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get langCurrency;

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @langBangla.
  ///
  /// In en, this message translates to:
  /// **'বাংলা'**
  String get langBangla;

  /// No description provided for @langChooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get langChooseLanguage;

  /// No description provided for @langChooseRegion.
  ///
  /// In en, this message translates to:
  /// **'Choose region'**
  String get langChooseRegion;

  /// No description provided for @langChooseTimeZone.
  ///
  /// In en, this message translates to:
  /// **'Choose time zone'**
  String get langChooseTimeZone;

  /// No description provided for @langChooseCurrency.
  ///
  /// In en, this message translates to:
  /// **'Choose currency'**
  String get langChooseCurrency;

  /// No description provided for @langSaved.
  ///
  /// In en, this message translates to:
  /// **'Preference saved'**
  String get langSaved;

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpTitle;

  /// No description provided for @helpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get help with using FoodRescue Sync'**
  String get helpSubtitle;

  /// No description provided for @helpFaq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get helpFaq;

  /// No description provided for @helpFaqSub.
  ///
  /// In en, this message translates to:
  /// **'Find answers to common questions'**
  String get helpFaqSub;

  /// No description provided for @helpContactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get helpContactSupport;

  /// No description provided for @helpContactSupportSub.
  ///
  /// In en, this message translates to:
  /// **'Reach out to our support team'**
  String get helpContactSupportSub;

  /// No description provided for @helpReportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report an Issue'**
  String get helpReportIssue;

  /// No description provided for @helpReportIssueSub.
  ///
  /// In en, this message translates to:
  /// **'Report a bug or technical problem'**
  String get helpReportIssueSub;

  /// No description provided for @helpTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get helpTerms;

  /// No description provided for @helpTermsSub.
  ///
  /// In en, this message translates to:
  /// **'Read our terms of service'**
  String get helpTermsSub;

  /// No description provided for @helpGetInTouch.
  ///
  /// In en, this message translates to:
  /// **'Get in Touch'**
  String get helpGetInTouch;

  /// No description provided for @helpRankingSystem.
  ///
  /// In en, this message translates to:
  /// **'Ranking System'**
  String get helpRankingSystem;

  /// No description provided for @helpRankingSystemSub.
  ///
  /// In en, this message translates to:
  /// **'Earn badges by donating food or rescuing meals. Higher tiers unlock more trust and visibility.'**
  String get helpRankingSystemSub;

  /// No description provided for @helpDonorTiers.
  ///
  /// In en, this message translates to:
  /// **'Donor Tiers'**
  String get helpDonorTiers;

  /// No description provided for @helpConsumerTiers.
  ///
  /// In en, this message translates to:
  /// **'Consumer Tiers'**
  String get helpConsumerTiers;

  /// No description provided for @helpMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the issue or your question…'**
  String get helpMessageHint;

  /// No description provided for @helpMessageSent.
  ///
  /// In en, this message translates to:
  /// **'Thanks — your message has been sent to our team.'**
  String get helpMessageSent;

  /// No description provided for @helpMessageEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please write a message first.'**
  String get helpMessageEmpty;

  /// No description provided for @helpSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get helpSend;

  /// No description provided for @helpFaqContent.
  ///
  /// In en, this message translates to:
  /// **'• How do I list surplus food?\nGo to the Donor dashboard and tap the + button to create a listing with photos, quantity and pickup details.\n\n• How do I claim a listing?\nBrowse the Marketplace or Surplus Radar, open a listing, and tap Claim or Request.\n\n• How are pickups coordinated?\nOnce a request is accepted, both sides see the pickup time and location under Pickups.\n\n• How do badges and tiers work?\nSee the Ranking System section below — tiers are computed automatically from your donation or rescue activity.'**
  String get helpFaqContent;

  /// No description provided for @helpTermsContent.
  ///
  /// In en, this message translates to:
  /// **'By using FoodRescue Sync you agree to list and request food in good faith, show up for scheduled pickups, and keep your account information accurate. Donors are responsible for the safety and accuracy of what they list; consumers are responsible for verifying food is suitable for their needs before consuming it. FoodRescue Sync is a coordination platform and is not itself a food safety authority.'**
  String get helpTermsContent;

  /// No description provided for @helpNoEmailApp.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open an email app on this device.'**
  String get helpNoEmailApp;

  /// No description provided for @welcomeHowWillYouHelp.
  ///
  /// In en, this message translates to:
  /// **'How will you help?'**
  String get welcomeHowWillYouHelp;

  /// No description provided for @welcomeDonor.
  ///
  /// In en, this message translates to:
  /// **'Donor'**
  String get welcomeDonor;

  /// No description provided for @welcomeDonorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Restaurants · Stores'**
  String get welcomeDonorSubtitle;

  /// No description provided for @welcomeFeatureInventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get welcomeFeatureInventory;

  /// No description provided for @welcomeConsumer.
  ///
  /// In en, this message translates to:
  /// **'Consumer'**
  String get welcomeConsumer;

  /// No description provided for @welcomeConsumerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'NGOs · Shelters'**
  String get welcomeConsumerSubtitle;

  /// No description provided for @welcomeGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get welcomeGetStarted;

  /// No description provided for @welcomeMealsPerDay.
  ///
  /// In en, this message translates to:
  /// **'Meals/day'**
  String get welcomeMealsPerDay;

  /// No description provided for @welcomeDonors.
  ///
  /// In en, this message translates to:
  /// **'Donors'**
  String get welcomeDonors;

  /// No description provided for @welcomePartners.
  ///
  /// In en, this message translates to:
  /// **'Partners'**
  String get welcomePartners;

  /// No description provided for @welcomeHeroLine1.
  ///
  /// In en, this message translates to:
  /// **'Fight Food Waste,\nOne '**
  String get welcomeHeroLine1;

  /// No description provided for @welcomeHeroHighlight.
  ///
  /// In en, this message translates to:
  /// **'Meal'**
  String get welcomeHeroHighlight;

  /// No description provided for @welcomeHeroLine2.
  ///
  /// In en, this message translates to:
  /// **' at a Time.'**
  String get welcomeHeroLine2;

  /// No description provided for @welcomeHeroTagline.
  ///
  /// In en, this message translates to:
  /// **'Connecting food donors with organizations and consumers — before it\'s wasted.'**
  String get welcomeHeroTagline;

  /// No description provided for @authWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get authWelcomeBack;

  /// No description provided for @authSignInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get authSignInToContinue;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// No description provided for @authLogIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get authLogIn;

  /// No description provided for @authOr.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get authOr;

  /// No description provided for @authSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get authSignUp;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get authCreateAccount;

  /// No description provided for @authStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Step 1 of 2 · Tell us about you'**
  String get authStep1Title;

  /// No description provided for @authAccountType.
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get authAccountType;

  /// No description provided for @authEnterName.
  ///
  /// In en, this message translates to:
  /// **'Enter name'**
  String get authEnterName;

  /// No description provided for @authNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get authNext;

  /// No description provided for @authBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get authBack;

  /// No description provided for @authStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Step 2 of 2 · Contact & security'**
  String get authStep2Title;

  /// No description provided for @authPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get authPhoneNumber;

  /// No description provided for @authAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get authAddress;

  /// No description provided for @authAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Business / organization address'**
  String get authAddressHint;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authEnterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get authEnterYourPassword;

  /// No description provided for @authPasswordStrength.
  ///
  /// In en, this message translates to:
  /// **'Strength: {strength}'**
  String authPasswordStrength(String strength);

  /// No description provided for @authPasswordNotStrong.
  ///
  /// In en, this message translates to:
  /// **'Password is not strong enough. It must be at least {minLength} characters and include uppercase, lowercase, number, and special character.'**
  String authPasswordNotStrong(int minLength);

  /// No description provided for @accountTypeNameRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Restaurant Name'**
  String get accountTypeNameRestaurant;

  /// No description provided for @accountTypeNameCaterer.
  ///
  /// In en, this message translates to:
  /// **'Business Name'**
  String get accountTypeNameCaterer;

  /// No description provided for @accountTypeNameStore.
  ///
  /// In en, this message translates to:
  /// **'Store Name'**
  String get accountTypeNameStore;

  /// No description provided for @accountTypeNameNgo.
  ///
  /// In en, this message translates to:
  /// **'Organization Name'**
  String get accountTypeNameNgo;

  /// No description provided for @accountTypeNameFoodBank.
  ///
  /// In en, this message translates to:
  /// **'Food Bank Name'**
  String get accountTypeNameFoodBank;

  /// No description provided for @accountTypeNameShelter.
  ///
  /// In en, this message translates to:
  /// **'Shelter Name'**
  String get accountTypeNameShelter;

  /// No description provided for @accountTypeNameIndividual.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get accountTypeNameIndividual;

  /// No description provided for @pwStrengthEmpty.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get pwStrengthEmpty;

  /// No description provided for @pwStrengthWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get pwStrengthWeak;

  /// No description provided for @pwStrengthFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get pwStrengthFair;

  /// No description provided for @pwStrengthGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get pwStrengthGood;

  /// No description provided for @pwStrengthStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get pwStrengthStrong;

  /// No description provided for @pwCriterionLength.
  ///
  /// In en, this message translates to:
  /// **'At least {minLength} characters'**
  String pwCriterionLength(int minLength);

  /// No description provided for @pwCriterionUppercase.
  ///
  /// In en, this message translates to:
  /// **'Contains an uppercase letter'**
  String get pwCriterionUppercase;

  /// No description provided for @pwCriterionLowercase.
  ///
  /// In en, this message translates to:
  /// **'Contains a lowercase letter'**
  String get pwCriterionLowercase;

  /// No description provided for @pwCriterionNumber.
  ///
  /// In en, this message translates to:
  /// **'Contains a number'**
  String get pwCriterionNumber;

  /// No description provided for @pwCriterionSpecial.
  ///
  /// In en, this message translates to:
  /// **'Contains a special character'**
  String get pwCriterionSpecial;

  /// No description provided for @recoveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Account recovery'**
  String get recoveryTitle;

  /// No description provided for @recoveryBackTooltip.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get recoveryBackTooltip;

  /// No description provided for @recoveryHeading.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get recoveryHeading;

  /// No description provided for @recoveryBody.
  ///
  /// In en, this message translates to:
  /// **'Enter your account email and we’ll send you a link to reset your password.'**
  String get recoveryBody;

  /// No description provided for @recoveryEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get recoveryEmailLabel;

  /// No description provided for @recoverySending.
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get recoverySending;

  /// No description provided for @recoverySendLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get recoverySendLink;

  /// No description provided for @recoveryBackToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get recoveryBackToSignIn;

  /// No description provided for @recoveryInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get recoveryInvalidEmail;

  /// No description provided for @recoveryLinkSent.
  ///
  /// In en, this message translates to:
  /// **'A password reset link was sent to {email}.'**
  String recoveryLinkSent(String email);

  /// No description provided for @donorDashTitle.
  ///
  /// In en, this message translates to:
  /// **'Donor Dashboard'**
  String get donorDashTitle;

  /// No description provided for @donorDashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your inventory, listings, and track donations'**
  String get donorDashSubtitle;

  /// No description provided for @donorDashGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi, {firstName}!'**
  String donorDashGreeting(String firstName);

  /// No description provided for @donorDashContributor.
  ///
  /// In en, this message translates to:
  /// **'Contributor'**
  String get donorDashContributor;

  /// No description provided for @donorDashInventoryGreatShape.
  ///
  /// In en, this message translates to:
  /// **'Your inventory is in great shape today.'**
  String get donorDashInventoryGreatShape;

  /// No description provided for @donorDashItemsReady.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 item ready to redistribute today.} other{{count} items ready to redistribute today.}}'**
  String donorDashItemsReady(int count);

  /// No description provided for @donorDashTotalItems.
  ///
  /// In en, this message translates to:
  /// **'Total Items'**
  String get donorDashTotalItems;

  /// No description provided for @donorDashSurplusTagged.
  ///
  /// In en, this message translates to:
  /// **'Surplus Tagged'**
  String get donorDashSurplusTagged;

  /// No description provided for @donorDashNeedRedistribution.
  ///
  /// In en, this message translates to:
  /// **'Need redistribution'**
  String get donorDashNeedRedistribution;

  /// No description provided for @donorDashActiveListings.
  ///
  /// In en, this message translates to:
  /// **'Active Listings'**
  String get donorDashActiveListings;

  /// No description provided for @donorDashFoodSavedKg.
  ///
  /// In en, this message translates to:
  /// **'Food Saved (kg)'**
  String get donorDashFoodSavedKg;

  /// No description provided for @donorDashEstimated.
  ///
  /// In en, this message translates to:
  /// **'Estimated'**
  String get donorDashEstimated;

  /// No description provided for @donorDashExpiringToday.
  ///
  /// In en, this message translates to:
  /// **'Expiring Today'**
  String get donorDashExpiringToday;

  /// No description provided for @commonViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get commonViewAll;

  /// No description provided for @donorDashCreateNew.
  ///
  /// In en, this message translates to:
  /// **'Create new'**
  String get donorDashCreateNew;

  /// No description provided for @donorDashQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get donorDashQuickActions;

  /// No description provided for @donorDashCheckExpiry.
  ///
  /// In en, this message translates to:
  /// **'Check Expiry'**
  String get donorDashCheckExpiry;

  /// No description provided for @donorDashDonationLog.
  ///
  /// In en, this message translates to:
  /// **'Donation Log'**
  String get donorDashDonationLog;

  /// No description provided for @donorDashRewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get donorDashRewards;

  /// No description provided for @donorDashLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get donorDashLeaderboard;

  /// No description provided for @donorDashRecentDonations.
  ///
  /// In en, this message translates to:
  /// **'Recent Donations'**
  String get donorDashRecentDonations;

  /// No description provided for @donorDashNoDonationHistory.
  ///
  /// In en, this message translates to:
  /// **'Donation history will appear here once you complete donations.'**
  String get donorDashNoDonationHistory;

  /// No description provided for @donorDashExpiresToday.
  ///
  /// In en, this message translates to:
  /// **'Expires today'**
  String get donorDashExpiresToday;

  /// No description provided for @donorDashQtyLabel.
  ///
  /// In en, this message translates to:
  /// **'{category} · Qty: {quantity}'**
  String donorDashQtyLabel(String category, int quantity);

  /// No description provided for @commonFree.
  ///
  /// In en, this message translates to:
  /// **'FREE'**
  String get commonFree;

  /// No description provided for @mktTitle.
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get mktTitle;

  /// No description provided for @mktSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse nearby surplus food listings'**
  String get mktSubtitle;

  /// No description provided for @mktGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi, {firstName}!'**
  String mktGreeting(String firstName);

  /// No description provided for @mktListingsNear.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 surplus listing near you right now.} other{{count} surplus listings near you right now.}}'**
  String mktListingsNear(int count);

  /// No description provided for @mktQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get mktQuickActions;

  /// No description provided for @mktSurplusRadar.
  ///
  /// In en, this message translates to:
  /// **'Surplus Radar'**
  String get mktSurplusRadar;

  /// No description provided for @mktBulkRequest.
  ///
  /// In en, this message translates to:
  /// **'Bulk Request'**
  String get mktBulkRequest;

  /// No description provided for @mktRequestStatus.
  ///
  /// In en, this message translates to:
  /// **'Request Status'**
  String get mktRequestStatus;

  /// No description provided for @mktRewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get mktRewards;

  /// No description provided for @mktLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get mktLeaderboard;

  /// No description provided for @mktSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search food listings...'**
  String get mktSearchHint;

  /// No description provided for @mktFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get mktFilterAll;

  /// No description provided for @mktFilterFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get mktFilterFree;

  /// No description provided for @mktFilterSale.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get mktFilterSale;

  /// No description provided for @mktCatAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get mktCatAll;

  /// No description provided for @mktCatCookedMeals.
  ///
  /// In en, this message translates to:
  /// **'Cooked Meals'**
  String get mktCatCookedMeals;

  /// No description provided for @mktCatBakery.
  ///
  /// In en, this message translates to:
  /// **'Bakery'**
  String get mktCatBakery;

  /// No description provided for @mktCatDairy.
  ///
  /// In en, this message translates to:
  /// **'Dairy'**
  String get mktCatDairy;

  /// No description provided for @mktCatProduce.
  ///
  /// In en, this message translates to:
  /// **'Produce'**
  String get mktCatProduce;

  /// No description provided for @mktCatGrains.
  ///
  /// In en, this message translates to:
  /// **'Grains'**
  String get mktCatGrains;

  /// No description provided for @mktNoListings.
  ///
  /// In en, this message translates to:
  /// **'No listings available'**
  String get mktNoListings;

  /// No description provided for @mktCheckBackSoon.
  ///
  /// In en, this message translates to:
  /// **'Check back soon for new surplus food listings.'**
  String get mktCheckBackSoon;

  /// No description provided for @mktListedBy.
  ///
  /// In en, this message translates to:
  /// **'Listed by {donorName}'**
  String mktListedBy(String donorName);

  /// No description provided for @mktQtyBadge.
  ///
  /// In en, this message translates to:
  /// **'Qty: {quantity}'**
  String mktQtyBadge(int quantity);

  /// No description provided for @mktKmBadge.
  ///
  /// In en, this message translates to:
  /// **'{distance} km'**
  String mktKmBadge(String distance);

  /// No description provided for @mktPickupBy.
  ///
  /// In en, this message translates to:
  /// **'Pickup by: {time} · {date}'**
  String mktPickupBy(String time, String date);

  /// No description provided for @mktDeliveryAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Delivery address — tap to pick on map'**
  String get mktDeliveryAddressHint;

  /// No description provided for @mktClaimNow.
  ///
  /// In en, this message translates to:
  /// **'Claim Now'**
  String get mktClaimNow;

  /// No description provided for @mktSchedulePickup.
  ///
  /// In en, this message translates to:
  /// **'Schedule Pickup'**
  String get mktSchedulePickup;

  /// No description provided for @mktClaimedMsg.
  ///
  /// In en, this message translates to:
  /// **'Claimed: {title}'**
  String mktClaimedMsg(String title);

  /// No description provided for @mktClaimFailedMsg.
  ///
  /// In en, this message translates to:
  /// **'Failed to claim: {title}'**
  String mktClaimFailedMsg(String title);

  /// No description provided for @mktScheduledMsg.
  ///
  /// In en, this message translates to:
  /// **'Scheduled pickup for {title}'**
  String mktScheduledMsg(String title);

  /// No description provided for @mktExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get mktExpired;

  /// No description provided for @mktClaimFree.
  ///
  /// In en, this message translates to:
  /// **'Claim Free'**
  String get mktClaimFree;

  /// No description provided for @mktDetailCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get mktDetailCategory;

  /// No description provided for @mktDetailQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get mktDetailQuantity;

  /// No description provided for @mktDetailPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get mktDetailPrice;

  /// No description provided for @mktDetailPickupWindow.
  ///
  /// In en, this message translates to:
  /// **'Pickup window'**
  String get mktDetailPickupWindow;

  /// No description provided for @mktDetailAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get mktDetailAddress;

  /// No description provided for @commonFreeLabel.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get commonFreeLabel;

  /// No description provided for @areaGulshan.
  ///
  /// In en, this message translates to:
  /// **'Gulshan 1, Dhaka'**
  String get areaGulshan;

  /// No description provided for @areaBanani.
  ///
  /// In en, this message translates to:
  /// **'Banani, Dhaka'**
  String get areaBanani;

  /// No description provided for @areaDhanmondi.
  ///
  /// In en, this message translates to:
  /// **'Dhanmondi, Dhaka'**
  String get areaDhanmondi;

  /// No description provided for @areaUttara.
  ///
  /// In en, this message translates to:
  /// **'Uttara, Dhaka'**
  String get areaUttara;

  /// No description provided for @areaMirpur.
  ///
  /// In en, this message translates to:
  /// **'Mirpur, Dhaka'**
  String get areaMirpur;

  /// No description provided for @areaBashundhara.
  ///
  /// In en, this message translates to:
  /// **'Bashundhara, Dhaka'**
  String get areaBashundhara;

  /// No description provided for @areaMohammadpur.
  ///
  /// In en, this message translates to:
  /// **'Mohammadpur, Dhaka'**
  String get areaMohammadpur;

  /// No description provided for @adminOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin Overview'**
  String get adminOverviewTitle;

  /// No description provided for @adminOverviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Platform-wide donations, consumption & accounts'**
  String get adminOverviewSubtitle;

  /// No description provided for @adminRegisteredAccounts.
  ///
  /// In en, this message translates to:
  /// **'Registered Accounts'**
  String get adminRegisteredAccounts;

  /// No description provided for @adminPendingApprovals.
  ///
  /// In en, this message translates to:
  /// **'Pending Approvals'**
  String get adminPendingApprovals;

  /// No description provided for @adminNeedsReview.
  ///
  /// In en, this message translates to:
  /// **'Needs review'**
  String get adminNeedsReview;

  /// No description provided for @adminAllCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'All caught up'**
  String get adminAllCaughtUp;

  /// No description provided for @adminManageAccounts.
  ///
  /// In en, this message translates to:
  /// **'Manage Accounts'**
  String get adminManageAccounts;

  /// No description provided for @adminAccountsWaiting.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 account waiting for approval} other{{count} accounts waiting for approval}}'**
  String adminAccountsWaiting(int count);

  /// No description provided for @adminReviewApproveRemove.
  ///
  /// In en, this message translates to:
  /// **'Review, approve, or remove accounts'**
  String get adminReviewApproveRemove;

  /// No description provided for @acctMgmtTitle.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get acctMgmtTitle;

  /// No description provided for @acctMgmtSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Approve, suspend, or remove registered accounts'**
  String get acctMgmtSubtitle;

  /// No description provided for @acctMgmtFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All ({count})'**
  String acctMgmtFilterAll(int count);

  /// No description provided for @acctMgmtFilterPending.
  ///
  /// In en, this message translates to:
  /// **'Pending ({count})'**
  String acctMgmtFilterPending(int count);

  /// No description provided for @acctMgmtFilterApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved ({count})'**
  String acctMgmtFilterApproved(int count);

  /// No description provided for @acctMgmtFilterSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended ({count})'**
  String acctMgmtFilterSuspended(int count);

  /// No description provided for @acctMgmtNoAccounts.
  ///
  /// In en, this message translates to:
  /// **'No accounts in this filter.'**
  String get acctMgmtNoAccounts;

  /// No description provided for @acctMgmtAccountDetails.
  ///
  /// In en, this message translates to:
  /// **'Account details'**
  String get acctMgmtAccountDetails;

  /// No description provided for @acctMgmtRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get acctMgmtRole;

  /// No description provided for @acctMgmtDonor.
  ///
  /// In en, this message translates to:
  /// **'Donor'**
  String get acctMgmtDonor;

  /// No description provided for @acctMgmtConsumer.
  ///
  /// In en, this message translates to:
  /// **'Consumer'**
  String get acctMgmtConsumer;

  /// No description provided for @acctMgmtAccountType.
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get acctMgmtAccountType;

  /// No description provided for @acctMgmtJoined.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get acctMgmtJoined;

  /// No description provided for @acctMgmtJoinedTag.
  ///
  /// In en, this message translates to:
  /// **'Joined {date}'**
  String acctMgmtJoinedTag(String date);

  /// No description provided for @acctMgmtStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get acctMgmtStatus;

  /// No description provided for @acctMgmtStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get acctMgmtStatusPending;

  /// No description provided for @acctMgmtStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get acctMgmtStatusApproved;

  /// No description provided for @acctMgmtStatusSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get acctMgmtStatusSuspended;

  /// No description provided for @acctMgmtApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get acctMgmtApprove;

  /// No description provided for @acctMgmtSuspend.
  ///
  /// In en, this message translates to:
  /// **'Suspend'**
  String get acctMgmtSuspend;

  /// No description provided for @acctMgmtRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get acctMgmtRemove;

  /// No description provided for @acctMgmtRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove account?'**
  String get acctMgmtRemoveTitle;

  /// No description provided for @acctMgmtRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'This will permanently remove \"{name}\" from the platform.'**
  String acctMgmtRemoveBody(String name);

  /// No description provided for @notifCenterTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifCenterTitle;

  /// No description provided for @notifCenterUnread.
  ///
  /// In en, this message translates to:
  /// **'{count} unread notifications'**
  String notifCenterUnread(int count);

  /// No description provided for @notifCenterMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get notifCenterMarkAllRead;

  /// No description provided for @notifCenterEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get notifCenterEmpty;

  /// No description provided for @rewardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get rewardsTitle;

  /// No description provided for @rewardsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track your achievements and earn badges'**
  String get rewardsSubtitle;

  /// No description provided for @rewardsGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi, {firstName}!'**
  String rewardsGreeting(String firstName);

  /// No description provided for @rewardsEarnedSummary.
  ///
  /// In en, this message translates to:
  /// **'You\'ve earned {points} points this {period} and reached {level} level.'**
  String rewardsEarnedSummary(int points, String period, String level);

  /// No description provided for @rewardsKgSavedToward.
  ///
  /// In en, this message translates to:
  /// **'{kg} kg saved toward Platinum'**
  String rewardsKgSavedToward(String kg);

  /// No description provided for @rewardsTimeframeWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get rewardsTimeframeWeekly;

  /// No description provided for @rewardsTimeframeMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get rewardsTimeframeMonthly;

  /// No description provided for @rewardsTimeframeYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get rewardsTimeframeYearly;

  /// No description provided for @rewardsPeriodWeek.
  ///
  /// In en, this message translates to:
  /// **'week'**
  String get rewardsPeriodWeek;

  /// No description provided for @rewardsPeriodMonth.
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get rewardsPeriodMonth;

  /// No description provided for @rewardsPeriodYear.
  ///
  /// In en, this message translates to:
  /// **'year'**
  String get rewardsPeriodYear;

  /// No description provided for @rewardsPointsThisPeriod.
  ///
  /// In en, this message translates to:
  /// **'Points This {period}'**
  String rewardsPointsThisPeriod(String period);

  /// No description provided for @rewardsFromRealActivity.
  ///
  /// In en, this message translates to:
  /// **'From real activity'**
  String get rewardsFromRealActivity;

  /// No description provided for @rewardsCurrentLevel.
  ///
  /// In en, this message translates to:
  /// **'Current Level'**
  String get rewardsCurrentLevel;

  /// No description provided for @rewardsPointsNow.
  ///
  /// In en, this message translates to:
  /// **'{points} points now'**
  String rewardsPointsNow(int points);

  /// No description provided for @rewardsRescuedMeals.
  ///
  /// In en, this message translates to:
  /// **'Rescued Meals'**
  String get rewardsRescuedMeals;

  /// No description provided for @rewardsDonationsPlusPickups.
  ///
  /// In en, this message translates to:
  /// **'Donations + pickups'**
  String get rewardsDonationsPlusPickups;

  /// No description provided for @rewardsWeightSavedKg.
  ///
  /// In en, this message translates to:
  /// **'Weight Saved (kg)'**
  String get rewardsWeightSavedKg;

  /// No description provided for @rewardsAllTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get rewardsAllTime;

  /// No description provided for @rewardsBadges.
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get rewardsBadges;

  /// No description provided for @rewardsUnlocked.
  ///
  /// In en, this message translates to:
  /// **'{count} unlocked'**
  String rewardsUnlocked(int count);

  /// No description provided for @rewardsAchieved.
  ///
  /// In en, this message translates to:
  /// **'Achieved'**
  String get rewardsAchieved;

  /// No description provided for @rewardsLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get rewardsLocked;

  /// No description provided for @levelPlatinum.
  ///
  /// In en, this message translates to:
  /// **'Platinum'**
  String get levelPlatinum;

  /// No description provided for @levelGold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get levelGold;

  /// No description provided for @levelSilver.
  ///
  /// In en, this message translates to:
  /// **'Silver'**
  String get levelSilver;

  /// No description provided for @levelBronze.
  ///
  /// In en, this message translates to:
  /// **'Bronze'**
  String get levelBronze;

  /// No description provided for @levelNovice.
  ///
  /// In en, this message translates to:
  /// **'Novice'**
  String get levelNovice;

  /// No description provided for @badgeFirstDonationName.
  ///
  /// In en, this message translates to:
  /// **'First Donation'**
  String get badgeFirstDonationName;

  /// No description provided for @badgeFirstDonationDesc.
  ///
  /// In en, this message translates to:
  /// **'Made your first donation.'**
  String get badgeFirstDonationDesc;

  /// No description provided for @badgeActiveSaverName.
  ///
  /// In en, this message translates to:
  /// **'Active Saver'**
  String get badgeActiveSaverName;

  /// No description provided for @badgeActiveSaverDesc.
  ///
  /// In en, this message translates to:
  /// **'10+ donations logged.'**
  String get badgeActiveSaverDesc;

  /// No description provided for @badgeMealRescuerName.
  ///
  /// In en, this message translates to:
  /// **'Meal Rescuer'**
  String get badgeMealRescuerName;

  /// No description provided for @badgeMealRescuerDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete 5 pickups.'**
  String get badgeMealRescuerDesc;

  /// No description provided for @badge100kgName.
  ///
  /// In en, this message translates to:
  /// **'100 kg Saved'**
  String get badge100kgName;

  /// No description provided for @badge100kgDesc.
  ///
  /// In en, this message translates to:
  /// **'Reach 100 kg of food saved.'**
  String get badge100kgDesc;

  /// No description provided for @badgeCommunityStarName.
  ///
  /// In en, this message translates to:
  /// **'Community Star'**
  String get badgeCommunityStarName;

  /// No description provided for @badgeCommunityStarDesc.
  ///
  /// In en, this message translates to:
  /// **'Inspire others to join the platform.'**
  String get badgeCommunityStarDesc;

  /// No description provided for @lbTitle.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get lbTitle;

  /// No description provided for @lbSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Top donors and consumers this {period}'**
  String lbSubtitle(String period);

  /// No description provided for @lbGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi, {firstName}!'**
  String lbGreeting(String firstName);

  /// No description provided for @lbSeeWhosLeading.
  ///
  /// In en, this message translates to:
  /// **'See who\'s leading this {period}.'**
  String lbSeeWhosLeading(String period);

  /// No description provided for @lbTopDonors.
  ///
  /// In en, this message translates to:
  /// **'Top Donors'**
  String get lbTopDonors;

  /// No description provided for @lbTopConsumers.
  ///
  /// In en, this message translates to:
  /// **'Top Consumers'**
  String get lbTopConsumers;

  /// No description provided for @lbTop5.
  ///
  /// In en, this message translates to:
  /// **'Top 5'**
  String get lbTop5;

  /// No description provided for @lbNoActivity.
  ///
  /// In en, this message translates to:
  /// **'No activity this {period}.'**
  String lbNoActivity(String period);

  /// No description provided for @lbNoActivityShort.
  ///
  /// In en, this message translates to:
  /// **'No activity this {period}'**
  String lbNoActivityShort(String period);

  /// No description provided for @lbItemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String lbItemsCount(int count);

  /// No description provided for @lbYou.
  ///
  /// In en, this message translates to:
  /// **'YOU'**
  String get lbYou;

  /// No description provided for @lbYourPosition.
  ///
  /// In en, this message translates to:
  /// **'Your current position'**
  String get lbYourPosition;

  /// No description provided for @expiryTitle.
  ///
  /// In en, this message translates to:
  /// **'Expiry Tracker'**
  String get expiryTitle;

  /// No description provided for @expirySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Monitor your inventory expiration dates'**
  String get expirySubtitle;

  /// No description provided for @expiryExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expiryExpired;

  /// No description provided for @expiryExpiresToday.
  ///
  /// In en, this message translates to:
  /// **'Expires Today'**
  String get expiryExpiresToday;

  /// No description provided for @expiryThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get expiryThisWeek;

  /// No description provided for @expirySafe.
  ///
  /// In en, this message translates to:
  /// **'Safe'**
  String get expirySafe;

  /// No description provided for @expiryExpiresThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Expires This Week'**
  String get expiryExpiresThisWeek;

  /// No description provided for @expirySafeItems.
  ///
  /// In en, this message translates to:
  /// **'Safe Items'**
  String get expirySafeItems;

  /// No description provided for @donationLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Donation Log'**
  String get donationLogTitle;

  /// No description provided for @donationLogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your complete donation history'**
  String get donationLogSubtitle;

  /// No description provided for @donationLogTotalDonations.
  ///
  /// In en, this message translates to:
  /// **'Total Donations'**
  String get donationLogTotalDonations;

  /// No description provided for @donationLogWeightKg.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get donationLogWeightKg;

  /// No description provided for @donationLogRecipients.
  ///
  /// In en, this message translates to:
  /// **'Recipients'**
  String get donationLogRecipients;

  /// No description provided for @donationLogEmpty.
  ///
  /// In en, this message translates to:
  /// **'No donations logged yet'**
  String get donationLogEmpty;

  /// No description provided for @donationLogCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get donationLogCompleted;

  /// No description provided for @donationLogRecipient.
  ///
  /// In en, this message translates to:
  /// **'Recipient: {id} · {date}'**
  String donationLogRecipient(String id, String date);

  /// No description provided for @donationLogRateThis.
  ///
  /// In en, this message translates to:
  /// **'Rate this donation'**
  String get donationLogRateThis;

  /// No description provided for @createListingTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Listing'**
  String get createListingTitle;

  /// No description provided for @createListingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'List your surplus food for donation or flash sale'**
  String get createListingSubtitle;

  /// No description provided for @createListingType.
  ///
  /// In en, this message translates to:
  /// **'Listing Type'**
  String get createListingType;

  /// No description provided for @createListingDonationFree.
  ///
  /// In en, this message translates to:
  /// **'Donation (Free)'**
  String get createListingDonationFree;

  /// No description provided for @createListingFlashSale.
  ///
  /// In en, this message translates to:
  /// **'Flash Sale'**
  String get createListingFlashSale;

  /// No description provided for @createListingTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get createListingTitleLabel;

  /// No description provided for @createListingTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Chicken Biryani (30 servings)'**
  String get createListingTitleHint;

  /// No description provided for @createListingDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get createListingDescription;

  /// No description provided for @createListingDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the food, quantity, freshness...'**
  String get createListingDescriptionHint;

  /// No description provided for @createListingPhotoOptional.
  ///
  /// In en, this message translates to:
  /// **'Photo (optional)'**
  String get createListingPhotoOptional;

  /// No description provided for @createListingPhotoHint.
  ///
  /// In en, this message translates to:
  /// **'Shown on this listing in the consumer marketplace.'**
  String get createListingPhotoHint;

  /// No description provided for @createListingCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get createListingCategory;

  /// No description provided for @createListingQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get createListingQuantity;

  /// No description provided for @createListingPrice.
  ///
  /// In en, this message translates to:
  /// **'Price (৳)'**
  String get createListingPrice;

  /// No description provided for @createListingPickupStart.
  ///
  /// In en, this message translates to:
  /// **'Pickup Start'**
  String get createListingPickupStart;

  /// No description provided for @createListingPickupEnd.
  ///
  /// In en, this message translates to:
  /// **'Pickup End'**
  String get createListingPickupEnd;

  /// No description provided for @createListingPickupLocation.
  ///
  /// In en, this message translates to:
  /// **'Pickup Location'**
  String get createListingPickupLocation;

  /// No description provided for @createListingCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get createListingCancel;

  /// No description provided for @createListingPostDonation.
  ///
  /// In en, this message translates to:
  /// **'Post Donation'**
  String get createListingPostDonation;

  /// No description provided for @createListingPostFlashSale.
  ///
  /// In en, this message translates to:
  /// **'Post Flash Sale'**
  String get createListingPostFlashSale;

  /// No description provided for @createListingSuccess.
  ///
  /// In en, this message translates to:
  /// **'Listing created successfully!'**
  String get createListingSuccess;

  /// No description provided for @createListingNoDetails.
  ///
  /// In en, this message translates to:
  /// **'No additional details provided.'**
  String get createListingNoDetails;

  /// No description provided for @catCookedMeals.
  ///
  /// In en, this message translates to:
  /// **'Cooked Meals'**
  String get catCookedMeals;

  /// No description provided for @catBakery.
  ///
  /// In en, this message translates to:
  /// **'Bakery'**
  String get catBakery;

  /// No description provided for @catDairy.
  ///
  /// In en, this message translates to:
  /// **'Dairy'**
  String get catDairy;

  /// No description provided for @catProduce.
  ///
  /// In en, this message translates to:
  /// **'Produce'**
  String get catProduce;

  /// No description provided for @catGrains.
  ///
  /// In en, this message translates to:
  /// **'Grains'**
  String get catGrains;

  /// No description provided for @catPulses.
  ///
  /// In en, this message translates to:
  /// **'Pulses'**
  String get catPulses;

  /// No description provided for @catOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get catOther;

  /// No description provided for @tierContributor.
  ///
  /// In en, this message translates to:
  /// **'Contributor'**
  String get tierContributor;

  /// No description provided for @tierProvider.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get tierProvider;

  /// No description provided for @tierPatron.
  ///
  /// In en, this message translates to:
  /// **'Patron'**
  String get tierPatron;

  /// No description provided for @tierMaster.
  ///
  /// In en, this message translates to:
  /// **'Master'**
  String get tierMaster;

  /// No description provided for @tierLegend.
  ///
  /// In en, this message translates to:
  /// **'Legend'**
  String get tierLegend;

  /// No description provided for @tierScout.
  ///
  /// In en, this message translates to:
  /// **'Scout'**
  String get tierScout;

  /// No description provided for @tierSaver.
  ///
  /// In en, this message translates to:
  /// **'Saver'**
  String get tierSaver;

  /// No description provided for @tierRescuer.
  ///
  /// In en, this message translates to:
  /// **'Rescuer'**
  String get tierRescuer;

  /// No description provided for @pickupSelf.
  ///
  /// In en, this message translates to:
  /// **'Self Pickup'**
  String get pickupSelf;

  /// No description provided for @pickupManagement.
  ///
  /// In en, this message translates to:
  /// **'Management Pickup'**
  String get pickupManagement;

  /// No description provided for @pickupRider.
  ///
  /// In en, this message translates to:
  /// **'Rider Delivery'**
  String get pickupRider;

  /// No description provided for @dcTitle.
  ///
  /// In en, this message translates to:
  /// **'Consumers'**
  String get dcTitle;

  /// No description provided for @dcSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Donate directly to consumers'**
  String get dcSubtitle;

  /// No description provided for @dcGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi, {firstName}!'**
  String dcGreeting(String firstName);

  /// No description provided for @dcConsumersAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 consumer available.} other{{count} consumers available.}}'**
  String dcConsumersAvailable(int count);

  /// No description provided for @dcAvailableForDonations.
  ///
  /// In en, this message translates to:
  /// **'Available for donations'**
  String get dcAvailableForDonations;

  /// No description provided for @dcDefaultPickupTime.
  ///
  /// In en, this message translates to:
  /// **'Default pickup time: {time}'**
  String dcDefaultPickupTime(String time);

  /// No description provided for @dcUpcomingDonations.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Donations'**
  String get dcUpcomingDonations;

  /// No description provided for @dcSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get dcSaveChanges;

  /// No description provided for @dcRescheduledMsg.
  ///
  /// In en, this message translates to:
  /// **'Pickup rescheduled — the consumer has been notified.'**
  String get dcRescheduledMsg;

  /// No description provided for @dcCancelDonationTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel donation?'**
  String get dcCancelDonationTitle;

  /// No description provided for @dcCancelDonationBody.
  ///
  /// In en, this message translates to:
  /// **'Cancel the donation scheduled for {name}?'**
  String dcCancelDonationBody(String name);

  /// No description provided for @dcKeepIt.
  ///
  /// In en, this message translates to:
  /// **'Keep it'**
  String get dcKeepIt;

  /// No description provided for @dcCancelDonation.
  ///
  /// In en, this message translates to:
  /// **'Cancel donation'**
  String get dcCancelDonation;

  /// No description provided for @dcCancelledMsg.
  ///
  /// In en, this message translates to:
  /// **'Donation cancelled — the consumer has been notified.'**
  String get dcCancelledMsg;

  /// No description provided for @dcSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search consumers...'**
  String get dcSearchHint;

  /// No description provided for @dcFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get dcFilterAll;

  /// No description provided for @dcFilterAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get dcFilterAvailable;

  /// No description provided for @dcFilterUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get dcFilterUnavailable;

  /// No description provided for @dcNoConsumersFound.
  ///
  /// In en, this message translates to:
  /// **'No consumers found'**
  String get dcNoConsumersFound;

  /// No description provided for @dcTryDifferentFilter.
  ///
  /// In en, this message translates to:
  /// **'Try a different search or filter.'**
  String get dcTryDifferentFilter;

  /// No description provided for @dcDonationScheduledFor.
  ///
  /// In en, this message translates to:
  /// **'Donation scheduled for {name}'**
  String dcDonationScheduledFor(String name);

  /// No description provided for @dcDonateTo.
  ///
  /// In en, this message translates to:
  /// **'Donate to {name}'**
  String dcDonateTo(String name);

  /// No description provided for @dcWhatDonating.
  ///
  /// In en, this message translates to:
  /// **'What are you donating?'**
  String get dcWhatDonating;

  /// No description provided for @dcItemHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Chicken Biryani (10 servings)'**
  String get dcItemHint;

  /// No description provided for @dcCollectionTime.
  ///
  /// In en, this message translates to:
  /// **'Collection time'**
  String get dcCollectionTime;

  /// No description provided for @dcCollectionLocation.
  ///
  /// In en, this message translates to:
  /// **'Collection location'**
  String get dcCollectionLocation;

  /// No description provided for @dcConfirmDonation.
  ///
  /// In en, this message translates to:
  /// **'Confirm Donation'**
  String get dcConfirmDonation;

  /// No description provided for @dcDescribeItemError.
  ///
  /// In en, this message translates to:
  /// **'Please describe what you are donating.'**
  String get dcDescribeItemError;

  /// No description provided for @dcValidQuantityError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid quantity.'**
  String get dcValidQuantityError;

  /// No description provided for @dcEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get dcEdit;

  /// No description provided for @dcCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dcCancel;

  /// No description provided for @dcQtyItemCategory.
  ///
  /// In en, this message translates to:
  /// **'{item} · {category} · Qty: {quantity}'**
  String dcQtyItemCategory(String item, String category, int quantity);

  /// No description provided for @dcAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get dcAvailable;

  /// No description provided for @dcUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get dcUnavailable;

  /// No description provided for @dcTimesDonated.
  ///
  /// In en, this message translates to:
  /// **'{count}x donated'**
  String dcTimesDonated(int count);

  /// No description provided for @dcNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get dcNew;

  /// No description provided for @dcDonate.
  ///
  /// In en, this message translates to:
  /// **'Donate'**
  String get dcDonate;

  /// No description provided for @imgMgrTitle.
  ///
  /// In en, this message translates to:
  /// **'Image Manager'**
  String get imgMgrTitle;

  /// No description provided for @imgMgrSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage photos for your food listings'**
  String get imgMgrSubtitle;

  /// No description provided for @imgMgrNoListings.
  ///
  /// In en, this message translates to:
  /// **'No listings yet.'**
  String get imgMgrNoListings;

  /// No description provided for @imgMgrAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get imgMgrAddPhoto;

  /// No description provided for @bulkReqTitle.
  ///
  /// In en, this message translates to:
  /// **'Bulk Request'**
  String get bulkReqTitle;

  /// No description provided for @bulkReqSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Submit large-scale food requests for your organization'**
  String get bulkReqSubtitle;

  /// No description provided for @bulkReqFillRequired.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields.'**
  String get bulkReqFillRequired;

  /// No description provided for @bulkReqAddOneItem.
  ///
  /// In en, this message translates to:
  /// **'Add at least one food item.'**
  String get bulkReqAddOneItem;

  /// No description provided for @bulkReqSuccess.
  ///
  /// In en, this message translates to:
  /// **'Bulk request submitted successfully!'**
  String get bulkReqSuccess;

  /// No description provided for @bulkReqOrgDetails.
  ///
  /// In en, this message translates to:
  /// **'Organization Details'**
  String get bulkReqOrgDetails;

  /// No description provided for @bulkReqOrgName.
  ///
  /// In en, this message translates to:
  /// **'Organization Name'**
  String get bulkReqOrgName;

  /// No description provided for @bulkReqOrgNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your NGO or food bank name'**
  String get bulkReqOrgNameHint;

  /// No description provided for @bulkReqContactPerson.
  ///
  /// In en, this message translates to:
  /// **'Contact Person'**
  String get bulkReqContactPerson;

  /// No description provided for @bulkReqFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get bulkReqFullName;

  /// No description provided for @bulkReqPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get bulkReqPhone;

  /// No description provided for @bulkReqAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery / Pickup Address'**
  String get bulkReqAddress;

  /// No description provided for @bulkReqAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Full address'**
  String get bulkReqAddressHint;

  /// No description provided for @bulkReqRequiredDate.
  ///
  /// In en, this message translates to:
  /// **'Required Date & Time'**
  String get bulkReqRequiredDate;

  /// No description provided for @bulkReqPeopleToFeed.
  ///
  /// In en, this message translates to:
  /// **'People to Feed'**
  String get bulkReqPeopleToFeed;

  /// No description provided for @bulkReqFoodItems.
  ///
  /// In en, this message translates to:
  /// **'Food Items'**
  String get bulkReqFoodItems;

  /// No description provided for @bulkReqAddItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get bulkReqAddItem;

  /// No description provided for @bulkReqItemNameHint.
  ///
  /// In en, this message translates to:
  /// **'Food item name'**
  String get bulkReqItemNameHint;

  /// No description provided for @bulkReqQtyHint.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get bulkReqQtyHint;

  /// No description provided for @bulkReqUnitHint.
  ///
  /// In en, this message translates to:
  /// **'Unit (kg/pcs)'**
  String get bulkReqUnitHint;

  /// No description provided for @bulkReqAdditionalNotes.
  ///
  /// In en, this message translates to:
  /// **'Additional Notes'**
  String get bulkReqAdditionalNotes;

  /// No description provided for @bulkReqNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Any dietary restrictions, special requirements, or notes...'**
  String get bulkReqNotesHint;

  /// No description provided for @bulkReqCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get bulkReqCancel;

  /// No description provided for @bulkReqSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get bulkReqSubmitting;

  /// No description provided for @bulkReqSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get bulkReqSubmit;

  /// No description provided for @pickupTitle.
  ///
  /// In en, this message translates to:
  /// **'Pickups'**
  String get pickupTitle;

  /// No description provided for @pickupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Coordinate and track your food pickups'**
  String get pickupSubtitle;

  /// No description provided for @pickupStatusScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get pickupStatusScheduled;

  /// No description provided for @pickupStatusEnRoute.
  ///
  /// In en, this message translates to:
  /// **'En Route'**
  String get pickupStatusEnRoute;

  /// No description provided for @pickupStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get pickupStatusCompleted;

  /// No description provided for @pickupActivePickups.
  ///
  /// In en, this message translates to:
  /// **'Active Pickups'**
  String get pickupActivePickups;

  /// No description provided for @pickupNoneScheduled.
  ///
  /// In en, this message translates to:
  /// **'No pickups scheduled'**
  String get pickupNoneScheduled;

  /// No description provided for @pickupHashId.
  ///
  /// In en, this message translates to:
  /// **'Pickup #{id}'**
  String pickupHashId(String id);

  /// No description provided for @pickupDetails.
  ///
  /// In en, this message translates to:
  /// **'Pickup details'**
  String get pickupDetails;

  /// No description provided for @pickupDetailStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get pickupDetailStatus;

  /// No description provided for @pickupDetailScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get pickupDetailScheduled;

  /// No description provided for @pickupDetailCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get pickupDetailCompleted;

  /// No description provided for @pickupDetailAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get pickupDetailAddress;

  /// No description provided for @pickupNoAddress.
  ///
  /// In en, this message translates to:
  /// **'No address'**
  String get pickupNoAddress;

  /// No description provided for @pickupOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get pickupOverdue;

  /// No description provided for @pickupRateThis.
  ///
  /// In en, this message translates to:
  /// **'Rate this pickup'**
  String get pickupRateThis;

  /// No description provided for @reqTrackerTitle.
  ///
  /// In en, this message translates to:
  /// **'My Requests'**
  String get reqTrackerTitle;

  /// No description provided for @reqTrackerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track the status of your food requests'**
  String get reqTrackerSubtitle;

  /// No description provided for @reqStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get reqStatusPending;

  /// No description provided for @reqStatusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get reqStatusAccepted;

  /// No description provided for @reqStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get reqStatusCompleted;

  /// No description provided for @reqStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get reqStatusRejected;

  /// No description provided for @reqTrackerEmpty.
  ///
  /// In en, this message translates to:
  /// **'No requests yet'**
  String get reqTrackerEmpty;

  /// No description provided for @reqTrackerEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Submit a bulk request to get started.'**
  String get reqTrackerEmptyHint;

  /// No description provided for @reqHashId.
  ///
  /// In en, this message translates to:
  /// **'Request #{id}'**
  String reqHashId(String id);

  /// No description provided for @reqDetails.
  ///
  /// In en, this message translates to:
  /// **'Bulk request details'**
  String get reqDetails;

  /// No description provided for @reqDetailStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get reqDetailStatus;

  /// No description provided for @reqDetailQuantity.
  ///
  /// In en, this message translates to:
  /// **'Requested Quantity'**
  String get reqDetailQuantity;

  /// No description provided for @reqDetailCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get reqDetailCreated;

  /// No description provided for @reqDetailLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last Updated'**
  String get reqDetailLastUpdated;

  /// No description provided for @reqQtyDate.
  ///
  /// In en, this message translates to:
  /// **'Qty: {quantity} {unit} · {date}'**
  String reqQtyDate(String quantity, String unit, String date);

  /// No description provided for @reqRateThis.
  ///
  /// In en, this message translates to:
  /// **'Rate this request'**
  String get reqRateThis;

  /// No description provided for @radarTitle.
  ///
  /// In en, this message translates to:
  /// **'Surplus Radar'**
  String get radarTitle;

  /// No description provided for @radarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover surplus food near you'**
  String get radarSubtitle;

  /// No description provided for @radarLive.
  ///
  /// In en, this message translates to:
  /// **'Live Radar'**
  String get radarLive;

  /// No description provided for @radarYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get radarYou;

  /// No description provided for @radarNearestFirst.
  ///
  /// In en, this message translates to:
  /// **'Nearest first'**
  String get radarNearestFirst;

  /// No description provided for @radarKmAway.
  ///
  /// In en, this message translates to:
  /// **'{km} km away'**
  String radarKmAway(String km);

  /// No description provided for @radarFindingRoute.
  ///
  /// In en, this message translates to:
  /// **'Finding route...'**
  String get radarFindingRoute;

  /// No description provided for @radarKmMinDrive.
  ///
  /// In en, this message translates to:
  /// **'{km} km · {min} min drive'**
  String radarKmMinDrive(String km, int min);

  /// No description provided for @commonCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get commonCall;

  /// No description provided for @commonEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get commonEmail;

  /// No description provided for @ratingTapToRate.
  ///
  /// In en, this message translates to:
  /// **'Tap to rate'**
  String get ratingTapToRate;

  /// No description provided for @ratingPoor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get ratingPoor;

  /// No description provided for @ratingFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get ratingFair;

  /// No description provided for @ratingGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get ratingGood;

  /// No description provided for @ratingVeryGood.
  ///
  /// In en, this message translates to:
  /// **'Very Good'**
  String get ratingVeryGood;

  /// No description provided for @ratingExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get ratingExcellent;

  /// No description provided for @ratingSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Rating submitted'**
  String get ratingSubmitted;

  /// No description provided for @ratingRateExperience.
  ///
  /// In en, this message translates to:
  /// **'Rate your experience'**
  String get ratingRateExperience;

  /// No description provided for @ratingWriteReview.
  ///
  /// In en, this message translates to:
  /// **'Write a review (optional)...'**
  String get ratingWriteReview;

  /// No description provided for @ratingSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit Rating'**
  String get ratingSubmit;

  /// No description provided for @pickDateTime.
  ///
  /// In en, this message translates to:
  /// **'Pick date & time'**
  String get pickDateTime;

  /// No description provided for @photoCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get photoCamera;

  /// No description provided for @photoGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get photoGallery;

  /// No description provided for @photoAccessError.
  ///
  /// In en, this message translates to:
  /// **'Could not access {source}: {error}'**
  String photoAccessError(String source, String error);

  /// No description provided for @locPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Location'**
  String get locPickerTitle;

  /// No description provided for @locPickerSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search an English address...'**
  String get locPickerSearchHint;

  /// No description provided for @locPickerSearchFailed.
  ///
  /// In en, this message translates to:
  /// **'Search failed. Please try again.'**
  String get locPickerSearchFailed;

  /// No description provided for @locPickerSearchUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the search service. Check your connection.'**
  String get locPickerSearchUnreachable;

  /// No description provided for @locPickerPinnedLocation.
  ///
  /// In en, this message translates to:
  /// **'Pinned location ({lat}, {lng})'**
  String locPickerPinnedLocation(String lat, String lng);

  /// No description provided for @locPickerResolving.
  ///
  /// In en, this message translates to:
  /// **'Resolving address...'**
  String get locPickerResolving;

  /// No description provided for @locPickerTapOrSearch.
  ///
  /// In en, this message translates to:
  /// **'Tap the map or search to pick a location'**
  String get locPickerTapOrSearch;

  /// No description provided for @locPickerConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm Location'**
  String get locPickerConfirm;

  /// No description provided for @tierDonorNoviceDesc.
  ///
  /// In en, this message translates to:
  /// **'Default starting rank upon registration.'**
  String get tierDonorNoviceDesc;

  /// No description provided for @tierDonorContributorDesc.
  ///
  /// In en, this message translates to:
  /// **'5+ listings created OR 25+ kg saved (≥80% fulfillment).'**
  String get tierDonorContributorDesc;

  /// No description provided for @tierDonorProviderDesc.
  ///
  /// In en, this message translates to:
  /// **'20+ listings OR 100+ kg saved (≥85% fulfillment, ≥3.8★, 3+ reviews).'**
  String get tierDonorProviderDesc;

  /// No description provided for @tierDonorPatronDesc.
  ///
  /// In en, this message translates to:
  /// **'50+ listings OR 300+ kg saved (≥90% fulfillment, ≥4.2★, 5+ reviews).'**
  String get tierDonorPatronDesc;

  /// No description provided for @tierDonorMasterDesc.
  ///
  /// In en, this message translates to:
  /// **'120+ listings OR 750+ kg saved (≥95% fulfillment, ≥4.5★, 10+ reviews).'**
  String get tierDonorMasterDesc;

  /// No description provided for @tierDonorLegendDesc.
  ///
  /// In en, this message translates to:
  /// **'250+ listings OR 1,500+ kg saved (top 2% regional, ≥4.7★).'**
  String get tierDonorLegendDesc;

  /// No description provided for @tierConsumerNoviceDesc.
  ///
  /// In en, this message translates to:
  /// **'Default starting rank (0–2 meals rescued).'**
  String get tierConsumerNoviceDesc;

  /// No description provided for @tierConsumerScoutDesc.
  ///
  /// In en, this message translates to:
  /// **'3–9 meals rescued/purchased.'**
  String get tierConsumerScoutDesc;

  /// No description provided for @tierConsumerSaverDesc.
  ///
  /// In en, this message translates to:
  /// **'10–24 meals rescued (≥85% on-time pickup, ≥3.8★, 3+ reviews).'**
  String get tierConsumerSaverDesc;

  /// No description provided for @tierConsumerRescuerDesc.
  ///
  /// In en, this message translates to:
  /// **'25–49 meals rescued (≥90% on-time pickup, ≥4.2★, 5+ reviews).'**
  String get tierConsumerRescuerDesc;

  /// No description provided for @tierConsumerMasterDesc.
  ///
  /// In en, this message translates to:
  /// **'50–99 meals rescued (≥95% on-time pickup, ≥4.5★, 10+ reviews).'**
  String get tierConsumerMasterDesc;

  /// No description provided for @tierConsumerLegendDesc.
  ///
  /// In en, this message translates to:
  /// **'100+ meals rescued (≥98% on-time pickup, ≥4.7★).'**
  String get tierConsumerLegendDesc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
