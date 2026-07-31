import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../models/models.dart';
import '../services/items_service.dart';
import '../widgets/surfaces.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final ItemsService _itemsService = ItemsService();

  List<LostItem> _recentItems = [];
  bool _recentLoading = true;
  String? _recentError;
  int _totalRegistered = 0;

  @override
  void initState() {
    super.initState();
    _loadRecentItems();
  }

  Future<void> _loadRecentItems() async {
    try {
      final result = await _itemsService.fetchItems(limit: 5);
      if (!mounted) return;
      setState(() {
        _recentItems = result.items;
        _totalRegistered = result.total;
        _recentLoading = false;
        _recentError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _recentLoading = false;
        _recentError = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: false,
        title: const Text(
          '구해조!',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () =>
                  context.push(auth.isLoggedIn ? '/profile' : '/login'),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.subtle,
                backgroundImage: auth.isLoggedIn
                    ? AssetImage(auth.user!.genderAvatarAsset)
                    : null,
                child: auth.isLoggedIn
                    ? null
                    : const Icon(Icons.person_outline, color: AppColors.textDark),
              ),
            ),
          ),
        ],
      ),
      endDrawer: _buildDrawer(auth),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: AspectRatio(
                aspectRatio: 1466 / 815,
                child: Image.asset(
                  'assets/상단배경.png',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () => context.push('/lost-items'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  decoration: neumorphicDecoration(radius: 24),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search_rounded,
                        color: AppColors.textLight,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          '무엇을 잃어버리셨나요?',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.tune_rounded,
                        color: AppColors.textLight,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Persona cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _personaCard(
                      imagePath: 'assets/찾아주세요.png',
                      title: '잃어버렸어요',
                      subtitle: '현상금 걸고\n찾아보세요',
                      onTap: () => context.push('/register-lost'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _personaCard(
                      imagePath: 'assets/습득물등록.png',
                      title: '주웠어요',
                      subtitle: '습득물 등록하고\n주인을 찾아주세요',
                      onTap: () => context.push('/register-found'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _statCell(
                    background: const Color(0xFFF4F7FE),
                    icon: Icons.description_outlined,
                    iconColor: AppColors.interactive,
                    value: '$_totalRegistered',
                    unit: '건',
                    label: '오늘 접수',
                  ),
                  const SizedBox(width: 8),
                  _statCell(
                    background: const Color(0xFFEFFBF3),
                    icon: Icons.check_circle_outline_rounded,
                    iconColor: AppColors.success,
                    value: '0',
                    unit: '건',
                    label: '오늘 반환',
                  ),
                  const SizedBox(width: 8),
                  _statCell(
                    background: const Color(0xFFFDF0F0),
                    icon: Icons.favorite_border_rounded,
                    iconColor: const Color(0xFFEF4444),
                    value: '0',
                    unit: '%',
                    label: '매칭 성공률',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Nearby
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '내 주변 분실물',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.textDark,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/map'),
                    child: const Row(
                      children: [
                        Text(
                          '지도 보기',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 12,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward,
                          size: 14,
                          color: AppColors.textLight,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () => context.push('/map'),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: neumorphicDecoration(radius: 18),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset(
                            'assets/지도.png',
                            height: 90,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '내 주변',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${_recentItems.length}',
                                    style: const TextStyle(
                                      color: AppColors.textDark,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: ' 건 발견',
                                    style: TextStyle(
                                      color: AppColors.textDark,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '최근 1km 이내',
                              style: TextStyle(
                                color: AppColors.textFaint,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Recently registered
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '방금 등록된 분실물',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.textDark,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/lost-items'),
                    child: const Row(
                      children: [
                        Text(
                          '더보기',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 12,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward,
                          size: 14,
                          color: AppColors.textLight,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 168, child: _buildRecentItems()),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _personaCard({
    required String imagePath,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imagePath,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward,
                size: 13,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCell({
    required Color background,
    required IconData icon,
    required Color iconColor,
    required String value,
    required String unit,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: iconColor.withOpacity(0.15),
              child: Icon(icon, color: iconColor, size: 14),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        value,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        unit,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentItems() {
    if (_recentLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_recentError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _recentError!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _loadRecentItems,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (_recentItems.isEmpty) {
      return const Center(
        child: Text(
          '아직 등록된 습득물이 없습니다.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      );
    }

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _recentItems.length,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (_, index) => _recentItemCard(_recentItems[index]),
    );
  }

  Widget _recentItemCard(LostItem item) {
    return GestureDetector(
      onTap: () => context.push('/lost-items'),
      child: Container(
        width: 130,
        decoration: neumorphicDecoration(radius: 16),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  width: 130,
                  height: 90,
                  child: item.imageUrl != null
                      ? Image.network(item.imageUrl!, fit: BoxFit.cover)
                      : Container(
                          color: AppColors.subtle,
                          child: const Icon(
                            Icons.image_outlined,
                            color: AppColors.textFaint,
                          ),
                        ),
                ),
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _timeAgo(item.createdAt),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textFaint,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date.toLocal());
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return '${diff.inDays}일 전';
  }

  Widget _buildDrawer(AuthProvider auth) {
    return Drawer(
      width: 280,
      child: SafeArea(
        child: Column(
          children: [
            // 헤더
            Container(
              width: double.infinity,
              color: AppColors.primary,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: auth.isLoggedIn
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          backgroundImage: AssetImage(auth.user!.genderAvatarAsset),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          auth.user!.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          auth.user!.email,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.bolt_rounded, color: Colors.amber, size: 15),
                              const SizedBox(width: 4),
                              Text(
                                '${auth.user!.points} pts',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('👋', style: TextStyle(fontSize: 36)),
                        const SizedBox(height: 10),
                        const Text(
                          '로그인하고\n더 많은 기능을 이용하세요',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            context.push('/login');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              '로그인',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 8),
            // 메뉴 항목
            _drawerItem(Icons.favorite_outline_rounded, '즐겨찾기', () {
              Navigator.of(context).pop();
              context.push('/favorites');
            }),
            _drawerItem(Icons.emoji_events_outlined, '랭킹', () {
              Navigator.of(context).pop();
              context.push('/ranking');
            }),
            _drawerItem(Icons.shopping_bag_outlined, '상점', () {
              Navigator.of(context).pop();
              context.push('/shop');
            }),
            _drawerItem(Icons.map_outlined, '지도', () {
              Navigator.of(context).pop();
              context.push('/map');
            }),
            if (auth.isLoggedIn) ...[
              const Divider(indent: 16, endIndent: 16),
              _drawerItem(Icons.manage_accounts_outlined, '계정 설정', () {
                Navigator.of(context).pop();
                context.push('/account-settings');
              }),
            ],
            const Spacer(),
            const Divider(indent: 16, endIndent: 16),
            if (auth.isLoggedIn)
              _drawerItem(
                Icons.logout_rounded,
                '로그아웃',
                () async {
                  Navigator.of(context).pop();
                  await auth.logout();
                },
                color: Colors.red.shade400,
              )
            else
              _drawerItem(Icons.login_rounded, '로그인', () {
                Navigator.of(context).pop();
                context.push('/login');
              }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, VoidCallback onTap, {Color? color}) {
    final c = color ?? AppColors.primary;
    return ListTile(
      leading: Icon(icon, color: c, size: 22),
      title: Text(
        label,
        style: TextStyle(color: c, fontSize: 14, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
      dense: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
