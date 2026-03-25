import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/novel.dart';
import '../providers/novel_provider.dart';
import '../widgets/novel_card.dart';
import 'novel_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NovelProvider>().fetchPopularNovels();
    });
  }

  void _navigateToDetail(Novel novel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NovelDetailScreen(novel: novel),
      ),
    );
  }

  final List<Map<String, dynamic>> categories = [
    {'name': '玄幻', 'icon': Icons.auto_awesome, 'color': Colors.purple},
    {'name': '仙侠', 'icon': Icons.cloud, 'color': Colors.blue},
    {'name': '都市', 'icon': Icons.location_city, 'color': Colors.orange},
    {'name': '历史', 'icon': Icons.history_edu, 'color': Colors.brown},
    {'name': '科幻', 'icon': Icons.rocket, 'color': Colors.indigo},
    {'name': '游戏', 'icon': Icons.videogame_asset, 'color': Colors.green},
    {'name': '武侠', 'icon': Icons.sports_kabaddi, 'color': Colors.red},
    {'name': '悬疑', 'icon': Icons.psychology, 'color': Colors.teal},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '悦读',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8B4513),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<NovelProvider>().fetchPopularNovels();
        },
        child: CustomScrollView(
          slivers: [
            // 分类快捷入口
            SliverToBoxAdapter(
              child: _buildCategorySection(),
            ),

            // 热门推荐标题
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(
                  children: [
                    Icon(Icons.local_fire_department,
                        color: Colors.orange, size: 24),
                    SizedBox(width: 8),
                    Text(
                      '热门推荐',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 热门小说网格
            Consumer<NovelProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (provider.error != null) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text('加载失败: ${provider.error}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => provider.fetchPopularNovels(),
                            child: const Text('重试'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final novels = provider.popularNovels;
                if (novels.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: Text('暂无数据')),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return GestureDetector(
                          onTap: () => _navigateToDetail(novels[index]),
                          child: NovelCard(novel: novels[index]),
                        );
                      },
                      childCount: novels.length,
                    ),
                  ),
                );
              },
            ),

            // 底部间距
            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '分类',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return GestureDetector(
                onTap: () {
                  context
                      .read<NovelProvider>()
                      .searchNovels(category['name'] as String);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: (category['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        category['icon'] as IconData,
                        color: category['color'] as Color,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category['name'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          color: category['color'] as Color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
