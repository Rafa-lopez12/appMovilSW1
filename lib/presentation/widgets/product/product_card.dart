// lib/presentation/widgets/product/product_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconly/iconly.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/constants/app_colors.dart';

class ProductCard extends StatefulWidget {
  final Map<String, dynamic> product;
  final VoidCallback onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onFavorite;
  final bool showNewBadge;
  final bool showDiscountBadge;
  final double? width;
  final double? height;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onTap,
    this.onAddToCart,
    this.onFavorite,
    this.showNewBadge = false,
    this.showDiscountBadge = true,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _isFavorite = widget.product['isFavorite'] ?? false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final price = product['price'] as double;
    final originalPrice = product['originalPrice'] as double?;
    final hasDiscount = originalPrice != null && originalPrice > price;
    final discountPercentage = hasDiscount 
        ? ((originalPrice! - price) / originalPrice * 100).round()
        : 0;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onTap();
            },
            onTapDown: (_) => _controller.forward(),
            onTapUp: (_) => _controller.reverse(),
            onTapCancel: () => _controller.reverse(),
            child: Container(
              width: widget.width,
              height: widget.height,
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
                  // Image section
                  Expanded(
                    flex: 3,
                    child: _buildImageSection(product, hasDiscount, discountPercentage),
                  ),
                  
                  // Content section
                  Expanded(
                    flex: 2,
                    child: _buildContentSection(product, price, originalPrice, hasDiscount),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSection(Map<String, dynamic> product, bool hasDiscount, int discountPercentage) {
    return Stack(
      children: [
        // Product Image
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(16),
          ),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: AppColors.background,
            child: product['image'] != null
                ? Image.network(
                    product['image'],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.background,
                        child: Icon(
                          IconlyLight.image,
                          size: 40,
                          color: AppColors.textSecondary,
                        ),
                      );
                    },
                  )
                : Icon(
                    IconlyLight.image,
                    size: 40,
                    color: AppColors.textSecondary,
                  ),
          ),
        ),
        
        // Badges and actions overlay
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: badges and favorite
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Badges
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.showNewBadge)
                          _buildBadge('NUEVO', AppColors.success),
                        if (hasDiscount && widget.showDiscountBadge)
                          _buildBadge('-$discountPercentage%', AppColors.error),
                      ],
                    ),
                    
                    // Favorite button
                    _buildFavoriteButton(),
                  ],
                ),
                
                const Spacer(),
                
                // Bottom: Add to cart button
                if (widget.onAddToCart != null)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: _buildAddToCartButton(),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentSection(Map<String, dynamic> product, double price, double? originalPrice, bool hasDiscount) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product name
          Text(
            product['name'] ?? 'Producto',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 4),
          
          // Rating
          if (product['rating'] != null)
            Row(
              children: [
                Icon(
                  Icons.star,
                  size: 14,
                  color: AppColors.ratingFilled,
                ),
                const SizedBox(width: 2),
                Text(
                  product['rating'].toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          
          const Spacer(),
          
          // Price section
          Row(
            children: [
              // Current price
              Text(
                '\$${price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              
              // Original price (if discounted)
              if (hasDiscount) ...[
                const SizedBox(width: 8),
                Text(
                  '\$${originalPrice!.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
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

  Widget _buildAddToCartButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onAddToCart?.call();
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
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          IconlyLight.plus,
          size: 16,
          color: Colors.white,
        ),
      ),
    );
  }
}