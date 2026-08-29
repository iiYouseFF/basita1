class ChatRoom {
  final String id;
  final String clientId;
  final String technicianId;
  final String? requestId;
  final String? serviceType;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ChatRoom({
    required this.id,
    required this.clientId,
    required this.technicianId,
    this.requestId,
    this.serviceType,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'] ?? '',
      clientId: json['client_id'] ?? '',
      technicianId: json['technician_id'] ?? '',
      requestId: json['request_id'],
      serviceType: json['service_type'],
      isActive: json['is_active'] ?? true,
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
      'client_id': clientId,
      'technician_id': technicianId,
      'request_id': requestId,
      'service_type': serviceType,
      'is_active': isActive,
    };
  }
}
