// lib/presentation/pages/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive_utils.dart';
// import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/search_bar_widget.dart';
import '../../widgets/product/product_card.dart';
import '../../widgets/product/category_card.dart';
import '../../widgets/common/section_header.dart';
import '../../providers/auth_provider.dart';

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
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
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
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
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
          
          // Categories
          SliverToBoxAdapter(
            child: _buildCategoriesSection(),
          ),
          
          // Featured Products
          SliverToBoxAdapter(
            child: _buildFeaturedProductsSection(),
          ),
          
          // New Products
          SliverToBoxAdapter(
            child: _buildNewProductsSection(),
          ),
          
          // Bottom spacing
          SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
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
              subtitle: 'IA Visual',
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

  Widget _buildCategoriesSection() {
    return FadeInUp(
      duration: const Duration(milliseconds: 1000),
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
              itemCount: _mockCategories.length,
              itemBuilder: (context, index) {
                final category = _mockCategories[index];
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < _mockCategories.length - 1 ? 12 : 0,
                  ),
                  child: CategoryCard(
                    title: category['name'],
                    icon: category['icon'],
                    color: category['color'],
                    onTap: () => _onCategoryTapped(category),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedProductsSection() {
    return FadeInUp(
      duration: const Duration(milliseconds: 1200),
      child: Column(
        children: [
          const SizedBox(height: 24),
          
          SectionHeader(
            title: AppStrings.recommendedProducts,
            actionText: 'Ver todos',
            onActionTap: _onViewAllFeaturedTapped,
          ),
          
          const SizedBox(height: 16),
          
          SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.getHorizontalPadding(context),
              ),
              itemCount: _mockProducts.length,
              itemBuilder: (context, index) {
                final product = _mockProducts[index];
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < _mockProducts.length - 1 ? 16 : 0,
                  ),
                  child: SizedBox(
                    width: 180,
                    child: ProductCard(
                      product: product,
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

  Widget _buildNewProductsSection() {
    return FadeInUp(
      duration: const Duration(milliseconds: 1400),
      child: Column(
        children: [
          const SizedBox(height: 24),
          
          SectionHeader(
            title: AppStrings.newProducts,
            actionText: 'Ver todos',
            onActionTap: _onViewAllNewTapped,
          ),
          
          const SizedBox(height: 16),
          
          SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.getHorizontalPadding(context),
              ),
              itemCount: _mockProducts.length,
              itemBuilder: (context, index) {
                final product = _mockProducts[index];
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < _mockProducts.length - 1 ? 16 : 0,
                  ),
                  child: SizedBox(
                    width: 180,
                    child: ProductCard(
                      product: product,
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

  // Event handlers
  void _onNotificationsTapped() {
    HapticFeedback.lightImpact();
    // TODO: Navigate to notifications
  }

  void _onSearchTapped() {
    HapticFeedback.lightImpact();
    // TODO: Navigate to search
  }

  void _onVoiceSearchTapped() {
    HapticFeedback.lightImpact();
    // TODO: Implement voice search
  }

  void _onAISearchTapped() {
    HapticFeedback.lightImpact();
    // TODO: Navigate to AI search camera
  }

  void _onVirtualTryonTapped() {
    HapticFeedback.lightImpact();
    // TODO: Navigate to virtual try-on
  }

  void _onViewAllCategoriesTapped() {
    HapticFeedback.lightImpact();
    // TODO: Navigate to categories page
  }

  void _onCategoryTapped(Map<String, dynamic> category) {
    HapticFeedback.lightImpact();
    // TODO: Navigate to category products
  }

  void _onViewAllFeaturedTapped() {
    HapticFeedback.lightImpact();
    // TODO: Navigate to featured products
  }

  void _onViewAllNewTapped() {
    HapticFeedback.lightImpact();
    // TODO: Navigate to new products
  }

  void _onProductTapped(Map<String, dynamic> product) {
    HapticFeedback.lightImpact();
    // TODO: Navigate to product detail
  }

  void _onAddToCartTapped(Map<String, dynamic> product) {
    HapticFeedback.lightImpact();
    // TODO: Add to cart
  }

  void _onFavoriteTapped(Map<String, dynamic> product) {
    HapticFeedback.lightImpact();
    // TODO: Toggle favorite
  }

  // Mock data - esto será reemplazado por providers reales
  final List<Map<String, dynamic>> _mockCategories = [
    {
      'name': 'Camisas',
      'icon': IconlyLight.paper,
      'color': AppColors.primary,
    },
    {
      'name': 'Pantalones',
      'icon': IconlyLight.category,
      'color': AppColors.secondary,
    },
    {
      'name': 'Vestidos',
      'icon': IconlyLight.star,
      'color': AppColors.accent,
    },
    {
      'name': 'Zapatos',
      'icon': IconlyLight.heart,
      'color': AppColors.warning,
    },
    {
      'name': 'Accesorios',
      'icon': IconlyLight.bag,
      'color': AppColors.success,
    },
  ];

  final List<Map<String, dynamic>> _mockProducts = [
    {
      'id': '1',
      'name': 'Camisa Elegante',
      'price': 89.99,
      'originalPrice': 120.00,
      'image': 'https://images.unsplash.com/photo-1571945153237-4929e783af4a?w=400',
      'rating': 4.5,
      'isFavorite': false,
    },
    {
      'id': '2',
      'name': 'Vestido Casual',
      'price': 65.00,
      'image': 'https://images.unsplash.com/photo-1515372039744-b8f02a3ae446?w=400',
      'rating': 4.8,
      'isFavorite': true,
    },
    {
      'id': '3',
      'name': 'Pantalón Formal',
      'price': 75.50,
      'originalPrice': 95.00,
      'image': 'https://images.unsplash.com/photo-1473966968600-fa801b869a1a?w=400',
      'rating': 4.2,
      'isFavorite': false,
    },
  ];
}