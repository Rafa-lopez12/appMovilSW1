// lib/presentation/widgets/product/variant_selector_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconly/iconly.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_utils.dart';

class VariantSelectorWidget extends StatefulWidget {
  final String title;
  final List<String> options;
  final String? selectedOption;
  final Function(String) onOptionSelected;
  final bool isColorSelector;
  final bool isRequired;
  final String? helpText;
  final bool showAsGrid;
  final int? maxItemsPerRow;

  const VariantSelectorWidget({
    Key? key,
    required this.title,
    required this.options,
    this.selectedOption,
    required this.onOptionSelected,
    this.isColorSelector = false,
    this.isRequired = false,
    this.helpText,
    this.showAsGrid = false,
    this.maxItemsPerRow,
  }) : super(key: key);

  @override
  State<VariantSelectorWidget> createState() => _VariantSelectorWidgetState();
}

class _VariantSelectorWidgetState extends State<VariantSelectorWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.options.isEmpty) {
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildOptions(),
            if (widget.helpText != null) ...[
              const SizedBox(height: 8),
              _buildHelpText(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Text(
          widget.title,
          style: TextStyle(
            fontSize: ResponsiveUtils.getFontSize(context, FontSizeType.subtitle),
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (widget.isRequired) ...[
          const SizedBox(width: 4),
          Text(
            '*',
            style: TextStyle(
              fontSize: ResponsiveUtils.getFontSize(context, FontSizeType.subtitle),
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
        ],
        const Spacer(),
        if (widget.selectedOption != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Seleccionado: ${widget.selectedOption}',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOptions() {
    if (widget.showAsGrid || widget.isColorSelector) {
      return _buildGridOptions();
    } else {
      return _buildHorizontalOptions();
    }
  }

  Widget _buildHorizontalOptions() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: widget.options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          
          return FadeInRight(
            duration: Duration(milliseconds: 300 + (index * 50)),
            child: Padding(
              padding: EdgeInsets.only(
                right: index < widget.options.length - 1 ? 12 : 0,
              ),
              child: _buildOptionItem(option, index),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGridOptions() {
    final itemsPerRow = widget.maxItemsPerRow ?? 
                      (widget.isColorSelector ? 4 : 3);
    
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: widget.options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        
        return FadeInUp(
          duration: Duration(milliseconds: 300 + (index * 50)),
          child: SizedBox(
            width: (MediaQuery.of(context).size.width - 
                   ResponsiveUtils.getHorizontalPadding(context) * 2 - 
                   (itemsPerRow - 1) * 12) / itemsPerRow,
            child: _buildOptionItem(option, index),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOptionItem(String option, int index) {
    final isSelected = widget.selectedOption == option;
    
    if (widget.isColorSelector) {
      return _buildColorOption(option, isSelected);
    } else {
      return _buildSizeOption(option, isSelected);
    }
  }

  Widget _buildSizeOption(String size, bool isSelected) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onOptionSelected(size);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              size,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Icon(
                IconlyBold.tick_square,
                size: 16,
                color: Colors.white,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption(String color, bool isSelected) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onOptionSelected(color);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Color circle
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _getColorFromName(color),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: _getContrastColor(_getColorFromName(color)),
                    )
                  : null,
            ),
            
            const SizedBox(width: 8),
            
            // Color name
            Text(
              color,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpText() {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.info.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.info.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              IconlyLight.info_circle,
              size: 16,
              color: AppColors.info,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.helpText!,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.info,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'rojo':
      case 'red':
        return Colors.red;
      case 'azul':
      case 'blue':
        return Colors.blue;
      case 'verde':
      case 'green':
        return Colors.green;
      case 'amarillo':
      case 'yellow':
        return Colors.yellow;
      case 'negro':
      case 'black':
        return Colors.black;
      case 'blanco':
      case 'white':
        return Colors.white;
      case 'gris':
      case 'gray':
      case 'grey':
        return Colors.grey;
      case 'rosa':
      case 'pink':
        return Colors.pink;
      case 'morado':
      case 'purple':
        return Colors.purple;
      case 'naranja':
      case 'orange':
        return Colors.orange;
      case 'café':
      case 'brown':
        return Colors.brown;
      case 'beige':
        return const Color(0xFFF5F5DC);
      case 'turquesa':
      case 'turquoise':
        return Colors.teal;
      case 'marino':
      case 'navy':
        return const Color(0xFF000080);
      case 'crema':
      case 'cream':
        return const Color(0xFFFFFDD0);
      case 'dorado':
      case 'gold':
        return const Color(0xFFFFD700);
      case 'plateado':
      case 'silver':
        return const Color(0xFFC0C0C0);
      default:
        return AppColors.primary;
    }
  }

  Color _getContrastColor(Color backgroundColor) {
    // Calculate relative luminance
    final luminance = backgroundColor.computeLuminance();
    
    // Return black for light colors, white for dark colors
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}

// Widget especializado para selector de tallas solamente
class SizeSelectorWidget extends StatelessWidget {
  final List<String> sizes;
  final String? selectedSize;
  final Function(String) onSizeSelected;
  final bool isRequired;
  final String? helpText;

  const SizeSelectorWidget({
    Key? key,
    required this.sizes,
    this.selectedSize,
    required this.onSizeSelected,
    this.isRequired = false,
    this.helpText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return VariantSelectorWidget(
      title: 'Talla',
      options: sizes,
      selectedOption: selectedSize,
      onOptionSelected: onSizeSelected,
      isRequired: isRequired,
      helpText: helpText,
    );
  }
}

// Widget especializado para selector de colores solamente
class ColorSelectorWidget extends StatelessWidget {
  final List<String> colors;
  final String? selectedColor;
  final Function(String) onColorSelected;
  final bool isRequired;
  final String? helpText;
  final bool showAsGrid;

  const ColorSelectorWidget({
    Key? key,
    required this.colors,
    this.selectedColor,
    required this.onColorSelected,
    this.isRequired = false,
    this.helpText,
    this.showAsGrid = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return VariantSelectorWidget(
      title: 'Color',
      options: colors,
      selectedOption: selectedColor,
      onOptionSelected: onColorSelected,
      isColorSelector: true,
      isRequired: isRequired,
      helpText: helpText,
      showAsGrid: showAsGrid,
    );
  }
}

// Widget combinado para mostrar talla y color juntos
class VariantCombinedSelectorWidget extends StatelessWidget {
  final List<String> sizes;
  final List<String> colors;
  final String? selectedSize;
  final String? selectedColor;
  final Function(String) onSizeSelected;
  final Function(String) onColorSelected;
  final bool isRequired;

  const VariantCombinedSelectorWidget({
    Key? key,
    required this.sizes,
    required this.colors,
    this.selectedSize,
    this.selectedColor,
    required this.onSizeSelected,
    required this.onColorSelected,
    this.isRequired = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (sizes.isNotEmpty) ...[
          SizeSelectorWidget(
            sizes: sizes,
            selectedSize: selectedSize,
            onSizeSelected: onSizeSelected,
            isRequired: isRequired,
            helpText: 'Selecciona la talla que mejor te quede',
          ),
          const SizedBox(height: 20),
        ],
        
        if (colors.isNotEmpty)
          ColorSelectorWidget(
            colors: colors,
            selectedColor: selectedColor,
            onColorSelected: onColorSelected,
            isRequired: isRequired,
            helpText: 'Elige tu color favorito',
          ),
      ],
    );
  }
}