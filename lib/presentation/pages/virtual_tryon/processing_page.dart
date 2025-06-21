// lib/presentation/pages/virtual_tryon/processing_page.dart - VERSIÓN COMPLETAMENTE CORREGIDA
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/virtual_tryon/processing_indicator.dart';
import '../../providers/virtual_tryon_provider.dart';
import 'tryon_result_page.dart';

// 🔧 CLASE ACTUALIZADA CON NUEVOS PARÁMETROS
class ProcessingPage extends StatefulWidget {
  final String sessionId;        // ✅ Solo necesitamos el session ID
  final dynamic initialSession; // ✅ Sesión inicial (opcional)

  const ProcessingPage({
    Key? key,
    required this.sessionId,
    this.initialSession,
  }) : super(key: key);

  @override
  State<ProcessingPage> createState() => _ProcessingPageState();
}

class _ProcessingPageState extends State<ProcessingPage>
    with TickerProviderStateMixin {
  
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  
  // Estados del procesamiento
  double _progress = 0.0;
  String _currentStatus = 'Verificando estado de la sesión...';
  bool _hasError = false;
  String? _errorMessage;
  dynamic _sessionResult;
  
  // Control de polling
  bool _isPolling = false;
  int _pollAttempts = 0;
  static const int _maxPollAttempts = 120; // 10 minutos con intervalos de 5s

  @override
  void initState() {
    super.initState();
    
    debugPrint('🎬 ProcessingPage iniciado para sesión: ${widget.sessionId}');
    debugPrint('📋 Sesión inicial: ${widget.initialSession?.status}');
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    // 🔥 INICIALIZAR CON LA SESIÓN EXISTENTE
    if (widget.initialSession != null) {
      _sessionResult = widget.initialSession;
      _updateStatusFromSession(widget.initialSession);
    }
    
    // 🔥 COMENZAR POLLING INMEDIATAMENTE - NO _startProcessing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startPollingSessionStatus();
    });
  }

  @override
  void dispose() {
    debugPrint('🧹 Disposing ProcessingPage...');
    _rotationController.dispose();
    _pulseController.dispose();
    _isPolling = false;
    super.dispose();
  }

  // 🔥 ELIMINAR COMPLETAMENTE EL MÉTODO _startProcessing
  // Ya no es necesario porque la sesión ya fue creada en VirtualTryonPage

  // 🔥 MÉTODO PRINCIPAL - SOLO POLLING
  Future<void> _startPollingSessionStatus() async {
    if (!mounted) return;
    
    setState(() {
      _currentStatus = 'Iniciando verificación de estado...';
      _progress = 0.1;
    });
    
    _isPolling = true;
    _pollAttempts = 0;
    
    final tryonProvider = Provider.of<VirtualTryonProvider>(context, listen: false);
    
    debugPrint('🔄 Iniciando polling para sesión: ${widget.sessionId}');
    
    try {
      // 🔥 Si ya tenemos una sesión inicial, verificar su estado
      if (widget.initialSession != null) {
        debugPrint('📋 Verificando sesión inicial: ${widget.initialSession.status}');
        
        if (widget.initialSession.status == 'completed') {
          debugPrint('✅ Sesión ya completada al iniciar');
          await _onProcessingCompleted(widget.initialSession);
          return;
        } else if (widget.initialSession.status == 'failed') {
          debugPrint('❌ Sesión ya falló al iniciar');
          _handleSessionFailed(widget.initialSession);
          return;
        }
        
        // Si está pending o processing, continuar con polling
        setState(() {
          _currentStatus = 'Sesión encontrada. Monitoreando progreso...';
          _progress = 0.2;
        });
      }
      
      // 🔥 LOOP DE POLLING
      while (_isPolling && _pollAttempts < _maxPollAttempts && mounted) {
        try {
          debugPrint('📡 Poll attempt ${_pollAttempts + 1}/$_maxPollAttempts');
          
          // 🔥 VERIFICAR ESTADO DE LA SESIÓN
          final session = await tryonProvider.getSessionStatus(widget.sessionId);
          
          if (session == null) {
            debugPrint('⚠️ Sesión no encontrada en attempt ${_pollAttempts + 1}');
            _pollAttempts++;
            
            if (_pollAttempts >= 3) {
              // Después de 3 intentos sin encontrar la sesión, es un error
              throw Exception('Sesión no encontrada después de múltiples intentos');
            }
            
            await Future.delayed(const Duration(seconds: 5));
            continue;
          }
          
          debugPrint('📊 Estado actual: ${session.status}');
          
          if (!mounted) return;
          
          setState(() {
            _sessionResult = session;
            _updateStatusFromSession(session);
          });
          
          // 🔥 VERIFICAR SI TERMINÓ
          if (session.status == 'completed') {
            debugPrint('✅ Procesamiento completado');
            _isPolling = false;
            await _onProcessingCompleted(session);
            return;
          } else if (session.status == 'failed') {
            debugPrint('❌ Procesamiento falló: ${session.errorMessage}');
            _isPolling = false;
            _handleSessionFailed(session);
            return;
          }
          
          _pollAttempts++;
          
          // Esperar antes del siguiente poll
          if (_isPolling && mounted) {
            await Future.delayed(const Duration(seconds: 5));
          }
          
        } catch (pollError) {
          debugPrint('💥 Error en polling attempt ${_pollAttempts + 1}: $pollError');
          _pollAttempts++;
          
          if (_pollAttempts >= _maxPollAttempts) {
            throw Exception('Timeout: El procesamiento tomó demasiado tiempo');
          }
          
          if (mounted) {
            await Future.delayed(const Duration(seconds: 5));
          }
        }
      }
      
      // Si llegamos aquí, fue por timeout
      if (_pollAttempts >= _maxPollAttempts) {
        throw Exception('Timeout: El procesamiento tomó demasiado tiempo');
      }
      
    } catch (error, stackTrace) {
      debugPrint('💥 Error en polling general: $error');
      debugPrint('📍 Stack trace: $stackTrace');
      
      if (!mounted) return;
      
      setState(() {
        _hasError = true;
        _errorMessage = error.toString();
        _currentStatus = 'Error verificando estado';
        _isPolling = false;
      });
      
      HapticFeedback.heavyImpact();
    }
  }

  // 🔥 Manejar sesión fallida
  void _handleSessionFailed(dynamic session) {
    if (!mounted) return;
    
    setState(() {
      _hasError = true;
      _errorMessage = session.errorMessage ?? 'El procesamiento falló';
      _currentStatus = 'Try-on falló';
      _progress = 0.0;
    });
    
    HapticFeedback.heavyImpact();
  }

  // 🔥 Actualizar estado basado en respuesta real de la API
  void _updateStatusFromSession(dynamic session) {
    if (!mounted) return;
    
    switch (session.status) {
      case 'pending':
        _currentStatus = 'En cola de procesamiento...';
        _progress = 0.3;
        break;
      case 'processing':
        _currentStatus = 'Procesando try-on virtual...';
        // Calcular progreso basado en tiempo o intentos
        final baseProgress = 0.4;
        final progressIncrement = (_pollAttempts / _maxPollAttempts) * 0.5;
        _progress = (baseProgress + progressIncrement).clamp(0.4, 0.9);
        break;
      case 'completed':
        _currentStatus = 'Try-on completado exitosamente';
        _progress = 1.0;
        break;
      case 'failed':
        _currentStatus = 'Error en el procesamiento';
        _hasError = true;
        _errorMessage = session.errorMessage ?? 'Error desconocido';
        _progress = 0.0;
        break;
      default:
        _currentStatus = 'Estado desconocido: ${session.status}';
        _progress = 0.2;
    }
  }

  // 🔥 Cuando el procesamiento está completo
  Future<void> _onProcessingCompleted(dynamic session) async {
    if (!mounted) return;
    
    debugPrint('🎉 Procesamiento completado, preparando navegación...');
    
    setState(() {
      _currentStatus = 'Try-on completado';
      _progress = 1.0;
    });
    
    // Esperar para mostrar finalización
    await Future.delayed(const Duration(seconds: 1));
    
    if (!mounted) return;
    
    try {
      debugPrint('🚀 Navegando a TryonResultPage...');
      
      // 🔥 NAVEGAR AL RESULTADO
      final result = await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TryonResultPage(session: session),
        ),
      );
      
      debugPrint('🔙 Retornó de TryonResultPage: $result');
      
      // 🔥 RETORNAR RESULTADO A VirtualTryonPage
      if (mounted) {
        Navigator.of(context).pop(result ?? session);
      }
      
    } catch (error) {
      debugPrint('💥 Error navegando a resultado: $error');
      if (mounted) {
        Navigator.of(context).pop({'error': 'Error mostrando resultado'});
      }
    }
  }

  // 🔥 Método para reintentar (cuando hay error)
  void _retryPolling() {
    setState(() {
      _hasError = false;
      _errorMessage = null;
      _progress = 0.0;
      _currentStatus = 'Reintentando verificación...';
      _isPolling = false;
      _pollAttempts = 0;
    });
    
    _startPollingSessionStatus();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_hasError || _sessionResult?.status == 'completed') {
          return true;
        }
        
        final shouldPop = await _showCancelDialog();
        if (shouldPop == true) {
          _isPolling = false;
        }
        return shouldPop ?? false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            _buildAnimatedBackground(),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.getHorizontalPadding(context),
                  vertical: 24,
                ),
                child: Column(
                  children: [
                    _buildTopControls(),
                    Expanded(
                      child: _hasError 
                          ? _buildErrorState()
                          : _sessionResult?.status == 'completed'
                              ? _buildSuccessState()
                              : _buildProcessingState(),
                    ),
                    _buildBottomControls(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: SweepGradient(
              center: Alignment.center,
              startAngle: _rotationController.value * 2 * pi,
              colors: [
                Colors.black,
                AppColors.primary.withOpacity(0.1),
                AppColors.secondary.withOpacity(0.1),
                AppColors.accent.withOpacity(0.1),
                Colors.black,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopControls() {
    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Row(
        children: [
          if (_hasError || _sessionResult?.status == 'completed')
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
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
            )
          else
            const SizedBox(width: 40),
          
          const Spacer(),
          
          Text(
            'Procesando Try-On',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const Spacer(),
          
          GestureDetector(
            onTap: _showProcessingInfo,
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
    );
  }

  Widget _buildProcessingState() {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Processing animation
          ScaleTransition(
            scale: Tween(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
            ),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.3),
                    AppColors.secondary.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Center(
                child: ProcessingIndicator(
                  progress: _progress,
                  size: 80,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Progress percentage
          Text(
            '${(_progress * 100).toInt()}%',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Current status
          Text(
            _currentStatus,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // Session info
          if (_isPolling)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                  Text(
                    'Session ID: ${widget.sessionId.substring(0, 8)}...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Verificando estado: ${_pollAttempts}/${_maxPollAttempts}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              IconlyBold.danger,
              size: 48,
              color: AppColors.error,
            ),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Error en el procesamiento',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.error.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              _errorMessage ?? 'Ocurrió un error desconocido',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 32),
          
          CustomButton(
            text: 'Reintentar',
            onPressed: _retryPolling,
            icon: IconlyLight.delete,
            type: ButtonType.outline,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              IconlyBold.tick_square,
              size: 48,
              color: AppColors.success,
            ),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            '¡Try-on completado!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Tu try-on virtual está listo. Serás redirigido automáticamente a ver el resultado.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    if (_hasError) {
      return FadeInUp(
        duration: const Duration(milliseconds: 1000),
        child: Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Volver',
                onPressed: () => Navigator.of(context).pop(),
                type: ButtonType.outline,
                icon: IconlyLight.arrow_left,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomButton(
                text: 'Contactar soporte',
                onPressed: _contactSupport,
                icon: IconlyLight.chat,
              ),
            ),
          ],
        ),
      );
    }
    
    return FadeInUp(
      duration: const Duration(milliseconds: 1000),
      child: Text(
        'El procesamiento puede tomar hasta 2 minutos.\nPor favor mantén la app abierta.',
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 14,
          height: 1.4,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Helper methods
  Future<bool?> _showCancelDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text('Cancelar procesamiento'),
        content: Text(
          '¿Estás seguro de que quieres cancelar el try-on? El progreso actual se perderá.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Continuar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showProcessingInfo() {
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
            Text('Procesamiento de Try-On'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'El procesamiento de tu try-on virtual incluye:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            ...[
              '🧠 Análisis de IA de tu pose corporal',
              '👕 Mapeo 3D de la prenda seleccionada',
              '✨ Simulación realista de textiles',
              '🎨 Ajuste de iluminación y sombras',
              '🔄 Optimización de calidad final',
            ].map((step) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                step,
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

  void _contactSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Función de soporte próximamente'),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}