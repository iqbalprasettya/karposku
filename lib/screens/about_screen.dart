import 'package:flutter/material.dart';
import 'package:karposku/consts/mki_colors.dart';
import 'package:karposku/screens/navigation_screen.dart';

class LogoAboutScreen extends StatelessWidget {
  const LogoAboutScreen({super.key});

  static String routeName = 'about-screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'ABOUT',
          style: TextStyle(color: MKIColorConst.mainBlue),
        ),
        backgroundColor: MKIColorConst.mainToscaBlue,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: MKIColorConst.mainGoldBlueAppBar,
          ),
        ),
        leading: InkWell(
          onTap: () {
            NavigationScreen.startIndex = 0;
            Navigator.pushNamedAndRemoveUntil(
              context,
              NavigationScreen.routeName,
              ModalRoute.withName('/'),
            );
          },
          child: Icon(
            Icons.close,
            color: MKIColorConst.mkiSilver,
            size: 45,
          ),
        ),
        // leading: Container(
        //   padding: const EdgeInsets.all(5),
        //   child: CircleAvatar(
        //     backgroundColor: Colors.white,
        //     child: Image.asset(
        //       'assets/images/person.png',
        //     ),
        //   ),
        // ),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                'WE PROVIDE YOUR NEEDS',
                style: TextStyle(fontSize: 22),
              ),
              Center(
                child: SizedBox(
                  // color: Color.fromARGB(255, 130, 119, 79),
                  height: 400,
                  width: 400,
                  child: ClipRRect(
                    child: Semantics(
                      label: 'Logo image with 400 * 400 dimensions',
                      readOnly: true,
                      child: Image.asset(
                        'assets/images/karbotech.png',
                      ),
                    ),
                  ),
                ),
              ),
              const Text(
                'DRIVEN BY PASSION',
                style: TextStyle(fontSize: 22),
              ),
              const Text(
                '(info@karbo.tech)',
                style: TextStyle(fontSize: 17),
              ),
              const Text(
                'Version 1.2.8',
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
