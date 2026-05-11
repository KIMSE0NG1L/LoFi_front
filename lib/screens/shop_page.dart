import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  String _activeCategory = '전체';
  ShopItem? _confirmItem;
  ShopItem? _successItem;

  final _categories = ['전체', '카페', '편의점', '배달', '영화', '포인트', '기부'];

  List<ShopItem> get _filtered => _activeCategory == '전체'
      ? mockShopItems
      : mockShopItems.where((i) => i.category == _activeCategory).toList();

  void _purchase(AuthProvider auth) {
    if (_confirmItem == null) return;
    if (!auth.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다')));
      setState(() => _confirmItem = null);
      return;
    }
    final ok = auth.spendPoints(_confirmItem!.cost);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('포인트가 부족합니다')));
      setState(() => _confirmItem = null);
      return;
    }
    setState(() { _successItem = _confirmItem; _confirmItem = null; });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary.withOpacity(0.95),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.of(context).pop()),
        title: const Text('포인트 상점', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 17)),
        automaticallyImplyLeading: false,
        actions: [
          if (auth.isLoggedIn)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Row(children: [
                const Text('보유 ', style: TextStyle(color: Colors.white60, fontSize: 12)),
                Text('${auth.user!.points}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                Text(' pts', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
              ]),
            ),
        ],
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Category filter
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _categories.length,
                    itemBuilder: (_, i) {
                      final cat = _categories[i];
                      final active = cat == _activeCategory;
                      return GestureDetector(
                        onTap: () => setState(() => _activeCategory = cat),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: active ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: active ? AppColors.primary : Colors.black.withOpacity(0.08)),
                          ),
                          child: Text(cat, style: TextStyle(color: active ? Colors.white : AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w500)),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Not logged in banner
              if (!auth.isLoggedIn)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(14)),
                    child: Row(children: [
                      const Text('🔐', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('로그인 후 구매 가능해요', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                        Text('포인트를 적립하고 다양한 혜택을 받으세요', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11, height: 1.4)),
                      ])),
                      GestureDetector(
                        onTap: () => context.push('/login'),
                        child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)), child: const Text('로그인', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
                      ),
                    ]),
                  ),
                ),
              // Points guide
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.black.withOpacity(0.05)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)]),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('포인트 획득 방법', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.primary)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        {'emoji': '📦', 'act': '등록', 'pts': '+10'},
                        {'emoji': '🎉', 'act': '매칭', 'pts': '+50'},
                        {'emoji': '📅', 'act': '접속', 'pts': '+5'},
                      ].map((r) => Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
                          child: Column(children: [
                            Text(r['emoji']!, style: const TextStyle(fontSize: 18)),
                            const SizedBox(height: 2),
                            Text(r['pts']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.primary)),
                            Text(r['act']!, style: const TextStyle(fontSize: 10, color: AppColors.textFaint)),
                          ]),
                        ),
                      )).toList(),
                    ),
                  ]),
                ),
              ),
              // Grid
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final item = filtered[i];
                      final canAfford = auth.isLoggedIn && auth.user != null && auth.user!.points >= item.cost;
                      return GestureDetector(
                        onTap: item.stock > 0 ? () => setState(() => _confirmItem = item) : null,
                        child: Opacity(
                          opacity: item.stock == 0 ? 0.5 : 1,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.black.withOpacity(0.05)),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
                            ),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(item.emoji, style: const TextStyle(fontSize: 30)),
                              const SizedBox(height: 10),
                              Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.primary, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text(item.description, style: const TextStyle(color: AppColors.textLight, fontSize: 11, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${item.cost}pts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: canAfford ? AppColors.primary : AppColors.textFaint)),
                                  if (item.stock > 0 && item.stock <= 5) Text('잔여 ${item.stock}개', style: const TextStyle(color: Colors.red, fontSize: 10)),
                                  if (item.stock == 0) const Text('품절', style: TextStyle(color: AppColors.textFaint, fontSize: 10)),
                                ],
                              ),
                            ]),
                          ),
                        ),
                      );
                    },
                    childCount: filtered.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.75),
                ),
              ),
            ],
          ),
          // Confirm modal
          if (_confirmItem != null) _buildConfirmModal(auth),
          // Success modal
          if (_successItem != null) _buildSuccessModal(),
        ],
      ),
    );
  }

  Widget _buildConfirmModal(AuthProvider auth) {
    final item = _confirmItem!;
    final remaining = (auth.user?.points ?? 0) - item.cost;
    return GestureDetector(
      onTap: () => setState(() => _confirmItem = null),
      child: Container(
        color: Colors.black54,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.black.withOpacity(0.1), borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),
                Text(item.emoji, style: const TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
                const SizedBox(height: 4),
                Text(item.description, style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(14)),
                  child: Column(children: [
                    _pointRow('보유 포인트', '${auth.user?.points ?? 0} pts'),
                    const SizedBox(height: 8),
                    _pointRow('사용 포인트', '-${item.cost} pts', valueColor: Colors.red),
                    Divider(color: Colors.black.withOpacity(0.06), height: 24),
                    _pointRow('잔여 포인트', '$remaining pts', bold: true),
                  ]),
                ),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _confirmItem = null),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), side: BorderSide(color: Colors.black.withOpacity(0.1))),
                      child: const Text('취소', style: TextStyle(color: AppColors.textMuted)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (auth.isLoggedIn && auth.user != null && auth.user!.points >= item.cost) ? () => _purchase(auth) : null,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, disabledBackgroundColor: AppColors.subtle, disabledForegroundColor: AppColors.textFaint, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      child: const Text('교환하기', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ]),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _pointRow(String label, String value, {Color? valueColor, bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
        Text(value, style: TextStyle(color: valueColor ?? AppColors.primary, fontWeight: bold ? FontWeight.bold : FontWeight.w500, fontSize: 14)),
      ],
    );
  }

  Widget _buildSuccessModal() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 30)]),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(18)),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 16),
                const Text('교환 완료!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.primary)),
                const SizedBox(height: 8),
                Text(_successItem!.title, style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
                const SizedBox(height: 4),
                const Text('쿠폰이 발급되었습니다.\n앱 내 쿠폰함에서 확인하세요.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textFaint, fontSize: 12, height: 1.5)),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => setState(() => _successItem = null),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    child: const Text('확인', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
