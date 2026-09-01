import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:basita1/core/config/firebase_options.dart';
import 'package:basita1/core/services/api_client.dart';
import 'package:basita1/features/auth/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Supabase.initialize(
    url: 'https://wduombkxwcqhipdumxmn.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndkdW9tYmt4d2NxaGlwZHVteG1uIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODYzNjg0MzEsImV4cCI6MjEwMTk0NDQzMX0.ukm1djuFf8NGr86RG_9O4yYRzpO7AI33o4F3g4w8WEc',
  );

  final apiClient = ApiClient();
  await apiClient.initialize();

  runApp(const BasseeytaApp());
}

class BasseeytaApp extends StatelessWidget {
  const BasseeytaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'بسيطة - Basseeyta',
      theme: ThemeData(
        primaryColor: const Color(0xFF0D47A1),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Cairo',
      ),
      home: const SplashScreen(),
    );
  }
}
