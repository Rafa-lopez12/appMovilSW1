import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconly/iconly.dart';
import 'dart:io';
import '../../../core/constants/app_colors.dart';

class TryonCameraWidget extends StatelessWidget {
  final VoidCallback? onCapture;
  final VoidCallback? onGallerySelect;
  final int currentStep;
  final File? userImage;
  final File? garmentImage;

  const TryonCameraWidget({
    Key? key,
    this.onCapture,
    this.onGallerySelect,
    this.currentStep = 0,
    this.userImage,
    this.garmentImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black,
        child: Stack(
          children: [
            // Camera preview area (placeholder)
            _buildCameraPreview(),
            
            // Overlay guides
            _buildOverlayGuides(),
            
            // Step-specific content
            if (currentStep == 0) _buildUserPhotoGuide(),
            if (currentStep == 1) _buildGarmentPhotoGuide(),
            if (currentStep == 2) _buildReadyState(),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              Colors.grey[900]!,
              Colors.black,
            ],
          ),
        ),
        child: Center(
          child: Icon(
            IconlyLight.camera,
            size: 100,
            color: Colors.white.withOpacity(0.2),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlayGuides() {
    return Positioned.fill(
      child: CustomPaint(
        painter: CameraOverlayPainter(currentStep: currentStep),
      ),
    );
  }

  Widget _buildUserPhotoGuide() {
    return Positioned(
      top: 200,
      left: 50,
      right: 50,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              IconlyBold.profile,
              color: AppColors.primary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Colócate en el centro del marco',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadyState() {
    return Positioned(
      top: 200,
      left: 50,
      right: 50,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // User image preview
                if (userImage != null)
                  _buildImagePreview(userImage!, 'Tu foto', IconlyBold.profile),
                
                // Garment image preview
                if (garmentImage != null)
                  _buildImagePreview(garmentImage!, 'Prenda', IconlyBold.bag),
              ],
            ),
            const SizedBox(height: 16),
            Icon(
              IconlyBold.tick_square,
              color: AppColors.success,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              '¡Todo listo!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Puedes comenzar el try-on virtual',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(File image, String label, IconData icon) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              image,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 12),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class CameraOverlayPainter extends CustomPainter {
  final int currentStep;

  CameraOverlayPainter({required this.currentStep});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    if (currentStep == 0) {
      // User silhouette guide
      _drawUserGuide(canvas, size, paint);
    } else if (currentStep == 1) {
      // Garment outline guide
      _drawGarmentGuide(canvas, size, paint);
    }
  }

  void _drawUserGuide(Canvas canvas, Size size, Paint paint) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // Draw body outline guide
    final path = Path();
    
    // Head (circle)
    canvas.drawCircle(
      Offset(centerX, centerY - 120),
      30,
      paint,
    );
    
    // Body (rectangle with rounded corners)
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, centerY - 40),
        width: 120,
        height: 160,
      ),
      const Radius.circular(20),
    );
    canvas.drawRRect(bodyRect, paint);
    
    // Arms
    canvas.drawLine(
      Offset(centerX - 60, centerY - 80),
      Offset(centerX - 100, centerY - 40),
      paint,
    );
    canvas.drawLine(
      Offset(centerX + 60, centerY - 80),
      Offset(centerX + 100, centerY - 40),
      paint,
    );
    
    // Legs
    canvas.drawLine(
      Offset(centerX - 30, centerY + 40),
      Offset(centerX - 40, centerY + 120),
      paint,
    );
    canvas.drawLine(
      Offset(centerX + 30, centerY + 40),
      Offset(centerX + 40, centerY + 120),
      paint,
    );
  }

  void _drawGarmentGuide(Canvas canvas, Size size, Paint paint) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // Draw garment outline (shirt example)
    final path = Path();
    path.moveTo(centerX - 80, centerY - 60);
    path.lineTo(centerX + 80, centerY - 60);
    path.lineTo(centerX + 100, centerY - 40);
    path.lineTo(centerX + 80, centerY + 60);
    path.lineTo(centerX - 80, centerY + 60);
    path.lineTo(centerX - 100, centerY - 40);
    path.close();
    
    canvas.drawPath(path, paint);
    
    // Draw collar
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(centerX, centerY - 50),
        width: 40,
        height: 20,
      ),
      0,
      3.14159,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}