import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/novel.dart';
import '../models/user.dart';

class BookshelfProvider extends ChangeNotifier {
  List<Novel> _bookshelf = [];
  List<Novel> get bookshelf => _bookshelf;
  
  // 阅读进度: novelId -> ReadingProgress
  Map<String, ReadingProgress> _readingProgress = {};
  Map<String, ReadingProgress> get readingProgress => _readingProgress;
  
  // 最近阅读
  List<Novel> get recentReads {
    var sorted = List<Novel>.from(_bookshelf);
    sorted.sort((a, b) {
      var progressA = _readingProgress[a.id];
      var progressB = _readingProgress[b.id];
      if (progressA == null && progressB == null) return 0;
      if (progressA == null) return 1;
      if (progressB == null) return -1;
      return progressB.lastReadTime.compareTo(progressA.lastReadTime);
    });
    return sorted.take(10).toList();
  }

  static const String _bookshelfKey = 'bookshelf';
  static const String _progressKey = 'reading_progress';

  BookshelfProvider() {
    _loadData();
  }

  /// 加载本地数据
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 加载书架
    final bookshelfJson = prefs.getString(_bookshelfKey);
    if (bookshelfJson != null) {
      final List<dynamic> decoded = json.decode(bookshelfJson);
      _bookshelf = decoded.map((item) => Novel.fromJson(item)).toList();
    }
    
    // 加载阅读进度
    final progressJson = prefs.getString(_progressKey);
    if (progressJson != null) {
      final Map<String, dynamic> decoded = json.decode(progressJson);
      _readingProgress = decoded.map((key, value) => 
        MapEntry(key, ReadingProgress.fromJson(value)));
    }
    
    notifyListeners();
  }

  /// 保存书架
  Future<void> _saveBookshelf() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(_bookshelf.map((n) => n.toJson()).toList());
    await prefs.setString(_bookshelfKey, encoded);
  }

  /// 保存阅读进度
  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(
      _readingProgress.map((key, value) => MapEntry(key, value.toJson()))
    );
    await prefs.setString(_progressKey, encoded);
  }

  /// 添加到书架
  Future<void> addToBookshelf(Novel novel) async {
    if (!isInBookshelf(novel.id)) {
      _bookshelf.add(novel);
      await _saveBookshelf();
      notifyListeners();
    }
  }

  /// 从书架移除
  Future<void> removeFromBookshelf(String novelId) async {
    _bookshelf.removeWhere((n) => n.id == novelId);
    _readingProgress.remove(novelId);
    await _saveBookshelf();
    await _saveProgress();
    notifyListeners();
  }

  /// 更新阅读进度
  Future<void> updateReadingProgress(
    String novelId, 
    String chapterId, 
    int chapterIndex, 
    {double scrollPosition = 0.0}
  ) async {
    _readingProgress[novelId] = ReadingProgress(
      novelId: novelId,
      chapterId: chapterId,
      chapterIndex: chapterIndex,
      scrollPosition: scrollPosition,
      lastReadTime: DateTime.now(),
    );
    await _saveProgress();
    notifyListeners();
  }

  /// 检查是否在书架
  bool isInBookshelf(String novelId) {
    return _bookshelf.any((n) => n.id == novelId);
  }

  /// 获取阅读进度
  ReadingProgress? getProgress(String novelId) {
    return _readingProgress[novelId];
  }

  /// 获取最近阅读的章节索引
  int getLastChapterIndex(String novelId) {
    return _readingProgress[novelId]?.chapterIndex ?? 0;
  }

  /// 清空书架
  Future<void> clearBookshelf() async {
    _bookshelf.clear();
    _readingProgress.clear();
    await _saveBookshelf();
    await _saveProgress();
    notifyListeners();
  }
}
