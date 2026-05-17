import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/models.dart';
import '../services/api_client.dart';
import '../services/ranking_service.dart';
import '../theme/app_theme.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  final RankingService _rankingService = RankingService(ApiClient.instance);

  List<AngelUser> _users = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRankings();
  }

  Future<void> _loadRankings() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final users = await _rankingService.fetchRankings();
      if (!mounted) return;
      setState(() => _users = users);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: const Text(
          '랭킹',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: _loadRankings,
        color: AppColors.primary,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (_error != null) {
      return _messageState(_error!);
    }
    if (_users.isEmpty) {
      return _messageState('아직 랭킹에 표시할 사용자가 없습니다.');
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        children: [
          const Icon(
            Icons.emoji_events_rounded,
            color: AppColors.primary,
            size: 44,
          ),
          const SizedBox(height: 8),
          const Text(
            '선행 포인트 랭킹',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '분실물을 찾아준 사용자들이 여기에 표시됩니다.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 24),
          if (_users.length >= 3) _buildPodium(),
          if (_users.length >= 3) const SizedBox(height: 20),
          _buildRankingList(),
          const SizedBox(height: 16),
          _buildPointsGuide(),
        ],
      ),
    );
  }

  Widget _messageState(String message) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _loadRankings,
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPodium() {
    final top3 = _users.take(3).toList();
    final podiumOrder = [1, 0, 2];
    final medals = ['2', '1', '3'];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: podiumOrder.map((index) {
        final user = top3[index];
        final isFirst = index == 0;
        final heights = [112.0, 80.0, 64.0];
        final width = isFirst ? 112.0 : 96.0;
        return Padding(
          padding: EdgeInsets.only(top: isFirst ? 0 : 32),
          child: SizedBox(
            width: width,
            child: Column(
              children: [
                _avatar(user, size: 40),
                const SizedBox(height: 4),
                Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${user.points} pts',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: width,
                  height: heights[index],
                  decoration: BoxDecoration(
                    color: isFirst ? AppColors.primary : AppColors.subtle,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        medals[index],
                        style: TextStyle(
                          color: isFirst ? Colors.white : AppColors.textMuted,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRankingList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.emoji_events_outlined,
                  color: Colors.white60,
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  '전체 랭킹',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ...List.generate(_users.length, (index) {
            final user = _users[index];
            return Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: index < _users.length - 1
                      ? BorderSide(color: Colors.black.withOpacity(0.04))
                      : BorderSide.none,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: index < 3 ? AppColors.primary : AppColors.subtle,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: index < 3 ? Colors.white : AppColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _avatar(user),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          '${user.itemsFound}개 찾아줌',
                          style: const TextStyle(
                            color: AppColors.textLight,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        user.points.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.primary,
                        ),
                      ),
                      const Text(
                        'pts',
                        style: TextStyle(
                          color: AppColors.textFaint,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPointsGuide() {
    const rows = [
      {'act': '습득물 등록', 'pts': '+10', 'icon': Icons.add_box_outlined},
      {'act': '매칭 성공', 'pts': '+50', 'icon': Icons.check_circle_outline},
      {'act': '일일 접속', 'pts': '+5', 'icon': Icons.today_outlined},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '포인트 획득 방법',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          ...rows.map(
            (row) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    row['icon'] as IconData,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      row['act'] as String,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    row['pts'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar(AngelUser user, {double size = 28}) {
    if (user.avatar.isNotEmpty) {
      return Text(user.avatar, style: TextStyle(fontSize: size * 0.72));
    }

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: AppColors.subtle,
      child: Text(
        user.name.isEmpty ? '?' : user.name.characters.first,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
