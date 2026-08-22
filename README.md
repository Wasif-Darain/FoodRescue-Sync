# FoodRescue-Sync

FoodRescue-Sync is a mobile application designed to connect food donors, consumers, and organizations in a unified platform for surplus food redistribution. The application enables donors to list surplus food items, consumers to discover available food, and organizations to coordinate bulk requests and pickups.

## Project Overview

This Flutter-based application implements a three-role system comprising donors, consumers, and organizations. The platform facilitates food surplus management by providing real-time marketplace discovery, inventory tracking, pickup coordination, leaderboards, rewards, and notification management. The backend is powered by Firebase (Authentication, Firestore) with Cloudinary for image uploads.

## Tech Stack

While the project relies primarily on Firebase, here is the current state of the listed stack:

- **UI:** Flutter (Dart)
- **State Management:** Provider
- **Local Database / Backend:** Firebase (Firestore, Firebase Auth)
- **Intelligence Engine:** TensorFlow Lite — **not yet implemented.** The original proposal mentioned it, but the current codebase does not include it. There are no `tflite`/`tflite_flutter` dependencies in `pubspec.yaml`.
- **Location Services:** OpenStreetMap — implemented via the `flutter_map` package which renders OpenStreetMap tiles and uses OSRM for routing directions.
- **Image Uploads:** Cloudinary (REST API).

> **Note:** Of the listed stack, **TensorFlow Lite is the only item not fully implemented.** All other items (UI, Provider, Firebase, OpenStreetMap) are present and working.

## Prerequisites

Before running the project locally, ensure you have:

1. Flutter SDK (3.12 or higher)
2. Dart SDK (bundled with Flutter)
3. Android Studio or Xcode (for Android/iOS respectively)
4. A code editor (VS Code recommended)
5. Access to the team's shared **Firebase project**

## Installation & Setup

1. **Clone the repository**:

   ```bash
   git clone [https://github.com/Wasif-Darain/FoodRescue-Sync.git](https://github.com/Wasif-Darain/FoodRescue-Sync.git)
   cd FoodRescue-Sync
   ```

2. **Install Dart dependencies**:
   ```bash
   flutter pub get
   ```

3. **Link to the shared Firebase project**:
   ```bash
   flutterfire configure
   ```
   
> **Note:** Select the shared team project when prompted to generate your local `lib/firebase_options.dart` file. If `flutterfire` is not installed, run `dart pub global activate flutterfire_cli` first.

4. **Verify the Flutter environment**:
   ```bash
   flutter doctor
   ```



## Running the Project

Once configured, run:

```bash
flutter run -d chrome        # for web
flutter run -d <device-id>   # for Android / iOS

```

For hot reload:

```bash
flutter run -d chrome --continuous

```

To build a release:

```bash
flutter build apk   # Android
flutter build ios   # iOS
flutter build web   # Web

```

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

## Deployment Notes

The app targets Android, iOS, and Web. After linking Firebase with `flutterfire configure`, build with the `flutter build` commands above. On web, Firestore + Cloudinary handle the backend and storage respectively.

## Support

For technical assistance, refer to the docs or open an issue on the GitHub repository.