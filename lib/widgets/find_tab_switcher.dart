import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';

/// "찾기" 영역 상단에서 습득물(찾았어요) / 분실 신고(찾아주세요) 목록을 오가는 탭.
///
/// [onChanged]를 주면 라우트 이동 없이 그 콜백만 호출한다(같은 페이지 안에서
/// 즉시 전환하는 용도). 안 주면 기존처럼 `/lost-items` ↔ `/lost-reports`로 이동한다.
class FindTabSwitcher extends StatelessWidget {
  final bool isFoundActive;
  final ValueChanged<bool>? onChanged;

  const FindTabSwitcher({super.key, required this.isFoundActive, this.onChanged});

  void _select(BuildContext context, bool toFound) {
    if (onChanged != null) {
      onChanged!(toFound);
    } else {
      context.go(toFound ? '/lost-items' : '/lost-reports');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: isFoundActive ? Alignment.centerLeft : Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.interactive,
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: _tab(
                    context,
                    label: '찾았어요',
                    active: isFoundActive,
                    onTap: () {
                      if (!isFoundActive) _select(context, true);
                    },
                  ),
                ),
                Expanded(
                  child: _tab(
                    context,
                    label: '찾아주세요',
                    active: !isFoundActive,
                    onTap: () {
                      if (isFoundActive) _select(context, false);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tab(
    BuildContext context, {
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 220),
        style: TextStyle(
          color: active ? Colors.white : AppColors.textMuted,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        child: Center(child: Text(label)),
      ),
    );
  }
}
