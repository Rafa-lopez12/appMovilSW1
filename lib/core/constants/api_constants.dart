// lib/core/constants/api_constants.dart
class ApiConstants {
  ApiConstants._();

  // Base Configuration
  static const String baseUrl = 'http://10.0.2.2:3000/api'; // CAMBIAR por tu IP
  static const String tenantId = 'tienda-abc'; // CAMBIAR por tu tenant ID
  
  // Timeout configurations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Auth Endpoints
  static const String authBase = '/cliente-auth';
  static const String login = '$authBase/login';
  static const String register = '$authBase/register';
  static const String profile = '$authBase/profile';
  static const String checkStatus = '$authBase/check-status';
  
  // Product Endpoints
  static const String productBase = '/producto';
  static const String products = '$productBase/tienda/findAll';
  static const String productDetail = '$productBase/tienda'; // + /{id}

  
  
  // Category Endpoints
  static const String categoryBase = '/categoria';
  static const String categories = '$categoryBase/findAll';
  
  // Cart Endpoints
  static const String cartBase = '/carrito';
  static const String cartAdd = '$cartBase/agregar';
  static const String cartGet = '$cartBase';
  static const String cartUpdate = '$cartBase/cantidad'; // + /{id}
  static const String cartRemove = '$cartBase/producto'; // + /{id}
  static const String cartClear = '$cartBase/vaciar';
  static const String cartCount = '$cartBase/contador';
  
  // AI Search Endpoints
  static const String aiSearchBase = '/ai-search';
  static const String aiSearchByImage = '$aiSearchBase/search-by-image';
  static const String aiSearchByUrl = '$aiSearchBase/search-by-url';
  
  // Virtual Try-on Endpoints
  static const String virtualTryonBase = '/virtual-tryon';
  static const String tryonUpload = '$virtualTryonBase/upload-and-create';
  static const String tryonBase64 = '$virtualTryonBase/create-from-base64';
  static const String tryonSession = '$virtualTryonBase/session'; // + /{id}
  static const String tryonHistory = '$virtualTryonBase/my-sessions';
  
  // Payment Endpoints
  static const String stripeBase = '/stripe';
  static const String createPaymentIntent = '$stripeBase/create-payment-intent';
  static const String createPaymentFromCart = '$stripeBase/create-payment-from-cart';
  static const String confirmPayment = '$stripeBase/confirm-payment';
  static const String myPayments = '$stripeBase/my-payments';
  
  // Order Endpoints
  static const String ventaBase = '/venta';
  static const String createOrder = '$ventaBase/comprar';
  static const String myOrders = '$ventaBase/mis-compras';
  static const String orderDetail = '$ventaBase/mi-compra'; // + /{id}
  
  // Size Endpoints
  static const String sizeBase = '/size';
  static const String sizes = '$sizeBase';
  
  // Headers
  static const String contentTypeJson = 'application/json';
  static const String headerContentType = 'Content-Type';
  static const String headerAuthorization = 'Authorization';
  static const String headerTenantId = 'X-Tenant-ID';
  
  // Status Codes
  static const int statusOk = 200;
  static const int statusCreated = 201;
  static const int statusBadRequest = 400;
  static const int statusUnauthorized = 401;
  static const int statusForbidden = 403;
  static const int statusNotFound = 404;
  static const int statusInternalServerError = 500;
}

// Configuración de entorno
class Environment {
  static const String dev = 'development';
  static const String prod = 'production';
  
  // Cambiar según el entorno
  static const String current = dev;
  
  static bool get isDevelopment => current == dev;
  static bool get isProduction => current == prod;
}

// URLs de imágenes placeholder
class ImageConstants {
  static const String placeholder = 'https://via.placeholder.com/300x300?text=Producto';
  static const String avatarPlaceholder = 'https://via.placeholder.com/100x100?text=Usuario';
  static const String logoUrl = 'https://via.placeholder.com/200x80?text=TiendaVirtual';
}