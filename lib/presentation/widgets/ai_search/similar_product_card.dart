// lib/presentation/widgets/ai_search/similar_product_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconly/iconly.dart';


import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../data/models/ai_search/similar_product_model.dart';

class SimilarProductCard extends StatefulWidget {
  final SimilarProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onFavorite;

  const SimilarProductCard({
    Key? key,
    required this.product,
    this.onTap,
    this.onAddToCart,
    this.onFavorite,
  }) : super(key: key);

  @override
  State<SimilarProductCard> createState() => _SimilarProductCardState();
}

class _SimilarProductCardState extends State<SimilarProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  bool _isFavorite = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) {
              setState(() => _isPressed = true);
              _animationController.forward();
            },
            onTapUp: (_) {
              setState(() => _isPressed = false);
              _animationController.reverse();
              HapticFeedback.lightImpact();
              widget.onTap?.call();
            },
            onTapCancel: () {
              setState(() => _isPressed = false);
              _animationController.reverse();
            },
            child: _buildCard(),
          ),
        );
      },
    );
  }

  Widget _buildCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section
          _buildImageSection(),
          
          // Content section
          _buildContentSection(),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
      return Expanded(
        flex: 3,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            color: AppColors.background,
          ),
          child: Stack(
            children: [
              // Product image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: widget.product.hasImages
                    ? Image.network(
                        widget.product.primaryImage,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: AppColors.background,
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                      )
                    : _buildImagePlaceholder(),
              ),
              
              // Similarity badge
              Positioned(
                top: 8,
                left: 8,
                child: _buildSimilarityBadge(),
              ),
              
              // Favorite button
              Positioned(
                top: 8,
                right: 8,
                child: _buildFavoriteButton(),
              ),
              
              // Match reasons
              if (widget.product.matchReasons != null && 
                  widget.product.matchReasons!.isNotEmpty)
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: _buildMatchReasonsChip(),
                ),
            ],
          ),
        ),
      );
    }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.background,
      child: Icon(
        IconlyLight.image,
        size: 40,
        color: AppColors.textSecondary.withOpacity(0.5),
      ),
    );
  }

  Widget _buildSimilarityBadge() {
    final similarity = widget.product.similarity;
    final Color badgeColor;
    final IconData badgeIcon;
    
    if (similarity >= 0.8) {
      badgeColor = AppColors.success;
      badgeIcon = IconlyBold.star;
    } else if (similarity >= 0.6) {
      badgeColor = AppColors.warning;
      badgeIcon = IconlyLight.star;
    } else {
      badgeColor = AppColors.info;
      badgeIcon = IconlyLight.heart;
    }

    return FadeIn(
      duration: const Duration(milliseconds: 500),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: badgeColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: badgeColor.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              badgeIcon,
              size: 12,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              widget.product.similarityPercentage,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _isFavorite = !_isFavorite;
        });
        widget.onFavorite?.call();
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          _isFavorite ? IconlyBold.heart : IconlyLight.heart,
          size: 16,
          color: _isFavorite ? AppColors.error : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildMatchReasonsChip() {
    if (widget.product.matchReasons == null || 
        widget.product.matchReasons!.isEmpty) {
      return const SizedBox();
    }

    final reason = widget.product.matchReasons!.first;
    
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          reason,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product name
            Text(
              widget.product.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 4),
            
            // Category
            Text(
              widget.product.category,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
            const Spacer(),
            
            // Price and variants
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.price.priceRange,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      if (widget.product.hasMultipleVariants)
                        Text(
                          '${widget.product.variants} variantes',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Add to cart button
                _buildAddToCartButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddToCartButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onAddToCart?.call();
        _showAddToCartAnimation();
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          IconlyLight.bag,
          size: 16,
          color: Colors.white,
        ),
      ),
    );
  }

  void _showAddToCartAnimation() {
    // Simple feedback animation
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }
}