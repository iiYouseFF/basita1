import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:basita1/core/models/appointment.dart';

class AppointmentRepository {
  final SupabaseClient _client = Supabase.instance.client;

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
    final data = await _client
        .from('appointments')
        .insert({
          'request_id': requestId,
          'client_id': clientId,
          'technician_id': technicianId,
          'service_type': serviceType,
          'service_name': serviceName,
          'appointment_date': appointmentDate?.toIso8601String(),
          'appointment_time': appointmentTime,
          'client_address': clientAddress,
          'client_latitude': clientLatitude,
          'client_longitude': clientLongitude,
          'technician_latitude': technicianLatitude,
          'technician_longitude': technicianLongitude,
          'estimated_duration': estimatedDuration,
          'price': price,
          'notes': notes,
        })
        .select()
        .single();
    return Appointment.fromJson(data);
  }

  Future<List<Appointment>> getUserAppointments(String userId) async {
    final data = await _client
        .from('appointments')
        .select()
        .or('client_id.eq.$userId,technician_id.eq.$userId')
        .order('appointment_date', ascending: true);
    return data.map((json) => Appointment.fromJson(json)).toList();
  }

  Stream<List<Appointment>> watchUserAppointments(String userId) {
    return _client
        .from('appointments')
        .stream(primaryKey: ['id'])
        .order('appointment_date', ascending: true)
        .map((data) => data
            .where((json) =>
                json['client_id'] == userId ||
                json['technician_id'] == userId)
            .map((json) => Appointment.fromJson(json))
            .toList());
  }

  Future<Appointment?> getAppointmentByRequestId(String requestId) async {
    final data = await _client
        .from('appointments')
        .select()
        .eq('request_id', requestId)
        .maybeSingle();
    return data != null ? Appointment.fromJson(data) : null;
  }

  /// إنشاء موعد عند قبول الفني للطلب،
  /// أو تحديث الموعد الحالي إن كان موجوداً مسبقاً (يمنع التكرار).
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
    final existing = await getAppointmentByRequestId(requestId);
    if (existing != null) {
      await _client
          .from('appointments')
          .update({
            'technician_id': technicianId,
            'status': 'scheduled',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('request_id', requestId);
      return Appointment.fromJson({
        'id': existing.id,
        'request_id': requestId,
        'client_id': clientId,
        'technician_id': technicianId,
        'service_type': serviceType,
        'service_name': serviceName ?? existing.serviceName,
        'client_address': clientAddress ?? existing.clientAddress,
        'client_latitude': clientLatitude ?? 0,
        'client_longitude': clientLongitude ?? 0,
        'price': price ?? existing.price,
      });
    }

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

  /// إتمام المهمة: تحديث حالة الموعد ومواقع الفني والعميل.
  Future<void> completeAppointmentAndSetLocations({
    required String requestId,
    required double technicianLatitude,
    required double technicianLongitude,
    required double clientLatitude,
    required double clientLongitude,
  }) async {
    await _client
        .from('appointments')
        .update({
          'status': 'completed',
          'technician_latitude': technicianLatitude,
          'technician_longitude': technicianLongitude,
          'client_latitude': clientLatitude,
          'client_longitude': clientLongitude,
          'completed_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('request_id', requestId);
  }

  Future<Appointment?> getAppointment(String appointmentId) async {
    final data = await _client
        .from('appointments')
        .select()
        .eq('id', appointmentId)
        .maybeSingle();
    return data != null ? Appointment.fromJson(data) : null;
  }

  Future<void> updateAppointmentStatus(
      String appointmentId, String status) async {
    await _client
        .from('appointments')
        .update({'status': status, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', appointmentId);
  }

  Future<void> updateAppointmentLocation({
    required String appointmentId,
    required String role,
    required double latitude,
    required double longitude,
  }) async {
    final updateData = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (role == 'technician') {
      updateData['technician_latitude'] = latitude;
      updateData['technician_longitude'] = longitude;
    } else {
      updateData['client_latitude'] = latitude;
      updateData['client_longitude'] = longitude;
    }
    await _client
        .from('appointments')
        .update(updateData)
        .eq('id', appointmentId);
  }

  Future<List<Appointment>> getTechnicianAppointments(String technicianId) async {
    final data = await _client
        .from('appointments')
        .select()
        .eq('technician_id', technicianId)
        .order('appointment_date', ascending: true);
    return data.map((json) => Appointment.fromJson(json)).toList();
  }

  Future<List<Appointment>> getClientAppointments(String clientId) async {
    final data = await _client
        .from('appointments')
        .select()
        .eq('client_id', clientId)
        .order('appointment_date', ascending: true);
    return data.map((json) => Appointment.fromJson(json)).toList();
  }
}
