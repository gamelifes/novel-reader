class Chapter {
  final String id;
  final String novelId;
  final String title;
  final String content;
  final int index;
  final bool isVip;
  final int? wordCount;
  final String? updateTime;

  Chapter({
    required this.id,
    required this.novelId,
    required this.title,
    this.content = '',
    required this.index,
    this.isVip = false,
    this.wordCount,
    this.updateTime,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id']?.toString() ?? json['chapter_id']?.toString() ?? '',
      novelId: json['novel_id']?.toString() ?? json['book_id']?.toString() ?? '',
      title: json['title'] ?? json['chapter_name'] ?? '无标题',
      content: json['content'] ?? json['text'] ?? '',
      index: json['index'] ?? json['chapter_order'] ?? 0,
      isVip: json['is_vip'] ?? json['isVip'] ?? false,
      wordCount: json['word_count'] ?? json['wordCount'],
      updateTime: json['update_time'] ?? json['updateTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'novel_id': novelId,
      'title': title,
      'content': content,
      'index': index,
      'is_vip': isVip,
      'word_count': wordCount,
      'update_time': updateTime,
    };
  }
}
