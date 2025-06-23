// lib/presentation/pages/home/home_page.dart - CON PRODUCTOS REALES
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../widgets/common/search_bar_widget.dart';
import '../../widgets/product/product_card.dart';
import '../../widgets/product/category_card.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/recommendations/recommendation_section.dart';
import '../../widgets/recommendations/ai_insights_card.dart';
import '../../providers/auth_provider.dart';
import '../../providers/recommendation_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../../data/models/recommendation/recommendation_model.dart';
import '../../../data/models/product/product_model.dart';
import '../product/product_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  bool _showAppBarShadow = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _initializeData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final recommendationProvider = Provider.of<RecommendationProvider>(context, listen: false);
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      
      // Inicializar recomendaciones y productos
      recommendationProvider.initialize();
      productProvider.initialize();
      
      // Cargar productos destacados y nuevos
      productProvider.getFeaturedProducts(limit: 10);
      productProvider.loadNewProducts(limit: 10);
    });
  }

  void _onScroll() {
    final showShadow = _scrollController.offset > 0;
    if (showShadow != _showAppBarShadow) {
      setState(() {
        _showAppBarShadow = showShadow;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.primary,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // Custom App Bar
            _buildAppBar(),
            
            // Search Bar
            SliverToBoxAdapter(
              child: _buildSearchSection(),
            ),
            
            // Quick Actions
            SliverToBoxAdapter(
              child: _buildQuickActions(),
            ),
            
            // AI Recommendations Content
            SliverToBoxAdapter(
              child: Consumer<RecommendationProvider>(
                builder: (context, recommendationProvider, child) {
                  if (recommendationProvider.isLoading && 
                      recommendationProvider.recommendations.isEmpty) {
                    return _buildLoadingSection();
                  }
                  
                  if (recommendationProvider.errorMessage != null && 
                      recommendationProvider.recommendations.isEmpty) {
                    return _buildErrorSection(recommendationProvider);
                  }
                  
                  return _buildRecommendationsContent(recommendationProvider);
                },
              ),
            ),
            
            // Categories Section
            SliverToBoxAdapter(
              child: Consumer<ProductProvider>(
                builder: (context, productProvider, child) {
                  return _buildCategoriesSection(productProvider);
                },
              ),
            ),
            
            // Featured Products Section
            SliverToBoxAdapter(
              child: Consumer<ProductProvider>(
                builder: (context, productProvider, child) {
                  return _buildFeaturedProductsSection(productProvider);
                },
              ),
            ),
            
            // New Products Section
            SliverToBoxAdapter(
              child: Consumer<ProductProvider>(
                builder: (context, productProvider, child) {
                  return _buildNewProductsSection(productProvider);
                },
              ),
            ),
            
            // Bottom spacing
            SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    final recommendationProvider = Provider.of<RecommendationProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    
    await Future.wait([
      recommendationProvider.refreshAll(),
      productProvider.refreshAll(),
    ]);
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      pinned: true,
      elevation: _showAppBarShadow ? 4 : 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      toolbarHeight: 70,
      title: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: Row(
              children: [
                // User Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                  ),
                  child: Center(
                    child: Text(
                      authProvider.userInitials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Greeting and Name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getGreeting(),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        authProvider.currentUser?.firstName ?? 'Usuario',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      actions: [
        // Notifications
        FadeInDown(
          duration: const Duration(milliseconds: 800),
          child: IconButton(
            onPressed: _onNotificationsTapped,
            icon: Stack(
              children: [
                Icon(
                  IconlyLight.notification,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
                // Notification badge
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.error,
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
          onTap: _onSearchTapped,
          onVoiceSearch: _onVoiceSearchTapped,
          onCameraSearch: _onAISearchTapped,
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getHorizontalPadding(context),
        ),
        child: Row(
          children: [
            _buildQuickActionCard(
              icon: IconlyLight.camera,
              title: 'Buscar por Foto',
              subtitle: 'Visual',
              color: AppColors.primary,
              onTap: _onAISearchTapped,
            ),
            
            const SizedBox(width: 12),
            
            _buildQuickActionCard(
              icon: IconlyLight.user,
              title: 'Probador Virtual',
              subtitle: 'Try-On',
              color: AppColors.secondary,
              onTap: _onVirtualTryonTapped,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSection() {
    return FadeIn(
      duration: const Duration(milliseconds: 600),
      child: Container(
        padding: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
        child: Column(
          children: [
            const SizedBox(height: 32),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'Cargando recomendaciones...',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorSection(RecommendationProvider provider) {
    return FadeIn(
      duration: const Duration(milliseconds: 600),
      child: Container(
        padding: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
        child: Column(
          children: [
            const SizedBox(height: 32),
            Icon(
              IconlyLight.info_circle,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar recomendaciones',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage ?? 'Error desconocido',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.refreshAll(),
              child: Text('Reintentar'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsContent(RecommendationProvider provider) {
    return Column(
      children: [
        const SizedBox(height: 24),
        
        // AI Insights Card
        if (provider.bestsellerRecommendations.isNotEmpty)
          FadeInUp(
            duration: const Duration(milliseconds: 1000),
            child: Column(
              children: [
                AIInsightsCard(
                  insights: provider.recommendations['bestsellers']?.insights ?? 
                           RecommendationInsights(
                             trendingCategories: [],
                             popularPriceRange: PriceRange(min: 0, max: 100),
                             topColors: [],
                             topSizes: [],
                           ),
                  onTap: _onInsightsTapped,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        
        // Bestsellers Section
        if (provider.bestsellerRecommendations.isNotEmpty)
          RecommendationSection(
            title: 'Más Vendidos',
            subtitle: 'Productos populares recomendados',
            titleIcon: IconlyBold.star,
            recommendations: provider.bestsellerRecommendations.take(10).toList(),
            onProductTap: _onRecommendationTapped,
            onAddToCart: _onAddRecommendationToCart,
            onViewAll: () => _onViewAllRecommendations('bestsellers'),
            showAIBadge: true,
            showScore: false,
          ),
        
        const SizedBox(height: 24),
        
        // New Arrivals Section
        if (provider.newArrivalRecommendations.isNotEmpty)
          RecommendationSection(
            title: 'Nuevos',
            subtitle: 'Últimas llegadas seleccionadas',
            titleIcon: IconlyBold.time_circle,
            recommendations: provider.newArrivalRecommendations.take(10).toList(),
            onProductTap: _onRecommendationTapped,
            onAddToCart: _onAddRecommendationToCart,
            onViewAll: () => _onViewAllRecommendations('new_arrivals'),
            showAIBadge: true,
            showScore: false,
          ),
        
        const SizedBox(height: 24),
        
        // Personalized Recommendations (if available)
        if (provider.topRecommendations.isNotEmpty)
          RecommendationSection(
            title: 'Para Ti',
            subtitle: 'Recomendaciones personalizadas',
            titleIcon: IconlyBold.heart,
            recommendations: provider.topRecommendations.take(8).toList(),
            onProductTap: _onRecommendationTapped,
            onAddToCart: _onAddRecommendationToCart,
            onViewAll: () => _onViewAllRecommendations('personalized'),
            showAIBadge: true,
            showScore: true,
          ),
      ],
    );
  }

  Widget _buildCategoriesSection(ProductProvider productProvider) {
    if (!productProvider.hasCategories) {
      return const SizedBox.shrink();
    }

    return FadeInUp(
      duration: const Duration(milliseconds: 1200),
      child: Column(
        children: [
          const SizedBox(height: 24),
          
          SectionHeader(
            title: AppStrings.categories,
            actionText: 'Ver todas',
            onActionTap: _onViewAllCategoriesTapped,
          ),
          
          const SizedBox(height: 16),
          
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.getHorizontalPadding(context),
              ),
              itemCount: productProvider.categories.length,
              itemBuilder: (context, index) {
                final category = productProvider.categories[index];
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < productProvider.categories.length - 1 ? 12 : 0,
                  ),
                  child: CategoryCard(
                    title: category.name,
                    icon: _getCategoryIcon(category.name),
                    color: _getCategoryColor(index),
                    onTap: () => _onCategoryTapped(category.id, category.name),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedProductsSection(ProductProvider productProvider) {
    if (productProvider.featuredProducts.isEmpty && !productProvider.isLoading) {
      return const SizedBox.shrink();
    }

    return FadeInUp(
      duration: const Duration(milliseconds: 1400),
      child: Column(
        children: [
          const SizedBox(height: 24),
          
          SectionHeader(
            title: AppStrings.recommendedProducts,
            actionText: 'Ver todos',
            onActionTap: _onViewAllFeaturedTapped,
          ),
          
          const SizedBox(height: 16),
          
          if (productProvider.featuredProducts.isEmpty && productProvider.isLoading)
            _buildProductLoadingList()
          else
            SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.getHorizontalPadding(context),
                ),
                itemCount: productProvider.featuredProducts.length,
                itemBuilder: (context, index) {
                  final product = productProvider.featuredProducts[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < productProvider.featuredProducts.length - 1 ? 16 : 0,
                    ),
                    child: SizedBox(
                      width: 180,
                      child: ProductCard(
                        product: product.toDisplayMap(),
                        onTap: () => _onProductTapped(product),
                        onAddToCart: () => _onAddToCartTapped(product),
                        onFavorite: () => _onFavoriteTapped(product),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNewProductsSection(ProductProvider productProvider) {
    if (productProvider.newProducts.isEmpty && !productProvider.isLoading) {
      return const SizedBox.shrink();
    }

    return FadeInUp(
      duration: const Duration(milliseconds: 1600),
      child: Column(
        children: [
          const SizedBox(height: 24),
          
          SectionHeader(
            title: AppStrings.newProducts,
            actionText: 'Ver todos',
            onActionTap: _onViewAllNewTapped,
          ),
          
          const SizedBox(height: 16),
          
          if (productProvider.newProducts.isEmpty && productProvider.isLoading)
            _buildProductLoadingList()
          else
            SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.getHorizontalPadding(context),
                ),
                itemCount: productProvider.newProducts.length,
                itemBuilder: (context, index) {
                  final product = productProvider.newProducts[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < productProvider.newProducts.length - 1 ? 16 : 0,
                    ),
                    child: SizedBox(
                      width: 180,
                      child: ProductCard(
                        product: product.toDisplayMap(),
                        onTap: () => _onProductTapped(product),
                        onAddToCart: () => _onAddToCartTapped(product),
                        onFavorite: () => _onFavoriteTapped(product),
                        showNewBadge: true,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductLoadingList() {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getHorizontalPadding(context),
        ),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: index < 2 ? 16 : 0),
            child: SizedBox(
              width: 180,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Buenos días 👋';
    } else if (hour < 18) {
      return 'Buenas tardes ☀️';
    } else {
      return 'Buenas noches 🌙';
    }
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'camisas':
      case 'blusas':
        return IconlyLight.paper;
      case 'pantalones':
      case 'jeans':
        return IconlyLight.category;
      case 'vestidos':
        return IconlyLight.star;
      case 'zapatos':
      case 'calzado':
        return IconlyLight.heart;
      case 'accesorios':
        return IconlyLight.bag;
      case 'deportivo':
      case 'sport':
        return IconlyLight.activity;
      case 'formal':
        return IconlyLight.work;
      default:
        return IconlyLight.buy;
    }
  }

  Color _getCategoryColor(int index) {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.accent,
      AppColors.warning,
      AppColors.success,
      AppColors.info,
    ];
    return colors[index % colors.length];
  }

  void _onRecommendationTapped(ProductRecommendation recommendation) {
    HapticFeedback.lightImpact();
    
    // Primero intentar encontrar el producto real por ID
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final realProduct = productProvider.getProductById(recommendation.id);
    
    if (realProduct != null) {
      // Si existe el producto real, navegar a su detalle
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailPage(productId: realProduct.id),
        ),
      );
    } else {
      // Si no existe, mostrar información de la recomendación
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${recommendation.name} - ${recommendation.reason}'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onAddRecommendationToCart(ProductRecommendation recommendation) {
    HapticFeedback.lightImpact();
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    
    // Agregar al carrito usando la información de la recomendación
    cartProvider.addItem(
      productId: recommendation.id,
      name: recommendation.name,
      price: recommendation.price.min,
      image: recommendation.mainImage,
      size: 'M', // Default size
      color: 'Default', // Default color
      productoVariedadId: recommendation.id, // Using recommendation ID as variant
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${recommendation.name} agregado al carrito'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onViewAllRecommendations(String type) {
    HapticFeedback.lightImpact();
    // TODO: Navigate to recommendations page filtered by type
    debugPrint('Ver todas las recomendaciones de tipo: $type');
    
    // Por ahora, navegar al catálogo
    Navigator.pushNamed(context, '/catalog');
  }

  void _onInsightsTapped() {
    HapticFeedback.lightImpact();
    
    final provider = Provider.of<RecommendationProvider>(context, listen: false);
    final stats = provider.getRecommendationStats();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                IconlyBold.chart,
                size: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            const Text('Estadísticas IA'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow('Total recomendaciones', '${stats['total_recommendations']}'),
            _buildStatRow('Bestsellers', '${stats['bestseller_count']}'),
            _buildStatRow('Nuevos productos', '${stats['new_arrivals_count']}'),
            _buildStatRow('Score promedio', '${(stats['average_score'] as double).toStringAsFixed(2)}'),
            _buildStatRow('Confianza promedio', '${(stats['average_confidence'] as double).toStringAsFixed(2)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  // Event handlers para productos reales
  void _onProductTapped(ProductModel product) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(productId: product.id),
      ),
    );
  }

  void _onAddToCartTapped(ProductModel product) {
    HapticFeedback.lightImpact();
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    
    // Obtener la primera variante disponible
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

  void _onFavoriteTapped(ProductModel product) {
    HapticFeedback.lightImpact();
    // TODO: Implementar sistema de favoritos
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Favoritos próximamente disponible'),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onCategoryTapped(String categoryId, String categoryName) {
    HapticFeedback.lightImpact();
    // Navegar al catálogo con filtro de categoría
    Navigator.pushNamed(
      context, 
      '/catalog',
      arguments: {
        'categoryId': categoryId,
        'categoryName': categoryName,
      },
    );
  }

  // Event handlers existentes
  void _onNotificationsTapped() {
    HapticFeedback.lightImpact();
    // TODO: Navigate to notifications
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notificaciones próximamente')),
    );
  }

  void _onSearchTapped() {
    HapticFeedback.lightImpact();
    // Navegar al catálogo con modo búsqueda
    Navigator.pushNamed(context, '/catalog');
  }

  void _onVoiceSearchTapped() {
    HapticFeedback.lightImpact();
    // TODO: Implement voice search
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Búsqueda por voz próximamente')),
    );
  }

  void _onAISearchTapped() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/ai-search');
  }

  void _onVirtualTryonTapped() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/virtual-tryon');
  }

  void _onViewAllCategoriesTapped() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/catalog');
  }

  void _onViewAllFeaturedTapped() {
    HapticFeedback.lightImpact();
    // Navegar al catálogo con filtro de productos destacados
    Navigator.pushNamed(context, '/catalog');
  }

  void _onViewAllNewTapped() {
    HapticFeedback.lightImpact();
    // Navegar al catálogo con filtro de productos nuevos  
    Navigator.pushNamed(context, '/catalog');
  }
}

// Extension para convertir ProductModel a formato de display
extension ProductModelExtension on ProductModel {
  Map<String, dynamic> toDisplayMap() {
    return {
      'id': id,
      'name': name,
      'price': minPrice,
      'originalPrice': hasDiscount ? maxPrice : null,
      'image': mainImage,
      'rating': 4.5, // TODO: Implementar sistema de rating real
      'isFavorite': false, // TODO: Implementar sistema de favoritos real
      'category': category.name,
      'inStock': inStock,
      'hasDiscount': hasDiscount,
    };
  }
}