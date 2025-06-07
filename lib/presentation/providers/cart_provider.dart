// lib/presentation/providers/cart_provider.dart
import 'package:flutter/foundation.dart';
import 'package:prueba/core/services/cart_service.dart';


// Modelo adaptado para trabajar con el backend
class CartItem {
  final String id;
  final String productId;
  final String name;
  final double price;
  final String image;
  final String size;
  final String color;
  int quantity;
  final String productoVariedadId; // ID que usa el backend

  CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.image,
    required this.size,
    required this.color,
    required this.quantity,
    required this.productoVariedadId,
  });

  double get totalPrice => price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'price': price,
      'image': image,
      'size': size,
      'color': color,
      'quantity': quantity,
      'productoVariedadId': productoVariedadId,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? json['productoVariedadId'],
      productId: json['productId'] ?? json['producto']?['id'] ?? '',
      name: json['name'] ?? json['producto']?['nombre'] ?? '',
      price: (json['price'] ?? json['variedad']?['precio'] ?? 0).toDouble(),
      image: json['image'] ?? '', // Se puede obtener de producto.images[0]
      size: json['size'] ?? json['variedad']?['talla'] ?? '',
      color: json['color'] ?? json['variedad']?['color'] ?? '',
      quantity: json['quantity'] ?? json['cantidad'] ?? 0,
      productoVariedadId: json['productoVariedadId'] ?? json['id'] ?? '',
    );
  }

  // Factory para crear desde respuesta del backend
  factory CartItem.fromBackendResponse(Map<String, dynamic> json) {
    return CartItem(
      id: json['productoVariedadId'] ?? '',
      productId: json['producto']?['id'] ?? '',
      name: json['producto']?['nombre'] ?? '',
      price: (json['variedad']?['precio'] ?? 0).toDouble(),
      image: '', // TODO: Obtener de producto.images si está disponible
      size: json['variedad']?['talla'] ?? '',
      color: json['variedad']?['color'] ?? '',
      quantity: json['cantidad'] ?? 0,
      productoVariedadId: json['productoVariedadId'] ?? '',
    );
  }
}

class CartProvider extends ChangeNotifier {
  final CarritoService _carritoService = CarritoService();
  
  final Map<String, CartItem> _items = {};
  bool _isLoading = false;
  String? _errorMessage;
  
  // Datos adicionales del backend
  Map<String, dynamic>? _backendCart;
  double _backendTotal = 0.0;
  int _backendItemCount = 0;

  // Getters existentes (mantienen compatibilidad)
  Map<String, CartItem> get items => {..._items};
  List<CartItem> get itemsList => _items.values.toList();
  int get itemCount => _backendItemCount > 0 ? _backendItemCount : _items.values.fold(0, (sum, item) => sum + item.quantity);
  int get uniqueItemCount => _items.length;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isEmpty => _items.isEmpty;

