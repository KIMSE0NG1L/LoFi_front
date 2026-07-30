import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/models.dart';
import 'supabase_client.dart';

class RankingService {
  Future<List<AngelUser>> fetchRankings({int limit = 20}) async {
    final data = await supabase
        .from('profiles')
        .select('id, name, avatar, points, items_found')
        .order('points', ascending: false)
        .limit(limit);

    return (data as List)
        .map((json) => _angelUserFromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// 내 포인트보다 높은 사람 수 + 1 (동점자는 같은 순위).
  Future<int> fetchMyRank(String userId) async {
    final me = await supabase
        .from('profiles')
        .select('points')
        .eq('id', userId)
        .single();
    final myPoints = me['points'] as int? ?? 0;

    final higher = await supabase
        .from('profiles')
        .select('id')
        .gt('points', myPoints)
        .count(CountOption.exact);

    return higher.count + 1;
  }

  AngelUser _angelUserFromJson(Map<String, dynamic> json) {
    return AngelUser(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Unknown',
      avatar: json['avatar'] as String? ?? '',
      itemsFound: json['items_found'] as int? ?? 0,
      points: json['points'] as int? ?? 0,
    );
  }
}
