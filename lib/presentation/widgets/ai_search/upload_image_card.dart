// lib/presentation/widgets/ai_search/upload_image_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconly/iconly.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive_utils.dart';

class UploadImageCard extends StatefulWidget {
  final VoidCallback onTap;
  final bool isLoading;
  final String? selectedImagePath;

  const UploadImageCard({
    Key? key,
    required this.onTap,
    this.isLoading = false,
    this.selectedImagePath,
  }) : super(key: key);

  @override
  State<UploadImageCard> createState() => _UploadImageCardState();
}

class _UploadImageCardState extends State<UploadImageCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
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
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * 0.1,
            child: GestureDetector(
              onTapDown: (_) {
                if (!widget.isLoading) {
                  setState(() => _isPressed = true);
                  _animationController.forward();
                }
              },
              onTapUp: (_) {
                if (!widget.isLoading) {
                  setState(() => _isPressed = false);
                  _animationController.reverse();
                  HapticFeedback.lightImpact();
                  widget.onTap();
                }
              },
              onTapCancel: () {
                if (!widget.isLoading) {
                  setState(() => _isPressed = false);
                  _animationController.reverse();
                }
              },
              child: _buildCard(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard() {
    return Container(
      height: ResponsiveUtils.isVerySmallScreen(context) ? 180 : 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: widget.isLoading 
                ? AppColors.primary.withOpacity(0.2)
                : Colors.black.withOpacity(0.08),
            blurRadius: widget.isLoading ? 20 : 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: widget.isLoading 
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.border.withOpacity(0.5),
          width: widget.isLoading ? 2 : 1,
        ),
      ),
      child: widget.isLoading 
          ? _buildLoadingContent()
          : _buildUploadContent(),
    );
  }

  Widget _buildLoadingContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated loading indicator
        Pulse(
          infinite: true,
          duration: const Duration(milliseconds: 1000),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              IconlyBold.image,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Loading text
        FadeInUp(
          child: Text(
            AppStrings.analyzing,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        FadeInUp(
          delay: const Duration(milliseconds: 200),
          child: Text(
            'Procesando imagen con IA...',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Progress indicator
        SizedBox(
          width: 100,
          child: LinearProgressIndicator(
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Upload icon with animation
        FadeInDown(
          duration: const Duration(milliseconds: 600),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.secondary.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Icon(
              IconlyLight.image,
              size: 36,
              color: AppColors.primary,
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Title
        FadeInUp(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 200),
          child: Text(
            AppStrings.chooseFromGallery,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Subtitle
        FadeInUp(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 400),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Selecciona una imagen de tu galería para encontrar productos similares',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Supported formats
        FadeInUp(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 600),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  IconlyLight.tick_square,
                  size: 16,
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                Text(
                  'JPG, PNG, WEBP (max 5MB)',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}