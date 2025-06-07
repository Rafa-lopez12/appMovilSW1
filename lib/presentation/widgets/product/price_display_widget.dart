// lib/presentation/widgets/product/price_display_widget.dart
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconly/iconly.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_utils.dart';

enum PriceDisplayStyle { 
  horizontal, 
  vertical, 
  compact, 
  card, 
  minimal 
}

enum PriceSize { small, medium, large, extraLarge }

class PriceDisplayWidget extends StatefulWidget {
  final double currentPrice;
  final double? originalPrice;
  final String currency;
  final bool showDiscount;
  final bool showSavings;
  final PriceDisplayStyle style;
  final PriceSize size;
  final Color? priceColor;
  final Color? originalPriceColor;
  final Color? discountColor;
  final bool showCurrency;
  final bool animated;
  final String? discountLabel;
  final bool showPercentage;
  final bool showAmount;
  final TextAlign alignment;

  const PriceDisplayWidget({
    Key? key,
    required this.currentPrice,
    this.originalPrice,
    this.currency = '\$',
    this.showDiscount = true,
    this.showSavings = false,
    this.style = PriceDisplayStyle.horizontal,
    this.size = PriceSize.medium,
    this.priceColor,
    this.originalPriceColor,
    this.discountColor,
    this.showCurrency = true,
    this.animated = true,
    this.discountLabel,
    this.showPercentage = true,
    this.showAmount = false,
    this.alignment = TextAlign.left,
  }) : super(key: key);

  @override
  State<PriceDisplayWidget> createState() => _PriceDisplayWidgetState();
}

