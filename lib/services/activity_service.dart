import '../models/models.dart';
import 'supabase_client.dart';

class ActivityService {
  Future<List<ActivityItem>> fetchRecent({int limit = 10}) async {
    final data = await supabase.rpc('get_recent_activity', params: {'p_limit': limit});
    return (data as List)
        .map((json) => _activityFromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<ActivityItem>> fetchMine({int limit = 20}) async {
    final uid = currentUserId;
    if (uid == null) throw const AppException('로그인이 필요합니다.');

    final results = await Future.wait([
      supabase
          .from('found_items')
          .select('id, title, location, created_at')
          .eq('finder_id', uid)
          .order('created_at', ascending: false)
          .limit(limit),
      supabase
          .from('lost_items')
          .select('id, title, location, created_at')
          .eq('owner_id', uid)
          .order('created_at', ascending: false)
          .limit(limit),
      supabase
          .from('purchases')
          .select('id, created_at, shop_items(id, title, emoji)')
          .eq('user_id', uid)
          .order('created_at', ascending: false)
          .limit(limit),
    ]);

    final found = results[0] as List;
    final lost = results[1] as List;
    final purchases = results[2] as List;

    final activities = <ActivityItem>[
      ...found.map((raw) {
        final item = raw as Map<String, dynamic>;
        return ActivityItem(
          id: 'found-${item['id']}',
          type: 'found_registered',
          title: '${item['title']} 등록',
          description: item['location'] as String? ?? '',
          icon: 'inventory',
          location: item['location'] as String?,
          pointsDelta: null,
          createdAt: DateTime.tryParse(item['created_at'] as String? ?? '') ?? DateTime.now(),
        );
      }),
      ...lost.map((raw) {
        final item = raw as Map<String, dynamic>;
        return ActivityItem(
          id: 'lost-${item['id']}',
          type: 'lost_registered',
          title: '${item['title']} 신고',
          description: item['location'] as String? ?? '',
          icon: 'search',
          location: item['location'] as String?,
          pointsDelta: 0,
          createdAt: DateTime.tryParse(item['created_at'] as String? ?? '') ?? DateTime.now(),
        );
      }),
      ...purchases.map((raw) {
        final purchase = raw as Map<String, dynamic>;
        final shopItem = purchase['shop_items'] as Map<String, dynamic>?;
        return ActivityItem(
          id: 'purchase-${purchase['id']}',
          type: 'shop_purchased',
          title: '${shopItem?['title'] ?? '상품'} 교환',
          description: '포인트 상점',
          icon: 'shopping_bag',
          location: null,
          pointsDelta: null,
          createdAt: DateTime.tryParse(purchase['created_at'] as String? ?? '') ?? DateTime.now(),
        );
      }),
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return activities.take(limit).toList();
  }

  ActivityItem _activityFromJson(Map<String, dynamic> json) {
    return ActivityItem(
      id: json['id'] as String? ?? '',
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
