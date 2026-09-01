import 'dart:async';
import 'package:basita1/core/models/appointment.dart';
import 'package:basita1/core/network/api_client.dart';

/// Real backend: POST /appointments, GET /appointments, PATCH, etc.
/// Base: http://basseeyta.duckdns.org
class AppointmentRepository {
  final ApiClient _api = ApiClient();

  Map<String, dynamic> _normalize(Map<String, dynamic> j) => {
    'id': j['id'] ?? '',
    'request_id': j['requestId'] ?? j['request_id'] ?? '',
    'client_id': j['clientId'] ?? j['client_id'] ?? '',
    'technician_id': j['technicianId'] ?? j['technician_id'] ?? '',
    'service_type': j['serviceType'] ?? j['service_type'] ?? '',
    'service_name': j['serviceName'] ?? j['service_name'],
    'status': j['status'] ?? 'scheduled',
    'appointment_date': j['appointmentDate'] ?? j['appointment_date'],
    'appointment_time': j['appointmentTime'] ?? j['appointment_time'],
    'client_address': j['clientAddress'] ?? j['client_address'],
    'client_latitude': j['clientLatitude'] ?? j['client_latitude'],
    'client_longitude': j['clientLongitude'] ?? j['client_longitude'],
    'technician_latitude': j['technicianLatitude'] ?? j['technician_latitude'],
    'technician_longitude':
        j['technicianLongitude'] ?? j['technician_longitude'],
    'estimated_duration': j['estimatedDuration'] ?? j['estimated_duration'],
    'price': j['price'],
    'notes': j['notes'],
    'created_at': j['createdAt'] ?? j['created_at'],
    'updated_at': j['updatedAt'] ?? j['updated_at'],
  };

  Future<Appointment> createAppointment({
    required String requestId,
    required String clientId,
    required String technicianId,
    required String serviceType,
    String? serviceName,
    DateTime? appointmentDate,
    String? appointmentTime,
    String? clientAddress,
    double? clientLatitude,
    double? clientLongitude,
    double? technicianLatitude,
    double? technicianLongitude,
    String? estimatedDuration,
    double? price,
    String? notes,
  }) async {
    final res = await _api.post(
      '/appointments',
      body: {
        'requestId': requestId,
        'clientId': clientId,
        'technicianId': technicianId,
        'serviceType': serviceType,
        if (serviceName != null) 'serviceName': serviceName,
        if (appointmentDate != null)
          'appointmentDate': appointmentDate.toIso8601String(),
        if (appointmentTime != null) 'appointmentTime': appointmentTime,
        if (clientAddress != null) 'clientAddress': clientAddress,
        if (clientLatitude != null) 'clientLatitude': clientLatitude,
        if (clientLongitude != null) 'clientLongitude': clientLongitude,
        if (technicianLatitude != null)
          'technicianLatitude': technicianLatitude,
        if (technicianLongitude != null)
          'technicianLongitude': technicianLongitude,
        if (estimatedDuration != null) 'estimatedDuration': estimatedDuration,
        if (price != null) 'price': price,
        if (notes != null) 'notes': notes,
      },
    );
    final data =
        (res['data'] as Map<String, dynamic>?)?['appointment'] ??
        res['data'] ??
        res;
    return Appointment.fromJson(
      _normalize(Map<String, dynamic>.from(data as Map)),
    );
  }

  Future<List<Appointment>> getUserAppointments(String userId) async {
    final res = await _api.get('/appointments', query: {'userId': userId});
    final list = _extractList(res);
    return list
        .map(
          (e) => Appointment.fromJson(_normalize(Map<String, dynamic>.from(e))),
        )
        .toList();
  }

  Stream<List<Appointment>> watchUserAppointments(String userId) async* {
    yield await getUserAppointments(userId);
  }

