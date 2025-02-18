import 'package:flutter/material.dart';
import 'package:karposku/consts/mki_colors.dart';
import 'package:karposku/consts/mki_methods.dart';
import 'package:karposku/consts/mki_variabels.dart';

class HomeTabsContent {
  HomeTabsContent({required this.title});
  final String title;
// Widget build(BuildContext context, String wTitle) {
  Widget build(String wTitle) {
    wTitle = title;
    return Center(
      child: FittedBox(
        child: Text(
          wTitle,
          style: const TextStyle(fontSize: 17),
        ),
      ),
    );
  }
}

class MKIStyles {
  static Widget promoContainer(
    double cWidth,
    double cHeight,
    Color cColor,
  ) {
    return Stack(
      children: [
        Transform.rotate(
          angle: 0.75,
          child: Container(
            color: cColor,
            width: cWidth,
            height: cHeight,
          ),
        ),
        // Transform.rotate(
        //   angle: 0.9,
        //   child: Container(
        //     color: cColor,
        //     width: cWidth,
        //     height: cHeight,
        //   ),
        // ),
        Container(
          padding: EdgeInsets.all(2),
          color: cColor,
          width: cWidth,
          height: cHeight,
          child: Center(
            child: FittedBox(
              child: Text('ROTATE'),
            ),
          ),
        ),
      ],
    );
  }

