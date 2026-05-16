import '../models/models.dart';
import 'api_client.dart';

class ShopService {
  ShopService(this._api);

  final ApiClient _api;

  Future<List<ShopItem>> fetchItems() async {
    final data = await _api.get('/shop') as List<dynamic>;
    return data
        .map((json) => _shopItemFromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> purchase(String shopItemId) async {
    await _api.post('/shop/purchase', body: {'shopItemId': shopItemId});
  }

  ShopItem _shopItemFromJson(Map<String, dynamic> json) {
    return ShopItem(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      cost: json['cost'] as int? ?? 0,
      emoji: json['emoji'] as String? ?? '',
      category: json['category'] as String? ?? '',
      stock: json['stock'] as int? ?? 0,
    );
  }
}
