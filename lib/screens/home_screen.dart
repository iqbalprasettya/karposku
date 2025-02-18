import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
import 'package:karposku/consts/mki_colors.dart';
import 'package:karposku/consts/mki_styles.dart';
import 'package:karposku/consts/mki_urls.dart';
import 'package:karposku/screens/about_screen.dart';
import 'package:karposku/screens/navigation_screen.dart';
import 'package:karposku/screens/printers/printer_list_screen.dart';
// import 'package:karposku/consts/mki_styles.dart';
// import 'package:karposku/consts/mki_variabels.dart';

String profilePath = '';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static String routeName = 'home-screen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void setImgPath() async {
    profilePath = await MKIUrls.profileImage();
    // print("Profile : " + profilePath);
    // setState(() {});
  }

  @override
  void initState() {
    super.initState();
    setImgPath();
  }

  @override
  Widget build(BuildContext context) {
    double screeenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    var screenOrientation = MediaQuery.of(context).orientation;

    return SizedBox(
      width: screeenWidth,
      height: screenHeight,
      // height: screenHeight * 0.32,
      // color: Colors.amber,
      child: Stack(
        children: [
          /* Top Bar */
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: screeenWidth,
              height: screenHeight * 0.32,
              decoration: BoxDecoration(
                gradient: MKIColorConst.mainGoldBlueAppBarAlt,
                // color: Colors.blueGrey,
                borderRadius: const BorderRadius.only(
                    // topLeft: Radius.circular(40),
                    // topRight: Radius.circular(40),
                    ),
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.07,
            left: screenHeight * 0.02,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(60),
                color: Colors.transparent,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: profilePath.trim() != ""
                    ? Image.network(
                        profilePath,
                      )
                    : Icon(
                        Icons.person,
                        color: MKIColorConst.mkiSilver,
                        size: 60,
                      ),
              ),
            ),
          ),
          /* Container For Style */
          Positioned(
            top: screenHeight * 0.27,
            left: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              width: screeenWidth,
              height: screenHeight * 0.05,
            ),
          ),
          /* Title */
          Positioned(
            top: screenHeight * 0.13,
            left: 0,
            child: SizedBox(
              width: screeenWidth,
              child: Center(
                child: Text(
                  'HOME',
                  style: TextStyle(
                    fontSize: 22,
                    color: MKIColorConst.mainBlue,
                  ),
                ),
              ),
            ),
          ),
          /* Icons Menu */
          Positioned(
            top: screenHeight * 0.04,
            child: SizedBox(
              width: screeenWidth,
              height: screenOrientation == Orientation.portrait
                  ? screenHeight * 0.58
                  : screenHeight * 0.6,
              // color: Colors.amber,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    child: MKIStyles.homeMenu(
                        context, "assets/images/icons/profile.png", "Profile"),
                    onTap: () {
                      Future.delayed(
                        Duration.zero,
                        (() async {
                          NavigationScreen.startIndex = 4;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NavigationScreen(),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                  MKIStyles.homeMenu(context,
                      "assets/images/icons/attendance.png", "Atendance"),
                  GestureDetector(
                    child: MKIStyles.homeMenu(
                        context, "assets/images/icons/about.png", "About"),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LogoAboutScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: screenOrientation == Orientation.portrait
                ? screenHeight * 0.22
                : screenHeight * 0.33,
            child: SizedBox(
              width: screeenWidth,
              height: screenHeight * 0.58,
              // color: Colors.amber,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    child: MKIStyles.homeMenu(
                        context, "assets/images/icons/cart.png", "Cart"),
                    onTap: () {
                      Future.delayed(
                        Duration.zero,
                        (() async {
                          NavigationScreen.startIndex = 2;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NavigationScreen(),
                            ),
                          );
                          // Navigator.pushReplacement(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => CartScreen(
                          //       title: 'CART',
                          //     ),
                          //   ),
                          // );
                        }),
                      );
                    },
                  ),
                  GestureDetector(
                    child: MKIStyles.homeMenu(
                        context, "assets/images/icons/print.png", "Printer"),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              const PrinterListScreen(),
                        ),
                      );
                    },
                  ),
                  GestureDetector(
                    child: MKIStyles.homeMenu(
                      context,
                      "assets/images/icons/report.png",
                      "Report",
                    ),
                    onTap: () {
                      Future.delayed(
                        Duration.zero,
                        (() async {
                          NavigationScreen.startIndex = 3;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NavigationScreen(),
                            ),
                          );
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => CartScreen(
                          //       title: 'Cart O',
                          //     ),
                          //   ),
                          // );
                        }),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    // return Scaffold(
    //   appBar: AppBar(
    //       centerTitle: true,
    //       title: Padding(
    //         padding: const EdgeInsets.only(bottom: 10),
    //         child: Text(
    //           'HOME',
    //           style: TextStyle(color: MKIColorConst.mainBlue),
    //         ),
    //       ),
    //       // backgroundColor: MKIColorConst.mainToscaBlue,
    //       flexibleSpace: Stack(
    //         children: [
    //           Container(
    //             // height: screenHeight * 0.7,
    //             decoration: BoxDecoration(
    //               gradient: MKIColorConst.mainGoldBlueAppBar,
    //             ),
    //           ),
    //           Positioned(
    //             top: 95,
    //             child: Container(
    //               decoration: const BoxDecoration(
    //                 color: Colors.white,
    //                 borderRadius: BorderRadius.only(
    //                   topLeft: Radius.circular(15),
    //                   topRight: Radius.circular(15),
    //                 ),
    //               ),
    //               width: screeenWidth,
    //               height: 20,
    //             ),
    //           ),
    //         ],
    //       )),
    //   body: Container(
    //     margin: const EdgeInsets.only(top: 10),
    //     padding: const EdgeInsets.all(10),
    //     child: SingleChildScrollView(
    //       child: Column(
    //         children: [
    //           const Text(
    //             'WE PROVIDE YOUR NEEDS',
    //             style: TextStyle(fontSize: 22),
    //           ),
    //           Row(
    //             mainAxisAlignment: MainAxisAlignment.spaceAround,
    //             children: [
    //               Container(
    //                 height: screenHeight * 0.17,
    //                 width: screeenWidth * 0.3,
    //                 color: Colors.yellowAccent,
    //                 child: Column(
    //                   children: [
    //                     Container(
    //                       height: screenHeight * 0.11,
    //                       color: MKIColorConst.mkiGoldMid,
    //                       child: const Center(
    //                         child: Text('Image'),
    //                       ),
    //                     ),
    //                     Container(
    //                       height: screenHeight * 0.03,
    //                       color: MKIColorConst.mkiGoldDeep,
    //                       child: const Center(
    //                         child: Text('Title'),
    //                       ),
    //                     ),
    //                     Container(
    //                       height: screenHeight * 0.03,
    //                       color: Colors.blueGrey,
    //                       child: const Center(
    //                         child: Text('Price'),
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //               Container(
    //                 height: screenHeight * 0.17,
    //                 width: screeenWidth * 0.3,
    //                 color: Colors.amber,
    //               ),
    //               Container(
    //                 height: screenHeight * 0.17,
    //                 width: screeenWidth * 0.3,
    //                 color: Colors.amber,
    //               ),
    //             ],
    //           ),
    //           const Text(
    //             'DRIVEN BY PASSION',
    //             style: TextStyle(fontSize: 22),
    //           ),
    //           const Text(
    //             '(info@karbo.tech)',
    //             style: TextStyle(fontSize: 17),
    //           ),
    //           const Text(
    //             'Version 1.2.8',
    //             style: TextStyle(fontSize: 15),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }
}
