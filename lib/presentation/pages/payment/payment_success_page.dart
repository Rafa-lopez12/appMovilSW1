// lib/presentation/pages/payment/payment_success_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconly/iconly.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../widgets/common/custom_button.dart';

class PaymentSuccessPage extends StatefulWidget {
  final String orderId;
  final double amount;
  final String paymentMethod;

  const PaymentSuccessPage({
    Key? key,
    required this.orderId,
    required this.amount,
    required this.paymentMethod,
  }) : super(key: key);

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage>
    with TickerProviderStateMixin {
  late AnimationController _checkmarkController;
  late AnimationController _cardController;
  late Animation<double> _checkmarkAnimation;
  late Animation<Offset> _cardSlideAnimation;

  @override
  void initState() {
    super.initState();
    _checkmarkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _checkmarkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkmarkController, curve: Curves.elasticOut),
    );

    _cardSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOutBack),
    );

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _checkmarkController.forward();
    
    await Future.delayed(const Duration(milliseconds: 400));
    _cardController.forward();
  }

  @override
  void dispose() {
    _checkmarkController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // Success animation
              _buildSuccessAnimation(),
              
              const SizedBox(height: 40),
              
              // Success message
              _buildSuccessMessage(),
              
              const SizedBox(height: 32),
              
              // Order details card
              _buildOrderDetailsCard(),
              
              const Spacer(),
              
              // Action buttons
              _buildActionButtons(),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessAnimation() {
    return AnimatedBuilder(
      animation: _checkmarkAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _checkmarkAnimation.value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.success, AppColors.success.withOpacity(0.8)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.check,
              size: 60,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuccessMessage() {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      delay: const Duration(milliseconds: 600),
      child: Column(
        children: [
          Text(
            '¡Pago exitoso!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Tu orden ha sido procesada correctamente.\nRecibirás un email de confirmación pronto.',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsCard() {
    return SlideTransition(
      position: _cardSlideAnimation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Icon(
                  IconlyBold.document,
                  size: 24,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Detalles de la orden',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Order details
            _buildDetailRow('Número de orden', widget.orderId),
            const SizedBox(height: 12),
            _buildDetailRow('Monto pagado', '\$${widget.amount.toStringAsFixed(2)}'),
            const SizedBox(height: 12),
            _buildDetailRow('Método de pago', widget.paymentMethod),
            const SizedBox(height: 12),
            _buildDetailRow('Fecha', _formatDate(DateTime.now())),
            
            const SizedBox(height: 20),
            
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.success.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    IconlyBold.tick_square,
                    size: 16,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Pagado',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
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

  Widget _buildDetailRow(String label, String value) {
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
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      delay: const Duration(milliseconds: 1000),
      child: Column(
        children: [
          // Primary action - Continue shopping
          CustomButton(
            text: 'Continuar comprando',
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/main',
                (route) => false,
              );
            },
            icon: IconlyLight.bag,
            size: ButtonSize.large,
          ),
          
          const SizedBox(height: 12),
          
          // Secondary actions
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Ver orden',
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/order-detail',
                      arguments: widget.orderId,
                    );
                  },
                  type: ButtonType.outline,
                  icon: IconlyLight.document,
                  size: ButtonSize.medium,
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: CustomButton(
                  text: 'Compartir',
                  onPressed: _shareReceipt,
                  type: ButtonType.outline,
                  icon: IconlyLight.upload,
                  size: ButtonSize.medium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _shareReceipt() {
    HapticFeedback.lightImpact();
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de compartir próximamente'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}