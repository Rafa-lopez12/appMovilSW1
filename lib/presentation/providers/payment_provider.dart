// lib/presentation/providers/payment_provider.dart
import 'package:flutter/foundation.dart';
import 'package:prueba/core/services/payment_service.dart';

enum PaymentType { stripe, direct }
enum PaymentStatus { idle, loading, success, failed, requiresAction }
enum CheckoutStep { cart, shipping, payment, confirmation }

class PaymentProvider extends ChangeNotifier {
  final PaymentService _paymentService = PaymentService();

  // Estado general
  PaymentStatus _paymentStatus = PaymentStatus.idle;
  PaymentType _selectedPaymentType = PaymentType.stripe;
  CheckoutStep _currentStep = CheckoutStep.cart;
  String? _errorMessage;
  bool _isProcessing = false;

  // Datos de Stripe
  StripePaymentIntent? _stripePaymentIntent;
  PaymentConfirmation? _paymentConfirmation;
  
  // Datos de compra directa
  DirectPurchaseResult? _directPurchaseResult;
  
  // Datos de historial
  List<PaymentHistory> _paymentHistory = [];
  List<OrderHistory> _orderHistory = [];
  
  // Datos de shipping/billing
  Map<String, dynamic> _shippingData = {};
  Map<String, dynamic> _billingData = {};

  // Getters
  PaymentStatus get paymentStatus => _paymentStatus;
  PaymentType get selectedPaymentType => _selectedPaymentType;
  CheckoutStep get currentStep => _currentStep;
  String? get errorMessage => _errorMessage;
  bool get isProcessing => _isProcessing;
  bool get hasError => _errorMessage != null;
  
  StripePaymentIntent? get stripePaymentIntent => _stripePaymentIntent;
  PaymentConfirmation? get paymentConfirmation => _paymentConfirmation;
  DirectPurchaseResult? get directPurchaseResult => _directPurchaseResult;
  
  List<PaymentHistory> get paymentHistory => [..._paymentHistory];
  List<OrderHistory> get orderHistory => [..._orderHistory];
  
  Map<String, dynamic> get shippingData => {..._shippingData};
  Map<String, dynamic> get billingData => {..._billingData};

  // Estado de checkout
  bool get canProceedToShipping => _currentStep == CheckoutStep.cart;
  bool get canProceedToPayment => _currentStep == CheckoutStep.shipping && _shippingData.isNotEmpty;
  bool get canProcessPayment => _currentStep == CheckoutStep.payment;
  bool get isCheckoutComplete => _paymentStatus == PaymentStatus.success;

  // NAVEGACIÓN DEL CHECKOUT

  void setCheckoutStep(CheckoutStep step) {
    _currentStep = step;
    notifyListeners();
  }

  void nextStep() {
    switch (_currentStep) {
      case CheckoutStep.cart:
        _currentStep = CheckoutStep.shipping;
        break;
      case CheckoutStep.shipping:
        if (_shippingData.isNotEmpty) {
          _currentStep = CheckoutStep.payment;
        }
        break;
      case CheckoutStep.payment:
        // El paso a confirmación se maneja después del pago exitoso
        break;
      case CheckoutStep.confirmation:
        // Ya está en el último paso
        break;
    }
    notifyListeners();
  }

  void previousStep() {
    switch (_currentStep) {
      case CheckoutStep.cart:
        // Ya está en el primer paso
        break;
      case CheckoutStep.shipping:
        _currentStep = CheckoutStep.cart;
        break;
      case CheckoutStep.payment:
        _currentStep = CheckoutStep.shipping;
        break;
      case CheckoutStep.confirmation:
        _currentStep = CheckoutStep.payment;
        break;
    }
    notifyListeners();
  }

  void resetCheckout() {
    _currentStep = CheckoutStep.cart;
    _paymentStatus = PaymentStatus.idle;
    _stripePaymentIntent = null;
    _paymentConfirmation = null;
    _directPurchaseResult = null;
    _shippingData.clear();
    _billingData.clear();
    _clearError();
    notifyListeners();
  }

  // CONFIGURACIÓN DE DATOS

  void setPaymentType(PaymentType type) {
    _selectedPaymentType = type;
    notifyListeners();
  }

