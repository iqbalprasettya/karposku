import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:karposku/consts/mki_colors.dart';
import 'package:karposku/consts/mki_methods.dart';
import 'package:karposku/consts/mki_urls.dart';
import 'package:karposku/consts/mki_variabels.dart';
import 'package:karposku/models/invoice_data.dart';
import 'package:karposku/providers/printer_provider.dart';
import 'package:karposku/screens/navigation_screen.dart';
import 'package:provider/provider.dart';

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({super.key});

  static String routeName = 'invoice-screen';
  static String reportPeriod = '';

  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  // Future<InvoiceData> getDoData() {
  InvoiceData invoiceData = InvoiceData('', '', '', []);
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  bool isPrinterConnect = false;
  String strTotal = '0';
  int intTotal = 0;
  void setDoData() async {
    // print(InvoiceListScreen.reportPeriod);
    invoiceData =
        await MKIUrls.fetchInvoiceList(InvoiceListScreen.reportPeriod);
    // print('Get Invoice');
    strTotal = invoiceData.total;
    intTotal = int.parse(strTotal);
    // print(intTotal);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    setDoData();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    var printerProvider = Provider.of<PrinterProvider>(context);
    if (printerProvider.bluetoothPrint != null && printerProvider.isConnect) {
      bluetoothPrint = printerProvider.bluetoothPrint!;
      isPrinterConnect = printerProvider.isConnect;
    }

    strTotal = invoiceData.total;
    // var invoiceDataProvider = Provider.of<InvoiceListProvider>(context);
    // Future<String> dataProvider = invoiceDataProvider.getExistsData();

    // var doInvList = Provider.of<DoInvoiceProvider>(context, listen: true);
    // var invData = doInvList.invoiceData;
    // doInvList.removeListener(() {});
    // setDoData();

    return Scaffold(
      body: invoiceData.data.isNotEmpty
          ? ListView.separated(
              itemBuilder: ((context, invoiceIdx) {
                String strGrandTotal = invoiceData.data[invoiceIdx].grandTotal;

                double dblGrandTotal = double.parse(strGrandTotal);
                int intGrandTotal = dblGrandTotal.toInt();
                String fmGrandTotal =
                    MKIVariabels.formatter.format(intGrandTotal);

                // String strNilaiBayar = doData.data[invoiceIdx].nilaiBayar;
                // double dblNilaiBayar = double.parse(strNilaiBayar);
                // int intNilaiBayar = dblNilaiBayar.toInt();
                // String fmNilaiBayar =
                //     MKIVariabels.formatter.format(intNilaiBayar);

                // int vBayar = intNilaiBayar;

                /* INVOICE HEADER */
                return Semantics(
                  label: 'List data from database',
                  child: ExpansionTile(
                    textColor: MKIColorConst.mkiSeaBlue,
                    collapsedTextColor: MKIColorConst.mkiDeepBlueLogo,
                    iconColor: MKIColorConst.mkiSeaBlue,
                    title: Text(
                      invoiceData.data[invoiceIdx].invoiceNo,
                      style: TextStyle(
                        fontSize: 17,
                        color: invoiceData.data[invoiceIdx].invoiceStatus ==
                                "Reject"
                            ? Colors.redAccent
                            : MKIColorConst.mkiSeaBlue,
                      ),
                    ),
                    subtitle: Text(
                      invoiceData.data[invoiceIdx].invoiceStatus == "Reject"
                          ? "${invoiceData.data[invoiceIdx].invoiceDate} (Rejected)"
                          : invoiceData.data[invoiceIdx].invoiceDate,
                      style: TextStyle(
                        fontSize: 14,
                        color: invoiceData.data[invoiceIdx].invoiceStatus ==
                                "Reject"
                            ? Colors.redAccent
                            : MKIColorConst.mkiSeaBlue,
                      ),
                    ),
                    leading: const Icon(Icons.list_alt_outlined),
                    children: [
                      /* ITEMS OF INVOICE */
                      ListView.builder(
                          shrinkWrap: true, // 1st add
                          physics: const ClampingScrollPhysics(), // 2nd add
                          itemCount:
                              invoiceData.data[invoiceIdx].itemsData.length,
                          itemBuilder: (_, itemsIdx) {
                            // var formatter = NumberFormat('#,##,000');
                            // print(formatter.format(16987));

                            return Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    MKIMethods.showMessage(
                                      context,
                                      Colors.redAccent,
                                      'Status data sudah tidak bisa edit',
                                    );
                                  },
                                  child: invoiceTile(
                                    tileColor: MKIColorConst.mkiGreyInvdata3,
                                    leftPadding: screenWidth * 0.1,
                                    marginLeft: screenWidth * 0.05,
                                    marginRight: screenWidth * 0.05,
                                    itemsCode: invoiceData.data[invoiceIdx]
                                        .itemsData[itemsIdx].itemsCode,
                                    itemsName: invoiceData.data[invoiceIdx]
                                        .itemsData[itemsIdx].itemsName,
                                    itemsQty: invoiceData.data[invoiceIdx]
                                        .itemsData[itemsIdx].qty,
                                    // gallonQty: doData.data[invoiceIdx]
                                    // .itemsData[itemsIdx].gallonQty,
                                    itemsPrice: invoiceData.data[invoiceIdx]
                                        .itemsData[itemsIdx].price,
                                    subTotal: invoiceData.data[invoiceIdx]
                                        .itemsData[itemsIdx].subtotal,
                                  ),
                                ),
                              ],
                            );
                          }),
                      Container(
                        padding: EdgeInsets.only(
                          left: screenWidth * 0.1,
                        ),
                        margin: EdgeInsets.only(
                          left: screenWidth * 0.05,
                          right: screenWidth * 0.05,
                        ),
                        color: MKIColorConst.mkiGreyInvdata3,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total      ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              // 'SUM INVOICE',
                              // doData.data[invoiceIdx].sumTotalInvoice,
                              fmGrandTotal,
                              style: TextStyle(
                                color: MKIColorConst.mkiGoldDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                          left: screenWidth * 0.1,
                        ),
                        margin: EdgeInsets.only(
                          left: screenWidth * 0.05,
                          right: screenWidth * 0.05,
                        ),
                        color: MKIColorConst.mkiGreyInvdata3,
                        alignment: Alignment.centerLeft,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Text(
                            //   'Bayar      ',
                            //   style: TextStyle(
                            //     fontWeight: FontWeight.bold,
                            //   ),
                            // ),
                            // Text(
                            //   fmNilaiBayar == '000' ? '0' : fmNilaiBayar,
                            //   // 'NILAI BAYAR',
                            //   // doData.data[invoiceIdx].nilaiBayar,
                            //   // '${jsonData['data'][invoiceIdx]['nilai_bayar']}',
                            //   style: TextStyle(
                            //     color: MKIColorConst.mkiGoldDark,
                            //     fontWeight: FontWeight.bold,
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      const Divider(thickness: 1),
                      Container(
                        margin: const EdgeInsets.only(top: 5, bottom: 5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    // primary: MKIColorConst.mainLightBlue,
                                    backgroundColor: MKIColorConst.mkiDeepBlue
                                        .withOpacity(0.7),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  onPressed: isPrinterConnect
                                      ? () async {
                                          Map<String, dynamic> config = {};
                                          List<LineText> list = [];
                                          list.add(
                                            LineText(
                                                type: LineText.TYPE_TEXT,
                                                content:
                                                    '================================',
                                                weight: 0,
                                                align: LineText.ALIGN_CENTER,
                                                linefeed: 1),
                                          );
                                          /* LOGO */
                                          // list.add(LineText(
                                          //     width: 20,
                                          //     height: 20,
                                          //     fontZoom: 3,
                                          //     type: LineText.TYPE_IMAGE,
                                          //     content: base64Image,
                                          //     align: LineText.ALIGN_CENTER,
                                          //     linefeed: 0));

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
                                              content:
                                                  '================================',
                                              weight: 0,
                                              align: LineText.ALIGN_CENTER,
                                              linefeed: 1));

                                          list.add(LineText(
                                              type: LineText.TYPE_TEXT,
                                              content:
                                                  'Tanggal  : ${MKIMethods.getIndCurrentDate()}',
                                              weight: 0,
                                              align: LineText.ALIGN_LEFT,
                                              fontZoom: 1,
                                              linefeed: 1));

                                          list.add(LineText(
                                              type: LineText.TYPE_TEXT,
                                              content:
                                                  // 'Tanggal  : ${doData.data[invoiceIdx].invoiceNo}',
                                                  'Inv No   : ${invoiceData.data[invoiceIdx].invoiceNo}',
                                              weight: 0,
                                              align: LineText.ALIGN_LEFT,
                                              fontZoom: 1,
                                              linefeed: 1));
                                          list.add(
                                            LineText(
                                                type: LineText.TYPE_TEXT,
                                                content:
                                                    '--------------------------------',
                                                weight: 0,
                                                align: LineText.ALIGN_CENTER,
                                                linefeed: 1),
                                          );

                                          double tmpTotal = 0;
                                          int intTotal = 0;
                                          String strTotal = '';
                                          for (var element in invoiceData
                                              .data[invoiceIdx].itemsData) {
                                            double tPrice =
                                                double.parse(element.price);
                                            var subTotal = element.qty * tPrice;
                                            tmpTotal += subTotal;

                                            var strSubTotal = MKIVariabels
                                                .formatter
                                                .format(subTotal);

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
                                                  content:
                                                      '  ${element.qty} x ${element.price}',
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
                                          strTotal = MKIVariabels.formatter
                                              .format(intTotal);

                                          list.add(
                                            LineText(
                                                type: LineText.TYPE_TEXT,
                                                content:
                                                    '--------------------------------',
                                                weight: 0,
                                                align: LineText.ALIGN_CENTER,
                                                linefeed: 1),
                                          );

                                          list.add(
                                            LineText(
                                                type: LineText.TYPE_TEXT,
                                                content: 'Total',
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
                                                x: 500,
                                                relativeX: 0,
                                                linefeed: 1),
                                          );

                                          // list.add(
                                          //   LineText(
                                          //       type: LineText.TYPE_TEXT,
                                          //       content: 'Bayar',
                                          //       weight: 0,
                                          //       align: LineText.ALIGN_LEFT,
                                          //       x: 0,
                                          //       relativeX: 0,
                                          //       linefeed: 0),
                                          // );
                                          // list.add(
                                          //   LineText(
                                          //       type: LineText.TYPE_TEXT,
                                          //       content: '',
                                          //       weight: 0,
                                          //       align: LineText.ALIGN_LEFT,
                                          //       x: 500,
                                          //       relativeX: 0,
                                          //       linefeed: 1),
                                          // );
                                          list.add(
                                            LineText(
                                                type: LineText.TYPE_TEXT,
                                                content:
                                                    '--------------------------------',
                                                weight: 0,
                                                align: LineText.ALIGN_CENTER,
                                                linefeed: 1),
                                          );

                                          list.add(LineText(
                                              type: LineText.TYPE_TEXT,
                                              content: 'BCA : 86500 28288',
                                              weight: 0,
                                              align: LineText.ALIGN_LEFT,
                                              fontZoom: 3,
                                              linefeed: 1));

                                          list.add(
                                            LineText(
                                                type: LineText.TYPE_TEXT,
                                                content: 'A/N : KARBOTECH',
                                                weight: 0,
                                                align: LineText.ALIGN_LEFT,
                                                fontZoom: 3,
                                                linefeed: 1),
                                          );
                                          list.add(
                                            LineText(linefeed: 1),
                                          );
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

                                          await bluetoothPrint.printReceipt(
                                              config, list);
                                        }
                                      : null,
                                  icon: const Icon(Icons.print),
                                  label: const FittedBox(
                                    child: Text(
                                      'Print',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                                /* Only The Sameday can be Edited */
                                if (InvoiceListScreen.reportPeriod ==
                                        MKIVariabels.dailyData &&
                                    invoiceData
                                            .data[invoiceIdx].invoiceStatus !=
                                        "Reject")
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      // primary: MKIColorConst.mainLightBlue,
                                      backgroundColor: MKIColorConst.mkiDeepBlue
                                          .withOpacity(0.7),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    onPressed: (() async {
                                      // print(doData.data[invoiceIdx].id);
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            AlertDialog(
                                          title: const Text('Konfirmasi'),
                                          content: Text(
                                              'Batalkan Invoice: ${invoiceData.data[invoiceIdx].invoiceNo}?'),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () => Navigator.pop(
                                                  context, 'Cancel'),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                // print('ok');
                                                String status = await MKIUrls
                                                    .invoiceRejection(
                                                        invoiceData
                                                            .data[invoiceIdx]
                                                            .id);
                                                // String status = "success";
                                                if (status == 'success') {
                                                  // ignore: use_build_context_synchronously
                                                  MKIMethods.showMessage(
                                                    // ignore: use_build_context_synchronously
                                                    context,
                                                    Colors.green,
                                                    'Reject invoice berhasil',
                                                  );

                                                  Future.delayed(
                                                    Duration.zero,
                                                    (() async {
                                                      NavigationScreen
                                                          .startIndex = 3;
                                                      Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              const NavigationScreen(),
                                                        ),
                                                      );
                                                    }),
                                                  );
                                                } else {
                                                  // ignore: use_build_context_synchronously
                                                  MKIMethods.showMessage(
                                                    // ignore: use_build_context_synchronously
                                                    context,
                                                    Colors.redAccent,
                                                    'Gagal reject invoice',
                                                  );
                                                }
                                                // ignore: use_build_context_synchronously
                                                Navigator.pop(context, 'OK');
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        ),
                                      );
                                      // Navigator.pushNamed(
                                      //   context,
                                      //   SignatureScreen.routeName,
                                      //   arguments:
                                      //       doData.data[invoiceIdx].invoiceNo,
                                      // );
                                    }),
                                    child: const FittedBox(
                                      child: Text(
                                        '  Reject  ',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                );
              }),
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(
                color: Colors.transparent,
              ),
              itemCount: invoiceData.data.length,
            )
          : Center(
              child: Text(
                'Data Tidak Ditemukan',
                style: TextStyle(fontSize: 20, color: MKIColorConst.mainBlue),
              ),
            ),
      bottomSheet: Container(
        padding: const EdgeInsets.only(left: 10, right: 10),
        color: Colors.grey.withOpacity(0.3),
        height: screenHeight * 0.06,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Text(
              "TOTAL",
              style: TextStyle(
                // fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              invoiceData.data.isNotEmpty
                  ? "${MKIVariabels.formatter.format(intTotal)},-"
                  : "0",
              // "Rp. $strTotal,-",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                // color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget invoiceTile({
    required Color tileColor,
    required double leftPadding,
    required double marginLeft,
    required double marginRight,
    required String itemsCode,
    required String itemsName,
    required int itemsQty,
    // required int gallonQty,
    required String itemsPrice,
    required String subTotal,
  }) {
    double dblPrice = double.parse(itemsPrice);
    int intPrice = dblPrice.toInt();
    String fmPrice = MKIVariabels.formatter.format(intPrice);

    double dblSubTotal = double.parse(subTotal);
    int intSubTotal = dblSubTotal.toInt();
    String fmSubTotal = MKIVariabels.formatter.format(intSubTotal);

    return ListView.builder(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: 1,
      itemBuilder: ((context, index) {
        return Column(
          children: [
            Container(
              padding: EdgeInsets.only(left: leftPadding, top: 2),
              margin: EdgeInsets.only(
                left: marginLeft,
                right: marginRight,
              ),
              color: tileColor,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  const Text(
                    'Kode    ',
                  ),
                  Text(
                    itemsCode,
                    style: TextStyle(color: MKIColorConst.mkiGoldDark),
                  ),
                ],
              ),
            ),
            Container(
              // decoration: BoxDecoration(
              // color: tileColor,
              // borderRadius: const BorderRadius.only(
              // topLeft: Radius.circular(15),
              // topRight: Radius.circular(15),
              // ),
              // ),
              padding: EdgeInsets.only(left: leftPadding),
              margin: EdgeInsets.only(
                left: marginLeft,
                right: marginRight,
              ),
              color: tileColor,

              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  const Text('Name   '),
                  Text(
                    itemsName,
                    style: TextStyle(color: MKIColorConst.mkiGoldDark),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: leftPadding),
              margin: EdgeInsets.only(
                left: marginLeft,
                right: marginRight,
              ),
              color: tileColor,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  const Text('Qty      '),
                  Text(
                    itemsQty.toString(),
                    style: TextStyle(color: MKIColorConst.mkiGoldDark),
                  ),
                ],
              ),
            ),
            // Container(
            //   padding: EdgeInsets.only(left: leftPadding),
            //   margin: EdgeInsets.only(
            //     left: marginLeft,
            //     right: marginRight,
            //   ),
            //   color: tileColor,
            //   alignment: Alignment.centerLeft,
            //   child: Row(
            //     children: [
            //       const Text('Galon  '),
            //       Text(
            //         gallonQty.toString(),
            //         style: TextStyle(color: MKIColorConst.mkiGoldDark),
            //       ),
            //     ],
            //   ),
            // ),
            Container(
              decoration: BoxDecoration(
                color: tileColor,
                // borderRadius: const BorderRadius.only(
                // bottomLeft: Radius.circular(15),
                // bottomRight: Radius.circular(15),
                // ),
              ),
              padding: EdgeInsets.only(left: leftPadding),
              margin: EdgeInsets.only(
                left: marginLeft,
                right: marginRight,
              ),
              // color: MKIColorConst.mkiSilver,
              alignment: Alignment.centerLeft,
              // child: Text(itemsPrice),
              child: Row(
                children: [
                  const Text('Harga  '),
                  Text(
                    fmPrice,
                    style: TextStyle(color: MKIColorConst.mkiGoldDark),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: tileColor,
                // borderRadius: const BorderRadius.only(
                // bottomLeft: Radius.circular(15),
                // bottomRight: Radius.circular(15),
                // ),
              ),
              padding: EdgeInsets.only(left: leftPadding, bottom: 2),
              margin: EdgeInsets.only(
                left: marginLeft,
                right: marginRight,
              ),
              // color: MKIColorConst.mkiSilver,
              alignment: Alignment.centerLeft,
              // child: Text(itemsPrice),
              child: Row(
                children: [
                  const Text('Total    '),
                  Text(
                    fmSubTotal,
                    style: TextStyle(color: MKIColorConst.mkiGoldDark),
                  ),
                ],
              ),
            ),
            const Divider(thickness: 1),
          ],
        );
      }),
    );
  }
}
