// lib/presentation/pages/home/main_page.dart - SOLO LA PARTE QUE CAMBIA

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prueba/presentation/pages/cart/cart_page.dart';
import 'package:prueba/presentation/pages/profile/profile_page.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/common/custom_bottom_nav_bar.dart';
import 'home_page.dart';
import '../catalog/catalog_page.dart';
import '../ai_search/ai_search_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

 
  final List<Widget> _pages = [
    const HomePage(),
    const CatalogPage(),      
    const AISearchPage(),  
    const CartPage(),
    const ProfilePage(),      
  ];

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onNavBarTapped(int index) {
    HapticFeedback.lightImpact();
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onNavBarTapped,
      ),
    );
  }
}