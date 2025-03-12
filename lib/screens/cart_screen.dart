import 'dart:convert';

import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:flutter/material.dart';
import 'package:karposku/consts/mki_colors.dart';
import 'package:karposku/consts/mki_colorsv2.dart';
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

class CartScreen extends StatefulWidget {
  const CartScreen({super.key, required this.title});

  final String title;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _paymentController = TextEditingController();
  final TextEditingController _changeController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final FocusNode _focusNodeTotal = FocusNode();
  final FocusNode _focusNodePayment = FocusNode();
  final FocusNode _focusNodeChange = FocusNode();
  final FocusNode _focusNodeQty = FocusNode();

  bool isEmpty = true;
  bool isPrinterConnect = false;
  BluetoothPrint? bluetoothPrint;

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

  InvoiceData invoiceData = InvoiceData('', '', '', []);

  @override
  void initState() {
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    int intPayValue = 0;
    int intChange = 0;

    var printerProvider = Provider.of<PrinterProvider>(context);
    if (printerProvider.bluetoothPrint != null && printerProvider.isConnect) {
      bluetoothPrint = printerProvider.bluetoothPrint!;
      isPrinterConnect = printerProvider.isConnect;
    }

    if (cartListProvider.itemList.isNotEmpty) {
      isEmpty = false;
    } else {
      isEmpty = true;
    }

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: BoxDecoration(
          color: MKIColorConstv2.neutral200,
        ),
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
                      'Keranjang',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: MKIColorConstv2.neutral100,
                      ),
                    ),
                    Row(
                      children: [
                        // QR Code Button
                        IconButton(
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
                          },
                          icon: Icon(
                            Icons.qr_code,
                            color: MKIColorConstv2.neutral100,
                            size: 28,
                          ),
                        ),
                        // Payment Button
                        IconButton(
                          onPressed: () {
                            if (cartListProvider.itemList.isNotEmpty) {
                              _showPaymentDialog(context, cartListProvider,
                                  intPayValue, intChange);
                            }
                          },
                          icon: Icon(
                            Icons.payment,
                            color: MKIColorConstv2.neutral100,
                            size: 28,
                          ),
                        ),
                        // Clear Cart Button
                        IconButton(
                          onPressed: () {
                            if (!isEmpty) {
                              _showClearCartDialog(context, cartListProvider);
                            }
                          },
                          icon: Icon(
                            Icons.delete_outline,
                            color: MKIColorConstv2.neutral100,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Cart Content
            Expanded(
              child: isEmpty
                  ? _buildEmptyCart()
                  : _buildCartList(cartListProvider),
            ),

            // Total Price
            if (!isEmpty)
              _buildTotalPrice(cartListProvider, intPayValue, intChange),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: MKIColorConstv2.neutral400,
          ),
          SizedBox(height: 16),
          Text(
            'Keranjang Kosong',
            style: TextStyle(
              fontSize: 20,
              color: MKIColorConstv2.neutral500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalPrice(
      ItemsListCartProvider cartListProvider, int intPayValue, int intChange) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total Pembayaran',
                style: TextStyle(
                  fontSize: 14,
                  color: MKIColorConstv2.neutral500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Rp ${MKIVariabels.formatter.format(cartListProvider.total)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: MKIColorConstv2.secondary,
                ),
              ),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: MKIColorConstv2.secondary,
              padding: EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              if (cartListProvider.itemList.isNotEmpty) {
                _showPaymentDialog(
                    context, cartListProvider, intPayValue, intChange);
              }
            },
            child: Text(
              'Bayar Sekarang',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(ItemsListCartProvider cartListProvider) {
    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemBuilder: (BuildContext context, index) {
        String img = cartListProvider.itemList[index].itemsIcon;
        String strPrice = cartListProvider.itemList[index].itemsPrice;
        int intPrice = MKIMethods.isNumber(strPrice) ? int.parse(strPrice) : 0;
        int qty = cartListProvider.itemList[index].qty;
        int subTotal = intPrice * qty;
        final String itemsKey = cartListProvider.itemList[index].itemsId;

        return Dismissible(
          key: Key(itemsKey),
          background: Container(
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20),
            child: Icon(
              Icons.delete,
              color: Colors.red,
              size: 26,
            ),
          ),
          direction: DismissDirection.endToStart,
          confirmDismiss: (DismissDirection direction) async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  title: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        color: MKIColorConstv2.secondary,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Hapus Item',
                        style: TextStyle(
                          color: MKIColorConstv2.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  content: Text(
                    'Apakah Anda ingin menghapus item ini?',
                    style: TextStyle(
                      color: MKIColorConstv2.neutral500,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        'Tidak',
                        style: TextStyle(
                          color: MKIColorConstv2.neutral500,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MKIColorConstv2.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        cartListProvider.removeItemData(
                            cartListProvider.itemList[index].itemsId);
                        Navigator.pop(context, true);
                      },
                      child: Text(
                        'Ya',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
            return confirmed;
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: MKIColorConstv2.neutral300,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Product Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: img != ''
                          ? NetworkImage(img)
                          : AssetImage('assets/images/karbotech.png')
                              as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cartListProvider.itemList[index].itemsName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: MKIColorConstv2.secondaryDark,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Rp ${MKIVariabels.formatter.format(intPrice)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: MKIColorConstv2.neutral500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: MKIColorConstv2.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                // Decrease Button
                                IconButton(
                                  onPressed: () {
                                    if (qty > 1) {
                                      cartListProvider.decItemsQty(
                                          cartListProvider.itemList[index]);
                                    } else {
                                      cartListProvider.removeItemData(
                                          cartListProvider
                                              .itemList[index].itemsId);
                                    }
                                  },
                                  icon: Icon(
                                    Icons.remove,
                                    size: 20,
                                    color: MKIColorConstv2.secondary,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                ),
                                // Quantity
                                GestureDetector(
                                  onDoubleTap: () {
                                    String txtQty = cartListProvider
                                        .itemList[index].qty
                                        .toString();
                                    _qtyController.text = txtQty;
                                    _focusNodeQty.requestFocus();

                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                          title: Row(
                                            children: [
                                              Icon(
                                                Icons.edit_outlined,
                                                color:
                                                    MKIColorConstv2.secondary,
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                'Ubah Jumlah',
                                                style: TextStyle(
                                                  color:
                                                      MKIColorConstv2.secondary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          content: Container(
                                            decoration: BoxDecoration(
                                              color: MKIColorConstv2.neutral200,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: TextFormField(
                                              controller: _qtyController,
                                              focusNode: _focusNodeQty,
                                              keyboardType:
                                                  TextInputType.number,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: MKIColorConstv2
                                                    .secondaryDark,
                                              ),
                                              decoration: InputDecoration(
                                                hintText: 'Masukkan jumlah',
                                                hintStyle: TextStyle(
                                                  color: MKIColorConstv2
                                                      .neutral400,
                                                ),
                                                border: InputBorder.none,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                  horizontal: 15,
                                                  vertical: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: Text(
                                                'Batal',
                                                style: TextStyle(
                                                  color: MKIColorConstv2
                                                      .neutral500,
                                                ),
                                              ),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    MKIColorConstv2.secondary,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              onPressed: () {
                                                if (MKIMethods.isNumber(
                                                    _qtyController.text)) {
                                                  int tmpQty = int.parse(
                                                      _qtyController.text);
                                                  if (tmpQty <= 0) {
                                                    MKIMethods.showMessage(
                                                        context,
                                                        Colors.redAccent,
                                                        'Quantity minimal 1');
                                                  } else {
                                                    cartListProvider
                                                        .setItemsQty(
                                                            cartListProvider
                                                                    .itemList[
                                                                index],
                                                            tmpQty);
                                                    _qtyController.clear();
                                                    Navigator.pop(context);
                                                  }
                                                } else if (_qtyController.text
                                                        .trim() ==
                                                    '') {
                                                  MKIMethods.showMessage(
                                                      context,
                                                      Colors.redAccent,
                                                      'Quantity harus diisi');
                                                } else {
                                                  MKIMethods.showMessage(
                                                      context,
                                                      Colors.redAccent,
                                                      'Quantity tidak valid');
                                                }
                                              },
                                              child: Text(
                                                'Simpan',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    alignment: Alignment.center,
                                    child: Text(
                                      qty.toString(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: MKIColorConstv2.secondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                // Increase Button
                                IconButton(
                                  onPressed: () {
                                    cartListProvider.incItemsQty(
                                        cartListProvider.itemList[index]);
                                  },
                                  icon: Icon(
                                    Icons.add,
                                    size: 20,
                                    color: MKIColorConstv2.secondary,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Spacer(),
                          Text(
                            'Rp ${MKIVariabels.formatter.format(subTotal)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: MKIColorConstv2.secondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      itemCount: cartListProvider.itemList.length,
    );
  }

  Widget _buildPaymentField(
    String hint,
    TextEditingController controller,
    FocusNode focusNode,
    IconData icon, {
    bool isEnabled = true,
    Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: MKIColorConstv2.neutral200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        enabled: isEnabled,
        onChanged: onChanged,
        keyboardType: TextInputType.number,
        style: TextStyle(
          fontSize: 16,
          color: MKIColorConstv2.secondaryDark,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: MKIColorConstv2.neutral400,
          ),
          prefixIcon: Icon(
            icon,
            color: MKIColorConstv2.secondary,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  void _showPaymentDialog(BuildContext context,
      ItemsListCartProvider cartListProvider, int intPayValue, int intChange) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        _changeController.text = '0';
        _totalController.text =
            MKIVariabels.formatter.format(cartListProvider.total);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(
                Icons.payment,
                color: MKIColorConstv2.secondary,
              ),
              SizedBox(width: 10),
              Text(
                'Pembayaran',
                style: TextStyle(
                  color: MKIColorConstv2.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPaymentField(
                  "Total",
                  _totalController,
                  _focusNodeTotal,
                  Icons.monetization_on,
                  isEnabled: false,
                ),
                SizedBox(height: 15),
                _buildPaymentField(
                  "Pembayaran",
                  _paymentController,
                  _focusNodePayment,
                  Icons.payments_outlined,
                  onChanged: (val) {
                    val = _paymentController.text;
                    if (MKIMethods.isNumber(val) == false) {
                      _paymentController.text = '0';
                      return;
                    }
                    intPayValue = val == '' ? 0 : int.parse(val);
                    intChange = 0;

                    if (intPayValue > cartListProvider.total) {
                      intChange = intPayValue - cartListProvider.total;
                    }
                    _changeController.text = intChange == 0
                        ? '0'
                        : MKIVariabels.formatter.format(intChange);
                  },
                ),
                SizedBox(height: 15),
                _buildPaymentField(
                  "Kembalian",
                  _changeController,
                  _focusNodeChange,
                  Icons.monetization_on_sharp,
                  isEnabled: false,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: TextStyle(
                  color: MKIColorConstv2.neutral500,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MKIColorConstv2.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                String payment = _paymentController.text == ''
                    ? '0'
                    : _paymentController.text;

                int payValue = int.parse(payment);
                int totalVal = cartListProvider.total;

                if (payValue < totalVal) {
                  textValidation("Nilai bayar tidak valid", _focusNodePayment,
                      Colors.redAccent);
                  return;
                } else {
                  var tmpJson = jsonEncode(cartListProvider.itemList);
                  var dataPrint = {
                    '"total"': '"${cartListProvider.total}"',
                    '"list_product"': tmpJson,
                  };

                  String createResult =
                      await MKIUrls.createNewInvoice(dataPrint.toString());

                  var rs = jsonDecode(createResult);

                  if (rs['status'].toLowerCase() == 'success') {
                    String invoiceNo = rs['data']['invoice_no'];
                    List<ItemsCartData> itemsList = cartListProvider.itemList;

                    if (bluetoothPrint != null) {
                      MKIMethods.invoicePrintNew(
                        isPrinterConnect,
                        bluetoothPrint!,
                        invoiceNo,
                        itemsList,
                        intPayValue == 0
                            ? '0'
                            : MKIVariabels.formatter.format(intPayValue),
                        intChange == 0
                            ? '0'
                            : MKIVariabels.formatter.format(intChange),
                      );
                    }

                    MKIMethods.showMessage(
                        context, Colors.green, 'Invoice berhasil ditambahkan');
                    cartListProvider.clearItemsData();

                    NavigationScreen.startIndex = 1;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NavigationScreen(),
                      ),
                    );
                  } else {
                    MKIMethods.showMessage(
                        context, Colors.redAccent, 'Ada kesalahan data');
                  }
                }
              },
              child: Text(
                'Bayar',
                style: TextStyle(
                  color: Colors.white, 
                ),
              ),
            ),
          ],
        );
      },
    ).then((value) {
      _totalController.clear();
      _paymentController.clear();
      _changeController.clear();
    });
  }

  void _showClearCartDialog(
      BuildContext context, ItemsListCartProvider cartListProvider) {
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
                Icons.delete_outline,
                color: MKIColorConstv2.secondary,
              ),
              SizedBox(width: 10),
              Text(
                'Konfirmasi',
                style: TextStyle(
                  color: MKIColorConstv2.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Apakah Anda ingin menghapus keranjang?',
            style: TextStyle(
              color: MKIColorConstv2.neutral500,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Tidak',
                style: TextStyle(
                  color: MKIColorConstv2.neutral500,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MKIColorConstv2.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                cartListProvider.clearItemsData();
                Navigator.pop(context);
              },
              child: Text(
                'Ya',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
