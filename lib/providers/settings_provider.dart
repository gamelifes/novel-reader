import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  // 字体大小 (12.0 - 24.0)
  double _fontSize = 16.0;
  double get fontSize => _fontSize;
  
  // 行高倍数 (1.2 - 2.0)
  double _lineHeight = 1.5;
  double get lineHeight => _lineHeight;
  
  // 页面边距
  double _pagePadding = 16.0;
  double get pagePadding => _pagePadding;
  
  // 字体名称
  String _fontFamily = 'Noto Serif SC';
  String get fontFamily => _fontFamily;
  
  // 是否启用夜间模式
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;
  
  // 阅读主题
  ReadTheme _currentTheme = ReadTheme.paper;
  ReadTheme get currentTheme => _currentTheme;

  // 背景颜色
  Color get backgroundColor => _isDarkMode 
      ? const Color(0xFF1A1A1A) 
      : _currentTheme.backgroundColor;
  
  // 文字颜色
  Color get textColor => _isDarkMode 
      ? const Color(0xFFB8B8B8) 
      : _currentTheme.textColor;

  static const String _settingsKey = 'reader_settings';

  SettingsProvider() {
    _loadSettings();
  }

  /// 加载设置
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_settingsKey);
    
    if (settingsJson != null) {
      final Map<String, dynamic> settings = json.decode(settingsJson);
      _fontSize = settings['fontSize'] ?? 16.0;
      _lineHeight = settings['lineHeight'] ?? 1.5;
      _pagePadding = settings['pagePadding'] ?? 16.0;
      _fontFamily = settings['fontFamily'] ?? 'Noto Serif SC';
      _isDarkMode = settings['isDarkMode'] ?? false;
      _currentTheme = ReadTheme.values[settings['themeIndex'] ?? 0];
      notifyListeners();
    }
  }

  /// 保存设置
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settings = {
      'fontSize': _fontSize,
      'lineHeight': _lineHeight,
      'pagePadding': _pagePadding,
      'fontFamily': _fontFamily,
      'isDarkMode': _isDarkMode,
      'themeIndex': _currentTheme.index,
    };
    await prefs.setString(_settingsKey, json.encode(settings));
  }

  /// 设置字体大小
  Future<void> setFontSize(double size) async {
    if (size >= 12.0 && size <= 24.0) {
      _fontSize = size;
      await _saveSettings();
      notifyListeners();
    }
  }

  /// 设置行高
  Future<void> setLineHeight(double height) async {
    if (height >= 1.2 && height <= 2.0) {
      _lineHeight = height;
      await _saveSettings();
      notifyListeners();
    }
  }

  /// 设置页面边距
  Future<void> setPagePadding(double padding) async {
    if (padding >= 8.0 && padding <= 32.0) {
      _pagePadding = padding;
      await _saveSettings();
      notifyListeners();
    }
  }

  /// 设置字体
  Future<void> setFontFamily(String font) async {
    _fontFamily = font;
    await _saveSettings();
    notifyListeners();
  }

  /// 切换夜间模式
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _saveSettings();
    notifyListeners();
  }

  /// 设置夜间模式
  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    await _saveSettings();
    notifyListeners();
  }

  /// 设置主题
  Future<void> setTheme(ReadTheme theme) async {
    _currentTheme = theme;
    await _saveSettings();
    notifyListeners();
  }

  /// 重置为默认设置
  Future<void> resetToDefault() async {
    _fontSize = 16.0;
    _lineHeight = 1.5;
    _pagePadding = 16.0;
    _fontFamily = 'Noto Serif SC';
    _isDarkMode = false;
    _currentTheme = ReadTheme.paper;
    await _saveSettings();
    notifyListeners();
  }
}

/// 阅读主题枚举
enum ReadTheme {
  paper('羊皮纸', Color(0xFFF5E6D3), Color(0xFF3D2914)),
  white('纯白', Color(0xFFFFFFFF), Color(0xFF333333)),
  sepia('茶色', Color(0xFFF4ECD8), Color(0xFF5B4636)),
  green('护眼绿', Color(0xFFE8F5E9), Color(0xFF2E4A3E)),
  dark('深色', Color(0xFF2D2D2D), Color(0xFFB8B8B8));

  final String label;
  final Color backgroundColor;
  final Color textColor;

  const ReadTheme(this.label, this.backgroundColor, this.textColor);
}
