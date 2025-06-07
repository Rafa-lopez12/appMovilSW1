// lib/presentation/widgets/product/quantity_selector_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconly/iconly.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_utils.dart';

enum QuantitySelectorStyle { horizontal, vertical, compact, minimal }

class QuantitySelectorWidget extends StatefulWidget {
  final int quantity;
  final Function(int) onQuantityChanged;
  final int minQuantity;
  final int maxQuantity;
  final String? title;
  final bool showTitle;
  final QuantitySelectorStyle style;
  final bool enabled;
  final String? stockText;
  final bool showStockWarning;
  final Color? primaryColor;
  final double? width;

  const QuantitySelectorWidget({
    Key? key,
    required this.quantity,
    required this.onQuantityChanged,
    this.minQuantity = 1,
    this.maxQuantity = 99,
    this.title,
    this.showTitle = true,
    this.style = QuantitySelectorStyle.horizontal,
    this.enabled = true,
    this.stockText,
    this.showStockWarning = true,
    this.primaryColor,
    this.width,
  }) : super(key: key);

  @override
  State<QuantitySelectorWidget> createState() => _QuantitySelectorWidgetState();
}

class _QuantitySelectorWidgetState extends State<QuantitySelectorWidget>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  late TextEditingController _textController;
  bool _isTextFieldFocused = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _textController = TextEditingController(text: widget.quantity.toString());
    _fadeController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(QuantitySelectorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.quantity != widget.quantity) {
      _textController.text = widget.quantity.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: widget.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showTitle && widget.title != null) ...[
              _buildTitle(),
              const SizedBox(height: 12),
            ],
            
            _buildQuantitySelector(),
            
            if (widget.stockText != null && widget.showStockWarning) ...[
              const SizedBox(height: 8),
              _buildStockWarning(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.title ?? 'Cantidad',
      style: TextStyle(
        fontSize: ResponsiveUtils.getFontSize(context, FontSizeType.subtitle),
        fontWeight: FontWeight.w600,
        color: widget.enabled ? AppColors.textPrimary : AppColors.disabled,
      ),
    );
  }

  Widget _buildQuantitySelector() {
    switch (widget.style) {
      case QuantitySelectorStyle.horizontal:
        return _buildHorizontalSelector();
      case QuantitySelectorStyle.vertical:
        return _buildVerticalSelector();
      case QuantitySelectorStyle.compact:
        return _buildCompactSelector();
      case QuantitySelectorStyle.minimal:
        return _buildMinimalSelector();
    }
  }

  Widget _buildHorizontalSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.enabled ? AppColors.border : AppColors.disabled,
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDecrementButton(),
          _buildQuantityDisplay(),
          _buildIncrementButton(),
        ],
      ),
    );
  }

  Widget _buildVerticalSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.enabled ? AppColors.border : AppColors.disabled,
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
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIncrementButton(isVertical: true),
          _buildQuantityDisplay(isVertical: true),
          _buildDecrementButton(isVertical: true),
        ],
      ),
    );
  }

  Widget _buildCompactSelector() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCompactButton(
          icon: IconlyLight.arrow_down_2,
          onTap: _decrementQuantity,
          enabled: _canDecrement(),
        ),
        
        const SizedBox(width: 12),
        
        Container(
          constraints: const BoxConstraints(minWidth: 40),
          child: Text(
            widget.quantity.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: widget.enabled ? AppColors.textPrimary : AppColors.disabled,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        
        const SizedBox(width: 12),
        
        _buildCompactButton(
          icon: IconlyLight.plus,
          onTap: _incrementQuantity,
          enabled: _canIncrement(),
        ),
      ],
    );
  }

  Widget _buildMinimalSelector() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _canDecrement() ? _decrementQuantity : null,
          child: Text(
            '−',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _canDecrement() 
                  ? (widget.primaryColor ?? AppColors.primary)
                  : AppColors.disabled,
            ),
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            widget.quantity.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: widget.enabled ? AppColors.textPrimary : AppColors.disabled,
            ),
          ),
        ),
        
        GestureDetector(
          onTap: _canIncrement() ? _incrementQuantity : null,
          child: Text(
            '+',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _canIncrement() 
                  ? (widget.primaryColor ?? AppColors.primary)
                  : AppColors.disabled,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDecrementButton({bool isVertical = false}) {
    final canDecrement = _canDecrement();
    
    return _buildActionButton(
      icon: IconlyLight.arrow_down_2,
      onTap: canDecrement ? _decrementQuantity : null,
      enabled: canDecrement,
      isVertical: isVertical,
    );
  }

  Widget _buildIncrementButton({bool isVertical = false}) {
    final canIncrement = _canIncrement();
    
    return _buildActionButton(
      icon: IconlyLight.plus,
      onTap: canIncrement ? _incrementQuantity : null,
      enabled: canIncrement,
      isVertical: isVertical,
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback? onTap,
    required bool enabled,
    bool isVertical = false,
  }) {
    final size = isVertical ? 40.0 : 48.0;
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: enabled && widget.enabled ? () {
            HapticFeedback.lightImpact();
            _scaleController.forward().then((_) {
              _scaleController.reverse();
            });
            onTap?.call();
          } : null,
          child: Transform.scale(
            scale: enabled ? 1.0 : _scaleAnimation.value,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: enabled && widget.enabled
                    ? (widget.primaryColor ?? AppColors.primary).withOpacity(0.1)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(isVertical ? 8 : 12),
                border: Border.all(
                  color: enabled && widget.enabled
                      ? (widget.primaryColor ?? AppColors.primary).withOpacity(0.3)
                      : AppColors.disabled,
                  width: 1,
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 18,
                  color: enabled && widget.enabled
                      ? (widget.primaryColor ?? AppColors.primary)
                      : AppColors.disabled,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactButton({
    required IconData icon,
    required VoidCallback? onTap,
    required bool enabled,
  }) {
    return GestureDetector(
      onTap: enabled && widget.enabled ? () {
        HapticFeedback.lightImpact();
        onTap?.call();
      } : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          gradient: enabled && widget.enabled
              ? LinearGradient(
                  colors: [
                    widget.primaryColor ?? AppColors.primary,
                    (widget.primaryColor ?? AppColors.primary).withOpacity(0.8),
                  ],
                )
              : null,
          color: !enabled || !widget.enabled ? AppColors.disabled : null,
          shape: BoxShape.circle,
          boxShadow: enabled && widget.enabled
              ? [
                  BoxShadow(
                    color: (widget.primaryColor ?? AppColors.primary).withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: 16,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildQuantityDisplay({bool isVertical = false}) {
    return GestureDetector(
      onTap: widget.enabled ? _showQuantityDialog : null,
      child: Container(
        width: isVertical ? 40 : 60,
        height: isVertical ? 40 : 48,
        child: Center(
          child: Text(
            widget.quantity.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: widget.enabled ? AppColors.textPrimary : AppColors.disabled,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStockWarning() {
    final isLowStock = widget.quantity >= widget.maxQuantity * 0.8;
    
    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isLowStock 
              ? AppColors.warning.withOpacity(0.1)
              : AppColors.info.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isLowStock 
                ? AppColors.warning.withOpacity(0.3)
                : AppColors.info.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isLowStock ? IconlyLight.danger : IconlyLight.info_circle,
              size: 16,
              color: isLowStock ? AppColors.warning : AppColors.info,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.stockText!,
                style: TextStyle(
                  fontSize: 12,
                  color: isLowStock ? AppColors.warning : AppColors.info,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _incrementQuantity() {
    if (_canIncrement()) {
      widget.onQuantityChanged(widget.quantity + 1);
    }
  }

  void _decrementQuantity() {
    if (_canDecrement()) {
      widget.onQuantityChanged(widget.quantity - 1);
    }
  }

  bool _canIncrement() {
    return widget.quantity < widget.maxQuantity;
  }

  bool _canDecrement() {
    return widget.quantity > widget.minQuantity;
  }

  void _showQuantityDialog() {
    showDialog(
      context: context,
      builder: (context) => _QuantityDialog(
        currentQuantity: widget.quantity,
        minQuantity: widget.minQuantity,
        maxQuantity: widget.maxQuantity,
        onQuantityChanged: widget.onQuantityChanged,
      ),
    );
  }
}

// Dialog para entrada manual de cantidad
class _QuantityDialog extends StatefulWidget {
  final int currentQuantity;
  final int minQuantity;
  final int maxQuantity;
  final Function(int) onQuantityChanged;

  const _QuantityDialog({
    required this.currentQuantity,
    required this.minQuantity,
    required this.maxQuantity,
    required this.onQuantityChanged,
  });

  @override
  State<_QuantityDialog> createState() => _QuantityDialogState();
}

class _QuantityDialogState extends State<_QuantityDialog> {
  late TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentQuantity.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Seleccionar Cantidad'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Cantidad',
              hintText: 'Ingresa la cantidad deseada',
              errorText: _errorText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: _validateQuantity,
            autofocus: true,
          ),
          const SizedBox(height: 16),
          Text(
            'Cantidad disponible: ${widget.minQuantity} - ${widget.maxQuantity}',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _errorText == null ? _saveQuantity : null,
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  void _validateQuantity(String value) {
    setState(() {
      if (value.isEmpty) {
        _errorText = 'Ingresa una cantidad';
        return;
      }

      final quantity = int.tryParse(value);
      if (quantity == null) {
        _errorText = 'Cantidad inválida';
        return;
      }

      if (quantity < widget.minQuantity) {
        _errorText = 'Cantidad mínima: ${widget.minQuantity}';
        return;
      }

      if (quantity > widget.maxQuantity) {
        _errorText = 'Cantidad máxima: ${widget.maxQuantity}';
        return;
      }

      _errorText = null;
    });
  }

  void _saveQuantity() {
    final quantity = int.tryParse(_controller.text);
    if (quantity != null && _errorText == null) {
      widget.onQuantityChanged(quantity);
      Navigator.of(context).pop();
    }
  }
}

// Widget simplificado para uso en carrito
class CartQuantitySelectorWidget extends StatelessWidget {
  final int quantity;
  final Function(int) onQuantityChanged;
  final int maxQuantity;
  final bool enabled;

  const CartQuantitySelectorWidget({
    Key? key,
    required this.quantity,
    required this.onQuantityChanged,
    required this.maxQuantity,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return QuantitySelectorWidget(
      quantity: quantity,
      onQuantityChanged: onQuantityChanged,
      maxQuantity: maxQuantity,
      style: QuantitySelectorStyle.compact,
      showTitle: false,
      enabled: enabled,
      width: 120,
    );
  }
}