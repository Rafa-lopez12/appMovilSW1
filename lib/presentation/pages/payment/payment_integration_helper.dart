// lib/presentation/pages/payment/payment_integration_helper.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/payment_provider.dart';
import '../../providers/cart_provider.dart';
import 'payment_page.dart';

class PaymentIntegrationHelper {
  // Método para navegar al pago desde el checkout
  static Future<void> navigateToPayment(
    BuildContext context, {
    bool fromCheckout = false,
  }) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);

    // Verificar que el carrito no esté vacío
    if (cartProvider.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tu carrito está vacío'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Limpiar estado previo de pagos
    paymentProvider.clearPaymentState();

    // Navegar a la página de pago
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          totalAmount: cartProvider.finalTotal,
          cartItems: cartProvider.itemsList,
        ),
      ),
    );

    // Si el pago fue exitoso y venimos del checkout, podemos hacer acciones adicionales
    if (result == true && fromCheckout) {
      // El carrito ya fue limpiado en PaymentPage
      // Podríamos navegar a una página de confirmación adicional aquí si fuera necesario
    }
  }

  // Método para procesar pago rápido (directo desde producto)
  static Future<bool> processQuickPayment(
    BuildContext context, {
    required String productId,
    required double amount,
    required int quantity,
  }) async {
    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);

    try {
      // Limpiar estado previo
      paymentProvider.clearPaymentState();

      // Crear payment intent personalizado
      await paymentProvider.createCustomPaymentIntent(
        amount: amount,
        description: 'Compra rápida - Producto $productId',
        metadata: {
          'product_id': productId,
          'quantity': quantity.toString(),
          'type': 'quick_purchase',
        },
      );

      // Procesar pago
      final success = await paymentProvider.processCompleteStripePayment();

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Compra exitosa!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      return success;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error en la compra: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  // Método para validar antes del pago
  static bool validateBeforePayment(
    BuildContext context, {
    required CartProvider cartProvider,
  }) {
    if (cartProvider.isEmpty) {
      _showError(context, 'Tu carrito está vacío');
      return false;
    }

    if (cartProvider.isLoading) {
      _showError(context, 'Carrito cargando, por favor espera');
      return false;
    }

    if (cartProvider.finalTotal <= 0) {
      _showError(context, 'Total inválido');
      return false;
    }

    return true;
  }

  // Método para mostrar errores
  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Método para mostrar confirmación de pago
  static void showPaymentSuccess(
    BuildContext context, {
    required String orderId,
    required double amount,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('¡Pago Exitoso!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text('Orden #$orderId'),
            Text('Total: \$${amount.toStringAsFixed(2)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/main',
                (route) => false,
              );
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }
}

// Extension para facilitar el uso desde widgets
extension PaymentHelperExtension on BuildContext {
  Future<void> navigateToPayment({bool fromCheckout = false}) async {
    await PaymentIntegrationHelper.navigateToPayment(
      this,
      fromCheckout: fromCheckout,
    );
  }

  Future<bool> processQuickPayment({
    required String productId,
    required double amount,
    required int quantity,
  }) async {
    return await PaymentIntegrationHelper.processQuickPayment(
      this,
      productId: productId,
      amount: amount,
      quantity: quantity,
    );
  }
}