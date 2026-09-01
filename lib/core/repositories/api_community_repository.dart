import '../models/api_post.dart';
import '../services/api_client.dart';

class CommunityRepository {
  final ApiClient _api = ApiClient();

  Future<ApiPost> createPost({
    required String authorId,
    required String authorName,
    String? authorRole,
    required String title,
    required String content,
    String? imagePath,
    bool? isQuestion,
    String? category,
  }) async {
    final body = <String, dynamic>{
      'authorId': authorId,
      'authorName': authorName,
      'title': title,
      'content': content,
    };
    if (authorRole != null) body['authorRole'] = authorRole;
    if (imagePath != null) body['imagePath'] = imagePath;
    if (isQuestion != null) body['isQuestion'] = isQuestion;
    if (category != null) body['category'] = category;
    
    final response = await _api.post('/posts', body: body);
    return ApiPost.fromJson(_api.unwrapData(response));
  }

  Future<List<ApiPost>> getPosts({
    String? category,
    String? authorId,
    String? sort,
    int? limit,
  }) async {
    final queryParams = <String, String>{};
    if (category != null) queryParams['category'] = category;
    if (authorId != null) queryParams['authorId'] = authorId;
    if (sort != null) queryParams['sort'] = sort;
    if (limit != null) queryParams['limit'] = limit.toString();
    
    final response = await _api.get(
      '/posts',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      includeAuth: false,
    );
    final posts = _api.unwrapList(response);
    return posts.map((p) => ApiPost.fromJson(p)).toList();
  }

  Future<ApiPost> toggleLike(String postId, String userId) async {
    final response = await _api.post(
      '/posts/$postId/like',
      body: {'userId': userId},
    );
    return ApiPost.fromJson(_api.unwrapData(response));
  }

  Future<ApiPost> updatePost(String postId, Map<String, dynamic> updates) async {
    final response = await _api.patch('/posts/$postId', body: updates);
    return ApiPost.fromJson(_api.unwrapData(response));
  }

  Future<void> deletePost(String postId) async {
    await _api.delete('/posts/$postId');
  }
}
