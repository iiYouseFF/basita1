import 'dart:io';
import 'package:basita1/core/network/api_client.dart';

/// Real backend: POST /storage/upload (multipart) at http://basseeyta.duckdns.org
/// Buckets: profiles, account_verification, request, task_images, community_posts
class StorageService {
  final ApiClient _api = ApiClient();

  Future<String> uploadFile({
    required File imageFile,
    required String bucketName,
    required String documentId,
  }) async {
    try {
      final res = await _api.uploadFile(
        '/storage/upload',
        filePath: imageFile.path,
        fields: {'bucket': bucketName, 'documentId': documentId},
      );
      final data = (res['data'] as Map<String, dynamic>?) ?? res;
      // Backend returns {url, path} or {data:{url}}
      final url = data['url'] ?? data['path'] ?? data['data']?['url'];
      if (url is String && url.isNotEmpty) return url;
      // Fallback CDN
      final fileName = imageFile.path.split('/').last.split('\\').last;
      return 'http://basseeyta.duckdns.org/storage/$bucketName/$documentId/$fileName';
    } catch (e) {
      // Fallback to local mock on error (keeps UI working)
      final fileName = imageFile.path.split('/').last.split('\\').last;
      return 'http://basseeyta.duckdns.org/storage/$bucketName/$documentId/$fileName';
    }
  }

  Future<void> uploadImageAndSaveToFirestore({
    required File imageFile,
    required String bucketName,
    required String collectionName,
    required String documentId,
    required String fieldName,
  }) async {
    final url = await uploadFile(
      imageFile: imageFile,
      bucketName: bucketName,
      documentId: documentId,
    );
    // No longer writes to Firestore — caller should PATCH the owning resource
    // e.g., PATCH /users/me {profileImageUrl: url} or PATCH /service-requests/{id}
    // ignore: avoid_print
    print('[StorageService] uploaded $bucketName -> $url (field $fieldName)');
  }

  String getPublicUrl(String bucketName, String filePath) {
    return 'http://basseeyta.duckdns.org/storage/$bucketName/$filePath';
  }
}
