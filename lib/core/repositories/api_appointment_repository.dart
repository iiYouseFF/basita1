import '../models/api_appointment.dart';
import '../services/api_client.dart';

class AppointmentRepository {
  final ApiClient _api = ApiClient();

  Future<ApiAppointment> createAppointment({
    required String requestId,
    required String clientId,
    required String technicianId,
    required String serviceType,
    String? serviceName,
    DateTime? appointmentDate,
    String? appointmentTime,
    String? clientAddress,
    double? price,
  }) async {
    final body = <String, dynamic>{
      'requestId': requestId,
      'clientId': clientId,
      'technicianId': technicianId,
      'serviceType': serviceType,
    };
    if (serviceName != null) body['serviceName'] = serviceName;
    if (appointmentDate != null) body['appointmentDate'] = appointmentDate.toIso8601String();
    if (appointmentTime != null) body['appointmentTime'] = appointmentTime;
    if (clientAddress != null) body['clientAddress'] = clientAddress;
    if (price != null) body['price'] = price;
    
    final response = await _api.post('/appointments', body: body);
    return ApiAppointment.fromJson(_api.unwrapData(response));
  }

  Future<ApiAppointment> upsertOnAccept(String requestId) async {
    final response = await _api.post(
      '/appointments/upsert-on-accept',
      body: {'requestId': requestId},
    );
    return ApiAppointment.fromJson(_api.unwrapData(response));
  }

  Future<ApiAppointment> updateStatus(String appointmentId, String status) async {
    final response = await _api.patch(
      '/appointments/$appointmentId/status',
      body: {'status': status},
    );
    return ApiAppointment.fromJson(_api.unwrapData(response));
  }

  Future<ApiAppointment> updateLocation({
    required String appointmentId,
    required String role,
    required double latitude,
    required double longitude,
  }) async {
    final response = await _api.patch(
      '/appointments/$appointmentId/location',
      body: {
        'role': role,
        'latitude': latitude,
        'longitude': longitude,
      },
    );
    return ApiAppointment.fromJson(_api.unwrapData(response));
  }

  Future<ApiAppointment> completeAppointment({
    required String requestId,
    double? technicianLatitude,
    double? technicianLongitude,
    double? clientLatitude,
    double? clientLongitude,
  }) async {
    final body = <String, dynamic>{};
    if (technicianLatitude != null) body['technicianLatitude'] = technicianLatitude;
    if (technicianLongitude != null) body['technicianLongitude'] = technicianLongitude;
    if (clientLatitude != null) body['clientLatitude'] = clientLatitude;
    if (clientLongitude != null) body['clientLongitude'] = clientLongitude;
    
    final response = await _api.patch(
      '/appointments/by-request/$requestId/complete',
      body: body,
    );
    return ApiAppointment.fromJson(_api.unwrapData(response));
  }

  Future<List<ApiAppointment>> getAppointments({
    String? userId,
    String? technicianId,
    String? requestId,
  }) async {
    final queryParams = <String, String>{};
    if (userId != null) queryParams['userId'] = userId;
    if (technicianId != null) queryParams['technicianId'] = technicianId;
    if (requestId != null) queryParams['requestId'] = requestId;
    
    final response = await _api.get(
      '/appointments',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final appointments = _api.unwrapList(response);
    return appointments.map((a) => ApiAppointment.fromJson(a)).toList();
  }

  Future<ApiAppointment> getAppointmentById(String id) async {
    final response = await _api.get('/appointments/$id');
    return ApiAppointment.fromJson(_api.unwrapData(response));
  }
}
