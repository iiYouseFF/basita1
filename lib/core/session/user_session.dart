class UserSession {
  // 1. تطبيق نمط الـ Singleton
  static final UserSession _instance = UserSession._internal();
  factory UserSession() => _instance;
  UserSession._internal();
  static UserSession get instance => _instance;

  // 2. تعريف المتغيرات لتخزين بيانات المستخدم
  String name = '';
  String phone = '';
  String email = '';
  String governorate = '';
  String city = '';
  String region = '';
  String placeType = '';
  String? profileImagePath;

  // 3. دالة لحفظ البيانات داخل الجلسة
  void saveUserData({
    required String name,
    required String phone,
    required String email,
    required String governorate,
    required String city,
    required String region,
    required String placeType,
    String? profileImagePath,
  }) {
    this.name = name;
    this.phone = phone;
    this.email = email;
    this.governorate = governorate;
    this.city = city;
    this.region = region;
    this.placeType = placeType;
    this.profileImagePath = profileImagePath;
  }

  // 4. دالة لمسح البيانات عند تسجيل الخروج
  void clearSession() {
    name = '';
    phone = '';
    email = '';
    governorate = '';
    city = '';
    region = '';
    placeType = '';
    profileImagePath = null;
  }
}