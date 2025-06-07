// lib/presentation/widgets/cart/cart_summary_widget.dart
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconly/iconly.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_utils.dart';

class CartSummaryWidget extends StatelessWidget {
  final double subtotal;
  final double shipping;
  final double tax;
  final double total;
  final int itemCount;
  final bool showItemCount;
  final bool showShipping;
  final bool showTax;
  final bool showDiscounts;
  final double? discount;
  final String? promoCode;
  final VoidCallback? onPromoCodeTap;
  final bool isExpanded;
  final bool animated;

  const CartSummaryWidget({
    Key? key,
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.total,
    required this.itemCount,
    this.showItemCount = true,
    this.showShipping = true,
    this.showTax = true,
    this.showDiscounts = false,
    this.discount,
    this.promoCode,
    this.onPromoCodeTap,
    this.isExpanded = true,
    this.animated = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (animated) {
      return FadeInUp(
        duration: const Duration(milliseconds: 600),
        child: _buildContent(),
      );
    }
    return _buildContent();
  }

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          
          if (isExpanded) ...[
            const SizedBox(height: 12),
            
            // Summary details
            _buildSummaryDetails(),
            
            const SizedBox(height: 12),
            
            // Divider
            Container(
              height: 1,
              color: AppColors.border,
            ),
            
            const SizedBox(height: 12),
            
            // Total
            _buildTotal(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Resumen del pedido',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        
        if (showItemCount)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$itemCount ${itemCount == 1 ? 'artículo' : 'artículos'}',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryDetails() {
    return Column(
      children: [
        // Subtotal
        _buildSummaryRow(
          'Subtotal',
          '\$${subtotal.toStringAsFixed(2)}',
        ),
        
        // Discount
        if (showDiscounts && discount != null && discount! > 0) ...[
          const SizedBox(height: 8),
          _buildSummaryRow(
            'Descuento${promoCode != null ? ' ($promoCode)' : ''}',
            '-\$${discount!.toStringAsFixed(2)}',
            valueColor: AppColors.success,
            showIcon: true,
            icon: IconlyLight.discount,
          ),
        ],
        
        // Shipping
        if (showShipping) ...[
          const SizedBox(height: 8),
          _buildSummaryRow(
            'Envío',
            shipping == 0 ? 'Gratis' : '\$${shipping.toStringAsFixed(2)}',
            valueColor: shipping == 0 ? AppColors.success : null,
            showIcon: shipping == 0,
            icon: IconlyLight.tick_square,
          ),
        ],
        
        // Tax
        if (showTax && tax > 0) ...[
          const SizedBox(height: 8),
          _buildSummaryRow(
            'Impuestos',
            '\$${tax.toStringAsFixed(2)}',
          ),
        ],
        
        // Promo code button
        if (showDiscounts && promoCode == null) ...[
          const SizedBox(height: 12),
          _buildPromoCodeButton(),
        ],
      ],
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    Color? valueColor,
    bool showIcon = false,
    IconData? icon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon && icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: valueColor ?? AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTotal() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Total',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        
        Text(
          '\$${total.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildPromoCodeButton() {
    return GestureDetector(
      onTap: onPromoCodeTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.primary,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              IconlyLight.ticket,
              size: 16,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Agregar código promocional',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget compacto para mini carrito
class MiniCartSummaryWidget extends StatelessWidget {
  final double total;
  final int itemCount;

  const MiniCartSummaryWidget({
    Key? key,
    required this.total,
    required this.itemCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$itemCount ${itemCount == 1 ? 'artículo' : 'artículos'}',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          
          Text(
            '\$${total.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget expandible para checkout
class CheckoutSummaryWidget extends StatefulWidget {
  final double subtotal;
  final double shipping;
  final double tax;
  final double total;
  final int itemCount;
  final double? discount;
  final String? promoCode;
  final VoidCallback? onPromoCodeTap;
  final VoidCallback? onEditCart;

  const CheckoutSummaryWidget({
    Key? key,
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.total,
    required this.itemCount,
    this.discount,
    this.promoCode,
    this.onPromoCodeTap,
    this.onEditCart,
  }) : super(key: key);

  @override
  State<CheckoutSummaryWidget> createState() => _CheckoutSummaryWidgetState();
}

class _CheckoutSummaryWidgetState extends State<CheckoutSummaryWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
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
          // Header (always visible)
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Resumen del pedido',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.itemCount} ${widget.itemCount == 1 ? 'artículo' : 'artículos'} • \$${widget.total.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.onEditCart != null)
                        GestureDetector(
                          onTap: widget.onEditCart,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              IconlyLight.edit,
                              size: 18,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      
                      const SizedBox(width: 8),
                      
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          IconlyLight.arrow_down_2,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Expanded content
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isExpanded ? null : 0,
            child: _isExpanded
                ? Container(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: CartSummaryWidget(
                      subtotal: widget.subtotal,
                      shipping: widget.shipping,
                      tax: widget.tax,
                      total: widget.total,
                      itemCount: widget.itemCount,
                      showItemCount: false,
                      showDiscounts: true,
                      discount: widget.discount,
                      promoCode: widget.promoCode,
                      onPromoCodeTap: widget.onPromoCodeTap,
                      isExpanded: true,
                      animated: false,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// Widget para mostrar ahorros
class SavingsWidget extends StatelessWidget {
  final double originalTotal;
  final double finalTotal;
  final String? description;

  const SavingsWidget({
    Key? key,
    required this.originalTotal,
    required this.finalTotal,
    this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final savings = originalTotal - finalTotal;
    
    if (savings <= 0) {
      return const SizedBox.shrink();
    }

    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.success.withOpacity(0.1),
              AppColors.success.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.success.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: Icon(
                IconlyLight.tick_square,
                size: 16,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(width: 12),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Estás ahorrando \$${savings.toStringAsFixed(2)}!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                  
                  if (description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      description!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.success.withOpacity(0.8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}