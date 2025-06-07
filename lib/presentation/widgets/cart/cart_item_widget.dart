// lib/presentation/widgets/cart/cart_item_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconly/iconly.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_utils.dart';
import '../product/quantity_selector_widget.dart';
import '../product/price_display_widget.dart';

class CartItemWidget extends StatefulWidget {
  final dynamic item; // CartItem from cart_provider
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;
  final VoidCallback? onTap;
  final bool showRemoveButton;
  final bool showQuantitySelector;

  const CartItemWidget({
    Key? key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
    this.onTap,
    this.showRemoveButton = true,
    this.showQuantitySelector = true,
  }) : super(key: key);

  @override
  State<CartItemWidget> createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<CartItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  
  bool _isRemoving = false;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                _buildProductImage(),
                
                const SizedBox(width: 16),
                
                // Product Info
                Expanded(
                  child: _buildProductInfo(),
                ),
                
                // Actions (Remove button)
                if (widget.showRemoveButton)
                  _buildRemoveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.background,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: widget.item.image.isNotEmpty
              ? Image.network(
                  widget.item.image,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.background,
                      child: Icon(
                        IconlyLight.image,
                        size: 32,
                        color: AppColors.textSecondary,
                      ),
                    );
                  },
                )
              : Icon(
                  IconlyLight.image,
                  size: 32,
                  color: AppColors.textSecondary,
                ),
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Name
        Text(
          widget.item.name ?? 'Producto',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: 8),
        
        // Variants (Size and Color)
        _buildVariantInfo(),
        
        const SizedBox(height: 12),
        
        // Price and Quantity Row
        Row(
          children: [
            // Price
            Expanded(
              child: CartPriceWidget(
                price: widget.item.price,
                quantity: widget.item.quantity,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Quantity Selector
            if (widget.showQuantitySelector)
              CartQuantitySelectorWidget(
                quantity: widget.item.quantity,
                onQuantityChanged: widget.onQuantityChanged,
                maxQuantity: 99, // TODO: Get from product stock
                enabled: !_isRemoving,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildVariantInfo() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        // Size
        if (widget.item.size != null && widget.item.size.isNotEmpty)
          _buildVariantChip(
            label: 'Talla',
            value: widget.item.size,
            icon: IconlyLight.category,
          ),
        
        // Color
        if (widget.item.color != null && widget.item.color.isNotEmpty)
          _buildVariantChip(
            label: 'Color',
            value: widget.item.color,
            icon: IconlyLight.star,
            color: _getColorFromName(widget.item.color),
          ),
      ],
    );
  }

  Widget _buildVariantChip({
    required String label,
    required String value,
    required IconData icon,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (color != null)
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
            )
          else
            Icon(
              icon,
              size: 12,
              color: AppColors.textSecondary,
            ),
          
          const SizedBox(width: 4),
          
          Text(
            '$label: $value',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemoveButton() {
    return GestureDetector(
      onTap: _isRemoving ? null : _handleRemove,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.error.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: _isRemoving
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.error),
                ),
              )
            : Icon(
                IconlyLight.delete,
                size: 16,
                color: AppColors.error,
              ),
      ),
    );
  }

  void _handleRemove() async {
    HapticFeedback.lightImpact();
    
    // Show confirmation dialog
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('¿Quieres eliminar "${widget.item.name}" del carrito?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldRemove == true) {
      setState(() {
        _isRemoving = true;
      });

      // Animate slide out
      await _slideController.forward();
      
      // Call remove callback
      widget.onRemove();
    }
  }

  Color? _getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'rojo':
      case 'red':
        return Colors.red;
      case 'azul':
      case 'blue':
        return Colors.blue;
      case 'verde':
      case 'green':
        return Colors.green;
      case 'amarillo':
      case 'yellow':
        return Colors.yellow;
      case 'negro':
      case 'black':
        return Colors.black;
      case 'blanco':
      case 'white':
        return Colors.white;
      case 'gris':
      case 'gray':
        return Colors.grey;
      case 'rosa':
      case 'pink':
        return Colors.pink;
      case 'morado':
      case 'purple':
        return Colors.purple;
      case 'naranja':
      case 'orange':
        return Colors.orange;
      case 'café':
      case 'brown':
        return Colors.brown;
      default:
        return null;
    }
  }
}

// Widget simplificado para mostrar en mini carrito
class MiniCartItemWidget extends StatelessWidget {
  final dynamic item;
  final VoidCallback? onTap;

  const MiniCartItemWidget({
    Key? key,
    required this.item,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Image
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.background,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: item.image.isNotEmpty
                    ? Image.network(
                        item.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            IconlyLight.image,
                            size: 20,
                            color: AppColors.textSecondary,
                          );
                        },
                      )
                    : Icon(
                        IconlyLight.image,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name ?? 'Producto',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Row(
                    children: [
                      Text(
                        '${item.quantity}x',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                                              Text(
                        '\${item.totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}