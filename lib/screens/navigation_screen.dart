import 'package:flutter/material.dart';
import 'package:karposku/consts/mki_colors.dart';
import 'package:karposku/consts/mki_colorsv2.dart';
import 'package:karposku/screens/cart_screen.dart';
import 'package:karposku/screens/home_screen.dart';
import 'package:karposku/screens/items_list_screen.dart';
import 'package:karposku/screens/profile_screen.dart';
import 'package:karposku/screens/sales_screen.dart';
import 'package:karposku/screens/packing_screen.dart';
import 'package:karposku/consts/mki_urls.dart';
import 'package:karposku/screens/invoice_packing_screen.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({
    super.key,
  });

  static const routeName = 'navigation-screen';
  static int startIndex = 0;

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  late int _selectedIndex;
  Map<String, dynamic> navigationData = {
    'data': [] // Inisialisasi kosong
  };
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedIndex = NavigationScreen.startIndex;
    _loadNavigation();
  }

  Future<void> _loadNavigation() async {
    try {
      final response = await MKIUrls.getNavigation();
      if (response['status'] == 'success') {
        setState(() {
          navigationData = {'items': response['data']};
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error mengambil data navigasi: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Modifikasi _tabs untuk menggunakan data dari API
  List<Widget> get _tabs {
    final activeItems = (navigationData['items'] as List? ?? []);

    return activeItems.map((item) {
      switch (item['route']) {
        case 'home':
          return const HomeScreen();
        case 'items':
          return const ItemListScreen();
        case 'packing':
          return const PackingScreen();
        case 'cart':
          return const CartScreen(title: 'Cart');
        case 'sales':
          return const SalesScreen(title: 'Sales');
        case 'profile':
          return const ProfileScreen();
        case 'invoice-packing':
          return const InvoicePackingScreen();
        default:
          return const SizedBox();
      }
    }).toList();
  }

  IconData _getIcon(String iconName, bool filled) {
    switch (iconName) {
      case 'home':
        return filled ? Icons.home : Icons.home_outlined;
      case 'list':
        return filled ? Icons.list : Icons.list_outlined;
      case 'inventory_2':
        return filled ? Icons.inventory_2 : Icons.inventory_2_outlined;
      case 'shopping_cart':
        return filled ? Icons.shopping_cart : Icons.shopping_cart_outlined;
      case 'analytics':
        return filled ? Icons.analytics : Icons.analytics_outlined;
      case 'person':
        return filled ? Icons.person : Icons.person_outline;
      case 'receipt_long':
        return filled ? Icons.receipt_long : Icons.receipt_long_outlined;
      default:
        return filled ? Icons.circle : Icons.circle_outlined;
    }
  }

  int get _floatingIndex {
    final activeItems = (navigationData['items'] as List? ?? []);
    return activeItems.indexWhere((item) => item['is_floating'] == 1);
  }

  List<BottomNavigationBarItem> _buildNavigationItems() {
    final activeItems = (navigationData['items'] as List? ?? []);

    return activeItems.map((item) {
      final index = activeItems.indexOf(item);
      final isFloating = _floatingIndex >= 0 && _floatingIndex == index;

      return BottomNavigationBarItem(
        icon: isFloating
            ? const SizedBox(height: 24)
            : Icon(_getIcon(item['icon_name'], false)),
        activeIcon: isFloating
            ? const SizedBox(height: 24)
            : Icon(_getIcon(item['icon_name'], true)),
        label: item['title'],
      );
    }).toList();
  }

  Widget? _buildFloatingButton() {
    if (_floatingIndex < 0) return null;

    final activeItems = (navigationData['items'] as List? ?? []);
    if (activeItems.isEmpty) return null;

    try {
      final floatingItem = activeItems[_floatingIndex];

      // Hitung posisi horizontal berdasarkan index
      final screenWidth = MediaQuery.of(context).size.width;
      final itemWidth = screenWidth / activeItems.length;
      final centerPosition = (_floatingIndex * itemWidth) + (itemWidth / 2);

      return Positioned(
        left: centerPosition - 30,
        top: -25,
        child: GestureDetector(
          onTap: () => setState(() => _selectedIndex = _floatingIndex),
          child: Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: MKIColorConstv2.primary,
              boxShadow: [
                BoxShadow(
                  color: MKIColorConstv2.primary.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              _getIcon(
                floatingItem['icon_name'],
                _selectedIndex == _floatingIndex,
              ),
              size: 32,
              color: Colors.white,
            ),
          ),
        ),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: _tabs[_selectedIndex],
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: (index) => setState(() => _selectedIndex = index),
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedItemColor: MKIColorConstv2.primary,
                unselectedItemColor: MKIColorConstv2.neutral500,
                selectedFontSize: 12,
                unselectedFontSize: 12,
                iconSize: 24,
                showSelectedLabels: true,
                showUnselectedLabels: true,
                items: _buildNavigationItems(),
              ),
            ),
          ),
          if (_floatingIndex >= 0) _buildFloatingButton() ?? const SizedBox(),
        ],
      ),
    );
  }
}
