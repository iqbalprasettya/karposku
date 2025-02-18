import 'package:flutter/material.dart';
import 'package:karposku/consts/mki_colors.dart';
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
      // appBar: AppBar(
      //   title: Text(widget.title),
      // ),
      body: _tabs[_selectedIndex],
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.all(
            TextStyle(
              // fontSize: 12.0,
              fontWeight: FontWeight.bold,
              color: MKIColorConst.mainBlue,
            ),
          ),
        ),
        child: NavigationBar(
          // backgroundColor: Colors.grey.withOpacity(0.1),
          shadowColor: MKIColorConst.mainOrange,
          // labelBehavior:,
          indicatorShape: const BeveledRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(13),
            ),
          ),
          elevation: 0,
          // type: BottomNavigationBarType.fixed,
          // selectedItemColor: Colors.black,
          // unselectedItemColor: Colors.grey.shade500,
          // selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
          indicatorColor: MKIColorConst.mkiSeaBlue,
          selectedIndex: _selectedIndex,
          destinations: [
            NavigationDestination(
              icon: Icon(
                Icons.home,
                color:
                    _selectedIndex == 0 ? _selectIconColor : _unSelecIconColor,
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.list,
                color:
                    _selectedIndex == 1 ? _selectIconColor : _unSelecIconColor,
              ),
              label: 'Items',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.shopping_cart,
                color:
                    _selectedIndex == 2 ? _selectIconColor : _unSelecIconColor,
              ),
              label: 'Cart',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.money_sharp,
                color:
                    _selectedIndex == 3 ? _selectIconColor : _unSelecIconColor,
              ),
              label: 'Sales',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.person,
                color:
                    _selectedIndex == 4 ? _selectIconColor : _unSelecIconColor,
              ),
              label: 'Profile',
            ),
          ],
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
              // _selectIconColor = Colors.white;
              // print(_selectedIndex);
            });
          },
        ),
      ),
    );
  }
}
