import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconly/iconly.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_utils.dart';


class PaymentMethodPage extends StatefulWidget {
  const PaymentMethodPage({Key? key}) : super(key: key);

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  final List<Map<String, dynamic>> _savedPaymentMethods = [
    {
      'id': '1',
      'type': 'visa',
      'lastFour': '4242',
      'expiryDate': '12/25',
      'isDefault': true,
    },
    {
      'id': '2',
      'type': 'mastercard',
      'lastFour': '8888',
      'expiryDate': '10/26',
      'isDefault': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Métodos de pago'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add new payment method
            _buildAddNewPaymentMethod(),
            
            const SizedBox(height: 24),
            
            // Saved payment methods
            if (_savedPaymentMethods.isNotEmpty) ...[
              Text(
                'Métodos guardados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: 16),
              
              ..._savedPaymentMethods.map((method) => 
                _buildSavedPaymentMethod(method)).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddNewPaymentMethod() {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to add payment method
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                IconlyLight.plus,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Agregar método de pago',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'Tarjeta de crédito o débito',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            Icon(
              IconlyLight.arrow_right_2,
              color: AppColors.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedPaymentMethod(Map<String, dynamic> method) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          // Card icon
          Container(
            width: 40,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              IconlyLight.wallet,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Card info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '•••• •••• •••• ${method['lastFour']}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (method['isDefault']) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Principal',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  'Expira ${method['expiryDate']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Actions
          PopupMenuButton<String>(
            icon: Icon(
              IconlyLight.more_circle,
              color: AppColors.textSecondary,
            ),
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  // TODO: Edit payment method
                  break;
                case 'delete':
                  _deletePaymentMethod(method['id']);
                  break;
                case 'default':
                  _setAsDefault(method['id']);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text('Editar'),
              ),
              if (!method['isDefault'])
                const PopupMenuItem(
                  value: 'default',
                  child: Text('Establecer como principal'),
                ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Eliminar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _deletePaymentMethod(String id) {
    // TODO: Implement delete payment method
    setState(() {
      _savedPaymentMethods.removeWhere((method) => method['id'] == id);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Método de pago eliminado'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _setAsDefault(String id) {
    // TODO: Implement set as default
    setState(() {
      for (var method in _savedPaymentMethods) {
        method['isDefault'] = method['id'] == id;
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Método de pago principal actualizado'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}