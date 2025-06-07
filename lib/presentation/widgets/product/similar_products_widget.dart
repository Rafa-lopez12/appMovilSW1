// lib/presentation/widgets/product/similar_products_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../common/section_header.dart';
import '../common/custom_button.dart';
import 'product_card.dart';
import '../../pages/product/product_detail_page.dart';

enum SimilarProductsType {
  similar,
  recommended,
  related,
  recentlyViewed,
  trending
}

class SimilarProductsWidget extends StatefulWidget {
  final String productId;
  final SimilarProductsType type;
  final String? title;
  final String? actionText;
  final int maxItems;
  final bool showViewAll;
  final bool horizontal;
  final double? height;
  final VoidCallback? onViewAll;
  final EdgeInsets? padding;

  const SimilarProductsWidget({
    Key? key,
    required this.productId,
    this.type = SimilarProductsType.similar,
    this.title,
    this.actionText,
    this.maxItems = 6,
    this.showViewAll = true,
    this.horizontal = true,
    this.height,
    this.onViewAll,
    this.padding,
  }) : super(key: key);

  @override
  State<SimilarProductsWidget> createState() => _SimilarProductsWidgetState();
}

class _SimilarProductsWidgetState extends State<SimilarProductsWidget> {
  List<dynamic> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSimilarProducts();
  }

  @override
  void didUpdateWidget(SimilarProductsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.productId != widget.productId || 
        oldWidget.type != widget.type) {
      _loadSimilarProducts();
    }
  }

  Future<void> _loadSimilarProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      List<dynamic> products = [];

      switch (widget.type) {
        case SimilarProductsType.similar:
          products = await productProvider.getSimilarProducts(widget.productId);
          break;
        case SimilarProductsType.recommended:
          products = await productProvider.getFeaturedProducts(limit: widget.maxItems);
          break;
        case SimilarProductsType.related:
          // For now, use similar products logic
          products = await productProvider.getSimilarProducts(widget.productId);
          break;
        case SimilarProductsType.recentlyViewed:
          // TODO: Implement recently viewed products
          products = await productProvider.getFeaturedProducts(limit: widget.maxItems);
          break;
        case SimilarProductsType.trending:
          products = await productProvider.getFeaturedProducts(limit: widget.maxItems);
          break;
      }

      setState(() {
        _products = products.take(widget.maxItems).toList();
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_products.isEmpty) {
      return const SizedBox.shrink();
    }

    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: Container(
        padding: widget.padding ?? EdgeInsets.symmetric(
          vertical: ResponsiveUtils.getSpacing(context, SpacingType.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            widget.horizontal ? _buildHorizontalList() : _buildVerticalGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SectionHeader(
      title: widget.title ?? _getDefaultTitle(),
      actionText: widget.showViewAll ? (widget.actionText ?? 'Ver todos') : null,
      onActionTap: widget.showViewAll ? _handleViewAll : null,
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getHorizontalPadding(context),
      ),
    );
  }

  Widget _buildHorizontalList() {
    return SizedBox(
      height: widget.height ?? 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getHorizontalPadding(context),
        ),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          
          return FadeInRight(
            duration: Duration(milliseconds: 300 + (index * 100)),
            child: Container(
              width: 180,
              margin: EdgeInsets.only(
                right: index < _products.length - 1 ? 16 : 0,
              ),
              child: ProductCard(
                product: _convertProductToMap(product),
                onTap: () => _onProductTapped(product),
                onAddToCart: () => _onAddToCartTapped(product),
                onFavorite: () => _onFavoriteTapped(product),
                showNewBadge: _isNewProduct(product),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVerticalGrid() {
    final crossAxisCount = ResponsiveUtils.getGridColumns(context);
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getHorizontalPadding(context),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          
          return FadeInUp(
            duration: Duration(milliseconds: 300 + (index * 100)),
            child: ProductCard(
              product: _convertProductToMap(product),
              onTap: () => _onProductTapped(product),
              onAddToCart: () => _onAddToCartTapped(product),
              onFavorite: () => _onFavoriteTapped(product),
              showNewBadge: _isNewProduct(product),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveUtils.getSpacing(context, SpacingType.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.getHorizontalPadding(context),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 150,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  width: 80,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Products skeleton
          SizedBox(
            height: widget.horizontal ? (widget.height ?? 280) : null,
            child: widget.horizontal 
                ? _buildHorizontalLoadingSkeleton()
                : _buildVerticalLoadingSkeleton(),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalLoadingSkeleton() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getHorizontalPadding(context),
      ),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          width: 180,
          margin: EdgeInsets.only(right: index < 2 ? 16 : 0),
          child: _buildProductSkeleton(),
        );
      },
    );
  }

  Widget _buildVerticalLoadingSkeleton() {
    final crossAxisCount = ResponsiveUtils.getGridColumns(context);
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getHorizontalPadding(context),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => _buildProductSkeleton(),
      ),
    );
  }

  Widget _buildProductSkeleton() {
    return Container(
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
        children: [
          // Image skeleton
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
            ),
          ),
          
          // Content skeleton
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 80,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 60,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: EdgeInsets.all(
        ResponsiveUtils.getSpacing(context, SpacingType.lg),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              IconlyLight.info_circle,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No se pudieron cargar los productos',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: 'Reintentar',
              onPressed: _loadSimilarProducts,
              type: ButtonType.outline,
              size: ButtonSize.small,
              icon: IconlyLight.arrow_right_circle,
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  String _getDefaultTitle() {
    switch (widget.type) {
      case SimilarProductsType.similar:
        return AppStrings.similarProducts;
      case SimilarProductsType.recommended:
        return AppStrings.recommendedProducts;
      case SimilarProductsType.related:
        return 'Productos relacionados';
      case SimilarProductsType.recentlyViewed:
        return 'Vistos recientemente';
      case SimilarProductsType.trending:
        return 'Productos populares';
    }
  }

  Map<String, dynamic> _convertProductToMap(dynamic product) {
    // Convert ProductModel to Map for ProductCard
    return {
      'id': product.id,
      'name': product.name,
      'price': product.minPrice,
      'originalPrice': product.hasDiscount ? product.maxPrice : null,
      'image': product.mainImage,
      'rating': 4.5, // Placeholder - implement rating system
      'isFavorite': false, // Placeholder - implement favorites
      'category': product.category?.name ?? '',
    };
  }

  bool _isNewProduct(dynamic product) {
    // Placeholder logic - implement based on creation date
    return false;
  }

  void _onProductTapped(dynamic product) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(productId: product.id),
      ),
    );
  }

  void _onAddToCartTapped(dynamic product) {
    HapticFeedback.lightImpact();
    
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    
    // Add with default variant
    final defaultVariant = product.variants?.isNotEmpty == true 
        ? product.variants.first 
        : null;
    
    if (defaultVariant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Producto sin variantes disponibles'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    cartProvider.addItem(
      productId: product.id,
      name: product.name,
      price: defaultVariant.price,
      image: product.mainImage,
      size: defaultVariant.size?.name ?? 'M',
      color: defaultVariant.color ?? 'Default',
      productoVariedadId: defaultVariant.id,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} agregado al carrito'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onFavoriteTapped(dynamic product) {
    HapticFeedback.lightImpact();
    // TODO: Implement favorites
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Favoritos próximamente')),
    );
  }

  void _handleViewAll() {
    HapticFeedback.lightImpact();
    if (widget.onViewAll != null) {
      widget.onViewAll!();
    } else {
      // Default behavior - navigate to catalog with filter
      Navigator.pushNamed(context, '/catalog');
    }
  }
}

// Widget especializado para productos similares
class SimilarProductsHorizontalWidget extends StatelessWidget {
  final String productId;
  final String? title;

  const SimilarProductsHorizontalWidget({
    Key? key,
    required this.productId,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimilarProductsWidget(
      productId: productId,
      type: SimilarProductsType.similar,
      title: title ?? AppStrings.similarProducts,
      horizontal: true,
      maxItems: 6,
    );
  }
}

// Widget para productos recomendados
class RecommendedProductsWidget extends StatelessWidget {
  final String productId;
  final bool horizontal;

  const RecommendedProductsWidget({
    Key? key,
    required this.productId,
    this.horizontal = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimilarProductsWidget(
      productId: productId,
      type: SimilarProductsType.recommended,
      title: AppStrings.recommendedProducts,
      horizontal: horizontal,
      maxItems: horizontal ? 6 : 8,
    );
  }
}

// Widget para productos trending
class TrendingProductsWidget extends StatelessWidget {
  final String productId;

  const TrendingProductsWidget({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimilarProductsWidget(
      productId: productId,
      type: SimilarProductsType.trending,
      title: 'Productos populares',
      horizontal: true,
      maxItems: 8,
    );
  }
}

// Widget para grid de productos relacionados
class RelatedProductsGridWidget extends StatelessWidget {
  final String productId;
  final int maxItems;

  const RelatedProductsGridWidget({
    Key? key,
    required this.productId,
    this.maxItems = 6,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimilarProductsWidget(
      productId: productId,
      type: SimilarProductsType.related,
      title: 'Productos relacionados',
      horizontal: false,
      maxItems: maxItems,
      showViewAll: true,
    );
  }
}