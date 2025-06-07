// lib/presentation/widgets/catalog/sort_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconly/iconly.dart';
import 'package:animate_do/animate_do.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../providers/product_provider.dart';

class SortBottomSheet extends StatelessWidget {
  final ProductProvider productProvider;

  const SortBottomSheet({
    Key? key,
    required this.productProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentFilter = productProvider.currentFilter;
    final currentSort = '${currentFilter.orderBy}_${currentFilter.orderDirection}';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          _buildSortOptions(context, currentSort),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Title
          Text(
            'Ordenar por',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortOptions(BuildContext context, String currentSort) {
    final sortOptions = [
      {
        'key': 'name_ASC',
        'title': 'Nombre (A-Z)',
        'subtitle': 'Alfabéticamente ascendente',
        'icon': IconlyLight.arrow_up_square,
      },
      {
        'key': 'name_DESC',
        'title': 'Nombre (Z-A)',
        'subtitle': 'Alfabéticamente descendente',
        'icon': IconlyLight.arrow_down_square,
      },
      {
        'key': 'price_ASC',
        'title': 'Precio: Menor a Mayor',
        'subtitle': 'Productos más económicos primero',
        'icon': IconlyLight.arrow_up_square,
      },
      {
        'key': 'price_DESC',
        'title': 'Precio: Mayor a Menor',
        'subtitle': 'Productos más caros primero',
        'icon': IconlyLight.arrow_down_square,
      },
      {
        'key': 'rating_DESC',
        'title': 'Mejor Calificación',
        'subtitle': 'Productos mejor valorados',
        'icon': IconlyLight.star,
      },
      {
        'key': 'createdAt_DESC',
        'title': 'Más Recientes',
        'subtitle': 'Productos agregados recientemente',
        'icon': IconlyLight.time_circle,
      },
    ];

    return Column(
      children: sortOptions.map((option) {
        final isSelected = currentSort == option['key'];
        
        return FadeInUp(
          duration: Duration(milliseconds: 300 + (sortOptions.indexOf(option) * 50)),
          child: _buildSortOption(
            context: context,
            title: option['title'] as String,
            subtitle: option['subtitle'] as String,
            icon: option['icon'] as IconData,
            isSelected: isSelected,
            onTap: () => _onSortSelected(context, option['key'] as String),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSortOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getHorizontalPadding(context),
        vertical: 4,
      ),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: isSelected
          ? Icon(
              IconlyBold.tick_square,
              color: AppColors.primary,
              size: 20,
            )
          : null,
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
    );
  }

  void _onSortSelected(BuildContext context, String sortKey) {
    final parts = sortKey.split('_');
    final orderBy = parts[0];
    final orderDirection = parts[1];
    
    productProvider.sortProducts(orderBy, orderDirection);
    Navigator.of(context).pop();
  }
}