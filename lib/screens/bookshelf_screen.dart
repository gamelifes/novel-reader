import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bookshelf_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/novel_card.dart';
import 'novel_detail_screen.dart';

class BookshelfScreen extends StatelessWidget {
  const BookshelfScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('书架'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '我的书架'),
              Tab(text: '最近阅读'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBookshelfTab(),
            _buildHistoryTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildBookshelfTab() {
    return Consumer<BookshelfProvider>(
      builder: (context, provider, child) {
        if (provider.bookshelf.isEmpty) {
          return _buildEmptyState(
            icon: Icons.book_outlined,
            message: '书架还是空的',
            subMessage: '去发现一些好书吧',
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.65,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: provider.bookshelf.length,
          itemBuilder: (context, index) {
            final novel = provider.bookshelf[index];
            final progress = provider.getProgress(novel.id);

            return Stack(
              children: [
                NovelCard(novel: novel),
                if (progress != null)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(12),
                        ),
                      ),
                      child: Text(
                        '读至第${progress.chapterIndex + 1}章',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    return Consumer<BookshelfProvider>(
      builder: (context, provider, child) {
        final recentNovels = provider.recentReads;

        if (recentNovels.isEmpty) {
          return _buildEmptyState(
            icon: Icons.history,
            message: '暂无阅读记录',
            subMessage: '开始阅读你的第一本书吧',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: recentNovels.length,
          itemBuilder: (context, index) {
            final novel = recentNovels[index];
            final progress = provider.getProgress(novel.id);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: novel.cover.isNotEmpty
                      ? Image.network(
                          novel.cover,
                          width: 50,
                          height: 70,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 50,
                          height: 70,
                          color: Colors.grey[300],
                          child: const Icon(Icons.book),
                        ),
                ),
                title: Text(novel.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(novel.author),
                    if (progress != null)
                      Text(
                        '上次读到：第${progress.chapterIndex + 1}章',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NovelDetailScreen(novel: novel),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required String subMessage,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subMessage,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // 切换到首页
            },
            child: const Text('去书城'),
          ),
        ],
      ),
    );
  }
}
