import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/payment/payment_form_widget.dart';
import '../../widgets/payment/payment_method_card.dart';
import '../../widgets/cart/cart_summary_widget.dart';
import '../../providers/payment_provider.dart';
import '../../providers/cart_provider.dart';
import 'payment_success_page.dart';

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
    with TickerProviderStateMixin {
  late TabController _tabController;
  PaymentType _selectedPaymentType = PaymentType.stripe;
  Map<String, String> _cardFormData = {};
  bool _cardFormValid = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Consumer<PaymentProvider>(
        builder: (context, paymentProvider, child) {
          if (paymentProvider.paymentStatus == PaymentStatus.loading) {
            return _buildLoadingState();
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
        onPressed: () => Navigator.of(context).pop(),
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

  Widget _buildLoadingState() {
    return Center(
      child: FadeIn(
        duration: const Duration(milliseconds: 600),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: 24),
            Text(
              'Procesando pago...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Por favor espera mientras procesamos tu pago',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
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
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            // Stripe Payment
            PaymentMethodCard(
              title: 'Tarjeta de crédito/débito',
              description: 'Visa, Mastercard, American Express',
              icon: IconlyLight.wallet,
              isSelected: _selectedPaymentType == PaymentType.stripe,
              onTap: () {
                setState(() {
                  _selectedPaymentType = PaymentType.stripe;
                });
                paymentProvider.setPaymentType(PaymentType.stripe);
              },
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCardBrandIcon('visa'),
                  const SizedBox(width: 4),
                  _buildCardBrandIcon('mastercard'),
                  const SizedBox(width: 4),
                  _buildCardBrandIcon('amex'),
                ],
              ),
            ),
            
            // Direct Payment
            PaymentMethodCard(
              title: 'Pago directo',
              description: 'Checkout rápido sin tarjeta',
              icon: IconlyLight.arrow_right,
              isSelected: _selectedPaymentType == PaymentType.direct,
              onTap: () {
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
      width: 24,
      height: 16,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: AppColors.border,
          width: 0.5,
        ),
      ),
      child: Center(
        child: Text(
          brand.toUpperCase(),
          style: const TextStyle(
            fontSize: 6,
            fontWeight: FontWeight.bold,
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
            
            const SizedBox(height: 100), // Space for bottom bar
          ],
        ),
      ),
    );
  }

  Widget _buildStripePaymentForm() {
    return PaymentFormWidget(
      onFormValid: (formData) {
        setState(() {
          _cardFormData = formData;
          _cardFormValid = true;
        });
      },
      enabled: true,
    );
  }

  Widget _buildDirectPaymentInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Icon(
            IconlyBold.tick_square,
            size: 48,
            color: AppColors.success,
          ),
          const SizedBox(height: 16),
          Text(
            'Pago directo rápido',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tu orden será procesada directamente sin necesidad de ingresar datos de tarjeta. Es rápido y seguro.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Tus datos están protegidos con encriptación SSL',
                  style: TextStyle(
                    fontSize: 12,
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '\${widget.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Pay button
            CustomButton(
              text: _getPayButtonText(),
              onPressed: _canProcessPayment(paymentProvider) 
                  ? () => _processPayment(paymentProvider)
                  : null,
              isLoading: paymentProvider.isProcessing,
              icon: IconlyLight.arrow_right,
              size: ButtonSize.large,
            ),
            
            // Error message
            if (paymentProvider.hasError) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.error.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      IconlyLight.info_circle,
                      size: 16,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        paymentProvider.errorMessage!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getPayButtonText() {
    switch (_selectedPaymentType) {
      case PaymentType.stripe:
        return 'Pagar con tarjeta';
      case PaymentType.direct:
        return 'Procesar pago directo';
    }
  }

  bool _canProcessPayment(PaymentProvider paymentProvider) {
    if (paymentProvider.isProcessing) return false;
    
    switch (_selectedPaymentType) {
      case PaymentType.stripe:
        return _cardFormValid;
      case PaymentType.direct:
        return true;
    }
  }

  Future<void> _processPayment(PaymentProvider paymentProvider) async {
    HapticFeedback.lightImpact();
    
    try {
      bool success = false;
      
      switch (_selectedPaymentType) {
        case PaymentType.stripe:
          // Create payment intent first
          if (paymentProvider.stripePaymentIntent == null) {
            await paymentProvider.createPaymentFromCart();
          }
          
          if (paymentProvider.stripePaymentIntent != null) {
            success = await paymentProvider.confirmStripePayment();
          }
          break;
          
        case PaymentType.direct:
          success = await paymentProvider.processDirectPurchase();
          break;
      }

      if (success && mounted) {
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
              paymentMethod: _selectedPaymentType == PaymentType.stripe ? 'Tarjeta' : 'Directo',
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error procesando pago: $error'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}