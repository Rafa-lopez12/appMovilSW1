// lib/presentation/pages/virtual_tryon/virtual_tryon_page.dart - VERSIÓN CORREGIDA
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prueba/presentation/pages/virtual_tryon/processing_page.dart';
import 'dart:io';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../widgets/common/custom_button.dart';
import '../../providers/virtual_tryon_provider.dart';
import 'tryon_camera_page.dart';

class VirtualTryonPage extends StatefulWidget {
  final String? productId;
  final String? productImageUrl;
  final String? productCategory;

  const VirtualTryonPage({
    Key? key,
    this.productId,
    this.productImageUrl,
    this.productCategory,
  }) : super(key: key);

  @override
  State<VirtualTryonPage> createState() => _VirtualTryonPageState();
}

class _VirtualTryonPageState extends State<VirtualTryonPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  
  @override
  bool get wantKeepAlive => true;

  final ScrollController _scrollController = ScrollController();
  late AnimationController _headerAnimationController;
  late AnimationController _floatingButtonController;
  
  bool _showAppBarShadow = false;
  File? _userImage;
  String? _selectedProductImageUrl;
  String? _selectedCategory;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _floatingButtonController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Initialize with product if provided
    if (widget.productImageUrl != null) {
      _selectedProductImageUrl = widget.productImageUrl;
    }
    if (widget.productCategory != null) {
      _selectedCategory = widget.productCategory;
      debugPrint('🏷️ Categoría recibida desde producto: ${widget.productCategory}');
    } else if (widget.productImageUrl != null) {
      _selectedCategory = _detectCategoryFromUrl(widget.productImageUrl!);
      debugPrint('🏷️ Categoría detectada desde URL: $_selectedCategory');
    }
    
    // Start animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _headerAnimationController.forward();
      _floatingButtonController.forward();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _headerAnimationController.dispose();
    _floatingButtonController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final showShadow = _scrollController.offset > 0;
    if (showShadow != _showAppBarShadow) {
      setState(() {
        _showAppBarShadow = showShadow;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildHeader(),
                _buildSetupSection(),
                _buildHowItWorks(),
                _buildTips(),
                const SizedBox(height: 100), // Space for floating button
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      pinned: true,
      elevation: _showAppBarShadow ? 4 : 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      toolbarHeight: 60,
      automaticallyImplyLeading: false,
      title: FadeInDown(
        duration: const Duration(milliseconds: 600),
        child: Row(
          children: [
            Icon(
              IconlyBold.user_2,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              AppStrings.virtualTryOn,
              style: TextStyle(
                fontSize: ResponsiveUtils.getFontSize(context, FontSizeType.title),
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
      actions: [
        FadeInDown(
          duration: const Duration(milliseconds: 1000),
          child: IconButton(
            onPressed: _showHelpDialog,
            icon: Icon(
              IconlyLight.info_circle,
              color: AppColors.textSecondary,
              size: 24,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeader() {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getHorizontalPadding(context),
          vertical: 24,
        ),
        child: Column(
          children: [
            // Main title with gradient
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.secondary,
                    AppColors.accent,
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    IconlyBold.user_2,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Probador Virtual con IA',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getFontSize(context, FontSizeType.headline),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Description
            Text(
              AppStrings.virtualTryOnDescription,
              style: TextStyle(
                fontSize: ResponsiveUtils.getFontSize(context, FontSizeType.body),
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetupSection() {
    return FadeInUp(
      duration: const Duration(milliseconds: 1000),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getHorizontalPadding(context),
        ),
        child: Column(
          children: [
            // Setup steps
            Row(
              children: [
                Expanded(
                  child: _buildSetupStep(
                    stepNumber: 1,
                    title: 'Tu foto',
                    subtitle: _userImage != null ? 'Listo ✓' : 'Sube tu foto',
                    icon: IconlyLight.profile,
                    isCompleted: _userImage != null,
                    onTap: _selectUserImage,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: _buildSetupStep(
                    stepNumber: 2,
                    title: 'Prenda',
                    subtitle: _selectedProductImageUrl != null ? 'Seleccionada ✓' : 'Elige prenda',
                    icon: IconlyLight.bag,
                    isCompleted: _selectedProductImageUrl != null,
                    onTap: _selectProduct,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Start try-on button
            Consumer<VirtualTryonProvider>(
              builder: (context, tryonProvider, child) {
                final canStartTryon = _userImage != null && _selectedProductImageUrl != null;
                print(tryonProvider.isCreatingSession);
                return CustomButton(
                  text: tryonProvider.isCreatingSession 
                      ? 'Creando try-on...' 
                      : 'Comenzar probador virtual',
                  onPressed: canStartTryon && !tryonProvider.isCreatingSession
                      ? _startVirtualTryon
                      : null,
                  isLoading: tryonProvider.isCreatingSession,
                  icon: IconlyLight.play,
                  size: ButtonSize.large,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetupStep({
    required int stepNumber,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isCompleted,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted ? AppColors.success : AppColors.border,
            width: isCompleted ? 2 : 1,
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
          children: [
            // Step number and icon
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: isCompleted ? AppColors.success : AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          )
                        : Text(
                            '$stepNumber',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const Spacer(),
                Icon(
                  icon,
                  size: 24,
                  color: isCompleted ? AppColors.success : AppColors.textSecondary,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Title and subtitle
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isCompleted ? AppColors.success : AppColors.textSecondary,
                    fontWeight: isCompleted ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorks() {
    return FadeInUp(
      duration: const Duration(milliseconds: 1400),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getHorizontalPadding(context),
          vertical: 32,
        ),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.05),
              AppColors.secondary.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  IconlyBold.play,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Cómo funciona',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            ...[
              '1. 📸 Sube una foto tuya de cuerpo completo',
              '2. 👕 Selecciona la prenda que quieres probar',
              '3. 🤖 Nuestra IA procesa las imágenes',
              '4. ✨ Ve cómo te queda la prenda virtualmente',
              '5. 💾 Guarda y comparte tus resultados',
            ].map((step) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                step,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTips() {
    return FadeInUp(
      duration: const Duration(milliseconds: 1600),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getHorizontalPadding(context),
          vertical: 16,
        ),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.accent.withOpacity(0.1),
              AppColors.secondary.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.accent.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  IconlyBold.info_circle,
                  color: AppColors.accent,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Consejos para mejores resultados',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            ...[
              '📏 Usa fotos de cuerpo completo con buena postura',
              '💡 Asegúrate de tener buena iluminación',
              '👤 Evita ropa muy holgada o arrugada',
              '📱 Mantén el teléfono vertical al tomar la foto',
              '🖼️ Usa fondos simples y uniformes',
            ].map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                tip,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Consumer<VirtualTryonProvider>(
      builder: (context, tryonProvider, child) {
        return ScaleTransition(
          scale: _floatingButtonController,
          child: FloatingActionButton.extended(
            onPressed: tryonProvider.isCreatingSession ? null : _quickTryon,
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            elevation: 8,
            icon: Icon(
              IconlyBold.camera,
              size: 24,
            ),
            label: Text(
              'Try-on rápido',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  // Event handlers
  // ⭐ MÉTODO PRINCIPAL CORREGIDO ⭐
  Future<void> _selectUserImage() async {
    try {
      debugPrint('🔄 Iniciando selección de imagen de usuario...');
      
      // 🔥 MÉTODO SIMPLE Y DIRECTO - SIN BOTTOM SHEET COMPLEJO
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        debugPrint('✅ Imagen seleccionada: ${image.path}');
        setState(() {
          _userImage = File(image.path);
        });
        
        HapticFeedback.lightImpact();
        _showSuccessSnackBar('Foto de usuario seleccionada');
      } else {
        debugPrint('❌ Selección de imagen cancelada');
      }
    } catch (e) {
      debugPrint('💥 Error al seleccionar imagen: $e');
      _showErrorSnackBar('Error al seleccionar imagen: $e');
    }
  }

  Future<void> _selectProduct() async {
    // Navigate to product selection or use current product
    if (widget.productId != null) {
      // Already have a product selected
      return;
    }
    
    // TODO: Navigate to product catalog for selection
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selección de productos próximamente'),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _quickTryon() async {
    HapticFeedback.mediumImpact();
    
    // Navigate directly to camera page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TryonCameraPage(
          productId: widget.productId,
          productImageUrl: widget.productImageUrl,
        ),
      ),
    );
  }

Future<void> _startVirtualTryon() async {
  if (_userImage == null || _selectedProductImageUrl == null) {
    _showErrorSnackBar('Se requieren ambas imágenes para el try-on');
    return;
  }
  
  try {
    debugPrint('🚀 Iniciando Virtual Try-On - CREANDO SESIÓN');
    
    // 🔥 USAR CATEGORÍA YA DETECTADA O DETECTAR DESDE URL
    String detectedCategory = _selectedCategory ?? 'upper_body';
    print('ESTA ES LA CATEGORIA: $detectedCategory');
    // Solo detectar desde URL si no tenemos categoría
    if (_selectedCategory == null && _selectedProductImageUrl != null) {
      final urlLower = _selectedProductImageUrl!.toLowerCase();
      debugPrint('🔍 Detectando categoría desde URL: $urlLower');
      
      if (urlLower.contains('jeans') || urlLower.contains('pantalon') || 
          urlLower.contains('pants') || urlLower.contains('trouser')) {
        detectedCategory = 'lower_body';
      } else if (urlLower.contains('vestido') || urlLower.contains('dress')) {
        detectedCategory = 'dresses';
      } else {
        detectedCategory = 'upper_body';
      }
    }

    debugPrint('🏷️ Categoría final para try-on: $detectedCategory');

    final tryonProvider = Provider.of<VirtualTryonProvider>(context, listen: false);
    
    dynamic session;
    
    if (_selectedProductImageUrl != null) {
      session = await tryonProvider.createTryonWithUserImage(
        userImage: _userImage!,
        garmentImageUrl: _selectedProductImageUrl!,
        productoId: widget.productId,
        category: detectedCategory, // 🔥 ENVIAR CATEGORY CORRECTA
        metadata: {
          'detectedCategory': detectedCategory,
          'productImageUrl': _selectedProductImageUrl,
          'source': 'virtual_tryon_page',
          'originalProductCategory': widget.productCategory, // Info adicional
        },
      );
    }
    
    if (session == null) {
      _showErrorSnackBar('No se pudo crear la sesión de try-on');
      return;
    }
    
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (context) => ProcessingPage(
          sessionId: session.id,
          initialSession: session,
        ),
      ),
    );
    
    if (result != null && result.status == 'completed') {
      debugPrint('✅ Try-on completado exitosamente');
      _showSuccessSnackBar('Try-on completado exitosamente');
    } else if (result != null && result.status == 'failed') {
      debugPrint('❌ Try-on falló: ${result.errorMessage}');
      _showErrorSnackBar('Try-on falló: ${result.errorMessage ?? "Error desconocido"}');
    }
    
  } catch (e) {
    debugPrint('💥 Error en _startVirtualTryon: $e');
    _showErrorSnackBar('Error iniciando try-on: $e');
  }
}

  String _detectCategoryFromUrl(String imageUrl) {
    final urlLower = imageUrl.toLowerCase();
    print('ES LA CATEGORIA: $urlLower');
    if (urlLower.contains('jeans') || urlLower.contains('pantalon') || 
        urlLower.contains('pants') || urlLower.contains('trouser')) {
      return 'lower_body';
    } else if (urlLower.contains('vestido') || urlLower.contains('dress')) {
      return 'dresses';
    }
    
    return 'upper_body'; // Default
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              IconlyBold.info_circle,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text('Acerca del Probador Virtual'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'El probador virtual usa inteligencia artificial para mostrar cómo te quedaría la ropa antes de comprarla.',
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tecnología:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '• IA de generación de imágenes\n• Análisis de pose y anatomía\n• Simulación realista de textiles\n• Procesamiento en la nube',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Entendido',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}