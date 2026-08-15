import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCro9ANL5v4ToLHid4jMCkiGFAm1onUV2M',
    appId: '1:760318724519:android:8db6d0cb524f57c6b14e82',
    messagingSenderId: '760318724519',
    projectId: 'foodrescue-sync',
    storageBucket: 'foodrescue-sync.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDJYy-NosVIM04TwSgX9c1SOX1JuLBWH_c',
    appId: '1:760318724519:ios:a04cbea787556a49b14e82',
    messagingSenderId: '760318724519',
    projectId: 'foodrescue-sync',
    storageBucket: 'foodrescue-sync.firebasestorage.app',
    iosBundleId: 'com.foodrescue.foodrescueSync',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'PLACEHOLDER_API_KEY',
    appId: 'PLACEHOLDER_APP_ID',
    messagingSenderId: 'PLACEHOLDER_SENDER_ID',
    projectId: 'PLACEHOLDER_PROJECT_ID',
    storageBucket: 'PLACEHOLDER_STORAGE_BUCKET',
    iosBundleId: 'PLACEHOLDER_BUNDLE_ID',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'PLACEHOLDER_API_KEY',
    appId: 'PLACEHOLDER_APP_ID',
    messagingSenderId: 'PLACEHOLDER_SENDER_ID',
    projectId: 'PLACEHOLDER_PROJECT_ID',
    storageBucket: 'PLACEHOLDER_STORAGE_BUCKET',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'PLACEHOLDER_API_KEY',
    appId: 'PLACEHOLDER_APP_ID',
    messagingSenderId: 'PLACEHOLDER_SENDER_ID',
    projectId: 'PLACEHOLDER_PROJECT_ID',
    storageBucket: 'PLACEHOLDER_STORAGE_BUCKET',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC8fJXkfjEJfYUPh-ZOE5rlvqSTEEs9qfs',
    appId: '1:760318724519:web:f25b250efbccb581b14e82',
    messagingSenderId: '760318724519',
    projectId: 'foodrescue-sync',
    authDomain: 'foodrescue-sync.firebaseapp.com',
    storageBucket: 'foodrescue-sync.firebasestorage.app',
    measurementId: 'G-SCSV07FWVQ',
  );
}
