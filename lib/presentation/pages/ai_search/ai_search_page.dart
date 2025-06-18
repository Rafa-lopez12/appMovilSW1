// lib/presentation/pages/ai_search/ai_search_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconly/iconly.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/ai_search/upload_image_card.dart';
import '../../widgets/ai_search/search_history_card.dart';
import '../../providers/ai_search_provider.dart';

class AISearchPage extends StatefulWidget {
  const AISearchPage({Key? key}) : super(key: key);

  @override
  State<AISearchPage> createState() => _AISearchPageState();
}

class _AISearchPageState extends State<AISearchPage>
    with AutomaticKeepAliveClientMixin {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar
          _buildAppBar(),
          
          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.getHorizontalPadding(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  
                  // Hero Section
                  _buildHeroSection(),
                  
                  const SizedBox(height: 32),
                  
                  // Upload Section
                  _buildUploadSection(),
                  
                  const SizedBox(height: 32),
                  
                  // Search Settings
                  _buildSearchSettings(),
                  
                  const SizedBox(height: 32),
                  
                  // Search History
                  _buildSearchHistory(),
                  
                  const SizedBox(height: 100), // Bottom padding for nav bar
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      pinned: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      toolbarHeight: 70,
      title: FadeInDown(
        duration: const Duration(milliseconds: 600),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                IconlyBold.search,
                color: Colors.white,
                size: 20,
              ),
            ),
            
            const SizedBox(width: 12),
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.aiSearch,
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Busca con inteligencia artificial',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        Consumer<AiSearchProvider>(
          builder: (context, provider, child) {
            if (!provider.hasResults) return const SizedBox();
            
            return FadeInDown(
              duration: const Duration(milliseconds: 800),
              child: IconButton(
                onPressed: _showSearchSettings,
                icon: Icon(
                  IconlyLight.setting,
                  color: AppColors.textPrimary,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.secondary.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  IconlyBold.camera,
                  color: AppColors.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppStrings.searchByImage,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Text(
              AppStrings.searchByImageDescription,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Quick stats
            Row(
              children: [
                _buildStatItem(
                  icon: IconlyLight.image,
                  label: 'Imágenes procesadas',
                  value: '1.2K+',
                ),
                const SizedBox(width: 24),
                _buildStatItem(
                  icon: IconlyLight.star,
                  label: 'Precisión',
                  value: '95%',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUploadSection() {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: Column(
        children: [
          SectionHeader(
            title: 'Subir Imagen',
            titleColor: AppColors.textPrimary,
          ),
          
          const SizedBox(height: 16),
          
          Consumer<AiSearchProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return _buildLoadingCard();
              }
              
              return UploadImageCard(
                onTap: _pickImageFromGallery,
                isLoading: provider.isLoading,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 200,
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
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            AppStrings.analyzing,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Analizando tu imagen con IA...',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSettings() {
    return Consumer<AiSearchProvider>(
      builder: (context, provider, child) {
        return FadeInUp(
          duration: const Duration(milliseconds: 1000),
          child: Column(
            children: [
              SectionHeader(
                title: 'Configuración de Búsqueda',
                titleColor: AppColors.textPrimary,
              ),
              
              const SizedBox(height: 16),
              
              Container(
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
                ),
                child: Column(
                  children: [
                    // Limit setting
                    _buildSettingRow(
                      title: 'Límite de resultados',
                      subtitle: '${provider.searchLimit} productos',
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              if (provider.searchLimit > 5) {
                                provider.setSearchLimit(provider.searchLimit - 5);
                              }
                            },
                            icon: Icon(
                              Icons.remove_circle_outline,
                              color: AppColors.primary,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              if (provider.searchLimit < 50) {
                                provider.setSearchLimit(provider.searchLimit + 5);
                              }
                            },
                            icon: Icon(
                              Icons.add_circle_outline,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    Divider(color: AppColors.divider),
                    
                    // Similarity setting
                    _buildSettingRow(
                      title: 'Similitud mínima',
                      subtitle: '${(provider.minSimilarity * 100).toInt()}%',
                      trailing: SizedBox(
                        width: 120,
                        child: Slider(
                          value: provider.minSimilarity,
                          min: 0.1,
                          max: 1.0,
                          divisions: 9,
                          activeColor: AppColors.primary,
                          onChanged: (value) {
                            provider.setMinSimilarity(value);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingRow({
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
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
        trailing,
      ],
    );
  }

  Widget _buildSearchHistory() {
    return Consumer<AiSearchProvider>(
      builder: (context, provider, child) {
        if (!provider.hasResults) {
          return const SizedBox();
        }

        return FadeInUp(
          duration: const Duration(milliseconds: 1200),
          child: Column(
            children: [
              SectionHeader(
                title: 'Última Búsqueda',
                actionText: 'Ver resultados',
                onActionTap: _navigateToResults,
                titleColor: AppColors.textPrimary,
              ),
              
              const SizedBox(height: 16),
              
              SearchHistoryCard(
                analysis: provider.lastAnalysis!,
                resultCount: provider.searchResults.length,
                onTap: _navigateToResults,
              ),
            ],
          ),
        );
      },
    );
  }

  // Event handlers
  Future<void> _pickImageFromGallery() async {
    try {
      HapticFeedback.lightImpact();
      
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return;

      final imageFile = File(image.path);
      
      if (!mounted) return;
      
      final provider = Provider.of<AiSearchProvider>(context, listen: false);
      
      await provider.searchByImageFile(imageFile);
      
      if (provider.hasResults && mounted) {
        _navigateToResults();
      } else if (provider.hasError && mounted) {
        _showErrorDialog(provider.errorMessage ?? 'Error en la búsqueda');
      }
      
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error seleccionando imagen: $e');
      }
    }
  }

  void _navigateToResults() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pushNamed('/ai-search-results');
  }

  void _showSearchSettings() {
    HapticFeedback.lightImpact();
    // TODO: Show bottom sheet with advanced settings
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Error',
          style: TextStyle(color: AppColors.error),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}