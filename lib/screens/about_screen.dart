import 'package:flutter/material.dart';
import 'package:karposku/consts/mki_colorsv2.dart';
import 'package:karposku/screens/navigation_screen.dart';

class LogoAboutScreen extends StatelessWidget {
  const LogoAboutScreen({super.key});

  static String routeName = 'about-screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: MKIColorConstv2.neutral200,
        ),
        child: SingleChildScrollView(
          child: Column(
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
                      Text(
                        'About',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: MKIColorConstv2.neutral100,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          NavigationScreen.startIndex = 0;
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            NavigationScreen.routeName,
                            ModalRoute.withName('/'),
                          );
                        },
                        icon: Icon(
                          Icons.close,
                          color: MKIColorConstv2.neutral100,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: MKIColorConstv2.neutral100,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: MKIColorConstv2.neutral400.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'WE PROVIDE YOUR NEEDS',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: MKIColorConstv2.secondaryDark,
                            ),
                          ),
                          SizedBox(height: 30),
                          Container(
                            height: 200,
                            width: 200,
                            decoration: BoxDecoration(
                              color: MKIColorConstv2.neutral200,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Semantics(
                                label: 'Logo image',
                                readOnly: true,
                                child: Image.asset(
                                  'assets/images/karbotech.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                          Text(
                            'DRIVEN BY PASSION',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: MKIColorConstv2.secondaryDark,
                            ),
                          ),
                          SizedBox(height: 15),
                          Text(
                            'info@karbo.tech',
                            style: TextStyle(
                              fontSize: 17,
                              color: MKIColorConstv2.secondary,
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 8),
                            decoration: BoxDecoration(
                              color: MKIColorConstv2.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Version 1.2.8',
                              style: TextStyle(
                                fontSize: 15,
                                color: MKIColorConstv2.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
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
}
