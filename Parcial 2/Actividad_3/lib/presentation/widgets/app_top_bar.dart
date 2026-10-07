import 'package:flutter/material.dart';
import 'package:pizzeria/theme/app_colors.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBack;
  final Widget? trailing;
  final Color backgroundColor;

  const AppTopBar({
    super.key,
    this.title = 'PizzApp',
    this.showBackButton = true,
    this.onBack,
    this.trailing,
    this.backgroundColor = Colors.transparent,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      centerTitle: true,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back,
                  color: AppColors.primary, size: 24),
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
            )
          : null,
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      actions: [
        if (trailing != null)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: trailing!),
          ),
      ],
    );
  }
}