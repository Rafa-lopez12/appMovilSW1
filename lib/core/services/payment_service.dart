// lib/core/services/payment_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import '../constants/api_constants.dart';
import 'auth_service.dart';

class PaymentService {
  final AuthService _authService = AuthService();

  // Inicializar Stripe
  static void initializeStripe() {
    Stripe.publishableKey = 'pk_test_51RTUBMHIj82SmGbDobq1uVtN5RTTtJbmY81CiBDmxgDzIEDe1QB7NooKByfJnQGL3uUTKPiVkYxNeCcBID4vua9R00lSQRU395'; // Configura tu clave pública
  }

  // Headers base para las peticiones
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getStoredToken();
    return {
      'Content-Type': 'application/json',
      'X-Tenant-ID': ApiConstants.tenantId,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // 1. CREAR PAYMENT INTENT DESDE CARRITO
  Future<StripePaymentIntent> createPaymentFromCart() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/stripe/create-payment-from-cart'),
        headers: await _getHeaders(),
      );

      debugPrint('Create Payment from Cart Status: ${response.statusCode}');
      debugPrint('Create Payment from Cart Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return StripePaymentIntent.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        throw PaymentException(
          errorData['message'] ?? 'Error creando pago desde carrito',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is PaymentException) rethrow;
      debugPrint('Create Payment from Cart Error: $e');
      throw PaymentException('Error de conexión: ${e.toString()}');
    }
  }

  // 2. CREAR PAYMENT INTENT DIRECTO (para productos específicos)
  Future<StripePaymentIntent> createPaymentIntent({
    required double amount,
    String currency = 'usd',
    List<PaymentItem>? items,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/stripe/create-payment-intent'),
        headers: await _getHeaders(),
        body: json.encode({
          'amount': (amount * 100).toInt(), // Convertir a centavos
          'currency': currency,
          if (items != null) 'items': items.map((item) => item.toJson()).toList(),
          if (description != null) 'description': description,
          if (metadata != null) 'metadata': metadata,
        }),
      );

      debugPrint('Create Payment Intent Status: ${response.statusCode}');
      debugPrint('Create Payment Intent Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return StripePaymentIntent.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        throw PaymentException(
          errorData['message'] ?? 'Error creando payment intent',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is PaymentException) rethrow;
      debugPrint('Create Payment Intent Error: $e');
      throw PaymentException('Error de conexión: ${e.toString()}');
    }
  }

  // 3. INICIALIZAR PAYMENT SHEET DE STRIPE
  Future<void> initializePaymentSheet(StripePaymentIntent paymentIntent) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent.clientSecret,
          merchantDisplayName: "Tu Tienda Virtual",
          customerId: paymentIntent.customerId.isNotEmpty ? paymentIntent.customerId : null,
          style: ThemeMode.system,
          // Opcional: configurar billing details
          billingDetails: const BillingDetails(
            // address: Address(...), // Si tienes datos de dirección
          ),
          // Habilitar Apple Pay / Google Pay si está disponible
          applePay: const PaymentSheetApplePay(
            merchantCountryCode: 'US', // Cambia según tu país
          ),
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'US', // Cambia según tu país
            testEnv: true, // Cambiar a false en producción
          ),
        ),
      );
    } catch (e) {
      throw PaymentException('Error inicializando Stripe: $e');
    }
  }

  // 4. PRESENTAR PAYMENT SHEET DE STRIPE
  Future<StripePaymentResult> presentPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      return StripePaymentResult(
        status: StripePaymentStatus.success,
        message: 'Pago completado en Stripe',
      );
    } catch (e) {
      if (e is StripeException) {
        switch (e.error.code) {
          case FailureCode.Canceled:
            return StripePaymentResult(
              status: StripePaymentStatus.canceled,
              message: 'Pago cancelado por el usuario',
            );
          case FailureCode.Failed:
            return StripePaymentResult(
              status: StripePaymentStatus.failed,
              message: 'Error en el pago: ${e.error.message}',
            );
          default:
            return StripePaymentResult(
              status: StripePaymentStatus.failed,
              message: 'Error desconocido: ${e.error.message}',
            );
        }
      }
      return StripePaymentResult(
        status: StripePaymentStatus.failed,
        message: 'Error inesperado: $e',
      );
    }
  }

  // 5. WORKFLOW COMPLETO DE STRIPE
  Future<CompletePaymentResult> processStripePayment({
    StripePaymentIntent? existingIntent,
    double? amount,
    List<PaymentItem>? items,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // 1. Crear o usar Payment Intent existente
      StripePaymentIntent paymentIntent;
      if (existingIntent != null) {
        paymentIntent = existingIntent;
      } else if (amount != null) {
        paymentIntent = await createPaymentIntent(
          amount: amount,
          items: items,
          description: description,
          metadata: metadata,
        );
      } else {
        paymentIntent = await createPaymentFromCart();
      }

      // 2. Inicializar Payment Sheet
      await initializePaymentSheet(paymentIntent);

      // 3. Presentar UI de pago
      final stripeResult = await presentPaymentSheet();

      if (stripeResult.status != StripePaymentStatus.success) {
        return CompletePaymentResult(
          success: false,
          message: stripeResult.message,
          canceled: stripeResult.status == StripePaymentStatus.canceled,
        );
      }

      // 4. Confirmar en el backend
      final confirmation = await confirmPayment(
        paymentIntentId: paymentIntent.paymentIntentId,
      );

      if (confirmation.isSuccessful) {
        return CompletePaymentResult(
          success: true,
          message: confirmation.message,
          paymentIntentId: paymentIntent.paymentIntentId,
          orderId: confirmation.ventaId,
          receiptUrl: confirmation.receiptUrl,
        );
      } else {
        return CompletePaymentResult(
          success: false,
          message: confirmation.message,
          requiresAction: confirmation.requiresAction,
        );
      }

    } on PaymentException catch (e) {
      return CompletePaymentResult(
        success: false,
        message: e.message,
      );
    } catch (e) {
      return CompletePaymentResult(
        success: false,
        message: 'Error procesando pago: $e',
      );
    }
  }

  // 6. CONFIRMAR PAGO EN BACKEND
  Future<PaymentConfirmation> confirmPayment({
    required String paymentIntentId,
    String? paymentMethodId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/stripe/confirm-payment'),
        headers: await _getHeaders(),
        body: json.encode({
          'paymentIntentId': paymentIntentId,
          if (paymentMethodId != null) 'paymentMethodId': paymentMethodId,
        }),
      );

      debugPrint('Confirm Payment Status: ${response.statusCode}');
      debugPrint('Confirm Payment Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return PaymentConfirmation.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        throw PaymentException(
          errorData['message'] ?? 'Error confirmando pago',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is PaymentException) rethrow;
      debugPrint('Confirm Payment Error: $e');
      throw PaymentException('Error de conexión: ${e.toString()}');
    }
  }

  // 7. COMPRA DIRECTA (sin Stripe - checkout rápido)
  Future<DirectPurchaseResult> purchaseFromCart() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/venta/comprar'),
        headers: await _getHeaders(),
      );

      debugPrint('Direct Purchase Status: ${response.statusCode}');
      debugPrint('Direct Purchase Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return DirectPurchaseResult.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        throw PaymentException(
          errorData['message'] ?? 'Error en compra directa',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is PaymentException) rethrow;
      debugPrint('Direct Purchase Error: $e');
      throw PaymentException('Error de conexión: ${e.toString()}');
    }
  }

  // 8. HISTORIAL DE PAGOS
  Future<List<PaymentHistory>> getPaymentHistory() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/stripe/my-payments'),
        headers: await _getHeaders(),
      );

      debugPrint('Payment History Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((payment) => PaymentHistory.fromJson(payment)).toList();
      } else {
        final errorData = json.decode(response.body);
        throw PaymentException(
          errorData['message'] ?? 'Error obteniendo historial de pagos',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is PaymentException) rethrow;
      debugPrint('Payment History Error: $e');
      throw PaymentException('Error de conexión: ${e.toString()}');
    }
  }

  // 9. OBTENER DETALLES DE PAGO
  Future<PaymentDetails> getPaymentDetails(String paymentId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/stripe/payment/$paymentId'),
        headers: await _getHeaders(),
      );

      debugPrint('Payment Details Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PaymentDetails.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        throw PaymentException(
          errorData['message'] ?? 'Error obteniendo detalles del pago',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is PaymentException) rethrow;
      debugPrint('Payment Details Error: $e');
      throw PaymentException('Error de conexión: ${e.toString()}');
    }
  }

  // 10. MIS COMPRAS (órdenes/ventas)
  Future<List<OrderHistory>> getMyOrders() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/venta/mis-compras'),
        headers: await _getHeaders(),
      );

      debugPrint('My Orders Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((order) => OrderHistory.fromJson(order)).toList();
      } else {
        final errorData = json.decode(response.body);
        throw PaymentException(
          errorData['message'] ?? 'Error obteniendo mis compras',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is PaymentException) rethrow;
      debugPrint('My Orders Error: $e');
      throw PaymentException('Error de conexión: ${e.toString()}');
    }
  }

  // 11. CONVERTIR BOB A USD
  static double convertBobToUsd(double amountInBob) {
    const double exchangeRate = 0.145; // 1 BOB = 0.145 USD aproximadamente
    return amountInBob * exchangeRate;
  }

  // 12. FORMATEAR AMOUNT PARA STRIPE
  static int formatAmountForStripe(double amount, String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
      case 'EUR':
        return (amount * 100).toInt();
      case 'JPY':
        return amount.toInt();
      default:
        return (amount * 100).toInt();
    }
  }
}

