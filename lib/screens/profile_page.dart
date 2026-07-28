import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../services/activity_service.dart';
import '../services/items_service.dart';
import '../services/storage_service.dart';
import '../widgets/surfaces.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ItemsService _itemsService = ItemsService();
  final ActivityService _activityService = ActivityService();

  String _activeTab = 'items';
  bool _notifEnabled = true;
  String? _modal;
  List<LostItem> _myFoundItems = [];
  List<ActivityItem> _myActivities = [];
  bool _itemsLoading = true;
  String? _itemsError;
  bool _activityLoading = true;
  String? _activityError;

  final _myItems = [
    {
      'id': 1,
      'title': '갤럭시 워치 6',
      'date': '2026.04.28',
      'status': '매칭 완료',
      'emoji': '⌚',
      'matched': true,
    },
    {
      'id': 2,
      'title': '검정 우산',
      'date': '2026.05.01',
      'status': '대기 중',
      'emoji': '☂️',
      'matched': false,
    },
    {
      'id': 3,
      'title': '에어팟 프로',
      'date': '2026.04.15',
      'status': '찾는 중',
      'emoji': '🎧',
      'matched': false,
    },
  ];

  final _myActivity = [
    {'text': '갤럭시 워치 6 매칭 완료!', 'time': '3일 전', 'pts': '+50', 'emoji': '🎉'},
    {'text': '검정 우산 등록', 'time': '5일 전', 'pts': '+10', 'emoji': '📦'},
    {'text': '일일 접속 보너스', 'time': '오늘', 'pts': '+5', 'emoji': '⭐'},
  ];

  static const _termsContent = '''제1조 (목적)
이 약관은 옛다 띱! 서비스의 이용에 관한 조건 및 절차, 권리와 의무를 규정합니다.

제2조 (서비스 이용)
서비스는 분실물 매칭 플랫폼으로, 습득물 등록 및 퀴즈 기반 인증을 제공합니다.

제3조 (퀴즈 시스템)
습득자는 분실물 특징으로 퀴즈를 출제하며, 분실자가 정답을 맞추면 매칭이 완료됩니다.

제4조 (포인트 시스템)
습득물 등록 시 10pts, 매칭 성공 시 50pts, 일일 접속 시 5pts가 지급됩니다.

제5조 (금지 행위)
허위 정보 등록, 타인 분실물 부정 청구, 시스템 악용을 금지합니다.''';

  static const _privacyContent = '''수집하는 개인정보
- 이름, 이메일 주소, 전화번호 (회원가입 시)
- 분실물 및 습득물 정보
- 서비스 이용 기록

개인정보 이용 목적
- 분실물 매칭 서비스 제공
- 포인트/랭킹 시스템 운영
- 서비스 개선
- 매칭 성공 시 분실자-습득자 간 연락

보유 및 이용 기간
회원 탈퇴 시까지 보유하며, 법령에서 정한 경우 해당 기간 동안 보관합니다.

제3자 제공
매칭 성공 시 분실자와 습득자 간 연락처 정보(전화번호 포함)를 상호 제공합니다.''';

  @override
  void initState() {
    super.initState();
    _loadMyFoundItems();
    _loadMyActivities();
  }

  Future<void> _loadMyFoundItems() async {
    setState(() {
      _itemsLoading = true;
      _itemsError = null;
    });

    try {
      final items = await _itemsService.fetchMine();
      if (!mounted) return;
      setState(() => _myFoundItems = items);
    } catch (e) {
      if (!mounted) return;
      setState(() => _itemsError = e.toString());
    } finally {
      if (mounted) setState(() => _itemsLoading = false);
    }
  }

  Future<void> _loadMyActivities() async {
    setState(() {
      _activityLoading = true;
      _activityError = null;
    });

    try {
      final activities = await _activityService.fetchMine();
      if (!mounted) return;
      setState(() => _myActivities = activities);
    } catch (e) {
      if (!mounted) return;
      setState(() => _activityError = e.toString());
    } finally {
      if (mounted) setState(() => _activityLoading = false);
    }
  }

  Future<void> _openEditFoundItem(LostItem item) async {
    final titleCtrl = TextEditingController(text: item.title);
    final descCtrl = TextEditingController(text: item.description);
    final locationCtrl = TextEditingController(text: item.location);
    final quizRows = item.quizzes.isEmpty
        ? [
            {
              'question': TextEditingController(),
              'answer': TextEditingController(),
            },
          ]
        : item.quizzes
              .map(
                (quiz) => {
                  'question': TextEditingController(text: quiz.question),
                  'answer': TextEditingController(
                    text: '${quiz.correctAnswer ?? ''}',
                  ),
                },
              )
              .toList();
    String selectedCategory = item.category;
    bool saving = false;
    File? editImageFile;
    String? currentImageUrl = item.imageUrl;
    final imagePicker = ImagePicker();

    final updated = await showModalBottomSheet<LostItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> save() async {
              if (titleCtrl.text.trim().isEmpty ||
                  selectedCategory.isEmpty ||
                  locationCtrl.text.trim().isEmpty ||
                  descCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('필수 항목을 모두 입력해주세요.')),
                );
                return;
              }

              final quizzes = quizRows
                  .where(
                    (row) =>
                        row['question']!.text.trim().isNotEmpty &&
                        row['answer']!.text.trim().isNotEmpty,
                  )
                  .map(
                    (row) => {
                      'question': row['question']!.text.trim(),
                      'type': 'text',
                      'correctAnswer': row['answer']!.text.trim(),
                    },
                  )
                  .toList();

              if (quizzes.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('?댁쫰瑜?1媛??댁긽 ?낅젰?댁＜?몄슂.')),
                );
                return;
              }

              setSheetState(() => saving = true);
              try {
                String? imageUrl = currentImageUrl;
                if (editImageFile != null) {
                  imageUrl = await uploadItemImage(editImageFile!);
                }
                final result = await _itemsService.updateFoundItem(
                  id: item.id,
                  category: selectedCategory,
                  title: titleCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  location: locationCtrl.text.trim(),
                  quizzes: quizzes,
                  mapX: item.mapPos.x,
                  mapY: item.mapPos.y,
                  imageUrl: imageUrl,
                );
                if (sheetContext.mounted) Navigator.of(sheetContext).pop(result);
              } catch (e) {
                setSheetState(() => saving = false);
                if (!context.mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            }

            return GlassContainer(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            '습득물 편집',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: saving
                              ? null
                              : () => Navigator.of(sheetContext).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: saving
                          ? null
                          : () async {
                              final picked = await imagePicker.pickImage(
                                source: ImageSource.gallery,
                                maxWidth: 1200,
                                maxHeight: 1200,
                                imageQuality: 85,
                              );
                              if (picked != null) {
                                setSheetState(() => editImageFile = File(picked.path));
                              }
                            },
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: (editImageFile != null || currentImageUrl != null)
                                ? AppColors.primary.withOpacity(0.3)
                                : Colors.black.withOpacity(0.08),
                            width: (editImageFile != null || currentImageUrl != null) ? 2 : 1,
                          ),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: editImageFile != null
                            ? Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.file(editImageFile!, fit: BoxFit.cover),
                                  Positioned(
                                    top: 6,
                                    right: 6,
                                    child: GestureDetector(
                                      onTap: () => setSheetState(() {
                                        editImageFile = null;
                                        currentImageUrl = null;
                                      }),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.55),
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(5),
                                        child: const Icon(Icons.close, color: Colors.white, size: 14),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 6,
                                    right: 6,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.85),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      child: const Text('사진 변경', style: TextStyle(color: Colors.white, fontSize: 10)),
                                    ),
                                  ),
                                ],
                              )
                            : currentImageUrl != null
                                ? Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.network(currentImageUrl!, fit: BoxFit.cover),
                                      Positioned(
                                        top: 6,
                                        right: 6,
                                        child: GestureDetector(
                                          onTap: () => setSheetState(() => currentImageUrl = null),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.55),
                                              shape: BoxShape.circle,
                                            ),
                                            padding: const EdgeInsets.all(5),
                                            child: const Icon(Icons.close, color: Colors.white, size: 14),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 6,
                                        right: 6,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withOpacity(0.85),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          child: const Text('사진 변경', style: TextStyle(color: Colors.white, fontSize: 10)),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_photo_alternate_outlined, size: 32, color: AppColors.textFaint),
                                      const SizedBox(height: 8),
                                      Text('사진 추가 (선택)', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                                    ],
                                  ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _editLabel('물품 이름 *'),
                    _editField(titleCtrl, '물품 이름'),
                    const SizedBox(height: 12),
                    _editLabel('카테고리 *'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _foundCategories.map((category) {
                        final id = category['id'] as String;
                        final active = selectedCategory == id;
                        return ChoiceChip(
                          selected: active,
                          onSelected: saving
                              ? null
                              : (_) => setSheetState(
                                    () => selectedCategory = active ? '' : id,
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
                    const SizedBox(height: 12),
                    _editLabel('습득 장소 *'),
                    _editField(locationCtrl, '습득 장소'),
                    const SizedBox(height: 12),
                    _editLabel('상세 설명 *'),
                    _editField(descCtrl, '상세 설명', maxLines: 4),
                    const SizedBox(height: 16),
                    _editLabel('?댁쫰 *'),
                    ...quizRows.asMap().entries.map((entry) {
                      final index = entry.key;
                      final row = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '?댁쫰 ${index + 1}',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (quizRows.length > 1)
                                  IconButton(
                                    onPressed: saving
                                        ? null
                                        : () => setSheetState(() {
                                              row['question']!.dispose();
                                              row['answer']!.dispose();
                                              quizRows.removeAt(index);
                                            }),
                                    icon: const Icon(Icons.close, size: 16),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _editField(row['question']!, '질문을 입력하세요'),
                            const SizedBox(height: 8),
                            _editField(row['answer']!, '정답을 입력하세요'),
                          ],
                        ),
                      );
                    }),
                    if (quizRows.length < 3)
                      OutlinedButton.icon(
                        onPressed: saving
                            ? null
                            : () => setSheetState(
                                  () => quizRows.add({
                                    'question': TextEditingController(),
                                    'answer': TextEditingController(),
                                  }),
                                ),
                        icon: const Icon(Icons.add_circle_outline, size: 18),
                        label: const Text('?댁쫰 異붽??섍린'),
                      ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: saving ? null : save,
                        icon: saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save_outlined, size: 18),
                        label: Text(saving ? '저장 중...' : '저장하기'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    titleCtrl.dispose();
    descCtrl.dispose();
    locationCtrl.dispose();
    for (final row in quizRows) {
      row['question']!.dispose();
      row['answer']!.dispose();
    }

    if (updated == null || !mounted) return;
    setState(() {
      final index = _myFoundItems.indexWhere((value) => value.id == updated.id);
      if (index == -1) {
        _myFoundItems.insert(0, updated);
      } else {
        _myFoundItems[index] = updated;
      }
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('습득물이 수정되었습니다.')));
  }

  List<Map<String, Object>> get _foundCategories => const [
    {'id': 'electronics', 'name': '전자기기'},
    {'id': 'clothing', 'name': '의류'},
    {'id': 'wallet', 'name': '지갑/카드'},
    {'id': 'accessories', 'name': '액세서리'},
    {'id': 'etc', 'name': '기타'},
  ];

  Widget _editLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        color: AppColors.textDark,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  Widget _editField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
      style: const TextStyle(fontSize: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final user = auth.user!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Container(
                  color: AppColors.primary,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 16,
                    left: 16,
                    right: 16,
                    bottom: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              if (Navigator.of(context).canPop()) {
                                Navigator.of(context).pop();
                              } else {
                                context.go('/');
                              }
                            },
                            padding: EdgeInsets.zero,
                          ),
                          GestureDetector(
                            onTap: () {
                              auth.logout();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('로그아웃 되었습니다')),
                              );
                              context.go('/');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.logout_outlined,
                                    color: Colors.white38,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    '로그아웃',
                                    style: TextStyle(
                                      color: Colors.white38,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                user.avatar,
                                style: const TextStyle(fontSize: 28),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  user.email,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.4),
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star_outline,
                                      color: Colors.white54,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${user.points} pts',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      ' · ',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.2),
                                      ),
                                    ),
                                    Text(
                                      '${user.itemsFound}개 찾아줌',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.4),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            _statCell(user.points.toString(), '포인트'),
                            Container(
                              width: 1,
                              height: 50,
                              color: Colors.white.withOpacity(0.06),
                            ),
                            _statCell(user.itemsFound.toString(), '찾아줌'),
                            Container(
                              width: 1,
                              height: 50,
                              color: Colors.white.withOpacity(0.06),
                            ),
                            _statCell('12위', '랭킹'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Tab switcher
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: neumorphicDecoration(radius: 18),
                    child: Row(
                      children: [
                        _tabBtn('items', '내 물건', Icons.inventory_2_outlined),
                        _tabBtn(
                          'activity',
                          '활동 내역',
                          Icons.emoji_events_outlined,
                        ),
                      ],
                    ),
                  ),
                ),
                // Tab content
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Column(
                    children: _activeTab == 'items'
                        ? _buildMyFoundItems()
                        : _buildMyActivities(),
                  ),
                ),
                // Quick links
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '바로가기',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _quickLink('🔖', '즐겨찾기', '/favorites'),
                          _quickLink('💬', '채팅', '/chats'),
                          _quickLink('🛍️', '포인트 상점', '/shop'),
                        ],
                      ),
                    ],
                  ),
                ),
                // Settings
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '설정',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: neumorphicDecoration(radius: 18),
                        child: Column(
                          children: [
                            _settingRow(
                              icon: Icons.notifications_outlined,
                              label: '알림 설정',
                              trailing: Switch(
                                value: _notifEnabled,
                                onChanged: (v) =>
                                    setState(() => _notifEnabled = v),
                                activeColor: AppColors.primary,
                              ),
                            ),
                            Divider(
                              height: 1,
                              color: Colors.black.withOpacity(0.04),
                            ),
                            _settingRow(
                              icon: Icons.description_outlined,
                              label: '서비스 이용약관',
                              onTap: () => setState(() => _modal = 'terms'),
                            ),
                            Divider(
                              height: 1,
                              color: Colors.black.withOpacity(0.04),
                            ),
                            _settingRow(
                              icon: Icons.shield_outlined,
                              label: '개인정보 처리방침',
                              onTap: () => setState(() => _modal = 'privacy'),
                            ),
                            Divider(
                              height: 1,
                              color: Colors.black.withOpacity(0.04),
                            ),
                            _settingRow(
                              icon: Icons.settings_outlined,
                              label: '계정 설정',
                              onTap: () => context.push('/account-settings'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_modal != null)
            _buildPolicyModal(
              _modal == 'terms' ? '서비스 이용약관' : '개인정보 처리방침',
              _modal == 'terms' ? _termsContent : _privacyContent,
            ),
        ],
      ),
    );
  }

  List<Widget> _buildMyFoundItems() {
    if (_itemsLoading) {
      return [
        const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      ];
    }

    if (_itemsError != null) {
      return [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: neumorphicDecoration(radius: 18),
          child: Column(
            children: [
              Text(
                _itemsError!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _loadMyFoundItems,
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ];
    }

    if (_myFoundItems.isEmpty) {
      return [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: neumorphicDecoration(radius: 18),
          child: const Text(
            '아직 등록한 습득물이 없습니다.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ),
      ];
    }

    return _myFoundItems.map((item) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: neumorphicDecoration(radius: 18),
        child: Row(
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              color: AppColors.primary,
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: AppColors.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_formatDate(item.createdAt)} · ${item.location}',
                    style: const TextStyle(
                      color: AppColors.textFaint,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _openEditFoundItem(item),
              icon: const Icon(Icons.edit_outlined),
              color: AppColors.primary,
              tooltip: '편집',
            ),
            GestureDetector(
              onTap: () => _openEditFoundItem(item),
              child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.subtle,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '등록됨',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildMyActivities() {
    if (_activityLoading) {
      return [
        const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      ];
    }

    if (_activityError != null) {
      return [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: neumorphicDecoration(radius: 18),
          child: Column(
            children: [
              Text(
                _activityError!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _loadMyActivities,
                child: const Text('?ㅼ떆 ?쒕룄'),
              ),
            ],
          ),
        ),
      ];
    }

    if (_myActivities.isEmpty) {
      return [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: neumorphicDecoration(radius: 18),
          child: const Text(
            '아직 활동 내역이 없습니다.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ),
      ];
    }

    return _myActivities.map((activity) {
      final points = activity.pointsDelta;
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: neumorphicDecoration(radius: 18),
        child: Row(
          children: [
            Icon(_activityIcon(activity.icon), color: AppColors.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: AppColors.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _relativeTime(activity.createdAt),
                    style: const TextStyle(
                      color: AppColors.textFaint,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (points != null && points != 0)
              Text(
                points > 0 ? '+$points' : '$points',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.primary,
                ),
              ),
          ],
        ),
      );
    }).toList();
  }

  IconData _activityIcon(String icon) {
    switch (icon) {
      case 'search':
        return Icons.search_rounded;
      case 'shopping_bag':
        return Icons.shopping_bag_outlined;
      case 'inventory':
      default:
        return Icons.inventory_2_outlined;
    }
  }

  Widget _statCell(String val, String label) {
    return Expanded(
      child: Container(
        color: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Text(
              val,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabBtn(String id, String label, IconData icon) {
    final active = _activeTab == id;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = id),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: active ? Colors.white : AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: active ? Colors.white : AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickLink(String emoji, String label, String path) {
    return Expanded(
      child: GestureDetector(
        onTap: () => context.push(path),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: neumorphicDecoration(radius: 14),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _settingRow({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.subtle,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 16, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 14, color: AppColors.primary),
              ),
            ),
            trailing ??
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textFaint,
                  size: 18,
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyModal(String title, String content) {
    return GestureDetector(
      onTap: () => setState(() => _modal = null),
      child: Container(
        color: Colors.black54,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {},
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: GlassContainer(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.primary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _modal = null),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: Colors.black.withOpacity(0.06)),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        content,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                  Divider(height: 1, color: Colors.black.withOpacity(0.06)),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      MediaQuery.of(context).padding.bottom + 84,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => setState(() => _modal = null),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          '확인',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _relativeTime(DateTime date) {
    final diff = DateTime.now().difference(date.toLocal());
    if (diff.inMinutes < 1) return '방금';
    if (diff.inHours < 1) return '${diff.inMinutes}분 전';
    if (diff.inDays < 1) return '${diff.inHours}시간 전';
    return '${diff.inDays}일 전';
  }

  String _formatDate(DateTime date) =>
      '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
}
