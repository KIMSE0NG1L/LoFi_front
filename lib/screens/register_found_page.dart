import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RegisterFoundPage extends StatefulWidget {
  const RegisterFoundPage({super.key});

  @override
  State<RegisterFoundPage> createState() => _RegisterFoundPageState();
}

class _RegisterFoundPageState extends State<RegisterFoundPage> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  String _selectedCategory = '';
  final List<Map<String, String>> _quizzes = [
    {'question': '', 'type': 'multiple', 'answer': ''},
  ];

  final _categories = [
    {'id': 'electronics', 'name': '전자기기', 'icon': '📱'},
    {'id': 'clothing', 'name': '의류', 'icon': '👔'},
    {'id': 'wallet', 'name': '지갑/카드', 'icon': '👛'},
    {'id': 'accessories', 'name': '액세서리', 'icon': '⌚'},
    {'id': 'etc', 'name': '기타', 'icon': '📦'},
  ];

  void _submit() {
    if (_titleCtrl.text.isEmpty || _selectedCategory.isEmpty || _locationCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('필수 항목을 모두 입력해주세요')));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('습득물이 등록되었습니다! (+10pts) 🎉')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.of(context).pop()),
        title: const Text('습득물 등록', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Reward badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: const Color(0xFFF5C842).withOpacity(0.15), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFF5C842).withOpacity(0.3))),
            child: const Row(children: [
              Text('⭐', style: TextStyle(fontSize: 18)),
              SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('등록 시 포인트 획득', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF0D0D0D))),
                Text('+10pts 적립 · 매칭 성공 시 +50pts 추가', style: TextStyle(fontSize: 11, color: Color(0xFF8A8880))),
              ]),
            ]),
          ),
          const SizedBox(height: 20),
          _sectionCard('기본 정보', [
            _label('물품 이름 *'),
            _field(_titleCtrl, '예) 아이폰 15 Pro, 검정 가죽 지갑'),
            const SizedBox(height: 14),
            _label('카테고리 *'),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _categories.map((cat) {
                final active = _selectedCategory == cat['id'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = active ? '' : cat['id']!),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : AppColors.background,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: active ? AppColors.primary : Colors.black.withOpacity(0.08)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(cat['icon']!, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(cat['name']!, style: TextStyle(color: active ? Colors.white : AppColors.textMuted, fontSize: 12)),
                    ]),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            _label('습득 장소 *'),
            _field(_locationCtrl, '예) 강남역 2번 출구 근처'),
            const SizedBox(height: 14),
            _label('상세 설명'),
            _field(_descCtrl, '물건의 특징, 상태 등을 자세히 적어주세요', maxLines: 4),
          ]),
          const SizedBox(height: 16),
          _sectionCard('퀴즈 설정', [
            const Text('소유자가 진짜 주인임을 증명할 퀴즈를 출제해주세요 (최대 3개)', style: TextStyle(color: AppColors.textMuted, fontSize: 12, height: 1.5)),
            const SizedBox(height: 16),
            ..._quizzes.asMap().entries.map((e) {
              final i = e.key;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(14)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('퀴즈 ${i + 1}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.primary)),
                    if (_quizzes.length > 1)
                      GestureDetector(
                        onTap: () => setState(() => _quizzes.removeAt(i)),
                        child: const Icon(Icons.close, size: 16, color: AppColors.textMuted),
                      ),
                  ]),
                  const SizedBox(height: 10),
                  TextField(
                    onChanged: (v) => setState(() => _quizzes[i]['question'] = v),
                    decoration: InputDecoration(hintText: '질문을 입력하세요', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.black.withOpacity(0.06))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.black.withOpacity(0.06))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.black.withOpacity(0.15))), contentPadding: const EdgeInsets.all(12)),
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    onChanged: (v) => setState(() => _quizzes[i]['answer'] = v),
                    decoration: InputDecoration(hintText: '정답을 입력하세요', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.black.withOpacity(0.06))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.black.withOpacity(0.06))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.black.withOpacity(0.15))), contentPadding: const EdgeInsets.all(12)),
                    style: const TextStyle(fontSize: 13),
                  ),
                ]),
              );
            }),
            if (_quizzes.length < 3)
              GestureDetector(
                onTap: () => setState(() => _quizzes.add({'question': '', 'type': 'multiple', 'answer': ''})),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(border: Border.all(color: Colors.black.withOpacity(0.08), style: BorderStyle.solid), borderRadius: BorderRadius.circular(14)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.add_circle_outline, size: 18, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    const Text('퀴즈 추가하기', style: TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w500)),
                  ]),
                ),
              ),
          ]),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.upload_rounded, size: 18),
                SizedBox(width: 8),
                Text('습득물 등록하기', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              ]),
            ),
          ),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }

  Widget _sectionCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.black.withOpacity(0.05)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.primary)),
        const SizedBox(height: 16),
        ...children,
      ]),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(color: AppColors.textDark, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.4)),
  );

  Widget _field(TextEditingController ctrl, String hint, {int maxLines = 1}) => TextField(
    controller: ctrl,
    maxLines: maxLines,
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.background,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.black.withOpacity(0.06))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.black.withOpacity(0.06))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.black.withOpacity(0.15))),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
    style: const TextStyle(fontSize: 14),
  );
}
