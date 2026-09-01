import '../models/api_service_request.dart';
import '../services/api_client.dart';

class ServiceRequestRepository {
  final ApiClient _api = ApiClient();

  Future<ApiServiceRequest> createRequest({
    required String userId,
    required String userName,
    required String userPhone,
    required String userGovernorate,
    required String title,
    required String description,
    required double budget,
    required String serviceType,
    DateTime? scheduledDate,
    List<String>? images,
  }) async {
    final body = <String, dynamic>{
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'userGovernorate': userGovernorate,
      'title': title,
      'description': description,
      'budget': budget,
      'serviceType': serviceType,
    };
    if (scheduledDate != null) body['scheduledDate'] = scheduledDate.toIso8601String();
    if (images != null) body['images'] = images;
    
    final response = await _api.post('/service-requests', body: body);
    return ApiServiceRequest.fromJson(_api.unwrapData(response));
  }

  Future<ApiServiceRequest> createCarpentryRequest({
    required String userId,
    required String userName,
    required String userPhone,
    required String userGovernorate,
    required String title,
    required String description,
    required double budget,
    DateTime? scheduledDate,
    List<String>? images,
  }) async {
    final body = <String, dynamic>{
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'userGovernorate': userGovernorate,
      'title': title,
      'description': description,
      'budget': budget,
      'serviceType': 'carpentry',
    };
    if (scheduledDate != null) body['scheduledDate'] = scheduledDate.toIso8601String();
    if (images != null) body['images'] = images;
    
    final response = await _api.post('/service-requests/carpentry', body: body);
    return ApiServiceRequest.fromJson(_api.unwrapData(response));
  }

  Future<ApiServiceRequest> createPlumbingRequest({
    required String userId,
    required String userName,
    required String userPhone,
    required String userGovernorate,
    required String title,
    required String description,
    required double budget,
    DateTime? scheduledDate,
    List<String>? images,
  }) async {
    final body = <String, dynamic>{
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'userGovernorate': userGovernorate,
      'title': title,
      'description': description,
      'budget': budget,
      'serviceType': 'plumbing',
    };
    if (scheduledDate != null) body['scheduledDate'] = scheduledDate.toIso8601String();
    if (images != null) body['images'] = images;
    
    final response = await _api.post('/service-requests/plumbing', body: body);
    return ApiServiceRequest.fromJson(_api.unwrapData(response));
  }

  Future<ApiServiceRequest> createPaintingRequest({
    required String userId,
    required String userName,
    required String userPhone,
    required String userGovernorate,
    required String title,
    required String description,
    required double budget,
    DateTime? scheduledDate,
    List<String>? images,
  }) async {
    final body = <String, dynamic>{
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'userGovernorate': userGovernorate,
      'title': title,
      'description': description,
      'budget': budget,
      'serviceType': 'painting',
    };
    if (scheduledDate != null) body['scheduledDate'] = scheduledDate.toIso8601String();
    if (images != null) body['images'] = images;
    
    final response = await _api.post('/service-requests/painting', body: body);
    return ApiServiceRequest.fromJson(_api.unwrapData(response));
  }

  Future<ApiServiceRequest> createElectricalRequest({
    required String userId,
    required String userName,
    required String userPhone,
    required String userGovernorate,
    required String title,
    required String description,
    required double budget,
    DateTime? scheduledDate,
    List<String>? images,
  }) async {
    final body = <String, dynamic>{
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'userGovernorate': userGovernorate,
      'title': title,
      'description': description,
      'budget': budget,
      'serviceType': 'electrical',
    };
    if (scheduledDate != null) body['scheduledDate'] = scheduledDate.toIso8601String();
    if (images != null) body['images'] = images;
    
    final response = await _api.post('/service-requests/electrical', body: body);
    return ApiServiceRequest.fromJson(_api.unwrapData(response));
  }

  Future<List<ApiServiceRequest>> getRequests({
    String? userId,
    String? status,
    String? governorate,
    String? serviceType,
    String? sort,
    int? limit,
    int? offset,
  }) async {
    final queryParams = <String, String>{};
    if (userId != null) queryParams['userId'] = userId;
    if (status != null) queryParams['status'] = status;
    if (governorate != null) queryParams['governorate'] = governorate;
    if (serviceType != null) queryParams['serviceType'] = serviceType;
    if (sort != null) queryParams['sort'] = sort;
    if (limit != null) queryParams['limit'] = limit.toString();
    if (offset != null) queryParams['offset'] = offset.toString();
    
    final response = await _api.get(
      '/service-requests',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final requests = _api.unwrapList(response);
    return requests.map((r) => ApiServiceRequest.fromJson(r)).toList();
  }

  Future<ApiServiceRequest> getRequestById(String id) async {
    final response = await _api.get('/service-requests/$id');
    return ApiServiceRequest.fromJson(_api.unwrapData(response));
  }

  Future<ApiServiceRequest> updateRequest(String id, Map<String, dynamic> updates) async {
    final response = await _api.patch('/service-requests/$id', body: updates);
    return ApiServiceRequest.fromJson(_api.unwrapData(response));
  }

  Future<ApiServiceRequest> updateRequestStatus(
    String id, {
    required String status,
    Map<String, dynamic>? extra,
  }) async {
    final body = <String, dynamic>{'status': status};
    if (extra != null) body['extra'] = extra;
    
    final response = await _api.patch('/service-requests/$id/status', body: body);
    return ApiServiceRequest.fromJson(_api.unwrapData(response));
  }

  Future<void> deleteRequest(String id) async {
    await _api.delete('/service-requests/$id');
  }
}
