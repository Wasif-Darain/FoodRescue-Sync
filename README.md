# FoodRescue-Sync

FoodRescue-Sync is a mobile application designed to connect food donors, consumers, and organizations in a unified platform for surplus food redistribution. The application enables donors to list surplus food items, consumers to discover available food, and organizations to coordinate bulk requests and pickups.

## Project Overview

This Flutter-based application implements a three-role system comprising donors, consumers, and organizations. The platform facilitates food surplus management by providing real-time marketplace discovery, inventory tracking, pickup coordination, and notification management. The backend is powered by Firebase (Authentication, Firestore) with Cloudinary for image uploads.

## Prerequisites

Before running the project locally, ensure the following tools are installed on your system:

1. Flutter SDK (version 3.0 or higher)
2. Dart SDK (included with Flutter)
3. Android Studio or Xcode (for Android and iOS development respectively)
4. A supported code editor (Visual Studio Code recommended)
5. A Firebase project (for Authentication and Firestore)
6. A Cloudinary account (for image uploads)

## Installation Instructions

Follow these steps to set up the project on your local machine:

1. Clone the repository to your local directory

2. Navigate to the project root directory

3. Obtain all project dependencies by running the following command:

   flutter pub get

4. Configure Firebase for your project:

   flutterfire configure

   This generates the `lib/firebase_options.dart` file with your Firebase project credentials.

5. Verify the Flutter environment configuration:

   flutter doctor

## Firebase Setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)

2. Enable the **Email/Password** sign-in provider under **Authentication → Sign-in method**

3. Create the following Firestore collections:
   - `users` — user metadata (uid, email, role, name, profileRef)
   - `organization_profiles` — organization details (orgName, address, contactEmail, contactPhone, isVerified)
   - `inventory_items` — donor inventory (donorId, name, quantity, expiryDate, isSurplus, category)
   - `listings` — food listings (donorId, title, description, price, quantity, photoUrls, pickupStart, pickupEnd, status)

4. Configure Firestore security rules to allow authenticated users to read/write their own data

## Cloudinary Setup

1. Create a Cloudinary account at [cloudinary.com](https://cloudinary.com)

2. Note your **cloud name** (default: `lobecgxv`)

3. Create an **unsigned upload preset** named `foodrescue_preset` under **Settings → Upload**

4. Update the constants in `lib/services/listing_image_manager.dart` if your cloud name or preset differs

## Running the Project Locally

To run the application on your development machine, follow these steps:

1. Connect a physical device or launch an emulator

2. For web development with Edge browser, execute:

   flutter run -d edge

3. For Android emulator or device, execute:

   flutter run -d android

4. For iOS simulator or device, execute:

   flutter run -d ios

5. To run with continuous hot reload during development, use:

   flutter run -d edge --continuous

6. To build a release version for production, execute:

   flutter build apk (for Android)
   flutter build ios (for iOS)
   flutter build web (for web)

## Project Structure

The application follows a modular architecture organized as follows:

1. lib/screens/donor contains donor-specific functionality including dashboard, inventory management, and listing creation

2. lib/screens/consumer contains consumer-specific functionality including marketplace discovery, radar visualization, and request tracking

3. lib/screens/shared contains common screens used across multiple roles including profile settings and notification management

4. lib/widgets contains reusable UI components organized by type (layout and UI)

5. lib/data contains mock data and data models

6. lib/providers contains state management logic with Firebase integration

7. lib/models contains Firestore-backed data models with serialization

8. lib/services contains external service integrations (Cloudinary image uploads)

```
FoodRescue-Sync/
|
|-- lib/
|   |-- screens/
|   |   |-- donor/
|   |   |   |-- create_listing.dart
|   |   |   |-- donation_log.dart
|   |   |   |-- donor_consumers.dart
|   |   |   |-- donor_dashboard.dart
|   |   |   |-- expiry_tracker.dart
|   |   |
|   |   |-- consumer/
|   |   |   |-- bulk_request.dart
|   |   |   |-- consumer_marketplace.dart
|   |   |   |-- pickup_coordination.dart
|   |   |   |-- request_status_tracker.dart
|   |   |   |-- surplus_radar.dart
|   |   |
|   |   |-- shared/
|   |   |   |-- edit_profile.dart
|   |   |   |-- notification_center.dart
|   |   |   |-- profile_settings.dart
|   |   |
|   |   |-- admin/
|   |   |   |-- account_management.dart
|   |   |   |-- admin_dashboard.dart
|   |   |
|   |   |-- login_register_screen.dart
|   |   |-- password_recovery_screen.dart
|   |   |-- welcome_screen.dart
|   |
|   |-- widgets/
|   |   |-- layout/
|   |   |   |-- app_layout.dart
|   |   |   |-- bottom_nav_bar.dart
|   |   |
|   |   |-- ui/
|   |   |   |-- app_badge.dart
|   |   |   |-- app_button.dart
|   |   |   |-- stat_card.dart
|   |   |   |-- photo_picker_row.dart
|   |   |   |-- countdown_timer.dart
|   |
|   |-- data/
|   |   |-- mock_data.dart
|   |
|   |-- models/
|   |   |-- models.dart
|   |   |-- user.dart
|   |   |-- organization_profile.dart
|   |   |-- inventory_item.dart
|   |   |-- listing.dart
|   |   |-- request.dart
|   |   |-- pickup.dart
|   |   |-- donation_log.dart
|   |   |-- notification_model.dart
|   |
|   |-- providers/
|   |   |-- auth_provider.dart
|   |   |-- donor_provider.dart
|   |   |-- consumer_provider.dart
|   |   |-- admin_provider.dart
|   |   |-- theme_provider.dart
|   |
|   |-- services/
|   |   |-- listing_image_manager.dart
|   |
|   |-- firebase_options.dart
|   |-- router.dart
|   |-- main.dart
|
|-- pubspec.yaml
|-- pubspec.lock
|-- analysis_options.yaml
|-- README.md
```

## Key Features

1. Marketplace Discovery: Browse and filter available food listings by category and listing type

2. Surplus Radar: Visualize nearby food sources on an interactive map with current location marker

3. Inventory Management: Track food inventory with expiry dates and barcode scanning

4. Pickup Coordination: Schedule and track food pickups with real-time status updates

5. Bulk Requests: Submit large-scale food requests for organizational use

6. Donation Logging: Record and document all donations made through the platform

7. Notification System: Receive alerts for listing updates, request status changes, and pickup reminders

8. Firebase Authentication: Email/password sign-in, sign-up, and password recovery

9. Cloudinary Image Uploads: Secure image hosting for food listings

## Tech Stack

- Flutter 3.12.2
- Dart 3.12.2
- Firebase Core 3.12.0
- Firebase Auth 5.5.0
- Cloud Firestore 5.6.4
- go_router 14.0.0
- provider 6.1.2
- http 1.6.0
- Cloudinary (REST API)

## Deployment Notes

The application is configured for deployment across multiple platforms including Android, iOS, and web browsers. Ensure platform-specific configuration files are properly updated before deployment. Firebase and Cloudinary credentials must be configured in the Firebase Console and Cloudinary Dashboard respectively.

## Support

For technical assistance or questions regarding the project, refer to the project documentation or contact the development team.