class Appointment {
  final String id;
  final String requestId;
  final String clientId;
  final String technicianId;
  final String serviceType;
  final String? serviceName;
  final String status;
  final DateTime? appointmentDate;
  final String? appointmentTime;
  final String? clientAddress;
  final double? clientLatitude;
  final double? clientLongitude;
  final double? technicianLatitude;
  final double? technicianLongitude;
  final String? estimatedDuration;
  final double? price;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Appointment({
    required this.id,
    required this.requestId,
    required this.clientId,
    required this.technicianId,
    required this.serviceType,
    this.serviceName,
    this.status = 'scheduled',
    this.appointmentDate,
    this.appointmentTime,
    this.clientAddress,
    this.clientLatitude,
    this.clientLongitude,
    this.technicianLatitude,
    this.technicianLongitude,
    this.estimatedDuration,
    this.price,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] ?? '',
      requestId: json['request_id'] ?? '',
      clientId: json['client_id'] ?? '',
      technicianId: json['technician_id'] ?? '',
      serviceType: json['service_type'] ?? '',
      serviceName: json['service_name'],
      status: json['status'] ?? 'scheduled',
      appointmentDate: json['appointment_date'] != null
          ? DateTime.tryParse(json['appointment_date'])
          : null,
      appointmentTime: json['appointment_time'],
      clientAddress: json['client_address'],
      clientLatitude: (json['client_latitude'] ?? 0).toDouble(),
      clientLongitude: (json['client_longitude'] ?? 0).toDouble(),
      technicianLatitude: (json['technician_latitude'] ?? 0).toDouble(),
      technicianLongitude: (json['technician_longitude'] ?? 0).toDouble(),
      estimatedDuration: json['estimated_duration'],
      price: (json['price'] ?? 0).toDouble(),
      notes: json['notes'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'request_id': requestId,
      'client_id': clientId,
      'technician_id': technicianId,
      'service_type': serviceType,
      'service_name': serviceName,
      'status': status,
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
    };
  }
}
