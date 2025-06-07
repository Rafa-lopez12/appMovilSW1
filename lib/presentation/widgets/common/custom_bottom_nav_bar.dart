// lib/presentation/widgets/common/custom_bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../providers/cart_provider.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = ResponsiveUtils.isVerySmallScreen(context);
    
    return Container(
      height: isSmallScreen ? 65 : 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedFontSize: isSmallScreen ? 10 : 12,
          unselectedFontSize: isSmallScreen ? 10 : 12,
          iconSize: isSmallScreen ? 20 : 24,
          items: [
            _buildNavBarItem(
              icon: IconlyLight.home,
              activeIcon: IconlyBold.home,
              label: AppStrings.home,
              index: 0,
            ),
            _buildNavBarItem(
              icon: IconlyLight.category,
              activeIcon: IconlyBold.category,
              label: AppStrings.catalog,
              index: 1,
            ),
            _buildNavBarItem(
              icon: IconlyLight.search,
              activeIcon: IconlyBold.search,
              label: AppStrings.aiSearch,
              index: 2,
              isSpecial: true, // Para destacar la búsqueda IA
            ),
            _buildNavBarItem(
              icon: IconlyLight.bag,
              activeIcon: IconlyBold.bag,
              label: AppStrings.cart,
              index: 3,
              hasBadge: true, // Para mostrar el contador del carrito
            ),
            _buildNavBarItem(
              icon: IconlyLight.profile,
              activeIcon: IconlyBold.profile,
              label: AppStrings.profile,
              index: 4,
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavBarItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    bool isSpecial = false,
    bool hasBadge = false,
  }) {
    return BottomNavigationBarItem(
      icon: _NavBarIcon(
        icon: icon,
        activeIcon: activeIcon,
        isActive: currentIndex == index,
        isSpecial: isSpecial,
        hasBadge: hasBadge,
        index: index,
      ),
      label: label,
    );
  }
}

class _NavBarIcon extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final bool isActive;
  final bool isSpecial;
  final bool hasBadge;
  final int index;

  const _NavBarIcon({
    required this.icon,
    required this.activeIcon,
    required this.isActive,
    required this.isSpecial,
    required this.hasBadge,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = Icon(
      isActive ? activeIcon : icon,
      size: ResponsiveUtils.isVerySmallScreen(context) ? 20 : 24,
    );

    // Si es especial (AI Search), agregar un fondo con gradiente
    if (isSpecial) {
      iconWidget = Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: isActive
              ? AppColors.primaryGradient
              : LinearGradient(
                  colors: [
                    AppColors.accent.withOpacity(0.2),
                    AppColors.primary.withOpacity(0.2),
                  ],
                ),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isActive ? activeIcon : icon,
          size: 20,
          color: isActive ? Colors.white : AppColors.primary,
        ),
      );
    }

    // Si tiene badge (carrito), agregar el contador
    if (hasBadge) {
      return Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          final itemCount = cartProvider.itemCount;
          
          return Stack(
            clipBehavior: Clip.none,
            children: [
              iconWidget,
              if (itemCount > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: FadeIn(
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 1,
                        ),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        itemCount > 99 ? '99+' : itemCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      );
    }

    // Animación para el ícono activo
    if (isActive && !isSpecial) {
      return Bounce(
        duration: const Duration(milliseconds: 300),
        child: iconWidget,
      );
    }

    return iconWidget;
  }
}