class _PriceDisplayWidgetState extends State<PriceDisplayWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    if (widget.animated) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
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
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: _buildPriceDisplay(),
          ),
        );
      },
    );
  }

  Widget _buildPriceDisplay() {
    switch (widget.style) {
      case PriceDisplayStyle.horizontal:
        return _buildHorizontalPrice();
      case PriceDisplayStyle.vertical:
        return _buildVerticalPrice();
      case PriceDisplayStyle.compact:
        return _buildCompactPrice();
      case PriceDisplayStyle.card:
        return _buildCardPrice();
      case PriceDisplayStyle.minimal:
        return _buildMinimalPrice();
    }
  }

  Widget _buildHorizontalPrice() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        _buildCurrentPrice(),
        if (_hasDiscount()) ...[
          const SizedBox(width: 8),
          _buildOriginalPrice(),
        ],
        if (_hasDiscount() && widget.showDiscount) ...[
          const SizedBox(width: 8),
          _buildDiscountBadge(),
        ],
      ],
    );
  }

  Widget _buildVerticalPrice() {
    return Column(
      crossAxisAlignment: _getColumnAlignment(),
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCurrentPrice(),
        if (_hasDiscount()) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildOriginalPrice(),
              if (widget.showDiscount) ...[
                const SizedBox(width: 8),
                _buildDiscountBadge(),
              ],
            ],
          ),
        ],
        if (widget.showSavings && _hasDiscount()) ...[
          const SizedBox(height: 4),
          _buildSavingsText(),
        ],
      ],
    );
  }

  Widget _buildCompactPrice() {
    if (!_hasDiscount()) {
      return _buildCurrentPrice();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCurrentPrice(),
        const SizedBox(width: 6),
        _buildOriginalPrice(isCompact: true),
        if (widget.showDiscount) ...[
          const SizedBox(width: 6),
          _buildDiscountBadge(isCompact: true),
        ],
      ],
    );
  }

  Widget _buildCardPrice() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: _hasDiscount() 
            ? LinearGradient(
                colors: [
                  AppColors.success.withOpacity(0.1),
                  AppColors.success.withOpacity(0.05),
                ],
              )
            : null,
        color: _hasDiscount() ? null : AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _hasDiscount() 
              ? AppColors.success.withOpacity(0.3)
              : AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCurrentPrice(),
              if (_hasDiscount() && widget.showDiscount)
                _buildDiscountBadge(),
            ],
          ),
          if (_hasDiscount()) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Precio anterior: ',
                  style: TextStyle(
                    fontSize: _getFontSize(PriceSize.small),
                    color: AppColors.textSecondary,
                  ),
                ),
                _buildOriginalPrice(showLabel: false),
              ],
            ),
          ],
          if (widget.showSavings && _hasDiscount()) ...[
            const SizedBox(height: 4),
            _buildSavingsText(),
          ],
        ],
      ),
    );
  }

  Widget _buildMinimalPrice() {
    return Text(
      _formatPrice(widget.currentPrice),
      style: TextStyle(
        fontSize: _getFontSize(widget.size),
        fontWeight: FontWeight.bold,
        color: widget.priceColor ?? AppColors.primary,
      ),
      textAlign: widget.alignment,
    );
  }

  Widget _buildCurrentPrice() {
    return Text(
      _formatPrice(widget.currentPrice),
      style: TextStyle(
        fontSize: _getFontSize(widget.size),
        fontWeight: FontWeight.bold,
        color: widget.priceColor ?? (_hasDiscount() ? AppColors.success : AppColors.primary),
      ),
      textAlign: widget.alignment,
    );
  }

  Widget _buildOriginalPrice({bool isCompact = false, bool showLabel = true}) {
    if (widget.originalPrice == null) return const SizedBox.shrink();

    return Text(
      _formatPrice(widget.originalPrice!),
      style: TextStyle(
        fontSize: _getFontSize(isCompact ? PriceSize.small : _getPreviousSize(widget.size)),
        fontWeight: FontWeight.w500,
        color: widget.originalPriceColor ?? AppColors.textSecondary,
        decoration: TextDecoration.lineThrough,
        decorationColor: widget.originalPriceColor ?? AppColors.textSecondary,
        decorationThickness: 2,
      ),
      textAlign: widget.alignment,
    );
  }

  Widget _buildDiscountBadge({bool isCompact = false}) {
    if (!_hasDiscount()) return const SizedBox.shrink();

    final discountPercentage = _getDiscountPercentage();
    final discountAmount = _getDiscountAmount();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 6 : 8,
        vertical: isCompact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: widget.discountColor ?? AppColors.error,
        borderRadius: BorderRadius.circular(isCompact ? 4 : 6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isCompact) ...[
            Icon(
              IconlyLight.discount,
              size: 12,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            widget.discountLabel ?? _getDiscountText(discountPercentage, discountAmount),
            style: TextStyle(
              fontSize: isCompact ? 10 : 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsText() {
    if (!_hasDiscount()) return const SizedBox.shrink();

    final savings = _getDiscountAmount();
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          IconlyLight.tick_square,
          size: 14,
          color: AppColors.success,
        ),
        const SizedBox(width: 4),
        Text(
          'Ahorras ${_formatPrice(savings)}',
          style: TextStyle(
            fontSize: _getFontSize(PriceSize.small),
            fontWeight: FontWeight.w600,
            color: AppColors.success,
          ),
        ),
      ],
    );
  }

  // Helper methods
  bool _hasDiscount() {
    return widget.originalPrice != null && 
           widget.originalPrice! > widget.currentPrice;
  }

  double _getDiscountPercentage() {
    if (!_hasDiscount()) return 0.0;
    return ((widget.originalPrice! - widget.currentPrice) / widget.originalPrice!) * 100;
  }

  double _getDiscountAmount() {
    if (!_hasDiscount()) return 0.0;
    return widget.originalPrice! - widget.currentPrice;
  }

  String _getDiscountText(double percentage, double amount) {
    if (widget.showPercentage && widget.showAmount) {
      return '-${percentage.toStringAsFixed(0)}% (${_formatPrice(amount)})';
    } else if (widget.showPercentage) {
      return '-${percentage.toStringAsFixed(0)}%';
    } else if (widget.showAmount) {
      return '-${_formatPrice(amount)}';
    } else {
      return '-${percentage.toStringAsFixed(0)}%';
    }
  }

  String _formatPrice(double price) {
    if (widget.showCurrency) {
      return '${widget.currency}${price.toStringAsFixed(2)}';
    } else {
      return price.toStringAsFixed(2);
    }
  }

  double _getFontSize(PriceSize size) {
    switch (size) {
      case PriceSize.small:
        return 12;
      case PriceSize.medium:
        return 16;
      case PriceSize.large:
        return 20;
      case PriceSize.extraLarge:
        return 24;
    }
  }

  PriceSize _getPreviousSize(PriceSize size) {
    switch (size) {
      case PriceSize.small:
        return PriceSize.small;
      case PriceSize.medium:
        return PriceSize.small;
      case PriceSize.large:
        return PriceSize.medium;
      case PriceSize.extraLarge:
        return PriceSize.large;
    }
  }

  CrossAxisAlignment _getColumnAlignment() {
    switch (widget.alignment) {
      case TextAlign.left:
        return CrossAxisAlignment.start;
      case TextAlign.center:
        return CrossAxisAlignment.center;
      case TextAlign.right:
        return CrossAxisAlignment.end;
      default:
        return CrossAxisAlignment.start;
    }
  }
}

