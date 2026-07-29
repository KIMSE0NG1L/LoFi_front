import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../services/chat_service.dart';
import '../services/items_service.dart';
import '../theme/app_theme.dart';
import '../widgets/surfaces.dart';

/// 다른 사람이 등록한 분실 신고를 둘러보고, 도움을 줄 수 있으면 채팅을 거는 화면.
class LostReportsPage extends StatefulWidget {
  const LostReportsPage({super.key});

  @override
  State<LostReportsPage> createState() => _LostReportsPageState();
}

class _LostReportsPageState extends State<LostReportsPage> {
  final ItemsService _itemsService = ItemsService();
  final ChatService _chatService = ChatService();

  List<LostReport> _reports = [];
  bool _loading = true;
  String? _error;
  String _startingChatFor = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final reports = await _itemsService.fetchPublicLostReports();
      if (!mounted) return;
      setState(() => _reports = reports);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _startChat(LostReport report) async {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      context.push('/login');
      return;
    }
    if (report.ownerId == auth.user!.id) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('내가 등록한 신고입니다.')));
      return;
    }

    setState(() => _startingChatFor = report.id);
    try {
      final thread = await _chatService.startLostItemChat(
        lostItemId: report.id,
        currentUserId: auth.user!.id,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      context.push('/chat/${thread.id}');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _startingChatFor = '');
    }
  }

  void _openDetail(LostReport report) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => _DetailSheet(
        report: report,
        starting: _startingChatFor == report.id,
        onChat: () => _startChat(report),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: const Text('분실 신고 둘러보기', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
            onPressed: () => context.push('/register-lost'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? _errorState()
              : _reports.isEmpty
                  ? _emptyState()
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                        itemCount: _reports.length,
                        itemBuilder: (ctx, i) => _reportCard(_reports[i]),
                      ),
                    ),
    );
  }

  Widget _reportCard(LostReport report) {
    final category = categories.firstWhere(
      (c) => c['id'] == report.category,
      orElse: () => {'name': '기타', 'icon': '📦'},
    );

    return GestureDetector(
      onTap: () => _openDetail(report),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: neumorphicDecoration(radius: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
              alignment: Alignment.center,
              child: Text(category['icon'] as String, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(report.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.primary), overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(report.description, style: const TextStyle(color: AppColors.textMuted, fontSize: 12, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.place_outlined, size: 11, color: AppColors.textFaint),
                      const SizedBox(width: 4),
                      Expanded(child: Text(report.location, style: const TextStyle(fontSize: 10, color: AppColors.textFaint), overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ],
              ),
            ),
            if (report.bountyPoints > 0) _bountyBadge(report.bountyPoints),
          ],
        ),
      ),
    );
  }

  Widget _bountyBadge(int points) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.amber.shade200)),
      child: Column(
        children: [
          const Icon(Icons.bolt_rounded, color: Colors.amber, size: 14),
          Text('${points}pt', style: TextStyle(color: Colors.amber.shade800, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _errorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _load, child: const Text('다시 시도')),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📭', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          const Text('등록된 분실 신고가 없습니다', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: AppColors.primary)),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.push('/register-lost'),
            child: const Text('분실물 신고하기'),
          ),
        ],
      ),
    );
  }
}

class _DetailSheet extends StatelessWidget {
  final LostReport report;
  final bool starting;
  final VoidCallback onChat;

  const _DetailSheet({required this.report, required this.starting, required this.onChat});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.black.withOpacity(0.1), borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            Text(report.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
            const SizedBox(height: 4),
            Text('신고자: ${report.ownerName ?? '알 수 없음'}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            if (report.bountyPoints > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(12)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.bolt_rounded, color: Colors.amber, size: 16),
                  const SizedBox(width: 6),
                  Text('현상금 ${report.bountyPoints}pt', style: TextStyle(color: Colors.amber.shade800, fontWeight: FontWeight.bold, fontSize: 13)),
                ]),
              ),
            ],
            const SizedBox(height: 16),
            Text(report.description, style: const TextStyle(color: AppColors.textDark, fontSize: 14, height: 1.6)),
            const SizedBox(height: 12),
            Row(children: [
              const Icon(Icons.place_outlined, size: 14, color: AppColors.textFaint),
              const SizedBox(width: 4),
              Text(report.location, style: const TextStyle(color: AppColors.textFaint, fontSize: 12)),
            ]),
            if (report.reward != null && report.reward!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('사례: ${report.reward}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: starting ? null : onChat,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: starting
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('제가 봤어요! 채팅하기', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
