// lib/presentation/widgets/ai_search/image_preview_widget.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconly/iconly.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../widgets/common/custom_button.dart';

class ImagePreviewWidget extends StatefulWidget {
  final File imageFile;
  final VoidCallback? onRetry;
  final VoidCallback? onRemove;
  final bool showActions;

  const ImagePreviewWidget({
    Key? key,
    required this.imageFile,
    this.onRetry,
    this.onRemove,
    this.showActions = true,
  }) : super(key: key);

  @override
  State<ImagePreviewWidget> createState() => _ImagePreviewWidgetState();
}

class _ImagePreviewWidgetState extends State<ImagePreviewWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  bool _isImageLoaded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: _buildContent(),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          
          // Image
          _buildImageSection(),
          
          // Actions
          if (widget.showActions) _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
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
              IconlyBold.image,
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
                  'Imagen Seleccionada',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  _getImageInfo(),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Remove button
          if (widget.onRemove != null)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onRemove?.call();
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  IconlyLight.close_square,
                  size: 18,
                  color: AppColors.error,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    final imageHeight = ResponsiveUtils.isVerySmallScreen(context) ? 200.0 : 250.0;
    
    return Container(
      height: imageHeight,
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
        child: Stack(
          children: [
            // Main image
            Image.file(
              widget.imageFile,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (frame != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && !_isImageLoaded) {
                      setState(() {
                        _isImageLoaded = true;
                      });
                    }
                  });
                  return child;
                }
                return _buildImagePlaceholder();
              },
              errorBuilder: (context, error, stackTrace) {
                return _buildImageError();
              },
            ),
            
            // Loading overlay
            if (!_isImageLoaded)
              Container(
                color: AppColors.background.withOpacity(0.8),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ),
            
            // Image overlay with info
            if (_isImageLoaded)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildImageOverlay(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              IconlyLight.image,
              size: 48,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Cargando imagen...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageError() {
    return Container(
      color: AppColors.error.withOpacity(0.1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              IconlyLight.danger,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 12),
            Text(
              'Error cargando imagen',
              style: TextStyle(
                color: AppColors.error,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOverlay() {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.7),
            ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              IconlyLight.tick_square,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Imagen lista para analizar',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Retry button
          if (widget.onRetry != null)
            Expanded(
              child: CustomButton(
                text: 'Buscar de Nuevo',
                onPressed: widget.onRetry,
                type: ButtonType.outline,
                icon: IconlyLight.arrow_down_2,
                size: ButtonSize.medium,
              ),
            ),
          
          if (widget.onRetry != null && widget.onRemove != null)
            const SizedBox(width: 12),
          
          // Change image button
          if (widget.onRemove != null)
            Expanded(
              child: CustomButton(
                text: 'Cambiar Imagen',
                onPressed: widget.onRemove,
                type: ButtonType.secondary,
                icon: IconlyLight.image,
                size: ButtonSize.medium,
              ),
            ),
        ],
      ),
    );
  }

  String _getImageInfo() {
    try {
      final fileStat = widget.imageFile.statSync();
      final sizeInKB = (fileStat.size / 1024).round();
      final extension = widget.imageFile.path.split('.').last.toUpperCase();
      
      return '$extension • ${sizeInKB}KB';
    } catch (e) {
      return 'Imagen seleccionada';
    }
  }
}