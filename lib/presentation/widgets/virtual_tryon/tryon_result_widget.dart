import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconly/iconly.dart';
import '../../../core/constants/app_colors.dart';

class TryonResultWidget extends StatelessWidget {
  final String resultImageUrl;
  final String originalImageUrl;
  final double confidence;
  final VoidCallback? onSave;
  final VoidCallback? onShare;
  final VoidCallback? onRetry;
  final bool isLoading;

  const TryonResultWidget({
    Key? key,
    required this.resultImageUrl,
    required this.originalImageUrl,
    this.confidence = 0.0,
    this.onSave,
    this.onShare,
    this.onRetry,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Result image with comparison
          _buildImageComparison(context),
          
          // Quality indicator
          _buildQualityIndicator(),
          
          // Action buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildImageComparison(BuildContext context) {
    return Container(
      height: 400,
      child: Stack(
        children: [
          // Result image
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: isLoading
                  ? _buildLoadingPlaceholder()
                  : Image.network(
                      resultImageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return _buildLoadingPlaceholder();
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return _buildErrorPlaceholder();
                      },
                    ),
            ),
          ),
          
          // Before/After toggle
          Positioned(
            top: 16,
            right: 16,
            child: _buildBeforeAfterToggle(),
          ),
          
          // Quality badge
          Positioned(
            top: 16,
            left: 16,
            child: _buildQualityBadge(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'Cargando resultado...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              IconlyLight.danger,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar imagen',
              style: TextStyle(
                color: AppColors.error,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toca para reintentar',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBeforeAfterToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            IconlyLight.swap,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            'Comparar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityBadge() {
    final qualityColor = confidence >= 0.8
        ? AppColors.success
        : confidence >= 0.6
            ? AppColors.warning
            : AppColors.error;
    
    final qualityText = confidence >= 0.8
        ? 'Excelente'
        : confidence >= 0.6
            ? 'Buena'
            : 'Regular';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: qualityColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            IconlyBold.star,
            color: Colors.white,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            qualityText,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Calidad del resultado',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${(confidence * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: confidence,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(
              confidence >= 0.8
                  ? AppColors.success
                  : confidence >= 0.6
                      ? AppColors.warning
                      : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Retry button
          Expanded(
            child: _buildActionButton(
              icon: IconlyLight.delete,
              label: 'Reintentar',
              onTap: () {
                HapticFeedback.lightImpact();
                onRetry?.call();
              },
              isPrimary: false,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Save button
          Expanded(
            child: _buildActionButton(
              icon: IconlyLight.download,
              label: 'Guardar',
              onTap: () {
                HapticFeedback.lightImpact();
                onSave?.call();
              },
              isPrimary: false,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Share button
          Expanded(
            child: _buildActionButton(
              icon: IconlyLight.upload,
              label: 'Compartir',
              onTap: () {
                HapticFeedback.lightImpact();
                onShare?.call();
              },
              isPrimary: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isPrimary ? null : Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isPrimary ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isPrimary ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}