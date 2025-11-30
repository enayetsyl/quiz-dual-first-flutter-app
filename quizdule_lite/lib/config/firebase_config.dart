import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Firebase Configuration
/// 
/// MERN Equivalent: Your Express server connecting to MongoDB
/// In MERN: mongoose.connect('mongodb://localhost:27017/quizduel')
/// In Flutter: We connect to Firebase Emulators (localhost:8080 for Firestore, 9099 for Auth)
/// 
/// This file initializes Firebase and connects to local emulators for development.
/// In production, you'd remove the useEmulator calls and use real Firebase.

/// Initialize Firebase and connect to emulators
/// 
/// MERN Equivalent: Starting your Express server with MongoDB connection
/// ```javascript
/// const mongoose = require('mongoose');
/// await mongoose.connect('mongodb://localhost:27017/quizduel');
/// ```
/// 
/// In Flutter, we do this in main() before runApp()
Future<void> initializeFirebase() async {
  // Initialize Firebase
  // MERN Equivalent: require('firebase-admin').initializeApp()
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'demo-api-key', // Not needed for emulators
      appId: 'demo-app-id',
      messagingSenderId: 'demo-sender-id',
      projectId: 'quizdule-lite-dev',
    ),
  );

  // Connect to Auth Emulator
  // MERN Equivalent: Your Express /auth routes running on localhost:3000
  // Firebase Auth Emulator = Your Express authentication endpoints
  // Using 127.0.0.1 for better web compatibility (Chrome/Edge)
  await FirebaseAuth.instance.useAuthEmulator('127.0.0.1', 9099);

  // Connect to Firestore Emulator
  // MERN Equivalent: MongoDB running on localhost:27017
  // Firestore Emulator = Your MongoDB database
  // Using 127.0.0.1 for better web compatibility (Chrome/Edge)
  FirebaseFirestore.instance.useFirestoreEmulator('127.0.0.1', 8080);

  print('🔥 Firebase initialized and connected to emulators!');
  print('   Auth Emulator: http://127.0.0.1:9099');
  print('   Firestore Emulator: http://127.0.0.1:8080');
  print('   Emulator UI: http://127.0.0.1:4000');
}

