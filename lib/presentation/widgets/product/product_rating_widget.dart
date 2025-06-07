// lib/presentation/widgets/product/product_rating_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconly/iconly.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_utils.dart';

enum RatingStyle { 
  horizontal, 
  vertical, 
  compact, 
  detailed, 
  minimal 
}

enum RatingSize { small, medium, large }

class ProductRatingWidget extends StatefulWidget {
  final double rating;
  final int? reviewCount;
  final RatingStyle style;
  final RatingSize size;
  final bool showReviewCount;
  final bool showRatingText;
  final bool isInteractive;
  final Function()? onTap;
  final Function(double)? onRatingChanged;
  final Color? starColor;
  final Color? emptyStarColor;
  final Color? textColor;
  final bool animated;
  final int maxStars;
  final bool allowHalfRating;
  final String? reviewText;
  final bool showProgressBars;

  const ProductRatingWidget({
    Key? key,
    required this.rating,
    this.reviewCount,
    this.style = RatingStyle.horizontal,
    this.size = RatingSize.medium,
    this.showReviewCount = true,
    this.showRatingText = false,
    this.isInteractive = false,
    this.onTap,
    this.onRatingChanged,
    this.starColor,
    this.emptyStarColor,
    this.textColor,
    this.animated = true,
    this.maxStars = 5,
    this.allowHalfRating = true,
    this.reviewText,
    this.showProgressBars = false,
  }) : super(key: key);

  @override
  State<ProductRatingWidget> createState() => _ProductRatingWidgetState();
}

