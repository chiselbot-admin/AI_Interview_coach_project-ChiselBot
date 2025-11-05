import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../models/cards.dart';
import '../providers/app_providers.dart';
import '../widgets/card_view.dart';
import 'main_view_title.dart';
import 'notice_view.dart';

class MainView extends ConsumerStatefulWidget {
  const MainView({super.key});

  @override
  ConsumerState<MainView> createState() => _MainViewState();
}

class _MainViewState extends ConsumerState<MainView> {
  bool _isLoading = true;
  final double _cardRatio = .17;

  int _selectedIndex = -1; // 카드 선택 인덱스

  // 백엔드 DB categoryId와 맞게 실제 매핑 수정
  // Map<String, int> _nameToId = const {
  //   'java': 1,
  //   'python': 2,
  //   'c': 3,
  //   'html/css': 4,
  //   'javascript': 5,
  //   'mysql': 6,
  // };
  // 서버에서 받아 채울 카테고리 이름→ID 매핑
  Map<String, int> _nameToId = {};

  // 카드 제목별 별칭 보정 (UI → 백 카테고리명)
  final Map<String, String> _aliases = const {
    'html/css': 'css',
    'mysql': 'oracle',
  };

  // 문자열 정규화 함수(공백제거+소문자)
  String _norm(String s) => s.trim().toLowerCase();

  @override
  void initState() {
    super.initState();
    // 화면이 완전히 빌드된 후 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    print('[MainView] _loadData start');
    try {
      final api = AppProviders.of(context).api;
      final cats = await api.fetchCategories();
      print(
          '[MainView] categories fetched: ${cats.map((e) => '${e.categoryId}:${e.name}').toList()}');

      final map = <String, int>{};
      for (final c in cats) {
        map[_norm(c.name)] = c.categoryId;
      }

      if (mounted) setState(() => _nameToId = map);
    } catch (e) {
      print('[MainView] fetchCategories error: $e');
      if (mounted) {
        // ScaffoldMessenger 직접 호출 X
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('카테고리 목록을 불러오지 못했어요.')),
          );
        });
      }
    } finally {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---- 카드 제목을 받아 카테고리 id로 변환 ----
  int? _resolveCategoryIdByTitle(String title) {
    final key = _norm(title);
    final canonical = _aliases[key] ?? key;
    return _nameToId[canonical];
  }

  // ---- 인덱스 기반이 아니라 제목으로 매핑 ----
  Future<void> _startByTitle(String title) async {
    final categoryId = _resolveCategoryIdByTitle(title);
    if (categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('카테고리 매핑 실패: $title')),
      );
      return;
    }

    final qna = AppProviders.of(context).qna;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    await qna.loadQuestion(categoryId: categoryId, level: 'LEVEL_1');

    if (mounted) Navigator.pop(context);

    if (qna.error != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('질문 불러오기 실패: ${qna.error}')));
      return;
    }

    if (qna.currentQuestion != null && mounted) {
      Navigator.pushNamed(context, '/chat');
      setState(() => _selectedIndex = -1);
    }
  }

  void _onCardTap(int newIndex, List<CardData> cards) {
    setState(() {
      _selectedIndex = _selectedIndex == newIndex ? -1 : newIndex;
    });
    if (_selectedIndex == -1) return;
    final title = cards[_selectedIndex].title;
    _startByTitle(title);
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);

    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MainViewTitle(context, mediaQuery),
        Divider(color: Colors.grey.shade800),
        NoticeView(),
        if (_isLoading)
          SizedBox(
            height: mediaQuery.size.height * _cardRatio * 3,
            child: const Center(
              child: SpinKitCircle(
                color: Colors.grey,
                duration: Duration(milliseconds: 300),
              ),
            ),
          )
        else ...[
          _buildCategorySection(
            context,
            mediaQuery,
            "백엔드",
            CardDataFactory.createBackendCards(),
          ),
          _buildCategorySection(
            context,
            mediaQuery,
            "프론트엔드",
            CardDataFactory.createFrontendCards(),
          ),
          _buildCategorySection(
            context,
            mediaQuery,
            "데이터베이스",
            CardDataFactory.createDatabaseCards(),
          ),
        ],
      ],
    );
  }

  Widget _buildCategorySection(BuildContext context, MediaQueryData mediaQuery,
      String categoryTitle, List<CardData> cards) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: Colors.grey.shade800, height: 32),
        Padding(
          padding: EdgeInsets.only(left: mediaQuery.size.width * .1),
          child: Text(categoryTitle,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70)),
        ),
        SizedBox(
          height: mediaQuery.size.height * _cardRatio,
          child: CardView(
            items: cards,
            onCardTap: (i) => _onCardTap(i, cards),
          ),
        ),
      ],
    );
  }
}
