class ApiPost {
  final String? id;
  final String? authorId;
  final String? authorName;
  final String? authorRole;
  final String? title;
  final String? content;
  final String? imagePath;
  final bool? isQuestion;
  final String? category;
  final List<String>? likedBy;
  final int? likesCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ApiPost({
    this.id,
    this.authorId,
    this.authorName,
    this.authorRole,
    this.title,
    this.content,
    this.imagePath,
    this.isQuestion,
    this.category,
    this.likedBy,
    this.likesCount,
    this.createdAt,
    this.updatedAt,
  });

  factory ApiPost.fromJson(Map<String, dynamic> json) {
    return ApiPost(
      id: json['id']?.toString(),
      authorId: json['authorId'],
      authorName: json['authorName'],
      authorRole: json['authorRole'],
      title: json['title'],
      content: json['content'],
      imagePath: json['imagePath'],
      isQuestion: json['isQuestion'],
      category: json['category'],
      likedBy: json['likedBy'] != null ? List<String>.from(json['likedBy']) : null,
      likesCount: json['likesCount'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'authorRole': authorRole,
      'title': title,
      'content': content,
      'imagePath': imagePath,
      'isQuestion': isQuestion,
      'category': category,
    };
  }
}
