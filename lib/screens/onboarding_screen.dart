import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _current = 0;
  final PageController _controller = PageController();

  final List<_SlideData> _slides = [
    _SlideData(
      emoji: '🎯',
      title: '옛다 띱!',
      subtitle: '분실물 퀴즈 매칭 서비스',
      description: '잃어버린 물건을 찾고,\n선행을 게임처럼 즐기세요.',
      bg: const Color(0xFF0D0D0D),
      textColor: Colors.white,
      accentColor: const Color(0xFFF5C842),
      icon: null,
    ),
    _SlideData(
      emoji: null,
      title: '퀴즈로 증명하세요',
      subtitle: '스마트한 인증 시스템',
      description: '습득자가 분실물 특징으로 문제를 출제하면,\n진짜 주인만 정답을 맞출 수 있어요.',
      bg: const Color(0xFFF7F6F3),
      textColor: const Color(0xFF0D0D0D),
      accentColor: const Color(0xFF0D0D0D),
      icon: '🧩',
      iconBg: const Color(0xFF0D0D0D),
    ),
    _SlideData(
      emoji: null,
      title: '오늘의 천사 랭킹',
      subtitle: '선행이 쌓일수록 올라가요',
      description: '분실물을 돌려주면 포인트를 획득하고\n랭킹에서 최고의 천사가 되어보세요.',
      bg: const Color(0xFFF7F6F3),
      textColor: const Color(0xFF0D0D0D),
      accentColor: const Color(0xFFF5C842),
      icon: '🏆',
      iconBg: const Color(0xFFF5C842),
    ),
    _SlideData(
      emoji: null,
      title: '지도로 한눈에',
      subtitle: '근처 분실물을 찾아보세요',
      description: '내 주변에서 발견된 분실물을\n지도에서 바로 확인할 수 있어요.',
      bg: const Color(0xFFF7F6F3),
      textColor: const Color(0xFF0D0D0D),
      accentColor: const Color(0xFF4A90D9),
      icon: '📍',
      iconBg: const Color(0xFF4A90D9),
    ),
  ];

  Future<void> _done() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) context.go('/');
  }

  void _next() {
    if (_current < _slides.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    } else {
      _done();
    }
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_current];
    final isLast = _current == _slides.length - 1;

    return Material(
      color: Colors.transparent,
      child: AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      color: slide.bg,
      child: SafeArea(
        child: Stack(
          children: [
            // Skip button
            if (!isLast)
              Positioned(
                top: 12,
                right: 16,
                child: GestureDetector(
                  onTap: _done,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: slide.textColor == Colors.white ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('건너뛰기', style: TextStyle(color: slide.textColor, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            Column(
              children: [
                // Slides
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (i) => setState(() => _current = i),
                    itemCount: _slides.length,
                    itemBuilder: (ctx, i) => _buildSlide(_slides[i]),
                  ),
                ),
                // Bottom controls
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Column(
                    children: [
                      // Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_slides.length, (i) {
                          final active = i == _current;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: active ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: active
                                  ? (slide.textColor == Colors.white ? const Color(0xFFF5C842) : const Color(0xFF0D0D0D))
                                  : (slide.textColor == Colors.white ? Colors.white.withOpacity(0.25) : Colors.black.withOpacity(0.15)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 24),
                      // CTA
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _next,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: slide.textColor == Colors.white ? const Color(0xFFF5C842) : const Color(0xFF0D0D0D),
                            foregroundColor: slide.textColor == Colors.white ? const Color(0xFF0D0D0D) : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(isLast ? '시작하기' : '다음', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(width: 6),
                              const Icon(Icons.chevron_right, size: 20),
                            ],
                          ),
                        ),
                      ),
                      if (isLast) ...[
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: _done,
                          child: Text(
                            '이미 계정이 있어요',
                            style: const TextStyle(color: Color(0xFF8A8880), fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildSlide(_SlideData slide) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 60, 32, 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          if (slide.emoji != null)
            Container(
              width: 96, height: 96,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(child: Text(slide.emoji!, style: const TextStyle(fontSize: 44))),
            )
          else if (slide.icon != null)
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(color: slide.iconBg, borderRadius: BorderRadius.circular(24)),
              child: Center(child: Text(slide.icon!, style: const TextStyle(fontSize: 36))),
            ),
          const SizedBox(height: 32),
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: slide.accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              slide.subtitle,
              style: TextStyle(
                color: slide.accentColor == const Color(0xFF0D0D0D) ? slide.accentColor : slide.accentColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            slide.title,
            style: TextStyle(
              color: slide.textColor,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            slide.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: slide.textColor == Colors.white ? Colors.white.withOpacity(0.55) : const Color(0xFF8A8880),
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideData {
  final String? emoji;
  final String title;
  final String subtitle;
  final String description;
  final Color bg;
  final Color textColor;
  final Color accentColor;
  final String? icon;
  final Color? iconBg;

  const _SlideData({
    this.emoji,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.bg,
    required this.textColor,
    required this.accentColor,
    this.icon,
    this.iconBg,
  });
}
