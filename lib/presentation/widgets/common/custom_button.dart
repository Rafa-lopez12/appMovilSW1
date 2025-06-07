// lib/presentation/widgets/common/custom_button.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';

enum ButtonType { primary, secondary, outline, text }
enum ButtonSize { small, medium, large }

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final ButtonType type;
  final ButtonSize size;
  final double? width;
  final bool enabled;
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderRadius;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.width,
    this.enabled = true,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: _buildButton(),
        );
      },
    );
  }

  Widget _buildButton() {
    final isEnabled = widget.enabled && !widget.isLoading && widget.onPressed != null;
    
    return Container(
      width: widget.width ?? double.infinity,
      height: _getButtonHeight(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? () {
            HapticFeedback.lightImpact();
            widget.onPressed?.call();
          } : null,
          onTapDown: isEnabled ? (details) {
            setState(() {
              _isPressed = true;
            });
            _animationController.forward();
          } : null,
          onTapUp: isEnabled ? (details) {
            setState(() {
              _isPressed = false;
            });
            _animationController.reverse();
          } : null,
          onTapCancel: isEnabled ? () {
            setState(() {
              _isPressed = false;
            });
            _animationController.reverse();
          } : null,
          borderRadius: BorderRadius.circular(widget.borderRadius ?? _getBorderRadius()),
          child: Container(
            decoration: BoxDecoration(
              gradient: _getBackgroundGradient(),
              border: _getBorder(),
              borderRadius: BorderRadius.circular(widget.borderRadius ?? _getBorderRadius()),
              boxShadow: _getBoxShadow(),
            ),
            child: Center(
              child: widget.isLoading
                  ? _buildLoadingIndicator()
                  : _buildButtonContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent() {
    final textStyle = _getTextStyle();
    
    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.icon,
            size: _getIconSize(),
            color: textStyle.color,
          ),
          const SizedBox(width: 8),
          Text(
            widget.text,
            style: textStyle,
          ),
        ],
      );
    }
    
    return Text(
      widget.text,
      style: textStyle,
    );
  }

  Widget _buildLoadingIndicator() {
    final color = _getTextColor();
    final size = _getIconSize();
    
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }

  double _getButtonHeight() {
    switch (widget.size) {
      case ButtonSize.small:
        return 40;
      case ButtonSize.medium:
        return 48;
      case ButtonSize.large:
        return 56;
    }
  }

  double _getBorderRadius() {
    switch (widget.size) {
      case ButtonSize.small:
        return 8;
      case ButtonSize.medium:
        return 12;
      case ButtonSize.large:
        return 16;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 18;
      case ButtonSize.large:
        return 20;
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 14;
      case ButtonSize.medium:
        return 16;
      case ButtonSize.large:
        return 18;
    }
  }

  Gradient? _getBackgroundGradient() {
    final isEnabled = widget.enabled && !widget.isLoading && widget.onPressed != null;
    
    if (widget.backgroundColor != null) {
      return LinearGradient(
        colors: [widget.backgroundColor!, widget.backgroundColor!],
      );
    }
    
    switch (widget.type) {
      case ButtonType.primary:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isEnabled
              ? [AppColors.primary, AppColors.secondary]
              : [AppColors.disabled, AppColors.disabled],
        );
      case ButtonType.secondary:
        return LinearGradient(
          colors: [AppColors.surface, AppColors.surface],
        );
      case ButtonType.outline:
      case ButtonType.text:
        return null;
    }
  }

  Border? _getBorder() {
    switch (widget.type) {
      case ButtonType.outline:
        return Border.all(
          color: AppColors.primary,
          width: 2,
        );
      default:
        return null;
    }
  }

  List<BoxShadow>? _getBoxShadow() {
    final isEnabled = widget.enabled && !widget.isLoading && widget.onPressed != null;
    
    if (!isEnabled) return null;
    
    switch (widget.type) {
      case ButtonType.primary:
        return [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ];
      case ButtonType.secondary:
        return [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ];
      default:
        return null;
    }
  }

  Color _getTextColor() {
    if (widget.textColor != null) return widget.textColor!;
    
    final isEnabled = widget.enabled && !widget.isLoading && widget.onPressed != null;
    
    switch (widget.type) {
      case ButtonType.primary:
        return isEnabled ? Colors.white : AppColors.textSecondary;
      case ButtonType.secondary:
        return isEnabled ? AppColors.textPrimary : AppColors.textSecondary;
      case ButtonType.outline:
      case ButtonType.text:
        return isEnabled ? AppColors.primary : AppColors.textSecondary;
    }
  }

  TextStyle _getTextStyle() {
    return TextStyle(
      fontSize: _getFontSize(),
      fontWeight: FontWeight.w600,
      color: _getTextColor(),
      letterSpacing: 0.5,
    );
  }
}