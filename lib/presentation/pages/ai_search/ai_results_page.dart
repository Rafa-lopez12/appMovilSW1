// lib/presentation/pages/ai_search/ai_results_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconly/iconly.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/ai_search/similar_product_card.dart';
import '../../widgets/ai_search/image_preview_widget.dart';
import '../../providers/ai_search_provider.dart';
import '../../../data/models/ai_search/similar_product_model.dart';

class AIResultsPage extends StatefulWidget {
  const AIResultsPage({Key? key}) : super(key: key);

  @override
  State<AIResultsPage> createState() => _AIResultsPageState();
}

class _AIResultsPageState extends State<AIResultsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _sortBy = 'similarity';
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<AiSearchProvider>(
        builder: (context, provider, child) {
          if (!provider.hasResults) {
            return _buildNoResultsView();
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // App Bar
              _buildAppBar(provider),
              
              // Image Preview
              SliverToBoxAdapter(
                child: _buildImagePreview(provider),
              ),
              
              // Analysis Results - Versión simplificada
              SliverToBoxAdapter(
                child: _buildSimpleAnalysisSection(provider),
              ),
              
              // Tab Bar
              SliverToBoxAdapter(
                child: _buildTabBar(provider),
              ),
              
              // Results Content
              _buildResultsContent(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(AiSearchProvider provider) {
    return SliverAppBar(
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: IconButton(
        icon: Icon(
          IconlyLight.arrow_left,
          color: AppColors.textPrimary,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.searchResults,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            '${provider.searchResults.length} productos encontrados',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _showSortOptions,
          icon: Icon(
            IconlyLight.filter,
            color: AppColors.textPrimary,
          ),
        ),
        IconButton(
          onPressed: _showFilters,
          icon: Icon(
            IconlyLight.setting,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview(AiSearchProvider provider) {
    if (provider.lastSearchedImage == null) {
      return const SizedBox();
    }

    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Container(
        margin: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
        child: ImagePreviewWidget(
          imageFile: provider.lastSearchedImage!,
          onRetry: _retrySearch,
        ),
      ),
    );
  }

  Widget _buildSimpleAnalysisSection(AiSearchProvider provider) {
    if (provider.lastAnalysis == null) {
      return const SizedBox();
    }

    final analysis = provider.lastAnalysis!;
    
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getHorizontalPadding(context),
          vertical: 16,
        ),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: AppColors.success.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.success, AppColors.accent],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    IconlyBold.star,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Análisis Completado',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${analysis.tipo} ${analysis.primaryColor} detectado',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Quick analysis info
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (analysis.tipo.isNotEmpty)
                  _buildAnalysisChip(analysis.tipo, AppColors.primary),
                if (analysis.colores.isNotEmpty)
                  _buildAnalysisChip(analysis.primaryColor, AppColors.secondary),
                if (analysis.estilo.isNotEmpty)
                  _buildAnalysisChip(analysis.estilo, AppColors.accent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildTabBar(AiSearchProvider provider) {
    final allResults = provider.searchResults;
    final highSimilarity = allResults.where((p) => p.similarity >= 0.8).toList();

    return FadeInUp(
      duration: const Duration(milliseconds: 1000),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getHorizontalPadding(context),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
          tabs: [
            Tab(
              text: 'Mejores (${highSimilarity.length})',
              icon: Icon(
                IconlyLight.star,
                size: 18,
              ),
            ),
            Tab(
              text: 'Todos (${allResults.length})',
              icon: Icon(
                IconlyLight.category,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsContent(AiSearchProvider provider) {
    final allResults = provider.searchResults;
    final highSimilarity = allResults.where((p) => p.similarity >= 0.8).toList();
    
    return SliverFillRemaining(
      child: TabBarView(
        controller: _tabController,
        children: [
          // High similarity results
          _buildProductGrid(highSimilarity),
          
          // All results
          _buildProductGrid(allResults),
        ],
      ),
    );
  }

  Widget _buildProductGrid(List<SimilarProductModel> products) {
    if (products.isEmpty) {
      return _buildEmptyResults();
    }

    return FadeInUp(
      duration: const Duration(milliseconds: 1200),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
        child: GridView.builder(
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: ResponsiveUtils.getGridColumns(context),
            childAspectRatio: 0.75,
            crossAxisSpacing: 12,
            mainAxisSpacing: 16,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return SimilarProductCard(
              product: product,
              onTap: () => _onProductTapped(product),
              onAddToCart: () => _onAddToCartTapped(product),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            IconlyLight.search,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            AppStrings.noSimilarProducts,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            AppStrings.tryDifferentImage,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          CustomButton(
            text: 'Nueva Búsqueda',
            onPressed: () => Navigator.of(context).pop(),
            icon: IconlyLight.camera,
            size: ButtonSize.medium,
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsView() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Sin Resultados'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              IconlyLight.danger,
              size: 64,
              color: AppColors.textSecondary,
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'No hay resultados disponibles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Realiza una búsqueda primero',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            
            const SizedBox(height: 24),
            
            CustomButton(
              text: 'Volver',
              onPressed: () => Navigator.of(context).pop(),
              icon: IconlyLight.arrow_left,
            ),
          ],
        ),
      ),
    );
  }

  // Event handlers
  void _retrySearch() {
    HapticFeedback.lightImpact();
    final provider = Provider.of<AiSearchProvider>(context, listen: false);
    provider.retryLastSearch();
  }

  void _showSortOptions() {
    HapticFeedback.lightImpact();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ordenar por',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildSortOption('similarity', 'Similitud', IconlyLight.star),
                  _buildSortOption('price', 'Precio', IconlyLight.buy),
                  _buildSortOption('name', 'Nombre', IconlyLight.document),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String value, String label, IconData icon) {
    final isSelected = _sortBy == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_sortBy == value) {
            _sortAscending = !_sortAscending;
          } else {
            _sortBy = value;
            _sortAscending = false;
          }
        });
        
        final provider = Provider.of<AiSearchProvider>(context, listen: false);
        provider.sortResults(_sortBy, ascending: _sortAscending);
        
        Navigator.of(context).pop();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 20,
            ),
            
            const SizedBox(width: 12),
            
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ),
            
            if (isSelected)
              Icon(
                _sortAscending ? IconlyLight.arrow_up : IconlyLight.arrow_down,
                color: AppColors.primary,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  void _showFilters() {
    HapticFeedback.lightImpact();
    
    // Versión simplificada sin bottom sheet
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Filtros avanzados próximamente'),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _onProductTapped(SimilarProductModel product) {
    HapticFeedback.lightImpact();
    Navigator.of(context).pushNamed(
      '/product-detail',
      arguments: {'productId': product.id},
    );
  }

  void _onAddToCartTapped(SimilarProductModel product) {
    HapticFeedback.lightImpact();
    // TODO: Add to cart functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} agregado al carrito'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}