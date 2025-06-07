import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconly/iconly.dart';
import 'package:animate_do/animate_do.dart';

import '../../../core/constants/app_colors.dart';



class PaymentStatusWidget extends StatelessWidget {
  final String status;
  final String message;
  final String? orderId;
  final double? amount;
  final VoidCallback? onContinue;
  final VoidCallback? onRetry;

  const PaymentStatusWidget({
    Key? key,
    required this.status,
    required this.message,
    this.orderId,
    this.amount,
    this.onContinue,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      duration: const Duration(milliseconds: 800),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status Icon
            _buildStatusIcon(),
            
            const SizedBox(height: 32),
            
            // Message
            Text(
              message,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // Order details
            if (orderId != null || amount != null)
              _buildOrderDetails(),
            
            const SizedBox(height: 32),
            
            // Actions
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    IconData icon;
    Color color;
    
    switch (status.toLowerCase()) {
      case 'success':
      case 'succeeded':
        icon = IconlyBold.tick_square;
        color = AppColors.success;
        break;
      case 'failed':
      case 'error':
        icon = IconlyBold.close_square;
        color = AppColors.error;
        break;
      case 'processing':
      case 'loading':
        icon = IconlyBold.time_circle;
        color = AppColors.warning;
        break;
      default:
        icon = IconlyBold.info_circle;
        color = AppColors.info;
    }
    
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 60,
        color: color,
      ),
    );
  }

  Widget _buildOrderDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          if (orderId != null)
            _buildDetailRow('Número de orden', orderId!),
          if (amount != null) ...[
            if (orderId != null) const SizedBox(height: 8),
            _buildDetailRow('Monto', '\$${amount!.toStringAsFixed(2)}'),
          ],
        ],
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

  Widget _buildActions() {
    switch (status.toLowerCase()) {
      case 'success':
      case 'succeeded':
        return Column(
          children: [
            if (onContinue != null)
              ElevatedButton(
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(200, 48),
                ),
                child: const Text(
                  'Continuar comprando',
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        );
      case 'failed':
      case 'error':
        return Column(
          children: [
            if (onRetry != null)
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  minimumSize: const Size(200, 48),
                ),
                child: const Text(
                  'Intentar de nuevo',
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        );
      default:
        return const CircularProgressIndicator();
    }
  }
}