// MODELOS DE DATOS EXISTENTES (mantener todos)

class StripePaymentIntent {
  final String paymentIntentId;
  final String clientSecret;
  final String customerId;
  final int amount;
  final String currency;
  final String status;

  StripePaymentIntent({
    required this.paymentIntentId,
    required this.clientSecret,
    required this.customerId,
    required this.amount,
    required this.currency,
    required this.status,
  });

  factory StripePaymentIntent.fromJson(Map<String, dynamic> json) {
    return StripePaymentIntent(
      paymentIntentId: json['paymentIntentId'] ?? '',
      clientSecret: json['clientSecret'] ?? '',
      customerId: json['customerId'] ?? '',
      amount: json['amount'] ?? 0,
      currency: json['currency'] ?? 'usd',
      status: json['status'] ?? '',
    );
  }

  double get amountInDollars => amount / 100.0;
}

// NUEVOS MODELOS PARA STRIPE

enum StripePaymentStatus { success, failed, canceled }

class StripePaymentResult {
  final StripePaymentStatus status;
  final String message;

  StripePaymentResult({
    required this.status,
    required this.message,
  });
}

class CompletePaymentResult {
  final bool success;
  final String message;
  final String? paymentIntentId;
  final String? orderId;
  final String? receiptUrl;
  final bool canceled;
  final bool requiresAction;

