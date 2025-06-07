// lib/presentation/widgets/common/password_strength_indicator.dart
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final int strength;
  final bool showText;
  final bool showRequirements;

  const PasswordStrengthIndicator({
    Key? key,
    required this.strength,
    this.showText = true,
    this.showRequirements = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Strength bars
        _buildStrengthBars(),
        
        if (showText) ...[
          const SizedBox(height: 8),
          _buildStrengthText(),
        ],
        
        if (showRequirements) ...[
          const SizedBox(height: 12),
          _buildRequirements(),
        ],
      ],
    );
  }

  Widget _buildStrengthBars() {
    return Row(
      children: List.generate(5, (index) {
        final isActive = index < strength;
        final color = _getStrengthColor();
        
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(
              right: index < 4 ? 4 : 0,
            ),
            decoration: BoxDecoration(
              color: isActive ? color : AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
            child: isActive
                ? FadeIn(
                    duration: Duration(milliseconds: 200 + (index * 50)),
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  )
                : null,
          ),
        );
      }),
    );
  }

  Widget _buildStrengthText() {
    final strengthText = Validators.getPasswordStrengthText(strength);
    final color = _getStrengthColor();
    
    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      child: Row(
        children: [
          Icon(
            _getStrengthIcon(),
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            'Fortaleza: $strengthText',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirements() {
    final requirements = [
      RequirementItem(
        text: 'Al menos 8 caracteres',
        isMet: strength >= 1,
      ),
      RequirementItem(
        text: 'Una letra mayúscula',
        isMet: strength >= 2,
      ),
      RequirementItem(
        text: 'Una letra minúscula',
        isMet: strength >= 3,
      ),
      RequirementItem(
        text: 'Un número',
        isMet: strength >= 4,
      ),
      RequirementItem(
        text: 'Un carácter especial',
        isMet: strength >= 5,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Requisitos de contraseña:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        ...requirements.map((requirement) => _buildRequirementItem(requirement)),
      ],
    );
  }

  Widget _buildRequirementItem(RequirementItem requirement) {
    return FadeInLeft(
      duration: const Duration(milliseconds: 300),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: requirement.isMet ? AppColors.success : AppColors.border,
              ),
              child: requirement.isMet
                  ? const Icon(
                      Icons.check,
                      size: 10,
                      color: Colors.white,
                    )
                  : Container(),
            ),
            const SizedBox(width: 8),
            Text(
              requirement.text,
              style: TextStyle(
                fontSize: 11,
                color: requirement.isMet
                    ? AppColors.success
                    : AppColors.textSecondary,
                fontWeight: requirement.isMet
                    ? FontWeight.w500
                    : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStrengthColor() {
    switch (strength) {
      case 0:
      case 1:
        return AppColors.error;
      case 2:
        return AppColors.warning;
      case 3:
        return AppColors.info;
      case 4:
        return AppColors.success;
      case 5:
        return AppColors.success;
      default:
        return AppColors.error;
    }
  }

  IconData _getStrengthIcon() {
    switch (strength) {
      case 0:
      case 1:
        return Icons.warning_rounded;
      case 2:
        return Icons.info_rounded;
      case 3:
        return Icons.check_circle_outline;
      case 4:
      case 5:
        return Icons.verified_rounded;
      default:
        return Icons.warning_rounded;
    }
  }
}

class RequirementItem {
  final String text;
  final bool isMet;

  RequirementItem({
    required this.text,
    required this.isMet,
  });
}