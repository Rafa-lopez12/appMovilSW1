import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconly/iconly.dart';
import 'package:animate_do/animate_do.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../common/custom_text_field.dart';

class PaymentFormWidget extends StatefulWidget {
  final Function(Map<String, String>) onFormValid;
  final Map<String, String>? initialData;
  final bool enabled;

  const PaymentFormWidget({
    Key? key,
    required this.onFormValid,
    this.initialData,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<PaymentFormWidget> createState() => _PaymentFormWidgetState();
}

class _PaymentFormWidgetState extends State<PaymentFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _setupListeners();
  }

  void _loadInitialData() {
    if (widget.initialData != null) {
      _cardNumberController.text = widget.initialData!['cardNumber'] ?? '';
      _expiryController.text = widget.initialData!['expiry'] ?? '';
      _cvvController.text = widget.initialData!['cvv'] ?? '';
      _cardHolderController.text = widget.initialData!['cardHolder'] ?? '';
    }
  }

  void _setupListeners() {
    _cardNumberController.addListener(_onFormChanged);
    _expiryController.addListener(_onFormChanged);
    _cvvController.addListener(_onFormChanged);
    _cardHolderController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    if (_formKey.currentState?.validate() == true) {
      widget.onFormValid({
        'cardNumber': _cardNumberController.text,
        'expiry': _expiryController.text,
        'cvv': _cvvController.text,
        'cardHolder': _cardHolderController.text,
      });
    }
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Card Preview
            _buildCardPreview(),
            
            const SizedBox(height: 24),
            
            // Card Number
            CustomTextField(
              controller: _cardNumberController,
              labelText: 'Número de tarjeta',
              hintText: '1234 5678 9012 3456',
              prefixIcon: IconlyLight.wallet,
              keyboardType: TextInputType.number,
              enabled: widget.enabled,
              validator: Validators.validateCardNumber,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                _CardNumberInputFormatter(),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Expiry and CVV
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _expiryController,
                    labelText: 'MM/AA',
                    hintText: '12/25',
                    prefixIcon: IconlyLight.calendar,
                    keyboardType: TextInputType.number,
                    enabled: widget.enabled,
                    validator: Validators.validateExpiryDate,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _ExpiryDateInputFormatter(),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    controller: _cvvController,
                    labelText: 'CVV',
                    hintText: '123',
                    prefixIcon: IconlyLight.lock,
                    keyboardType: TextInputType.number,
                    enabled: widget.enabled,
                    validator: Validators.validateCVV,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Card Holder Name
            CustomTextField(
              controller: _cardHolderController,
              labelText: 'Nombre del titular',
              hintText: 'Juan Pérez',
              prefixIcon: IconlyLight.profile,
              enabled: widget.enabled,
              validator: Validators.validateCardHolderName,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardPreview() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card brand and chip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Text(
                  _getCardBrand(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const Spacer(),
            
            // Card number
            Text(
              _formatCardNumber(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Card holder and expiry
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TITULAR',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _cardHolderController.text.isEmpty 
                          ? 'NOMBRE APELLIDO'
                          : _cardHolderController.text.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'EXPIRA',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _expiryController.text.isEmpty ? 'MM/AA' : _expiryController.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatCardNumber() {
    final text = _cardNumberController.text.replaceAll(' ', '');
    if (text.isEmpty) return '•••• •••• •••• ••••';
    
    final formatted = text.padRight(16, '•');
    return '${formatted.substring(0, 4)} ${formatted.substring(4, 8)} ${formatted.substring(8, 12)} ${formatted.substring(12, 16)}';
  }

  String _getCardBrand() {
    final number = _cardNumberController.text.replaceAll(' ', '');
    if (number.isEmpty) return 'CARD';
    
    if (number.startsWith('4')) return 'VISA';
    if (number.startsWith('5')) return 'MASTERCARD';
    if (number.startsWith('3')) return 'AMEX';
    return 'CARD';
  }
}

// Input formatters
class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length && i < 16; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }
    
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length && i < 4; i++) {
      if (i == 2) {
        buffer.write('/');
      }
      buffer.write(text[i]);
    }
    
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}