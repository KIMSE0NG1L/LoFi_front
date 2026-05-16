import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/api_client.dart';
import '../services/items_service.dart';
import '../theme/app_theme.dart';

class RegisterFoundPage extends StatefulWidget {
  const RegisterFoundPage({super.key});

  @override
  State<RegisterFoundPage> createState() => _RegisterFoundPageState();
}

class _RegisterFoundPageState extends State<RegisterFoundPage> {
  final ItemsService _itemsService = ItemsService(ApiClient.instance);
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final List<Map<String, String>> _quizzes = [
    {'question': '', 'answer': ''},
  ];

  String _selectedCategory = '';
  bool _submitting = false;

  final _categories = [
    {'id': 'electronics', 'name': '전자기기', 'icon': Icons.devices_other},
    {'id': 'clothing', 'name': '의류', 'icon': Icons.checkroom_outlined},
    {'id': 'wallet', 'name': '지갑/카드', 'icon': Icons.wallet_outlined},
    {'id': 'accessories', 'name': '액세서리', 'icon': Icons.watch_outlined},
    {'id': 'etc', 'name': '기타', 'icon': Icons.inventory_2_outlined},
  ];

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty ||
        _selectedCategory.isEmpty ||
        _locationCtrl.text.trim().isEmpty ||
        _descCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('필수 항목을 모두 입력해주세요.')));
      return;
    }

    final quizzes = _quizzes
        .where(
          (quiz) =>
              quiz['question']!.trim().isNotEmpty &&
              quiz['answer']!.trim().isNotEmpty,
        )
        .map(
          (quiz) => {
            'question': quiz['question']!.trim(),
            'type': 'text',
            'correctAnswer': quiz['answer']!.trim(),
          },
        )
        .toList();

    if (quizzes.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('퀴즈를 1개 이상 입력해주세요.')));
      return;
    }

    setState(() => _submitting = true);
    try {
      await _itemsService.createFoundItem(
        category: _selectedCategory,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        quizzes: quizzes,
      );
      if (!mounted) return;
      await context.read<AuthProvider>().refreshProfile();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('습득물이 등록되었습니다. (+50pts)')));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '습득물 등록',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionCard('기본 정보', [
              _label('물품 이름 *'),
              _field(_titleCtrl, '예: 아이폰 15 Pro'),
              const SizedBox(height: 14),
              _label('카테고리 *'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((category) {
                  final id = category['id'] as String;
                  final active = _selectedCategory == id;
                  return ChoiceChip(
                    selected: active,
                    onSelected: (_) =>
                        setState(() => _selectedCategory = active ? '' : id),
                    avatar: Icon(
                      category['icon'] as IconData,
                      size: 16,
                      color: active ? Colors.white : AppColors.textMuted,
                    ),
                    label: Text(category['name'] as String),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: active ? Colors.white : AppColors.textMuted,
                      fontSize: 12,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              _label('습득 장소 *'),
              _field(_locationCtrl, '예: 강남역 2번 출구 근처'),
              const SizedBox(height: 14),
              _label('상세 설명 *'),
              _field(_descCtrl, '물건의 특징, 상태 등을 자세히 적어주세요.', maxLines: 4),
            ]),
            const SizedBox(height: 16),
            _sectionCard('퀴즈 설정', [
              const Text(
                '주인이 맞는지 확인할 수 있는 질문과 정답을 입력해주세요.',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              ..._quizzes.asMap().entries.map((entry) {
                final index = entry.key;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '퀴즈 ${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: AppColors.primary,
                            ),
                          ),
                          if (_quizzes.length > 1)
                            IconButton(
                              onPressed: () =>
                                  setState(() => _quizzes.removeAt(index)),
                              icon: const Icon(Icons.close, size: 16),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        onChanged: (value) =>
                            setState(() => _quizzes[index]['question'] = value),
                        decoration: _inputDecoration('질문을 입력하세요.'),
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        onChanged: (value) =>
                            setState(() => _quizzes[index]['answer'] = value),
                        decoration: _inputDecoration('정답을 입력하세요.'),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                );
              }),
              if (_quizzes.length < 3)
                OutlinedButton.icon(
                  onPressed: () => setState(
                    () => _quizzes.add({'question': '', 'answer': ''}),
                  ),
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text('퀴즈 추가하기'),
                ),
            ]),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.upload_rounded, size: 18),
                label: Text(_submitting ? '등록 중...' : '습득물 등록하기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        color: AppColors.textDark,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
    ),
  );

  Widget _field(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: _inputDecoration(hint),
      style: const TextStyle(fontSize: 14),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.15)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }
}
