import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/novel.dart';
import '../providers/providers.dart';
import 'novel_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 搜索栏
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: '搜索书名、作者',
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                  ),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF8B7355)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Color(0xFF8B7355)),
                          onPressed: () {
                            _searchController.clear();
                            context.read<NovelProvider>().clearResults();
                            setState(() {});
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFFFAF0E6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
                style: const TextStyle(
                  color: Color(0xFF3D2914),
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    context.read<NovelProvider>().searchNovels(value.trim());
                  }
                },
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),

            // 搜索内容区域
            Expanded(
              child: Consumer<NovelProvider>(
                builder: (context, provider, child) {
                  // 显示加载中
                  if (provider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF8B4513),
                      ),
                    );
                  }

                  // 显示错误
                  if (provider.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            provider.error!,
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              provider.clearError();
                            },
                            child: const Text('重试'),
                          ),
                        ],
                      ),
                    );
                  }

                  // 显示搜索结果
                  if (provider.novels.isNotEmpty) {
                    return _buildSearchResults(provider.novels);
                  }

                  // 显示搜索历史和热门搜索
                  return _buildSearchHistory(provider);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(List<Novel> novels) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: novels.length,
      itemBuilder: (context, index) {
        final novel = novels[index];
        return _buildNovelListItem(novel);
      },
    );
  }

  Widget _buildNovelListItem(Novel novel) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NovelDetailScreen(novel: novel),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF0E6),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 封面
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 80,
                height: 110,
                color: Colors.grey[300],
                child: novel.cover.isNotEmpty
                    ? Image.network(
                        novel.cover,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Text(
                              novel.title.substring(0, 1),
                              style: const TextStyle(
                                fontSize: 24,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Text(
                          novel.title.substring(0, 1),
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.grey,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // 信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    novel.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3D2914),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    novel.author,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    novel.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B4513).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          novel.category,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF8B4513),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        novel.status,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHistory(NovelProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 搜索历史
          if (provider.searchHistory.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '搜索历史',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3D2914),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    provider.clearSearchHistory();
                  },
                  child: const Text(
                    '清空',
                    style: TextStyle(
                      color: Color(0xFF8B7355),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: provider.searchHistory.map((keyword) {
                return GestureDetector(
                  onTap: () {
                    _searchController.text = keyword;
                    provider.searchNovels(keyword);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF0E6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      keyword,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF3D2914),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // 热门搜索
          const Text(
            '热门搜索',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3D2914),
            ),
          ),
          const SizedBox(height: 12),
          _buildHotSearchList(),
        ],
      ),
    );
  }

  Widget _buildHotSearchList() {
    final hotSearches = [
      '斗破苍穹',
      '凡人修仙传',
      '诡秘之主',
      '大奉打更人',
      '完美世界',
      '遮天',
      '仙逆',
      '神墓',
    ];

    return Column(
      children: hotSearches.asMap().entries.map((entry) {
        final index = entry.key;
        final keyword = entry.value;
        return GestureDetector(
          onTap: () {
            _searchController.text = keyword;
            context.read<NovelProvider>().searchNovels(keyword);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[200]!,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: index < 3
                        ? const Color(0xFF8B4513)
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: index < 3 ? Colors.white : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    keyword,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF3D2914),
                    ),
                  ),
                ),
                Icon(
                  Icons.trending_up,
                  size: 16,
                  color: index < 3 ? Colors.orange : Colors.grey[400],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
