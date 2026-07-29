import 'dart:convert';

import 'package:http/http.dart' as http;

// 카카오 디벨로퍼스(developers.kakao.com) REST API 키.
// `--dart-define=KAKAO_REST_API_KEY=...` 로 오버라이드 가능 (supabase_client.dart와 동일한 패턴).
const String _defaultKakaoRestApiKey = 'd334b4d6066d73d5ae5f94e25c5514f8';

String get _kakaoRestApiKey {
  const fromEnv = String.fromEnvironment('KAKAO_REST_API_KEY');
  return fromEnv.isNotEmpty ? fromEnv : _defaultKakaoRestApiKey;
}

class KakaoPlace {
  final String name;
  final String address;
  final double lat;
  final double lng;

  const KakaoPlace({
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
  });
}

class KakaoLocationService {
  static const _endpoint = 'https://dapi.kakao.com/v2/local/search/keyword.json';

  /// 장소/주소 키워드로 검색 — 도로명 주소 위주(place_name)로 매칭되고
  /// 좌표(x=경도, y=위도)가 함께 내려온다.
  Future<List<KakaoPlace>> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final uri = Uri.parse(_endpoint).replace(queryParameters: {
      'query': trimmed,
      'size': '15',
    });

    final res = await http.get(
      uri,
      headers: {'Authorization': 'KakaoAK $_kakaoRestApiKey'},
    );

    if (res.statusCode != 200) {
      throw Exception('장소 검색에 실패했습니다 (${res.statusCode})');
    }

    final body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    final documents = body['documents'] as List? ?? [];

    return documents.map((doc) {
      final json = doc as Map<String, dynamic>;
      return KakaoPlace(
        name: json['place_name'] as String? ?? '',
        address: (json['road_address_name'] as String?)?.isNotEmpty == true
            ? json['road_address_name'] as String
            : json['address_name'] as String? ?? '',
        lat: double.tryParse(json['y'] as String? ?? '') ?? 0,
        lng: double.tryParse(json['x'] as String? ?? '') ?? 0,
      );
    }).toList();
  }
}
