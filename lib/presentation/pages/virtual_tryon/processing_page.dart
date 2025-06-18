// lib/presentation/pages/virtual_tryon/processing_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:math';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/virtual_tryon/processing_indicator.dart';
import '../../providers/virtual_tryon_provider.dart';
import 'tryon_result_page.dart';

class ProcessingPage extends StatefulWidget {
  final File userImage;
  final String? garmentImageUrl;
  final File? garmentImageFile;
  final String? productId;

  const ProcessingPage({
    Key? key,
    required this.userImage,
    this.garmentImageUrl,
    this.garmentImageFile,
    this.productId,
  }) : super(key: key);

  @override
  State<ProcessingPage> createState() => _ProcessingPageState();
}

class _ProcessingPageState extends State<ProcessingPage>
    with TickerProviderStateMixin {
  
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _progressController;
  
  double _progress = 0.0;
  String _currentStatus = 'Iniciando procesamiento...';
  bool _hasError = false;
  String? _errorMessage;
  dynamic _sessionResult;
  
  final List<String> _processingSteps = [
    'Analizando imagen del usuario...',
    'Procesando imagen de la prenda...',
    'Generando pose 3D...',
    'Aplicando la prenda virtualmente...',
    'Ajustando iluminación y sombras...',
    'Finalizando resultado...',
  ];
  
  int _currentStepIndex = 0;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _progressController = AnimationController(
      duration: const Duration(seconds: 20), // Total processing time
      vsync: this,
    );
    
    _startProcessing();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _startProcessing() async {
    final tryonProvider = Provider.of<VirtualTryonProvider>(context, listen: false);
    
    try {
      // Start progress animation
      _progressController.forward();
      
      // Simulate step-by-step processing
      await _simulateProcessingSteps();
      
      // Actually create the try-on session
      dynamic session;
      
      if (widget.garmentImageUrl != null) {
        // Use URL-based try-on
        session = await tryonProvider.createTryonFromUrls(
          userImageUrl: widget.userImage.path, // This would need to be uploaded first
          garmentImageUrl: widget.garmentImageUrl!,
          productoId: widget.productId,
          metadata: {
            'processing_type': 'url_based',
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
      } else if (widget.garmentImageFile != null) {
        // Use file-based try-on
        session = await tryonProvider.uploadAndCreateTryon(
          userImage: widget.userImage,
          garmentImage: widget.garmentImageFile!,
          productoId: widget.productId,
          metadata: {
            'processing_type': 'file_based',
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
      }
      
      if (session != null) {
        setState(() {
          _sessionResult = session;
          _progress = 1.0;
          _currentStatus = AppStrings.tryOnComplete;
        });
        
        // Wait a moment to show completion
        await Future.delayed(const Duration(seconds: 1));
        
        // Navigate to result page
        if (mounted) {
          final result = await Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TryonResultPage(session: session),
            ),
          );
          
          // Return result to previous page
          if (mounted) {
            Navigator.of(context).pop(result);
          }
        }
      } else {
        throw Exception('No se pudo crear la sesión de try-on');
      }
    } catch (error) {
      setState(() {
        _hasError = true;
        _errorMessage = error.toString();
        _currentStatus = AppStrings.tryOnFailed;
      });
      
      HapticFeedback.notificationFeedback(NotificationFeedbackType.error);
    }
  }

  Future<void> _simulateProcessingSteps() async {
    for (int i = 0; i < _processingSteps.length; i++) {
      if (!mounted) return;
      
      setState(() {
        _currentStepIndex = i;
        _currentStatus = _processingSteps[i];
        _progress = (i + 1) / _processingSteps.length * 0.8; // 80% for simulation
      });
      
      // Random delay between steps to simulate real processing
      final delay = Duration(milliseconds: 1500 + Random().nextInt(2000));
      await Future.delayed(delay);
      
      // Add haptic feedback for each step
      HapticFeedback.selectionClick();
    }
    
    setState(() {
      _currentStatus = 'Generando resultado final...';
      _progress = 0.9;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_hasError || _sessionResult != null) {
          return true;
        }
        
        // Show confirmation dialog when processing
        final shouldPop = await _showCancelDialog();
        return shouldPop ?? false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Background with animated gradient
            _buildAnimatedBackground(),
            
            // Main content
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.getHorizontalPadding(context),
                  vertical: 24,
                ),
                child: Column(
                  children: [
                    // Top controls
                    _buildTopControls(),
                    
                    // Main processing area
                    Expanded(
                      child: _hasError 
                          ? _buildErrorState()
                          : _sessionResult != null
                              ? _buildSuccessState()
                              : _buildProcessingState(),
                    ),
                    
                    // Bottom controls
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
          // Back button (only show if error or completed)
          if (_hasError || _sessionResult != null)
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
          
          // Title
          Text(
            AppStrings.processingTryOn,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const Spacer(),
          
          // Help button
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
          
          const Size