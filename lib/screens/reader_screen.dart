import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/novel.dart';
import '../models/chapter.dart';
import '../providers/bookshelf_provider.dart';
import '../providers/settings_provider.dart';
import '../services/novel_service.dart';

class ReaderScreen extends StatefulWidget {
  final Novel novel;
  final int initialChapterIndex;

  const ReaderScreen({
    super.key,
    required this.novel,
    this.initialChapterIndex = 0,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late NovelService _novelService;
  List<Chapter> _chapters = [];
  Chapter? _currentChapter;
  int _currentChapterIndex = 0;
  bool _isLoading = true;
  bool _showControls = true;
  final PageController _pageController = PageController();
  List<String> _pages = [];

  @override
  void initState() {
    super.initState();
    _currentChapterIndex = widget.initialChapterIndex;
    _novelService = NovelService();
    _loadChapters();
  }

  Future<void> _loadChapters() async {
    try {
      _chapters = await _novelService.getChapterList(widget.novel.id);
      if (_chapters.isNotEmpty && _currentChapterIndex < _chapters.length) {
        await _loadChapterContent(_chapters[_currentChapterIndex]);
      }
    } catch (e) {
      print('Load chapters error: $e');
    }
  }

  Future<void> _loadChapterContent(Chapter chapter) async {
    setState(() => _isLoading = true);
    try {
      final content = await _novelService.getChapterContent(chapter.id);
      if (content != null) {
        setState(() {
          _currentChapter = content;
          _pages = _splitContent(content.content);
          _isLoading = false;
        });

        // 更新阅读进度
        context.read<BookshelfProvider>().updateReadingProgress(
              widget.novel.id,
              chapter.id,
              chapter.index,
            );
      }
    } catch (e) {
      print('Load chapter content error: $e');
      setState(() => _isLoading = false);
    }
  }

  List<String> _splitContent(String content) {
    // 简单分页逻辑
    final settings = context.read<SettingsProvider>();
    final pageSize = 1000; // 每页大约字符数

    if (content.length <= pageSize) {
      return [content];
    }

    List<String> pages = [];
    for (int i = 0; i < content.length; i += pageSize) {
      int end = (i + pageSize < content.length) ? i + pageSize : content.length;
      // 尽量在句号或换行处分页
      if (end < content.length) {
        while (end > i && content[end - 1] != '。' && content[end - 1] != '\n') {
          end--;
        }
        if (end == i) end = i + pageSize;
      }
      pages.add(content.substring(i, end));
    }
    return pages;
  }

  void _nextChapter() {
    if (_currentChapterIndex < _chapters.length - 1) {
      _currentChapterIndex++;
      _loadChapterContent(_chapters[_currentChapterIndex]);
    }
  }

  void _previousChapter() {
    if (_currentChapterIndex > 0) {
      _currentChapterIndex--;
      _loadChapterContent(_chapters[_currentChapterIndex]);
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Scaffold(
          backgroundColor: settings.backgroundColor,
          body: GestureDetector(
            onTap: _toggleControls,
            child: Stack(
              children: [
                // 阅读内容
                _buildReaderContent(settings),

                // 顶部控制栏
                if (_showControls) _buildTopBar(settings),

                // 底部控制栏
                if (_showControls) _buildBottomBar(settings),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReaderContent(SettingsProvider settings) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: settings.textColor,
        ),
      );
    }

    if (_pages.isEmpty) {
      return Center(
        child: Text(
          '暂无内容',
          style: TextStyle(color: settings.textColor),
        ),
      );
    }

    return PageView.builder(
      controller: _pageController,
      itemCount: _pages.length,
      onPageChanged: (index) {
        if (index == _pages.length - 1 &&
            _currentChapterIndex < _chapters.length - 1) {
          // 最后一页，加载下一章
          // 这里可以显示"加载下一章"的提示
        }
      },
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.all(settings.pagePadding),
          child: SingleChildScrollView(
            child: Text(
              _pages[index],
              style: TextStyle(
                fontSize: settings.fontSize,
                height: settings.lineHeight,
                color: settings.textColor,
                fontFamily: settings.fontFamily,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(SettingsProvider settings) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        color: settings.backgroundColor.withOpacity(0.95),
        child: SafeArea(
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: settings.textColor),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              _currentChapter?.title ?? widget.novel.title,
              style: TextStyle(color: settings.textColor, fontSize: 16),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.more_vert, color: settings.textColor),
                onPressed: () {
                  _showChapterList();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(SettingsProvider settings) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: settings.backgroundColor.withOpacity(0.95),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 章节导航
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: _previousChapter,
                      child: Text(
                        '上一章',
                        style: TextStyle(color: settings.textColor),
                      ),
                    ),
                    Text(
                      '第${_currentChapterIndex + 1}/${_chapters.length}章',
                      style: TextStyle(color: settings.textColor),
                    ),
                    TextButton(
                      onPressed: _nextChapter,
                      child: Text(
                        '下一章',
                        style: TextStyle(color: settings.textColor),
                      ),
                    ),
                  ],
                ),
              ),

              // 底部工具栏
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: settings.textColor.withOpacity(0.2),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBottomAction(
                      icon: Icons.settings,
                      label: '设置',
                      onTap: () => _showSettingsPanel(settings),
                    ),
                    _buildBottomAction(
                      icon: settings.isDarkMode
                          ? Icons.wb_sunny
                          : Icons.nights_stay,
                      label: settings.isDarkMode ? '日间' : '夜间',
                      onTap: () {
                        settings.toggleDarkMode();
                      },
                    ),
                    _buildBottomAction(
                      icon: Icons.list,
                      label: '目录',
                      onTap: () => _showChapterList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  void _showSettingsPanel(SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: settings.backgroundColor,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('阅读设置',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // 字体大小
              Row(
                children: [
                  Text('字体', style: TextStyle(color: settings.textColor)),
                  Expanded(
                    child: Slider(
                      value: settings.fontSize,
                      min: 12,
                      max: 24,
                      onChanged: (value) {
                        settings.setFontSize(value);
                      },
                    ),
                  ),
                ],
              ),

              // 主题选择
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ReadTheme.values.map((theme) {
                  final isSelected = settings.currentTheme == theme;
                  return GestureDetector(
                    onTap: () => settings.setTheme(theme),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: theme.backgroundColor,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showChapterList() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '章节目录',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text('共${_chapters.length}章'),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _chapters.length,
                  itemBuilder: (context, index) {
                    final chapter = _chapters[index];
                    final isCurrent = index == _currentChapterIndex;

                    return ListTile(
                      title: Text(
                        chapter.title,
                        style: TextStyle(
                          color:
                              isCurrent ? Theme.of(context).primaryColor : null,
                          fontWeight: isCurrent ? FontWeight.bold : null,
                        ),
                      ),
                      trailing: chapter.isVip
                          ? const Icon(Icons.lock, size: 16)
                          : null,
                      onTap: () {
                        _currentChapterIndex = index;
                        _loadChapterContent(chapter);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
