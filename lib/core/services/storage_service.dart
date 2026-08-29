import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final _supabase = Supabase.instance.client;
  final _firestore = FirebaseFirestore.instance;

  // الدالة دي بترفع الصورة لـ Supabase وبتحفظ الرابط في Firebase
  Future<void> uploadImageAndSaveToFirestore({
    required File imageFile,
    required String bucketName, // هنا هنكتب 'user_profiles' أو 'request'
    required String
    collectionName, // هنا هنكتب اسم الكولكشن في فايربيز زي 'offers'
    required String documentId, // الـ ID بتاع العرض أو المستخدم
    required String
    fieldName, // اسم الحقل اللي هيتخزن فيه الرابط زي 'imagePath'
  }) async {
    try {
      // 1. استخراج اسم الملف وامتداده
      final fileExtension = path.extension(imageFile.path);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}$fileExtension';
      final filePath = '$documentId/$fileName';

      // 2. رفع الصورة على Supabase Storage
      await _supabase.storage
          .from(bucketName)
          .upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      // 3. الحصول على الرابط العام (Public URL) للصورة
      final publicUrl = _supabase.storage
          .from(bucketName)
          .getPublicUrl(filePath);

      // 4. تحديث الرابط في Firebase Firestore
      await _firestore.collection(collectionName).doc(documentId).update({
        fieldName: publicUrl,
      });

      print('تم رفع الصورة وحفظ الرابط بنجاح: $publicUrl');
    } catch (e) {
      print('حدث خطأ أثناء الرفع: $e');
    }
  }
}
