import 'dart:convert';

import 'package:karposku/utilities/printer_adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:karposku/consts/mki_tabs_widget.dart';
import 'package:karposku/consts/mki_urls.dart';
import 'package:karposku/consts/mki_variabels.dart';
import 'package:karposku/models/items_cart_data.dart';
import 'package:karposku/models/items_category.dart';
import 'package:karposku/models/user_data.dart';
import 'package:karposku/screens/items_gridview_screen.dart';
import 'package:karposku/utilities/local_storage.dart';
import 'package:uuid/uuid.dart';

String? phoneNo = '';
String? userName = '';
String? pass = '';
String? userToken = '';
late UserData userData;
bool isValidUser = false;

class MKIMethods {
  static void showMessage(
      BuildContext context, Color vsaColor, String vsaMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: vsaColor,
        content: Text(vsaMessage),
      ),
    );
  }

  static void showTopMessage(
    BuildContext context,
    String titleText,
    Color titleColor,
    String textContent,
    final Function()? okButtonPress,
    final Function()? noButtonPress,
  ) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black38,
      barrierLabel: 'Label',
      barrierDismissible: true,
      pageBuilder: (_, __, ___) => Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.25,
          decoration: BoxDecoration(
            color: Colors.white,
            // borderRadius: BorderRadius.circular(15),
          ),
          child: Material(
              color: Colors.transparent,
              child: Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.07,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      // borderRadius: BorderRadius.only(
                      //     topLeft: Radius.circular(15),
                      //     topRight: Radius.circular(15)),
                      color: titleColor,
                    ),
                    child: Center(
                      child: Text(
                        titleText,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.08,
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        // color: Colors.teal,
                        ),
                    child: Center(
                      child: Text(
                        textContent,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 21,
                        ),
                      ),
                    ),
                  ),
                  Container(
                      height: MediaQuery.of(context).size.height * 0.05,
                      padding: EdgeInsets.all(7),
                      decoration: BoxDecoration(
                          // color: Colors.teal,
                          ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Center(
                            child: IconButton(
                              onPressed: okButtonPress,
                              // onPressed: () {
                              //   Navigator.of(context).pop();
                              // },
                              icon: Icon(
                                Icons.check_circle,
                                size: 32,
                                color: Colors.teal,
                              ),
                            ),
                          ),
                          Center(
                            child: IconButton(
                              onPressed: okButtonPress,
                              // onPressed: () {
                              //   Navigator.of(context).pop();
                              // },
                              icon: Icon(
                                Icons.cancel,
                                size: 32,
                                color: Colors.teal,
                              ),
                            ),
                          ),
                        ],
                      )),
                ],
              )),
        ),
      ),
    );
  }

  static processGetData() async {
    /* List for HomeScreen title tabs */
    List<ItemsCategory> categoryList = await MKIUrls.getItemsCategory();
    print('Kategori : ${categoryList.length}');
    MKITabsWidget.categoryGroupTitle.clear();
    MKITabsWidget.categoriesWidgetContent.clear();

    for (int i = 0; i < categoryList.length; i++) {
      MKITabsWidget.categoryGroupTitle.add(
        WidgetDataTitle(
          title: categoryList[i].categoryName,
        ),
      );
      /* Widget Content for HomeScreen */
      // BrowseItemsScreen.categoryName = categoryList[i].categoryName;
      MKITabsWidget.categoriesWidgetContent.add(
        ItemsGridViewScreen(
          categoryName: categoryList[i].categoryId,
        ),
      );
    }
    /* Get Item List */
    ItemsGridViewScreen.startlistItem = await MKIUrls.getItemsList();
  }

  static Future<bool> autoLogin() async {
    phoneNo = await LocalStorage.load(MKIVariabels.userPhone);
    pass = await LocalStorage.load(MKIVariabels.userPassword);
    userToken = await LocalStorage.load(MKIVariabels.token);
    // LocalStorage.save(MKIVariabels.IS_VALID_LOGIN, '0');

    String? tPhoneNo = phoneNo ?? '';
    String? tPass = pass ?? '';

    userData = await MKIUrls.fetchUser(tPhoneNo, tPass);

    isValidUser = false;
    if (userData.userName != '' && userData.token != '') {
      isValidUser = true;
      // print(userData.phoneNo);
      // print(userData.userName);
      // print(isValidUser);
      // LocalStorage.save(MKIVariabels.IS_VALID_LOGIN, '1');
      // ignore: use_build_context_synchronously
      // Provider.of<UserProvider>(context, listen: false).addUserData(
      //   UserData(
      //     phoneNo: phoneNo!,
      //     userName: userName!,
      //     token: userData.token,
      //     picPath: userData.picPath,
      //   ),
      // );
    }
    return isValidUser;
  }

  static String capitalizeFirstChar(String value) {
    var result = value[0].toUpperCase();
    for (int i = 1; i < value.length; i++) {
      if (value[i - 1] == " ") {
        result = result + value[i].toUpperCase();
      } else {
        result = result + value[i];
      }
    }
    return result;
  }

  // static String capitalizeFirstChar(String value) {
  //   var result = value[0].toUpperCase();
  //   for (int i = 1; i < value.length; i++) {
  //     if (value[i - 1] == " ") {
  //       result = result + value[i].toUpperCase();
  //     } else {
  //       result = result + value[i].toLowerCase();
  //     }
  //   }
  //   return result;
  // }

  static bool isNumber(String string) {
    final numericRegex = RegExp(r'^-?(([0-9]*)|(([0-9]*)\.([0-9]*)))$');
    return numericRegex.hasMatch(string);
  }

  static String getOriginalCurrentDate() {
    var now = DateTime.now();
    var formatter = DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    // print(formattedDate);
    return formattedDate;
  }

  static String getIndCurrentDate() {
    var now = DateTime.now();
    var formatter = DateFormat('dd-MM-yyyy');
    String formattedDate = formatter.format(now);
    // print(formattedDate);
    return formattedDate;
  }

  static String getUUID() {
    var uuid = const Uuid();
    String tmp = uuid.v1();
    String rs = tmp.replaceAll('-', '');
    return rs;
  }

  // static String numberFormat(int source) {
  //   String tmp = source.toString();
  //   NumberFormat formatter;

  //   if (tmp.length <= 5) {
  //     formatter = NumberFormat('###,###,000');
  //   } else if (tmp.length > 5) {
  //     formatter = NumberFormat('###,###,000');
  //   }
  //   return formatter.format(source);
  // }
  // static Future<String> loadData() async {
  //   return await MKIUrls.fetchDeliveryOrder.whenComplete(
  //     (() {
  //       return const Center(child: CircularProgressIndicator());
  //     }),
  //   );
  // }

  static Future<Uint8List> imagePathToUint8List(String path) async {
    //converting to Uint8List to pass to printer
    ByteData data = await rootBundle.load(path);
    Uint8List imageBytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    return imageBytes;
  }

  static testPrint(
    bool isPrinterConnect,
    BluetoothPrint bluetoothPrint,
  ) async {
    print('Coba Print');
    bluetoothPrint.printTest();
    Map<String, dynamic> config = {};
    config['width'] = 40; // 标签宽度，单位mm
    config['height'] = 70; // 标签高度，单位mm
    config['gap'] = 2; // 标签间隔，单位mm

    // x、y坐标位置，单位dpi，1mm=8dpi
    List<LineText> list = [];
    list.add(
        LineText(type: LineText.TYPE_TEXT, x: 10, y: 10, content: 'A Title'));
    list.add(LineText(
        type: LineText.TYPE_TEXT, x: 10, y: 40, content: 'this is content'));
    list.add(LineText(
        type: LineText.TYPE_QRCODE, x: 10, y: 70, content: 'qrcode i\n'));
    list.add(LineText(
        type: LineText.TYPE_BARCODE, x: 10, y: 190, content: 'qrcode i\n'));

    List<LineText> list1 = [];
    ByteData data = await rootBundle.load("assets/images/karbotech.png");
    List<int> imageBytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    String base64Image = base64Encode(imageBytes);
    list1.add(LineText(
      type: LineText.TYPE_IMAGE,
      x: 10,
      y: 10,
      content: base64Image,
    ));

    await bluetoothPrint.printLabel(config, list);
    await bluetoothPrint.printLabel(config, list1);
  }

  static invoicePrintNew(
    bool isPrinterConnect,
    BluetoothPrint bluetoothPrint,
    String invoiceNo,
    List<ItemsCartData> itemsList,
    String payment,
    String change,
  ) async {
    print('Coba Print');
    bluetoothPrint.printTest();
    Map<String, dynamic> config = {};
    // config['width'] = 40; // 标签宽度，单位mm
    // config['height'] = 70; // 标签高度，单位mm
    // config['gap'] = 2; // 标签间隔，单位mm

    // x、y坐标位置，单位dpi，1mm=8dpi
    List<LineText> list = [];
    list.add(
      LineText(
          type: LineText.TYPE_TEXT,
          content: '================================',
          weight: 0,
          align: LineText.ALIGN_CENTER,
          linefeed: 1),
    );
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'KARBOTECH JAYA',
        weight: 0,
        align: LineText.ALIGN_CENTER,
        fontZoom: 4,
        linefeed: 1));
    list.add(LineText(linefeed: 1));

    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'WA  : 08217 888 1717',
        weight: 0,
        align: LineText.ALIGN_LEFT,
        fontZoom: 1,
        linefeed: 1));

    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'Tanggal  : ${MKIMethods.getIndCurrentDate()}',
        weight: 0,
        align: LineText.ALIGN_LEFT,
        fontZoom: 1,
        linefeed: 1));

    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: '================================',
        weight: 0,
        align: LineText.ALIGN_CENTER,
        linefeed: 1));

    double tmpTotal = 0;
    int intTotal = 0;
    String strTotal = '';
    for (var element in itemsList) {
      double tPrice = double.parse(element.itemsPrice);
      var subTotal = element.qty * tPrice;
      tmpTotal += subTotal;

      var strSubTotal = MKIVariabels.formatter.format(subTotal);

      list.add(
        LineText(
            type: LineText.TYPE_TEXT,
            content: element.itemsName,
            weight: 0,
            align: LineText.ALIGN_LEFT,
            x: 0,
            relativeX: 0,
            linefeed: 1),
      );

      list.add(
        LineText(
            type: LineText.TYPE_TEXT,
            content: '  ${element.qty} x ${element.itemsPrice}',
            weight: 0,
            align: LineText.ALIGN_LEFT,
            x: 0,
            relativeX: 0,
            linefeed: 0),
      );

      list.add(
        LineText(
            type: LineText.TYPE_TEXT,
            content: strSubTotal,
            weight: 0,
            align: LineText.ALIGN_RIGHT,
            x: 250,
            relativeX: 0,
            linefeed: 0),
      );
      list.add(
        LineText(
            type: LineText.TYPE_TEXT,
            content: '',
            weight: 0,
            align: LineText.ALIGN_LEFT,
            x: 500,
            relativeX: 0,
            linefeed: 1),
      );
    }
    intTotal = tmpTotal.toInt();
    strTotal = MKIVariabels.formatter.format(intTotal);

    list.add(
      LineText(
          type: LineText.TYPE_TEXT,
          content: '--------------------------------',
          weight: 0,
          align: LineText.ALIGN_CENTER,
          linefeed: 1),
    );

    list.add(
      LineText(
          type: LineText.TYPE_TEXT,
          content: 'Total  :',
          weight: 0,
          align: LineText.ALIGN_LEFT,
          x: 0,
          relativeX: 0,
          linefeed: 0),
    );

    list.add(
      LineText(
          type: LineText.TYPE_TEXT,
          content: strTotal,
          weight: 0,
          align: LineText.ALIGN_RIGHT,
          x: 250,
          relativeX: 0,
          linefeed: 0),
    );
    list.add(
      LineText(
          type: LineText.TYPE_TEXT,
          content: '',
          weight: 0,
          align: LineText.ALIGN_LEFT,
          x: 0,
          relativeX: 0,
          linefeed: 1),
    );

    list.add(
      LineText(
          type: LineText.TYPE_TEXT,
          content: 'Bayar  :',
          weight: 0,
          align: LineText.ALIGN_LEFT,
          x: 0,
          relativeX: 0,
          linefeed: 0),
    );

    list.add(
      LineText(
          type: LineText.TYPE_TEXT,
          content: payment,
          weight: 0,
          align: LineText.ALIGN_RIGHT,
          x: 250,
          relativeX: 0,
          linefeed: 0),
    );
    list.add(
      LineText(
          type: LineText.TYPE_TEXT,
          content: '',
          weight: 0,
          align: LineText.ALIGN_LEFT,
          x: 0,
          relativeX: 0,
          linefeed: 1),
    );

    list.add(
      LineText(
          type: LineText.TYPE_TEXT,
          content: 'Kembali:',
          weight: 0,
          align: LineText.ALIGN_LEFT,
          x: 0,
          relativeX: 0,
          linefeed: 0),
    );

    list.add(
      LineText(
          type: LineText.TYPE_TEXT,
          content: change,
          weight: 0,
          align: LineText.ALIGN_RIGHT,
          x: 250,
          relativeX: 0,
          linefeed: 0),
    );
    list.add(
      LineText(
          type: LineText.TYPE_TEXT,
          content: '',
          weight: 0,
          align: LineText.ALIGN_LEFT,
          x: 0,
          relativeX: 0,
          linefeed: 1),
    );

    list.add(
      LineText(
          type: LineText.TYPE_TEXT,
          content: '--------------------------------',
          weight: 0,
          align: LineText.ALIGN_CENTER,
          linefeed: 1),
    );

    // list.add(LineText(
    //     type: LineText.TYPE_TEXT,
    //     content: 'BCA : 86500 28288',
    //     weight: 0,
    //     align: LineText.ALIGN_LEFT,
    //     fontZoom: 3,
    //     linefeed: 1));

    // list.add(
    //   LineText(
    //       type: LineText.TYPE_TEXT,
    //       content: 'A/N : KARBOTECH',
    //       weight: 0,
    //       align: LineText.ALIGN_LEFT,
    //       fontZoom: 3,
    //       linefeed: 1),
    // );
    // list.add(
    //   LineText(linefeed: 1),
    // );
    list.add(
      LineText(
          type: LineText.TYPE_TEXT,
          content: 'TERIMA KASIH',
          weight: 2,
          align: LineText.ALIGN_CENTER,
          fontZoom: 4,
          linefeed: 1),
    );
    list.add(
      LineText(linefeed: 1),
    );

    // List<LineText> listImg = [];
    // ByteData data = await rootBundle.load("assets/images/karbotech.png");
    // List<int> imageBytes =
    //     data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    // String base64Image = base64Encode(imageBytes);
    // listImg.add(LineText(
    //   type: LineText.TYPE_IMAGE,
    //   x: 10,
    //   y: 10,
    //   content: base64Image,
    // ));

    await bluetoothPrint.printLabel(config, list);
    // await bluetoothPrint.printReceipt(config, listImg);
    // await bluetoothPrint.printLabel(config, list1);
  }

  // static invoicePrint(
  //   bool isPrinterConnect,
  //   String invoiceNo,
  //   List<ItemsCartData> dataList,
  //   BluetoothPrint bluetoothPrint,
  // ) {
  //   print('Coba Print');
  //   print(isPrinterConnect);
  //   isPrinterConnect
  //       ? () async {
  //           Map<String, dynamic> config = {};
  //           List<LineText> list = [];
  //           list.add(
  //             LineText(
  //                 type: LineText.TYPE_TEXT,
  //                 content: '================================',
  //                 weight: 0,
  //                 align: LineText.ALIGN_CENTER,
  //                 linefeed: 1),
  //           );
  //           /* LOGO */
  //           // list.add(LineText(
  //           //     width: 20,
  //           //     height: 20,
  //           //     fontZoom: 3,
  //           //     type: LineText.TYPE_IMAGE,
  //           //     content: base64Image,
  //           //     align: LineText.ALIGN_CENTER,
  //           //     linefeed: 0));

  //           list.add(LineText(
  //               type: LineText.TYPE_TEXT,
  //               content: 'KARBOTECH JAYA',
  //               weight: 0,
  //               align: LineText.ALIGN_CENTER,
  //               fontZoom: 4,
  //               linefeed: 1));
  //           list.add(LineText(linefeed: 1));

  //           list.add(LineText(
  //               type: LineText.TYPE_TEXT,
  //               content: 'WA  : 087826267788 - 08128585685',
  //               weight: 0,
  //               align: LineText.ALIGN_LEFT,
  //               fontZoom: 1,
  //               linefeed: 1));

  //           list.add(LineText(
  //               type: LineText.TYPE_TEXT,
  //               content: '================================',
  //               weight: 0,
  //               align: LineText.ALIGN_CENTER,
  //               linefeed: 1));

  //           list.add(LineText(
  //               type: LineText.TYPE_TEXT,
  //               content: 'Tanggal  : ${MKIMethods.getIndCurrentDate()}',
  //               weight: 0,
  //               align: LineText.ALIGN_LEFT,
  //               fontZoom: 1,
  //               linefeed: 1));

  //           list.add(LineText(
  //               type: LineText.TYPE_TEXT,
  //               content:
  //                   // 'Tanggal  : ${doData.data[invoiceIdx].invoiceNo}',
  //                   'Inv No   : ${invoiceNo}',
  //               weight: 0,
  //               align: LineText.ALIGN_LEFT,
  //               fontZoom: 1,
  //               linefeed: 1));
  //           list.add(
  //             LineText(
  //                 type: LineText.TYPE_TEXT,
  //                 content: '--------------------------------',
  //                 weight: 0,
  //                 align: LineText.ALIGN_CENTER,
  //                 linefeed: 1),
  //           );

  //           double tmpTotal = 0;
  //           int intTotal = 0;
  //           String strTotal = '';
  //           for (var element in dataList) {
  //             double tPrice = double.parse(element.itemsPrice);
  //             var subTotal = element.qty * tPrice;
  //             tmpTotal += subTotal;

  //             var strSubTotal = MKIVariabels.formatter.format(subTotal);

  //             list.add(
  //               LineText(
  //                   type: LineText.TYPE_TEXT,
  //                   content: element.itemsName,
  //                   weight: 0,
  //                   align: LineText.ALIGN_LEFT,
  //                   x: 0,
  //                   relativeX: 0,
  //                   linefeed: 1),
  //             );

  //             list.add(
  //               LineText(
  //                   type: LineText.TYPE_TEXT,
  //                   content: '  ${element.qty} x ${element.itemsPrice}',
  //                   weight: 0,
  //                   align: LineText.ALIGN_LEFT,
  //                   x: 0,
  //                   relativeX: 0,
  //                   linefeed: 0),
  //             );

  //             list.add(
  //               LineText(
  //                   type: LineText.TYPE_TEXT,
  //                   content: strSubTotal,
  //                   weight: 0,
  //                   align: LineText.ALIGN_RIGHT,
  //                   x: 250,
  //                   relativeX: 0,
  //                   linefeed: 0),
  //             );
  //             list.add(
  //               LineText(
  //                   type: LineText.TYPE_TEXT,
  //                   content: '',
  //                   weight: 0,
  //                   align: LineText.ALIGN_LEFT,
  //                   x: 500,
  //                   relativeX: 0,
  //                   linefeed: 1),
  //             );
  //           }
  //           intTotal = tmpTotal.toInt();
  //           strTotal = MKIVariabels.formatter.format(intTotal);

  //           list.add(
  //             LineText(
  //                 type: LineText.TYPE_TEXT,
  //                 content: '--------------------------------',
  //                 weight: 0,
  //                 align: LineText.ALIGN_CENTER,
  //                 linefeed: 1),
  //           );

  //           list.add(
  //             LineText(
  //                 type: LineText.TYPE_TEXT,
  //                 content: 'Total',
  //                 weight: 0,
  //                 align: LineText.ALIGN_LEFT,
  //                 x: 0,
  //                 relativeX: 0,
  //                 linefeed: 0),
  //           );
  //           list.add(
  //             LineText(
  //                 type: LineText.TYPE_TEXT,
  //                 content: strTotal,
  //                 weight: 0,
  //                 align: LineText.ALIGN_RIGHT,
  //                 x: 250,
  //                 relativeX: 0,
  //                 linefeed: 0),
  //           );
  //           list.add(
  //             LineText(
  //                 type: LineText.TYPE_TEXT,
  //                 content: '',
  //                 weight: 0,
  //                 align: LineText.ALIGN_LEFT,
  //                 x: 500,
  //                 relativeX: 0,
  //                 linefeed: 1),
  //           );

  //           list.add(
  //             LineText(
  //                 type: LineText.TYPE_TEXT,
  //                 content: 'Bayar',
  //                 weight: 0,
  //                 align: LineText.ALIGN_LEFT,
  //                 x: 0,
  //                 relativeX: 0,
  //                 linefeed: 0),
  //           );
  //           list.add(
  //             LineText(
  //                 type: LineText.TYPE_TEXT,
  //                 content: '',
  //                 weight: 0,
  //                 align: LineText.ALIGN_LEFT,
  //                 x: 500,
  //                 relativeX: 0,
  //                 linefeed: 1),
  //           );
  //           list.add(
  //             LineText(
  //                 type: LineText.TYPE_TEXT,
  //                 content: '--------------------------------',
  //                 weight: 0,
  //                 align: LineText.ALIGN_CENTER,
  //                 linefeed: 1),
  //           );

  //           list.add(LineText(
  //               type: LineText.TYPE_TEXT,
  //               content: 'BCA : 86500 28288',
  //               weight: 0,
  //               align: LineText.ALIGN_LEFT,
  //               fontZoom: 3,
  //               linefeed: 1));

  //           list.add(
  //             LineText(
  //                 type: LineText.TYPE_TEXT,
  //                 content: 'A/N : YONNI ISKANDAR',
  //                 weight: 0,
  //                 align: LineText.ALIGN_LEFT,
  //                 fontZoom: 3,
  //                 linefeed: 1),
  //           );
  //           list.add(
  //             LineText(linefeed: 1),
  //           );
  //           list.add(
  //             LineText(
  //                 type: LineText.TYPE_TEXT,
  //                 content: 'TERIMA KASIH',
  //                 weight: 2,
  //                 align: LineText.ALIGN_CENTER,
  //                 fontZoom: 4,
  //                 linefeed: 1),
  //           );
  //           list.add(
  //             LineText(linefeed: 1),
  //           );

  //           // await bluetoothPrint.printReceipt(config, list);
  //           await bluetoothPrint.printLabel(config, list);
  //         }
  //       : null;
  // }
}
