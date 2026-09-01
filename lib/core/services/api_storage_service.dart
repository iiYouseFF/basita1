import '../services/api_client.dart';

class ApiStorageService {
  final ApiClient _api = ApiClient();

  Future<String> uploadFile({
    required String filePath,
    required String bucket,
    String? documentId,
  }) async {
    final fields = <String, String>{
      'bucket': bucket,
    };
    if (documentId != null) fields['documentId'] = documentId;
    
    final response = await _api.uploadMultipart(
      '/storage/upload',
      filePath: filePath,
      fieldName: 'file',
      fields: fields,
    );
    return response['url'] ?? '';
  }

  String getFileUrl(String bucket, String path) {
    return '${ApiClient.baseUrl}/storage/$bucket/$path';
  }

  Future<void> deleteFile(String bucket, String path) async {
    await _api.delete('/storage/$bucket/$path');
  }
}
