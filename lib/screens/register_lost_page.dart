import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RegisterLostPage extends StatefulWidget {
  const RegisterLostPage({super.key});

  @override
  State<RegisterLostPage> createState() => _RegisterLostPageState();
}

class _RegisterLostPageState extends State<RegisterLostPage> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _rewardCtrl = TextEditingController();
  String _selectedCategory = '';

  final _categories = [
    {'id': 'electronics', 'name': '전자기기', 'icon': '📱'},
    {'id': 'clothing', 'name': '의류', 'icon': '👔'},
    {'id': 'wallet', 'name': '지갑/카드', 'icon': '👛'},
    {'id': 'accessories', 'name': '액세서리', 'icon': '⌚'},
    {'id': 'etc', 'name': '기타', 'icon': '📦'},
  ];

  void _submit() {
    if (_titleCtrl.text.isEmpty || _selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('필수 항목을 모두 입력해주세요')));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('분실물 신고가 완료되었습니다! 알림을 보내드릴게요 📢')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.of(context).pop()),
        title: const Text('분실물 신고', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Notice
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.blue.shade100)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.info_outline, color: Colors.blue.shade600, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text('분실물이 등록되면 매칭 시 알림을 받을 수 있습니다. 최대한 상세하게 입력해주세요.', style: TextStyle(color: Colors.blue.shade800, fontSize: 12, height: 1.5))),
            ]),
          ),
          const SizedBox(height: 20),
          _sectionCard('분실물 정보', [
            _label('물품 이름 *'),
            _field(_titleCtrl, '예) 갤럭시 버즈 2 프로'),
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
            _label('분실 장소 (예상)'),
            _field(_locationCtrl, '예) 지하철 2호선, 강남 일대'),
            const SizedBox(height: 14),
            _label('상세 설명'),
            _field(_descCtrl, '물건의 특징, 외관, 내부 내용물 등을 상세히 적어주세요', maxLines: 4),
            const SizedBox(height: 14),
            _label('사례 (선택)'),
            _field(_rewardCtrl, '예) 감사 선물 드립니다, 사례금 지급 가능'),
          ]),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.warning_amber_rounded, size: 18),
                SizedBox(width: 8),
                Text('분실물 신고하기', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
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
