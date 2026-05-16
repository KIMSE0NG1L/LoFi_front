import '../models/models.dart';
import 'api_client.dart';

class ActivityService {
  ActivityService(this._api);

  final ApiClient _api;

  Future<List<ActivityItem>> fetchRecent({int limit = 10}) async {
    final data =
        await _api.get('/activity/recent', query: {'limit': '$limit'})
            as List<dynamic>;
    return data
        .map((json) => _activityFromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<ActivityItem>> fetchMine({int limit = 20}) async {
    final data =
        await _api.get('/activity/mine', query: {'limit': '$limit'})
            as List<dynamic>;
    return data
        .map((json) => _activityFromJson(json as Map<String, dynamic>))
        .toList();
  }

  ActivityItem _activityFromJson(Map<String, dynamic> json) {
    return ActivityItem(
      id: json['id'] as String,
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      location: json['location'] as String?,
      pointsDelta: json['points_delta'] as int?,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
