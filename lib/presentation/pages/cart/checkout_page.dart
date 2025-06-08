// lib/presentation/pages/cart/checkout_page.dart - VERSIÓN CORREGIDA
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
import '../payment/payment_page.dart';

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
  
  // 🔧 VARIABLES DE CONTROL CON VALORES POR DEFECTO SEGUROS
  int _currentStep = 0;
  bool _isProcessing = false;
  
  // Form keys
  final _shippingFormKey = GlobalKey<FormState>();
  
  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _countryController = TextEditingController();
  
  // Shipping options
  String _selectedShippingMethod = 'standard';
  Map<String, dynamic> _shippingData = {};

  @override
  void initState() {
    super.initState();
    
    // 🔍 VALIDACIONES CRÍTICAS PRIMERO
    print('=== CHECKOUT INIT DEBUG ===');
    print('Cart items: ${widget.cartItems.length}');
    print('Total amount: ${widget.totalAmount}');
    
    // 🚨 VALIDAR DATOS ANTES DE CONTINUAR
    if (!_validateInputData()) {
      return; // Sale early si hay problemas
    }
    
    // ✅ INICIALIZACIÓN SEGURA
    _prefillUserData();
  }

  // 🔍 VALIDACIÓN DE DATOS DE ENTRADA
  bool _validateInputData() {
    if (widget.cartItems.isEmpty) {
      print('ERROR: Cart items is empty');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateBackWithError('El carrito está vacío');
      });
      return false;
    }

    if (widget.totalAmount <= 0) {
      print('ERROR: Invalid total amount: ${widget.totalAmount}');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateBackWithError('Total de compra inválido');
      });
      return false;
    }

    return true;
  }

  void _navigateBackWithError(String message) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    // Dispose controllers safely
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _prefillUserData() {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;
      
      if (user != null) {
        _firstNameController.text = user.firstName ?? '';
        _lastNameController.text = user.lastName ?? '';
        _emailController.text = user.email ?? '';
        _phoneController.text = user.phone ?? '';
        _addressController.text = user.address ?? '';
        _countryController.text = 'Bolivia'; // Default country
      }
    } catch (e) {
      print('Error prefilling user data: $e');
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
            child: _buildCurrentStep(),
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
    final steps = ['Envío', 'Revisión', 'Pago'];
    
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

  Widget _buildCurrentStep() {
    // 🔧 USAR SWITCH SEGURO EN LUGAR DE PAGEVIEW
    switch (_currentStep) {
      case 0:
        return _buildShippingStep();
      case 1:
        return _buildReviewStep();
      case 2:
        return _buildPaymentStep();
      default:
        return _buildShippingStep(); // Fallback seguro
    }
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
                    labelText: 'Estado/Departamento',
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
            
            const SizedBox(height: 100),
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
            subtotal: widget.totalAmount * 0.85,
            shipping: _getShippingCost(),
            tax: widget.totalAmount * 0.15,
            total: widget.totalAmount,
            itemCount: widget.cartItems.length,
            onEditCart: () => Navigator.of(context).pop(),
          ),
          
          const SizedBox(height: 24),
          
          // Shipping information review
          _buildReviewSection(
            'Información de envío',
            [
              '${_firstNameController.text} ${_lastNameController.text}',
              _emailController.text,
              _phoneController.text,
              _addressController.text,
              '${_cityController.text}, ${_stateController.text} ${_zipCodeController.text}',
              _countryController.text,
              'Método: ${_getShippingMethodName()}',
            ],
            onEdit: () => _goToStep(0),
          ),
          
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildPaymentStep() {
    // Este paso navega a PaymentPage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToPayment();
    });
    
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
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
                  '\$${(method['price'] as double).toStringAsFixed(2)}',
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
        border: Border.all(color: AppColors.border, width: 1),
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
      padding: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
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
            
            // Next button
            Expanded(
              flex: _currentStep == 0 ? 1 : 2,
              child: CustomButton(
                text: _getNextButtonText(),
                onPressed: _isProcessing ? null : _handleNextStep,
                isLoading: _isProcessing,
                icon: _currentStep == 1 ? IconlyLight.tick_square : IconlyLight.arrow_right,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getNextButtonText() {
    switch (_currentStep) {
      case 0:
        return 'Continuar';
      case 1:
        return 'Proceder al pago';
      default:
        return 'Continuar';
    }
  }

  void _goToStep(int step) {
    if (step >= 0 && step <= 2) {
      setState(() {
        _currentStep = step;
      });
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
    }
  }

  void _handleNextStep() {
    if (_validateCurrentStep()) {
      if (_currentStep < 1) {
        _goToStep(_currentStep + 1);
      } else {
        // Go to payment
        _navigateToPayment();
      }
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (!(_shippingFormKey.currentState?.validate() ?? false)) {
          return false;
        }
        _saveShippingData();
        return true;
      case 1:
        return true;
      default:
        return true;
    }
  }

  void _saveShippingData() {
    _shippingData = {
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'address': _addressController.text,
      'city': _cityController.text,
      'state': _stateController.text,
      'zipCode': _zipCodeController.text,
      'country': _countryController.text,
      'shippingMethod': _selectedShippingMethod,
    };
  }

  void _navigateToPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          totalAmount: widget.totalAmount,
          cartItems: widget.cartItems,
        ),
      ),
    );
  }

  double _getShippingCost() {
    switch (_selectedShippingMethod) {
      case 'express':
        return 25.0;
      case 'standard':
      default:
        return 15.0;
    }
  }

  String _getShippingMethodName() {
    switch (_selectedShippingMethod) {
      case 'express':
        return 'Express (2-3 días)';
      case 'standard':
      default:
        return 'Estándar (5-7 días)';
    }
  }
}