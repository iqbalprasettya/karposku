import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
import 'package:karposku/consts/mki_colors.dart';
import 'package:karposku/consts/mki_colorsv2.dart';
import 'package:karposku/consts/mki_styles.dart';
import 'package:karposku/consts/mki_urls.dart';
import 'package:karposku/screens/about_screen.dart';
import 'package:karposku/screens/navigation_screen.dart';
import 'package:karposku/screens/printers/printer_list_screen.dart';
import 'package:karposku/screens/cart_screen.dart';
import 'package:karposku/screens/invoice_list_screen.dart';
import 'package:karposku/screens/profile_screen.dart';
import 'package:karposku/screens/packing_screen.dart';
// import 'package:karposku/consts/mki_styles.dart';
// import 'package:karposku/consts/mki_variabels.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static String routeName = 'home-screen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String profilePath = '';

  Future<void> setImgPath() async {
    try {
      final path = await MKIUrls.profileImage();
      setState(() {
        profilePath =
            path.isNotEmpty ? path : 'https://via.placeholder.com/150';
      });
    } catch (e) {
      setState(() {
        profilePath = 'https://via.placeholder.com/150';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    setImgPath();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: BoxDecoration(
          color: MKIColorConstv2.neutral200,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              Container(
                padding: EdgeInsets.only(top: 50, bottom: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      MKIColorConstv2.secondaryDark,
                      MKIColorConstv2.secondary.withOpacity(0.95),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Halo, Iqbal Prasetya!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: MKIColorConstv2.neutral100,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined,
                                  size: 16, color: MKIColorConstv2.neutral300),
                              Text(
                                'Cabang Depok',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: MKIColorConstv2.neutral300,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: MKIColorConstv2.secondary,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 25,
                          backgroundColor: MKIColorConstv2.neutral100,
                          child: profilePath.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    profilePath,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.person,
                                        size: 30,
                                        color: MKIColorConstv2.neutral400,
                                      );
                                    },
                                  ),
                                )
                              : Icon(
                                  Icons.person,
                                  size: 30,
                                  color: MKIColorConstv2.neutral400,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Pendapatan card
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        MKIColorConstv2.primary,
                        MKIColorConstv2.primaryLight,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: MKIColorConstv2.primary.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: MKIColorConstv2.neutral100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.account_balance_wallet,
                              color: MKIColorConstv2.primary,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Pendapatan Hari ini',
                            style: TextStyle(
                              color: MKIColorConstv2.neutral100,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Rp. 3,650,000',
                        style: TextStyle(
                          color: MKIColorConstv2.neutral100,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Menu Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildMenuItem('Packing', Icons.inventory_2_rounded, () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PackingScreen()));
                    }, iconColor: MKIColorConstv2.secondary),
                    _buildMenuItem('Printer', Icons.print_outlined, () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PrinterListScreen()));
                    }, iconColor: MKIColorConstv2.secondary),
                    _buildMenuItem('Keranjang', Icons.shopping_cart_rounded,
                        () {
                      NavigationScreen.startIndex = 2;
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NavigationScreen()));
                    }, iconColor: MKIColorConstv2.secondary),
                    _buildMenuItem('Items', Icons.list_alt_rounded, () {
                      NavigationScreen.startIndex = 1;
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NavigationScreen()));
                    }, iconColor: MKIColorConstv2.secondary),
                    _buildMenuItem('Laporan', Icons.analytics_rounded, () {
                      NavigationScreen.startIndex = 3;
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NavigationScreen()));
                    }, iconColor: MKIColorConstv2.secondary),
                    _buildMenuItem('Profile', Icons.person_rounded, () {
                      NavigationScreen.startIndex = 4;
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NavigationScreen()));
                    }, iconColor: MKIColorConstv2.secondary),
                    _buildMenuItem('About', Icons.info_rounded, () {
                      Navigator.push(
                          context, // Untuk About tetap push biasa karena bukan bagian dari bottom nav
                          MaterialPageRoute(
                              builder: (context) => const LogoAboutScreen()));
                    }, iconColor: MKIColorConstv2.secondary),
                    _buildMenuItem('Lainnya', Icons.grid_view_rounded, () {
                      _showComingSoonDialog();
                    }, iconColor: MKIColorConstv2.secondary),
                  ],
                ),
              ),

              // Riwayat Pembelian section
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Riwayat Pembelian',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: MKIColorConstv2.primary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'Lihat Semua',
                            style: TextStyle(
                              color: MKIColorConstv2.primaryLight,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    _buildRiwayatItem(
                      'INV20250101082',
                      'Galon, tap Mobil, Sabun',
                      '21,000',
                    ),
                    _buildRiwayatItem(
                      'INV20250232144',
                      'Rokok, Permen, Gas 3kg, Beras',
                      '340,000',
                    ),
                    _buildRiwayatItem(
                      'INV20232123519',
                      'Indomie, Tepung, Gas 3kg',
                      '178,500',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap,
      {Color? iconColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (iconColor ?? MKIColorConstv2.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 26,
              color: iconColor ?? MKIColorConstv2.primary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: MKIColorConstv2.secondaryDark,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatItem(String invNo, String items, String amount) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MKIColorConstv2.neutral100,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: MKIColorConstv2.neutral200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: MKIColorConstv2.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              color: MKIColorConstv2.neutral100,
              size: 20,
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invNo,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: MKIColorConstv2.secondaryDark,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  items,
                  style: TextStyle(
                    color: MKIColorConstv2.neutral500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+ Rp. $amount',
            style: TextStyle(
              color: MKIColorConstv2.primaryLight,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(
                Icons.access_time,
                color: MKIColorConstv2.secondary,
              ),
              SizedBox(width: 10),
              Text(
                'Segera Hadir!',
                style: TextStyle(
                  color: MKIColorConstv2.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Fitur ini sedang dalam pengembangan dan akan segera hadir untuk Anda.',
            style: TextStyle(
              color: MKIColorConstv2.neutral500,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Tutup',
                style: TextStyle(
                  color: MKIColorConstv2.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
