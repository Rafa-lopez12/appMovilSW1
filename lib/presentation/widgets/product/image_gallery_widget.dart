// lib/presentation/widgets/product/image_gallery_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconly/iconly.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_utils.dart';

class ImageGalleryWidget extends StatefulWidget {
  final List<String> images;
  final String? heroTag;
  final double? height;
  final bool showThumbnails;
  final bool enableZoom;
  final Function(int)? onImageTap;
  final int initialIndex;

  const ImageGalleryWidget({
    Key? key,
    required this.images,
    this.heroTag,
    this.height,
    this.showThumbnails = true,
    this.enableZoom = true,
    this.onImageTap,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<ImageGalleryWidget> createState() => _ImageGalleryWidgetState();
}

class _ImageGalleryWidgetState extends State<ImageGalleryWidget>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  int _currentIndex = 0;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return _buildEmptyState();
    }

    final height = widget.height ?? MediaQuery.of(context).size.height * 0.4;

    return Container(
      height: height,
      child: Column(
        children: [
          // Main image carousel
          Expanded(
            child: _buildMainCarousel(height - (widget.showThumbnails ? 80 : 0)),
          ),
          
          // Thumbnails
          if (widget.showThumbnails && widget.images.length > 1)
            _buildThumbnails(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: widget.height ?? 300,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              IconlyLight.image,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Sin imágenes',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCarousel(double carouselHeight) {
    return Stack(
      children: [
        // Page view with images
        FadeTransition(
          opacity: _fadeAnimation,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              return _buildImageItem(widget.images[index], index);
            },
          ),
        ),
        
        // Image indicators (dots)
        if (widget.images.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: _buildImageIndicators(),
          ),
        
        // Navigation arrows (for larger screens)
        if (widget.images.length > 1 && !ResponsiveUtils.isMobile(context))
          _buildNavigationArrows(),
        
        // Zoom button
        if (widget.enableZoom)
          Positioned(
            top: 16,
            right: 16,
            child: _buildZoomButton(),
          ),
      ],
    );
  }

  Widget _buildImageItem(String imageUrl, int index) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (widget.enableZoom) {
          _showFullscreenImage(index);
        }
        widget.onImageTap?.call(index);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Hero(
            tag: widget.heroTag != null ? '${widget.heroTag}_$index' : 'image_$index',
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                
                return Container(
                  color: AppColors.background,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                              : null,
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Cargando imagen...',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.background,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          IconlyLight.danger,
                          size: 48,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar imagen',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageIndicators() {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.images.length, (index) {
          final isActive = index == _currentIndex;
          
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNavigationArrows() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Previous arrow
        if (_currentIndex > 0)
          Positioned(
            left: 16,
            child: _buildArrowButton(
              icon: IconlyLight.arrow_left_2,
              onTap: _goToPrevious,
            ),
          )
        else
          const SizedBox(width: 56), // Placeholder to maintain spacing
        
        // Next arrow
        if (_currentIndex < widget.images.length - 1)
          Positioned(
            right: 16,
            child: _buildArrowButton(
              icon: IconlyLight.arrow_right_2,
              onTap: _goToNext,
            ),
          )
        else
          const SizedBox(width: 56), // Placeholder to maintain spacing
      ],
    );
  }

  Widget _buildArrowButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
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
          icon,
          color: AppColors.textPrimary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildZoomButton() {
    return FadeInDown(
      duration: const Duration(milliseconds: 800),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _showFullscreenImage(_currentIndex);
        },
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            IconlyLight.scan,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnails() {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.getHorizontalPadding(context),
          ),
          itemCount: widget.images.length,
          itemBuilder: (context, index) {
            return _buildThumbnailItem(widget.images[index], index);
          },
        ),
      ),
    );
  }

  Widget _buildThumbnailItem(String imageUrl, int index) {
    final isActive = index == _currentIndex;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _goToImage(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 56,
        height: 56,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
            width: isActive ? 2 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.background,
                child: Icon(
                  IconlyLight.image,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNext() {
    if (_currentIndex < widget.images.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToImage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showFullscreenImage(int initialIndex) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
            _FullscreenImageGallery(
          images: widget.images,
          initialIndex: initialIndex,
          heroTag: widget.heroTag,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
        barrierDismissible: true,
        opaque: false,
      ),
    );
  }
}

// Fullscreen image gallery
class _FullscreenImageGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String? heroTag;

  const _FullscreenImageGallery({
    required this.images,
    required this.initialIndex,
    this.heroTag,
  });

  @override
  State<_FullscreenImageGallery> createState() => _FullscreenImageGalleryState();
}

class _FullscreenImageGalleryState extends State<_FullscreenImageGallery> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Image viewer
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                panEnabled: true,
                boundaryMargin: const EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: Hero(
                    tag: widget.heroTag != null 
                        ? '${widget.heroTag}_$index' 
                        : 'image_$index',
                    child: Image.network(
                      widget.images[index],
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          IconlyLight.danger,
                          size: 64,
                          color: Colors.white,
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Top bar with close button and counter
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Image counter
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentIndex + 1} de ${widget.images.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  
                  // Close button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        IconlyLight.close_square,
                        color: Colors.white,
                        size: 20,
                      ),
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
}