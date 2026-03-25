import 'package:flutter/material.dart';
import '../models/novel.dart';

class NovelDetailScreen extends StatefulWidget {
  final Novel novel;

  const NovelDetailScreen({super.key, required this.novel});

  @override
  State<NovelDetailScreen> createState() => _NovelDetailScreenState();
}

class _NovelDetailScreenState extends State<NovelDetailScreen> {
  bool showFullSummary = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 可折叠的AppBar
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeader(),
            ),
          ),

          // 小说信息
          SliverToBoxAdapter(
            child: _buildInfoSection(),
          ),

          // 简介
          SliverToBoxAdapter(
            child: _buildSummarySection(),
          ),

          // 章节列表标题
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                '章节列表',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // 章节列表（简化版）
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _buildChapterItem(index);
              },
              childCount: 20, // 显示前20章
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey[400]!,
            Colors.grey[200]!,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'novel_cover_${widget.novel.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: widget.novel.cover.isNotEmpty
                    ? Image.network(
                        widget.novel.cover,
                        height: 180,
                        width: 130,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholder();
                        },
                      )
                    : _buildPlaceholder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.novel.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.novel.author,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 180,
      width: 130,
      color: Colors.grey[300],
      child: const Icon(Icons.book, size: 60, color: Colors.grey),
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem('状态', widget.novel.status),
          _buildInfoItem('分类', widget.novel.category),
          _buildInfoItem(
              '字数', '${(widget.novel.wordCount / 10000).toStringAsFixed(1)}万'),
          if (widget.novel.rating != null)
            _buildInfoItem('评分', widget.novel.rating!.toStringAsFixed(1)),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '简介',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                showFullSummary = !showFullSummary;
              });
            },
            child: Text(
              widget.novel.summary,
              maxLines: showFullSummary ? null : 3,
              overflow: showFullSummary ? null : TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.6,
              ),
            ),
          ),
          if (widget.novel.summary.length > 100)
            TextButton(
              onPressed: () {
                setState(() {
                  showFullSummary = !showFullSummary;
                });
              },
              child: Text(showFullSummary ? '收起' : '展开更多'),
            ),
        ],
      ),
    );
  }

  Widget _buildChapterItem(int index) {
    return ListTile(
      title: Text('第${index + 1}章'),
      subtitle: const Text('章节标题示例'),
      trailing: index > 20
          ? const Icon(Icons.lock, size: 16, color: Colors.grey)
          : null,
      onTap: () {
        // 导航到阅读页面
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => ReaderScreen(
        //       novel: widget.novel,
        //       chapterIndex: index,
        //     ),
        //   ),
        // );
      },
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: ElevatedButton.icon(
                onPressed: () {
                  // 加入书架
                },
                icon: const Icon(Icons.bookmark_border),
                label: const Text('加入书架'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black87,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {
                  // 开始阅读
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => ReaderScreen(
                  //       novel: widget.novel,
                  //       chapterIndex: 0,
                  //     ),
                  //   ),
                  // );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B4513),
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  '开始阅读',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
