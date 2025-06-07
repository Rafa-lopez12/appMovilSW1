// lib/presentation/widgets/cart/empty_cart_widget.dart
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconly/iconly.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive_utils.dart';
import '../common/custom_button.dart';

class EmptyCartWidget extends StatelessWidget {
  final VoidCallback? onContinueShopping;
  final VoidCallback? onViewRecommendations;
  final bool showRecommendations;
  final String? customTitle;
  final String? customDescription;
  final IconData? customIcon;

  const EmptyCartWidget({
    Key? key,
    this.onContinueShopping,
    this.onViewRecommendations,
    this.showRecommendations = true,
    this.customTitle,
    this.customDescription,
    this.customIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getHorizontalPadding(context),
        vertical: 32,
      ),
      child: Column(
        children: [
          // Spacer for centering
          SizedBox(height: MediaQuery.of(context).size.height * 0.1),
          
          // Empty cart illustration
          _buildIllustration(),
          
          const SizedBox(height: 32),
          
          // Title and description
          _buildContent(),
          
          const SizedBox(height: 40),
          
          // Action buttons
          _buildActionButtons(context),
          
          if (showRecommendations) ...[
            const SizedBox(height: 40),
            _buildRecommendations(),
          ],
        ],
      ),
    );
  }

  Widget _buildIllustration() {
    return FadeIn(
      duration: const Duration(milliseconds: 800),
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.primary.withOpacity(0.05),
              Colors.transparent,
            ],
          ),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.border,
                width: 2,
              ),
            ),
            child: Icon(
              customIcon ?? IconlyLight.bag_2,
              size: 60,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      delay: const Duration(milliseconds: 200),
      child: Column(
        children: [
          Text(
            customTitle ?? AppStrings.cartEmpty,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          Text(
            customDescription ?? AppStrings.cartEmptyDescription,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      delay: const Duration(milliseconds: 400),
      child: Column(
        children: [
          // Main CTA button
          CustomButton(
            text: AppStrings.continueShopping,
            onPressed: onContinueShopping ?? () => _navigateToCatalog(context),
            icon: IconlyLight.arrow_right,
            size: ButtonSize.large,
          ),
          
          const SizedBox(height: 16),
          
          // Secondary button
          if (showRecommendations)
            CustomButton(
              text: 'Ver productos recomendados',
              onPressed: onViewRecommendations ?? () => _showRecommendations(context),
              type: ButtonType.outline,
              icon: IconlyLight.star,
              size: ButtonSize.medium,
            ),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      delay: const Duration(milliseconds: 600),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  IconlyLight.star,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Mientras tanto...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            _buildQuickAction(
              icon: IconlyLight.category,
              title: 'Explorar categorías',
              description: 'Descubre productos por categoría',
              onTap: () => _navigateToCategories(),
            ),
            
            const SizedBox(height: 12),
            
            _buildQuickAction(
              icon: IconlyLight.camera,
              title: 'Búsqueda visual',
              description: 'Encuentra productos con tu cámara',
              onTap: () => _navigateToAISearch(),
            ),
            
            const SizedBox(height: 12),
            
            _buildQuickAction(
              icon: IconlyLight.heart,
              title: 'Tus favoritos',
              description: 'Revisa productos que te gustaron',
              onTap: () => _navigateToFavorites(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.border.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: AppColors.primary,
              ),
            ),
            
            const SizedBox(width: 12),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            Icon(
              IconlyLight.arrow_right_2,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCatalog(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/main');
  }

  void _showRecommendations(BuildContext context) {
    // TODO: Implementar navegación a recomendaciones
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recomendaciones próximamente')),
    );
  }

  void _navigateToCategories() {
    // TODO: Implementar navegación a categorías
  }

  void _navigateToAISearch() {
    // TODO: Implementar navegación a búsqueda IA
  }

  void _navigateToFavorites() {
    // TODO: Implementar navegación a favoritos
  }
}

// Widget específico para cuando no hay resultados de búsqueda
class EmptySearchWidget extends StatelessWidget {
  final String query;
  final VoidCallback? onClearSearch;
  final VoidCallback? onTryAgain;

  const EmptySearchWidget({
    Key? key,
    required this.query,
    this.onClearSearch,
    this.onTryAgain,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyCartWidget(
      customIcon: IconlyLight.search,
      customTitle: 'No encontramos resultados',
      customDescription: 'No hay productos que coincidan con "$query". Intenta con otros términos de búsqueda.',
      onContinueShopping: onClearSearch,
      showRecommendations: false,
    );
  }
}

// Widget para cuando el carrito está temporalmente indisponible
class CartUnavailableWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? errorMessage;

  const CartUnavailableWidget({
    Key? key,
    this.onRetry,
    this.errorMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyCartWidget(
      customIcon: IconlyLight.info_circle,
      customTitle: 'Carrito no disponible',
      customDescription: errorMessage ?? 'Hay un problema temporal con el carrito. Por favor intenta de nuevo.',
      onContinueShopping: onRetry,
      showRecommendations: false,
    );
  }
}