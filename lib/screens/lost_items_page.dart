import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../services/items_service.dart';
import '../widgets/quiz_modal.dart';
import '../widgets/surfaces.dart';

class LostItemsPage extends StatefulWidget {
  const LostItemsPage({super.key});

  @override
  State<LostItemsPage> createState() => _LostItemsPageState();
}

class _LostItemsPageState extends State<LostItemsPage> {
  final ItemsService _itemsService = ItemsService();

  String _selectedCategory = '';
  String _selectedLocation = '';
  String _searchQuery = '';
  bool _showFilter = false;
  List<LostItem> _items = [];
  bool _loading = true;
  bool _loadingMore = false;
  int _page = 1;
  int _totalPages = 1;
  String? _error;
  late final ScrollController _scrollCtrl;

  final Map<String, List<String>> _locationKeywords = {
    'subway': ['역', '지하철', '호선'],
    'bus': ['버스', '정류장'],
    'cafe': ['카페', '음식점', '레스토랑', '식당'],
    'mall': ['쇼핑몰', '백화점', '몰', '월드'],
    'station': ['역 근처', '출구'],
  };

  List<LostItem> get _filtered => _items.where((item) {
    final matchCat =
        _selectedCategory.isEmpty || item.category == _selectedCategory;
    final matchSearch =
        _searchQuery.isEmpty ||
        item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        item.description.toLowerCase().contains(_searchQuery.toLowerCase());
    final matchLoc =
        _selectedLocation.isEmpty ||
        (_locationKeywords[_selectedLocation]?.any(
              (k) => item.location.contains(k) || item.description.contains(k),
            ) ??
            false);
    return matchCat && matchSearch && matchLoc;
  }).toList();

