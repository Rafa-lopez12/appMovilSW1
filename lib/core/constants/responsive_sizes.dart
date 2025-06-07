// lib/core/constants/responsive_sizes.dart
import 'package:flutter/material.dart';
import '../utils/responsive_utils.dart';

class ResponsiveSizes {
  ResponsiveSizes._();

  // Obtener tamaños de texto responsivos
  static TextStyle displayLarge(BuildContext context) => TextStyle(
    fontSize: ResponsiveUtils.getFontSize(context, FontSizeType.display),
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  static TextStyle headlineLarge(BuildContext context) => TextStyle(
    fontSize: ResponsiveUtils.getFontSize(context, FontSizeType.headline),
    fontWeight: FontWeight.bold,
    letterSpacing: -0.25,
  );

  static TextStyle titleLarge(BuildContext context) => TextStyle(
    fontSize: ResponsiveUtils.getFontSize(context, FontSizeType.title),
    fontWeight: FontWeight.w600,
  );

  static TextStyle titleMedium(BuildContext context) => TextStyle(
    fontSize: ResponsiveUtils.getFontSize(context, FontSizeType.subtitle),
    fontWeight: FontWeight.w600,
  );

  static TextStyle bodyLarge(BuildContext context) => TextStyle(
    fontSize: ResponsiveUtils.getFontSize(context, FontSizeType.body),
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle bodyMedium(BuildContext context) => TextStyle(
    fontSize: ResponsiveUtils.getFontSize(context, FontSizeType.body),
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static TextStyle bodySmall(BuildContext context) => TextStyle(
    fontSize: ResponsiveUtils.getFontSize(context, FontSizeType.small),
    fontWeight: FontWeight.w400,
    height: 1.3,
  );

  static TextStyle labelLarge(BuildContext context) => TextStyle(
    fontSize: ResponsiveUtils.getFontSize(context, FontSizeType.body),
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  // Tamaños de botones responsivos
  static Size getButtonSize(BuildContext context, ButtonSizeType type) {
    final scaleFactor = ResponsiveUtils.getScaleFactor(context);
    
    switch (type) {
      case ButtonSizeType.small:
        return Size(double.infinity, 40 * scaleFactor);
      case ButtonSizeType.medium:
        return Size(double.infinity, 48 * scaleFactor);
      case ButtonSizeType.large:
        return Size(double.infinity, 56 * scaleFactor);
    }
  }

  // Tamaños de logos y elementos gráficos
  static double getLogoSize(BuildContext context, LogoSizeType type) {
    final scaleFactor = ResponsiveUtils.getScaleFactor(context);
    
    switch (type) {
      case LogoSizeType.small:
        return 60 * scaleFactor;
      case LogoSizeType.medium:
        return 80 * scaleFactor;
      case LogoSizeType.large:
        return 120 * scaleFactor;
      case LogoSizeType.splash:
        return 150 * scaleFactor;
    }
  }

  // Tamaños de cards responsivos
  static double getCardElevation(BuildContext context) {
    return ResponsiveUtils.isMobile(context) ? 2.0 : 4.0;
  }

  static EdgeInsets getCardMargin(BuildContext context) {
    final spacing = ResponsiveUtils.getSpacing(context, SpacingType.sm);
    return EdgeInsets.all(spacing);
  }

  static EdgeInsets getCardPadding(BuildContext context) {
    final spacing = ResponsiveUtils.getSpacing(context, SpacingType.md);
    return EdgeInsets.all(spacing);
  }

  // Tamaños de formularios
  static double getInputHeight(BuildContext context) {
    final scaleFactor = ResponsiveUtils.getScaleFactor(context);
    return 48 * scaleFactor;
  }

  static EdgeInsets getInputPadding(BuildContext context) {
    final spacing = ResponsiveUtils.getSpacing(context, SpacingType.md);
    return EdgeInsets.symmetric(horizontal: spacing, vertical: spacing * 0.75);
  }

  // Espaciado vertical común
  static Widget verticalSpaceXS(BuildContext context) => 
      ResponsiveUtils.getVerticalSpacing(context, SpacingType.xs);
      
  static Widget verticalSpaceSM(BuildContext context) => 
      ResponsiveUtils.getVerticalSpacing(context, SpacingType.sm);
      
  static Widget verticalSpaceMD(BuildContext context) => 
      ResponsiveUtils.getVerticalSpacing(context, SpacingType.md);
      
  static Widget verticalSpaceLG(BuildContext context) => 
      ResponsiveUtils.getVerticalSpacing(context, SpacingType.lg);
      
  static Widget verticalSpaceXL(BuildContext context) => 
      ResponsiveUtils.getVerticalSpacing(context, SpacingType.xl);

  // Espaciado horizontal común
  static Widget horizontalSpaceXS(BuildContext context) => 
      ResponsiveUtils.getHorizontalSpacing(context, SpacingType.xs);
      
  static Widget horizontalSpaceSM(BuildContext context) => 
      ResponsiveUtils.getHorizontalSpacing(context, SpacingType.sm);
      
  static Widget horizontalSpaceMD(BuildContext context) => 
      ResponsiveUtils.getHorizontalSpacing(context, SpacingType.md);
      
  static Widget horizontalSpaceLG(BuildContext context) => 
      ResponsiveUtils.getHorizontalSpacing(context, SpacingType.lg);
      
  static Widget horizontalSpaceXL(BuildContext context) => 
      ResponsiveUtils.getHorizontalSpacing(context, SpacingType.xl);
}

// Enums adicionales
enum ButtonSizeType { small, medium, large }
enum LogoSizeType { small, medium, large, splash }