import 'package:flutter/material.dart';

import '../services/kakao_location_service.dart';
import '../theme/app_theme.dart';

/// 실제 존재하는 주소/장소를 검색해서 선택하는 화면.
/// Navigator.pop(context, KakaoPlace) 로 결과를 돌려준다.
class LocationSearchPage extends StatefulWidget {
  const LocationSearchPage({super.key});

  @override
  State<LocationSearchPage> createState() => _LocationSearchPageState();
}

class _LocationSearchPageState extends State<LocationSearchPage> {
  final _service = KakaoLocationService();
  final _searchCtrl = TextEditingController();

  List<KakaoPlace> _results = [];
  bool _loading = false;
  bool _searched = false;
  String? _error;

  Future<void> _search() async {
    final query = _searchCtrl.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
      _searched = true;
    });
    try {
      final results = await _service.search(query);
      if (!mounted) return;
      setState(() => _results = results);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('장소 검색', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: '예) 강남역, 서울시 강남대로 396',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward, color: AppColors.primary),
                  onPressed: _search,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMuted)),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: _search, child: const Text('다시 시도')),
            ],
          ),
        ),
      );
    }
    if (!_searched) {
      return const Center(
        child: Text('장소나 주소를 검색해주세요', style: TextStyle(color: AppColors.textFaint, fontSize: 13)),
      );
    }
    if (_results.isEmpty) {
      return const Center(
        child: Text('검색 결과가 없습니다', style: TextStyle(color: AppColors.textFaint, fontSize: 13)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: _results.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: Colors.black.withOpacity(0.05)),
      itemBuilder: (ctx, i) {
        final place = _results[i];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
          leading: const Icon(Icons.place_outlined, color: AppColors.primary),
          title: Text(place.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textDark)),
          subtitle: Text(place.address, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          onTap: () => Navigator.of(context).pop(place),
        );
      },
    );
  }
}
