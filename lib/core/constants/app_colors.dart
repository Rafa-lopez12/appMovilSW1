// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9B94FF);
  static const Color primaryDark = Color(0xFF3F35CC);
  
  // Secondary Colors
  static const Color secondary = Color(0xFFFF6B9D);
  static const Color secondaryLight = Color(0xFFFF9BC7);
  static const Color secondaryDark = Color(0xFFCC3F73);
  
  // Accent Colors
  static const Color accent = Color(0xFF4ECDC4);
  static const Color accentLight = Color(0xFF7EE4DD);
  static const Color accentDark = Color(0xFF26A69A);
  
  // Background Colors
  static const Color background = Color(0xFFF8F9FE);
  static const Color backgroundDark = Color(0xFF1A1A1A);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF2D2D2D);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color textLight = Color(0xFFA0AEC0);
  static const Color textDark = Color(0xFF1A202C);
  
  // Status Colors
  static const Color success = Color(0xFF48BB78);
  static const Color successLight = Color(0xFF68D391);
  static const Color successDark = Color(0xFF38A169);
  
  static const Color warning = Color(0xFFED8936);
  static const Color warningLight = Color(0xFFFBB865);
  static const Color warningDark = Color(0xFFDD6B20);
  
  static const Color error = Color(0xFFE53E3E);
  static const Color errorLight = Color(0xFFFC8181);
  static const Color errorDark = Color(0xFFC53030);
  
  static const Color info = Color(0xFF3182CE);
  static const Color infoLight = Color(0xFF63B3ED);
  static const Color infoDark = Color(0xFF2C5282);
  
  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;
  
  // Border and Divider Colors
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF4A5568);
  static const Color divider = Color(0xFFEDF2F7);
  
  // Disabled Colors
  static const Color disabled = Color(0xFFA0AEC0);
  static const Color disabledDark = Color(0xFF4A5568);
  
  // Shadow Colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowDark = Color(0x33000000);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, primary],
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, surface],
  );
  
  // Social Media Colors
  static const Color google = Color(0xFFDB4437);
  static const Color facebook = Color(0xFF4267B2);
  static const Color apple = Color(0xFF000000);
  static const Color twitter = Color(0xFF1DA1F2);
  static const Color instagram = Color(0xFFE4405F);
  
  // Category Colors (for product categories)
  static const List<Color> categoryColors = [
    Color(0xFFFF6B9D), // Pink
    Color(0xFF4ECDC4), // Teal
    Color(0xFFFFE66D), // Yellow
    Color(0xFF95E1D3), // Mint
    Color(0xFFFCE38A), // Light Yellow
    Color(0xFFF38BA8), // Light Pink
    Color(0xFFA8DADC), // Light Blue
    Color(0xFFDDA0DD), // Plum
  ];
  
  // Rating Colors
  static const Color ratingFilled = Color(0xFFFFB400);
  static const Color ratingEmpty = Color(0xFFE0E6ED);
  
  // Cart and Shopping Colors
  static const Color cartBackground = Color(0xFFF1F3F4);
  static const Color priceTag = Color(0xFF00BFA5);
  static const Color discount = Color(0xFFFF5722);
  static const Color outOfStock = Color(0xFF9E9E9E);
  
  // Theme-specific method to get colors based on brightness
  static Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? white 
        : textPrimary;
  }
  
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? backgroundDark 
        : background;
  }
  
  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? surfaceDark 
        : surface;
  }
}