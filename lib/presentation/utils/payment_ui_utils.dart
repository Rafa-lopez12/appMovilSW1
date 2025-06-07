// lib/presentation/utils/payment_ui_utils.dart
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/constants/app_colors.dart';
import '../providers/payment_provider.dart'; // PaymentType, PaymentStatus, CheckoutStep están aquí

class PaymentUIUtils {
  // Obtener color según el estado del pago
  static Color getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.idle:
        return AppColors.textSecondary;
      case PaymentStatus.loading:
        return AppColors.warning;
      case PaymentStatus.success:
        return AppColors.success;
      case PaymentStatus.failed:
        return AppColors.error;
      case PaymentStatus.requiresAction:
        return AppColors.info;
    }
  }

  // Obtener icono según el estado del pago
  static IconData getStatusIcon(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.idle:
        return IconlyLight.wallet;
      case PaymentStatus.loading:
        return IconlyLight.time_circle;
      case PaymentStatus.success:
        return IconlyBold.tick_square;
      case PaymentStatus.failed:
        return IconlyBold.close_square;
      case PaymentStatus.requiresAction:
        return IconlyLight.info_circle;
    }
  }

  // Obtener mensaje según el estado del pago
  static String getStatusMessage(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.idle:
        return 'Listo para procesar pago';
      case PaymentStatus.loading:
        return 'Procesando pago...';
      case PaymentStatus.success:
        return '¡Pago exitoso!';
      case PaymentStatus.failed:
        return 'Pago fallido';
      case PaymentStatus.requiresAction:
        return 'Se requiere autenticación adicional';
    }
  }

  // Mostrar SnackBar según el estado del pago
  static void showPaymentSnackBar(
    BuildContext context,
    PaymentStatus status, {
    String? customMessage,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    final color = getStatusColor(status);
    final message = customMessage ?? getStatusMessage(status);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              getStatusIcon(status),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: Duration(
          seconds: status == PaymentStatus.success ? 3 : 5,
        ),
        action: onAction != null && actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }

  // Mostrar dialog de confirmación de pago
  static Future<bool?> showPaymentConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required double amount,
    String? paymentMethod,
  }) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total a pagar:'),
                      Text(
                        '\$${amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  if (paymentMethod != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Método:'),
                        Text(
                          paymentMethod,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text(
              'Confirmar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Mostrar dialog de error de pago
  static void showPaymentErrorDialog(
    BuildContext context, {
    required String error,
    VoidCallback? onRetry,
    VoidCallback? onCancel,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              IconlyBold.close_square,
              color: AppColors.error,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text('Error en el pago'),
          ],
        ),
        content: Text(error),
        actions: [
          if (onCancel != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onCancel();
              },
              child: const Text('Cancelar'),
            ),
          if (onRetry != null)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text(
                'Reintentar',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  // Formatear método de pago para mostrar al usuario
  static String formatPaymentMethod(PaymentType type) {
    switch (type) {
      case PaymentType.stripe:
        return 'Tarjeta de crédito/débito';
      case PaymentType.direct:
        return 'Pago directo';
    }
  }

  // Obtener descripción del método de pago
  static String getPaymentMethodDescription(PaymentType type) {
    switch (type) {
      case PaymentType.stripe:
        return 'Procesado de forma segura por Stripe';
      case PaymentType.direct:
        return 'Checkout rápido sin datos de tarjeta';
    }
  }

  // Validar si se puede procesar el pago
  static bool canProcessPayment(
    PaymentProvider paymentProvider,
    PaymentType selectedType, {
    bool? stripeCardValid,
  }) {
    if (paymentProvider.isProcessing) return false;
    if (paymentProvider.paymentStatus == PaymentStatus.loading) return false;
    
    switch (selectedType) {
      case PaymentType.stripe:
        return stripeCardValid ?? false;
      case PaymentType.direct:
        return true;
    }
  }

  // Obtener título para el botón de pago
  static String getPayButtonTitle(
    PaymentType type,
    double amount, {
    bool isLoading = false,
  }) {
    if (isLoading) {
      return 'Procesando...';
    }
    
    final formattedAmount = '\$${amount.toStringAsFixed(2)}';
    
    switch (type) {
      case PaymentType.stripe:
        return 'Pagar con tarjeta $formattedAmount';
      case PaymentType.direct:
        return 'Pago directo $formattedAmount';
    }
  }

  // Crear widget de estado de pago
  static Widget buildPaymentStatusWidget(
    PaymentStatus status, {
    String? customMessage,
    double size = 48,
  }) {
    final color = getStatusColor(status);
    final icon = getStatusIcon(status);
    final message = customMessage ?? getStatusMessage(status);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: size * 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Crear indicador de progreso de pago
  static Widget buildPaymentProgress(
    CheckoutStep currentStep, {
    double? progress,
  }) {
    final steps = [
      'Carrito',
      'Envío',
      'Pago',
      'Confirmación',
    ];

    return Column(
      children: [
        // Progress bar
        LinearProgressIndicator(
          value: progress ?? _getStepProgress(currentStep),
          backgroundColor: AppColors.border,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
        const SizedBox(height: 8),
        // Step labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isActive = index <= currentStep.index;
            
            return Text(
              step,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  static double _getStepProgress(CheckoutStep step) {
    switch (step) {
      case CheckoutStep.cart:
        return 0.25;
      case CheckoutStep.shipping:
        return 0.5;
      case CheckoutStep.payment:
        return 0.75;
      case CheckoutStep.confirmation:
        return 1.0;
    }
  }
}