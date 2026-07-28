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
