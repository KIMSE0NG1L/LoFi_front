import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/items_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class RegisterFoundPage extends StatefulWidget {
  const RegisterFoundPage({super.key});

  @override
  State<RegisterFoundPage> createState() => _RegisterFoundPageState();
}

class _RegisterFoundPageState extends State<RegisterFoundPage> {
  final ItemsService _itemsService = ItemsService();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final List<Map<String, String>> _quizzes = [
    {'question': '', 'answer': ''},
  ];

  String _selectedCategory = '';
  bool _submitting = false;
  File? _imageFile;
  final _imagePicker = ImagePicker();

  final _categories = [
    {'id': 'electronics', 'name': '전자기기', 'icon': Icons.devices_other},
    {'id': 'clothing', 'name': '의류', 'icon': Icons.checkroom_outlined},
    {'id': 'wallet', 'name': '지갑/카드', 'icon': Icons.wallet_outlined},
    {'id': 'accessories', 'name': '액세서리', 'icon': Icons.watch_outlined},
    {'id': 'etc', 'name': '기타', 'icon': Icons.inventory_2_outlined},
  ];

  Future<void> _pickImage() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

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
      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = await uploadItemImage(_imageFile!);
      }

      await _itemsService.createFoundItem(
        category: _selectedCategory,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        quizzes: quizzes,
        imageUrl: imageUrl,
      );
      if (!mounted) return;
      await context.read<AuthProvider>().refreshProfile();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('습득물이 등록되었습니다. (+50pts)')));
      if (context.canPop()) { context.pop(); } else { context.go('/'); }
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
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: const Text(
          '습득물 등록',
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold),
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
            _imagePickerSection(),
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

  Widget _imagePickerSection() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _imageFile != null
                ? AppColors.primary.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            width: _imageFile != null ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: _imageFile != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(_imageFile!, fit: BoxFit.cover),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => setState(() => _imageFile = null),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      child: const Text(
                        '사진 변경',
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined,
                      size: 40, color: AppColors.textFaint),
                  const SizedBox(height: 10),
                  Text(
                    '사진 추가 (선택)',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '갤러리에서 물건 사진을 선택해 주세요',
                    style: TextStyle(color: AppColors.textFaint, fontSize: 11),
                  ),
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
