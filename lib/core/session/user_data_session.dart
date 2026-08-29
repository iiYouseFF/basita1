import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserDataSession {
  static String fullName = "";
  static String phone = "";
  static String experience = "";
  static String specialty = "";
  static String governorate = "";
  static String area = "";
  static String profileImagePath = "";

  static void saveUserData({
    required String name,
    required String phoneNumber,
    required String exp,
    required String spec,
    required String gov,
    required String ar,
    String imagePath = "",
  }) {
    fullName = name;
    phone = phoneNumber; // أهم حاجة: دا الرقم اللي هيترفع بيه
    experience = exp;
    specialty = spec;
    governorate = gov;
    area = ar;
    profileImagePath = imagePath;
  }

  // 1. الدالة الجديدة: رفع الصورة إلى Supabase والحصول على الرابط
  static Future<void> uploadImageToSupabase(File imageFile) async {
    try {
      final supabase = Supabase.instance.client;

      // استخراج امتداد الملف (مثلاً: jpg, png)
      final fileExt = imageFile.path.split('.').last;

      // إنشاء اسم فريد للملف باستخدام رقم الهاتف والوقت الحالي لمنع التكرار
      final fileName =
          'profile_${phone}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      // رفع الصورة إلى الباكت (Bucket) المسمى 'profiles' في Supabase
      // تأكد من أنك أنشأت Bucket بهذا الاسم وجعلته Public في إعدادات Supabase
      await supabase.storage
          .from('profiles')
          .upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      // الحصول على الرابط العام (Public URL) للصورة المرفوعة
      final String publicUrl = supabase.storage
          .from('profiles')
          .getPublicUrl(fileName);

      // تحديث المتغير ليحمل الرابط (URL) بدلاً من المسار المحلي
      profileImagePath = publicUrl;
    } catch (e) {
      throw Exception("فشل رفع الصورة إلى Supabase: $e");
    }
  }

  // 2. رفع البيانات إلى Firebase (الآن سيرفع رابط الصورة من الإنترنت)
  static Future<void> uploadDataToFirebase() async {
    try {
      // هنا بيتم إنشاء المستند (Document) باسم رقم الهاتف مباشرة
      await FirebaseFirestore.instance.collection('technicians').doc(phone).set(
        {
          'fullName': fullName,
          'phone': phone,
          'experience': experience,
          'specialty': specialty,
          'governorate': governorate,
          'area': area,
          'profileImagePath': profileImagePath, // <--- سيحتوي على رابط Supabase
          'createdAt': FieldValue.serverTimestamp(),
          'role': 'technician', // يفضل إضافة الدور لتسهيل التمييز لاحقاً
          'isVerified': false, // حالة التوثيق المبدئية
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception("فشل رفع البيانات إلى فايربيس: $e");
    }
  }

  static void clearSession() {
    fullName = "";
    phone = "";
    experience = "";
    specialty = "";
    governorate = "";
    area = "";
    profileImagePath = "";
  }
}
