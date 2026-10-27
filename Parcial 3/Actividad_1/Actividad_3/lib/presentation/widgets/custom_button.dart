import 'package:flutter/material.dart';
import 'package:pizzeria/theme/app_colors.dart';

enum ButtonVariant { filled, outlined, text }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? textColor;
  final double borderRadius;
  final Widget? icon;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.filled,
    this.width = double.infinity,
    this.height = 54,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 28,
    this.icon,
    this.isLoading = false,
  });

  Widget _spinner(Color color) => SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final action = isLoading ? null : onPressed;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    );

    switch (variant) {
      case ButtonVariant.outlined:
        final color = textColor ?? AppColors.primary;
        return SizedBox(
          width: width,
          height: height,
          child: OutlinedButton(
            onPressed: action,
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: backgroundColor ?? AppColors.primary,
                width: 1.5,
              ),
              shape: shape,
            ),
            child: isLoading
                ? _spinner(color)
                : Text(text,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: color)),
          ),
        );

      case ButtonVariant.text:
        final color = textColor ?? AppColors.primary;
        return TextButton(
          onPressed: action,
          child: isLoading
              ? _spinner(color)
              : Text(text,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: color)),
        );

      case ButtonVariant.filled:
        return SizedBox(
          width: width,
          height: height,
          child: ElevatedButton(
            onPressed: action,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor ?? AppColors.primary,
              elevation: 0,
              shape: shape,
            ),
            child: isLoading
                ? _spinner(Colors.white)
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[icon!, const SizedBox(width: 8)],
                      Text(text,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textColor ?? Colors.white)),
                    ],
                  ),
          ),
        );
    }
  }
}