  CompletePaymentResult({
    required this.success,
    required this.message,
    this.paymentIntentId,
    this.orderId,
    this.receiptUrl,
    this.canceled = false,
    this.requiresAction = false,
  });
}

// MANTENER TODOS TUS MODELOS EXISTENTES

class PaymentItem {
  final String productoVariedadId;
  final int cantidad;
  final double precio;
  final String nombre;

  PaymentItem({
    required this.productoVariedadId,
    required this.cantidad,
    required this.precio,
    required this.nombre,
  });

  Map<String, dynamic> toJson() {
    return {
      'productoVariedadId': productoVariedadId,
      'cantidad': cantidad,
      'precio': (precio * 100).toInt(), // Convertir a centavos
      'nombre': nombre,
    };
  }
}

class PaymentConfirmation {
  final bool success;
  final String paymentStatus;
  final String? ventaId;
  final String? receiptUrl;
  final String message;
  final Map<String, dynamic>? nextAction;

  PaymentConfirmation({
    required this.success,
    required this.paymentStatus,
    this.ventaId,
    this.receiptUrl,
    required this.message,
    this.nextAction,
  });

  factory PaymentConfirmation.fromJson(Map<String, dynamic> json) {
    return PaymentConfirmation(
      success: json['success'] ?? false,
      paymentStatus: json['paymentStatus'] ?? '',
      ventaId: json['ventaId'],
      receiptUrl: json['receiptUrl'],
      message: json['message'] ?? '',
      nextAction: json['nextAction'],
    );
  }

