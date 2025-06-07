// lib/presentation/pages/auth/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prueba/presentation/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconly/iconly.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/responsive_sizes.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/utils/validators.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/responsive_wrapper.dart';
import '../../providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  
  late AnimationController _backgroundController;
  late AnimationController _formController;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _formController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _formController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _backgroundController.dispose();
    _formController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Animated Background
          _buildAnimatedBackground(),
          
          // Main Content - Usando ResponsiveScrollView con mejores ajustes
          ResponsiveScrollView(
            maxWidth: 400,
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.getHorizontalPadding(context),
              vertical: ResponsiveUtils.isVerySmallScreen(context) ? 8.0 : 16.0,
            ),
            child: Column(
              children: [
                // Espaciado superior adaptativo
                SizedBox(height: ResponsiveUtils.isVerySmallScreen(context) ? 20 : 40),
                
                // Logo and Welcome Section
                _buildWelcomeSection(),
                
                // Espaciado adaptativo
                SizedBox(height: ResponsiveUtils.isVerySmallScreen(context) ? 16 : 32),
                
                // Login Form
                _buildLoginForm(),
                
                // Espaciado adaptativo
                SizedBox(height: ResponsiveUtils.isVerySmallScreen(context) ? 12 : 24),
                
                // Social Login Options
                _buildSocialLogin(),
                
                // Espaciado flexible
                SizedBox(height: ResponsiveUtils.isVerySmallScreen(context) ? 16 : 32),
                
                // Register Link
                _buildRegisterLink(),
                
                // Espaciado inferior mínimo
                SizedBox(height: ResponsiveUtils.isVerySmallScreen(context) ? 8 : 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: GradientRotation(_backgroundController.value * 2 * 3.14159),
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.secondary.withOpacity(0.05),
                AppColors.accent.withOpacity(0.1),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Floating Circles
              Positioned(
                top: 100,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 200,
                left: -100,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.secondary.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection() {
    final isVerySmall = ResponsiveUtils.isVerySmallScreen(context);
    
    return FadeInDown(
      duration: const Duration(milliseconds: 800),
      child: Column(
        children: [
          // App Logo with Animation - tamaño adaptativo
          Container(
            width: isVerySmall ? 70 : ResponsiveSizes.getLogoSize(context, LogoSizeType.medium),
            height: isVerySmall ? 70 : ResponsiveSizes.getLogoSize(context, LogoSizeType.medium),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              IconlyBold.bag_2,
              size: isVerySmall ? 35 : ResponsiveUtils.getIconSize(context, IconSizeType.large),
              color: Colors.white,
            ),
          ),
          
          SizedBox(height: isVerySmall ? 12 : 20),
          
          // Welcome Text - tamaño adaptativo
          Text(
            AppStrings.welcomeBack,
            style: TextStyle(
              fontSize: isVerySmall ? 24 : ResponsiveUtils.getFontSize(context, FontSizeType.headline),
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          
          SizedBox(height: isVerySmall ? 4 : 8),
          
          Text(
            AppStrings.loginSubtitle,
            style: TextStyle(
              fontSize: isVerySmall ? 14 : ResponsiveUtils.getFontSize(context, FontSizeType.body),
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
            maxLines: isVerySmall ? 2 : 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    final isVerySmall = ResponsiveUtils.isVerySmallScreen(context);
    
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      delay: const Duration(milliseconds: 200),
      child: Container(
        padding: EdgeInsets.all(isVerySmall ? 16 : 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context, BorderRadiusType.medium)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Email Field
              CustomTextField(
                controller: _emailController,
                labelText: AppStrings.email,
                hintText: AppStrings.emailHint,
                prefixIcon: IconlyLight.message,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
                textInputAction: TextInputAction.next,
              ),
              
              SizedBox(height: isVerySmall ? 16 : 20),
              
              // Password Field
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
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _handleLogin(),
              ),
              
              SizedBox(height: isVerySmall ? 12 : 16),
              
              // Remember Me & Forgot Password
              Row(
                children: [
                  // Remember Me Checkbox
                  Transform.scale(
                    scale: isVerySmall ? 0.7 : 0.8,
                    child: Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Text(
                    AppStrings.rememberMe,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: isVerySmall ? 12 : 14,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Forgot Password
                  TextButton(
                    onPressed: _handleForgotPassword,
                    child: Text(
                      AppStrings.forgotPassword,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: isVerySmall ? 12 : 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: isVerySmall ? 16 : 24),
              
              // Login Button
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return CustomButton(
                    text: AppStrings.login,
                    onPressed: authProvider.isLoading ? null : _handleLogin,
                    isLoading: authProvider.isLoading,
                    icon: IconlyLight.login,
                    size: isVerySmall ? ButtonSize.small : ButtonSize.medium,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLogin() {
    final isVerySmall = ResponsiveUtils.isVerySmallScreen(context);
    
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      delay: const Duration(milliseconds: 400),
      child: Column(
        children: [
          // Divider
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: AppColors.textSecondary.withOpacity(0.3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  AppStrings.orContinueWith,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: isVerySmall ? 12 : 14,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: AppColors.textSecondary.withOpacity(0.3),
                ),
              ),
            ],
          ),
          
          SizedBox(height: isVerySmall ? 16 : 24),
          
          // Social Buttons - usando iconos temporales
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSocialButton(
                '', // No necesitamos path por ahora
                'Google',
                () => _handleSocialLogin('google'),
              ),
              _buildSocialButton(
                '', // No necesitamos path por ahora
                'Apple',
                () => _handleSocialLogin('apple'),
              ),
              _buildSocialButton(
                '', // No necesitamos path por ahora
                'Facebook',
                () => _handleSocialLogin('facebook'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(String iconPath, String label, VoidCallback onTap) {
    final isVerySmall = ResponsiveUtils.isVerySmallScreen(context);
    final size = isVerySmall ? 60.0 : 80.0;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ResponsiveUtils.getBorderRadius(context, BorderRadiusType.medium)),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Usar iconos de Material en lugar de SVG por ahora
            Icon(
              _getSocialIcon(label),
              size: isVerySmall ? 20 : 24,
              color: _getSocialColor(label),
            ),
            SizedBox(height: isVerySmall ? 4 : 8),
            Text(
              label,
              style: TextStyle(
                fontSize: isVerySmall ? 10 : 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getSocialIcon(String label) {
    switch (label.toLowerCase()) {
      case 'google':
        return Icons.g_mobiledata;
      case 'apple':
        return Icons.apple;
      case 'facebook':
        return Icons.facebook;
      default:
        return Icons.login;
    }
  }

  Color _getSocialColor(String label) {
    switch (label.toLowerCase()) {
      case 'google':
        return AppColors.google;
      case 'apple':
        return AppColors.apple;
      case 'facebook':
        return AppColors.facebook;
      default:
        return AppColors.primary;
    }
  }

  Widget _buildRegisterLink() {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      delay: const Duration(milliseconds: 600),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppStrings.dontHaveAccount,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
          TextButton(
            onPressed: _navigateToRegister,
            child: Text(
              AppStrings.signUp,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

void _handleLogin() async {
  if (!_formKey.currentState!.validate()) return;

  // Add haptic feedback
  HapticFeedback.lightImpact();

  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final cartProvider = Provider.of<CartProvider>(context, listen: false);
  try {
    await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      rememberMe: _rememberMe,
    );

    if (authProvider.isAuthenticated && mounted) {
      // Cargar el carrito del usuario
      await cartProvider.loadCart();
      
      // Mostrar mensaje de bienvenida
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Bienvenido, ${authProvider.currentUser?.firstName}!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      
      // Navegar a la pantalla principal
      Navigator.of(context).pushReplacementNamed('/main');
    }
  } catch (error) {
    if (mounted) {
      String errorMessage = 'Error de conexión';
      
      // Personalizar mensaje según el tipo de error
      if (error.toString().contains('Credentials are not valid')) {
        errorMessage = 'Email o contraseña incorrectos';
      } else if (error.toString().contains('User is inactive')) {
        errorMessage = 'Cuenta inactiva. Contacta al administrador';
      } else if (error.toString().contains('Error de conexión')) {
        errorMessage = 'Problema de conexión. Verifica tu internet';
      } else if (error.toString().contains('401')) {
        errorMessage = 'Credenciales inválidas';
      } else if (error.toString().contains('404')) {
        errorMessage = 'Servicio no disponible';
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
              _handleLogin();
            },
          ),
        ),
      );
    }
  }
}

  void _handleForgotPassword() {
    // Add haptic feedback
    HapticFeedback.selectionClick();
    
    Navigator.of(context).pushNamed('/forgot-password');
  }

  void _handleSocialLogin(String provider) {
    // Add haptic feedback
    HapticFeedback.selectionClick();
    
    // TODO: Implement social login
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$provider login coming soon!'),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _navigateToRegister() {
    // Add haptic feedback
    HapticFeedback.selectionClick();
    
    Navigator.of(context).pushNamed('/register');
  }
}