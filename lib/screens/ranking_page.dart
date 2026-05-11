import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart';

class RankingPage extends StatelessWidget {
  const RankingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final top3 = mockAngelUsers.take(3).toList();
    final podiumOrder = [1, 0, 2]; // 2nd, 1st, 3rd
    final medalEmoji = ['🥇', '🥈', '🥉'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.of(context).pop()),
        title: const Text('랭킹', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: Column(
          children: [
            // Header
            const Text('👼', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            const Text('선행 포인트 랭킹', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 4),
            const Text('분실물을 찾아준 천사들을 응원합니다!', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            const SizedBox(height: 24),
            // Podium
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: podiumOrder.map((index) {
                final u = top3[index];
                final isFirst = index == 0;
                final heights = [112.0, 80.0, 64.0];
                final widths = isFirst ? 112.0 : 96.0;
                return Padding(
                  padding: EdgeInsets.only(top: isFirst ? 0 : 32),
                  child: SizedBox(
                    width: widths,
                    child: Column(
                      children: [
                        Text(u.avatar, style: const TextStyle(fontSize: 24)),
                        const SizedBox(height: 4),
                        Text(u.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.primary)),
                        const SizedBox(height: 2),
                        Text('${u.points} pts', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                        const SizedBox(height: 8),
                        Container(
                          width: widths,
                          height: heights[index],
                          decoration: BoxDecoration(
                            color: isFirst ? AppColors.primary : AppColors.subtle,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(medalEmoji[index], style: const TextStyle(fontSize: 20)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            // Full ranking
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.black.withOpacity(0.05)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                    ),
                    child: Row(children: const [
                      Icon(Icons.emoji_events_outlined, color: Colors.white60, size: 18),
                      SizedBox(width: 8),
                      Text('전체 랭킹', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                    ]),
                  ),
                  ...List.generate(mockAngelUsers.length, (i) {
                    final u = mockAngelUsers[i];
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(bottom: i < mockAngelUsers.length - 1 ? BorderSide(color: Colors.black.withOpacity(0.04)) : BorderSide.none),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              color: i < 3 ? AppColors.primary : AppColors.subtle,
                              shape: BoxShape.circle,
                            ),
                            child: Center(child: Text('${i + 1}', style: TextStyle(color: i < 3 ? Colors.white : AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.bold))),
                          ),
                          const SizedBox(width: 12),
                          Text(u.avatar, style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(u.name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: AppColors.primary)),
                                Text('${u.itemsFound}개 찾아줌', style: const TextStyle(color: AppColors.textLight, fontSize: 11)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(u.points.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary)),
                              const Text('pts', style: TextStyle(color: AppColors.textFaint, fontSize: 10)),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Points guide
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.black.withOpacity(0.05)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('포인트 획득 방법', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.primary)),
                  const SizedBox(height: 12),
                  ...[
                    {'act': '습득물 등록', 'pts': '+10', 'emoji': '📦'},
                    {'act': '매칭 성공', 'pts': '+50', 'emoji': '🎉'},
                    {'act': '일일 접속', 'pts': '+5', 'emoji': '📅'},
                  ].map((row) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Text(row['emoji']!, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 10),
                        Expanded(child: Text(row['act']!, style: const TextStyle(color: AppColors.textDark, fontSize: 14))),
                        Text(row['pts']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary)),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
