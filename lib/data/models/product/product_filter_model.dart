class ProductFilterModel {
  final String? categoryId;
  final String? subcategory;
  final String? search;
  final double? minPrice;
  final double? maxPrice;
  final String? size;
  final String? color;
  final String orderBy;
  final String orderDirection;
  final int page;
  final int limit;

  ProductFilterModel({
    this.categoryId,
    this.subcategory,
    this.search,
    this.minPrice,
    this.maxPrice,
    this.size,
    this.color,
    this.orderBy = 'name',
    this.orderDirection = 'ASC',
    this.page = 1,
    this.limit = 20,
  });

  ProductFilterModel copyWith({
    String? categoryId,
    String? subcategory,
    String? search,
    double? minPrice,
    double? maxPrice,
    String? size,
    String? color,
    String? orderBy,
    String? orderDirection,
    int? page,
    int? limit,
  }) {
    return ProductFilterModel(
      categoryId: categoryId ?? this.categoryId,
      subcategory: subcategory ?? this.subcategory,
      search: search ?? this.search,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      size: size ?? this.size,
      color: color ?? this.color,
      orderBy: orderBy ?? this.orderBy,
      orderDirection: orderDirection ?? this.orderDirection,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }

  Map<String, dynamic> toQueryParams() {
    final params = <String, String>{};
    
    if (categoryId != null) params['categoryId'] = categoryId!;
    if (subcategory != null) params['subcategory'] = subcategory!;
    if (search != null) params['search'] = search!;
    if (minPrice != null) params['minPrice'] = minPrice.toString();
    if (maxPrice != null) params['maxPrice'] = maxPrice.toString();
    if (size != null) params['size'] = size!;
    if (color != null) params['color'] = color!;
    params['orderBy'] = orderBy;
    params['orderDirection'] = orderDirection;
    params['page'] = page.toString();
    params['limit'] = limit.toString();
    
    return params;
  }

  bool get hasFilters {
    return categoryId != null ||
           subcategory != null ||
           search != null ||
           minPrice != null ||
           maxPrice != null ||
           size != null ||
           color != null;
  }

  String get filterSummary {
    final filters = <String>[];
    
    if (categoryId != null) filters.add('Categoría');
    if (subcategory != null) filters.add('Subcategoría');
    if (search != null) filters.add('Búsqueda');
    if (minPrice != null || maxPrice != null) filters.add('Precio');
    if (size != null) filters.add('Talla');
    if (color != null) filters.add('Color');
    
    if (filters.isEmpty) return 'Sin filtros';
    return filters.join(', ');
  }
}