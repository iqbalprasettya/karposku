import 'package:flutter/material.dart';

class MKIColorConst {
  static Color mainBlue = const Color(0xff020135);
  static Color mainOrange = const Color(0xffff9c00);
  static Color mainYellow = const Color(0xfff5f306);
  static Color mainGreen = const Color(0xff0ef51f);
  static Color mainLightBlue = const Color(0xff01abd7);
  static Color mainToscaBlue = const Color.fromARGB(255, 51, 170, 174);

  // static Color mkiSoftBackground = const Color(0xfff7e7cc);
  static Color mkiWhiteBackground = const Color(0xfff4eade);
  // static Color mkiWhiteBackground = const Color(0xffFFFEF2);

  static Color mkiCoral = const Color(0xffed8c72);

  static Color mkiGrecianBlue = const Color(0xff2988bc);
  static Color mkiSeaBlue = const Color(0xff2f496e);

  static Color mkiDeepBlueLogo = const Color(0xff010044);
  static Color mkiMidBlueLogo = const Color(0xff2a50e0);
  static Color mkiLowBlueLogo = const Color(0xff0daced);

  static Color mkiDeepBlue = const Color(0xff014364);

  static Color mkiGreen = const Color(0xff1ca261);
  static Color mkiYellow = const Color(0xffffce42);
  static Color mkiRed = const Color(0xffd8382b);

  // static Color mkiGold1 = const Color(0xffa0845b);
  // static Color mkiGold2 = const Color(0xffd6ab71);
  // static Color mkiGold3 = const Color(0xffa37340);

  static Color mkiSilver = const Color(0xffE8E8E8);
  static Color mkiGrey = const Color(0xff909090);

  static Color mkiGreyInvdata1 = const Color.fromARGB(255, 228, 222, 222);
  static Color mkiGreyInvdata2 = const Color.fromARGB(255, 234, 231, 231);
  static Color mkiGreyInvdata3 = const Color.fromARGB(255, 236, 232, 232);

  static Color mkiGoldLight = const Color(0xffF4DFBA);
  static Color mkiGoldMid = const Color(0xffEEC373);
  static Color mkiGoldDeep = const Color(0xffCA965C);
  static Color mkiGoldDark = const Color(0xff876445);

  static LinearGradient mainBlueBackground = LinearGradient(colors: [
    MKIColorConst.mainBlue,
    MKIColorConst.mainToscaBlue,
    MKIColorConst.mainBlue,
  ]);

  static LinearGradient mainGoldBlueAppBar = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      MKIColorConst.mkiSeaBlue,
      MKIColorConst.mkiGoldLight,
      MKIColorConst.mkiSeaBlue,
    ],
  );

  static LinearGradient mainGoldBlueAppBarAlt = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      MKIColorConst.mkiSeaBlue,
      MKIColorConst.mkiGoldLight,
      MKIColorConst.mkiSeaBlue,
    ],
  );
  // static LinearGradient mainBlueGoldBackground = LinearGradient(colors: [
  //   MKIColorConst.mkiGoldDeep,
  //   MKIColorConst.mkiGoldLight,
  //   MKIColorConst.mkiGoldDark,
  // ]);

  static LinearGradient mainGoldBackground = LinearGradient(colors: [
    MKIColorConst.mkiGoldDeep,
    MKIColorConst.mkiGoldLight,
    MKIColorConst.mkiGoldDeep,
  ]);

  // static LinearGradient mainGoldLightBackground = LinearGradient(colors: [
  //   MKIColorConst.mkiGoldMid,
  //   MKIColorConst.mkiGoldLight,
  //   MKIColorConst.mkiGoldMid,
  // ]);

  static List<Color> mainGradientBackground = [
    MKIColorConst.mkiGoldDeep,
    MKIColorConst.mainGreen,
    MKIColorConst.mainToscaBlue,
  ];

  LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      MKIColorConst.mainToscaBlue,
      MKIColorConst.mainGreen,
      MKIColorConst.mainToscaBlue,
    ],
  );

  static BoxDecoration mkiBoxDecorationLightGold = BoxDecoration(
    gradient: LinearGradient(
      colors: [
        mkiWhiteBackground,
        mkiGoldLight,
        mkiWhiteBackground,
      ],
    ),
  );
}
