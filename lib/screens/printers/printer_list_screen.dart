import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:karposku/consts/mki_colors.dart';
import 'package:karposku/providers/printer_provider.dart';
import 'package:karposku/screens/navigation_screen.dart';
import 'package:provider/provider.dart';

/*
 Cara Konek Printer Bluetooth :
    1. Siapkan printer bluetooth dan pastikan hidup
    2. Pada android, hidupkan bluetooth dan pair priinter BT nya
    3. Hidupkan Location
    4. Pada menu Home, pilih Icon Printer
    5. Pilih Nama Printernya, klik tombol Connect
 */

class PrinterListScreen extends StatefulWidget {
  const PrinterListScreen({super.key});

  @override
  State<PrinterListScreen> createState() => _PrinterListScreenState();
}

class _PrinterListScreenState extends State<PrinterListScreen> {
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  bool connectedPrinter = false;
  BluetoothDevice? device;
  String tips = 'No device connect';

  // PrinterData printerData = PrinterData(
  //   connectedPrinter: false,
  //   device: null,
  //   bluetoothPrint: null,
  //   tips: '',
  // );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => initBluetooth());
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initBluetooth() async {
    bluetoothPrint.startScan(timeout: const Duration(seconds: 4));
    bool isConnected = await bluetoothPrint.isConnected ?? false;
    bluetoothPrint.state.listen((state) {
      // print('******************* cur device status: $state');
      switch (state) {
        case BluetoothPrint.CONNECTED:
          setState(() {
            // MKIVariabels.connectedPrinter = true;
            // LocalStorage.save(MKIVariabels.printerStatusKey, true);
            connectedPrinter = true;
            tips = 'Connect Success';
            // printerData.connectedPrinter = connectedPrinter;
            // printerData.tips = tips;
          });
          break;
        case BluetoothPrint.DISCONNECTED:
          setState(() {
            // MKIVariabels.connectedPrinter = false;
            // LocalStorage.save(MKIVariabels.printerStatusKey, false);
            connectedPrinter = false;
            tips = 'Disconnect Success';
            // printerData.connectedPrinter = connectedPrinter;
            // printerData.tips = tips;
          });
          break;
        default:
          break;
      }
      // print('Status ${MKIVariabels.connectedPrinter}');
    });

    if (!mounted) return;

    if (isConnected) {
      setState(() {
        connectedPrinter = true;
        tips = 'Connect Success';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var printerProvider = Provider.of<PrinterProvider>(context);
    if (printerProvider.bluetoothPrint != null && printerProvider.isConnect) {
      device = printerProvider.bluetoothDevice;
      bluetoothPrint = printerProvider.bluetoothPrint!;
      tips = printerProvider.tips;
      connectedPrinter = printerProvider.isConnect;
    } else {
      connectedPrinter = false;
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Select Printer',
          style: TextStyle(color: MKIColorConst.mainBlue),
        ),
        // backgroundColor: MKIColorConst.mainToscaBlue,
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
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            bluetoothPrint.startScan(timeout: const Duration(seconds: 4)),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    child: Text(tips),
                  ),
                ],
              ),
              const Divider(),
              StreamBuilder<List<BluetoothDevice>>(
                stream: bluetoothPrint.scanResults,
                initialData: const [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data!
                      .map((d) => ListTile(
                            title: Text(d.name ?? ''),
                            subtitle: Text(d.address ?? ''),
                            onTap: () async {
                              setState(() {
                                device = d;
                                // printerData.device = device;
                                printerProvider.seBluetoothDevice(device!);
                              });
                            },
                            trailing:
                                device != null && device!.address == d.address
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.green,
                                      )
                                    : null,
                          ))
                      .toList(),
                ),
              ),
              const Divider(),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 5, 20, 10),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            // primary: MKIColorConst.mainLightBlue,
                            backgroundColor: MKIColorConst.mainLightBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: connectedPrinter
                              ? null
                              : () async {
                                  // print('Status : $connectedPrinter');
                                  if (device != null &&
                                      device!.address != null) {
                                    setState(() {
                                      tips = 'Connecting...';
                                    });
                                    await bluetoothPrint.connect(device!);
                                    setState(() {
                                      printerProvider
                                          .setIsConnect(bluetoothPrint);
                                      // printerProvider
                                      //     .setBluetoothPrint(bluetoothPrint);
                                    });

                                    // print('Cek : ${printerProvider.tips}');
                                  } else {
                                    setState(() {
                                      tips = 'Please select device';
                                    });
                                    // print('Please select device');
                                  }
                                  // ignore: use_build_context_synchronously
                                  // Navigator.pop(context);
                                },
                          child: const Text(' Connect '),
                        ),
                        const SizedBox(width: 10.0),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            // primary: MKIColorConst.mainLightBlue,
                            backgroundColor: MKIColorConst.mainLightBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: connectedPrinter
                              ? () async {
                                  // print(connectedPrinter);
                                  setState(() {
                                    tips = 'Disconnecting...';
                                  });
                                  await bluetoothPrint.disconnect();
                                  printerProvider.clearPrinterData();
                                  // ignore: use_build_context_synchronously
                                  // Navigator.pop(context);
                                }
                              : null,
                          child: const Text('Disconnect'),
                        ),
                      ],
                    ),
                    const Divider(),
                    // OutlinedButton(
                    //   onPressed: MKIVariabels.connectedPrinter
                    //       ? () async {
                    //           Map<String, dynamic> config = {};

                    //           List<LineText> list = [];

                    //           list.add(LineText(
                    //               type: LineText.TYPE_TEXT,
                    //               content:
                    //                   '**********************************************',
                    //               weight: 1,
                    //               align: LineText.ALIGN_CENTER,
                    //               linefeed: 1));
                    //           list.add(LineText(
                    //               type: LineText.TYPE_TEXT,
                    //               content: '打印单据头',
                    //               weight: 1,
                    //               align: LineText.ALIGN_CENTER,
                    //               fontZoom: 2,
                    //               linefeed: 1));
                    //           list.add(LineText(linefeed: 1));

                    //           list.add(LineText(
                    //               type: LineText.TYPE_TEXT,
                    //               content:
                    //                   '----------------------明细---------------------',
                    //               weight: 1,
                    //               align: LineText.ALIGN_CENTER,
                    //               linefeed: 1));
                    //           list.add(LineText(
                    //               type: LineText.TYPE_TEXT,
                    //               content: '物资名称规格型号',
                    //               weight: 1,
                    //               align: LineText.ALIGN_LEFT,
                    //               x: 0,
                    //               relativeX: 0,
                    //               linefeed: 0));
                    //           list.add(LineText(
                    //               type: LineText.TYPE_TEXT,
                    //               content: '单位',
                    //               weight: 1,
                    //               align: LineText.ALIGN_LEFT,
                    //               x: 350,
                    //               relativeX: 0,
                    //               linefeed: 0));
                    //           list.add(LineText(
                    //               type: LineText.TYPE_TEXT,
                    //               content: '数量',
                    //               weight: 1,
                    //               align: LineText.ALIGN_LEFT,
                    //               x: 500,
                    //               relativeX: 0,
                    //               linefeed: 1));

                    //           list.add(LineText(
                    //               type: LineText.TYPE_TEXT,
                    //               content: '混凝土C30',
                    //               align: LineText.ALIGN_LEFT,
                    //               x: 0,
                    //               relativeX: 0,
                    //               linefeed: 0));
                    //           list.add(LineText(
                    //               type: LineText.TYPE_TEXT,
                    //               content: '吨',
                    //               align: LineText.ALIGN_LEFT,
                    //               x: 350,
                    //               relativeX: 0,
                    //               linefeed: 0));
                    //           list.add(LineText(
                    //               type: LineText.TYPE_TEXT,
                    //               content: '12.0',
                    //               align: LineText.ALIGN_LEFT,
                    //               x: 500,
                    //               relativeX: 0,
                    //               linefeed: 1));

                    //           list.add(LineText(
                    //               type: LineText.TYPE_TEXT,
                    //               content:
                    //                   '**********************************************',
                    //               weight: 1,
                    //               align: LineText.ALIGN_CENTER,
                    //               linefeed: 1));
                    //           list.add(LineText(linefeed: 1));

                    //           ByteData data = await rootBundle
                    //               .load("assets/images/camera.png");
                    //           List<int> imageBytes = data.buffer.asUint8List(
                    //               data.offsetInBytes, data.lengthInBytes);
                    //           // String base64Image = base64Encode(imageBytes);
                    //           // list.add(LineText(type: LineText.TYPE_IMAGE, content: base64Image, align: LineText.ALIGN_CENTER, linefeed: 1));

                    //           await bluetoothPrint.printReceipt(config, list);
                    //         }
                    //       : null,
                    //   child: const Text('print receipt(esc)'),
                    // ),
                    // OutlinedButton(
                    //   onPressed: connectedPrinter
                    //       ? () async {
                    //           Map<String, dynamic> config = Map();
                    //           config['width'] = 40; // 标签宽度，单位mm
                    //           config['height'] = 70; // 标签高度，单位mm
                    //           config['gap'] = 2; // 标签间隔，单位mm

                    //           // x、y坐标位置，单位dpi，1mm=8dpi
                    //           List<LineText> list = [];
                    //           list.add(LineText(
                    //               type: LineText.TYPE_TEXT,
                    //               x: 10,
                    //               y: 10,
                    //               content: 'A Title'));
                    //           list.add(LineText(
                    //               type: LineText.TYPE_TEXT,
                    //               x: 10,
                    //               y: 40,
                    //               content: 'this is content'));
                    //           list.add(LineText(
                    //               type: LineText.TYPE_QRCODE,
                    //               x: 10,
                    //               y: 70,
                    //               content: 'qrcode i\n'));
                    //           list.add(LineText(
                    //               type: LineText.TYPE_BARCODE,
                    //               x: 10,
                    //               y: 190,
                    //               content: 'qrcode i\n'));

                    //           List<LineText> list1 = [];
                    //           ByteData data = await rootBundle
                    //               .load("assets/images/camera.png");
                    //           List<int> imageBytes = data.buffer.asUint8List(
                    //               data.offsetInBytes, data.lengthInBytes);
                    //           String base64Image = base64Encode(imageBytes);
                    //           list1.add(LineText(
                    //             type: LineText.TYPE_IMAGE,
                    //             x: 10,
                    //             y: 10,
                    //             content: base64Image,
                    //           ));

                    //           await bluetoothPrint.printLabel(config, list);
                    //           await bluetoothPrint.printLabel(config, list1);
                    //         }
                    //       : null,
                    //   child: const Text('print label(tsc)'),
                    // ),
                    // OutlinedButton(
                    //   onPressed: connectedPrinter
                    //       ? () async {
                    //           await bluetoothPrint.printTest();
                    //         }
                    //       : null,
                    //   child: const Text('print selftest'),
                    // )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
