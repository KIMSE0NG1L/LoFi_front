import '../models/models.dart';
import 'api_client.dart';

class RankingService {
  RankingService(this._api);

  final ApiClient _api;

  Future<List<AngelUser>> fetchRankings({int limit = 20}) async {
    final data =
        await _api.get('/ranking', query: {'limit': '$limit'}) as List<dynamic>;
    return data
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
