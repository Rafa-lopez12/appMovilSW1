// lib/presentation/widgets/catalog/filter_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconly/iconly.dart';
import 'package:animate_do/animate_do.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../providers/product_provider.dart';
import '../common/custom_button.dart';

class FilterBottomSheet extends StatefulWidget {
  final ProductProvider productProvider;

  const FilterBottomSheet({
    Key? key,
    required this.productProvider,
  }) : super(key: key);

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  // Filter state
  String? _selectedCategoryId;
  String? _selectedSubcategory;
  double _minPrice = 0;
  double _maxPrice = 1000;
  String? _selectedSize;
  String? _selectedColor;
  
  // Available options
  List<String> _availableSizes = [];
  List<String> _availableColors = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeFilters();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initializeFilters() {
    final filter = widget.productProvider.currentFilter;
    
    setState(() {
      _selectedCategoryId = filter.categoryId;
      _selectedSubcategory = filter.subcategory;
      _minPrice = filter.minPrice ?? 0;
      _maxPrice = filter.maxPrice ?? 1000;
      _selectedSize = filter.size;
      _selectedColor = filter.color;
      
      _availableSizes = widget.productProvider.getAvailableSizes();
      _availableColors = widget.productProvider.getAvailableColors();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCategoryTab(),
                _buildPriceTab(),
                _buildSizeTab(),
                _buildColorTab(),
              ],
            ),
          ),
          _buildActions(),
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
          
