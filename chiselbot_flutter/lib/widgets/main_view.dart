import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../models/cards.dart';
import '../providers/app_providers.dart';
import '../widgets/card_view.dart';
import '../widgets/error_panel.dart';
import 'level_picker_dialog.dart';
import 'level_select_sheet.dart';
import 'main_view_title.dart';
import 'notice_view.dart';
import '../widgets/error_sheet.dart';

class MainView extends ConsumerStatefulWidget {
  const MainView({super.key});

  @override
  ConsumerState<MainView> createState() => _MainViewState();
}

class _MainViewState extends ConsumerState<MainView> {
  bool _isLoading = true;
  final double _cardRatio = .17;

  int _selectedIndex = -1; // 카드 선택 인덱스
  String? _error; // 에러 메세지 보관

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
    setState(() {
      _isLoading = true;
      _error = null; // 기존 에러 리셋
    });

    try {
      final api = AppProviders.of(context).api;
      final cats = await api.fetchCategories();
      final map = <String, int>{};
      for (final c in cats) {
        map[_norm(c.name)] = c.categoryId;
      }
      if (mounted) setState(() => _nameToId = map);
    } catch (e) {
      if (mounted) setState(() => _error = '카테고리 목록을 불러오지 못했어요.\n$e');
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
      // SnackBar -> 매핑 실패 다이얼로그
      _showMappingFailSheet(title);
      return;
    }

    // 1) 레벨 모달 먼저
    final level = await pickInterviewLevel(context);
    if (level == null) return; // 사용자가 닫음

    final qna = AppProviders.of(context).qna;

    // 2) 로딩 다이얼로그 (선택 사항)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // 3) 질문 로드
    await qna.loadQuestion(categoryId: categoryId, level: level);

    if (mounted) Navigator.pop(context); // 로딩 닫기

    if (qna.error != null) {
      if (!mounted) return;
      _showQnaErrorSheet(title: title, error: qna.error!);
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
        else if (_error != null) //에러 상태 UI 분기
          SizedBox(
            height: mediaQuery.size.height * _cardRatio * 3,
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: mediaQuery.size.width * .1),
                child: ErrorPanel(
                  message: _error!,
                  onRetry: _loadData,
                  onDetails: () => _showErrorDetails(_error!),
                ),
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

  // ---------- [MODIFIED] 공통: 화면 중앙 다이얼로그 헬퍼 ----------
  void _showCenteredDialog(Widget child) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true, // 바깥/백버튼으로 닫힘 (기본 의도)
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54, // 반투명 배리어
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) {
        // [MODIFIED] 바깥 탭 닫힘을 확실히 하기 위해 전체 화면 GestureDetector 추가
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).pop(), // 바깥을 탭하면 닫기
          child: Center(
            // [MODIFIED] 다이얼로그 영역은 탭이 닫힘으로 전달되지 않도록 막아줌
            child: GestureDetector(
              onTap: () {}, // 다이얼로그 안쪽 탭 이벤트 소비(전파 방지)
              child: Material(
                color: Colors.transparent,
                child: Dialog(
                  backgroundColor: Colors.grey.shade900,
                  insetPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: child, // 원하는 위젯을 내용으로 주입
                  ),
                ),
              ),
            ),
          ),
        );
      },
      // 부드러운 scale + fade
      transitionBuilder: (_, anim, __, dialogChild) => Opacity(
        opacity: anim.value,
        child: Transform.scale(
          scale: 0.96 + 0.04 * anim.value,
          child: dialogChild,
        ),
      ),
    );
  }

// ---------- 에러 상세 다이얼로그 (개발자용) ----------
  void _showErrorDetails(String message) {
    // [MODIFIED] BottomSheet -> Center Dialog
    _showCenteredDialog(
      Padding(
        padding: const EdgeInsets.all(16),
        child: SelectableText(
          message,
          style: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }

// ---------- 카테고리 매핑 실패: 가운데 다이얼로그 ----------
  void _showMappingFailSheet(String title) {
    // [MODIFIED] BottomSheet -> Center Dialog
    _showCenteredDialog(
      ErrorSheet(
        title: '카테고리 매핑에 실패했어요',
        mascotAsset: 'assets/images/chiselBot.png',
        onPrimary: () {
          Navigator.pop(context);
          _loadData(); // 새로고침
        },
        primaryLabel: '카테고리 새로고침',
        onSecondary: () {
          Navigator.pop(context);
          _showAvailableCategories();
        },
      ),
    );
  }

// ---------- 카테고리 후보 리스트: 가운데 다이얼로그 ----------
  void _showAvailableCategories() {
    final items = _nameToId.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    // [MODIFIED] BottomSheet -> Center Dialog
    _showCenteredDialog(
      SizedBox(
        height: 420, // 스크롤 높이 제한
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemBuilder: (_, i) => ListTile(
            title:
                Text(items[i].key, style: const TextStyle(color: Colors.white)),
            subtitle: Text('ID: ${items[i].value}',
                style: const TextStyle(color: Colors.white70)),
            onTap: () => Navigator.pop(context),
          ),
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemCount: items.length,
        ),
      ),
    );
  }

// ---------- QnA 실패: 가운데 다이얼로그 ----------
  void _showQnaErrorSheet({required String title, required String error}) {
    // [MODIFIED] BottomSheet -> Center Dialog
    _showCenteredDialog(
      ErrorSheet(
        title: '질문을 불러오지 못했어요',
        // caption: null,
        mascotAsset: 'assets/images/chiselBot.png',
        // tip: '네트워크/로그인 상태를 확인한 뒤 다시 시도해 보세요.',
        onPrimary: () {
          Navigator.pop(context);
          _startByTitle(title); // 다시 시도
        },
        primaryLabel: '다시 시도',
        onSecondary: () {
          Navigator.pop(context);
          _loadData(); // 카테고리 새로고침
        },
        secondaryLabel: '카테고리 새로고침',
      ),
    );
  }
}
