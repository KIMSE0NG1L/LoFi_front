import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final bool showMenu;
  final VoidCallback? onMenuTap;
  final List<Widget>? actions;

  const AppHeader({
    super.key,
    required this.title,
    this.showBack = false,
    this.showMenu = false,
    this.onMenuTap,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      automaticallyImplyLeading: false,
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textDark,
          fontWeight: FontWeight.bold,
          fontSize: 20,
          letterSpacing: -0.5,
        ),
      ),
      actions: actions ??
          (showMenu
              ? [
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: AppColors.textDark),
                    onPressed: onMenuTap,
                  ),
                ]
              : null),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
