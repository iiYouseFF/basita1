import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:basita1/features/auth/screens/onboarding_screen.dart';
import 'package:basita1/features/home/screens/home_screen.dart';
import 'package:basita1/features/home/screens/home1.dart';
import 'package:basita1/core/session/user_session.dart';
import 'package:basita1/core/session/user_data_session.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _controller.forward();

    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String userType = prefs.getString('userType') ?? '';

    if (isLoggedIn) {
      if (userType == 'technician') {
        // 👈 استرجاع بيانات الفني محلياً في الذاكرة المؤقتة
        UserDataSession.saveUserData(
          name: prefs.getString('techName') ?? '',
          phoneNumber: prefs.getString('techPhone') ?? '',
          exp: prefs.getString('techExp') ?? '',
          spec: prefs.getString('techSpec') ?? '',
          gov: prefs.getString('techGov') ?? '',
          ar: prefs.getString('techArea') ?? '',
          imagePath: prefs.getString('techImage') ?? '',
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainTechnicianScreen()),
        );
      } else {
        // 👈 استرجاع بيانات العميل محلياً في الذاكرة المؤقتة لكي يظهر اسمك فوراً
        UserSession.instance.saveUserData(
          name: prefs.getString('userName') ?? '',
          phone: prefs.getString('userPhone') ?? '',
          email: prefs.getString('userEmail') ?? '',
          governorate: prefs.getString('userGov') ?? '',
          city: prefs.getString('userCity') ?? '',
          region: prefs.getString('userRegion') ?? '',
          placeType: prefs.getString('userPlaceType') ?? '',
          profileImagePath: prefs.getString('userImage'),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SimpleHomeScreen()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2563EB), Color(0xFF004AC6), Color(0xFF0053DB)],
          ),
        ),
        child: Center(
          child: ScaleTransition(
            scale: _animation,
            child: Image.asset(
              'assets/image (21)-Picsart-AiImageEnhancer (1).png',
              width: 150,
            ),
          ),
        ),
      ),
    );
  }
}
