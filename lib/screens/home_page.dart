import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../models/models.dart';
import '../services/activity_service.dart';
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
  final ActivityService _activityService = ActivityService();

  List<ActivityItem> _recentActivities = [];
  bool _recentLoading = true;
  String? _recentError;

  final Map<String, int> _animatedValues = {
    'registered': 0,
    'matched': 0,
    'rate': 0,
  };
  final Map<String, int> _targets = {
    'registered': 156,
    'matched': 89,
    'rate': 57,
  };

  @override
  void initState() {
    super.initState();
    _loadRecentItems();
    _startAnimation();
  }

  Future<void> _loadRecentItems() async {
    try {
      final result = await _itemsService.fetchItems(limit: 1);
      final activities = await _activityService.fetchRecent(limit: 5);
      if (!mounted) return;
      setState(() {
        _recentActivities = activities;
        _recentLoading = false;
        _recentError = null;
        _targets['registered'] = result.total;
        _targets['matched'] = 0;
        _targets['rate'] = result.total == 0 ? 0 : 0;
      });
      _startAnimation();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _recentLoading = false;
        _recentError = e.toString();
      });
    }
  }

  void _startAnimation() {
    for (final key in _targets.keys) {
      _animateValue(key, _targets[key]!);
    }
  }

  void _animateValue(String key, int target) async {
    final steps = 40;
    for (int i = 1; i <= steps; i++) {
      await Future.delayed(const Duration(milliseconds: 30));
      if (mounted) {
        setState(() {
          _animatedValues[key] = ((target / steps) * i).floor().clamp(
            0,
            target,
          );
        });
      }
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
          IconButton(
            icon: const Icon(Icons.menu, color: AppColors.textDark),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      endDrawer: _buildDrawer(auth),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero
            Container(
              color: AppColors.primary,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (auth.isLoggedIn) ...[
                    const Text(
                      'Welcome back',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${auth.user!.name}님 👋',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ] else ...[
                    const Text(
                      '퀴즈로 찾는',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '분실물 매칭 서비스 ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Image.asset(
                          'assets/app_logo_T_white_N.png',
                          width: 37,
                          height: 37,
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                  // Stats
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        _statCell(
                          _animatedValues['registered'].toString(),
                          '건',
                          '등록됨',
                        ),
                        _divider(),
                        _statCell(
                          _animatedValues['matched'].toString(),
                          '건',
                          '매칭됨',
                        ),
                        _divider(),
                        _statCell(
                          _animatedValues['rate'].toString(),
                          '%',
                          '성공률',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Action cards
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.push('/lost-items'),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: neumorphicDecoration(radius: 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.search_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              '분실물\n찾기',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              '퀴즈 풀고\n내 물건 찾기',
                              style: TextStyle(
                                color: AppColors.textLight,
                                fontSize: 11,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: const [
                                Text(
                                  '바로가기',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: 2),
                                Icon(
                                  Icons.arrow_forward,
                                  size: 12,
                                  color: AppColors.textMuted,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.push('/register-found'),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.upload_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              '습득물\n등록',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '주운 물건\n주인 찾아주기',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 11,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Text(
                                  '등록하기',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.4),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Icon(
                                  Icons.arrow_forward,
                                  size: 12,
                                  color: Colors.white.withOpacity(0.4),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Feature grid
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  _featureCell(Icons.map_outlined, '지도', '/map'),
                  _featureCell(
                    Icons.chat_bubble_outline_rounded,
                    '채팅',
                    '/chats',
                  ),
                  _featureCell(Icons.shopping_bag_outlined, '상점', '/shop'),
                ],
              ),
            ),
            // Tip
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: neumorphicDecoration(radius: 18),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.subtle,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '오늘의 팁',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '물건 특징을 세밀하게 입력할수록 매칭 성공률이 올라가요!',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Recent activity
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '최근 활동',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.primary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/ranking'),
                    child: const Row(
                      children: [
                        Text(
                          '전체보기',
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
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Container(
                decoration: neumorphicDecoration(radius: 18),
                child: _buildRecentItems(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentItems() {
    if (_recentLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_recentError != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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

    if (_recentActivities.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          '아직 등록된 습득물이 없습니다.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      );
    }

    return Column(
      children: List.generate(_recentActivities.length, (index) {
        final item = _recentActivities[index];
        return Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: index < _recentActivities.length - 1
                  ? BorderSide(color: Colors.black.withOpacity(0.04))
                  : BorderSide.none,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _activityIcon(item.icon),
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.bolt_outlined,
                          size: 10,
                          color: AppColors.textFaint,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            item.location ?? item.description,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textFaint,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                _formatDate(item.createdAt),
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textFaint,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _statCell(String value, String unit, String label) {
    return Expanded(
      child: Container(
        color: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                Text(
                  unit,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.35),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 60, color: Colors.white.withOpacity(0.06));

  Widget _featureCell(IconData icon, String label, String path) {
    return Expanded(
      child: GestureDetector(
        onTap: () => context.push(path),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.subtle,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
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

  String _formatDate(DateTime date) =>
      '${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';

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
                        Text(
                          auth.user!.avatar.isNotEmpty ? auth.user!.avatar : '🙂',
                          style: const TextStyle(fontSize: 36),
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
