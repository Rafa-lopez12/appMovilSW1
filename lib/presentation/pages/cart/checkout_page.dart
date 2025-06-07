// lib/presentation/pages/cart/checkout_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/utils/validators.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/cart/cart_summary_widget.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
// import 'order_confirmation_page.dart';

class CheckoutPage extends StatefulWidget {
  final List<dynamic> cartItems;
  final double totalAmount;

  const CheckoutPage({
    Key? key,
    required this.cartItems,
    required this.totalAmount,
  }) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;
  
  int _currentStep = 0;
  bool _isProcessing = false;
  
  // Form keys
  final _shippingFormKey = GlobalKey<FormState>();
  final _paymentFormKey = GlobalKey<FormState>();
  
  // Shipping form controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _countryController = TextEditingController();
  
  // Payment form controllers
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderController = TextEditingController();
  
  // Options
  String _selectedShippingMethod = 'standard';
  String _selectedPaymentMethod = 'card';
  bool _sameAsBilling = true;
  bool _savePaymentMethod = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _pageController = PageController();
    
    // Pre-fill user data if available
    _prefillUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }

  void _prefillUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    
    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _emailController.text = user.email;
      _phoneController.text = user.phone ?? '';
      _addressController.text = user.address ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(),
          
          // Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildShippingStep(),
                _buildPaymentStep(),
                _buildReviewStep(),
              ],
            ),
          ),
          
          // Navigation buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: IconButton(
        icon: Icon(
          IconlyLight.arrow_left,
          color: AppColors.textPrimary,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Finalizar compra',
        style: TextStyle(
          fontSize: ResponsiveUtils.getFontSize(context, FontSizeType.title),
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildProgressIndicator() {
    final steps = ['Envío', 'Pago', 'Revisar'];
    
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Row(
        children: List.generate(steps.length, (index) {
          final isActive = index <= _currentStep;
          final isCompleted = index < _currentStep;
          
          return Expanded(
            child: Row(
              children: [
                // Step indicator
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? AppColors.success
                        : isActive
                            ? AppColors.primary
                            : AppColors.border,
                  ),
                  child: Center(
                    child: isCompleted
                        ? Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          )
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isActive ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                  ),
                ),
                
                // Step label
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    steps[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                ),
                
                // Progress line
                if (index < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: index < _currentStep
                            ? AppColors.success
                            : AppColors.border,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildShippingStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(
        ResponsiveUtils.getHorizontalPadding(context),
      ),
      child: Form(
        key: _shippingFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Section title
            _buildSectionTitle('Información de envío'),
            
            const SizedBox(height: 20),
            
            // Name fields
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _firstNameController,
                    labelText: 'Nombre',
                    prefixIcon: IconlyLight.profile,
                    validator: Validators.validateName,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    controller: _lastNameController,
                    labelText: 'Apellido',
                    prefixIcon: IconlyLight.profile,
                    validator: Validators.validateName,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Contact fields
            CustomTextField(
              controller: _emailController,
              labelText: 'Email',
              prefixIcon: IconlyLight.message,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.validateEmail,
            ),
            
            const SizedBox(height: 20),
            
            CustomTextField(
              controller: _phoneController,
              labelText: 'Teléfono',
              prefixIcon: IconlyLight.call,
              keyboardType: TextInputType.phone,
              validator: Validators.validatePhone,
            ),
            
            const SizedBox(height: 20),
            
            // Address fields
            CustomTextField(
              controller: _addressController,
              labelText: 'Dirección',
              prefixIcon: IconlyLight.location,
              validator: Validators.validateAddress,
            ),
            
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: CustomTextField(
                    controller: _cityController,
                    labelText: 'Ciudad',
                    prefixIcon: IconlyLight.location,
                    validator: Validators.validateRequired,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    controller: _zipCodeController,
                    labelText: 'Código postal',
                    keyboardType: TextInputType.number,
                    validator: Validators.validateRequired,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _stateController,
                    labelText: 'Estado/Provincia',
                    validator: Validators.validateRequired,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    controller: _countryController,
                    labelText: 'País',
                    validator: Validators.validateRequired,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Shipping method
            _buildSectionTitle('Método de envío'),
            const SizedBox(height: 16),
            _buildShippingMethods(),
            
            const SizedBox(height: 100), // Space for navigation buttons
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(
        ResponsiveUtils.getHorizontalPadding(context),
      ),
      child: Form(
        key: _paymentFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Payment method selection
            _buildSectionTitle('Método de pago'),
            const SizedBox(height: 16),
            _buildPaymentMethods(),
            
            const SizedBox(height: 32),
            
            // Card details
            if (_selectedPaymentMethod == 'card') ...[
              _buildSectionTitle('Detalles de la tarjeta'),
              const SizedBox(height: 20),
              
              CustomTextField(
                controller: _cardNumberController,
                labelText: 'Número de tarjeta',
                prefixIcon: IconlyLight.wallet,
                keyboardType: TextInputType.number,
                validator: Validators.validateCardNumber,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _CardNumberInputFormatter(),
                ],
              ),
              
              const SizedBox(height: 20),
              
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _expiryController,
                      labelText: 'MM/AA',
                      prefixIcon: IconlyLight.calendar,
                      keyboardType: TextInputType.number,
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
                      prefixIcon: IconlyLight.lock,
                      keyboardType: TextInputType.number,
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
              
              CustomTextField(
                controller: _cardHolderController,
                labelText: 'Nombre del titular',
                prefixIcon: IconlyLight.profile,
                validator: Validators.validateCardHolderName,
              ),
              
              const SizedBox(height: 20),
              
              // Save payment method checkbox
              CheckboxListTile(
                value: _savePaymentMethod,
                onChanged: (value) {
                  setState(() {
                    _savePaymentMethod = value ?? false;
                  });
                },
                title: Text(
                  'Guardar método de pago para futuras compras',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
              ),
            ],
            
            const SizedBox(height: 100), // Space for navigation buttons
          ],
        ),
      ),
    );
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(
        ResponsiveUtils.getHorizontalPadding(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          
          // Order summary
          CheckoutSummaryWidget(
            subtotal: widget.totalAmount * 0.85, // Mock calculation
            shipping: 15.0,
            tax: widget.totalAmount * 0.15,
            total: widget.totalAmount,
            itemCount: widget.cartItems.length,
            onEditCart: () => Navigator.of(context).pop(),
          ),
          
          const SizedBox(height: 24),
          
          // Shipping information
          _buildReviewSection(
            'Información de envío',
            [
              '${_firstNameController.text} ${_lastNameController.text}',
              _emailController.text,
              _phoneController.text,
              _addressController.text,
              '${_cityController.text}, ${_stateController.text} ${_zipCodeController.text}',
              _countryController.text,
            ],
            onEdit: () => _goToStep(0),
          ),
          
          const SizedBox(height: 24),
          
          // Payment information
          _buildReviewSection(
            'Método de pago',
            [
              _selectedPaymentMethod == 'card'
                  ? '**** **** **** ${_cardNumberController.text.replaceAll(' ', '').substring(_cardNumberController.text.replaceAll(' ', '').length - 4)}'
                  : 'PayPal',
              if (_selectedPaymentMethod == 'card')
                _cardHolderController.text,
            ],
            onEdit: () => _goToStep(1),
          ),
          
          const SizedBox(height: 100), // Space for navigation buttons
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: ResponsiveUtils.getFontSize(context, FontSizeType.subtitle),
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildShippingMethods() {
    final methods = [
      {
        'id': 'standard',
        'name': 'Envío estándar',
        'description': '5-7 días hábiles',
        'price': 15.0,
        'icon': IconlyLight.document,
      },
      {
        'id': 'express',
        'name': 'Envío express',
        'description': '2-3 días hábiles',
        'price': 25.0,
        'icon': IconlyLight.time_circle,
      },
      {
        'id': 'overnight',
        'name': 'Envío nocturno',
        'description': '1 día hábil',
        'price': 35.0,
        'icon': IconlyLight.arrow_up,
      },
    ];

    return Column(
      children: methods.map((method) {
        final isSelected = _selectedShippingMethod == method['id'];
        
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedShippingMethod = method['id'] as String;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  method['icon'] as IconData,
                  size: 24,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        method['name'] as String,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                      
                      const SizedBox(height: 2),
                      
                      Text(
                        method['description'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                Text(
                  (method['price'] as double) == 0 
                      ? 'Gratis' 
                      : '\$${(method['price'] as double).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPaymentMethods() {
    final methods = [
      {
        'id': 'card',
        'name': 'Tarjeta de crédito/débito',
        'description': 'Visa, Mastercard, American Express',
        'icon': IconlyLight.wallet,
      },
      {
        'id': 'paypal',
        'name': 'PayPal',
        'description': 'Paga con tu cuenta de PayPal',
        'icon': IconlyLight.wallet,
      },
    ];

    return Column(
      children: methods.map((method) {
        final isSelected = _selectedPaymentMethod == method['id'];
        
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedPaymentMethod = method['id'] as String;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  method['icon'] as IconData,
                  size: 24,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        method['name'] as String,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                      
                      const SizedBox(height: 2),
                      
                      Text(
                        method['description'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                if (isSelected)
                  Icon(
                    IconlyBold.tick_square,
                    size: 20,
                    color: AppColors.primary,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReviewSection(
    String title,
    List<String> items, {
    VoidCallback? onEdit,
  }) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              
              if (onEdit != null)
                GestureDetector(
                  onTap: onEdit,
                  child: Text(
                    'Editar',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          ...items.where((item) => item.isNotEmpty).map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: EdgeInsets.all(
        ResponsiveUtils.getHorizontalPadding(context),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Back button
            if (_currentStep > 0)
              Expanded(
                child: CustomButton(
                  text: 'Anterior',
                  onPressed: _goToPreviousStep,
                  type: ButtonType.outline,
                  icon: IconlyLight.arrow_left,
                ),
              ),
            
            if (_currentStep > 0) const SizedBox(width: 16),
            
            // Next/Complete button
            Expanded(
              flex: _currentStep == 0 ? 1 : 2,
              child: CustomButton(
                text: _currentStep == 2 ? 'Completar pedido' : 'Continuar',
                onPressed: _isProcessing ? null : _handleNextStep,
                isLoading: _isProcessing,
                icon: _currentStep == 2 ? IconlyLight.tick_square : IconlyLight.arrow_right,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goToStep(int step) {
    setState(() {
      _currentStep = step;
    });
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
    }
  }

  void _handleNextStep() {
    if (_currentStep < 2) {
      if (_validateCurrentStep()) {
        _goToStep(_currentStep + 1);
      }
    } else {
      _processOrder();
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _shippingFormKey.currentState?.validate() ?? false;
      case 1:
        if (_selectedPaymentMethod == 'card') {
          return _paymentFormKey.currentState?.validate() ?? false;
        }
        return true;
      case 2:
        return true;
      default:
        return true;
    }
  }

  Future<void> _processOrder() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate order processing
      await Future.delayed(const Duration(seconds: 2));

      // Clear cart
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      await cartProvider.clearCart();

      // Navigate to confirmation
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => OrderConfirmationPage(
      //       orderNumber: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      //       totalAmount: widget.totalAmount,
      //       estimatedDelivery: DateTime.now().add(const Duration(days: 7)),
      //     ),
      //   ),
      // );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error procesando el pedido: $error'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }
}

// Input formatters for card number and expiry date
class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
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