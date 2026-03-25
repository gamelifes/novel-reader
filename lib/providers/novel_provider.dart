import 'package:flutter/material.dart';
import '../models/novel.dart';
import '../services/novel_service.dart';

class NovelProvider extends ChangeNotifier {
  final NovelService _novelService = NovelService();

  List<Novel> _novels = [];
  List<Novel> get novels => _novels;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // 热门小说
  List<Novel> _popularNovels = [];
  List<Novel> get popularNovels => _popularNovels;

  // 搜索历史
  final List<String> _searchHistory = [];
  List<String> get searchHistory => _searchHistory;

  /// 搜索小说
  Future<void> searchNovels(String keyword) async {
    if (keyword.isEmpty) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _novels = await _novelService.searchNovels(keyword);
      _addToSearchHistory(keyword);
    } catch (e) {
      _error = '搜索失败: $e';
      _novels = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 获取热门小说
  Future<void> fetchPopularNovels() async {
    _isLoading = true;
    notifyListeners();

    try {
      _popularNovels = await _novelService.getPopularNovels();
    } catch (e) {
      _error = '获取热门小说失败: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 获取小说详情
  Future<Novel?> getNovelDetail(String novelId) async {
    try {
      return await _novelService.getNovelDetail(novelId);
    } catch (e) {
      _error = '获取小说详情失败: $e';
      return null;
    }
  }

  /// 添加到搜索历史
  void _addToSearchHistory(String keyword) {
    if (!_searchHistory.contains(keyword)) {
      _searchHistory.insert(0, keyword);
      if (_searchHistory.length > 10) {
        _searchHistory.removeLast();
      }
      notifyListeners();
    }
  }

  /// 清除搜索历史
  void clearSearchHistory() {
    _searchHistory.clear();
    notifyListeners();
  }

  /// 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// 清除搜索结果
  void clearResults() {
    _novels = [];
    notifyListeners();
  }
}
