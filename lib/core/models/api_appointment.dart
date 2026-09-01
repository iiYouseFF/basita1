class ApiAppointment {
  final String? id;
  final String? requestId;
  final String? clientId;
  final String? technicianId;
  final String? serviceType;
  final String? serviceName;
  final DateTime? appointmentDate;
  final String? appointmentTime;
  final String? clientAddress;
  final double? price;
  final String? status;
  final double? technicianLatitude;
  final double? technicianLongitude;
  final double? clientLatitude;
  final double? clientLongitude;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ApiAppointment({
    this.id,
    this.requestId,
    this.clientId,
    this.technicianId,
    this.serviceType,
    this.serviceName,
    this.appointmentDate,
    this.appointmentTime,
    this.clientAddress,
    this.price,
    this.status,
    this.technicianLatitude,
    this.technicianLongitude,
    this.clientLatitude,
    this.clientLongitude,
    this.createdAt,
    this.updatedAt,
  });

  factory ApiAppointment.fromJson(Map<String, dynamic> json) {
    return ApiAppointment(
      id: json['id']?.toString(),
      requestId: json['requestId'],
      clientId: json['clientId'],
      technicianId: json['technicianId'],
      serviceType: json['serviceType'],
      serviceName: json['serviceName'],
      appointmentDate: json['appointmentDate'] != null ? DateTime.parse(json['appointmentDate']) : null,
      appointmentTime: json['appointmentTime'],
      clientAddress: json['clientAddress'],
      price: json['price']?.toDouble(),
      status: json['status'],
      technicianLatitude: json['technicianLatitude']?.toDouble(),
      technicianLongitude: json['technicianLongitude']?.toDouble(),
      clientLatitude: json['clientLatitude']?.toDouble(),
      clientLongitude: json['clientLongitude']?.toDouble(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'clientId': clientId,
      'technicianId': technicianId,
      'serviceType': serviceType,
      'serviceName': serviceName,
      'appointmentDate': appointmentDate?.toIso8601String(),
      'appointmentTime': appointmentTime,
      'clientAddress': clientAddress,
      'price': price,
    };
  }
}
