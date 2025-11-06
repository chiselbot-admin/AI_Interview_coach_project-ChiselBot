import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/qna_provider.dart';

class QnaFormScreen extends ConsumerStatefulWidget {
  const QnaFormScreen({super.key});
  @override
  ConsumerState<QnaFormScreen> createState() => _QnaFormScreenState();
}

class _QnaFormScreenState extends ConsumerState<QnaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _titleFocus = FocusNode();
  final _contentFocus = FocusNode();

  static const int _minContent = 10;
  static const int _maxContent = 1000;

  bool _submitting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _titleFocus.dispose();
    _contentFocus.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    final t = _titleCtrl.text.trim();
    final c = _contentCtrl.text.trim();
    return t.isNotEmpty && c.length >= _minContent && c.length <= _maxContent;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    await ref.read(createInquiryProvider.notifier).submit(
          title: _titleCtrl.text.trim(),
          content: _contentCtrl.text.trim(),
        );
    final state = ref.read(createInquiryProvider);
    setState(() => _submitting = false);

    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('등록 실패: ${state.error}')),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('문의가 등록되었습니다.')));
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 로그인 여부 판단
    final api = ref.watch(apiServiceProvider);
    final authed = api.getHeaders().containsKey('Authorization');

    // 비로그인 화면(UI 개선)
    if (!authed) {
      return Scaffold(
        appBar: AppBar(title: const Text('문의 작성')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceVariant,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_outline,
                        size: 40, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 12),
                    const Text('로그인이 필요합니다',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    const Text(
                      '문의 작성은 로그인 사용자만 이용할 수 있어요.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.login),
                        label: const Text('로그인 하러 가기'),
                        onPressed: () => Navigator.pushNamed(context, '/login'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    // 로그인 상태
    final async = ref.watch(createInquiryProvider);
    final isLoading = async.isLoading || _submitting;

    final contentLen = _contentCtrl.text.characters.length;
    final contentErr = contentLen < _minContent || contentLen > _maxContent;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: const Text('문의 작성'),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(44),
                child: _InfoBanner(),
              ),
            ),
            body: SafeArea(
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _titleCtrl,
                            focusNode: _titleFocus,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => FocusScope.of(context)
                                .requestFocus(_contentFocus),
                            decoration: const InputDecoration(
                              labelText: '제목',
                              hintText: '문의 제목을 입력하세요',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? '제목을 입력하세요'
                                : null,
                          ),
                          const SizedBox(height: 14),
                          _SectionLabel(
                            label: '문의 내용',
                            trailing: Text(
                              '$contentLen / $_maxContent',
                              style: TextStyle(
                                fontSize: 12,
                                color: contentErr
                                    ? Theme.of(context).colorScheme.error
                                    : Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          _ContentField(
                            controller: _contentCtrl,
                            focus: _contentFocus,
                            onChanged: (_) => setState(() {}),
                            minLines: 10,
                            maxLength: _maxContent,
                            validator: (v) {
                              final text = v?.trim() ?? '';
                              if (text.isEmpty) return '내용을 입력하세요';
                              if (text.length < _minContent) {
                                return '$_minContent자 이상 입력해주세요';
                              }
                              if (text.length > _maxContent) {
                                return '$_maxContent자 이하로 작성해주세요';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            bottomNavigationBar: SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: (!isLoading && _isFormValid) ? _submit : null,
                  icon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.send_rounded),
                  label: Text(isLoading ? '전송 중...' : '등록'),
                ),
              ),
            ),
          ),

          // 로딩 오버레이 (중복입력 방지)
          if (isLoading)
            IgnorePointer(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                color: Colors.black.withOpacity(0.15),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      alignment: Alignment.centerLeft,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        border: Border(
          top: BorderSide(color: cs.outlineVariant),
          bottom: BorderSide(color: cs.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 18, color: cs.primary),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '개인정보(주민번호, 계좌번호 등)는 입력하지 마세요. 보통 24시간 이내에 답변됩니다.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final Widget? trailing;
  const _SectionLabel({required this.label, this.trailing});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context)
        .textTheme
        .titleSmall
        ?.copyWith(fontWeight: FontWeight.w600);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _ContentField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focus;
  final ValueChanged<String>? onChanged;
  final int minLines;
  final int maxLength;
  final String? Function(String?)? validator;

  const _ContentField({
    super.key,
    required this.controller,
    required this.focus,
    this.onChanged,
    this.minLines = 10,
    this.maxLength = 1000,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focus,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      minLines: minLines,
      maxLines: null,
      maxLength: maxLength,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: '불편 사항, 문의 내용을 구체적으로 작성해주세요.\n(예: 발생 화면/버전, 카테고리 등)',
        alignLabelWithHint: true,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }
}
