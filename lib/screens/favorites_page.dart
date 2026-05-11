import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart';
import '../providers/auth_provider.dart';
import '../widgets/quiz_modal.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final favItems = mockLostItems.where((item) => auth.isFavorite(item.id)).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.of(context).pop()),
        title: const Text('즐겨찾기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
      ),
      body: favItems.isEmpty
          ? Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('🔖', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                const Text('즐겨찾기가 없습니다', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                const SizedBox(height: 8),
                const Text('분실물 목록에서 즐겨찾기를 추가해보세요', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
              ]),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: favItems.length,
              itemBuilder: (_, i) {
                final item = favItems[i];
                return GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => QuizModal(item: item))),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.black.withOpacity(0.05)),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              if (item.imageUrl != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(item.imageUrl!, width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 80, height: 80, color: AppColors.subtle)),
                                ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Row(children: [
                                    Expanded(child: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.primary), overflow: TextOverflow.ellipsis)),
                                    GestureDetector(
                                      onTap: () => auth.toggleFavorite(item.id),
                                      child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.bookmark, color: AppColors.primary, size: 18)),
                                    ),
                                  ]),
                                  const SizedBox(height: 4),
                                  Text(item.description, style: const TextStyle(color: AppColors.textMuted, fontSize: 12, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 8),
                                  Row(children: [
                                    const Icon(Icons.location_on_outlined, size: 11, color: AppColors.textFaint),
                                    const SizedBox(width: 2),
                                    Text(item.location, style: const TextStyle(fontSize: 10, color: AppColors.textFaint)),
                                  ]),
                                ]),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: const BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(18), bottomRight: Radius.circular(18))),
                          child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text('퀴즈 풀고 찾기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                            SizedBox(width: 6),
                            Text('🎯', style: TextStyle(fontSize: 12)),
                          ]),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