class _ProductRatingWidgetState extends State<ProductRatingWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<AnimationController> _starControllers;
  late List<Animation<double>> _starAnimations;
  
  double _currentRating = 0.0;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.rating;
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _starControllers = List.generate(
      widget.maxStars,
      (index) => AnimationController(
        duration: Duration(milliseconds: 300 + (index * 100)),
        vsync: this,
      ),
    );

    _starAnimations = _starControllers
        .map((controller) => Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: controller, curve: Curves.elasticOut),
            ))
        .toList();

    if (widget.animated) {
      _startStarAnimations();
    } else {
      for (var controller in _starControllers) {
        controller.value = 1.0;
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var controller in _starControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(ProductRatingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rating != widget.rating) {
      setState(() {
        _currentRating = widget.rating;
      });
    }
  }

  void _startStarAnimations() {
    for (int i = 0; i < _starControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) {
          _starControllers[i].forward();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.style) {
      case RatingStyle.horizontal:
        return _buildHorizontalRating();
      case RatingStyle.vertical:
        return _buildVerticalRating();
      case RatingStyle.compact:
        return _buildCompactRating();
      case RatingStyle.detailed:
        return _buildDetailedRating();
      case RatingStyle.minimal:
        return _buildMinimalRating();
    }
  }

  Widget _buildHorizontalRating() {
    return GestureDetector(
      onTap: widget.isInteractive ? () {
        HapticFeedback.lightImpact();
        widget.onTap?.call();
      } : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildStarRow(),
          if (widget.showRatingText || widget.showReviewCount) ...[
            const SizedBox(width: 8),
            _buildRatingInfo(),
          ],
        ],
      ),
    );
  }

  Widget _buildVerticalRating() {
    return GestureDetector(
      onTap: widget.isInteractive ? () {
        HapticFeedback.lightImpact();
        widget.onTap?.call();
      } : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStarRow(),
          if (widget.showRatingText || widget.showReviewCount) ...[
            const SizedBox(height: 8),
            _buildRatingInfo(),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactRating() {
    return GestureDetector(
      onTap: widget.isInteractive ? () {
        HapticFeedback.lightImpact();
        widget.onTap?.call();
      } : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: _getStarSize(),
            color: widget.starColor ?? AppColors.ratingFilled,
          ),
          const SizedBox(width: 4),
          Text(
            _currentRating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: _getTextSize(),
              fontWeight: FontWeight.w600,
              color: widget.textColor ?? AppColors.textPrimary,
            ),
          ),
          if (widget.showReviewCount && widget.reviewCount != null) ...[
            const SizedBox(width: 4),
            Text(
              '(${widget.reviewCount})',
              style: TextStyle(
                fontSize: _getTextSize() - 2,
                color: widget.textColor?.withOpacity(0.7) ?? AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailedRating() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Calificación general',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          _currentRating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStarRow(),
                            if (widget.reviewCount != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                '${widget.reviewCount} reseñas',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (widget.showProgressBars) ...[
            const SizedBox(height: 16),
            _buildRatingBreakdown(),
          ],
        ],
      ),
    );
  }

  Widget _buildMinimalRating() {
    return _buildStarRow();
  }

  Widget _buildStarRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.maxStars, (index) {
        return AnimatedBuilder(
          animation: _starAnimations[index],
          builder: (context, child) {
            return Transform.scale(
              scale: _starAnimations[index].value,
              child: _buildStar(index),
            );
          },
        );
      }),
    );
  }

  Widget _buildStar(int index) {
    final double value = _currentRating - index;
    IconData iconData;
    Color color;

    if (value >= 1.0) {
      iconData = Icons.star;
      color = widget.starColor ?? AppColors.ratingFilled;
    } else if (value >= 0.5 && widget.allowHalfRating) {
      iconData = Icons.star_half;
      color = widget.starColor ?? AppColors.ratingFilled;
    } else {
      iconData = Icons.star_border;
      color = widget.emptyStarColor ?? AppColors.ratingEmpty;
    }

    return GestureDetector(
      onTap: widget.isInteractive ? () {
        HapticFeedback.lightImpact();
        final newRating = (index + 1).toDouble();
        setState(() {
          _currentRating = newRating;
        });
        widget.onRatingChanged?.call(newRating);
      } : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1),
        child: Icon(
          iconData,
          size: _getStarSize(),
          color: color,
        ),
      ),
    );
  }

  Widget _buildRatingInfo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showRatingText) ...[
          Text(
            _currentRating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: _getTextSize(),
              fontWeight: FontWeight.w600,
              color: widget.textColor ?? AppColors.textPrimary,
            ),
          ),
          if (widget.showReviewCount && widget.reviewCount != null)
            const SizedBox(width: 4),
        ],
        
        if (widget.showReviewCount && widget.reviewCount != null) ...[
          Text(
            widget.reviewText ?? '(${widget.reviewCount} reseñas)',
            style: TextStyle(
              fontSize: _getTextSize() - 2,
              color: widget.textColor?.withOpacity(0.7) ?? AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRatingBreakdown() {
    // Mock data for rating breakdown
    final ratingData = [
      {'stars': 5, 'percentage': 0.7},
      {'stars': 4, 'percentage': 0.15},
      {'stars': 3, 'percentage': 0.08},
      {'stars': 2, 'percentage': 0.04},
      {'stars': 1, 'percentage': 0.03},
    ];

    return Column(
      children: ratingData.map((data) {
        final stars = data['stars'] as int;
        final percentage = data['percentage'] as double;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Text(
                '$stars',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.star,
                size: 12,
                color: AppColors.ratingFilled,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: AppColors.ratingEmpty,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.ratingFilled),
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
      }).toList(),
    );
  }

  double _getStarSize() {
    switch (widget.size) {
      case RatingSize.small:
        return 14;
      case RatingSize.medium:
        return 18;
      case RatingSize.large:
        return 24;
    }
  }

  double _getTextSize() {
    switch (widget.size) {
      case RatingSize.small:
        return 12;
      case RatingSize.medium:
        return 14;
      case RatingSize.large:
        return 16;
    }
  }
}

// Widget simple para mostrar solo estrellas
class SimpleStarRatingWidget extends StatelessWidget {
  final double rating;
  final double starSize;
  final Color? starColor;
  final Color? emptyStarColor;
  final bool allowHalfRating;

  const SimpleStarRatingWidget({
    Key? key,
    required this.rating,
    this.starSize = 16,
    this.starColor,
    this.emptyStarColor,
    this.allowHalfRating = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProductRatingWidget(
      rating: rating,
      style: RatingStyle.minimal,
      size: RatingSize.small,
      starColor: starColor,
      emptyStarColor: emptyStarColor,
      allowHalfRating: allowHalfRating,
      animated: false,
    );
  }
}

// Widget para tarjetas de producto
class ProductCardRatingWidget extends StatelessWidget {
  final double rating;
  final int? reviewCount;

  const ProductCardRatingWidget({
    Key? key,
    required this.rating,
    this.reviewCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProductRatingWidget(
      rating: rating,
      reviewCount: reviewCount,
      style: RatingStyle.compact,
      size: RatingSize.small,
      animated: false,
    );
  }
}

// Widget interactivo para dejar reseñas
class InteractiveRatingWidget extends StatelessWidget {
  final double rating;
  final Function(double) onRatingChanged;
  final String? title;

  const InteractiveRatingWidget({
    Key? key,
    required this.rating,
    required this.onRatingChanged,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        ProductRatingWidget(
          rating: rating,
          style: RatingStyle.horizontal,
          size: RatingSize.large,
          isInteractive: true,
          onRatingChanged: onRatingChanged,
          showRatingText: true,
          animated: true,
        ),
      ],
    );
  }
}

// Widget para detalle de producto
class ProductDetailRatingWidget extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final Function()? onTap;

  const ProductDetailRatingWidget({
    Key? key,
    required this.rating,
    required this.reviewCount,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProductRatingWidget(
      rating: rating,
      reviewCount: reviewCount,
      style: RatingStyle.horizontal,
      size: RatingSize.medium,
      showReviewCount: true,
      showRatingText: true,
      isInteractive: onTap != null,
      onTap: onTap,
      reviewText: '$reviewCount reseñas',
    );
  }
}

// Widget para página de reseñas completa
class ReviewSummaryWidget extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final bool showBreakdown;

  const ReviewSummaryWidget({
    Key? key,
    required this.rating,
    required this.reviewCount,
    this.showBreakdown = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProductRatingWidget(
      rating: rating,
      reviewCount: reviewCount,
      style: RatingStyle.detailed,
      size: RatingSize.medium,
      showProgressBars: showBreakdown,
      animated: true,
    );
  }
}