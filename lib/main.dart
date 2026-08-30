import 'package:flutter/material.dart';
import 'package:basita1/features/auth/screens/splash_screen.dart';
import 'package:basita1/core/network/api_config.dart';
import 'package:basita1/core/session/auth_session.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // External backend: Node.js at http://basseeyta.duckdns.org
  // GitHub: https://github.com/iiYouseFF/basseeyta
  // All data goes through ApiClient (lib/core/network/api_client.dart)
  // JWT is persisted via AuthSession (SharedPreferences).
  ApiConfig.init();
  await AuthSession.instance.load();

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
