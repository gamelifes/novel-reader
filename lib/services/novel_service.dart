import '../models/novel.dart';
import '../models/chapter.dart';
import 'api_service.dart';

class NovelService {
  static final NovelService _instance = NovelService._internal();
  factory NovelService() => _instance;
  NovelService._internal() {
    ApiService().initialize();
  }

  final ApiService _api = ApiService();

  /// 搜索小说
  Future<List<Novel>> searchNovels(String keyword, {int limit = 30}) async {
    try {
      final response = await _api.get('/book/search', queryParameters: {
        'query': keyword,
        'limit': limit.toString(),
      });

      if (response.data is Map && response.data['books'] != null) {
        final List<dynamic> data = response.data['books'];
        return data.map((item) => Novel.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      // 返回模拟数据用于测试
      return _getMockNovels();
    }
  }

  /// 获取小说详情
  Future<Novel?> getNovelDetail(String novelId) async {
    try {
      // 这里使用搜索接口作为示例，实际应该有专门的详情接口
      final novels = await searchNovels(novelId, limit: 1);
      return novels.isNotEmpty ? novels.first : null;
    } catch (e) {
      return _getMockNovels().firstWhere(
        (n) => n.id == novelId,
        orElse: () => _getMockNovels().first,
      );
    }
  }

  /// 获取章节列表
  Future<List<Chapter>> getChapterList(String novelId) async {
    try {
      // 根据爱下电子书的API结构，获取章节目录
      final response = await _api.get('/mixToc/$novelId');

      if (response.data is Map &&
          response.data['mixToc'] != null &&
          response.data['mixToc']['chapters'] != null) {
        final List<dynamic> chaptersData = response.data['mixToc']['chapters'];
        return chaptersData
            .map((chapter) => Chapter.fromJson(chapter))
            .toList();
      }

      // 如果上面的方式失败，尝试另一种可能的章节目录接口
      final tocResponse = await _api.get('/toc/$novelId?view=chapters');

      if (tocResponse.data is Map && tocResponse.data['chapters'] != null) {
        final List<dynamic> chaptersData = tocResponse.data['chapters'];
        return chaptersData
            .map((chapter) => Chapter.fromJson(chapter))
            .toList();
      }

      return [];
    } catch (e) {
      // 返回模拟数据用于测试
      return _getMockChapters(novelId);
    }
  }

  /// 获取章节内容
  Future<Chapter?> getChapterContent(String itemId) async {
    try {
      // 根据爱下电子书的API结构，获取章节内容
      final response = await _api.get('/chapter/$itemId');

      if (response.data is Map && response.data['chapter'] != null) {
        final chapterData = response.data['chapter'];
        return Chapter.fromJson({
          'id': itemId,
          'novelId': chapterData['book_id']?.toString() ?? '',
          'title': chapterData['title'] ?? '章节标题',
          'content': chapterData['body'] ?? chapterData['content'] ?? '',
          'index': chapterData['chapter_order'] ?? 0,
          'isVip': chapterData['is_vip'] ?? false,
          'wordCount': chapterData['word_count'] ?? 0,
          'updateTime': chapterData['update_time'] ?? '',
        });
      }

      // 如果上面的方式失败，尝试另一种可能的章节内容接口
      final contentResponse = await _api.get('/content', queryParameters: {
        'id': itemId,
      });

      if (contentResponse.data is Map &&
          contentResponse.data['content'] != null) {
        final contentData = contentResponse.data['content'];
        return Chapter.fromJson({
          'id': itemId,
          'novelId': '',
          'title': contentData['title'] ?? '章节标题',
          'content': contentData['body'] ?? contentData['content'] ?? '',
          'index': 0,
          'isVip': false,
          'wordCount': 0,
          'updateTime': '',
        });
      }

      return null;
    } catch (e) {
      return _getMockChapterContent(itemId);
    }
  }

  /// 获取热门小说
  Future<List<Novel>> getPopularNovels() async {
    return searchNovels('热门', limit: 20);
  }

  /// 模拟小说数据
  List<Novel> _getMockNovels() {
    return [
      Novel(
        id: '1',
        title: '斗破苍穹',
        author: '天蚕土豆',
        cover: 'https://via.placeholder.com/300x400/FF6B6B/FFFFFF?text=斗破苍穹',
        summary:
            '这里是斗气大陆，没有花俏艳丽的魔法，有的，仅仅是繁衍到巅峰的斗气！主角萧炎，少年天才，却因变故修为尽失，受尽嘲讽。然在药老的帮助下，他重获力量，踏上强者之路...',
        category: '玄幻',
        status: '已完结',
        wordCount: 5300000,
        lastUpdate: '2024-01-15',
        rating: 9.2,
        readCount: 5000000,
      ),
      Novel(
        id: '2',
        title: '凡人修仙传',
        author: '忘语',
        cover: 'https://via.placeholder.com/300x400/4ECDC4/FFFFFF?text=凡人修仙传',
        summary:
            '一个普通的山村穷小子，偶然之下，跨入到一个江湖小门派，成了一名记名弟子。他以平庸的资质，进入到修仙者的行列，在弱肉强食的修仙界，如何闯出一片天地...',
        category: '仙侠',
        status: '已完结',
        wordCount: 7700000,
        lastUpdate: '2024-01-14',
        rating: 9.0,
        readCount: 3500000,
      ),
      Novel(
        id: '3',
        title: '诡秘之主',
        author: '爱潜水的乌贼',
        cover: 'https://via.placeholder.com/300x400/95E1D3/FFFFFF?text=诡秘之主',
        summary: '蒸汽与机械的浪潮中，谁能触及非凡？历史和黑暗的迷雾里，又是谁在耳语？我从诡秘中醒来，睁眼看见这个世界...',
        category: '奇幻',
        status: '已完结',
        wordCount: 4460000,
        lastUpdate: '2024-01-13',
        rating: 9.5,
        readCount: 2800000,
      ),
      Novel(
        id: '4',
        title: '大奉打更人',
        author: '卖报小郎君',
        cover: 'https://via.placeholder.com/300x400/F38181/FFFFFF?text=大奉打更人',
        summary: '这个世界，有儒；有道；有佛；有妖；有术士。警校毕业的许七安幽幽醒来，发现自己身处牢狱之中，三日后流放边陲...',
        category: '仙侠',
        status: '已完结',
        wordCount: 3800000,
        lastUpdate: '2024-01-12',
        rating: 9.1,
        readCount: 3200000,
      ),
    ];
  }

  /// 模拟章节列表
  List<Chapter> _getMockChapters(String novelId) {
    return List.generate(50, (index) {
      return Chapter(
        id: '${novelId}_$index',
        novelId: novelId,
        title: '第${index + 1}章：章节标题示例',
        index: index,
        isVip: index > 20,
        wordCount: 3000,
        updateTime: '2024-01-${15 - index % 15}',
      );
    });
  }

  /// 模拟章节内容
  Chapter _getMockChapterContent(String itemId) {
    return Chapter(
      id: itemId,
      novelId: '1',
      title: '第一章：测试章节',
      index: 0,
      content: '''
第一章 测试章节

这是一段示例小说内容。在这个虚构的世界里，有着无数的神秘和奇迹等待着人们去探索。

主角站在山巅，望着远处的云海。晨曦的光芒洒在他的脸上，映照出他坚毅的轮廓。"这个世界，终将为我而改变。"他轻声说道，语气中充满了决心。

微风拂过，带来阵阵清香。山下的村庄逐渐苏醒，炊烟袅袅升起。这是一个平凡的早晨，但对主角来说，却是新生活的开始。

"该出发了。"他整理了一下衣衫，开始沿着山路向下走去。

一路上，他遇到了各种各样的挑战。有时是凶猛的野兽，有时是险恶的陷阱，但他凭借着自己的智慧和勇气，一一克服了这些困难。

中午时分，他来到了一个小镇。镇上的居民们正在忙碌着各自的工作，街道上人来人往，热闹非凡。他在一家客栈前停下，准备休息一下再继续前行。

"客官，住店还是吃饭？"小二热情地迎了上来。

"先吃些东西吧。"他回答道，"有什么推荐的？"

"我们这里的招牌菜是红烧狮子头，保证让您满意！"

"那就来一份吧。"

他坐在窗边的位置，望着窗外的风景。这个小镇虽然不大，但却充满了生活的气息。他开始思考自己的下一步计划...

（本章完）
      ''',
    );
  }
}
