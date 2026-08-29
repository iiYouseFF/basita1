class SupportTicket {
  final String id;
  final String userId;
  final String userType;
  final String subject;
  final String description;
  final String status;
  final String priority;
  final String? adminReply;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SupportTicket({
    required this.id,
    required this.userId,
    required this.userType,
    required this.subject,
    required this.description,
    this.status = 'open',
    this.priority = 'medium',
    this.adminReply,
    this.createdAt,
    this.updatedAt,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      userType: json['user_type'] ?? 'user',
      subject: json['subject'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'open',
      priority: json['priority'] ?? 'medium',
      adminReply: json['admin_reply'],
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
      'user_id': userId,
      'user_type': userType,
      'subject': subject,
      'description': description,
      'status': status,
      'priority': priority,
    };
  }
}
