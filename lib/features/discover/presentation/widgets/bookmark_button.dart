import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

/// Reusable animated bookmark button for plant articles and guides.
class BookmarkButton extends StatelessWidget {
  const BookmarkButton({
    super.key,
    required this.isBookmarked,
    required this.onTap,
    this.size = 22.0,
    this.padding = 8.0,
    this.backgroundColor,
  });

  final bool isBookmarked;
  final VoidCallback onTap;
  final double size;
  final double padding;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white.withValues(alpha: 0.85),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            size: size,
            color: isBookmarked ? AppColors.primaryGreen : AppColors.secondaryText,
          ),
        ),
      ),
    );
  }
}
