import 'dart:io';

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
    phone = phoneNumber;
    experience = exp;
    specialty = spec;
    governorate = gov;
    area = ar;
    profileImagePath = imagePath;
  }

  // Previously uploaded to dynamic Storage `profiles` bucket.
  // Now mock — see docs/backend-prd.html § Storage
  static Future<void> uploadImageToSupabase(File imageFile) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // TODO(backend): POST /storage/upload {bucket: 'profiles', file: imageFile}
    // mock URL:
    final fileName = 'profile_${phone}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    profileImagePath = 'https://cdn.basita.example.com/profiles/$fileName';
  }

  // Previously Firestore `technicians/{phone}`.
  static Future<void> uploadDataToFirebase() async {
    await Future.delayed(const Duration(milliseconds: 400));
    // TODO(backend): PUT /technicians/{phone}
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
