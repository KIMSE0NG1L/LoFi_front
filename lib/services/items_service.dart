import 'dart:convert';

import '../models/models.dart';
import 'api_client.dart';

class ItemsResult {
  final List<LostItem> items;
  final int total;
  final int page;
  final int totalPages;

  const ItemsResult({
    required this.items,
    required this.total,
    required this.page,
    required this.totalPages,
  });
}

class ItemsService {
  ItemsService(this._api);

  final ApiClient _api;

  Future<ItemsResult> fetchItems({
    String? category,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final query = <String, String>{
      'page': '$page',
      'limit': '$limit',
      if (category != null && category.isNotEmpty) 'category': category,
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final data = await _api.get('/items', query: query) as Map<String, dynamic>;
    final rawItems = data['items'] as List<dynamic>? ?? [];

    return ItemsResult(
      items: rawItems
          .map((json) => _lostItemFromJson(json as Map<String, dynamic>))
          .toList(),
      total: data['total'] as int? ?? rawItems.length,
      page: data['page'] as int? ?? page,
      totalPages: data['totalPages'] as int? ?? 1,
    );
  }

  Future<List<LostItem>> fetchRecent({int limit = 5}) async {
    final result = await fetchItems(limit: limit);
    return result.items;
  }

  Future<List<LostItem>> fetchMine() async {
    final data = await _api.get('/items/mine') as List<dynamic>;
    return data
        .map((json) => _lostItemFromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<LostItem>> fetchFavorites() async {
    final data = await _api.get('/items/favorites/mine') as List<dynamic>;
    return data
        .map((json) => _lostItemFromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<bool> toggleFavorite(String itemId) async {
    final data =
        await _api.post('/items/$itemId/favorites') as Map<String, dynamic>;
    return data['favorited'] == true;
  }

  Future<LostItem> createFoundItem({
    required String category,
    required String title,
    required String description,
    required String location,
    required List<Map<String, dynamic>> quizzes,
    double mapX = 0,
    double mapY = 0,
  }) async {
    final data =
        await _api.post(
              '/items',
              body: {
                'category': category,
                'title': title,
                'description': description,
                'location': location,
                'mapX': mapX,
                'mapY': mapY,
                'quizzes': _encodeQuizzes(quizzes),
              },
            )
            as Map<String, dynamic>;

    return _lostItemFromJson(data);
  }

  String _encodeQuizzes(List<Map<String, dynamic>> quizzes) {
    final normalized = quizzes
        .map(
          (quiz) => {
            'question': quiz['question'],
            'type': quiz['type'] ?? 'text',
            'options': quiz['options'],
            'correctAnswer': quiz['correctAnswer'],
          },
        )
        .toList();
    return jsonEncode(normalized);
  }

  LostItem _lostItemFromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] is Map<String, dynamic>
        ? json['profiles'] as Map<String, dynamic>
        : null;

    return LostItem(
      id: json['id'] as String,
      category: json['category'] as String? ?? 'etc',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      quizzes: _quizzesFromJson(json['quizzes']),
      finderId: json['finder_id'] as String? ?? profile?['id'] as String?,
      foundBy: profile?['name'] as String?,
      location: json['location'] as String? ?? '',
      mapPos: MapPos(
        x: _numToDouble(json['map_x']),
        y: _numToDouble(json['map_y']),
      ),
    );
  }

  List<Quiz> _quizzesFromJson(dynamic value) {
    if (value is! List) return const [];

    return value.map((item) {
      final json = item as Map<String, dynamic>;
      final options = json['options'];
      return Quiz(
        question: json['question'] as String? ?? '',
        type: json['type'] as String? ?? 'text',
        options: options is List ? options.map((v) => '$v').toList() : null,
        correctAnswer: json['correct_answer'],
      );
    }).toList();
  }

  double _numToDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0;
  }
}