          // Title and clear button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filtros',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              
              TextButton(
                onPressed: _clearAllFilters,
                child: Text(
                  'Limpiar todo',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getHorizontalPadding(context),
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        tabs: const [
          Tab(text: 'Categoría'),
          Tab(text: 'Precio'),
          Tab(text: 'Talla'),
          Tab(text: 'Color'),
        ],
      ),
    );
  }

  Widget _buildCategoryTab() {
    return FadeIn(
      duration: const Duration(milliseconds: 300),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(
          ResponsiveUtils.getHorizontalPadding(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            
            // Categories
            Text(
              'Categorías',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // All categories option
            _buildFilterTile(
              title: 'Todas las categorías',
              isSelected: _selectedCategoryId == null,
              onTap: () {
                setState(() {
                  _selectedCategoryId = null;
                  _selectedSubcategory = null;
                });
              },
            ),
            
            // Category list
            ...widget.productProvider.categories.map((category) {
              final isSelected = _selectedCategoryId == category.id;
              
              return Column(
                children: [
                  _buildFilterTile(
                    title: category.name,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        _selectedCategoryId = isSelected ? null : category.id;
                        _selectedSubcategory = null;
                      });
                    },
                  ),
                  
                  // Subcategories
                  if (isSelected && category.subcategories.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(left: 20),
                      child: Column(
                        children: category.subcategories.map((subcategory) {
                          return _buildFilterTile(
                            title: subcategory,
                            isSelected: _selectedSubcategory == subcategory,
                            isSubcategory: true,
                            onTap: () {
                              setState(() {
                                _selectedSubcategory = _selectedSubcategory == subcategory 
                                    ? null 
                                    : subcategory;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceTab() {
    return FadeIn(
      duration: const Duration(milliseconds: 300),
      child: Padding(
        padding: EdgeInsets.all(
          ResponsiveUtils.getHorizontalPadding(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            
            Text(
              'Rango de Precio',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Price display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPriceInput(
                  label: 'Precio mínimo',
                  value: _minPrice,
                  onChanged: (value) {
                    setState(() {
                      _minPrice = value;
                      if (_minPrice > _maxPrice) {
                        _maxPrice = _minPrice;
                      }
                    });
                  },
                ),
                
                Container(
                  width: 20,
                  height: 2,
                  color: AppColors.border,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),
                
                _buildPriceInput(
                  label: 'Precio máximo',
                  value: _maxPrice,
                  onChanged: (value) {
                    setState(() {
                      _maxPrice = value;
                      if (_maxPrice < _minPrice) {
                        _minPrice = _maxPrice;
                      }
                    });
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Range slider
            RangeSlider(
              values: RangeValues(_minPrice, _maxPrice),
              min: 0,
              max: 1000,
              divisions: 100,
              labels: RangeLabels(
                '\${_minPrice.toStringAsFixed(0)}',
                '\${_maxPrice.toStringAsFixed(0)}',
              ),
              activeColor: AppColors.primary,
              inactiveColor: AppColors.border,
              onChanged: (values) {
                setState(() {
                  _minPrice = values.start;
                  _maxPrice = values.end;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Quick price filters
            Text(
              'Filtros rápidos',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQuickPriceFilter('Menos de \$50', 0, 50),
                _buildQuickPriceFilter('\$50 - \$100', 50, 100),
                _buildQuickPriceFilter('\$100 - \$200', 100, 200),
                _buildQuickPriceFilter('Más de \$200', 200, 1000),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeTab() {
    return FadeIn(
      duration: const Duration(milliseconds: 300),
      child: Padding(
        padding: EdgeInsets.all(
          ResponsiveUtils.getHorizontalPadding(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            
            Text(
              'Tallas disponibles',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            
            const SizedBox(height: 16),
            
            if (_availableSizes.isEmpty)
              Center(
                child: Text(
                  'No hay tallas disponibles',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _availableSizes.map((size) {
                  final isSelected = _selectedSize == size;
                  
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _selectedSize = isSelected ? null : size;
                      });
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          size,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorTab() {
    return FadeIn(
      duration: const Duration(milliseconds: 300),
      child: Padding(
        padding: EdgeInsets.all(
          ResponsiveUtils.getHorizontalPadding(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            
            Text(
              'Colores disponibles',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            
            const SizedBox(height: 16),
            
            if (_availableColors.isEmpty)
              Center(
                child: Text(
                  'No hay colores disponibles',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _availableColors.map((color) {
                  final isSelected = _selectedColor == color;
                  
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _selectedColor = isSelected ? null : color;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: _getColorFromName(color),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            color,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTile({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    bool isSubcategory = false,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: isSubcategory ? 14 : 16,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
      trailing: isSelected
          ? Icon(
              IconlyBold.tick_square,
              color: AppColors.primary,
              size: 20,
            )
          : Icon(
              IconlyLight.tick_square,
              color: AppColors.border,
              size: 20,
            ),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildPriceInput({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '\${value.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPriceFilter(String label, double min, double max) {
    final isSelected = _minPrice == min && _maxPrice == max;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _minPrice = min;
          _maxPrice = max;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    final hasChanges = _hasFilterChanges();
    
    return Container(
      padding: EdgeInsets.all(
        ResponsiveUtils.getHorizontalPadding(context),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Results count
            Expanded(
              child: Text(
                '${widget.productProvider.totalProducts} productos',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            // Apply filters button
            CustomButton(
              text: hasChanges ? 'Aplicar filtros' : 'Ver productos',
              onPressed: _applyFilters,
              icon: IconlyLight.filter,
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
      default:
        return AppColors.primary;
    }
  }

  bool _hasFilterChanges() {
    final currentFilter = widget.productProvider.currentFilter;
    
    return _selectedCategoryId != currentFilter.categoryId ||
           _selectedSubcategory != currentFilter.subcategory ||
           _minPrice != (currentFilter.minPrice ?? 0) ||
           _maxPrice != (currentFilter.maxPrice ?? 1000) ||
           _selectedSize != currentFilter.size ||
           _selectedColor != currentFilter.color;
  }

  void _clearAllFilters() {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedCategoryId = null;
      _selectedSubcategory = null;
      _minPrice = 0;
      _maxPrice = 1000;
      _selectedSize = null;
      _selectedColor = null;
    });
  }

  void _applyFilters() {
    HapticFeedback.lightImpact();
    
    widget.productProvider.applyFilters(
      categoryId: _selectedCategoryId,
      subcategory: _selectedSubcategory,
      minPrice: _minPrice > 0 ? _minPrice : null,
      maxPrice: _maxPrice < 1000 ? _maxPrice : null,
      size: _selectedSize,
      color: _selectedColor,
    );
    
    Navigator.of(context).pop();
  }
}