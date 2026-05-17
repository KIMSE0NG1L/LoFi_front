import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../widgets/quiz_modal.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LostItem? _activeItem;
  String _activeFilter = 'all';
  String _searchType = 'location';
  String _searchQuery = '';

  List<LostItem> get _filtered => mockLostItems.where((item) {
    if (_activeFilter != 'all' && item.category != _activeFilter) return false;
    if (_searchQuery.trim().isNotEmpty) {
      if (_searchType == 'location') {
        return item.location.toLowerCase().contains(_searchQuery.toLowerCase());
      } else {
        return item.title.toLowerCase().contains(_searchQuery.toLowerCase());
      }
    }
    return true;
  }).toList();

  final _filters = [
    {'id': 'all', 'label': '전체', 'emoji': '🗺️'},
    {'id': 'electronics', 'label': '전자기기', 'emoji': '📱'},
    {'id': 'wallet', 'label': '지갑', 'emoji': '👛'},
    {'id': 'clothing', 'label': '의류', 'emoji': '👔'},
    {'id': 'accessories', 'label': '액세서리', 'emoji': '⌚'},
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: AppColors.primary.withOpacity(0.95),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.canPop() ? context.pop() : context.go('/')),
        title: const Text('지도로 찾기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 17)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(Icons.navigation_outlined, color: Colors.white38, size: 14),
                const SizedBox(width: 4),
                const Text('서울', style: TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: DropdownButton<String>(
                    value: _searchType,
                    isDense: true,
                    dropdownColor: const Color(0xFF1A1A1A),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'location', child: Text('위치')),
                      DropdownMenuItem(value: 'item', child: Text('물품명')),
                    ],
                    onChanged: (v) => setState(() => _searchType = v!),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    decoration: InputDecoration(
                      hintText: _searchType == 'location' ? '위치 검색...' : '물품명 검색...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
                      prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.4), size: 16),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.white.withOpacity(0.4))),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _filters.length,
              itemBuilder: (_, i) {
                final f = _filters[i];
                final active = _activeFilter == f['id'];
                return GestureDetector(
                  onTap: () => setState(() => _activeFilter = f['id']!),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: active ? Colors.white : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Text(f['emoji']!, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(f['label']!, style: TextStyle(color: active ? AppColors.primary : Colors.white.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Map
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LayoutBuilder(builder: (ctx, constraints) {
              final w = constraints.maxWidth;
              const h = 300.0;
              return Container(
                width: w, height: h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
                  ),
                ),
                clipBehavior: Clip.hardEdge,
                child: Stack(
                  children: [
                    // Grid
                    ...([20, 40, 60, 80].expand((p) => [
                      Positioned(left: w * p / 100, top: 0, bottom: 0, child: Container(width: 1, color: Colors.white.withOpacity(0.04))),
                      Positioned(top: h * p / 100, left: 0, right: 0, child: Container(height: 1, color: Colors.white.withOpacity(0.04))),
                    ])),
                    // Han river
                    Positioned(
                      left: w * 0.12, top: h * 0.46,
                      width: w * 0.76, height: h * 0.07,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Colors.transparent, Color(0xFF2563EB), Colors.transparent]),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    Positioned(
                      left: w * 0.18, top: h * 0.475,
                      child: Text('— 한 강 —', style: TextStyle(fontSize: 8, color: Colors.blue.shade200.withOpacity(0.5), letterSpacing: 2, fontWeight: FontWeight.w500)),
                    ),
                    // Districts
                    ...districts.map((d) => Positioned(
                      left: w * (d['x'] as double) / 100 - 16,
                      top: h * (d['y'] as double) / 100 - 8,
                      child: Text(d['name'] as String, style: TextStyle(fontSize: 8, color: Colors.white.withOpacity(0.2), fontWeight: FontWeight.w500)),
                    )),
                    // Item pins
                    ...filtered.map((item) {
                      final color = Color(categoryColors[item.category] ?? 0xFF0D0D0D);
                      final emoji = categoryEmoji[item.category] ?? '📦';
                      final isActive = _activeItem?.id == item.id;
                      return Positioned(
                        left: w * item.mapPos.x / 100 - 18,
                        top: h * item.mapPos.y / 100 - 36,
                        child: GestureDetector(
                          onTap: () => setState(() => _activeItem = isActive ? null : item),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    width: 36, height: 36,
                                    decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)]),
                                    child: Center(child: Text(emoji, style: const TextStyle(fontSize: 16))),
                                  ),
                                  if (isActive)
                                    Positioned(top: -2, right: -2, child: Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: color, width: 2)))),
                                ],
                              ),
                              CustomPaint(painter: _TrianglePainter(color), size: const Size(10, 7)),
                            ],
                          ),
                        ),
                      );
                    }),
                    // Count badge
                    Positioned(
                      top: 12, right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                        child: Text('${filtered.length}개 등록', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          // Active item or hint
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _activeItem != null
                ? _activeItemCard(_activeItem!)
                : const Center(child: Text('핀을 탭하면 상세 정보를 볼 수 있어요', style: TextStyle(color: Colors.white30, fontSize: 12))),
          ),
          const SizedBox(height: 12),
          // List
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(alignment: Alignment.centerLeft, child: Text('전체 목록', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5))),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final item = filtered[i];
                final isActive = _activeItem?.id == item.id;
                return GestureDetector(
                  onTap: () => setState(() => _activeItem = item),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Text(categoryEmoji[item.category] ?? '📦', style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(item.title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                            Text('📍 ${item.location}', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
                          ]),
                        ),
                        Text(_fmtDate(item.createdAt), style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _activeItemCard(LostItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                if (item.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(item.imageUrl!, width: 64, height: 64, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 64, height: 64, color: AppColors.subtle)),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.primary), overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(item.description, style: const TextStyle(color: AppColors.textMuted, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Text('📍 ${item.location}', style: const TextStyle(fontSize: 10, color: AppColors.textFaint)),
                  ]),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => QuizModal(item: item))),
            child: Container(
              width: double.infinity,
              color: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Center(child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('퀴즈 풀고 찾기 ', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                  Image.asset('assets/app_logo_T_white_N.png', width: 20, height: 20),
                ],
              )),
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) => '${d.month}월 ${d.day}일';
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  const _TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrianglePainter old) => old.color != color;
}
