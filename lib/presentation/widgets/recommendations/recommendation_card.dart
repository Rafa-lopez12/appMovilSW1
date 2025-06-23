// lib/presentation/widgets/recommendations/recommendation_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconly/iconly.dart';
import 'package:animate_do/animate_do.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../data/models/recommendation/recommendation_model.dart';

class RecommendationCard extends StatelessWidget {
  final ProductRecommendation recommendation;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final bool showAIBadge;
  final bool showScore;
  final bool compact;

  const RecommendationCard({
    Key? key,
    required this.recommendation,
    this.onTap,
    this.onAddToCart,
    this.showAIBadge = true,
    this.showScore = false,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        width: compact ? 160 : 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(context),
            _buildContentSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Stack(
      children: [
        // Product Image
        Container(
          height: compact ? 140 : 160,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            color: AppColors.background,
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: recommendation.mainImage.isNotEmpty
                ? Image.network(
                    recommendation.mainImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildImagePlaceholder();
                    },
                  )
                : _buildImagePlaceholder(),
          ),
        ),

        // AI Badge
        if (showAIBadge)
          Positioned(
            top: 8,
            left: 8,
            child: FadeIn(
              duration: const Duration(milliseconds: 600),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.accent, AppColors.primary],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      IconlyBold.star,
                      size: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'IA',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Score Badge
        if (showScore && recommendation.score > 0)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                recommendation.scorePercentage,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

        // Tags
        if (recommendation.tags.isNotEmpty)
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Wrap(
              spacing: 4,
              children: recommendation.tags.take(2).map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getTagColor(tag).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildContentSection(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Name
            Text(
              recommendation.name,
              style: TextStyle(
                fontSize: compact ? 13 : 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 4),
            
            // Category
            Text(
              recommendation.category,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Price
            Text(
              recommendation.priceRange,
              style: TextStyle(
                fontSize: compact ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            
            if (!compact) ...[
              const SizedBox(height: 8),
              
              // Confidence indicator
              Row(
                children: [
                  Icon(
                    IconlyLight.shield_done,
                    size: 12,
                    color: _getConfidenceColor(),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    recommendation.confidenceLevel,
                    style: TextStyle(
                      fontSize: 10,
                      color: _getConfidenceColor(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
            
            const Spacer(),
            
            // Add to Cart Button
            if (onAddToCart != null)
              SizedBox(
                width: double.infinity,
                height: 32,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onAddToCart?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        IconlyLight.bag,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Agregar',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Icon(
          IconlyLight.image,
          size: 40,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Color _getTagColor(String tag) {
    switch (tag.toLowerCase()) {
      case 'bestseller':
        return AppColors.success;
      case 'new':
      case 'new_arrivals':
        return AppColors.info;
      case 'discount':
      case 'sale':
        return AppColors.error;
      case 'personalized':
      case 'ai-powered':
        return AppColors.accent;
      default:
        return AppColors.primary;
    }
  }

  Color _getConfidenceColor() {
    if (recommendation.confidence >= 0.8) return AppColors.success;
    if (recommendation.confidence >= 0.6) return AppColors.info;
    if (recommendation.confidence >= 0.4) return AppColors.warning;
    return AppColors.error;
  }
}

// lib/presentation/widgets/recommendations/recommendation_section.dart
class RecommendationSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<ProductRecommendation> recommendations;
  final Function(ProductRecommendation)? onProductTap;
  final Function(ProductRecommendation)? onAddToCart;
  final VoidCallback? onViewAll;
  final bool showAIBadge;
  final bool showScore;
  final IconData? titleIcon;

  const RecommendationSection({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.recommendations,
    this.onProductTap,
    this.onAddToCart,
    this.onViewAll,
    this.showAIBadge = true,
    this.showScore = false,
    this.titleIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (recommendations.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        _buildSectionHeader(context),
        
        const SizedBox(height: 16),
        
        // Recommendations List
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.getHorizontalPadding(context),
            ),
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final recommendation = recommendations[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index < recommendations.length - 1 ? 16 : 0,
                ),
                child: FadeInRight(
                  duration: Duration(milliseconds: 300 + (index * 100)),
                  child: RecommendationCard(
                    recommendation: recommendation,
                    onTap: () => onProductTap?.call(recommendation),
                    onAddToCart: () => onAddToCart?.call(recommendation),
                    showAIBadge: showAIBadge,
                    showScore: showScore,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getHorizontalPadding(context),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (titleIcon != null) ...[
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          titleIcon,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getFontSize(context, FontSizeType.title),
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          if (onViewAll != null)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onViewAll?.call();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Ver todas',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      IconlyLight.arrow_right_2,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// lib/presentation/widgets/recommendations/ai_insights_card.dart
class AIInsightsCard extends StatelessWidget {
  final RecommendationInsights insights;
  final VoidCallback? onTap;

  const AIInsightsCard({
    Key? key,
    required this.insights,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getHorizontalPadding(context),
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.accent.withOpacity(0.1),
              AppColors.primary.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    IconlyBold.chart,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tendencias',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Insights personalizados',
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
                  color: AppColors.primary,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Insights Grid
            Row(
              children: [
                Expanded(
                  child: _buildInsightItem(
                    icon: IconlyLight.category,
                    title: 'Top Categoría',
                    value: insights.topCategory ?? 'N/A',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInsightItem(
                    icon: IconlyLight.star,
                    title: 'Color Popular',
                    value: insights.topColor ?? 'N/A',
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildInsightItem(
                    icon: IconlyLight.heart,
                    title: 'Talla Popular',
                    value: insights.topSize ?? 'N/A',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInsightItem(
                    icon: IconlyLight.wallet,
                    title: 'Rango Precio',
                    value: '\$${insights.popularPriceRange.min.toInt()}-\$${insights.popularPriceRange.max.toInt()}',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}