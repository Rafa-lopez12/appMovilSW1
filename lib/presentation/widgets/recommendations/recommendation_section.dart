import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconly/iconly.dart';
import 'package:animate_do/animate_do.dart';
import 'package:prueba/presentation/widgets/recommendations/recommendation_card.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../data/models/recommendation/recommendation_model.dart';


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