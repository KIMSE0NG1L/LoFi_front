import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../services/api_client.dart';
import '../services/chat_service.dart';
import '../theme/app_theme.dart';

class QuizModal extends StatefulWidget {
  final LostItem item;

  const QuizModal({super.key, required this.item});

  @override
  State<QuizModal> createState() => _QuizModalState();
}

class _QuizModalState extends State<QuizModal> {
  final ChatService _chatService = ChatService(ApiClient.instance);
  String _step = 'intro'; // intro | quiz | success | failed
  Quiz? _currentQuiz;
  int? _currentQuizIndex;
  List<int> _attempts = [];
  int? _selectedAnswer;
  String _textAnswer = '';
  List<int> _usedQuizzes = [];
  bool _startingChat = false;

  @override
  void initState() {
    super.initState();
    // Check if already failed (simplified: just use in-memory state)
  }

  void _startQuiz() {
    _pickRandomQuiz();
    if (_currentQuiz != null) {
      setState(() => _step = 'quiz');
    }
  }

  Future<void> _startChat() async {
    final auth = context.read<AuthProvider>();
    final currentUserId = auth.user?.id;
    final finderId = widget.item.finderId;

    if (!auth.isLoggedIn || currentUserId == null || currentUserId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다.')));
      return;
    }
    if (finderId == null || finderId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('습득자 정보를 찾을 수 없습니다.')));
      return;
    }
    if (finderId == currentUserId) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('내가 등록한 물건입니다.')));
      return;
    }

    setState(() => _startingChat = true);
    try {
      final thread = await _chatService.createThread(
        foundItemId: widget.item.id,
        otherUserId: finderId,
        currentUserId: currentUserId,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      context.push('/chat/${thread.id}');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _startingChat = false);
    }
  }

  void _pickRandomQuiz() {
    final available = List.generate(
      widget.item.quizzes.length,
      (i) => i,
    ).where((i) => !_usedQuizzes.contains(i)).toList();

    if (available.isEmpty) {
      setState(() => _step = 'failed');
      return;
    }

    available.shuffle();
    final index = available.first;
    setState(() {
      _currentQuizIndex = index;
      _currentQuiz = widget.item.quizzes[index];
      _selectedAnswer = null;
      _textAnswer = '';
    });
  }

  Future<void> _handleSubmit() async {
    if (_currentQuiz == null || _currentQuizIndex == null) return;

    final quizId = _currentQuiz!.id;
    if (quizId == null) return;

    final dynamic answer = _currentQuiz!.type == 'multiple'
        ? _selectedAnswer
        : _textAnswer.trim();

    _attempts.add(_currentQuizIndex!);
    _usedQuizzes.add(_currentQuizIndex!);

    try {
      final data = await ApiClient.instance.post(
        '/quiz/attempt',
        body: {
          'foundItemId': widget.item.id,
          'quizId': quizId,
          'answer': answer,
        },
      ) as Map<String, dynamic>;

      if (!mounted) return;
      final isCorrect = data['correct'] == true;

      if (isCorrect) {
        setState(() => _step = 'success');
      } else {
        if (_attempts.length >= 3) {
          setState(() => _step = 'failed');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('틀렸습니다. 다른 문제로 다시 도전하세요!')),
          );
          _pickRandomQuiz();
          setState(() {});
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary.withOpacity(0.95),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.item.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 17,
              ),
            ),
            const Text(
              '소유권 인증',
              style: TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
        actions: _step == 'quiz'
            ? [
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${3 - _attempts.length}/3',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    switch (_step) {
      case 'intro':
        return _buildIntro();
      case 'quiz':
        return _buildQuiz();
      case 'success':
        return _buildSuccess();
      case 'failed':
        return _buildFailed();
      default:
        return const SizedBox();
    }
  }

  Widget _buildIntro() {
    return Column(
      children: [
        if (widget.item.imageUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.network(
              widget.item.imageUrl!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(height: 200, color: AppColors.subtle),
            ),
          ),
        const SizedBox(height: 20),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Image.asset(
              'assets/app_logo_T_white_N.png',
              width: 61,
              height: 61,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          '퀴즈 인증 시작',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.item.description,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 14,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5C842).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.shuffle_rounded,
                      color: Color(0xFFF5C842),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '인증 방식',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '랜덤 퀴즈 3회 도전',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '• 문제는 랜덤으로 출제됩니다\n• 최대 3번까지 도전 가능\n• 1문제만 맞추면 인증 성공!',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _startQuiz,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('퀴즈 시작하기', style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(width: 8),
                Icon(Icons.emoji_events_outlined, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuiz() {
    if (_currentQuiz == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '도전 ${_attempts.length + 1}/3',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '남은 기회: ${3 - _attempts.length}번',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (_attempts.length + 1) / 3,
            backgroundColor: AppColors.subtle,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5C842),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        'Q',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _currentQuiz!.type == 'multiple' ? '객관식' : '주관식',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _currentQuiz!.question,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              if (_currentQuiz!.type == 'multiple')
                ...List.generate(_currentQuiz!.options!.length, (i) {
                  final isSelected = _selectedAnswer == i;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedAnswer = i),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.black.withOpacity(0.08),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${i + 1}. ',
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white54
                                  : AppColors.textFaint,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _currentQuiz!.options![i],
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.primary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                })
              else
                TextField(
                  onChanged: (v) => setState(() => _textAnswer = v),
                  decoration: InputDecoration(
                    hintText: '정답을 입력하세요',
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: Colors.black.withOpacity(0.06),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: Colors.black.withOpacity(0.06),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: Colors.black.withOpacity(0.2),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                (_currentQuiz!.type == 'multiple'
                    ? _selectedAnswer != null
                    : _textAnswer.trim().isNotEmpty)
                ? _handleSubmit
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.subtle,
              foregroundColor: Colors.white,
              disabledForegroundColor: AppColors.textFaint,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text(
              '정답 제출하기',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess() {
    return Column(
      children: [
        const SizedBox(height: 32),
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(
            Icons.check_circle_outline,
            color: Colors.white,
            size: 56,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          '인증 성공! 🎉',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '축하합니다! 분실물 주인이 확인되었습니다.\n습득자와 채팅을 시작하세요.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 14,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_events, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Text(
                  '+50 포인트 획득!',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _startingChat ? null : _startChat,
            icon: _startingChat
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.chat_bubble_outline, size: 18),
            label: Text(
              '채팅 시작하기',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              side: BorderSide(color: Colors.black.withOpacity(0.08), width: 2),
            ),
            child: const Text(
              '나중에 하기',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFailed() {
    return Column(
      children: [
        const SizedBox(height: 32),
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(Icons.lock_outline, color: Colors.white, size: 56),
        ),
        const SizedBox(height: 20),
        const Text(
          '인증 실패',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '3회 모두 실패했습니다.\n더 이상 이 분실물에 도전할 수 없습니다.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 14,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.red.shade100),
          ),
          child: Column(
            children: [
              Icon(Icons.cancel_outlined, color: Colors.red.shade400, size: 48),
              const SizedBox(height: 12),
              Text(
                '본인 소유가 아닌 것으로 확인되었습니다',
                style: TextStyle(
                  color: Colors.red.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text(
              '확인',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
