import 'package:karposku/utilities/printer_adapter.dart';
import 'package:flutter/material.dart';

class PrinterProvider with ChangeNotifier {
  // late PrinterData _printerData = PrinterData(
  //   connectedPrinter: false,
  //   device: null,
  //   bluetoothPrint: null,
  //   tips: '',
  // );
  late bool _isConnect = false;
  late BluetoothDevice? _bluetoothDevice;
  late BluetoothPrint? _bluetoothPrint = BluetoothPrint.instance;
  String _tips = '';

  bool get isConnect {
    return _isConnect;
  }

  BluetoothDevice? get bluetoothDevice {
    return _bluetoothDevice;
  }

  BluetoothPrint? get bluetoothPrint {
    return _bluetoothPrint;
  }

  String get tips {
    return _tips;
  }

  void setIsConnect(BluetoothPrint bluetoothPrint) async {
    _isConnect = (await bluetoothPrint.isConnected)!;
    if (isConnect) {
      _tips = 'Connected ${bluetoothDevice!.name}';
      _bluetoothPrint = bluetoothPrint;
    } else {
      _tips = 'Disconnect';
    }
    notifyListeners();
  }

  void seBluetoothDevice(BluetoothDevice bluetoothDevice) {
    _bluetoothDevice = bluetoothDevice;
    notifyListeners();
  }

  // void setBluetoothPrint(BluetoothPrint bluetoothPrint) {
  //   _bluetoothPrint = bluetoothPrint;
  //   notifyListeners();
  // }

  // void setTips(String tips) {
  //   _tips = tips;
  //   notifyListeners();
  // }
  // PrinterData get printerData {
  //   return _printerData;
  // }

  // void addUserData(UserData userData) {
  //   _userData.add(userData);
  //   notifyListeners();
  // }

  // void addPrinterData(PrinterData printerData) {
  //   _printerData = PrinterData(
  //     connectedPrinter: printerData.connectedPrinter,
  //     device: printerData.device,
  //     bluetoothPrint: printerData.bluetoothPrint,
  //     tips: printerData.tips,
  //   );
  //   notifyListeners();
  // }

  void clearPrinterData() {
    _isConnect = false;
    _bluetoothDevice = null;
    _bluetoothPrint = null;
    _tips = '';
  }
}
