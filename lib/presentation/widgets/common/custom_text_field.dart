import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final bool enabled;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final bool readOnly;
  final VoidCallback? onTap;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.enabled = true,
    this.maxLines = 1,
    this.inputFormatters,
    this.focusNode,
    this.readOnly = false,
    this.onTap,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  bool _isFocused = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });

    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                widget.labelText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _isFocused
                      ? AppColors.primary
                      : _hasError
                          ? AppColors.error
                          : AppColors.textSecondary,
                ),
              ),
            ),
            
            // Text Field Container
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isFocused
                      ? AppColors.primary
                      : _hasError
                          ? AppColors.error
                          : AppColors.border,
                  width: _isFocused ? 2 : 1,
                ),
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: TextFormField(
                controller: widget.controller,
                focusNode: _focusNode,
                obscureText: widget.obscureText,
                keyboardType: widget.keyboardType,
                textInputAction: widget.textInputAction,
                enabled: widget.enabled,
                maxLines: widget.maxLines,
                inputFormatters: widget.inputFormatters,
                readOnly: widget.readOnly,
                onTap: widget.onTap,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.6),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: widget.prefixIcon != null
                      ? Container(
                          margin: const EdgeInsets.only(left: 16, right: 12),
                          child: Icon(
                            widget.prefixIcon,
                            color: _isFocused
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            size: 20,
                          ),
                        )
                      : null,
                  suffixIcon: widget.suffixIcon != null
                      ? Container(
                          margin: const EdgeInsets.only(right: 16),
                          child: widget.suffixIcon,
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: widget.prefixIcon != null ? 0 : 16,
                    vertical: 16,
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 20,
                  ),
                  suffixIconConstraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 20,
                  ),
                ),
                validator: (value) {
                  final error = widget.validator?.call(value);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      _hasError = error != null;
                    });
                  });
                  return error;
                },
                onChanged: widget.onChanged,
                onFieldSubmitted: widget.onFieldSubmitted,
              ),
            ),
          ],
        );
      },
    );
  }
}