// lib/main.dart - Actualizado con navegación completa
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prueba/presentation/pages/cart/cart_page.dart';
import 'package:prueba/presentation/pages/catalog/catalog_page.dart';
import 'package:prueba/presentation/providers/payment_provider.dart';
import 'package:provider/provider.dart';
import 'package:prueba/presentation/providers/product_provider.dart';

import 'core/constants/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/cart_provider.dart';

import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/auth/register_page.dart';
import 'presentation/pages/home/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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