  static Widget homeMenu(
    BuildContext context,
    String assetFilePath,
    String menuTitle,
  ) {
    double screeenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    var screenOrientation = MediaQuery.of(context).orientation;
    return SizedBox(
      height: screenOrientation == Orientation.portrait
          ? screenHeight * 0.19
          : screenHeight * 0.25,
      width: screenOrientation == Orientation.portrait
          ? screeenWidth * 0.28
          : screeenWidth * 0.13,
      // decoration: BoxDecoration(
      //   color: Colors.amberAccent,
      //   borderRadius: BorderRadius.circular(30),
      // ),
      // color: Colors.yellowAccent,
      child: Column(
        children: [
          /* Image Menu */
          Container(
            height: screenOrientation == Orientation.portrait
                ? screenHeight * 0.13
                : screenHeight * 0.19,
            width: screenOrientation == Orientation.portrait
                ? screenHeight * 0.3
                : screenHeight * 0.23,
            decoration: const BoxDecoration(
              // color: MKIColorConst.mkiGoldMid,
              // color: Colors.yellowAccent,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Image.asset(
              assetFilePath,
              fit: BoxFit.contain,
            ),
          ),
          /* Title Menu */
          Container(
            // width: screeenWidth * 0.1,
            height: screenOrientation == Orientation.portrait
                ? screenHeight * 0.03
                : screenHeight * 0.06,
            decoration: const BoxDecoration(
              // color: MKIColorConst.mkiGoldDeep,
              // color: Colors.greenAccent,
              borderRadius: BorderRadius.only(
                  // topLeft: Radius.circular(15),
                  // topRight: Radius.circular(15),
                  ),
            ),
            child: Center(
              child: Text(
                menuTitle,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          /* Add Info Menu */
          // Container(
          //   height: screenHeight * 0.03,
          //   decoration: const BoxDecoration(
          //     color: Colors.blueGrey,
          //     borderRadius: BorderRadius.only(
          //       bottomLeft: Radius.circular(25),
          //       bottomRight: Radius.circular(25),
          //     ),
          //   ),
          //   child: const Center(
          //     child: Text('Price'),
          //   ),
          // ),
        ],
      ),
    );
  }

  static Widget mkiCartTile(
    BuildContext context,
    Widget img,
    String itemsName,
    String price,
    String qty,
    String subTotal,
    // Widget decButton,
    // Widget incButton,
    Widget buttons,
    int index,
  ) {
    double screeenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return SizedBox(
        // color: Colors.yellow,
        // color: index.isOdd
        //     ? MKIColorConst.mkiGoldMid.withOpacity(0.1)
        //     : MKIColorConst.mkiGoldDeep.withOpacity(0.15),
        width: screeenWidth,
        height: screenHeight * 0.12,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /* Left Image */
                Container(
                  height: screenHeight * 0.1,
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.4),
                    // color: MKIColorConst.mkiGoldMid.withOpacity(0.15),
                    // gradient: MKIColorConst.mainGoldBlueAppBar,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: img,
                ),
                /* Items Name & Price */
                Container(
                  width: screeenWidth * 0.58,
                  color: Colors.green,
                  padding: const EdgeInsets.only(left: 7, right: 3),
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /* Items Name */
                      SizedBox(
                        height: screenHeight * 0.04,
                        // color: Colors.blueGrey,
                        child: FittedBox(
                          child: Text(
                            MKIMethods.capitalizeFirstChar(
                              itemsName,
                            ),
                            style: const TextStyle(
                              fontSize: 10,
                              // fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      // const Expanded(
                      //   child: Divider(
                      //     color: Colors.black,
                      //   ),
                      // ),
                      Text(
                        MKIMethods.capitalizeFirstChar(
                          qty,
                        ),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /* Items Price */
                          SizedBox(
                            height: screenHeight * 0.03,
                            // color: Colors.yellowAccent,
                            child: FittedBox(
                              child: Text(
                                MKIMethods.capitalizeFirstChar(
                                  price,
                                ),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          // SizedBox(
                          //   height: screenHeight * 0.03,
                          // ),
                        ],
                      ),
                      // SizedBox(
                      //   height: screenHeight * 0.035,
                      //   // color: Colors.yellowAccent,
                      //   child: FittedBox(
                      //     child: Text(
                      //       MKIMethods.capitalizeFirstChar(
                      //         subTotal,
                      //       ),
                      //       style: const TextStyle(
                      //         fontSize: 11,
                      //         fontWeight: FontWeight.bold,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
                Container(
                  // color: Colors.amber,
                  // width: screeenWidth * 0.2,
                  // height: screenHeight * 0.1,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    gradient: MKIColorConst.mainGoldBlueAppBar,
                  ),
                  child: buttons,
                ),
              ],
            ),
            const Expanded(
              child: Divider(
                color: Colors.grey,
              ),
            ),
          ],
        ));
  }

  static Widget containerOrientation(
    BuildContext context,
    double portraitWidth,
    double landscapeWidth,
    double portraitHeight,
    double landscapeHeight,
    double top,
    double bottom,
    double left,
    double right,
    Color containerColor,
    double borderRadius,
    Widget childWidget,
  ) {
    double screeenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.only(
        top: top,
        bottom: bottom,
        right: right,
        left: left,
      ),
      decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(borderRadius)),
      width: MediaQuery.of(context).orientation == Orientation.portrait
          ? screeenWidth * portraitWidth
          : screeenWidth * landscapeWidth,
      height: MediaQuery.of(context).orientation == Orientation.portrait
          ? screenHeight * portraitHeight
          : screenHeight * landscapeHeight,
      child: childWidget,
    );
  }

  static Widget mkiCartTileNew(
    BuildContext context,
    Widget img,
    String itemsName,
    String price,
    String qty,
    String subTotal,
    Widget buttons,
    int index,
  ) {
    double screeenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      color: Colors.transparent,
      // color: index.isOdd
      //     ? MKIColorConst.mkiGoldMid.withOpacity(0.1)
      //     : MKIColorConst.mkiGoldDeep.withOpacity(0.15),
      width: screeenWidth,
      height: MediaQuery.of(context).orientation == Orientation.portrait
          ? screenHeight * 0.14
          : screenHeight * 0.28,
      child: Column(
        children: [
          Row(
            children: [
              /* Left Picture */
              containerOrientation(
                context,
                0.22,
                0.12,
                0.115,
                0.24,
                1, 1, 1, 1,
                // Colors.grey.withOpacity(0.5),
                Colors.grey.withOpacity(0.3),
                // Colors.white,
                10,
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: img,
                ),
              ),
              /* Items */
              containerOrientation(
                context,
                0.77,
                0.87,
                0.12,
                0.25,
                0,
                1,
                0,
                0,
                // Colors.blueAccent,
                Colors.transparent,
                0,
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /* Items Name */
                    containerOrientation(
                      context,
                      0.77,
                      0.87,
                      0.032,
                      0.08,
                      0,
                      0,
                      0,
                      0,
                      // Colors.greenAccent,
                      Colors.transparent,
                      0,
                      Padding(
                        padding: const EdgeInsets.only(left: 7),
                        child: FittedBox(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            MKIMethods.capitalizeFirstChar(
                              itemsName,
                            ),
                            style: const TextStyle(
                              fontSize: 10,
                              // fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    /* Items Price */
                    containerOrientation(
                      context,
                      0.77,
                      0.87,
                      0.032,
                      0.08,
                      0,
                      0,
                      0,
                      0,
                      // Colors.yellowAccent,
                      Colors.transparent,
                      0,
                      Padding(
                        padding: const EdgeInsets.only(left: 7),
                        child: FittedBox(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            price,
                            style: const TextStyle(
                                // fontSize: 10,
                                // fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ),
                    ),
                    /* Subtotal & Buttons */
                    containerOrientation(
                      context,
                      0.77,
                      0.87,
                      0.035,
                      0.08,
                      0,
                      0,
                      0,
                      0,
                      Colors.transparent,
                      0,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /* Subtotal */
                          containerOrientation(
                            context,
                            0.2,
                            0.2,
                            0.035,
                            0.08,
                            0,
                            0,
                            0,
                            0,
                            Colors.transparent,
                            0,
                            FittedBox(
                              child: Text(
                                subTotal,
                                // style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                          /* Buttons */
                          containerOrientation(
                            context,
                            0.31,
                            0.155,
                            0.035,
                            0.08,
                            0,
                            0,
                            0,
                            0,
                            // Colors.grey.withOpacity(0.4),
                            Colors.transparent,
                            0,
                            buttons,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Expanded(
            child: Divider(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  static Widget mkiCardDisplayNew(
    BuildContext context,
    int index,
    String itemsName,
    int normalPrice,
    int finalPrice,
    String img,
    bool isOnline, {
    Widget promoWidget = const SizedBox(),
  }) {
    double screeenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Card(
      color: Colors.white,
      shadowColor: Colors.grey,
      child: SizedBox(
        width: screenHeight,
        height: screenHeight,
        child: Column(
          children: [
            Stack(
              children: [
                promoWidget,
                Container(
                  margin: EdgeInsets.only(
                    top: MediaQuery.of(context).orientation ==
                            Orientation.portrait
                        ? 10
                        : 0,
                  ),
                  width: screeenWidth,
                  height:
                      MediaQuery.of(context).orientation == Orientation.portrait
                          ? screenHeight * 0.1
                          : screenHeight * 0.25,
                  child: Center(
                    child: ClipRRect(
                      // borderRadius: BorderRadius.circular(35),
                      child: img != ''
                          ? Image.network(
                              img,
                              // height: 60,
                              fit: BoxFit.contain,
                            )
                          : Image.asset('assets/images/karbotech.png'),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: screeenWidth,
              height: MediaQuery.of(context).orientation == Orientation.portrait
                  ? screeenWidth * 0.05
                  : screeenWidth * 0.03,
              // decoration: BoxDecoration(
              // color: MKIColorConst.mkiDeepBlue.withOpacity(0.9),
              // gradient: MKIColorConst.mainGoldBackground,
              // ),
              child: Center(
                child: Text(
                  MKIMethods.capitalizeFirstChar(itemsName),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(
              width: screeenWidth,
              height: MediaQuery.of(context).orientation == Orientation.portrait
                  ? screeenWidth * 0.05
                  : screeenWidth * 0.03,
              // decoration: BoxDecoration(
              // color: MKIColorConst.mkiDeepBlue.withOpacity(0.9),
              // gradient: MKIColorConst.mainGoldBackground,
              // ),
              child: Row(
                mainAxisAlignment: normalPrice == finalPrice
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.spaceEvenly,
                children: [
                  normalPrice == finalPrice
                      ? SizedBox()
                      : Text(
                          'Rp.${MKIVariabels.formatter.format(normalPrice)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: MKIColorConst.mkiRed,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: Colors.grey,
                            decorationThickness: 2.0,
                          ),
                        ),
                  Text(
                    'Rp.${MKIVariabels.formatter.format(finalPrice)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: MKIColorConst.mkiDeepBlue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget mkiCardDisplay(
    BuildContext context,
    int index,
    String itemsName,
    int itemsPrice,
    String img,
    bool isOnline,
  ) {
    double screeenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Card(
      color: Colors.white,
      shadowColor: Colors.grey,
      child: Container(
        decoration: BoxDecoration(
          // color: Colors.amber.withOpacity(0.8),
          // color: Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        // decoration: MKIColorConst.mkiBoxDecorationLightGold,
        height: screenHeight * 0.9,
        margin: const EdgeInsets.all(3),
        child: Stack(
          children: [
            Positioned.fill(
              bottom: 40,
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  // height: screenHeight * 0.13,
                  width: screeenWidth * 0.32,
                  height: screeenWidth * 0.32,
                  child: Center(
                    child: ClipRRect(
                      // borderRadius: BorderRadius.circular(35),
                      child: img != ''
                          ? Image.network(
                              img,
                              // height: 60,
                              fit: BoxFit.contain,
                            )
                          : Image.asset('assets/images/karbotech.png'),
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              top: 90,
              left: 0,
              child: Align(
                child: Container(
                  alignment: Alignment.bottomCenter,
                  height: screenHeight * 0.065,
                  // color: Colors.amber,
                  child: Column(
                    children: [
                      SizedBox(
                        width: screeenWidth,
                        height: screeenWidth * 0.055,
                        // decoration: BoxDecoration(
                        // color: MKIColorConst.mkiDeepBlue.withOpacity(0.9),
                        // gradient: MKIColorConst.mainGoldBackground,
                        // ),
                        child: Center(
                          child: Text(
                            MKIMethods.capitalizeFirstChar(itemsName),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: screeenWidth,
                        height: screeenWidth * 0.055,
                        // decoration: BoxDecoration(
                        // color: MKIColorConst.mkiDeepBlue.withOpacity(0.9),
                        // gradient: MKIColorConst.mainGoldBackground,
                        // ),
                        child: Center(
                          child: Text(
                            'Rp.${MKIVariabels.formatter.format(itemsPrice)}',
                            style: TextStyle(
                              // color: Colors.white,
                              fontWeight: FontWeight.bold,
                              color: MKIColorConst.mkiDeepBlue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // static Widget mkiCard11111111(BuildContext context, int index,
  //     String itemsName, int itemsPrice, String img, bool isOnline) {
  //   // String strPrice = MKIVariabels.formatter.format(intPrice);
  //   double screeenWidth = MediaQuery.of(context).size.width;
  //   double screenHeight = MediaQuery.of(context).size.height;
  //   return Container(
  //     // color: Colors.transparent,
  //     padding: const EdgeInsets.all(6),
  //     decoration: BoxDecoration(
  //       // color: Colors.amber.withOpacity(0.8),
  //       color: Colors.grey.withOpacity(0.1),
  //       borderRadius: BorderRadius.circular(20),
  //     ),
  //     // decoration: MKIColorConst.mkiBoxDecorationLightGold,
  //     height: screenHeight * 0.9,
  //     margin: const EdgeInsets.all(3),
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.spaceAround,
  //       children: [
  //         Container(
  //           padding: const EdgeInsets.all(5),
  //           height: screenHeight * 0.13,
  //           width: screeenWidth * 0.2,
  //           decoration: BoxDecoration(
  //             // color: MKIColorConst.mkiSilver.withOpacity(1),
  //             color: Colors.white,
  //             // gradient: MKIColorConst.mainGoldBackground,
  //             borderRadius: BorderRadius.circular(35),

  //             // borderRadius: const BorderRadius.only(
  //             //   topLeft: Radius.circular(17),
  //             //   topRight: Radius.circular(17),
  //             // ),
  //           ),
  //           child: ClipRRect(
  //             borderRadius: BorderRadius.circular(35),
  //             child: img != ''
  //                 ? Image.network(
  //                     img,
  //                     // height: 60,
  //                     fit: BoxFit.contain,
  //                   )
  //                 : Image.asset('assets/images/karbotech.png'),
  //           ),
  //         ),
  //         Column(
  //           mainAxisAlignment: MainAxisAlignment.start,
  //           children: [
  //             Container(
  //               decoration: BoxDecoration(
  //                 color: MKIColorConst.mkiDeepBlue.withOpacity(0.9),
  //                 gradient: MKIColorConst.mainGoldBackground,
  //                 // borderRadius: const BorderRadius.only(
  //                 //   topLeft: Radius.circular(12),
  //                 //   topRight: Radius.circular(12),
  //                 //   bottomLeft: Radius.circular(12),
  //                 //   bottomRight: Radius.circular(12),
  //                 // ),
  //               ),
  //               child: Center(
  //                 // child: Text(_itemsFound[index].itemsName),
  //                 child: FittedBox(
  //                     child: Text(
  //                   MKIMethods.capitalizeFirstChar(itemsName),
  //                   // itemsName,
  //                   style: TextStyle(
  //                     // color: Colors.white,
  //                     color: MKIColorConst.mkiDeepBlue,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 )),
  //               ),
  //             ),
  //             Container(
  //               decoration: BoxDecoration(
  //                 color: MKIColorConst.mkiDeepBlue.withOpacity(0.9),
  //                 gradient: MKIColorConst.mainGoldBackground,
  //                 borderRadius: const BorderRadius.only(
  //                     // bottomLeft: Radius.circular(12),
  //                     // bottomRight: Radius.circular(12),
  //                     ),
  //               ),
  //               child: Center(
  //                 // child: Text(_itemsFound[index].itemsName),
  //                 // child: Text(itemsPrice),
  //                 child: Text(
  //                   'Rp.${MKIVariabels.formatter.format(itemsPrice)}',
  //                   style: TextStyle(
  //                     // color: Colors.white,
  //                     fontWeight: FontWeight.bold,
  //                     color: MKIColorConst.mkiDeepBlue,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         )
  //       ],
  //     ),
  //   );
  // }

  static ButtonStyle getButtonStyle(
    Color buttonColor,
    double width,
    double height,
  ) {
    return ButtonStyle(
      fixedSize: WidgetStateProperty.all<Size>(Size(width, height)),
      backgroundColor: WidgetStateProperty.all<Color>(buttonColor),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
          // side: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  // static InputDecoration getInputStyle(double radius, IconData icon) {
  //   return InputDecoration(
  //     border: OutlineInputBorder(
  //         borderRadius: BorderRadius.all(
  //           Radius.circular(radius),
  //         ),
  //         borderSide: const BorderSide(
  //           width: 0,
  //           style: BorderStyle.none,
  //         )),
  //     prefixIcon: Icon(icon),
  //   );
  // }

  static Widget textFieldCustomImage({
    required double width,
    required double height,
    required TextEditingController controller,
    required String textHint,
    required TextInputType inputType,
    required Function validationFunc,
    required FocusNode focusNode,
    bool isAutoFocus = false,
    bool isObsecureText = false,
    Color bgColor = Colors.white,
    String assetPath = '',
    bool isEnable = true,
    TextAlign textPosition = TextAlign.start,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      child: TextFormField(
        textAlign: textPosition,
        enabled: isEnable,
        focusNode: focusNode,
        textInputAction: TextInputAction.next,
        controller: controller,
        obscureText: isObsecureText,
        autofocus: isAutoFocus,
        decoration: InputDecoration(
          hintText: textHint,
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
              borderSide: BorderSide(
                width: 0,
                style: BorderStyle.none,
              )),
          prefixIcon: assetPath != ''
              ? Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Image.asset(
                    assetPath,
                    width: 20,
                    height: 20,
                    fit: BoxFit.scaleDown,
                  ),
                )
              : null,
          suffixIcon: isObsecureText
              ? Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Material(
                    child: GestureDetector(
                      child: Image.asset(
                        'assets/images/eye.png',
                        width: 20,
                        height: 20,
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                  ),
                )
              : null,
        ),
        keyboardType: inputType,
        validator: (_) => validationFunc(),
      ),
    );
  }

  static Widget setPassFieldCustomImage({
    required double width,
    required double height,
    required TextEditingController controller,
    required String textHint,
    required String assetPath,
    required TextInputType inputType,
    required Function validationFunc,
    required Function secureTextFunc,
    required FocusNode focusNode,
    bool isAutoFocus = false,
    bool isObsecureText = false,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      child: TextFormField(
        focusNode: focusNode,
        textInputAction: TextInputAction.next,
        controller: controller,
        obscureText: isObsecureText,
        autofocus: isAutoFocus,
        decoration: InputDecoration(
          hintText: textHint,
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
              borderSide: BorderSide(
                width: 0,
                style: BorderStyle.none,
              )),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Image.asset(
              assetPath,
              width: 20,
              height: 20,
              fit: BoxFit.scaleDown,
            ),
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Material(
              child: GestureDetector(
                onTap: secureTextFunc(),
                child: Image.asset(
                  'assets/images/eye.png',
                  width: 20,
                  height: 20,
                  fit: BoxFit.scaleDown,
                ),
              ),
            ),
          ),
        ),
        keyboardType: inputType,
        validator: (_) => validationFunc(),
      ),
    );
  }

  // static ButtonStyle buttonStyle = ButtonStyle(
  //   shape: MaterialStateProperty.all<RoundedRectangleBorder>(
  //     RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(18.0),
  //       // side: const BorderSide(color: Colors.red),
  //     ),
  //   ),
  // );
}
