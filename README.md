# FoodRescue-Sync

Surplus food redistribution app connecting donors, consumers, and riders. Donors list surplus food, consumers discover and claim it, riders deliver it.

## Tech Stack

- Flutter, Dart
- Provider, GoRouter
- Firebase Auth, Cloud Firestore, Firebase Messaging, Firebase Hosting
- Cloudinary
- OpenStreetMap, OSRM, Nominatim
- Geolocator, Flutter TTS, Flutter Local Notifications
- Image Picker, HTTP, URL Launcher, Shared Preferences, Intl

## Prerequisites

- Flutter SDK 3.12+ (`flutter --version`)
- Firebase CLI (`firebase --version`) + access to the `foodrescue-sync` project
- Android: Android Studio + SDK, or a connected device with USB debugging
- iOS: macOS + Xcode (iOS builds only run on macOS)
- Web: Chrome

## Setup

- `git clone https://github.com/Wasif-Darain/FoodRescue-Sync.git`
- `cd FoodRescue-Sync`
- `flutter pub get`
- `flutterfire configure` (select `foodrescue-sync`; regenerates `lib/firebase_options.dart`)
- `flutter doctor`

## Run

- Android: `flutter run` (or `flutter run -d <device-id>`)
- iOS: `flutter run -d ios` (macOS only)
- Web: `flutter run -d chrome`

## Project Structure

- `lib/main.dart` — app entry, Firebase init, providers, router
- `lib/router.dart` — GoRouter routes and role guards
- `lib/screens/donor/` — dashboard, create listing, expiry tracker, donation log
- `lib/screens/consumer/` — marketplace, surplus radar, bulk request, request tracker, pickup coordination
- `lib/screens/rider/` — delivery pool, navigation, live tracking
- `lib/screens/admin/` — dashboard, accounts, user detail, reports, statistics
- `lib/screens/shared/` — profile, notifications, reviews, help, language, privacy
- `lib/screens/rewards/`, `lib/screens/leaderboard/` — tiers, points, rankings
- `lib/providers/` — auth, donor, consumer, rider, admin, theme, locale, block
- `lib/services/` — Cloudinary uploads, FCM service, push relay sender
- `lib/models/` — Firestore models
- `lib/widgets/` — layout and reusable UI
- `lib/l10n/` — English + Bengali strings
- `functions/` — Cloud Functions (FCM push, stats; needs Blaze to deploy)
- `apps_script/` — free push relay used instead of Cloud Functions
- `test/`, `integration_test/` — unit/widget and flow tests

## Key Features

- Role-based auth with admin approval (donor, consumer, rider, admin)
- Donor inventory with expiry tracking and surplus flags
- Donation and flash-sale listings with photos and pickup windows
- Marketplace with category filters and live countdowns
- Surplus Radar map with OSRM road routes
- Bulk requests, request tracking, pickup scheduling
- Rider pool with direct assignment, TTS navigation, live tracking
- Donation logs shared by donor and recipient
- Rewards tiers, points, badges, leaderboards from real activity
- Push + in-app notifications with per-type preferences
- Ratings, reviews, reports, user blocking
- English/Bengali UI with dark mode


## Firestore Collection Schema

The app reads and writes the following Firestore collections. Each document's fields are what the Dart models expect.

### `users`

* `uid` (string) — Firebase Auth UID
* `email` (string)
* `role` (string) — `donor`, `consumer`, or `admin`
* `name` (string)
* `profileRef` (DocumentReference) — points to `organization_profiles/{orgId}`
* `createdAt` (Timestamp)
* `latitude` (number, optional)
* `longitude` (number, optional)
* `address` (string, optional)

### `organization_profiles`

* `orgName` (string)
* `address` (string)
* `contactEmail` (string)
* `contactPhone` (string)
* `isVerified` (bool)
* `latitude` (number, optional)
* `longitude` (number, optional)

### `inventory_items`

* `donorId` (string) — user UID
* `name` (string)
* `barcode` (string, optional)
* `quantity` (number)
* `expiryDate` (Timestamp)
* `isSurplus` (bool)
* `category` (string) — e.g. `Cooked Meals`, `Bakery`, `Produce`
* `imageUrl` (string, optional)

### `listings`

* `donorId` (string)
* `donorName` (string)
* `title` (string)
* `description` (string)
* `category` (string)
* `price` (number)
* `quantity` (number)
* `unit` (string)
* `photoUrls` (List)
* `pickupStart` (Timestamp)
* `pickupEnd` (Timestamp)
* `latitude` (number)
* `longitude` (number)
* `address` (string, optional)
* `status` (string) — `active`, `claimed`, `expired`
* `claimDeadline` (Timestamp, optional)

### `requests`

* `consumerId` (string)
* `listingId` (string)
* `requestedQuantity` (number)
* `unit` (string)
* `status` (string) — `pending`, `accepted`, `rejected`, `completed`
* `createdAt` (Timestamp)
* `updatedAt` (Timestamp, optional)
* For bulk requests: `orgName`, `contactPerson`, `phone`, `address`, `requiredDate`, `peopleToFeed`, `items` (list of maps), `notes`

### `pickups`

* `requestId` (string)
* `consumerId` (string) — for consumer pickups
* `volunteerDriverId` (string, optional)
* `scheduledTime` (Timestamp, optional)
* `completedAt` (Timestamp, optional)
* `status` (string) — `scheduled`, `enRoute`, `completed`
* `latitude` (number)
* `longitude` (number)
* `address` (string, optional)

