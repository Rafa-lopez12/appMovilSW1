// lib/presentation/pages/cart/cart_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/cart/cart_item_widget.dart';
import '../../widgets/cart/cart_summary_widget.dart';
import '../../widgets/cart/empty_cart_widget.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import 'checkout_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> 
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  
  @override
  bool get wantKeepAlive => true;

  late AnimationController _refreshController;
  late Animation<double> _refreshAnimation;
  
  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _refreshAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _refreshController, curve: Curves.easeInOut),
    );
    
    // Cargar carrito al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCart();
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadCart() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    await cartProvider.loadCart();
  }

  Future<void> _refreshCart() async {
    _refreshController.forward().then((_) {
      _refreshController.reset();
    });
    await _loadCart();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.isLoading) {
            return _buildLoadingState();
          }

          if (cartProvider.isEmpty) {
            return const EmptyCartWidget();
          }

          return Column(
            children: [
              // Lista de productos
              Expanded(
                child: _buildCartList(cartProvider),
              ),
              
              // Resumen y botón de checkout
              _buildBottomSection(cartProvider),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      title: FadeInDown(
        duration: const Duration(milliseconds: 600),
        child: Text(
          AppStrings.myCart,
          style: TextStyle(
            fontSize: ResponsiveUtils.getFontSize(context, FontSizeType.title),
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      centerTitle: true,
      actions: [
        FadeInDown(
          duration: const Duration(milliseconds: 800),
          child: Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return PopupMenuButton<String>(
                icon: Icon(
                  IconlyLight.more_circle,
                  color: AppColors.textPrimary,
                ),
                onSelected: (value) => _handleMenuAction(value, cartProvider),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'refresh',
                    child: Row(
                      children: [
                        Icon(IconlyLight.arrow_down_2, size: 18),
                        const SizedBox(width: 12),
                        Text('Actualizar'),
                      ],
                    ),
                  ),
                  if (cartProvider.itemCount > 0)
                    PopupMenuItem(
                      value: 'clear',
                      child: Row(
                        children: [
                          Icon(IconlyLight.delete, size: 18, color: AppColors.error),
                          const SizedBox(width: 12),
                          Text('Vaciar carrito', style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Cargando carrito...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(CartProvider cartProvider) {
    return RefreshIndicator(
      onRefresh: _refreshCart,
      color: AppColors.primary,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getHorizontalPadding(context),
          vertical: 16,
        ),
        physics: const BouncingScrollPhysics(),
        itemCount: cartProvider.itemsList.length,
        itemBuilder: (context, index) {
          final item = cartProvider.itemsList[index];
          
          return FadeInUp(
            duration: Duration(milliseconds: 300 + (index * 100)),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: CartItemWidget(
                item: item,
                onQuantityChanged: (newQuantity) => 
                    _updateQuantity(cartProvider, item, newQuantity),
                onRemove: () => _removeItem(cartProvider, item),
                onTap: () => _navigateToProduct(item),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomSection(CartProvider cartProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(
            ResponsiveUtils.getHorizontalPadding(context),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Resumen de precios
              CartSummaryWidget(
                subtotal: cartProvider.subtotal,
                shipping: cartProvider.shipping,
                tax: cartProvider.tax,
                total: cartProvider.finalTotal,
                itemCount: cartProvider.itemCount,
              ),
              
              const SizedBox(height: 16),
              
              // Botón de checkout
              Row(
                children: [
                  // Botón continuar comprando (opcional)
                  Expanded(
                    flex: 1,
                    child: CustomButton(
                      text: 'Seguir comprando',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Usa la navegación inferior para explorar productos')),
                        );
                      },
                      type: ButtonType.outline,
                      icon: IconlyLight.arrow_left,
                      size: ButtonSize.medium,
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Botón checkout
                  Expanded(
                    flex: 2,
                    child: CustomButton(
                      text: 'Proceder al pago (\$${cartProvider.finalTotal.toStringAsFixed(2)})',
                      onPressed: cartProvider.canCheckout() 
                          ? () => _proceedToCheckout(cartProvider)
                          : null,
                      isLoading: cartProvider.isLoading,
                      icon: IconlyLight.arrow_right,
                      size: ButtonSize.medium,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Información adicional
              _buildAdditionalInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo() {
    return FadeInUp(
      duration: const Duration(milliseconds: 1000),
      child: Column(
        children: [
          // Envío gratis
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.success.withOpacity(0.3),
                width: 1,
              ),
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
                  'Envío gratis en compras mayores a \$100',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Garantía
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                IconlyLight.shield_done,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                'Compra 100% segura',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                IconlyLight.arrow_left_square,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                'Devoluciones gratis',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Event handlers
  void _handleMenuAction(String action, CartProvider cartProvider) {
    switch (action) {
      case 'refresh':
        HapticFeedback.lightImpact();
        _refreshCart();
        break;
      case 'clear':
        HapticFeedback.lightImpact();
        _showClearCartDialog(cartProvider);
        break;
    }
  }

  Future<void> _updateQuantity(CartProvider cartProvider, dynamic item, int newQuantity) async {
    try {
      final itemKey = '${item.productId}_${item.size}_${item.color}';
      await cartProvider.updateQuantity(itemKey, newQuantity);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cantidad actualizada'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error actualizando cantidad: $error'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _removeItem(CartProvider cartProvider, dynamic item) async {
    try {
      final itemKey = '${item.productId}_${item.size}_${item.color}';
      await cartProvider.removeItem(itemKey);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.name} eliminado del carrito'),
          backgroundColor: AppColors.info,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Deshacer',
            textColor: Colors.white,
            onPressed: () {
              // TODO: Implementar deshacer eliminación
            },
          ),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error eliminando producto: $error'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _navigateToProduct(dynamic item) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(
      context, 
      '/product-detail',
      arguments: item.productId,
    );
  }

  void _proceedToCheckout(CartProvider cartProvider) {
    HapticFeedback.lightImpact();
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (!authProvider.isAuthenticated) {
      _showLoginRequiredDialog();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(
          cartItems: cartProvider.itemsList,
          totalAmount: cartProvider.finalTotal,
        ),
      ),
    );
  }

  void _showClearCartDialog(CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vaciar carrito'),
        content: const Text('¿Estás seguro de que quieres eliminar todos los productos del carrito?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              try {
                await cartProvider.clearCart();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Carrito vaciado'),
                    backgroundColor: AppColors.info,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error vaciando carrito: $error'),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Vaciar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Iniciar sesión requerido'),
        content: const Text('Necesitas iniciar sesión para proceder al pago.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/login');
            },
            child: const Text('Iniciar sesión'),
          ),
        ],
      ),
    );
  }
}