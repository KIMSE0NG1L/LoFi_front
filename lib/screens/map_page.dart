import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart' hide Path;
import '../theme/app_theme.dart';
import '../data/mock_data.dart' show categoryEmoji, categoryColors;
import '../models/models.dart';
import '../services/items_service.dart';
import '../widgets/quiz_modal.dart';
import '../widgets/surfaces.dart';

// CartoDB Positron — 라벨이 정갈하고 배경이 밝아 애플 지도와 톤이 비슷한
// 오픈소스(OpenStreetMap 기반) 무료 타일. API 키 불필요.
const _tileUrl = 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png';
const _tileSubdomains = ['a', 'b', 'c', 'd'];

const _seoulCenter = LatLng(37.5665, 126.9780);

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  final ItemsService _itemsService = ItemsService();

  LostItem? _activeItem;
  String _activeFilter = 'all';
  String _searchQuery = '';
  LatLng? _myLocation;

  List<LostItem> _items = [];
  bool _loading = true;
  String? _error;

  List<LostItem> get _filtered {
    if (_searchQuery.trim().isEmpty) return _items;
    final q = _searchQuery.toLowerCase();
    return _items.where((item) => item.location.toLowerCase().contains(q)).toList();
  }

  final _filters = [
    {'id': 'all', 'label': '전체', 'icon': Icons.map_outlined},
    {'id': 'electronics', 'label': '전자기기', 'icon': Icons.smartphone_outlined},
    {'id': 'wallet', 'label': '지갑', 'icon': Icons.account_balance_wallet_outlined},
    {'id': 'clothing', 'label': '의류', 'icon': Icons.checkroom_outlined},
    {'id': 'accessories', 'label': '액세서리', 'icon': Icons.watch_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _resolveMyLocation();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _itemsService.fetchItems(
        category: _activeFilter == 'all' ? null : _activeFilter,
        limit: 100,
      );
      if (!mounted) return;
      setState(() => _items = result.items);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // 습득물 등록 시 지도 위치를 아직 입력받지 않아 mapPos가 항상 (0,0)이라,
  // 핀이 한 점에 겹치지 않도록 아이템 id로 안정적인 위치를 흩뿌려 배치.
  // 할것.txt "지도 리얼데이터" 항목에서 실제 좌표로 교체 예정.
  LatLng _toLatLng(MapPos pos, String id) {
    const latMax = 37.70, latMin = 37.42;
    const lngMin = 126.76, lngMax = 127.18;
    double x = pos.x, y = pos.y;
    if (x == 0 && y == 0) {
      final h = id.hashCode;
      x = (h % 80 + 10).toDouble();
      y = ((h ~/ 80) % 80 + 10).toDouble();
    }
    return LatLng(
      latMax - (y / 100) * (latMax - latMin),
      lngMin + (x / 100) * (lngMax - lngMin),
    );
  }

  Future<void> _resolveMyLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() => _myLocation = LatLng(pos.latitude, pos.longitude));
      _mapController.move(_myLocation!, 14);
    } catch (_) {
      // 위치를 가져오지 못하면 서울 기본 좌표로 유지
    }
  }

  void _goToMyLocation() {
    if (_myLocation != null) {
      _mapController.move(_myLocation!, 15);
    } else {
      _resolveMyLocation();
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
          '지도로 찾기',
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600, fontSize: 17),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 40,
              height: 40,
              decoration: neumorphicDecoration(radius: 12),
              child: const Icon(Icons.tune_rounded, color: AppColors.textDark, size: 18),
            ),
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // 검색 영역
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: neumorphicDecoration(radius: 14),
                  child: DropdownButton<String>(
                    value: _activeFilter,
                    isDense: true,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted, size: 18),
                    style: const TextStyle(color: AppColors.textDark, fontSize: 13, fontWeight: FontWeight.w500),
                    items: _filters
                        .map((f) => DropdownMenuItem(
                              value: f['id'] as String,
                              child: Text(f['label'] as String),
                            ))
                        .toList(),
                    onChanged: (v) {
                      setState(() => _activeFilter = v!);
                      _loadItems();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: neumorphicDecoration(radius: 14),
                    child: TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: const TextStyle(color: AppColors.textDark, fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: '위치 검색',
                        hintStyle: TextStyle(color: AppColors.textFaint, fontSize: 13),
                        prefixIcon: Icon(Icons.search_rounded, color: AppColors.textFaint, size: 18),
                        border: InputBorder.none,
                        isCollapsed: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 카테고리 필터 칩
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              itemBuilder: (_, i) {
                final f = _filters[i];
                final active = _activeFilter == f['id'];
                return GestureDetector(
                  onTap: () {
                    setState(() => _activeFilter = f['id'] as String);
                    _loadItems();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? const Color(0xFFE8EEFC) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: active ? AppColors.interactive : Colors.black.withOpacity(0.05),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          f['icon'] as IconData,
                          size: 15,
                          color: active ? AppColors.interactive : AppColors.textMuted,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          f['label'] as String,
                          style: TextStyle(
                            color: active ? AppColors.interactive : AppColors.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          // 지도
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                height: 300,
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _myLocation ?? _seoulCenter,
                        initialZoom: 12,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: _tileUrl,
                          subdomains: _tileSubdomains,
                          userAgentPackageName: 'com.guhaejo.app',
                        ),
                        MarkerLayer(
                          markers: [
                            if (_myLocation != null)
                              Marker(
                                point: _myLocation!,
                                width: 40,
                                height: 40,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.interactive.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: AppColors.interactive,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ...filtered.map((item) {
                              final color = Color(categoryColors[item.category] ?? 0xFF5B9BF2);
                              final emoji = categoryEmoji[item.category] ?? '📦';
                              final isActive = _activeItem?.id == item.id;
                              return Marker(
                                point: _toLatLng(item.mapPos, item.id),
                                width: 40,
                                height: 46,
                                alignment: Alignment.topCenter,
                                child: GestureDetector(
                                  onTap: () => setState(() => _activeItem = isActive ? null : item),
                                  child: Column(
                                    children: [
                                      Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: color,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.white, width: 2),
                                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6, offset: const Offset(0, 2))],
                                            ),
                                            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 16))),
                                          ),
                                          if (isActive)
                                            Positioned(
                                              top: -2,
                                              right: -2,
                                              child: Container(
                                                width: 12,
                                                height: 12,
                                                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: color, width: 2)),
                                              ),
                                            ),
                                        ],
                                      ),
                                      CustomPaint(painter: _TrianglePainter(color), size: const Size(10, 7)),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                        const SimpleAttributionWidget(
                          source: Text('© OpenStreetMap contributors © CARTO'),
                        ),
                      ],
                    ),
                    // 등록 개수 배지
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)],
                        ),
                        child: Text(
                          '${filtered.length}개 등록',
                          style: const TextStyle(color: AppColors.textDark, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    // 내 위치로 이동 버튼
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: _goToMyLocation,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
                          ),
                          child: const Icon(Icons.my_location_rounded, color: AppColors.interactive, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 안내 문구 또는 선택된 아이템
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _activeItem != null
                ? _activeItemCard(_activeItem!)
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textFaint),
                      const SizedBox(width: 6),
                      const Text(
                        '핀을 탭하면 상세 정보를 볼 수 있어요',
                        style: TextStyle(color: AppColors.textFaint, fontSize: 12),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 12),
          // 목록 헤더
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '전체 목록',
                  style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600, fontSize: 14),
                ),
                Row(
                  children: [
                    const Text('최신순', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted, size: 16),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // 목록
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.interactive))
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_error!, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                            const SizedBox(height: 8),
                            OutlinedButton(onPressed: _loadItems, child: const Text('다시 시도')),
                          ],
                        ),
                      )
                    : filtered.isEmpty
                        ? const Center(
                            child: Text('등록된 습득물이 없습니다.', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                          )
                        : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final item = filtered[i];
                final isActive = _activeItem?.id == item.id;
                return GestureDetector(
                  onTap: () {
                    setState(() => _activeItem = item);
                    _mapController.move(_toLatLng(item.mapPos, item.id), 15);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isActive ? AppColors.interactive : Colors.black.withOpacity(0.05),
                      ),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: item.imageUrl != null
                              ? Image.network(item.imageUrl!, width: 52, height: 52, fit: BoxFit.cover)
                              : Container(
                                  width: 52,
                                  height: 52,
                                  color: AppColors.subtle,
                                  child: Center(child: Text(categoryEmoji[item.category] ?? '📦', style: const TextStyle(fontSize: 22))),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 12, color: AppColors.interactive),
                                  const SizedBox(width: 2),
                                  Expanded(
                                    child: Text(
                                      item.location,
                                      style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Text(_fmtDate(item.createdAt), style: const TextStyle(color: AppColors.textFaint, fontSize: 11)),
                        const Icon(Icons.chevron_right, color: AppColors.textFaint, size: 18),
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
      decoration: neumorphicDecoration(radius: 18),
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
                    Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textDark), overflow: TextOverflow.ellipsis),
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
              color: AppColors.interactive,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: const Center(
                child: Text('퀴즈 풀고 찾기', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
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
