class User {
  final String id;
  final String name;
  final String avatar;
  final String? email;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.name,
    required this.avatar,
    this.email,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['nickname'] ?? '书友',
      avatar: json['avatar'] ?? json['avatar_url'] ?? '',
      email: json['email'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'email': email,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class ReadingProgress {
  final String novelId;
  final String chapterId;
  final int chapterIndex;
  final double scrollPosition;
  final DateTime lastReadTime;

  ReadingProgress({
    required this.novelId,
    required this.chapterId,
    required this.chapterIndex,
    this.scrollPosition = 0.0,
    required this.lastReadTime,
  });

  factory ReadingProgress.fromJson(Map<String, dynamic> json) {
    return ReadingProgress(
      novelId: json['novel_id'] ?? '',
      chapterId: json['chapter_id'] ?? '',
      chapterIndex: json['chapter_index'] ?? 0,
      scrollPosition: (json['scroll_position'] ?? 0.0).toDouble(),
      lastReadTime: json['last_read_time'] != null 
          ? DateTime.parse(json['last_read_time']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'novel_id': novelId,
      'chapter_id': chapterId,
      'chapter_index': chapterIndex,
      'scroll_position': scrollPosition,
      'last_read_time': lastReadTime.toIso8601String(),
    };
  }
}
