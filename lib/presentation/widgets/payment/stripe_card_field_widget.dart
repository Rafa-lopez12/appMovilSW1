// lib/presentation/widgets/payment/stripe_card_field_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconly/iconly.dart';

import '../../../core/constants/app_colors.dart';

class StripeCardFieldWidget extends StatefulWidget {
  final Function(bool isValid) onValidityChanged;
  final Function(CardFieldInputDetails?) onCardChanged;
  final bool enabled;

  const StripeCardFieldWidget({
    Key? key,
    required this.onValidityChanged,
    required this.onCardChanged,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<StripeCardFieldWidget> createState() => _StripeCardFieldWidgetState();
}

class _StripeCardFieldWidgetState extends State<StripeCardFieldWidget> {
  bool _isValid = false;
  bool _isComplete = false;

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card field label
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(
                  IconlyLight.wallet,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Información de la tarjeta',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          
          // Stripe Card Field
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isValid ? AppColors.success : AppColors.border,
                width: _isValid ? 2 : 1,
              ),
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
              child: CardField(
                onCardChanged: (card) {
                  setState(() {
                    _isValid = card?.complete ?? false;
                    _isComplete = card?.complete ?? false;
                  });
                  
                  widget.onValidityChanged(_isValid);
                  widget.onCardChanged(card);
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Número de tarjeta',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
                enablePostalCode: false,
              ),
            ),
          ),
          
          // Security info
          const SizedBox(height: 12),
          _buildSecurityInfo(),
          
          // Card validation status
          if (_isComplete) ...[
            const SizedBox(height: 12),
            _buildValidationStatus(),
          ],
        ],
      ),
    );
  }

  Widget _buildSecurityInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.info.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            IconlyBold.shield_done,
            size: 16,
            color: AppColors.info,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Tus datos están protegidos con encriptación SSL de extremo a extremo',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.info,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationStatus() {
    return FadeIn(
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.success.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              IconlyBold.tick_square,
              size: 16,
              color: AppColors.success,
            ),
            const SizedBox(width: 8),
            Text(
              'Tarjeta válida y lista para el pago',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}