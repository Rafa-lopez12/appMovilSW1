// lib/presentation/pages/catalog/catalog_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../widgets/common/search_bar_widget.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/product/product_card.dart';
import '../../widgets/product/category_card.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/catalog/filter_bottom_sheet.dart';
import '../../widgets/catalog/sort_bottom_sheet.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../product/product_detail_page.dart';
import '../../../data/models/product/product_model.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({Key? key}) : super(key: key);

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> 
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  
  @override
  bool get wantKeepAlive => true;

  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;
  
  bool _showAppBarShadow = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Initialize provider and load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      productProvider.initialize();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final showShadow = _scrollController.offset > 0;
    if (showShadow != _showAppBarShadow) {
      setState(() {
        _showAppBarShadow = showShadow;
      });
    }

    // Load more products when reaching the bottom
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      productProvider.loadMoreProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          // Initialize tab controller when categories are loaded
          if (productProvider.hasCategories && 
              (_tabController.length != productProvider.categories.length + 1)) {
            _tabController = TabController(
              length: productProvider.categories.length + 1, 
              vsync: this
            );
          }

          return NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                // App Bar
                _buildAppBar(productProvider),
                
                // Search Bar
                SliverToBoxAdapter(
                  child: _buildSearchSection(),
                ),
                
                // Category Tabs
                if (productProvider.hasCategories)
                  SliverToBoxAdapter(
                    child: _buildCategoryTabs(productProvider),
                  ),
                
                // Filters and Sort
                SliverToBoxAdapter(
                  child: _buildFiltersSection(productProvider),
                ),
              ];
            },
            body: _buildContent(productProvider),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(ProductProvider productProvider) {
    return SliverAppBar(
      floating: true,
      pinned: true,
      elevation: _showAppBarShadow ? 4 : 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      toolbarHeight: 60,
      automaticallyImplyLeading: false,
      title: FadeInDown(
        duration: const Duration(milliseconds: 600),
        child: Text(
          AppStrings.catalog,
          style: TextStyle(
            fontSize: ResponsiveUtils.getFontSize(context, FontSizeType.title),
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      actions: [
        FadeInDown(
          duration: const Duration(milliseconds: 800),
          child: IconButton(
            onPressed: () => _showFiltersBottomSheet(productProvider),
            icon: Stack(
              children: [
                Icon(
                  IconlyLight.filter,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
                if (productProvider.hasFiltersApplied)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchSection() {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getHorizontalPadding(context),
          vertical: 16,
        ),
        child: SearchBarWidget(
          hintText: 'Buscar productos...',
          onTap: _onSearchTapped,
          onCameraSearch: _onCameraSearchTapped,
          onVoiceSearch: _onVoiceSearchTapped,
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(ProductProvider productProvider) {
    final categories = ['Todos', ...productProvider.categories.map((c) => c.name)];
    
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: Container(
        height: 50,
        child: TabBar(
          controller: _tabController,
          isScrollable: true,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.getHorizontalPadding(context),
          ),
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
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          indicatorPadding: const EdgeInsets.symmetric(horizontal: -12, vertical: 8),
          tabs: categories.map((category) {
            return Tab(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(category),
              ),
            );
          }).toList(),
          onTap: (index) {
            _onCategoryChanged(index, productProvider);
          },
        ),
      ),
    );
  }

  Widget _buildFiltersSection(ProductProvider productProvider) {
    return FadeInUp(
      duration: const Duration(milliseconds: 1000),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getHorizontalPadding(context),
          vertical: 16,
        ),
        child: Row(
          children: [
            // Results count and filters
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${productProvider.totalProducts} productos encontrados',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (productProvider.hasFiltersApplied)
                    Text(
                      productProvider.filterSummary,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
            
            // Clear filters button
            if (productProvider.hasFiltersApplied)
              TextButton(
                onPressed: () => _onClearFilters(productProvider),
                child: Text(
                  'Limpiar',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            
            // Sort button
            GestureDetector(
              onTap: () => _showSortBottomSheet(productProvider),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      IconlyLight.swap,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Ordenar',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
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

  Widget _buildContent(ProductProvider productProvider) {
    if (productProvider.isLoading && productProvider.products.isEmpty) {
      return _buildLoadingState();
    }

    if (productProvider.errorMessage != null && productProvider.products.isEmpty) {
      return _buildErrorState(productProvider);
    }

    if (productProvider.products.isEmpty) {
      return _buildEmptyState(productProvider);
    }

    return _buildProductGrid(productProvider);
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Cargando productos...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
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
              'Error al cargar productos',
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
              onPressed: () => productProvider.loadProducts(refresh: true),
              icon: IconlyLight.delete,
              type: ButtonType.outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ProductProvider productProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeIn(
              duration: const Duration(milliseconds: 800),
              child: Icon(
                IconlyLight.search,
                size: 80,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            FadeInUp(
              duration: const Duration(milliseconds: 1000),
              child: Text(
                AppStrings.noProducts,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            FadeInUp(
              duration: const Duration(milliseconds: 1200),
              child: Text(
                productProvider.hasFiltersApplied
                    ? 'Intenta ajustar los filtros o busca otros productos'
                    : 'No hay productos disponibles en este momento',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (productProvider.hasFiltersApplied) ...[
              const SizedBox(height: 24),
              FadeInUp(
                duration: const Duration(milliseconds: 1400),
                child: CustomButton(
                  text: 'Limpiar Filtros',
                  onPressed: () => _onClearFilters(productProvider),
                  type: ButtonType.outline,
                  icon: IconlyLight.delete,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid(ProductProvider productProvider) {
    final crossAxisCount = ResponsiveUtils.getGridColumns(context);
    
    return FadeInUp(
      duration: const Duration(milliseconds: 1200),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getHorizontalPadding(context),
        ),
        child: Column(
          children: [
            // Products Grid
            Expanded(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 20),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: productProvider.products.length + 
                           (productProvider.hasMoreProducts ? 1 : 0),
                itemBuilder: (context, index) {
                  // Show loading indicator at the end if there are more products
                  if (index >= productProvider.products.length) {
                    return _buildLoadMoreIndicator(productProvider);
                  }
                  
                  final product = productProvider.products[index];
                  return ProductCard(
                    product: product.toDisplayMap(),
                    onTap: () => _onProductTapped(product),
                    onAddToCart: () => _onAddToCartTapped(product),
                    onFavorite: () => _onFavoriteTapped(product),
                    showNewBadge: false, // Could be based on creation date
                  );
                },
              ),
            ),
            
            // Load more button (alternative to automatic loading)
            if (productProvider.hasMoreProducts && !productProvider.isLoadingMore)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: CustomButton(
                  text: 'Cargar más productos',
                  onPressed: () => productProvider.loadMoreProducts(),
                  type: ButtonType.outline,
                  icon: IconlyLight.arrow_down_2,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator(ProductProvider productProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: productProvider.isLoadingMore
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cargando...',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              )
            : Icon(
                IconlyLight.arrow_down_2,
                color: AppColors.textSecondary,
              ),
      ),
    );
  }

  // Event handlers
  void _onSearchTapped() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/search');
  }

  void _onCameraSearchTapped() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/ai-search');
  }

  void _onVoiceSearchTapped() {
    HapticFeedback.lightImpact();
    // TODO: Implement voice search
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Búsqueda por voz próximamente')),
    );
  }

  void _onCategoryChanged(int index, ProductProvider productProvider) {
    HapticFeedback.lightImpact();
    
    if (index == 0) {
      // "Todos" selected
      productProvider.clearFilters();
    } else {
      final category = productProvider.categories[index - 1];
      productProvider.filterByCategory(category.id);
    }
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
    
    // For now, add with default variant
    final defaultVariant = product.variants.isNotEmpty ? product.variants.first : null;
    
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
      size: defaultVariant.size.name,
      color: defaultVariant.color,
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

  void _onClearFilters(ProductProvider productProvider) {
    HapticFeedback.lightImpact();
    productProvider.clearFilters();
    if (_tabController.index != 0) {
      _tabController.animateTo(0);
    }
  }

  void _showFiltersBottomSheet(ProductProvider productProvider) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => FilterBottomSheet(
        productProvider: productProvider,
      ),
    );
  }

  void _showSortBottomSheet(ProductProvider productProvider) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SortBottomSheet(
        productProvider: productProvider,
      ),
    );
  }
}

extension ProductModelExtension on ProductModel {
  Map<String, dynamic> toDisplayMap() {
    return {
      'id': id,
      'name': name,
      'price': minPrice,
      'originalPrice': hasDiscount ? maxPrice : null,
      'image': mainImage,
      'rating': 4.5, // Placeholder, implement rating system
      'isFavorite': false, // Placeholder, implement favorites
      'category': category.name,
    };
  }
}