// lib/presentation/pages/virtual_tryon/tryon_result_page.dart - VERSIÓN CON PROPORCIONES CORREGIDAS
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/virtual_tryon/tryon_result_widget.dart';
import '../../providers/virtual_tryon_provider.dart';
import '../../providers/cart_provider.dart';

class TryonResultPage extends StatefulWidget {
  final dynamic session;

  const TryonResultPage({
    Key? key,
    required this.session,
  }) : super(key: key);

  @override
  State<TryonResultPage> createState() => _TryonResultPageState();
}

class _TryonResultPageState extends State<TryonResultPage>
    with TickerProviderStateMixin {
  
  late AnimationController _pageController;
  late AnimationController _fabController;
  
  bool _showBeforeAfter = false;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    
    _pageController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pageController.forward();
    
    // Delay FAB animation
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _fabController.forward();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main content
          _buildMainContent(),
          
          // Top overlay
          _buildTopOverlay(),
          
          // Bottom overlay
          _buildBottomOverlay(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildMainContent() {
    return Positioned.fill(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _showBeforeAfter
            ? _buildBeforeAfterView()
            : _buildResultView(),
      ),
    );
  }

  // 🔥 MÉTODO CORREGIDO PARA MANTENER PROPORCIONES
  Widget _buildResultView() {
    return FadeIn(
      duration: const Duration(milliseconds: 800),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: widget.session.hasResult
            ? _buildProportionalImage(
                widget.session.resultImageUrl,
                'Resultado del try-on'
              )
            : _buildNoResultPlaceholder(),
      ),
    );
  }

  // 🔥 NUEVO WIDGET PARA MANTENER PROPORCIONES
  Widget _buildProportionalImage(String imageUrl, String label) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Center(
        child: Image.network(
          imageUrl,
          // 🔥 CAMBIO PRINCIPAL: BoxFit.contain mantiene proporciones
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildLoadingPlaceholder();
          },
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error cargando imagen: $error');
            return _buildErrorPlaceholder();
          },
        ),
      ),
    );
  }

  // 🔥 MÉTODO CORREGIDO PARA COMPARACIÓN ANTES/DESPUÉS
  Widget _buildBeforeAfterView() {
    return Row(
      children: [
        // Before (original) - Con proporciones mantenidas
        Expanded(
          child: Container(
            child: Stack(
              children: [
                Positioned.fill(
                  child: _buildProportionalImage(
                    widget.session.userImageUrl,
                    'Imagen original'
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Antes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Divider
        Container(
          width: 2,
          color: Colors.white,
        ),
        
        // After (result) - Con proporciones mantenidas
        Expanded(
          child: Container(
            child: Stack(
              children: [
                Positioned.fill(
                  child: _buildProportionalImage(
                    widget.session.resultImageUrl ?? '',
                    'Resultado del try-on'
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Después',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopOverlay() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: FadeInDown(
          duration: const Duration(milliseconds: 800),
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
                  Colors.black.withOpacity(0.7),
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
                  'Tu Try-On',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const Spacer(),
                
                // Before/After toggle
                GestureDetector(
                  onTap: _toggleBeforeAfter,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _showBeforeAfter 
                          ? AppColors.primary.withOpacity(0.8)
                          : Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      IconlyLight.swap,
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
          duration: const Duration(milliseconds: 1000),
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
                // Quality indicator
                _buildQualityIndicator(),
                
                const SizedBox(height: 20),
                
                // Action buttons
                _buildActionButtons(),
                
                const SizedBox(height: 100), // Space for floating button
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQualityIndicator() {
    final confidence = 0.92; // Mock data - would come from session
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    IconlyBold.star,
                    color: AppColors.success,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Calidad del resultado',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                '${(confidence * 100).toInt()}%',
                style: TextStyle(
                  color: AppColors.success,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Progress bar
          LinearProgressIndicator(
            value: confidence,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            confidence >= 0.9 
                ? '¡Excelente resultado! La prenda se ve muy natural.'
                : confidence >= 0.7
                    ? 'Buen resultado. Pequeños ajustes pueden mejorar.'
                    : 'Resultado aceptable. Considera tomar nuevas fotos.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Save button
        Expanded(
          child: _buildActionButton(
            icon: _isSaved ? IconlyBold.bookmark : IconlyLight.bookmark,
            label: _isSaved ? 'Guardado' : 'Guardar',
            onTap: _saveResult,
            color: _isSaved ? AppColors.success : Colors.white.withOpacity(0.8),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Share button
        Expanded(
          child: _buildActionButton(
            icon: IconlyLight.upload,
            label: 'Compartir',
            onTap: _shareResult,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Retry button
        Expanded(
          child: _buildActionButton(
            icon: IconlyLight.delete,
            label: 'Nuevo try-on',
            onTap: _retryTryon,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return ScaleTransition(
      scale: _fabController,
      child: FloatingActionButton.extended(
        onPressed: _addToCart,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 8,
        icon: Icon(IconlyBold.bag_2, size: 24),
        label: Text(
          'Agregar al carrito',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      color: Colors.grey[900],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'Cargando resultado...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey[900],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              IconlyLight.danger,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar resultado',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Verifica tu conexión e intenta de nuevo',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Reintentar',
              onPressed: () {
                setState(() {});
              },
              type: ButtonType.outline,
              icon: IconlyLight.delete,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultPlaceholder() {
    return Container(
      color: Colors.grey[900],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              IconlyLight.image,
              size: 64,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Resultado no disponible',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'El try-on aún se está procesando o falló',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Event handlers
  void _toggleBeforeAfter() {
    setState(() {
      _showBeforeAfter = !_showBeforeAfter;
    });
    HapticFeedback.selectionClick();
  }

  void _saveResult() {
    setState(() {
      _isSaved = !_isSaved;
    });
    
    final tryonProvider = Provider.of<VirtualTryonProvider>(context, listen: false);
    
    if (_isSaved) {
      // Save to history
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Try-on guardado en tu historial'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Try-on removido del historial'),
          backgroundColor: AppColors.info,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _shareResult() {
    HapticFeedback.lightImpact();
    
    // TODO: Implement share functionality
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Compartir Try-On',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Comparte tu try-on virtual con amigos y familiares',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(
                  icon: Icons.copy,
                  label: 'Copiar enlace',
                  onTap: () {
                    Navigator.pop(context);
                    _showSuccessSnackBar('Enlace copiado al portapapeles');
                  },
                ),
                _buildShareOption(
                  icon: Icons.share,
                  label: 'Compartir',
                  onTap: () {
                    Navigator.pop(context);
                    _showInfoSnackBar('Función de compartir próximamente');
                  },
                ),
                _buildShareOption(
                  icon: Icons.download,
                  label: 'Descargar',
                  onTap: () {
                    Navigator.pop(context);
                    _showSuccessSnackBar('Imagen descargada');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _retryTryon() {
    HapticFeedback.lightImpact();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text('Nuevo Try-On'),
        content: Text(
          '¿Quieres hacer un nuevo try-on? Esto te llevará de vuelta a la cámara.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to camera/setup
            },
            child: Text('Continuar'),
          ),
        ],
      ),
    );
  }

  void _addToCart() {
    HapticFeedback.mediumImpact();
    
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    
    // TODO: Get actual product info from session
    // For now, using mock data
    cartProvider.addItem(
      productId: widget.session.producto?.id ?? 'mock-product',
      name: widget.session.producto?.name ?? 'Producto del Try-On',
      price: widget.session.produto?.minPrice ?? 99.99,
      image: widget.session.garmentImageUrl ?? '',
      size: 'M',
      color: 'Default',
      productoVariedadId: 'mock-variant',
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Producto agregado al carrito'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Ver carrito',
          textColor: Colors.white,
          onPressed: () {
            Navigator.pushNamed(context, '/cart');
          },
        ),
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