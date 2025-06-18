
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/virtual_tryon/tryon_camera_widget.dart';
import '../../providers/virtual_tryon_provider.dart';
import 'processing_page.dart';

class TryonCameraPage extends StatefulWidget {
  final String? productId;
  final String? productImageUrl;

  const TryonCameraPage({
    Key? key,
    this.productId,
    this.productImageUrl,
  }) : super(key: key);

  @override
  State<TryonCameraPage> createState() => _TryonCameraPageState();
}

class _TryonCameraPageState extends State<TryonCameraPage>
    with TickerProviderStateMixin {
  
  late AnimationController _animationController;
  late AnimationController _pulseController;
  
  File? _userImage;
  File? _garmentImage;
  final ImagePicker _imagePicker = ImagePicker();
  int _currentStep = 0; // 0: user photo, 1: garment photo, 2: ready

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _animationController.forward();
    _pulseController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main camera interface
          _buildCameraInterface(),
          
          // Top overlay with controls
          _buildTopOverlay(),
          
          // Bottom overlay with actions
          _buildBottomOverlay(),
          
          // Step indicator
          _buildStepIndicator(),
        ],
      ),
    );
  }

  Widget _buildCameraInterface() {
    return TryonCameraWidget(
      onCapture: _captureImage,
      onGallerySelect: _selectFromGallery,
      currentStep: _currentStep,
      userImage: _userImage,
      garmentImage: _garmentImage,
    );
  }

  Widget _buildTopOverlay() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: FadeInDown(
          duration: const Duration(milliseconds: 600),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.getHorizontalPadding(context),
              vertical: 16,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              children: [
                // Back button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      IconlyLight.arrow_left,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Title
                Text(
                  _getStepTitle(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const Spacer(),
                
                // Help button
                GestureDetector(
                  onTap: _showHelpDialog,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      IconlyLight.info_circle,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: FadeInUp(
          duration: const Duration(milliseconds: 600),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.getHorizontalPadding(context),
              vertical: 24,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Instruction text
                Text(
                  _getStepInstruction(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 24),
                
                // Action buttons
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Positioned(
      top: 120,
      left: 0,
      right: 0,
      child: FadeInDown(
        duration: const Duration(milliseconds: 800),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final isActive = index <= _currentStep;
            final isCompleted = index < _currentStep;
            
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.success
                          : isActive
                              ? AppColors.primary
                              : Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
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
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  if (index < 2)
                    Container(
                      width: 24,
                      height: 2,
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      color: index < _currentStep
                          ? AppColors.success
                          : Colors.white.withOpacity(0.3),
                    ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_currentStep == 2) {
      // Ready to start try-on
      return Column(
        children: [
          Row(
            children: [
              // Retake photos
              Expanded(
                child: CustomButton(
                  text: 'Cambiar fotos',
                  onPressed: _resetPhotos,
                  type: ButtonType.outline,
                  icon: IconlyLight.camera,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Start try-on
              Expanded(
                flex: 2,
                child: Consumer<VirtualTryonProvider>(
                  builder: (context, tryonProvider, child) {
                    return CustomButton(
                      text: tryonProvider.isCreatingSession 
                          ? 'Iniciando...' 
                          : 'Comenzar try-on',
                      onPressed: !tryonProvider.isCreatingSession
                          ? _startTryon
                          : null,
                      isLoading: tryonProvider.isCreatingSession,
                      icon: IconlyLight.play,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      );
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Gallery button
        _buildCameraButton(
          icon: IconlyLight.image,
          label: 'Galería',
          onTap: _selectFromGallery,
        ),
        
        // Capture button
        ScaleTransition(
          scale: Tween(begin: 1.0, end: 1.1).animate(
            CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
          ),
          child: _buildCameraButton(
            icon: IconlyBold.camera,
            label: 'Capturar',
            onTap: _captureImage,
            isPrimary: true,
            size: 80,
          ),
        ),
        
        // Switch camera button (placeholder)
        _buildCameraButton(
          icon: IconlyLight.swap,
          label: 'Cambiar',
          onTap: _switchCamera,
        ),
      ],
    );
  }

  Widget _buildCameraButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
    double size = 60,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: isPrimary 
                  ? AppColors.primary 
                  : Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: isPrimary ? 32 : 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Toma tu foto';
      case 1:
        return 'Foto de la prenda';
      case 2:
        return 'Listo para probar';
      default:
        return 'Probador Virtual';
    }
  }

  String _getStepInstruction() {
    switch (_currentStep) {
      case 0:
        return 'Colócate de frente a la cámara con buena iluminación.\nAsegúrate de que tu cuerpo completo sea visible.';
      case 1:
        return widget.productImageUrl != null
            ? 'Foto de producto seleccionada automáticamente.\nToca "Siguiente" para continuar.'
            : 'Toma una foto clara de la prenda que quieres probar.\nAsegúrate de que esté bien visible y sin arrugas.';
      case 2:
        return 'Perfecto! Tienes ambas fotos listas.\nAhora podemos comenzar el try-on virtual.';
      default:
        return '';
    }
  }

  Future<void> _captureImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        _processImage(File(image.path));
      }
    } catch (e) {
      _showErrorSnackBar('Error al capturar imagen: $e');
    }
  }

  Future<void> _selectFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        _processImage(File(image.path));
      }
    } catch (e) {
      _showErrorSnackBar('Error al seleccionar imagen: $e');
    }
  }

  void _processImage(File imageFile) {
    setState(() {
      if (_currentStep == 0) {
        _userImage = imageFile;
        _currentStep = 1;
        
        // If we have a product image URL, skip to step 2
        if (widget.productImageUrl != null) {
          _currentStep = 2;
        }
      } else if (_currentStep == 1) {
        _garmentImage = imageFile;
        _currentStep = 2;
      }
    });
    
    HapticFeedback.lightImpact();
    _showSuccessSnackBar('Imagen capturada correctamente');
  }

  void _resetPhotos() {
    setState(() {
      _userImage = null;
      _garmentImage = null;
      _currentStep = 0;
    });
    
    HapticFeedback.lightImpact();
  }

  void _switchCamera() {
    // TODO: Implement camera switching
    HapticFeedback.lightImpact();
    _showInfoSnackBar('Función de cambio de cámara próximamente');
  }

  Future<void> _startTryon() async {
    if (_userImage == null) {
      _showErrorSnackBar('Se requiere una foto del usuario');
      return;
    }
    
    String? garmentImageUrl = widget.productImageUrl;
    
    if (garmentImageUrl == null && _garmentImage == null) {
      _showErrorSnackBar('Se requiere una imagen de la prenda');
      return;
    }
    
    try {
      // Navigate to processing page
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProcessingPage(
            userImage: _userImage!,
            garmentImageUrl: garmentImageUrl,
            garmentImageFile: _garmentImage,
            productId: widget.productId,
          ),
        ),
      );
      
      // If processing completed successfully, pop this page too
      if (result != null && mounted) {
        Navigator.of(context).pop(result);
      }
    } catch (e) {
      _showErrorSnackBar('Error iniciando try-on: $e');
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
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
            Text('Consejos para mejores fotos'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Para obtener los mejores resultados en tu try-on virtual:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            ...[
              '📏 Mantén una postura natural y relajada',
              '💡 Usa buena iluminación, preferiblemente natural',
              '👤 Asegúrate de que todo tu cuerpo sea visible',
              '📱 Mantén el teléfono vertical y estable',
              '🖼️ Usa un fondo simple y uniforme',
              '👕 Para prendas, asegúrate de que estén bien extendidas',
            ].map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                tip,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
              ),
            )),
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

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}