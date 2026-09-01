import '../models/api_misc.dart';
import '../services/api_client.dart';

class AiRepository {
  final ApiClient _api = ApiClient();

  Future<ApiAiResponse> askAssistant({
    required String query,
    Map<String, dynamic>? userContext,
  }) async {
    final body = <String, dynamic>{
      'query': query,
    };
    if (userContext != null) body['userContext'] = userContext;
    
    final response = await _api.post('/ai/assistant', body: body);
    return ApiAiResponse.fromJson(_api.unwrapData(response));
  }
}
