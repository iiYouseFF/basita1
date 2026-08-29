// File: lib/firebase_options.dart
// Default Firebase options for Bassyta project

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;

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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macOS.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCnS7ZsXenV-_FYJ6PBtvvCIjuwKQ6dug4',
    appId: '1:718849850419:web:49c3add1e1b5643110f746',
    messagingSenderId: '718849850419',
    projectId: 'bassyta-851a5',
    authDomain: 'bassyta-851a5.firebaseapp.com',
    storageBucket: 'bassyta-851a5.firebasestorage.app',
    measurementId: 'G-09G1DWCE1H',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCnS7ZsXenV-_FYJ6PBtvvCIjuwKQ6dug4',
    appId: '1:718849850419:web:49c3add1e1b5643110f746',
    messagingSenderId: '718849850419',
    projectId: 'bassyta-851a5',
    storageBucket: 'bassyta-851a5.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCnS7ZsXenV-_FYJ6PBtvvCIjuwKQ6dug4',
    appId: '1:718849850419:web:49c3add1e1b5643110f746',
    messagingSenderId: '718849850419',
    projectId: 'bassyta-851a5',
    storageBucket: 'bassyta-851a5.firebasestorage.app',
  );
}