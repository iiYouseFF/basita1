import 'package:flutter/material.dart';
import 'package:basita1/features/auth/screens/account_type_screen.dart'; // تأكد من استيراد صفحة نوع الحساب

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  final Color primaryBlue = const Color(0xFF0056D2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. الجزء العلوي (اللوجو في اليمين)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Align(
                alignment: Alignment
                    .centerRight, // تم التعديل هنا لضمان وجود اللوجو في اليمين
                child: Image.asset(
                  'assets/Gemini_Generated_Image_rlqvx4rlqvx4rlqv (1).png', // تأكد من اسم الملف ومساره
                  height: 35,
                ),
              ),
            ),

            // 2. الصورة (Illustrations)
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: Image.asset(
                  'assets/ztm5s3s555rmr0czftztvm1f9w.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // 3. النصوص
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  Text(
                    "ابحث عن خبراء موثوقين\nبالقرب منك",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900, // خط عريض جداً
                      color: Color(0xFF1A1D2E), // لون كحلي داكن مائل للأسود
                      height: 1.3, // مسافة بين السطور ليكون شكلها مرتب
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "تصفح آلاف الفنيين المعتمدين في كافة المجالات.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B7280), // لون رمادي أهدى شوية
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // 4. مؤشرات الصفحات (Dots)
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // النقطة الزرقاء (الصفحة الحالية)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0056D2),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8), // مسافة بين النقطتين
                // النقطة الرمادية (الصفحة الثانية)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),

            // 5. زر التالي
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // هذا هو الكود المسؤول عن التنقل
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AccountTypeScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0056D2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0, // شيلنا الظل عشان يكون فلات زي التصميم
                  ),
                  child: const Text(
                    "التالي",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
