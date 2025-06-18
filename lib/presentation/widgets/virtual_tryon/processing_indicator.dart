import 'package:flutter/material.dart';
import 'dart:math';
import '../../../core/constants/app_colors.dart';

class ProcessingIndicator extends StatefulWidget {
  final double progress;
  final double size;
  final Color? color;

  const ProcessingIndicator({
    Key? key,
    required this.progress,
    this.size = 60,
    this.color,
  }) : super(key: key);

  @override
  State<ProcessingIndicator> createState() => _ProcessingIndicatorState();
}

class _ProcessingIndicatorState extends State<ProcessingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          
          // Progress indicator
          CustomPaint(
            size: Size(widget.size, widget.size),
            painter: ProcessingPainter(
              progress: widget.progress,
              color: widget.color ?? AppColors.primary,
              animation: _rotationController,
            ),
          ),
          
          // Center pulse
          ScaleTransition(
            scale: Tween(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
            ),
            child: Container(
              width: widget.size * 0.3,
              height: widget.size * 0.3,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (widget.color ?? AppColors.primary).withOpacity(0.8),
              ),
            ),
          ),
          
          // Progress percentage
          Text(
            '${(widget.progress * 100).toInt()}%',
            style: TextStyle(
              color: Colors.white,
              fontSize: widget.size * 0.15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class ProcessingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Animation<double> animation;

  ProcessingPainter({
    required this.progress,
    required this.color,
    required this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    
    // Background arc
    final backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    
    canvas.drawCircle(center, radius, backgroundPaint);
    
    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    
    final sweepAngle = 2 * pi * progress;
    final startAngle = -pi / 2 + (animation.value * 2 * pi);
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
    
    // Animated dots
    for (int i = 0; i < 8; i++) {
      final angle = (i * pi / 4) + (animation.value * 2 * pi);
      final dotX = center.dx + (radius + 8) * cos(angle);
      final dotY = center.dy + (radius + 8) * sin(angle);
      
      final dotPaint = Paint()
        ..color = color.withOpacity(0.6)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(dotX, dotY), 2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}