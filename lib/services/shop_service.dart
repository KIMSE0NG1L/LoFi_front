import '../models/models.dart';
import 'supabase_client.dart';

class ShopService {
  Future<List<ShopItem>> fetchItems() async {
    final data = await supabase.from('shop_items').select().gt('stock', 0);
    return (data as List)
        .map((json) => _shopItemFromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> purchase(String shopItemId) async {
    try {
      await supabase.rpc('purchase_shop_item', params: {'p_shop_item_id': shopItemId});
    } catch (e) {
      final message = e.toString();
      if (message.contains('ITEM_NOT_FOUND')) throw const AppException('상품을 찾을 수 없습니다.');
      if (message.contains('OUT_OF_STOCK')) throw const AppException('재고가 없습니다.');
      if (message.contains('INSUFFICIENT_POINTS')) throw const AppException('포인트가 부족합니다.');
      rethrow;
    }
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