### `donation_logs`

* `donorId` (string)
* `recipientId` (string)
* `listingId` (string)
* `totalWeight` (number)
* `itemSummary` (Map<string, number>)
* `completedAt` (Timestamp)

### `notifications`

* `recipientUid` (string)
* `payloadType` (string) — e.g. `listing`, `request`, `pickup`, `system`
* `message` (string)
* `isRead` (bool)
* `createdAt` (Timestamp)

## Project Structure

The application follows a modular architecture:

1. **`lib/screens/`** — feature screens grouped by role (donor, consumer, admin, shared).
2. **`lib/widgets/`** — reusable layout and UI components.
3. **`lib/models/`** — Firestore-backed models with `fromFirestore`/`toMap`.
4. **`lib/providers/`** — Provider state management with Firebase integration.
5. **`lib/services/`** — external service integrations (Cloudinary image uploads).
6. **`lib/router.dart`** — GoRouter navigation.
7. **`lib/utils/`** — helpers (e.g., password validator, haversine distance).

```
FoodRescue-Sync/
|
|-- lib/
|   |-- screens/ (donor, consumer, shared, admin, ...)
|   |-- widgets/ (layout, ui)
|   |-- models/ (Firestore-backed models)
|   |-- providers/ (auth, donor, consumer, admin, theme)
|   |-- services/ (listing_image_manager)
|   |-- utils/
|   |-- firebase_options.dart (generated)
|   |-- main.dart
|   |-- router.dart
|
|-- functions/ (Cloud Functions — future)
|-- pubspec.yaml
|-- README.md

```

## Key Features

1. **Marketplace Discovery** — browse/filter food listings by category and type.
2. **Surplus Radar** — OpenStreetMap view + OSRM routing.
3. **Inventory Management** — track food with expiry dates and categories.
4. **Pickup Coordination** — schedule/track pickups with status updates.
5. **Bulk Requests** — large-scale organizational requests.
6. **Donation Logging** — tax/impact history.
7. **Notifications** — Firestore-driven alerts, read/unread.
8. **Leaderboard** — top donors & consumers computed from real donation/pickup data.
9. **Rewards/Badges** — level and badges computed from real activity (donations & weight saved).
10. **Firebase Auth** — email/password, sign-up, password recovery.
11. **Cloudinary Image Uploads** — for listing photos.

## Push Notifications

Every write to the `notifications` Firestore collection is meant to trigger
a real OS-level push, not just an in-app Notification Center entry. There
are two ways this is wired up:

1. **`functions/index.js`** — a standard Firebase Cloud Function
   (`sendNotificationPush`) that triggers on every new `notifications` doc
   and sends FCM pushes to the recipient's tokens. This is the "normal" way
   to do it, but Cloud Functions requires the project to be on Firebase's
   Blaze (pay-as-you-go) plan — billing must be enabled even to stay within
   the free tier. Deploy with `cd functions && npm install && npm run
   deploy` once the project is on Blaze.
2. **`apps_script/`** — a free alternative that needs no billing at all.
   The Flutter client (`lib/services/push_notification_sender.dart`) calls
   a small Google Apps Script Web App directly, right after writing the
   notification doc, and the script sends the FCM push itself. This is what
   the app currently uses.

### Setting up the Apps Script relay

1. Go to [script.google.com](https://script.google.com) (same Google
   account that owns the Firebase project) → **New project**.
2. Replace the default `Code.gs` content with
   [`apps_script/Code.gs`](apps_script/Code.gs).
3. Project Settings (gear icon) → check **"Show `appsscript.json`
   manifest file in editor"** → open it and replace its content with
   [`apps_script/appsscript.json`](apps_script/appsscript.json).
4. **Deploy → New deployment** → type **Web app** → Execute as **Me**,
   Who has access **Anyone** → **Deploy**. Approve the OAuth consent
   screen (it'll warn the app is unverified — that's expected for a
   personal script; click **Advanced → Go to (project name)**).
5. Copy the deployed Web App URL (ends in `/exec`).
6. Paste it into `_pushRelayUrl` in
   [`lib/services/push_notification_sender.dart`](lib/services/push_notification_sender.dart),
   replacing the `REPLACE_WITH_YOUR_APPS_SCRIPT_WEB_APP_URL` placeholder.

No credential is embedded in the app — the script verifies every request's
Firebase ID token server-side before sending anything, and the FCM-sending
credential lives only inside the Apps Script project.

## Deployment Notes

The app targets Android, iOS, and Web. After linking Firebase with `flutterfire configure`, build with the `flutter build` commands above. On web, Firestore + Cloudinary handle the backend and storage respectively.

## Support

For technical assistance, refer to the docs or open an issue on the GitHub repository.

## Versioning

This project follows [Semantic Versioning](https://semver.org/) in the form `MAJOR.MINOR.PATCH`, starting from **`0.1.0`**:

- **MAJOR** — breaking changes (e.g., incompatible schema/API changes)
- **MINOR** — new features, backward compatible
- **PATCH** — bug fixes and small improvements

While the project is in `0.x` (pre-1.0), the API and data schemas are considered unstable and the **MINOR** number may include breaking changes.

The current version is tracked in:

- `pubspec.yaml` → `version: 0.1.0+1` (the `+1` is the Flutter build number)

Each release is tagged on GitHub as `v<version>` (e.g., `v0.1.0`).

| Version | Status |
|---------|--------|
| 0.1.0 | Initial versioned release |