  Future<Appointment?> getAppointmentByRequestId(String requestId) async {
    final res = await _api.get(
      '/appointments',
      query: {'requestId': requestId},
    );
    final list = _extractList(res);
    if (list.isEmpty) return null;
    return Appointment.fromJson(
      _normalize(Map<String, dynamic>.from(list.first)),
    );
  }

  Future<Appointment> upsertAppointmentOnAccept({
    required String requestId,
    required String clientId,
    required String technicianId,
    required String serviceType,
    String? serviceName,
    String? clientAddress,
    double? clientLatitude,
    double? clientLongitude,
    double? price,
  }) async {
    final res = await _api.post(
      '/appointments/upsert-on-accept',
      body: {
        'requestId': requestId,
        'clientId': clientId,
        'technicianId': technicianId,
        'serviceType': serviceType,
        if (serviceName != null) 'serviceName': serviceName,
        if (clientAddress != null) 'clientAddress': clientAddress,
        if (clientLatitude != null) 'clientLatitude': clientLatitude,
        if (clientLongitude != null) 'clientLongitude': clientLongitude,
        if (price != null) 'price': price,
      },
    );
    final data =
        (res['data'] as Map<String, dynamic>?)?['appointment'] ??
        res['data'] ??
        res;
    if (data is Map)
      return Appointment.fromJson(_normalize(Map<String, dynamic>.from(data)));
    return createAppointment(
      requestId: requestId,
      clientId: clientId,
      technicianId: technicianId,
      serviceType: serviceType,
      serviceName: serviceName,
      appointmentDate: DateTime.now(),
      appointmentTime:
          '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
      clientAddress: clientAddress,
      clientLatitude: clientLatitude,
      clientLongitude: clientLongitude,
      price: price,
    );
  }

  Future<void> completeAppointmentAndSetLocations({
    required String requestId,
    required double technicianLatitude,
    required double technicianLongitude,
    required double clientLatitude,
    required double clientLongitude,
  }) async {
    await _api.patch(
      '/appointments/by-request/$requestId/complete',
      body: {
        'technicianLatitude': technicianLatitude,
        'technicianLongitude': technicianLongitude,
        'clientLatitude': clientLatitude,
        'clientLongitude': clientLongitude,
      },
    );
  }

  Future<Appointment?> getAppointment(String appointmentId) async {
    try {
      final res = await _api.get('/appointments/$appointmentId');
      final data = (res['data'] as Map<String, dynamic>?) ?? res;
      return Appointment.fromJson(_normalize(Map<String, dynamic>.from(data)));
    } catch (_) {
      return null;
    }
  }

  Future<void> updateAppointmentStatus(
    String appointmentId,
    String status,
  ) async {
    await _api.patch(
      '/appointments/$appointmentId/status',
      body: {'status': status},
    );
  }

  Future<void> updateAppointmentLocation({
    required String appointmentId,
    required String role,
    required double latitude,
    required double longitude,
  }) async {
    await _api.patch(
      '/appointments/$appointmentId/location',
      body: {'role': role, 'latitude': latitude, 'longitude': longitude},
    );
  }

  Future<List<Appointment>> getTechnicianAppointments(
    String technicianId,
  ) async {
    final res = await _api.get(
      '/appointments',
      query: {'technicianId': technicianId},
    );
    final list = _extractList(res);
    return list
        .map(
          (e) => Appointment.fromJson(_normalize(Map<String, dynamic>.from(e))),
        )
        .toList();
  }

  Future<List<Appointment>> getClientAppointments(String clientId) async {
    final res = await _api.get('/appointments', query: {'userId': clientId});
    final list = _extractList(res);
    return list
        .map(
          (e) => Appointment.fromJson(_normalize(Map<String, dynamic>.from(e))),
        )
        .toList();
  }

  List<dynamic> _extractList(Map<String, dynamic> res) {
    final data = res['data'];
    if (data is List) return data;
    if (data is Map && data['appointments'] is List)
      return data['appointments'];
    return [];
  }
}
