// lib/core/utils/responsive_utils.dart
import 'package:flutter/material.dart';

class ResponsiveUtils {
  ResponsiveUtils._();

  // Breakpoints estándar
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // Obtener el tipo de dispositivo
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < mobileBreakpoint) {
      return DeviceType.mobile;
    } else if (width < tabletBreakpoint) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  // Verificar si es móvil
  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }

  // Verificar si es tablet
  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  // Verificar si es desktop
  static bool isDesktop(BuildContext context) {
    return getDeviceType(context) == DeviceType.desktop;
  }

  // Obtener padding horizontal responsivo
  static double getHorizontalPadding(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return 16.0;
      case DeviceType.tablet:
        return 32.0;
      case DeviceType.desktop:
        return 64.0;
    }
  }

  // Obtener padding vertical responsivo
  static double getVerticalPadding(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return 16.0;
      case DeviceType.tablet:
        return 24.0;
      case DeviceType.desktop:
        return 32.0;
    }
  }

  // Obtener ancho máximo del contenido
  static double getMaxContentWidth(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return double.infinity;
      case DeviceType.tablet:
        return 600.0;
      case DeviceType.desktop:
        return 800.0;
    }
  }

  // Obtener número de columnas para grids
  static int getGridColumns(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return 2;
      case DeviceType.tablet:
        return 3;
      case DeviceType.desktop:
        return 4;
    }
  }

  // Verificar si la pantalla es pequeña (height < 700)
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.height < 700;
  }

  // Verificar si la pantalla es muy pequeña (height < 600)
  static bool isVerySmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.height < 600;
  }

  // Obtener factor de escala para elementos UI
  static double getScaleFactor(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    
    if (height < 600) {
      return 0.8; // Pantallas muy pequeñas
    } else if (height < 700) {
      return 0.9; // Pantallas pequeñas
    } else if (height > 900) {
      return 1.1; // Pantallas grandes
    } else {
      return 1.0; // Pantallas normales
    }
  }

  // Obtener tamaños de fuente responsivos
  static double getFontSize(BuildContext context, FontSizeType type) {
    final scaleFactor = getScaleFactor(context);
    final deviceType = getDeviceType(context);
    
    double baseSize;
    switch (type) {
      case FontSizeType.small:
        baseSize = deviceType == DeviceType.mobile ? 12 : 14;
        break;
      case FontSizeType.body:
        baseSize = deviceType == DeviceType.mobile ? 14 : 16;
        break;
      case FontSizeType.subtitle:
        baseSize = deviceType == DeviceType.mobile ? 16 : 18;
        break;
      case FontSizeType.title:
        baseSize = deviceType == DeviceType.mobile ? 20 : 24;
        break;
      case FontSizeType.headline:
        baseSize = deviceType == DeviceType.mobile ? 24 : 32;
        break;
      case FontSizeType.display:
        baseSize = deviceType == DeviceType.mobile ? 28 : 36;
        break;
    }
    
    return baseSize * scaleFactor;
  }

  // Obtener espaciado responsivo
  static double getSpacing(BuildContext context, SpacingType type) {
    final scaleFactor = getScaleFactor(context);
    
    double baseSpacing;
    switch (type) {
      case SpacingType.xs:
        baseSpacing = 4;
        break;
      case SpacingType.sm:
        baseSpacing = 8;
        break;
      case SpacingType.md:
        baseSpacing = 16;
        break;
      case SpacingType.lg:
        baseSpacing = 24;
        break;
      case SpacingType.xl:
        baseSpacing = 32;
        break;
      case SpacingType.xxl:
        baseSpacing = 48;
        break;
    }
    
    return baseSpacing * scaleFactor;
  }

  // Obtener tamaños de iconos responsivos
  static double getIconSize(BuildContext context, IconSizeType type) {
    final scaleFactor = getScaleFactor(context);
    
    double baseSize;
    switch (type) {
      case IconSizeType.small:
        baseSize = 16;
        break;
      case IconSizeType.medium:
        baseSize = 24;
        break;
      case IconSizeType.large:
        baseSize = 32;
        break;
      case IconSizeType.xl:
        baseSize = 48;
        break;
    }
    
    return baseSize * scaleFactor;
  }

  // Obtener radio de bordes responsivo
  static double getBorderRadius(BuildContext context, BorderRadiusType type) {
    final deviceType = getDeviceType(context);
    
    double baseRadius;
    switch (type) {
      case BorderRadiusType.small:
        baseRadius = deviceType == DeviceType.mobile ? 8 : 12;
        break;
      case BorderRadiusType.medium:
        baseRadius = deviceType == DeviceType.mobile ? 12 : 16;
        break;
      case BorderRadiusType.large:
        baseRadius = deviceType == DeviceType.mobile ? 16 : 20;
        break;
      case BorderRadiusType.xl:
        baseRadius = deviceType == DeviceType.mobile ? 20 : 24;
        break;
    }
    
    return baseRadius;
  }

  // Métodos de conveniencia para valores específicos
  static EdgeInsets getPagePadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: getHorizontalPadding(context),
      vertical: getVerticalPadding(context),
    );
  }

  static EdgeInsets getCardPadding(BuildContext context) {
    final spacing = getSpacing(context, SpacingType.md);
    return EdgeInsets.all(spacing);
  }

  static SizedBox getVerticalSpacing(BuildContext context, SpacingType type) {
    return SizedBox(height: getSpacing(context, type));
  }

  static SizedBox getHorizontalSpacing(BuildContext context, SpacingType type) {
    return SizedBox(width: getSpacing(context, type));
  }
}

// Enums para tipos
enum DeviceType { mobile, tablet, desktop }
enum FontSizeType { small, body, subtitle, title, headline, display }
enum SpacingType { xs, sm, md, lg, xl, xxl }
enum IconSizeType { small, medium, large, xl }
enum BorderRadiusType { small, medium, large, xl }