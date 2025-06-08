// lib/presentation/pages/payment/payment_page.dart - CON DEBUGGING MEJORADO
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/payment/stripe_card_field_widget.dart';
import '../../widgets/payment/payment_method_card.dart';
import '../../widgets/cart/cart_summary_widget.dart';
import '../../providers/payment_provider.dart';
import '../../providers/cart_provider.dart';
import 'payment_success_page.dart';
import 'package:flutter/foundation.dart';

class PaymentPage extends StatefulWidget {
  final double totalAmount;
  final List<dynamic> cartItems;

  const PaymentPage({
    Key? key,
    required this.totalAmount,
    required this.cartItems,
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> 
    with TickerProviderStateMixin, WidgetsBindingObserver {
  PaymentType _selectedPaymentType = PaymentType.stripe;
  bool _stripeCardValid = false;
  bool _isProcessingPayment = false;
  String? _lastError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // ✅ DEBUGGING INICIAL
    _debugPrint('=== PAYMENT PAGE INIT ===');
    _debugPrint('Total Amount: ${widget.totalAmount}');
    _debugPrint('Cart Items Count: ${widget.cartItems.length}');
    _debugValidateInputs();
    
    // ✅ INICIALIZACIÓN SEGURA CON TRY-CATCH
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _safeInitializeStripe();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ✅ MÉTODO SEGURO PARA INICIALIZAR STRIPE
  void _safeInitializeStripe() {
    if (!mounted) return;
    
    try {
      _debugPrint('Initializing Stripe...');
      final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
      paymentProvider.initializeStripe();
      _debugPrint('Stripe initialized successfully');
    } catch (error) {
      _debugPrint('Error initializing Stripe: $error');
      _showErrorSnackBar('Error inicializando sistema de pagos: $error');
    }
  }

  // ✅ VALIDACIÓN DE INPUTS AL INICIAR
  void _debugValidateInputs() {
    bool hasErrors = false;
    
    if (widget.totalAmount <= 0) {
      _debugPrint('ERROR: Invalid total amount: ${widget.totalAmount}');
      hasErrors = true;
    }
    
    if (widget.cartItems.isEmpty) {
      _debugPrint('ERROR: Empty cart items');
      hasErrors = true;
    }
    
    try {
      for (int i = 0; i < widget.cartItems.length; i++) {
        final item = widget.cartItems[i];
        if (item == null) {
          _debugPrint('ERROR: Null item at index $i');
          hasErrors = true;
        }
      }
    } catch (e) {
      _debugPrint('ERROR: Exception validating cart items: $e');
      hasErrors = true;
    }
    
    if (hasErrors) {
      _debugPrint('❌ INPUT VALIDATION FAILED');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateBackWithError('Datos de pago inválidos');
      });
    } else {
      _debugPrint('✅ INPUT VALIDATION PASSED');
    }
  }

  // ✅ NAVEGACIÓN SEGURA DE VUELTA CON ERROR
  void _navigateBackWithError(String message) {
    if (!mounted) return;
    
    _debugPrint('Navigating back with error: $message');
    Navigator.of(context).pop();
    
    // Mostrar error en el contexto anterior
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  // ✅ DEBUGGING HELPER
  void _debugPrint(String message) {
    debugPrint('[PaymentPage] $message');
  }

  // ✅ HELPER PARA MOSTRAR ERRORES
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'CERRAR',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Consumer<PaymentProvider>(
        builder: (context, paymentProvider, child) {
          // ✅ VERIFICAR ERRORES DEL PROVIDER
          if (paymentProvider.hasError && _lastError != paymentProvider.errorMessage) {
            _lastError = paymentProvider.errorMessage;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showErrorSnackBar(paymentProvider.errorMessage!);
            });
          }

          // Si está procesando, mostrar pantalla de carga
          if (_isProcessingPayment || paymentProvider.paymentStatus == PaymentStatus.loading) {
            return _buildProcessingState();
          }

          return Column(
            children: [
              // Payment method selection
              _buildPaymentMethodSelection(paymentProvider),
              
              // Content
              Expanded(
                child: _buildContent(paymentProvider),
              ),
              
              // Bottom section with summary and pay button
              _buildBottomSection(paymentProvider),
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
      leading: IconButton(
        icon: Icon(
          IconlyLight.arrow_left,
          color: AppColors.textPrimary,
        ),
        onPressed: () {
          _debugPrint('Back button pressed');
          Navigator.of(context).pop();
        },
      ),
      title: Text(
        'Método de pago',
        style: TextStyle(
          fontSize: ResponsiveUtils.getFontSize(context, FontSizeType.title),
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildProcessingState() {
    return Center(
      child: FadeIn(
        duration: const Duration(milliseconds: 600),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated loading indicator
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                strokeWidth: 6,
              ),
            ),
            
            const SizedBox(height: 32),
            
            Text(
              'Procesando pago...',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Por favor espera mientras procesamos tu pago de forma segura',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.info.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    IconlyBold.shield_done,
                    size: 20,
                    color: AppColors.info,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Transacción protegida con SSL',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.info,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelection(PaymentProvider paymentProvider) {
    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selecciona tu método de pago',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            // Stripe Payment (Tarjeta)
            PaymentMethodCard(
              title: 'Pagar con tarjeta',
              description: 'Visa, Mastercard, American Express - Procesado por Stripe',
              icon: IconlyLight.wallet,
              isSelected: _selectedPaymentType == PaymentType.stripe,
              onTap: () {
                _debugPrint('Stripe payment method selected');
                setState(() {
                  _selectedPaymentType = PaymentType.stripe;
                });
                paymentProvider.setPaymentType(PaymentType.stripe);
              },
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCardBrandIcon('VISA'),
                  const SizedBox(width: 4),
                  _buildCardBrandIcon('MC'),
                  const SizedBox(width: 4),
                  _buildCardBrandIcon('AMEX'),
                ],
              ),
            ),
            
            // Direct Payment
            PaymentMethodCard(
              title: 'Pago directo',
              description: 'Checkout rápido sin introducir datos de tarjeta',
              icon: IconlyLight.arrow_right,
              isSelected: _selectedPaymentType == PaymentType.direct,
              onTap: () {
                _debugPrint('Direct payment method selected');
                setState(() {
                  _selectedPaymentType = PaymentType.direct;
                });
                paymentProvider.setPaymentType(PaymentType.direct);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBrandIcon(String brand) {
    return Container(
      width: 28,
      height: 18,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: AppColors.border,
          width: 0.5,
        ),
      ),
      child: Center(
        child: Text(
          brand,
          style: const TextStyle(
            fontSize: 7,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(PaymentProvider paymentProvider) {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Payment form based on selected method
            if (_selectedPaymentType == PaymentType.stripe)
              _buildStripePaymentForm()
            else
              _buildDirectPaymentInfo(),
            
            const SizedBox(height: 24),
            
            // Security info
            _buildSecurityInfo(),
            
            const SizedBox(height: 24),
            
            // Order summary
            _buildOrderSummary(),
            
            // Error display
            if (paymentProvider.hasError) ...[
              const SizedBox(height: 20),
              _buildErrorWidget(paymentProvider.errorMessage!),
            ],
            
            const SizedBox(height: 100), // Space for bottom bar
          ],
        ),
      ),
    );
  }

Widget _buildStripePaymentForm() {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(IconlyBold.wallet, size: 24, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(
              'Pago con tarjeta',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // ✅ OPCIÓN 1: Información sin formulario
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(
                IconlyBold.wallet,
                size: 48,
                color: AppColors.primary,
              ),
              const SizedBox(height: 12),
              Text(
                'Pago seguro con Stripe',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Al presionar "Pagar", se abrirá el formulario seguro de Stripe donde podrás ingresar los datos de tu tarjeta.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ✅ MÉTODO SEPARADO PARA MANEJAR EL STRIPE CARD FIELD
Widget _buildStripeCardField() {
  try {
    return StripeCardFieldWidget(
      onValidityChanged: (isValid) {
        _debugPrint('Card validity changed: $isValid');
        if (mounted) {
          setState(() {
            _stripeCardValid = isValid;
          });
        }
      },
      onCardChanged: (cardDetails) {
        _debugPrint('Card details changed: ${cardDetails?.complete}');
      },
      enabled: !_isProcessingPayment,
    );
  } catch (e) {
    _debugPrint('Error building Stripe card field: $e');
    return _buildStripeErrorWidget(e);
  }
}

// ✅ WIDGET DE ERROR PARA STRIPE
Widget _buildStripeErrorWidget(Object error) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.error.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: AppColors.error.withOpacity(0.3),
        width: 1,
      ),
    ),
    child: Column(
      children: [
        Icon(
          IconlyLight.info_circle, 
          color: AppColors.error,
          size: 32,
        ),
        const SizedBox(height: 12),
        Text(
          'Error cargando formulario de tarjeta',
          style: TextStyle(
            color: AppColors.error,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'No se pudo inicializar Stripe. Verifica tu conexión a internet.',
          style: TextStyle(
            color: AppColors.error,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  _debugPrint('Retrying Stripe card field...');
                  setState(() {}); // Reintentar
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text(
                  'Reintentar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _debugPrint('Switching to direct payment due to Stripe error');
                  setState(() {
                    _selectedPaymentType = PaymentType.direct;
                  });
                  final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
                  paymentProvider.setPaymentType(PaymentType.direct);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primary),
                ),
                child: Text(
                  'Pago directo',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
        
        // ✅ INFORMACIÓN TÉCNICA EN MODO DEBUG
        if (kDebugMode) ...[
          const SizedBox(height: 12),
          ExpansionTile(
            title: Text(
              'Detalles técnicos',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Error: $error',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    ),
  );
}

  Widget _buildDirectPaymentInfo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.success.withOpacity(0.1),
            AppColors.success.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.success.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: Icon(
              IconlyBold.tick_square,
              size: 40,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 20),
          
          Text(
            'Pago directo rápido',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Tu orden será procesada directamente sin necesidad de ingresar datos de tarjeta. Es la forma más rápida y segura de completar tu compra.',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  IconlyBold.time_circle,
                  size: 16,
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                Text(
                  'Procesamiento instantáneo',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Icon(
            IconlyBold.shield_done,
            size: 24,
            color: AppColors.success,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pago 100% seguro',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Protegido por Stripe con encriptación SSL y cumplimiento PCI DSS',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return CheckoutSummaryWidget(
          subtotal: cartProvider.subtotal,
          shipping: cartProvider.shipping,
          tax: cartProvider.tax,
          total: cartProvider.finalTotal,
          itemCount: cartProvider.itemCount,
        );
      },
    );
  }

  Widget _buildErrorWidget(String error) {
    return FadeIn(
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.error.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              IconlyLight.info_circle,
              size: 20,
              color: AppColors.error,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                error,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection(PaymentProvider paymentProvider) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Total amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total a pagar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '\$${widget.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Pay button
            CustomButton(
              text: _getPayButtonText(),
              onPressed: _canProcessPayment(paymentProvider) 
                  ? () => _processPayment(paymentProvider)
                  : null,
              isLoading: _isProcessingPayment || paymentProvider.isProcessing,
              icon: IconlyLight.arrow_right,
              size: ButtonSize.large,
            ),
          ],
        ),
      ),
    );
  }

  String _getPayButtonText() {
    switch (_selectedPaymentType) {
      case PaymentType.stripe:
        return 'Pagar con Stripe (\$${widget.totalAmount.toStringAsFixed(2)})';
      case PaymentType.direct:
        return 'Procesar pago directo (\$${widget.totalAmount.toStringAsFixed(2)})';
    }
  }

bool _canProcessPayment(PaymentProvider paymentProvider) {
  if (_isProcessingPayment || paymentProvider.isProcessing) {
    return false;
  }
  
  switch (_selectedPaymentType) {
    case PaymentType.stripe:
      return true; // ✅ CAMBIO: Siempre permite procesar con Stripe
    case PaymentType.direct:
      return true;
  }
}

  // ✅ MÉTODO DE PAGO MEJORADO CON DEBUGGING
  Future<void> _processPayment(PaymentProvider paymentProvider) async {
    if (!_canProcessPayment(paymentProvider)) {
      _debugPrint('❌ Payment processing blocked - conditions not met');
      return;
    }
    
    _debugPrint('🚀 Starting payment process');
    _debugPrint('Payment Type: $_selectedPaymentType');
    _debugPrint('Amount: ${widget.totalAmount}');
    
    setState(() {
      _isProcessingPayment = true;
    });

    HapticFeedback.lightImpact();
    
    try {
      bool success = false;
      
      switch (_selectedPaymentType) {
        case PaymentType.stripe:
          _debugPrint('Processing Stripe payment...');
          success = await paymentProvider.processCompleteStripePayment();
          break;
          
        case PaymentType.direct:
          _debugPrint('Processing direct payment...');
          success = await paymentProvider.processDirectPurchase();
          break;
      }

      _debugPrint('Payment result: $success');

      if (success && mounted) {
        _debugPrint('✅ Payment successful, clearing cart and navigating');
        
        // Clear cart
        final cartProvider = Provider.of<CartProvider>(context, listen: false);
        await cartProvider.clearCart();
        
        // Navigate to success page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentSuccessPage(
              orderId: paymentProvider.lastOrderId ?? 'N/A',
              amount: paymentProvider.lastPurchaseAmount ?? widget.totalAmount,
              paymentMethod: _selectedPaymentType == PaymentType.stripe ? 'Stripe' : 'Directo',
            ),
          ),
        );
      } else if (mounted) {
        _debugPrint('❌ Payment failed or was canceled');
        
        // Handle specific error cases
        if (paymentProvider.wasPaymentCanceled) {
          _debugPrint('Payment was canceled by user');
          _showErrorSnackBar('Pago cancelado por el usuario');
        } else {
          final errorMsg = paymentProvider.errorMessage ?? 'Error procesando pago';
          _debugPrint('Payment error: $errorMsg');
          _showErrorSnackBar(errorMsg);
        }
      }
    } catch (error) {
      _debugPrint('❌ Payment exception: $error');
      if (mounted) {
        _showErrorSnackBar('Error inesperado: $error');
      }
    } finally {
      _debugPrint('Payment process completed, resetting processing state');
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
        });
      }
    }
  }
}