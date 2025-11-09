import 'package:flutter/material.dart';
import '../config/custom_colors.dart';

/// A reusable AppBar with consistent brand green background and high-contrast
/// dark foreground that meets WCAG AA requirements (>3:1 for large text/icons).
///
/// The brand green #74B225 with white text only provides ~2.6:1 contrast ratio,
/// which fails WCAG requirements. Using black/dark foreground provides >4.5:1
/// contrast for better accessibility.
class BrandedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  const BrandedAppBar({
    super.key,
    required this.title,
    this.actions,
    this.bottom,
    this.leading,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    // Use black for high contrast against brand green (#74B225)
    // This provides >4.5:1 contrast ratio (WCAG AA compliant)
    const foregroundColor = Colors.black87;

    return AppBar(
      backgroundColor: brandGreen,
      foregroundColor: foregroundColor,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      iconTheme: const IconThemeData(color: foregroundColor),
      title: Text(
        title,
        style: const TextStyle(
          color: foregroundColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );
}
