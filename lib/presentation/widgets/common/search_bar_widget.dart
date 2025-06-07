// lib/presentation/widgets/common/search_bar_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconly/iconly.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

class SearchBarWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onVoiceSearch;
  final VoidCallback? onCameraSearch;
  final String? hintText;
  final bool readOnly;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;

  const SearchBarWidget({
    Key? key,
    this.onTap,
    this.onVoiceSearch,
    this.onCameraSearch,
    this.hintText,
    this.readOnly = true,
    this.controller,
    this.onChanged,
    this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: readOnly ? () {
        HapticFeedback.lightImpact();
        onTap?.call();
      } : null,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: AppColors.border.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Search icon
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Icon(
                IconlyLight.search,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
            
            // Search input
            Expanded(
              child: readOnly
                  ? Text(
                      hintText ?? AppStrings.search,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    )
                  : TextField(
                      controller: controller,
                      onChanged: onChanged,
                      onSubmitted: onSubmitted,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        hintText: hintText ?? AppStrings.search,
                        hintStyle: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
            ),
            
            // Action buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Camera search button
                if (onCameraSearch != null)
                  _buildActionButton(
                    icon: IconlyLight.camera,
                    onTap: onCameraSearch!,
                    tooltip: 'Buscar con cámara',
                  ),
                
                // Voice search button
                if (onVoiceSearch != null)
                  _buildActionButton(
                    icon: IconlyLight.voice,
                    onTap: onVoiceSearch!,
                    tooltip: 'Búsqueda por voz',
                  ),
                
                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          width: 36,
          height: 36,
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}