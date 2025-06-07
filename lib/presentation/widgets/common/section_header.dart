// lib/presentation/widgets/common/section_header.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_utils.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;
  final IconData? actionIcon;
  final Color? titleColor;
  final Color? actionColor;
  final EdgeInsets? padding;

  const SectionHeader({
    Key? key,
    required this.title,
    this.actionText,
    this.onActionTap,
    this.actionIcon,
    this.titleColor,
    this.actionColor,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultPadding = EdgeInsets.symmetric(
      horizontal: ResponsiveUtils.getHorizontalPadding(context),
    );

    return Container(
      padding: padding ?? defaultPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: ResponsiveUtils.getFontSize(context, FontSizeType.title),
              fontWeight: FontWeight.bold,
              color: titleColor ?? AppColors.textPrimary,
            ),
          ),
          
          // Action button
          if (actionText != null || actionIcon != null)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onActionTap?.call();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: (actionColor ?? AppColors.primary).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (actionText != null)
                      Text(
                        actionText!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: actionColor ?? AppColors.primary,
                        ),
                      ),
                    if (actionIcon != null) ...[
                      if (actionText != null) const SizedBox(width: 4),
                      Icon(
                        actionIcon,
                        size: 16,
                        color: actionColor ?? AppColors.primary,
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}