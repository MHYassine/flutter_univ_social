// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB-OA9O37yTkB8gxaezUBHI5wvw7rbGpsg',
    appId: '1:1091823562515:web:09cf39e09fa9052dd374e6',
    messagingSenderId: '1091823562515',
    projectId: 'proj-mobile-355e7',
    authDomain: 'proj-mobile-355e7.firebaseapp.com',
    storageBucket: 'proj-mobile-355e7.appspot.com',
    measurementId: 'G-E072HM95L3',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD7DuCFl1f7DaZ3Xz6c5FU-R16viXRcp8U',
    appId: '1:1091823562515:android:38c32e73bbd417fbd374e6',
    messagingSenderId: '1091823562515',
    projectId: 'proj-mobile-355e7',
    storageBucket: 'proj-mobile-355e7.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAEBgZFNVUOiG5CQguAtNPYKb3aof8qcgU',
    appId: '1:1091823562515:ios:3f88b0a72abb5b95d374e6',
    messagingSenderId: '1091823562515',
    projectId: 'proj-mobile-355e7',
    storageBucket: 'proj-mobile-355e7.appspot.com',
    iosBundleId: 'com.example.gtkFlutter',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAEBgZFNVUOiG5CQguAtNPYKb3aof8qcgU',
    appId: '1:1091823562515:ios:3f88b0a72abb5b95d374e6',
    messagingSenderId: '1091823562515',
    projectId: 'proj-mobile-355e7',
    storageBucket: 'proj-mobile-355e7.appspot.com',
    iosBundleId: 'com.example.gtkFlutter',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB-OA9O37yTkB8gxaezUBHI5wvw7rbGpsg',
    appId: '1:1091823562515:web:2b8d874792ba7207d374e6',
    messagingSenderId: '1091823562515',
    projectId: 'proj-mobile-355e7',
    authDomain: 'proj-mobile-355e7.firebaseapp.com',
    storageBucket: 'proj-mobile-355e7.appspot.com',
    measurementId: 'G-VGQM3K950X',
  );

}