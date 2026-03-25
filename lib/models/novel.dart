class Novel {
  final String id;
  final String title;
  final String author;
  final String cover;
  final String summary;
  final String category;
  final String status;
  final int wordCount;
  final String lastUpdate;
  final double? rating;
  final int? readCount;

  Novel({
    required this.id,
    required this.title,
    required this.author,
    required this.cover,
    required this.summary,
    required this.category,
    required this.status,
    required this.wordCount,
    required this.lastUpdate,
    this.rating,
    this.readCount,
  });

  factory Novel.fromJson(Map<String, dynamic> json) {
    return Novel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title'] ?? json['book_name'] ?? '未知书名',
      author: json['author'] ?? '未知作者',
      cover: json['cover'] != null
          ? 'http://img22.aixdzs.com/${json['cover']}'
          : (json['cover_url'] ?? ''),
      summary: json['shortIntro'] ?? json['intro'] ?? json['summary'] ?? '暂无简介',
      category:
          json['cat'] ?? json['category'] ?? json['category_name'] ?? '其他',
      status: json['status'] ?? '连载中',
      wordCount: json['wordCount'] ?? json['word_count'] ?? 0,
      lastUpdate: json['updateTime'] ?? json['last_update'] ?? '',
      rating: (json['score'] ?? json['rating'])?.toDouble(),
      readCount: json['readCount'] ?? json['read_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'cover': cover,
      'summary': summary,
      'category': category,
      'status': status,
      'word_count': wordCount,
      'last_update': lastUpdate,
      'rating': rating,
      'read_count': readCount,
    };
  }

  Novel copyWith({
    String? id,
    String? title,
    String? author,
    String? cover,
    String? summary,
    String? category,
    String? status,
    int? wordCount,
    String? lastUpdate,
    double? rating,
    int? readCount,
  }) {
    return Novel(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      cover: cover ?? this.cover,
      summary: summary ?? this.summary,
      category: category ?? this.category,
      status: status ?? this.status,
      wordCount: wordCount ?? this.wordCount,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      rating: rating ?? this.rating,
      readCount: readCount ?? this.readCount,
    );
  }
}