  int get _activeFilters =>
      (_selectedCategory.isNotEmpty ? 1 : 0) +
      (_selectedLocation.isNotEmpty ? 1 : 0);

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController()..addListener(_onScroll);
    _loadItems();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadItems() async {
    setState(() { _loading = true; _error = null; _page = 1; });
    try {
      final result = await _itemsService.fetchItems(page: 1, limit: 20);
      if (!mounted) return;
      setState(() {
        _items = result.items;
        _totalPages = result.totalPages;
        _page = 1;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _page >= _totalPages) return;
    setState(() => _loadingMore = true);
    try {
      final next = _page + 1;
      final result = await _itemsService.fetchItems(page: next, limit: 20);
      if (!mounted) return;
      setState(() {
        _items.addAll(result.items);
        _page = next;
        _totalPages = result.totalPages;
      });
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: const Text(
          '분실물 찾기',
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.black.withOpacity(0.07)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: '분실물 검색...',
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.textLight,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _iconButton(
                  badge: _activeFilters > 0 ? _activeFilters.toString() : null,
                  icon: Icons.tune_rounded,
                  onTap: () => setState(() => _showFilter = true),
                ),
                const SizedBox(width: 8),
                _iconButton(
                  icon: Icons.map_outlined,
                  onTap: () => context.push('/map'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: GestureDetector(
              onTap: () => context.push('/lost-reports'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bolt_rounded, color: Colors.amber, size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        '내 물건을 잃어버렸나요? 현상금 걸고 분실 신고하기',
                        style: TextStyle(color: AppColors.textDark, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.amber.shade800, size: 18),
                  ],
                ),
              ),
            ),
          ),
          // Active filters
          if (_activeFilters > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(
                children: [
                  const Text(
                    '필터: ',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  if (_selectedCategory.isNotEmpty)
                    _filterChip(
                      categories.firstWhere(
                            (c) => c['id'] == _selectedCategory,
                          )['name']
                          as String,
                      () => setState(() => _selectedCategory = ''),
                    ),
                  if (_selectedLocation.isNotEmpty)
                    _filterChip(
                      _locationLabel(_selectedLocation),
                      () => setState(() => _selectedLocation = ''),
                    ),
                  GestureDetector(
                    onTap: () => setState(() {
                      _selectedCategory = '';
                      _selectedLocation = '';
                    }),
                    child: const Text(
                      '전체 초기화',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // List
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(
              children: [
                Text(
                  '분실물 목록',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '(${filtered.length})',
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _error != null
                ? _errorState()
                : filtered.isEmpty
                ? _emptyState()
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    itemCount: filtered.length + (_loadingMore ? 1 : 0),
                    itemBuilder: (ctx, i) {
                      if (i == filtered.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
                        );
                      }
                      return _itemCard(filtered[i]);
                    },
                  ),
          ),
          if (_showFilter) _buildFilterSheet(),
        ],
      ),
    );
  }

  Widget _iconButton({
    required IconData icon,
    VoidCallback? onTap,
    String? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.black.withOpacity(0.07)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
              ],
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          if (badge != null)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, color: Colors.white, size: 14),
          ),
        ],
      ),
    );
  }

  void _showLoginPrompt() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => GlassContainer(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 24),
            const Text('🔐', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 16),
            const Text(
              '로그인이 필요해요',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            const Text(
              '퀴즈를 풀려면 먼저 로그인해 주세요.',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.push('/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('로그인하기', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemCard(LostItem item) {
    return GestureDetector(
      onTap: () {
        final auth = context.read<AuthProvider>();
        if (!auth.isLoggedIn) {
          _showLoginPrompt();
          return;
        }
        Navigator.of(
          context,
          rootNavigator: true,
        ).push(MaterialPageRoute(builder: (_) => QuizModal(item: item)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: neumorphicDecoration(radius: 18),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  if (item.imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        item.imageUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 80,
                          height: 80,
                          color: AppColors.subtle,
                        ),
                      ),
                    ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: AppColors.primary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            _favoriteButton(item.id),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.description,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 11,
                              color: AppColors.textFaint,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(item.createdAt),
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textFaint,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '퀴즈 풀고 찾기',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Image.asset(
                    'assets/app_logo_T_white_N.png',
                    width: 20,
                    height: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _favoriteButton(String id) {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) => GestureDetector(
        onTap: () => auth.toggleFavorite(id),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            auth.isFavorite(id) ? Icons.bookmark : Icons.bookmark_border,
            color: auth.isFavorite(id)
                ? AppColors.primary
                : AppColors.textFaint,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _errorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _loadItems, child: const Text('다시 시도')),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          const Text(
            '분실물이 없습니다',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '다른 조건으로 검색해보세요',
            style: TextStyle(color: AppColors.textLight, fontSize: 12),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => setState(() {
              _selectedCategory = '';
              _searchQuery = '';
            }),
            child: const Text(
              '전체 보기',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSheet() {
    return GestureDetector(
      onTap: () => setState(() => _showFilter = false),
      child: Stack(
        children: [
          Container(color: Colors.black54),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {},
              child: GlassContainer(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '카테고리',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories.map((cat) {
                        final active = _selectedCategory == cat['id'];
                        return GestureDetector(
                          onTap: () => setState(
                            () => _selectedCategory = active
                                ? ''
                                : cat['id'] as String,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: active
                                  ? AppColors.primary
                                  : AppColors.background,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: active
                                    ? AppColors.primary
                                    : Colors.black.withOpacity(0.08),
                              ),
                            ),
                            child: Text(
                              cat['name'] as String,
                              style: TextStyle(
                                color: active
                                    ? Colors.white
                                    : AppColors.textMuted,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '위치',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          [
                            {'id': 'subway', 'name': '지하철'},
                            {'id': 'bus', 'name': '버스 정류장'},
                            {'id': 'cafe', 'name': '카페/음식점'},
                            {'id': 'mall', 'name': '쇼핑몰'},
                            {'id': 'station', 'name': '역 근처'},
                          ].map((loc) {
                            final active = _selectedLocation == loc['id'];
                            return GestureDetector(
                              onTap: () => setState(
                                () => _selectedLocation = active
                                    ? ''
                                    : loc['id']!,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: active
                                      ? AppColors.primary
                                      : AppColors.background,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: active
                                        ? AppColors.primary
                                        : Colors.black.withOpacity(0.08),
                                  ),
                                ),
                                child: Text(
                                  loc['name']!,
                                  style: TextStyle(
                                    color: active
                                        ? Colors.white
                                        : AppColors.textMuted,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setState(() {
                              _selectedCategory = '';
                              _selectedLocation = '';
                            }),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              side: BorderSide(
                                color: Colors.black.withOpacity(0.1),
                              ),
                            ),
                            child: const Text(
                              '초기화',
                              style: TextStyle(color: AppColors.textMuted),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () =>
                                setState(() => _showFilter = false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              '적용',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
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
    );
  }

  String _locationLabel(String id) {
    const labels = {
      'subway': '지하철',
      'bus': '버스 정류장',
      'cafe': '카페/음식점',
      'mall': '쇼핑몰',
      'station': '역 근처',
    };
    return labels[id] ?? id;
  }

  String _formatDate(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';
}
