import 'package:flutter/material.dart';
import 'package:karposku/consts/mki_colors.dart';
import 'package:karposku/consts/mki_colorsv2.dart';
import 'package:karposku/screens/cart_screen.dart';
import 'package:karposku/screens/home_screen.dart';
import 'package:karposku/screens/items_list_screen.dart';
import 'package:karposku/screens/profile_screen.dart';
import 'package:karposku/screens/sales_screen.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({
    super.key,
  });

  // final String title;
  static const routeName = 'navigation-screen';
  static int startIndex = 0;

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  late int _selectedIndex;
  final List<Widget> _tabs = const [
    HomeScreen(),
    ItemListScreen(),
    CartScreen(title: 'Cart'),
    SalesScreen(title: 'Sales'),
    // LogoAboutScreen(),
    ProfileScreen(),
  ];
  // int _selectedIndex = 0;
  final Color _selectIconColor = Colors.white;
  final Color _unSelecIconColor = Colors.black;
  // final Color _selectLabelColor = Colors.white;
  // final Color _unSelecLabelColor = Colors.black;

  @override
  void initState() {
    super.initState();
    _selectedIndex = NavigationScreen.startIndex;
  }

  @override
  Widget build(BuildContext context) {
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
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.list_outlined),
                    activeIcon: Icon(Icons.list),
                    label: 'Items',
                  ),
                  BottomNavigationBarItem(
                    icon: SizedBox(height: 24),
                    label: 'Cart',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.analytics_outlined),
                    activeIcon: Icon(Icons.analytics),
                    label: 'Sales',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    activeIcon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: -25,
            child: GestureDetector(
              onTap: () => setState(() => _selectedIndex = 2),
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
                  _selectedIndex == 2
                      ? Icons.shopping_cart
                      : Icons.shopping_cart_outlined,
                  size: 32,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
