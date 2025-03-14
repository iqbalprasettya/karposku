import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

// Kelas untuk menggantikan BluetoothDevice dari bluetooth_print
class BluetoothDevice {
  final String name;
  final String address;

  BluetoothDevice({required this.name, required this.address});

  // Konversi dari BluetoothInfo ke BluetoothDevice
  factory BluetoothDevice.fromBluetoothInfo(BluetoothInfo info) {
    return BluetoothDevice(
      name: info.name,
      address: info.macAdress,
    );
  }
}

// Kelas untuk menggantikan LineText dari bluetooth_print
class LineText {
  static const int TYPE_TEXT = 0;
  static const int TYPE_BARCODE = 1;
  static const int TYPE_QRCODE = 2;
  static const int TYPE_IMAGE = 3;
  static const int ALIGN_LEFT = 0;
  static const int ALIGN_CENTER = 1;
  static const int ALIGN_RIGHT = 2;

  final int? type;
  final String? content;
  final int? size;
  final int? align;
  final int? weight;
  final int? width;
  final int? height;
  final int? fontZoom;
  final int? linefeed;
  final int? x;
  final int? y;
  final int? relativeX;

  LineText({
    this.type,
    this.content,
    this.size,
    this.align,
    this.weight,
    this.width,
    this.height,
    this.fontZoom,
    this.linefeed,
    this.x,
    this.y,
    this.relativeX,
  });
}

// Kelas untuk menggantikan BluetoothPrint dari bluetooth_print
class BluetoothPrint {
  static const int CONNECTED = 1;
  static const int DISCONNECTED = 0;

  static final BluetoothPrint _instance = BluetoothPrint._internal();
  static BluetoothPrint get instance => _instance;

  BluetoothPrint._internal();

  // Getter untuk status scanning
  Stream<bool> get isScanning async* {
    yield false; // Selalu false karena print_bluetooth_thermal tidak memiliki metode scan
  }

  // Stream untuk hasil scan
  Stream<List<BluetoothDevice>> get scanResults async* {
    final devices = await pairedBluetooths;
    yield devices;
  }

  // Mendapatkan daftar perangkat Bluetooth yang sudah dipasangkan
  Future<List<BluetoothDevice>> get pairedBluetooths async {
    final List<BluetoothInfo> devices =
        await PrintBluetoothThermal.pairedBluetooths;
    return devices
        .map((device) => BluetoothDevice.fromBluetoothInfo(device))
        .toList();
  }

  // Memulai scan perangkat Bluetooth
  Future<void> startScan({Duration? timeout}) async {
    // Tidak perlu implementasi karena print_bluetooth_thermal tidak memiliki metode scan
    // Kita hanya menggunakan pairedBluetooths
  }

  // Menghentikan scan perangkat Bluetooth
  Future<void> stopScan() async {
    // Tidak perlu implementasi karena print_bluetooth_thermal tidak memiliki metode scan
  }

  // Menghubungkan ke perangkat Bluetooth
  Future<bool> connect(BluetoothDevice device) async {
    return await PrintBluetoothThermal.connect(
        macPrinterAddress: device.address);
  }

  // Memutuskan koneksi dari perangkat Bluetooth
  Future<bool> disconnect() async {
    return await PrintBluetoothThermal.disconnect;
  }

  // Memeriksa apakah terhubung ke perangkat Bluetooth
  Future<bool?> get isConnected async {
    return await PrintBluetoothThermal.connectionStatus;
  }

  // Stream untuk status koneksi
  Stream<int> get state async* {
    bool isConnected = await PrintBluetoothThermal.connectionStatus;
    yield isConnected ? CONNECTED : DISCONNECTED;
  }

  // Mencetak teks uji
  Future<bool> printTest() async {
    bool connected = await PrintBluetoothThermal.connectionStatus;
    if (connected) {
      List<int> bytes = [];
      bytes += await _textToBytes("=========================\n");
      bytes += await _textToBytes("PRINT TEST\n");
      bytes += await _textToBytes("=========================\n\n");
      return await PrintBluetoothThermal.writeBytes(bytes);
    }
    return false;
  }

  // Mencetak struk
  Future<bool> printReceipt(
      Map<String, dynamic> config, List<LineText> list) async {
    bool connected = await PrintBluetoothThermal.connectionStatus;
    if (connected) {
      List<int> bytes = [];

      for (var line in list) {
        if (line.type == LineText.TYPE_TEXT) {
          String text = line.content ?? "";
          if (line.linefeed != null && line.linefeed! > 0) {
            text += "\n" * line.linefeed!;
          }

          int size = line.size ?? 1;
          if (size < 1) size = 1;
          if (size > 5) size = 5;

          if (line.align == LineText.ALIGN_CENTER) {
            // Menambahkan spasi di awal untuk perataan tengah
            int textLength = text.length;
            int padding = (32 - textLength) ~/ 2;
            if (padding > 0) {
              text = " " * padding + text;
            }
          } else if (line.align == LineText.ALIGN_RIGHT) {
            // Menambahkan spasi di awal untuk perataan kanan
            int textLength = text.length;
            int padding = 32 - textLength;
            if (padding > 0) {
              text = " " * padding + text;
            }
          }

          bytes += await PrintBluetoothThermal.writeString(
                  printText: PrintTextSize(size: size, text: text))
              ? [1]
              : [0];
        } else if (line.type == LineText.TYPE_BARCODE) {
          // Implementasi cetak barcode
          bytes += await _textToBytes("${line.content}\n");
        } else if (line.type == LineText.TYPE_QRCODE) {
          // Implementasi cetak QR code
          bytes += await _textToBytes("${line.content}\n");
        } else if (line.type == LineText.TYPE_IMAGE) {
          // Implementasi cetak gambar
          if (line.content != null) {
            List<int> imageBytes = base64Decode(line.content!);
            bytes += imageBytes;
          }
        }
      }

      return bytes.isNotEmpty;
    }
    return false;
  }

  // Mencetak label (sama dengan printReceipt untuk kompatibilitas)
  Future<bool> printLabel(
      Map<String, dynamic> config, List<LineText> list) async {
    return await printReceipt(config, list);
  }

  // Mengkonversi teks ke bytes
  Future<List<int>> _textToBytes(String text) async {
    return text.codeUnits;
  }
}
