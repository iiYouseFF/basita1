class ApiChatRoom {
  final String? id;
  final String? clientId;
  final String? technicianId;
  final String? requestId;
  final String? serviceType;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ApiChatRoom({
    this.id,
    this.clientId,
    this.technicianId,
    this.requestId,
    this.serviceType,
    this.createdAt,
    this.updatedAt,
  });

  factory ApiChatRoom.fromJson(Map<String, dynamic> json) {
    return ApiChatRoom(
      id: json['id']?.toString(),
      clientId: json['clientId'],
      technicianId: json['technicianId'],
      requestId: json['requestId'],
      serviceType: json['serviceType'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'technicianId': technicianId,
      'requestId': requestId,
      'serviceType': serviceType,
    };
  }
}

class ApiChatMessage {
  final String? id;
  final String? roomId;
  final String? senderId;
  final String? senderType;
  final String? message;
  final bool? isRead;
  final DateTime? createdAt;

  ApiChatMessage({
    this.id,
    this.roomId,
    this.senderId,
    this.senderType,
    this.message,
    this.isRead,
    this.createdAt,
  });

  factory ApiChatMessage.fromJson(Map<String, dynamic> json) {
    return ApiChatMessage(
      id: json['id']?.toString(),
      roomId: json['roomId'],
      senderId: json['senderId'],
      senderType: json['senderType'],
      message: json['message'],
      isRead: json['isRead'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'senderType': senderType,
      'message': message,
    };
  }
}
