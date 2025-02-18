import 'dart:convert';

import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:flutter/material.dart';
import 'package:karposku/consts/mki_colors.dart';
import 'package:karposku/consts/mki_methods.dart';
import 'package:karposku/consts/mki_styles.dart';
import 'package:karposku/consts/mki_urls.dart';
import 'package:karposku/consts/mki_variabels.dart';
import 'package:karposku/models/invoice_data.dart';
import 'package:karposku/models/items_cart_data.dart';
import 'package:karposku/providers/items_list_cart_provider.dart';
import 'package:karposku/providers/printer_provider.dart';
import 'package:karposku/screens/navigation_screen.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

TextEditingController _totalController = TextEditingController();
TextEditingController _paymentController = TextEditingController();
TextEditingController _changeController = TextEditingController();

late FocusNode _focusNodeTotal;
late FocusNode _focusNodePayment;
late FocusNode _focusNodeChange;

TextEditingController _qtyController = TextEditingController();
late FocusNode _focusNodeQty;

class CartScreen extends StatefulWidget {
  const CartScreen({super.key, required this.title});

  final String title;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isEmpty = false;
  int paymentStatus = 0;

  // late Timer _timer;
  final int _start = 10;

  InvoiceData invoiceData = InvoiceData('', '', '', []);
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  bool isPrinterConnect = false;

  // void _startTimer() {
  //   const oneSec = Duration(seconds: 1);
  //   _timer = Timer.periodic(
  //     oneSec,
  //     (Timer timer) {
  //       if (_start == 0) {
  //         setState(() {
  //           timer.cancel();
  //           paymentStatus++;
  //         });
  //       } else {
  //         setState(() {
  //           _start--;
  //         });
  //       }
  //     },
  //   );
  // }