// Widget simplificado para mostrar solo precio actual
class SimplePriceWidget extends StatelessWidget {
  final double price;
  final String currency;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;

  const SimplePriceWidget({
    Key? key,
    required this.price,
    this.currency = '\$',
    this.color,
    this.fontSize,
    this.fontWeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      '$currency${price.toStringAsFixed(2)}',
      style: TextStyle(
        fontSize: fontSize ?? 16,
        fontWeight: fontWeight ?? FontWeight.bold,
        color: color ?? AppColors.primary,
      ),
    );
  }
}

// Widget para mostrar precio con descuento simple
class DiscountPriceWidget extends StatelessWidget {
  final double currentPrice;
  final double originalPrice;
  final String currency;
  final bool showPercentage;

  const DiscountPriceWidget({
    Key? key,
    required this.currentPrice,
    required this.originalPrice,
    this.currency = '\$',
    this.showPercentage = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PriceDisplayWidget(
      currentPrice: currentPrice,
      originalPrice: originalPrice,
      currency: currency,
      style: PriceDisplayStyle.horizontal,
      size: PriceSize.medium,
      showDiscount: showPercentage,
      showPercentage: showPercentage,
    );
  }
}

// Widget para tarjetas de producto
class ProductCardPriceWidget extends StatelessWidget {
  final double currentPrice;
  final double? originalPrice;
  final String currency;

  const ProductCardPriceWidget({
    Key? key,
    required this.currentPrice,
    this.originalPrice,
    this.currency = '\$',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PriceDisplayWidget(
      currentPrice: currentPrice,
      originalPrice: originalPrice,
      currency: currency,
      style: PriceDisplayStyle.compact,
      size: PriceSize.small,
      animated: false,
    );
  }
}

// Widget para página de detalle de producto
class ProductDetailPriceWidget extends StatelessWidget {
  final double currentPrice;
  final double? originalPrice;
  final String currency;
  final bool showSavings;

  const ProductDetailPriceWidget({
    Key? key,
    required this.currentPrice,
    this.originalPrice,
    this.currency = '\$',
    this.showSavings = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PriceDisplayWidget(
      currentPrice: currentPrice,
      originalPrice: originalPrice,
      currency: currency,
      style: PriceDisplayStyle.vertical,
      size: PriceSize.extraLarge,
      showSavings: showSavings,
      showDiscount: true,
      animated: true,
    );
  }
}

// Widget para carrito
class CartPriceWidget extends StatelessWidget {
  final double price;
  final int quantity;
  final String currency;

  const CartPriceWidget({
    Key? key,
    required this.price,
    required this.quantity,
    this.currency = '\$',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalPrice = price * quantity;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (quantity > 1) ...[
          Text(
            '$currency${price.toStringAsFixed(2)} c/u',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
        ],
        Text(
          '$currency${totalPrice.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}