  bool get isSuccessful => success && paymentStatus == 'succeeded';
  bool get requiresAction => nextAction != null;
}

class DirectPurchaseResult {
  final String id;
  final DateTime fechaVenta;
  final String cliente;
  final double subtotal;
  final double total;
  final String estado;
  final int cantidadItems;
  final String message;

  DirectPurchaseResult({
    required this.id,
    required this.fechaVenta,
    required this.cliente,
    required this.subtotal,
    required this.total,
    required this.estado,
    required this.cantidadItems,
    required this.message,
  });

  factory DirectPurchaseResult.fromJson(Map<String, dynamic> json) {
    return DirectPurchaseResult(
      id: json['id'] ?? '',
      fechaVenta: DateTime.tryParse(json['fechaVenta'] ?? '') ?? DateTime.now(),
      cliente: json['cliente']?['nombre'] ?? '',
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      estado: json['estado'] ?? '',
      cantidadItems: json['cantidadItems'] ?? 0,
      message: json['message'] ?? json['mensaje'] ?? '',
    );
  }
}

class PaymentHistory {
  final String id;
  final double amount;
  final String currency;
  final String status;
  final DateTime createdAt;
  final String? receiptUrl;

  PaymentHistory({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
    this.receiptUrl,
  });

  factory PaymentHistory.fromJson(Map<String, dynamic> json) {
    return PaymentHistory(
      id: json['id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'usd',
      status: json['status'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      receiptUrl: json['receiptUrl'],
    );
  }
}

class PaymentDetails {
  final String id;
  final double amount;
  final String currency;
  final String status;
  final DateTime createdAt;
  final Map<String, dynamic> cliente;
  final Map<String, dynamic>? venta;
  final String? receiptUrl;
  final Map<String, dynamic>? metadata;

  PaymentDetails({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
    required this.cliente,
    this.venta,
    this.receiptUrl,
    this.metadata,
  });

  factory PaymentDetails.fromJson(Map<String, dynamic> json) {
    return PaymentDetails(
      id: json['id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'usd',
      status: json['status'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      cliente: json['cliente'] ?? {},
      venta: json['venta'],
      receiptUrl: json['receiptUrl'],
      metadata: json['metadata'],
    );
  }
}

class OrderHistory {
  final String id;
  final DateTime fecha;
  final String? usuario;
  final String cliente;
  final double total;
  final String estado;
  final int cantidadItems;
  final List<Map<String, dynamic>> detalles;

  OrderHistory({
    required this.id,
    required this.fecha,
    this.usuario,
    required this.cliente,
    required this.total,
    required this.estado,
    required this.cantidadItems,
    required this.detalles,
  });

  factory OrderHistory.fromJson(Map<String, dynamic> json) {
    return OrderHistory(
      id: json['id'] ?? '',
      fecha: DateTime.tryParse(json['fecha'] ?? json['fechaVenta'] ?? '') ?? DateTime.now(),
      usuario: json['usuario'],
      cliente: json['cliente'] ?? '',
      total: (json['total'] ?? 0).toDouble(),
      estado: json['estado'] ?? '',
      cantidadItems: json['cantidadItems'] ?? 0,
      detalles: List<Map<String, dynamic>>.from(json['detalles'] ?? []),
    );
  }
}

// Exception personalizada para pagos
class PaymentException implements Exception {
  final String message;
  final int? statusCode;

  PaymentException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}