  void setShippingData(Map<String, dynamic> data) {
    _shippingData = {...data};
    notifyListeners();
  }

  void setBillingData(Map<String, dynamic> data) {
    _billingData = {...data};
    notifyListeners();
  }

  // MÉTODOS DE PAGO

  // 1. CREAR PAYMENT INTENT DESDE CARRITO
  Future<void> createPaymentFromCart() async {
    _setProcessing(true);
    _setPaymentStatus(PaymentStatus.loading);
    _clearError();

    try {
      _stripePaymentIntent = await _paymentService.createPaymentFromCart();
      _setPaymentStatus(PaymentStatus.idle); // Listo para confirmar
      
      debugPrint('Payment Intent creado: ${_stripePaymentIntent!.paymentIntentId}');
      
    } on PaymentException catch (e) {
      _handleError(e.message);
      _setPaymentStatus(PaymentStatus.failed);
    } catch (e) {
      _handleError('Error creando payment intent: $e');
      _setPaymentStatus(PaymentStatus.failed);
    } finally {
      _setProcessing(false);
    }
  }

  // 2. CREAR PAYMENT INTENT PERSONALIZADO
  Future<void> createCustomPaymentIntent({
    required double amount,
    String currency = 'usd',
    List<PaymentItem>? items,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    _setProcessing(true);
    _setPaymentStatus(PaymentStatus.loading);
    _clearError();

    try {
      _stripePaymentIntent = await _paymentService.createPaymentIntent(
        amount: amount,
        currency: currency,
        items: items,
        description: description,
        metadata: metadata,
      );
      _setPaymentStatus(PaymentStatus.idle);
      
    } on PaymentException catch (e) {
      _handleError(e.message);
      _setPaymentStatus(PaymentStatus.failed);
    } catch (e) {
      _handleError('Error creando payment intent: $e');
      _setPaymentStatus(PaymentStatus.failed);
    } finally {
      _setProcessing(false);
    }
  }

  // 3. CONFIRMAR PAGO CON STRIPE
  Future<bool> confirmStripePayment({String? paymentMethodId}) async {
    if (_stripePaymentIntent == null) {
      _handleError('No hay payment intent activo');
      return false;
    }

    _setProcessing(true);
    _setPaymentStatus(PaymentStatus.loading);
    _clearError();

    try {
      _paymentConfirmation = await _paymentService.confirmPayment(
        paymentIntentId: _stripePaymentIntent!.paymentIntentId,
        paymentMethodId: paymentMethodId,
      );

      if (_paymentConfirmation!.isSuccessful) {
        _setPaymentStatus(PaymentStatus.success);
        _currentStep = CheckoutStep.confirmation;
        debugPrint('Pago exitoso! Venta ID: ${_paymentConfirmation!.ventaId}');
        return true;
      } else if (_paymentConfirmation!.requiresAction) {
        _setPaymentStatus(PaymentStatus.requiresAction);
        _handleError('El pago requiere autenticación adicional');
        return false;
      } else {
        _setPaymentStatus(PaymentStatus.failed);
        _handleError(_paymentConfirmation!.message);
        return false;
      }

    } on PaymentException catch (e) {
      _handleError(e.message);
      _setPaymentStatus(PaymentStatus.failed);
      return false;
    } catch (e) {
      _handleError('Error confirmando pago: $e');
      _setPaymentStatus(PaymentStatus.failed);
      return false;
    } finally {
      _setProcessing(false);
    }
  }

  // 4. COMPRA DIRECTA (sin Stripe)
  Future<bool> processDirectPurchase() async {
    _setProcessing(true);
    _setPaymentStatus(PaymentStatus.loading);
    _clearError();

    try {
      _directPurchaseResult = await _paymentService.purchaseFromCart();
      _setPaymentStatus(PaymentStatus.success);
      _currentStep = CheckoutStep.confirmation;
      
      debugPrint('Compra directa exitosa! ID: ${_directPurchaseResult!.id}');
      return true;

    } on PaymentException catch (e) {
      _handleError(e.message);
      _setPaymentStatus(PaymentStatus.failed);
      return false;
    } catch (e) {
      _handleError('Error en compra directa: $e');
      _setPaymentStatus(PaymentStatus.failed);
      return false;
    } finally {
      _setProcessing(false);
    }
  }

  // 5. CHECKOUT COMPLETO (método de conveniencia)
  Future<bool> processCheckout() async {
    switch (_selectedPaymentType) {
      case PaymentType.stripe:
        // Primero crear payment intent si no existe
        if (_stripePaymentIntent == null) {
          await createPaymentFromCart();
          if (_paymentStatus == PaymentStatus.failed) return false;
        }
        // Luego confirmar (aquí necesitarás integrar con Stripe SDK para el frontend)
        return await confirmStripePayment();
        
      case PaymentType.direct:
        return await processDirectPurchase();
    }
  }

  // HISTORIAL Y DATOS

  Future<void> loadPaymentHistory() async {
    _setProcessing(true);
    _clearError();

    try {
      _paymentHistory = await _paymentService.getPaymentHistory();
    } on PaymentException catch (e) {
      _handleError(e.message);
    } catch (e) {
      _handleError('Error cargando historial de pagos: $e');
    } finally {
      _setProcessing(false);
    }
  }

  Future<void> loadOrderHistory() async {
    _setProcessing(true);
    _clearError();

    try {
      _orderHistory = await _paymentService.getMyOrders();
    } on PaymentException catch (e) {
      _handleError(e.message);
    } catch (e) {
      _handleError('Error cargando historial de órdenes: $e');
    } finally {
      _setProcessing(false);
    }
  }

  Future<PaymentDetails?> getPaymentDetails(String paymentId) async {
    _setProcessing(true);
    _clearError();

    try {
      final details = await _paymentService.getPaymentDetails(paymentId);
      return details;
    } on PaymentException catch (e) {
      _handleError(e.message);
      return null;
    } catch (e) {
      _handleError('Error obteniendo detalles del pago: $e');
      return null;
    } finally {
      _setProcessing(false);
    }
  }

  // UTILIDADES

  String getPaymentStatusText() {
    switch (_paymentStatus) {
      case PaymentStatus.idle:
        return 'Listo para procesar';
      case PaymentStatus.loading:
        return 'Procesando pago...';
      case PaymentStatus.success:
        return 'Pago exitoso';
      case PaymentStatus.failed:
        return 'Pago fallido';
      case PaymentStatus.requiresAction:
        return 'Requiere autenticación';
    }
  }

  String getCheckoutStepText() {
    switch (_currentStep) {
      case CheckoutStep.cart:
        return 'Revisar carrito';
      case CheckoutStep.shipping:
        return 'Información de envío';
      case CheckoutStep.payment:
        return 'Método de pago';
      case CheckoutStep.confirmation:
        return 'Confirmación';
    }
  }

  double getCheckoutProgress() {
    switch (_currentStep) {
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

  bool isShippingDataValid() {
    final required = ['fullName', 'address', 'city', 'country'];
    return required.every((field) => 
      _shippingData.containsKey(field) && 
      _shippingData[field] != null && 
      _shippingData[field].toString().isNotEmpty
    );
  }

  // MÉTODOS DE ESTADO INTERNO

  void _setProcessing(bool processing) {
    _isProcessing = processing;
    notifyListeners();
  }

  void _setPaymentStatus(PaymentStatus status) {
    _paymentStatus = status;
    notifyListeners();
  }

  void _handleError(String error) {
    _errorMessage = error;
    debugPrint('Payment Error: $error');
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  // LIMPIEZA DE ESTADO

  void clearPaymentState() {
    _stripePaymentIntent = null;
    _paymentConfirmation = null;
    _directPurchaseResult = null;
    _paymentStatus = PaymentStatus.idle;
    _clearError();
    notifyListeners();
  }

  void clearAllData() {
    _stripePaymentIntent = null;
    _paymentConfirmation = null;
    _directPurchaseResult = null;
    _paymentHistory.clear();
    _orderHistory.clear();
    _shippingData.clear();
    _billingData.clear();
    _paymentStatus = PaymentStatus.idle;
    _currentStep = CheckoutStep.cart;
    _selectedPaymentType = PaymentType.stripe;
    _isProcessing = false;
    _clearError();
    notifyListeners();
  }

  // VALIDACIONES

  bool canStartCheckout() {
    // Aquí puedes agregar validaciones como carrito no vacío, usuario logueado, etc.
    return !_isProcessing && _paymentStatus != PaymentStatus.loading;
  }

  bool canConfirmPayment() {
    return _stripePaymentIntent != null && 
           !_isProcessing && 
           _paymentStatus != PaymentStatus.loading &&
           _paymentStatus != PaymentStatus.success;
  }

  bool canRetryPayment() {
    return _paymentStatus == PaymentStatus.failed && !_isProcessing;
  }

  // GETTERS DE CONVENIENCIA PARA UI

  String? get lastOrderId {
    if (_directPurchaseResult != null) {
      return _directPurchaseResult!.id;
    }
    if (_paymentConfirmation != null && _paymentConfirmation!.ventaId != null) {
      return _paymentConfirmation!.ventaId;
    }
    return null;
  }

  String? get receiptUrl {
    return _paymentConfirmation?.receiptUrl;
  }

  double? get lastPurchaseAmount {
    if (_directPurchaseResult != null) {
      return _directPurchaseResult!.total;
    }
    if (_stripePaymentIntent != null) {
      return _stripePaymentIntent!.amountInDollars;
    }
    return null;
  }

  String get lastPurchaseMessage {
    if (_directPurchaseResult != null) {
      return _directPurchaseResult!.message;
    }
    if (_paymentConfirmation != null) {
      return _paymentConfirmation!.message;
    }
    return 'Compra procesada exitosamente';
  }

  // MÉTODOS PARA INTEGRACIÓN CON STRIPE SDK (Flutter)
  
  // Estos métodos serían llamados desde el frontend después de la integración con Stripe
  void setStripePaymentMethodId(String paymentMethodId) {
    // Este método sería usado para almacenar el payment method del Stripe SDK
    debugPrint('Payment Method ID configurado: $paymentMethodId');
  }

  void handleStripeError(String error) {
    _handleError('Error de Stripe: $error');
    _setPaymentStatus(PaymentStatus.failed);
  }

  void handleStripeSuccess() {
    debugPrint('Stripe confirma que el pago fue exitoso del lado del cliente');
  }

  // MÉTODOS PARA TESTING Y DESARROLLO

  void simulatePaymentSuccess() {
    if (kDebugMode) {
      _paymentConfirmation = PaymentConfirmation(
        success: true,
        paymentStatus: 'succeeded',
        ventaId: 'test-venta-${DateTime.now().millisecondsSinceEpoch}',
        message: 'Pago simulado exitoso',
      );
      _setPaymentStatus(PaymentStatus.success);
      _currentStep = CheckoutStep.confirmation;
    }
  }

  void simulatePaymentFailure() {
    if (kDebugMode) {
      _handleError('Pago simulado fallido');
      _setPaymentStatus(PaymentStatus.failed);
    }
  }

  void simulateDirectPurchase() {
    if (kDebugMode) {
      _directPurchaseResult = DirectPurchaseResult(
        id: 'test-compra-${DateTime.now().millisecondsSinceEpoch}',
        fechaVenta: DateTime.now(),
        cliente: 'Usuario Test',
        subtotal: 85.50,
        total: 100.00,
        estado: 'completada',
        cantidadItems: 3,
        message: 'Compra directa simulada exitosa',
      );
      _setPaymentStatus(PaymentStatus.success);
      _currentStep = CheckoutStep.confirmation;
    }
  }

  // MÉTODOS PARA DEBUGGING

  void printCurrentState() {
    if (kDebugMode) {
      debugPrint('=== PAYMENT PROVIDER STATE ===');
      debugPrint('Payment Status: $_paymentStatus');
      debugPrint('Payment Type: $_selectedPaymentType');
      debugPrint('Current Step: $_currentStep');
      debugPrint('Is Processing: $_isProcessing');
      debugPrint('Has Error: ${_errorMessage != null}');
      debugPrint('Error: $_errorMessage');
      debugPrint('Has Stripe Intent: ${_stripePaymentIntent != null}');
      debugPrint('Has Confirmation: ${_paymentConfirmation != null}');
      debugPrint('Has Direct Result: ${_directPurchaseResult != null}');
      debugPrint('Shipping Data Valid: ${isShippingDataValid()}');
      debugPrint('Can Start Checkout: ${canStartCheckout()}');
      debugPrint('===============================');
    }
  }
}