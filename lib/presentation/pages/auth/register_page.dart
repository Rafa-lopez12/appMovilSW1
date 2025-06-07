// lib/presentation/pages/auth/register_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prueba/presentation/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconly/iconly.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/password_strength_indicator.dart';
import '../../providers/auth_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  
  // Form controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addressController = TextEditingController();
  
  // Form states
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;
  bool _acceptNewsletter = true;
  int _currentStep = 0;
  int _passwordStrength = 0;
  
  // Animation controllers
  late AnimationController _progressController;
  late AnimationController _stepController;
  
  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _stepController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Listen to password changes for strength indicator
    _passwordController.addListener(_updatePasswordStrength);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    _progressController.dispose();
    _stepController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _updatePasswordStrength() {
    setState(() {
      _passwordStrength = Validators.getPasswordStrength(_passwordController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // Background decoration
          _buildBackground(),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Progress indicator
                _buildProgressIndicator(),
                
                // Form steps
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildPersonalInfoStep(),
                      _buildContactInfoStep(),
                      _buildPasswordStep(),
                      _buildConfirmationStep(),
                    ],
                  ),
                ),
                
                // Navigation buttons
                _buildNavigationButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          IconlyLight.arrow_left,
          color: AppColors.textPrimary,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        AppStrings.createAccount,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withOpacity(0.02),
            AppColors.background,
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Step indicators
          Row(
            children: List.generate(4, (index) {
              final isActive = index <= _currentStep;
              final isCompleted = index < _currentStep;
              
              return Expanded(
                child: Row(
                  children: [
                    // Step circle
                    FadeIn(
                      duration: Duration(milliseconds: 300 + (index * 100)),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted
                              ? AppColors.success
                              : isActive
                                  ? AppColors.primary
                                  : AppColors.border,
                          border: Border.all(
                            color: isActive ? AppColors.primary : AppColors.border,
                            width: 2,
                          ),
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
                                    color: isActive ? Colors.white : AppColors.textSecondary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    
                    // Progress line
                    if (index < 3)
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
          
          const SizedBox(height: 16),
          
          // Step title
          Text(
            _getStepTitle(_currentStep),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Step description
          Text(
            _getStepDescription(_currentStep),
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

  Widget _buildPersonalInfoStep() {
    return FadeInRight(
      duration: const Duration(milliseconds: 500),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // First Name
              CustomTextField(
                controller: _firstNameController,
                labelText: AppStrings.firstName,
                hintText: AppStrings.firstNameHint,
                prefixIcon: IconlyLight.profile,
                validator: Validators.validateName,
                textInputAction: TextInputAction.next,
              ),
              
              const SizedBox(height: 20),
              
              // Last Name
              CustomTextField(
                controller: _lastNameController,
                labelText: AppStrings.lastName,
                hintText: AppStrings.lastNameHint,
                prefixIcon: IconlyLight.profile,
                validator: Validators.validateName,
                textInputAction: TextInputAction.next,
              ),
              
              const SizedBox(height: 20),
              
              // Birth Date Picker
              _buildBirthDatePicker(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactInfoStep() {
    return FadeInRight(
      duration: const Duration(milliseconds: 500),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Email
            CustomTextField(
              controller: _emailController,
              labelText: AppStrings.email,
              hintText: AppStrings.emailHint,
              prefixIcon: IconlyLight.message,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.validateEmail,
              textInputAction: TextInputAction.next,
            ),
            
            const SizedBox(height: 20),
            
            // Phone
            CustomTextField(
              controller: _phoneController,
              labelText: AppStrings.phone,
              hintText: AppStrings.phoneHint,
              prefixIcon: IconlyLight.call,
              keyboardType: TextInputType.phone,
              validator: Validators.validateOptionalPhone,
              textInputAction: TextInputAction.next,
            ),
            
            const SizedBox(height: 20),
            
            // Address
            CustomTextField(
              controller: _addressController,
              labelText: AppStrings.address,
              hintText: AppStrings.addressHint,
              prefixIcon: IconlyLight.location,
              validator: Validators.validateOptionalAddress,
              textInputAction: TextInputAction.done,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordStep() {
    return FadeInRight(
      duration: const Duration(milliseconds: 500),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Password
            CustomTextField(
              controller: _passwordController,
              labelText: AppStrings.password,
              hintText: AppStrings.passwordHint,
              prefixIcon: IconlyLight.lock,
              obscureText: !_isPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? IconlyLight.show : IconlyLight.hide,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              validator: Validators.validatePassword,
              textInputAction: TextInputAction.next,
            ),
            
            const SizedBox(height: 12),
            
            // Password Strength Indicator
            PasswordStrengthIndicator(
              strength: _passwordStrength,
            ),
            
            const SizedBox(height: 20),
            
            // Confirm Password
            CustomTextField(
              controller: _confirmPasswordController,
              labelText: AppStrings.confirmPassword,
              hintText: AppStrings.confirmPasswordHint,
              prefixIcon: IconlyLight.lock,
              obscureText: !_isConfirmPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible ? IconlyLight.show : IconlyLight.hide,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              ),
              validator: (value) => Validators.validateConfirmPassword(
                value,
                _passwordController.text,
              ),
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationStep() {
    return FadeInRight(
      duration: const Duration(milliseconds: 500),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumen de tu cuenta',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildSummaryRow('Nombre', '${_firstNameController.text} ${_lastNameController.text}'),
                  _buildSummaryRow('Email', _emailController.text),
                  if (_phoneController.text.isNotEmpty)
                    _buildSummaryRow('Teléfono', _phoneController.text),
                  if (_addressController.text.isNotEmpty)
                    _buildSummaryRow('Dirección', _addressController.text),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Terms and Conditions
            _buildCheckboxTile(
              value: _acceptTerms,
              onChanged: (value) {
                setState(() {
                  _acceptTerms = value ?? false;
                });
              },
              title: 'Acepto los Términos y Condiciones',
              subtitle: 'Lee nuestros términos y condiciones',
              isRequired: true,
            ),
            
            const SizedBox(height: 16),
            
            // Newsletter
            _buildCheckboxTile(
              value: _acceptNewsletter,
              onChanged: (value) {
                setState(() {
                  _acceptNewsletter = value ?? false;
                });
              },
              title: 'Recibir ofertas y promociones',
              subtitle: 'Te enviaremos las mejores ofertas por email',
              isRequired: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBirthDatePicker() {
    return CustomTextField(
      controller: TextEditingController(), // This will be handled differently
      labelText: AppStrings.birthDate,
      hintText: AppStrings.birthDateHint,
      prefixIcon: IconlyLight.calendar,
      readOnly: true,
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
          firstDate: DateTime.now().subtract(const Duration(days: 36500)), // 100 years ago
          lastDate: DateTime.now().subtract(const Duration(days: 4745)), // 13 years ago
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: AppColors.primary,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: AppColors.textPrimary,
                ),
              ),
              child: child!,
            );
          },
        );
        
        if (date != null) {
          // Handle selected date
          setState(() {
            // Store the selected date
          });
        }
      },
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxTile({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String title,
    required String subtitle,
    required bool isRequired,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRequired && !value ? AppColors.error : AppColors.border,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (isRequired)
                      Text(
                        ' *',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
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

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Back button
          if (_currentStep > 0)
            Expanded(
              child: CustomButton(
                text: AppStrings.previous,
                onPressed: _goToPreviousStep,
                type: ButtonType.outline,
                icon: IconlyLight.arrow_left,
              ),
            ),
          
          if (_currentStep > 0) const SizedBox(width: 16),
          
          // Next/Register button
          Expanded(
            flex: _currentStep == 0 ? 1 : 2,
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return CustomButton(
                  text: _currentStep == 3 ? AppStrings.register : AppStrings.next,
                  onPressed: authProvider.isLoading ? null : _handleNextStep,
                  isLoading: authProvider.isLoading,
                  icon: _currentStep == 3 ? IconlyLight.tick_square : IconlyLight.arrow_right,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Información Personal';
      case 1:
        return 'Información de Contacto';
      case 2:
        return 'Seguridad';
      case 3:
        return 'Confirmación';
      default:
        return '';
    }
  }

  String _getStepDescription(int step) {
    switch (step) {
      case 0:
        return 'Cuéntanos un poco sobre ti';
      case 1:
        return 'Cómo podemos contactarte';
      case 2:
        return 'Protege tu cuenta';
      case 3:
        return 'Revisa y confirma tu información';
      default:
        return '';
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      HapticFeedback.selectionClick();
    }
  }

  void _handleNextStep() {
    if (_currentStep < 3) {
      if (_validateCurrentStep()) {
        setState(() {
          _currentStep++;
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        HapticFeedback.lightImpact();
      }
    } else {
      _handleRegister();
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _firstNameController.text.isNotEmpty &&
               _lastNameController.text.isNotEmpty;
      case 1:
        return Validators.validateEmail(_emailController.text) == null;
      case 2:
        return Validators.validatePassword(_passwordController.text) == null &&
               Validators.validateConfirmPassword(
                 _confirmPasswordController.text,
                 _passwordController.text,
               ) == null;
      case 3:
        return _acceptTerms;
      default:
        return true;
    }
  }

void _handleRegister() async {
  if (!_validateCurrentStep()) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Por favor acepta los términos y condiciones'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
    return;
  }

  // Add haptic feedback
  HapticFeedback.lightImpact();

  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final cartProvider = Provider.of<CartProvider>(context, listen: false);
  
  try {
    await authProvider.register(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      acceptNewsletter: _acceptNewsletter,
    );

    if (authProvider.isAuthenticated && mounted) {
      // Inicializar carrito para nuevo usuario
      await cartProvider.loadCart();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Cuenta creada exitosamente! Bienvenido, ${authProvider.currentUser?.firstName}!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      
      // Navigate to main app
      Navigator.of(context).pushReplacementNamed('/main');
    }
  } catch (error) {
    if (mounted) {
      String errorMessage = 'Error creando cuenta';
      
      // Personalizar mensaje según el tipo de error
      if (error.toString().contains('email already exists') || 
          error.toString().contains('ya está registrado')) {
        errorMessage = 'Este email ya está registrado. Intenta iniciar sesión';
      } else if (error.toString().contains('weak password') || 
                 error.toString().contains('password must have')) {
        errorMessage = 'La contraseña no cumple los requisitos de seguridad';
      } else if (error.toString().contains('invalid email')) {
        errorMessage = 'El formato del email no es válido';
      } else if (error.toString().contains('Error de conexión')) {
        errorMessage = 'Problema de conexión. Verifica tu internet';
      } else if (error.toString().contains('400')) {
        errorMessage = 'Datos inválidos. Verifica la información';
      } else if (error.toString().contains('500')) {
        errorMessage = 'Error del servidor. Intenta más tarde';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Reintentar',
            textColor: Colors.white,
            onPressed: () {
              _handleRegister();
            },
          ),
        ),
      );
    }
  }
}
}