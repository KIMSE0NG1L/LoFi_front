import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// 팝업/모달/바텀시트 공용 글래스모피즘 컨테이너.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final double blur;
  final double opacity;

  /// 유리 위에 덧씌울 선택적 그라데이션 (예: 하단만 어둡게).
  final Gradient? overlayGradient;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.padding,
    this.blur = 20,
    this.opacity = 0.65,
    this.overlayGradient,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            borderRadius: borderRadius,
            border: Border.all(color: Colors.white.withOpacity(0.6)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              if (overlayGradient != null)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(gradient: overlayGradient),
                  ),
                ),
              Padding(
                padding: padding ?? EdgeInsets.zero,
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 카드 공용 뉴모피즘(soft UI) 데코레이션.
/// 배경과 같은 계열 색(AppColors.background) 위에 밝은/어두운 이중 그림자로
/// 눌리거나 떠 있는 느낌을 낸다. [inset]이면 안쪽으로 눌린 느낌.
BoxDecoration neumorphicDecoration({
  double radius = 20,
  bool inset = false,
  Color color = AppColors.background,
}) {
  final light = BoxShadow(
    color: Colors.white.withOpacity(0.9),
    offset: const Offset(-6, -6),
    blurRadius: 14,
    spreadRadius: inset ? -6 : 0,
  );
  final dark = BoxShadow(
    color: const Color(0xFFB8BCC4).withOpacity(0.55),
    offset: const Offset(6, 6),
    blurRadius: 14,
    spreadRadius: inset ? -6 : 0,
  );
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [light, dark],
  );
}