  @override
  void initState() {
    _focusNodeQty = FocusNode();
    _focusNodeTotal = FocusNode();
    _focusNodePayment = FocusNode();
    _focusNodeChange = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _focusNodeQty.dispose();
    _focusNodeTotal.dispose();
    _focusNodePayment.dispose();
    _focusNodeChange.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var cartListProvider =
        Provider.of<ItemsListCartProvider>(context, listen: true);

    int intPayValue = 0;
    int intChange = 0;

    void textValidation(
        String textMessage, FocusNode focusNode, Color messageColor) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: messageColor,
          content: Text(textMessage),
        ),
      );
      focusNode.requestFocus();
    }

    var printerProvider = Provider.of<PrinterProvider>(context);
    if (printerProvider.bluetoothPrint != null && printerProvider.isConnect) {
      bluetoothPrint = printerProvider.bluetoothPrint!;
      isPrinterConnect = printerProvider.isConnect;
    }

    // var cartListProvider =
    //     Provider.of<ItemsListGroupProvider>(context, listen: true);
    // var itemsList = cartListProvider.itemList;
    // double screeenWidth = MediaQuery.of(context).size.width;
    // double screenHeight = MediaQuery.of(context).size.height;

    // void textValidation(
    //     String textMessage, FocusNode focusNode, Color messageColor) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       backgroundColor: messageColor,
    //       content: Text(textMessage),
    //     ),
    //   );
    //   focusNode.requestFocus();
    // }

    // startTimer();
    // print(paymentStatus);

    if (cartListProvider.itemList.isNotEmpty) {
      isEmpty = false;
    } else {
      isEmpty = true;
    }
    // print('Jumlah List ${cartListProvider.itemList.length}');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  elevation: 5.0,
                  backgroundColor: Colors.white,
                  child: Container(
                    // width: 100,
                    height: 320,
                    padding: const EdgeInsets.all(20.0),
                    child: QrImageView(
                      data: 'This is a simple QR code',
                      version: QrVersions.auto,
                      size: 320,
                      gapless: false,
                    ),
                  ),
                );
              },
            );

            print(_start);
            if (_start == 0) {
              Navigator.of(context).pop();
            }
          },
          icon: Icon(
            Icons.qr_code,
            color: MKIColorConst.mkiWhiteBackground,
            size: 40,
          ),
        ),
        // InkWell(
        //   onTap: () {
        //     NavigationScreen.startIndex = 0;
        //     Navigator.pushNamedAndRemoveUntil(
        //       context,
        //       NavigationScreen.routeName,
        //       ModalRoute.withName('/'),
        //     );
        //   },
        //   child: Icon(
        //     Icons.close,
        //     color: MKIColorConst.mkiSilver,
        //     size: 45,
        //   ),
        // ),
        actions: [
          IconButton(
            onPressed: () {
              if (cartListProvider.itemList.isNotEmpty) {
                /* Payment Form */
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      _changeController.text = '0';
                      _totalController.text =
                          MKIVariabels.formatter.format(cartListProvider.total);
                      return AlertDialog(
                        contentPadding: EdgeInsets.zero,
                        content: Stack(
                          // overflow: Overflow.visible,
                          children: <Widget>[
                            Form(
                              key: _formKey,
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    const SizedBox(height: 60),
                                    getTextPadding(
                                      "Total",
                                      Icons.monetization_on,
                                      Colors.grey.withOpacity(0.4),
                                      _totalController,
                                      _focusNodeTotal,
                                      isEnabled: false,
                                    ),
                                    getTextPadding(
                                      "Payment",
                                      Icons.money,
                                      Colors.grey.withOpacity(0.4),
                                      _paymentController,
                                      _focusNodePayment,
                                      isFocus: true,
                                      onChanged: (val) {
                                        val = _paymentController.text;
                                        if (MKIMethods.isNumber(val) == false) {
                                          _paymentController.text = '0';
                                          return;
                                        }
                                        intPayValue =
                                            val == '' ? 0 : int.parse(val);
                                        intChange = 0;

                                        if (intPayValue >
                                            cartListProvider.total) {
                                          intChange = intPayValue -
                                              cartListProvider.total;
                                        }
                                        _changeController.text = intChange == 0
                                            ? '0'
                                            : MKIVariabels.formatter
                                                .format(intChange);
                                      },
                                    ),
                                    getTextPadding(
                                      "Change",
                                      Icons.monetization_on_sharp,
                                      Colors.grey.withOpacity(0.4),
                                      _changeController,
                                      _focusNodeChange,
                                      isEnabled: false,
                                    ),
                                    Container(
                                      alignment: Alignment.centerRight,
                                      // padding: EdgeInsets.all(10),
                                      margin: const EdgeInsets.only(
                                          right: 10, bottom: 5),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          // primary: MKIColorConst
                                          // .mainLightBlue,
                                          backgroundColor: MKIColorConst
                                              .mkiDeepBlue
                                              .withOpacity(0.7),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                        ),
                                        child: const Text(
                                          "Bayar",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        onPressed: () async {
                                          // String total = _totalController.text;
                                          String payment =
                                              _paymentController.text == ''
                                                  ? '0'
                                                  : _paymentController.text;

                                          int payValue = int.parse(payment);
                                          int totalVal = cartListProvider.total;

                                          // print(payValue);
                                          // print(totalVal);
                                          // print(confPass);
                                          // return;
                                          if (payValue < totalVal) {
                                            textValidation(
                                              "Nilai bayar tidak valid",
                                              _focusNodePayment,
                                              Colors.redAccent,
                                            );
                                            return;
                                          } else {
                                            var tmpJson = jsonEncode(
                                                cartListProvider.itemList);
                                            var dataPrint = {
                                              '"total"':
                                                  '"${cartListProvider.total}"',
                                              '"list_product"': tmpJson,
                                            };
                                            // print(dataPrint);
                                            print('Check Printer');
                                            print(
                                                'Printer Connect Status: $isPrinterConnect');
                                            // Future<bool?> st =
                                            //     bluetoothPrint.isConnected;
                                            // print(st);

                                            String createResult =
                                                await MKIUrls.createNewInvoice(
                                              dataPrint.toString(),
                                            );

                                            var rs = jsonDecode(createResult);

                                            if (rs['status'].toLowerCase() ==
                                                'success') {
                                              print(createResult);
                                              print(rs['data']['invoice_no']);

                                              String invoiceNo =
                                                  rs['data']['invoice_no'];
                                              List<ItemsCartData> itemsList =
                                                  cartListProvider.itemList;
                                              /* PRINT IS HERE */
                                              // MKIMethods.invoicePrint(
                                              //   isPrinterConnect,
                                              //   invoiceNo,
                                              //   itemsList,
                                              //   bluetoothPrint,
                                              // );

                                              MKIMethods.invoicePrintNew(
                                                isPrinterConnect,
                                                bluetoothPrint,
                                                invoiceNo,
                                                itemsList,
                                                intPayValue == 0
                                                    ? '0'
                                                    : MKIVariabels.formatter
                                                        .format(intPayValue),
                                                intChange == 0
                                                    ? '0'
                                                    : MKIVariabels.formatter
                                                        .format(intChange),
                                              );

                                              // ignore: use_build_context_synchronously
                                              MKIMethods.showMessage(
                                                  // ignore: use_build_context_synchronously
                                                  context,
                                                  Colors.green,
                                                  'Invoice berhasil ditambahkan');
                                              cartListProvider.clearItemsData();

                                              NavigationScreen.startIndex = 1;
                                              Navigator.pushReplacement(
                                                // ignore: use_build_context_synchronously
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const NavigationScreen(),
                                                ),
                                              );
                                            } else {
                                              // ignore: use_build_context_synchronously
                                              MKIMethods.showMessage(
                                                  // ignore: use_build_context_synchronously
                                                  context,
                                                  Colors.redAccent,
                                                  'Ada kesalahan data');
                                            }
                                          }
                                          // if (_formKey.currentState
                                          //     .validate()) {
                                          //   _formKey.currentState.save();
                                          // }
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              left: 0,
                              child: Container(
                                height: 60,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                    gradient: MKIColorConst.mainGoldBlueAppBar,
                                    // color:
                                    // MKIColorConst.mainToscaBlue,
                                    // color: Colors.yellow
                                    //     .withOpacity(0.2),
                                    border: Border(
                                        bottom: BorderSide(
                                            color:
                                                Colors.grey.withOpacity(0.3)))),
                                child: Container(
                                  padding: const EdgeInsets.only(left: 30),
                                  alignment: Alignment.centerLeft,
                                  child: const Text(
                                    "Pembayaran",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 20,
                                        fontStyle: FontStyle.italic,
                                        fontFamily: "Helvetica"),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 12,
                              top: 15.0,
                              child: InkResponse(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundColor: MKIColorConst.mkiDeepBlue
                                      .withOpacity(0.7),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).then((value) {
                  _totalController.clear();
                  _paymentController.clear();
                  _changeController.clear();
                });
              }
            },
            /* Payment */
            icon: Icon(
              Icons.attach_money_outlined,
              color: MKIColorConst.mkiWhiteBackground,
              size: 40,
            ),
          ),
          IconButton(
            onPressed: () {
              if (!isEmpty) {
                showDialog<void>(
                  context: context,
                  barrierDismissible: false, // user must tap button!
                  builder: (BuildContext context) {
                    return AlertDialog(
                      // surfaceTintColor: Colors.amber,
                      // backgroundColor: Colors.yellow,
                      title: const Center(child: Text('Konfirmasi')),
                      content: const SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            // Text('This is a demo alert dialog.'),
                            Text('Apakah Anda ingin menghapus keranjang?'),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Container(
                            width: 65,
                            height: 35,
                            decoration: BoxDecoration(
                                color: MKIColorConst.mkiDeepBlue,
                                borderRadius: BorderRadius.circular(30)),
                            child: const Center(
                              child: Text(
                                'YA',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          onPressed: () {
                            cartListProvider.clearItemsData();
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Container(
                            width: 65,
                            height: 35,
                            decoration: BoxDecoration(
                                color: MKIColorConst.mkiDeepBlue,
                                borderRadius: BorderRadius.circular(30)),
                            child: const Center(
                              child: Text(
                                'TIDAK',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            },
            icon: Icon(
              Icons.delete_forever,
              color: MKIColorConst.mkiWhiteBackground,
              size: 40,
            ),
          ),
        ],
        centerTitle: true,
        title: Text(
          'CART',
          style: TextStyle(color: MKIColorConst.mainBlue),
        ),
        backgroundColor: MKIColorConst.mainToscaBlue,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: MKIColorConst.mainGoldBlueAppBar,
          ),
        ),
      ),
      body: isEmpty
          ? Center(
              child: Text(
                'Cart Is Empty !',
                style: TextStyle(
                  color: MKIColorConst.mkiDeepBlue,
                  fontSize: 30,
                ),
              ),
            )
          : ListView.builder(
              itemBuilder: (BuildContext context, index) {
                String img = cartListProvider.itemList[index].itemsIcon;
                String strPrice = cartListProvider.itemList[index].itemsPrice;
                int intPrice =
                    MKIMethods.isNumber(strPrice) ? int.parse(strPrice) : 0;
                int qty = cartListProvider.itemList[index].qty;
                int subTotal = intPrice * qty;
                // String strSubTotal = subTotal.toString();
                final String itemsKey =
                    cartListProvider.itemList[index].itemsId;
                return Dismissible(
                  key: Key(itemsKey),
                  confirmDismiss: (DismissDirection direction) async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Hapus dari list?'),
                          actions: [
                            Container(
                              width: 65,
                              height: 35,
                              decoration: BoxDecoration(
                                  color: MKIColorConst.mkiDeepBlue,
                                  borderRadius: BorderRadius.circular(30)),
                              child: TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text(
                                  'No',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 65,
                              height: 35,
                              decoration: BoxDecoration(
                                  color: MKIColorConst.mkiDeepBlue,
                                  borderRadius: BorderRadius.circular(30)),
                              child: TextButton(
                                onPressed: () {
                                  cartListProvider.removeItemData(
                                      cartListProvider.itemList[index].itemsId);
                                  Navigator.pop(context, true);
                                },
                                child: const Text(
                                  'Yes',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          ],
                        );
                      },
                    );
                    // log('Deletion confirmed: $confirmed');
                    return confirmed;
                  },
                  child: MKIStyles.mkiCartTileNew(
                    context,
                    /* Left Image */
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: img != ''
                          ? Image.network(
                              img,
                            )
                          : Image.asset('assets/images/karbotech.png'),
                    ),
                    cartListProvider.itemList[index].itemsName,
                    MKIVariabels.formatter.format(intPrice),
                    cartListProvider.itemList[index].qty.toString(),
                    MKIVariabels.formatter.format(subTotal),

                    /* Increase & Decrease Button */
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        /* Decrease Button */
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            // borderRadius: BorderRadius.circular(17),
                          ),
                          height: 55,
                          child: InkWell(
                            child: Icon(
                              Icons.remove_circle,
                              color: MKIColorConst.mkiDeepBlue,
                              size: 31,
                            ),
                            onTap: () {
                              if (qty > 1) {
                                cartListProvider.decItemsQty(
                                    cartListProvider.itemList[index]);
                              } else {
                                cartListProvider.removeItemData(
                                    cartListProvider.itemList[index].itemsId);
                              }
                            },
                          ),
                        ),
                        /* QTY */
                        GestureDetector(
                          onDoubleTap: () {
                            // print('Doble Tap');
                            String txtQty =
                                cartListProvider.itemList[index].qty.toString();
                            _qtyController.text = txtQty;
                            // _qtyController.selection;
                            _focusNodeQty.requestFocus();
                            // _qtyController.selection;
                            showDialog(
                                context: context,
                                builder: (BuildContext ctx) {
                                  return AlertDialog(
                                    content: Stack(
                                      children: [
                                        // Positioned(
                                        //   top: 0,
                                        //   left: 0,
                                        //   child: Container(
                                        //     height: 60,
                                        //     width: MediaQuery.of(context)
                                        //         .size
                                        //         .width,
                                        //     decoration: BoxDecoration(
                                        //       gradient: MKIColorConst
                                        //           .mainGoldBlueAppBar,
                                        //       border: Border(
                                        //         bottom: BorderSide(
                                        //           color: Colors.grey
                                        //               .withOpacity(0.3),
                                        //         ),
                                        //       ),
                                        //     ),
                                        //     child: Container(
                                        //       padding: const EdgeInsets.only(
                                        //           left: 30),
                                        //       alignment: Alignment.centerLeft,
                                        //       child: const Text(
                                        //         "Quantity",
                                        //         style: TextStyle(
                                        //             color: Colors.white,
                                        //             fontWeight: FontWeight.w700,
                                        //             fontSize: 20,
                                        //             fontStyle: FontStyle.italic,
                                        //             fontFamily: "Helvetica"),
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
                                        // Positioned(
                                        //   right: 12,
                                        //   top: 15,
                                        //   child: IconButton(
                                        //     onPressed: () {
                                        //       print('Close');
                                        //     },
                                        //     icon: Icon(Icons.close),
                                        //   ),
                                        // ),
                                        // Positioned(
                                        //   right: 12,
                                        //   top: 15.0,
                                        //   child: InkResponse(
                                        //     onTap: () {
                                        //       Navigator.pop(context);
                                        //     },
                                        //     child: CircleAvatar(
                                        //       radius: 12,
                                        //       backgroundColor: MKIColorConst
                                        //           .mkiDeepBlue
                                        //           .withOpacity(0.7),
                                        //       child: const Icon(
                                        //         Icons.close,
                                        //         color: Colors.white,
                                        //         size: 18,
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
                                        Form(
                                          key: _formKey,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                // const SizedBox(height: 30),
                                                getTextPaddingQty(
                                                  "Qty",
                                                  // Icons.key,
                                                  Colors.grey.withOpacity(0.4),
                                                  _qtyController,
                                                  _focusNodeQty,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    /* Cancel Button */
                                                    Container(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      margin:
                                                          const EdgeInsets.only(
                                                              right: 10,
                                                              bottom: 5),
                                                      child: ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              MKIColorConst
                                                                  .mkiDeepBlue
                                                                  .withOpacity(
                                                                      0.7),
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30),
                                                          ),
                                                        ),
                                                        child: const Text(
                                                          " Batal ",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        onPressed: () async {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      ),
                                                    ),
                                                    /* Save Button */
                                                    Container(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      margin:
                                                          const EdgeInsets.only(
                                                              right: 10,
                                                              bottom: 5),
                                                      child: ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              MKIColorConst
                                                                  .mkiDeepBlue
                                                                  .withOpacity(
                                                                      0.7),
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30),
                                                          ),
                                                        ),
                                                        child: const Text(
                                                          "Ubah",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        onPressed: () async {
                                                          if (MKIMethods
                                                              .isNumber(
                                                                  _qtyController
                                                                      .text)) {
                                                            int tmpQty =
                                                                int.parse(
                                                                    _qtyController
                                                                        .text);
                                                            if (tmpQty <= 0) {
                                                              MKIMethods.showMessage(
                                                                  context,
                                                                  Colors
                                                                      .redAccent,
                                                                  'Quantity minimal 1');
                                                            } else {
                                                              cartListProvider
                                                                  .setItemsQty(
                                                                cartListProvider
                                                                        .itemList[
                                                                    index],
                                                                tmpQty,
                                                              );
                                                              _qtyController
                                                                  .clear();
                                                              Navigator.pop(
                                                                  context);
                                                            }
                                                          } else if (_qtyController
                                                                  .text
                                                                  .trim() ==
                                                              '') {
                                                            MKIMethods.showMessage(
                                                                context,
                                                                Colors
                                                                    .redAccent,
                                                                'Quantity harus diisi');
                                                          } else {
                                                            MKIMethods.showMessage(
                                                                context,
                                                                Colors
                                                                    .redAccent,
                                                                'Quantity tidak valid');
                                                          }
                                                          // int tmpQty = MKIMethods
                                                          //         .isNumber(
                                                          //             _qtyController
                                                          //                 .text)
                                                          //     ? int.parse(
                                                          //         _qtyController
                                                          //             .text)
                                                          //     : 0;
                                                          // cartListProvider
                                                          //     .itemList[index]
                                                          //     .qty = tmpQty;

                                                          // String strQty =
                                                          //     _qtyController
                                                          //         .text;
                                                          // if (strQty.trim() ==
                                                          //         '' ||
                                                          //     _qtyController
                                                          //         .text
                                                          //         .isEmpty) {
                                                          //   MKIMethods.showMessage(
                                                          //       context,
                                                          //       Colors
                                                          //           .redAccent,
                                                          //       'Quantity tidak boleh kosong');
                                                          // } else if (strQty
                                                          //         .trim() ==
                                                          //     '0') {
                                                          //   MKIMethods.showMessage(
                                                          //       context,
                                                          //       Colors
                                                          //           .redAccent,
                                                          //       'Quantity minimal 1');
                                                          // } else if (!MKIMethods
                                                          //     .isNumber(
                                                          //         strQty)) {
                                                          //   MKIMethods.showMessage(
                                                          //       context,
                                                          //       Colors
                                                          //           .redAccent,
                                                          //       'Angka tidak valid');

                                                          // Navigator.pop(context);
                                                        },
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            width: 35,
                            child: Center(
                              child: Text(
                                cartListProvider.itemList[index].qty.toString(),
                                style: TextStyle(fontSize: 17),
                              ),
                            ),
                          ),
                        ),
                        /* Increase Button */
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            // borderRadius: BorderRadius.circular(17),
                          ),
                          height: 55,
                          child: InkWell(
                            child: Icon(
                              Icons.add_circle,
                              color: MKIColorConst.mkiDeepBlue,
                              size: 31,
                            ),
                            onTap: () {
                              cartListProvider.incItemsQty(
                                  cartListProvider.itemList[index]);
                            },
                          ),
                        ),
                      ],
                    ),
                    index,
                  ),
                );
              },
              itemCount: cartListProvider.itemList.length,
            ),
      bottomSheet: Container(
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.5),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        height: 32,
        width: MediaQuery.of(context).size.width * 0.5,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                const Text(
                  '  Rp.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  cartListProvider.total > 0
                      ? MKIVariabels.formatter.format(cartListProvider.total)
                      : '0',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                )
              ],
            ),
            // Container(
            //   // color: Colors.yellowAccent,
            //   margin: EdgeInsets.only(right: 15),
            //   height: 32,
            //   width: 80,
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.circular(30),
            //     color: MKIColorConst.mkiDeepBlue.withOpacity(0.7),
            //   ),
            //   child: MaterialButton(
            //     onPressed: () {
            //       // var tmpJson = jsonEncode(cartListProvider.itemList);
            //       // print(tmpJson);
            //       if (cartListProvider.itemList.isNotEmpty) {
            //         Timer(const Duration(seconds: 1), () async {
            //           var tmpJson = jsonEncode(cartListProvider.itemList);
            //           var dataPrint = {
            //             '"total"': '"${cartListProvider.total}"',
            //             '"list_product"': tmpJson,
            //           };
            //           // print(dataPrint);
            //           String status = await MKIUrls.createNewInvoice(
            //             dataPrint.toString(),
            //           );

            //           if (status.toLowerCase() == 'success') {
            //             // ignore: use_build_context_synchronously
            //             MKIMethods.showMessage(
            //                 // ignore: use_build_context_synchronously
            //                 context,
            //                 Colors.green,
            //                 'Invoice berhasil ditambahkan');
            //             cartListProvider.clearItemsData();

            //             NavigationScreen.startIndex = 1;
            //             Navigator.pushReplacement(
            //               // ignore: use_build_context_synchronously
            //               context,
            //               MaterialPageRoute(
            //                 builder: (context) => const NavigationScreen(),
            //               ),
            //             );
            //           } else {
            //             // ignore: use_build_context_synchronously
            //             MKIMethods.showMessage(
            //                 // ignore: use_build_context_synchronously
            //                 context,
            //                 Colors.redAccent,
            //                 'Ada kesalahan data');
            //           }
            //         });
            //       }
            //     },
            //     child: const Text(
            //       'Bayar',
            //       style: TextStyle(
            //         fontSize: 17,
            //         color: Colors.white,
            //       ),
            //     ),
            //   ),
            // ),

            // Container(
            //   height: 35,
            //   width: screeenWidth * 0.45,
            //   decoration:
            //       BoxDecoration(borderRadius: BorderRadius.circular(25)),
            //   color: MKIColorConst.mkiYellow,
            // )
          ],
        ),
      ),
    );

    // return OrientationBuilder(
    //   builder: (context, orientation) {
    //     return screeenOrientation(context, orientation, [
    //       Container(
    //         color: MKIColorConst.mkiGoldLight,
    //         width: orientation == Orientation.portrait
    //             ? screeenWidth
    //             : screeenWidth * 0.65,
    //         height: orientation == Orientation.portrait
    //             ? screenHeight * 0.6
    //             : screenHeight,
    //         child: isEmpty
    //             ? Center(
    //                 child: Text(
    //                   'Cart Is Empty !',
    //                   style: TextStyle(
    //                     color: MKIColorConst.mkiDeepBlue,
    //                     fontSize: 30,
    //                   ),
    //                 ),
    //               )
    //             : ListView.builder(
    //                 itemBuilder: (BuildContext context, index) {
    //                   String img = cartListProvider.itemList[index].itemsIcon;
    //                   return Container(
    //                       margin: const EdgeInsets.only(top: 4, bottom: 5),
    //                       padding: const EdgeInsets.only(left: 5, right: 5),
    //                       color: index.isOdd
    //                           ? MKIColorConst.mkiWhiteBackground
    //                               .withOpacity(0.1)
    //                           : MKIColorConst.mkiSeaBlue.withOpacity(0.1),
    //                       width: screeenWidth,
    //                       height: 50,
    //                       child: Row(
    //                         mainAxisAlignment: MainAxisAlignment.start,
    //                         children: [
    //                           Container(
    //                             child: img != ''
    //                                 ? Image.network(
    //                                     img,
    //                                     height: 60,
    //                                     fit: BoxFit.cover,
    //                                   )
    //                                 : Image.asset(
    //                                     'assets/images/karbotech.png'),
    //                           ),
    //                           Container(),
    //                           Container(),
    //                         ],
    //                       ));
    //                 },
    //                 itemCount: cartListProvider.itemList.length,
    //               ),
    //       ),
    //       Container(
    //         color: Colors.amber,
    //         width: orientation == Orientation.portrait
    //             ? screeenWidth
    //             : screeenWidth * 0.35,
    //         height: orientation == Orientation.portrait
    //             ? screenHeight * 0.3
    //             : screenHeight,
    //       ),
    //     ]);
    //   },
    // );
  }

  Widget screeenOrientation(
      BuildContext context, Orientation orientation, List<Widget> items) {
    return orientation == Orientation.portrait
        ? SingleChildScrollView(
            child: Column(
              children: items,
            ),
          )
        : Row(
            children: items,
          );
  }

  Padding getTextPaddingQty(
    String hintText,
    // IconData icon,
    Color iconColor,
    TextEditingController textController,
    FocusNode focusNode,
  ) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.2))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expanded(
            //   flex: 1,
            //   child: Container(
            //     width: 30,
            //     decoration: BoxDecoration(
            //         border: Border(
            //             right:
            //                 BorderSide(color: Colors.grey.withOpacity(0.2)))),
            //     child: Center(
            //       child: Icon(
            //         icon,
            //         size: 25,
            //         // color: Colors.grey.withOpacity(0.4),
            //         color: iconColor,
            //       ),
            //     ),
            //   ),
            // ),
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: textController,
                focusNode: focusNode,
                obscureText: false,
                keyboardType: TextInputType.numberWithOptions(signed: true),
                decoration: InputDecoration(
                  hintText: hintText,
                  contentPadding: const EdgeInsets.only(left: 10),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  hintStyle: const TextStyle(
                      color: Colors.black26,
                      fontSize: 18,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Padding getTextPadding(
  String hintText,
  IconData icon,
  Color iconColor,
  TextEditingController textController,
  FocusNode focusNode, {
  bool isEnabled = true,
  bool isFocus = false,
  final Function(String)? onChanged,
}) {
  return Padding(
    padding: const EdgeInsets.all(5.0),
    child: Container(
      height: 40,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.2))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              width: 30,
              decoration: BoxDecoration(
                  border: Border(
                      right: BorderSide(color: Colors.grey.withOpacity(0.2)))),
              child: Center(
                child: Icon(
                  icon,
                  size: 25,
                  // color: Colors.grey.withOpacity(0.4),
                  color: iconColor,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: TextFormField(
              controller: textController,
              focusNode: focusNode,
              obscureText: false,
              keyboardType: TextInputType.number,
              enabled: isEnabled,
              autofocus: isFocus,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hintText,
                contentPadding: const EdgeInsets.only(left: 20),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                hintStyle: const TextStyle(
                    color: Colors.black26,
                    fontSize: 22,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