  double get totalAmount {
    return _backendTotal > 0 ? _backendTotal : _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double get subtotal => totalAmount;

  double get shipping {
    return totalAmount > 100 ? 0.0 : 10.0;
  }

  double get tax {
    return totalAmount * 0.15;
  }

  double get finalTotal => subtotal + shipping + tax;

  // NUEVOS MÉTODOS CONECTADOS AL BACKEND

  // Cargar carrito desde el backend
  Future<void> loadCart() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _carritoService.obtenerCarrito();
      _backendCart = response;
      
      // Actualizar datos del resumen
      final resumen = response['resumen'] ?? {};
      _backendTotal = (resumen['total'] as num?)?.toDouble() ?? 0.0;
      _backendItemCount = (resumen['totalItems'] as num?)?.toInt() ?? 0;
      
      // Convertir items del backend a nuestro modelo local
      _items.clear();
      final backendItems = response['items'] as List<dynamic>? ?? [];
      
      for (final item in backendItems) {
        final cartItem = CartItem.fromBackendResponse(item);
        final itemKey = '${cartItem.productId}_${cartItem.size}_${cartItem.color}';
        _items[itemKey] = cartItem;
      }
      
      notifyListeners();
    } on CartException catch (e) {
      _handleError(e.message);
    } catch (e) {
      _handleError('Error cargando carrito: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Agregar item conectado al backend
  Future<void> addItem({
    required String productId,
    required String name,
    required double price,
    required String image,
    required String size,
    required String color,
    required String productoVariedadId, // NUEVO: ID del backend
    int quantity = 1,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Llamar al backend
      await _carritoService.agregarAlCarrito(
        productoVariedadId: productoVariedadId,
        cantidad: quantity,
      );

      // Recargar carrito para obtener estado actualizado
      await loadCart();
      
    } on CartException catch (e) {
      _handleError(e.message);
      throw Exception(e.message);
    } catch (e) {
      _handleError('Error agregando al carrito: $e');
      throw e;
    } finally {
      _setLoading(false);
    }
  }

  // Método simplificado para mantener compatibilidad (sin productoVariedadId)
  Future<void> addItemLegacy({
    required String productId,
    required String name,
    required double price,
    required String image,
    required String size,
    required String color,
    int quantity = 1,
  }) async {
    // Este método mantiene la compatibilidad con tu código existente
    // pero necesitarás el productoVariedadId para conectar con el backend
    final productoVariedadId = '${productId}_${size}_${color}'; // Temporal
    
    await addItem(
      productId: productId,
      name: name,
      price: price,
      image: image,
      size: size,
      color: color,
      productoVariedadId: productoVariedadId,
      quantity: quantity,
    );
  }

  // Actualizar cantidad conectado al backend
  Future<void> updateQuantity(String itemId, int newQuantity) async {
    if (newQuantity <= 0) {
      await removeItem(itemId);
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      final item = _items[itemId];
      if (item == null) {
        throw Exception('Item no encontrado en el carrito');
      }

      // Llamar al backend
      await _carritoService.actualizarCantidad(
        productoVariedadId: item.productoVariedadId,
        cantidad: newQuantity,
      );

      // Recargar carrito
      await loadCart();
      
    } on CartException catch (e) {
      _handleError(e.message);
      throw Exception(e.message);
    } catch (e) {
      _handleError('Error actualizando cantidad: $e');
      throw e;
    } finally {
      _setLoading(false);
    }
  }

  // Remover item conectado al backend
  Future<void> removeItem(String itemId) async {
    _setLoading(true);
    _clearError();

    try {
      final item = _items[itemId];
      if (item == null) {
        throw Exception('Item no encontrado en el carrito');
      }

      // Llamar al backend
      await _carritoService.removerProducto(
        productoVariedadId: item.productoVariedadId,
      );

      // Recargar carrito
      await loadCart();
      
    } on CartException catch (e) {
      _handleError(e.message);
      throw Exception(e.message);
    } catch (e) {
      _handleError('Error removiendo item: $e');
      throw e;
    } finally {
      _setLoading(false);
    }
  }

  // Vaciar carrito conectado al backend
  Future<void> clearCart() async {
    _setLoading(true);
    _clearError();

    try {
      // Llamar al backend
      await _carritoService.vaciarCarrito();

      // Limpiar estado local
      _items.clear();
      _backendCart = null;
      _backendTotal = 0.0;
      _backendItemCount = 0;
      
      notifyListeners();
      
    } on CartException catch (e) {
      _handleError(e.message);
      throw Exception(e.message);
    } catch (e) {
      _handleError('Error vaciando carrito: $e');
      throw e;
    } finally {
      _setLoading(false);
    }
  }


  // Obtener item específico
  CartItem? getItem(String itemId) {
    return _items[itemId];
  }

  // Verificar si producto existe en carrito
  bool containsProduct(String productId, String size, String color) {
    final itemKey = '${productId}_${size}_${color}';
    return _items.containsKey(itemKey);
  }

  // Verificar por productoVariedadId (NUEVO)
  bool containsProductVariant(String productoVariedadId) {
    return _items.values.any((item) => item.productoVariedadId == productoVariedadId);
  }

  // Obtener cantidad de producto específico
  int getProductQuantity(String productId, String size, String color) {
    final itemKey = '${productId}_${size}_${color}';
    return _items[itemKey]?.quantity ?? 0;
  }

  // Obtener cantidad por productoVariedadId (NUEVO)
  int getProductVariantQuantity(String productoVariedadId) {
    final item = _items.values.firstWhere(
      (item) => item.productoVariedadId == productoVariedadId,
      orElse: () => CartItem(
        id: '',
        productId: '',
        name: '',
        price: 0,
        image: '',
        size: '',
        color: '',
        quantity: 0,
        productoVariedadId: '',
      ),
    );
    return item.quantity;
  }

  // Cargar solo contador de items (para badges)
  Future<void> loadItemCount() async {
    try {
      _backendItemCount = await _carritoService.contarItems();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading item count: $e');
    }
  }

  // Sincronizar carrito (refrescar desde backend)
  Future<void> syncCart() async {
    await loadCart();
  }

  // MÉTODOS HELPER EXISTENTES

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _handleError(dynamic error) {
    _errorMessage = error.toString();
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  bool canCheckout() {
    return _items.isNotEmpty && !_isLoading;
  }

  String getCartSummary() {
    if (_items.isEmpty) return 'Carrito vacío';
    
    final totalItems = itemCount;
    final total = totalAmount;
    
    return '$totalItems ${totalItems == 1 ? 'artículo' : 'artículos'} • \${total.toStringAsFixed(2)}';
  }

  // Limpiar estado al cerrar sesión
  void clearState() {
    _items.clear();
    _backendCart = null;
    _backendTotal = 0.0;
    _backendItemCount = 0;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  // MÉTODOS PARA TESTING/DESARROLLO

  void addMockItems() {
    // Mantener para desarrollo, pero ahora carga desde backend
    loadCart();
  }

  // Método para debugging
  void printCartState() {
    debugPrint('=== CART STATE ===');
    debugPrint('Local items: ${_items.length}');
    debugPrint('Backend total: $_backendTotal');
    debugPrint('Backend item count: $_backendItemCount');
    debugPrint('Items: ${_items.keys.toList()}');
    debugPrint('==================');
  }
}