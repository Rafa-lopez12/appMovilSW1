// lib/presentation/pages/product/product_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/product/image_gallery_widget.dart';
import '../../widgets/product/variant_selector_widget.dart';
import '../../widgets/product/quantity_selector_widget.dart';
import '../../widgets/product/price_display_widget.dart';
import '../../widgets/product/product_rating_widget.dart';
import '../../widgets/product/similar_products_widget.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  
  String? _selectedSize;
  String? _selectedColor;
  int _quantity = 1;
  bool _isFavorite = false;
  bool _showAppBarTitle = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    
    // Cargar detalles del producto
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      productProvider.loadProductDetail(widget.productId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final showTitle = _scrollController.offset > 200;
    if (showTitle != _showAppBarTitle) {
      setState(() {
        _showAppBarTitle = showTitle;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.isLoadingDetail) {
            return _buildLoadingState();
          }

          if (productProvider.errorMessage != null) {
            return _buildErrorState(productProvider);
          }

          final product = productProvider.selectedProduct;
          if (product == null) {
            return _buildNotFoundState();
          }

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildAppBar(product),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageGallery(product),
                    _buildProductInfo(product),
                    _buildVariantSelectors(product),
                    _buildQuantityAndActions(product),
                    _buildTabSection(product),
                    _buildSimilarProducts(),
                    const SizedBox(height: 100), // Espacio para el bottom bar
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          final product = productProvider.selectedProduct;
          if (product == null) return const SizedBox.shrink();
          
          return _buildBottomActions(product);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(ProductProvider productProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              IconlyLight.info_circle,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar producto',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              productProvider.errorMessage ?? 'Error desconocido',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Reintentar',
              onPressed: () {
                productProvider.loadProductDetail(widget.productId);
              },
              icon: IconlyLight.delete,
              type: ButtonType.outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              IconlyLight.search,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Producto no encontrado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'El producto que buscas no existe o no está disponible',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Volver al catálogo',
              onPressed: () => Navigator.of(context).pop(),
              icon: IconlyLight.arrow_left,
              type: ButtonType.outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(dynamic product) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      elevation: _showAppBarTitle ? 4 : 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            IconlyLight.arrow_left,
            color: AppColors.textPrimary,
          ),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: AnimatedOpacity(
        opacity: _showAppBarTitle ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Text(
          product.name ?? '',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      actions: [
        IconButton(
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              _isFavorite ? IconlyBold.heart : IconlyLight.heart,
              color: _isFavorite ? AppColors.error : AppColors.textSecondary,
              size: 20,
            ),
          ),
          onPressed: _toggleFavorite,
        ),
        IconButton(
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              IconlyLight.upload,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
          onPressed: _shareProduct,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildImageGallery(dynamic product) {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: ImageGalleryWidget(
        images: product.images?.map<String>((img) => img.url).toList() ?? [],
        heroTag: 'product-${product.id}',
      ),
    );
  }

  Widget _buildProductInfo(dynamic product) {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getHorizontalPadding(context),
          vertical: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre del producto
            Text(
              product.name ?? '',
              style: TextStyle(
                fontSize: ResponsiveUtils.getFontSize(context, FontSizeType.title),
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Rating y reseñas
            ProductRatingWidget(
              rating: 4.5, // Placeholder - implementar sistema de rating
              reviewCount: 127,
              onTap: () => _tabController.animateTo(2),
            ),
            
            const SizedBox(height: 16),
            
            // Precio
            PriceDisplayWidget(
              currentPrice: product.minPrice ?? 0.0,
              originalPrice: product.hasDiscount ? product.maxPrice : null,
              showDiscount: product.hasDiscount,
            ),
            
            const SizedBox(height: 12),
            
            // Categoría y subcategoría
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    product.category.name ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (product.subcategory != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      product.subcategory,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVariantSelectors(dynamic product) {
    return FadeInUp(
      duration: const Duration(milliseconds: 1000),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getHorizontalPadding(context),
        ),
        child: Column(
          children: [
            // Selector de talla
            if (product.availableSizes.isNotEmpty)
              VariantSelectorWidget(
                title: 'Talla',
                options: product.availableSizes,
                selectedOption: _selectedSize,
                onOptionSelected: (size) {
                  setState(() {
                    _selectedSize = size;
                  });
                },
              ),
            
            const SizedBox(height: 16),
            
            // Selector de color
            if (product.availableColors.isNotEmpty)
              VariantSelectorWidget(
                title: 'Color',
                options: product.availableColors,
                selectedOption: _selectedColor,
                onOptionSelected: (color) {
                  setState(() {
                    _selectedColor = color;
                  });
                },
                isColorSelector: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityAndActions(dynamic product) {
    return FadeInUp(
      duration: const Duration(milliseconds: 1200),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getHorizontalPadding(context),
          vertical: 20,
        ),
        child: Row(
          children: [
            // Selector de cantidad
            Expanded(
              flex: 2,
              child: QuantitySelectorWidget(
                quantity: _quantity,
                onQuantityChanged: (quantity) {
                  setState(() {
                    _quantity = quantity;
                  });
                },
                maxQuantity: _getMaxQuantity(product),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Indicador de stock
            Expanded(
              flex: 3,
              child: _buildStockIndicator(product),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockIndicator(dynamic product) {
    final stock = _getMaxQuantity(product);
    final isLowStock = stock > 0 && stock <= 5;
    final isOutOfStock = stock <= 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isOutOfStock
            ? AppColors.error.withOpacity(0.1)
            : isLowStock
                ? AppColors.warning.withOpacity(0.1)
                : AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isOutOfStock
                ? IconlyLight.close_square
                : isLowStock
                    ? IconlyLight.danger
                    : IconlyLight.tick_square,
            size: 16,
            color: isOutOfStock
                ? AppColors.error
                : isLowStock
                    ? AppColors.warning
                    : AppColors.success,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isOutOfStock
                  ? 'Agotado'
                  : isLowStock
                      ? 'Últimas $stock unidades'
                      : '$stock disponibles',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isOutOfStock
                    ? AppColors.error
                    : isLowStock
                        ? AppColors.warning
                        : AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection(dynamic product) {
    return FadeInUp(
      duration: const Duration(milliseconds: 1400),
      child: Column(
        children: [
          // Tab bar
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.getHorizontalPadding(context),
            ),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              tabs: const [
                Tab(text: 'Descripción'),
                Tab(text: 'Características'),
                Tab(text: 'Reseñas'),
              ],
            ),
          ),
          
          // Tab content
          Container(
            height: 300,
            margin: const EdgeInsets.only(top: 16),
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDescriptionTab(product),
                _buildFeaturesTab(product),
                _buildReviewsTab(product),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionTab(dynamic product) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getHorizontalPadding(context),
      ),
      child: Text(
        product.description ?? 'No hay descripción disponible.',
        style: TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildFeaturesTab(dynamic product) {
    // Mock features - en la implementación real vendrían del backend
    final features = [
      'Material: 100% Algodón',
      'Lavable en máquina',
      'Ajuste regular',
      'Importado',
      'Garantía de 6 meses',
    ];

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getHorizontalPadding(context),
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Icon(
                IconlyLight.tick_square,
                size: 16,
                color: AppColors.success,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  features[index],
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewsTab(dynamic product) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getHorizontalPadding(context),
      ),
      child: Column(
        children: [
          // Resumen de reseñas
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Column(
                  children: [
                    Text(
                      '4.5',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < 4 ? Icons.star : Icons.star_border,
                          size: 16,
                          color: AppColors.ratingFilled,
                        );
                      }),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '127 reseñas',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    children: List.generate(5, (index) {
                      final rating = 5 - index;
                      final percentage = [70, 15, 8, 4, 3][index] / 100;
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Text(
                              '$rating',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: percentage,
                                backgroundColor: AppColors.border,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.ratingFilled,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${(percentage * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Botón para ver todas las reseñas
          CustomButton(
            text: 'Ver todas las reseñas',
            onPressed: () {
              // TODO: Navegar a página de reseñas
            },
            type: ButtonType.outline,
            icon: IconlyLight.arrow_right,
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarProducts() {
    return FadeInUp(
      duration: const Duration(milliseconds: 1600),
      child: SimilarProductsWidget(
        productId: widget.productId,
      ),
    );
  }

  Widget _buildBottomActions(dynamic product) {
    final canAddToCart = _selectedSize != null && 
                        _selectedColor != null && 
                        _getMaxQuantity(product) > 0;

    return Container(
      padding: EdgeInsets.all(
        ResponsiveUtils.getHorizontalPadding(context),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Botón de favorito
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(16),
              ),
              child: IconButton(
                onPressed: _toggleFavorite,
                icon: Icon(
                  _isFavorite ? IconlyBold.heart : IconlyLight.heart,
                  color: _isFavorite ? AppColors.error : AppColors.textSecondary,
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Botón agregar al carrito
            Expanded(
              child: CustomButton(
                text: canAddToCart 
                    ? 'Agregar al carrito (\$${(product.minPrice * _quantity).toStringAsFixed(2)})'
                    : _getMaxQuantity(product) <= 0
                        ? 'Agotado'
                        : 'Selecciona variante',
                onPressed: canAddToCart ? _addToCart : null,
                icon: IconlyLight.bag,
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getMaxQuantity(dynamic product) {
    if (_selectedSize == null || _selectedColor == null) {
      return product.totalStock ?? 0;
    }
    
    // Buscar la variante específica
    final variant = product.variants?.firstWhere(
      (v) => v.size.name == _selectedSize && v.color == _selectedColor,
      orElse: () => null,
    );
    
    return variant?.quantity ?? 0;
  }

  void _toggleFavorite() {
    HapticFeedback.lightImpact();
    setState(() {
      _isFavorite = !_isFavorite;
    });
    
    // TODO: Implementar lógica de favoritos
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorite 
              ? 'Agregado a favoritos' 
              : 'Removido de favoritos',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _shareProduct() {
    HapticFeedback.lightImpact();
    // TODO: Implementar compartir producto
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de compartir próximamente'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _addToCart() {
    if (_selectedSize == null || _selectedColor == null) return;
    
    HapticFeedback.lightImpact();
    
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final product = productProvider.selectedProduct;
    
    if (product == null) return;
    
    // Buscar la variante específica
    final variant = product.variants?.where(
      (v) => v.size.name == _selectedSize && v.color == _selectedColor,
    ).firstOrNull;
    
    if (variant == null) return;
    
    cartProvider.addItem(
      productId: product.id,
      name: product.name,
      price: variant.price,
      image: product.mainImage,
      size: _selectedSize!,
      color: _selectedColor!,
      productoVariedadId: variant.id,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} agregado al carrito'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Ver carrito',
          textColor: Colors.white,
          onPressed: () {
            // TODO: Navegar al carrito
          },
        ),
      ),
    );
  }
}