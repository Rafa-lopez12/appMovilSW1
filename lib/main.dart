// lib/main.dart - Actualizado con navegación completa
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:prueba/presentation/pages/ai_search/ai_results_page.dart';
import 'package:prueba/presentation/pages/ai_search/ai_search_page.dart';
import 'package:prueba/presentation/pages/cart/cart_page.dart';
import 'package:prueba/presentation/pages/cart/checkout_page.dart';
import 'package:prueba/presentation/pages/catalog/catalog_page.dart';
import 'package:prueba/presentation/pages/payment/payment_page.dart';
import 'package:prueba/presentation/pages/payment/payment_success_page.dart';
import 'package:prueba/presentation/pages/virtual_tryon/virtual_tryon_page.dart';
import 'package:prueba/presentation/providers/ai_search_provider.dart';
import 'package:prueba/presentation/providers/payment_provider.dart';
import 'package:provider/provider.dart';
import 'package:prueba/presentation/providers/product_provider.dart';
import 'package:prueba/presentation/providers/virtual_tryon_provider.dart';

import 'core/constants/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/cart_provider.dart';

import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/auth/register_page.dart';
import 'presentation/pages/home/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Global Flutter Error: ${details.exception}');
    debugPrint('Stack trace: ${details.stack}');
  };
    try {
    await _initializeStripe();
    debugPrint('✅ Stripe initialized successfully');
  } catch (e) {
    debugPrint('❌ Error initializing Stripe: $e');
    // La app puede continuar sin Stripe en modo de depuración
  }
  
  // Configurar la barra de estado
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Configurar orientaciones permitidas
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const TiendaVirtualApp());
}

Future<void> _initializeStripe() async {
  try {
    // IMPORTANTE: Esta debe ser tu clave PÚBLICA (pk_test_...), no la secreta (sk_...)
    const String stripePublishableKey = 'pk_test_51RTUBMHIj82SmGbDobq1uVtN5RTTtJbmY81CiBDmxgDzIEDe1QB7NooKByfJnQGL3uUTKPiVkYxNeCcBID4vua9R00lSQRU395';
    
    Stripe.publishableKey = stripePublishableKey;
    
    // ✅ VERIFICAR QUE STRIPE SE INICIALIZÓ CORRECTAMENTE
    debugPrint('Stripe publishable key set: ${stripePublishableKey.substring(0, 12)}...');
    await Stripe.instance.applySettings();
    
  } catch (e) {
    debugPrint('Error in Stripe initialization: $e');
    rethrow;
  }
}

class TiendaVirtualApp extends StatelessWidget {
  const TiendaVirtualApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Provider
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
        ),
        
        // Cart Provider
        ChangeNotifierProvider(
          create: (context) => CartProvider(),
        ),
        
        ChangeNotifierProvider(
          create: (context) => ProductProvider(),
        ),

        ChangeNotifierProvider(
          create: (context) => PaymentProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => AiSearchProvider()),

        ChangeNotifierProvider(
          create: (context) => VirtualTryonProvider(),
        ),
        
        // Aquí irán más providers cuando los necesites:
        // ChangeNotifierProvider(create: (context) => ProductProvider()),
        // ChangeNotifierProvider(create: (context) => OrderProvider()),
        // ChangeNotifierProvider(create: (context) => AISearchProvider()),
        // ChangeNotifierProvider(create: (context) => VirtualTryonProvider()),
        // etc...
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp(
            title: 'Tienda Virtual',
            debugShowCheckedModeBanner: false,
            
            // Tema de la aplicación
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light, // Por ahora solo modo claro
            
            // Configuración de localización
            locale: const Locale('es', 'ES'),
            
            // Rutas de la aplicación
            initialRoute: '/login', // Cambiar a '/splash' cuando esté listo
            routes: {
              '/login': (context) => const LoginPage(),
              '/register': (context) => const RegisterPage(),
              '/main': (context) => const MainPage(),
              '/catalog': (context) => const CatalogPage(),
              '/cart': (context) => const CartPage(),     
              '/ai-search': (context) => const AISearchPage(),
              '/ai-search-results': (context) => const AIResultsPage(),       
              '/checkout': (context) {
                final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
                return CheckoutPage(
                  cartItems: args?['cartItems'] as List<dynamic>? ?? [],
                  totalAmount: args?['totalAmount'] as double? ?? 0.0,
                );
              },
              
              // ✅ RUTA PAYMENT CORREGIDA  
              '/payment': (context) {
                final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
                return PaymentPage(
                  totalAmount: args?['totalAmount'] as double? ?? 0.0,
                  cartItems: args?['cartItems'] as List<dynamic>? ?? [],
                );
              },
              
              // ✅ RUTA PAYMENT SUCCESS CORREGIDA
              '/payment-success': (context) {
                final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
                return PaymentSuccessPage(
                  orderId: args?['orderId'] as String? ?? 'N/A',
                  amount: args?['amount'] as double? ?? 0.0,
                  paymentMethod: args?['paymentMethod'] as String? ?? 'Stripe',
                );
              },

              '/virtual-tryon': (context) {
              final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
              return VirtualTryonPage(
                productId: args?['productId'] as String?,
                productImageUrl: args?['productImageUrl'] as String?,
              );
            },

              // Rutas adicionales se agregarán aquí
            },
            
            // Manejo de rutas desconocidas
            onUnknownRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => const LoginPage(),
              );
            },
            
            // Builder para configuraciones globales
            builder: (context, child) {
              return GestureDetector(
                // Ocultar teclado al tocar fuera de un campo de texto
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: child,
              );
            },
          );
        },
      ),
    );
  }
}