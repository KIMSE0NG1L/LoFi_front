import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/items_service.dart';
import '../services/kakao_location_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'location_search_page.dart';

class RegisterLostPage extends StatefulWidget {
  const RegisterLostPage({super.key});

  @override
  State<RegisterLostPage> createState() => _RegisterLostPageState();
}

class _RegisterLostPageState extends State<RegisterLostPage> {
  final ItemsService _itemsService = ItemsService();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _detailLocationCtrl = TextEditingController();
  final _rewardCtrl = TextEditingController();
  String _selectedCategory = '';
  KakaoPlace? _selectedPlace;
  int _bountyPoints = 0;
  bool _submitting = false;
  File? _imageFile;
  final _imagePicker = ImagePicker();

  final _categories = [
    {'id': 'electronics', 'name': '전자기기', 'icon': '📱'},
    {'id': 'clothing', 'name': '의류', 'icon': '👔'},
    {'id': 'wallet', 'name': '지갑/카드', 'icon': '👛'},
    {'id': 'bag', 'name': '가방', 'icon': '🎒'},
    {'id': 'accessories', 'name': '액세서리', 'icon': '⌚'},
    {'id': 'glasses', 'name': '안경/선글라스', 'icon': '👓'},
    {'id': 'umbrella', 'name': '우산', 'icon': '☂️'},
    {'id': 'books', 'name': '도서/문구', 'icon': '📚'},
    {'id': 'keys', 'name': '열쇠', 'icon': '🔑'},
    {'id': 'documents', 'name': '서류/카드', 'icon': '🪪'},
    {'id': 'etc', 'name': '기타', 'icon': '📦'},
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

  Future<void> _pickLocation() async {
    final place = await Navigator.of(context).push<KakaoPlace>(
      MaterialPageRoute(builder: (_) => const LocationSearchPage()),
    );
    if (place != null) setState(() => _selectedPlace = place);
  }

  void _adjustBounty(int delta, int myPoints) {
    setState(() {
      _bountyPoints = (_bountyPoints + delta).clamp(0, myPoints);
    });
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty ||
        _selectedCategory.isEmpty ||
        _selectedPlace == null ||
        _descCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('필수 항목을 모두 입력해주세요')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = await uploadItemImage(_imageFile!);
      }

      final place = _selectedPlace!;
      final detail = _detailLocationCtrl.text.trim();
      final location = detail.isEmpty ? place.address : '${place.address} ($detail)';

      await _itemsService.createLostItem(
        category: _selectedCategory,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        location: location,
        imageUrl: imageUrl,
        reward: _rewardCtrl.text.trim().isEmpty ? null : _rewardCtrl.text.trim(),
        bountyPoints: _bountyPoints,
      );
      if (!mounted) return;
      await context.read<AuthProvider>().refreshProfile();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _bountyPoints > 0
                ? '분실물 신고가 완료되었습니다! 현상금 ${_bountyPoints}pt가 걸렸어요 📢'
                : '분실물 신고가 완료되었습니다! 알림을 보내드릴게요 📢',
          ),
        ),
      );
      if (context.canPop()) { context.pop(); } else { context.go('/'); }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _detailLocationCtrl.dispose();
    _rewardCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myPoints = context.watch<AuthProvider>().user?.points ?? 0;
    if (_bountyPoints > myPoints) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _bountyPoints = myPoints);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textDark), onPressed: () => context.canPop() ? context.pop() : context.go('/')),
        title: const Text('분실물 신고', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _imagePickerSection(),
          const SizedBox(height: 16),
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
                      color: active ? AppColors.interactive : AppColors.background,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: active ? AppColors.interactive : Colors.black.withOpacity(0.08)),
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
            _label('분실 장소 (예상) *'),
            _locationPicker(),
            if (_selectedPlace != null) ...[
              const SizedBox(height: 10),
              _label('상세 위치 (선택)'),
              _field(_detailLocationCtrl, '예) 2호선 강남역 2번 출구 근처'),
            ],
            const SizedBox(height: 14),
            _label('상세 설명 *'),
            _field(_descCtrl, '물건의 특징, 외관, 내부 내용물 등을 상세히 적어주세요', maxLines: 4),
            const SizedBox(height: 14),
            _label('사례 메모 (선택)'),
            _field(_rewardCtrl, '예) 감사 선물 드립니다, 사례금 지급 가능'),
          ]),
          const SizedBox(height: 16),
          _sectionCard('현상금 걸기 (선택)', [
            Text(
              '포인트로 현상금을 걸면 등록 즉시 보유 포인트에서 차감되어 보관되고, 도움을 준 사람에게 전달돼요. '
              '매칭이 안 되어 신고를 취소하면 그대로 환불됩니다.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12, height: 1.5),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _bountyStepButton(Icons.remove, () => _adjustBounty(-10, myPoints)),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '$_bountyPoints pt',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: AppColors.primary),
                      ),
                      Text(
                        '보유 $myPoints pt',
                        style: const TextStyle(color: AppColors.textFaint, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                _bountyStepButton(Icons.add, () => _adjustBounty(10, myPoints)),
              ],
            ),
          ]),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.interactive, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
              child: _submitting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
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

  Widget _locationPicker() {
    return GestureDetector(
      onTap: _pickLocation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.place_outlined,
              size: 18,
              color: _selectedPlace != null ? AppColors.primary : AppColors.textFaint,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _selectedPlace?.address ?? '주소/장소 검색하기',
                style: TextStyle(
                  fontSize: 14,
                  color: _selectedPlace != null ? AppColors.textDark : AppColors.textFaint,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.search, size: 18, color: AppColors.textFaint),
          ],
        ),
      ),
    );
  }

  Widget _bountyStepButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withOpacity(0.08)),
        ),
        child: Icon(icon, size: 18, color: AppColors.primary),
      ),
    );
  }

  Widget _imagePickerSection() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _imageFile != null ? AppColors.primary.withOpacity(0.3) : Colors.black.withOpacity(0.08),
            width: _imageFile != null ? 2 : 1,
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
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
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.55), shape: BoxShape.circle),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined, size: 36, color: AppColors.textFaint),
                  const SizedBox(height: 8),
                  Text('사진 추가 (선택)', style: TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
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
