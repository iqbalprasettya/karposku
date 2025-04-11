import 'package:karposku/utilities/printer_adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:karposku/consts/mki_colors.dart';
import 'package:karposku/consts/mki_colorsv2.dart';
import 'package:karposku/providers/printer_provider.dart';
import 'package:karposku/screens/navigation_screen.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

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
  String tips = 'Tidak ada perangkat terhubung';

  // Status Bluetooth
  bool _isBluetoothAvailable = false;
  bool _isBluetoothOn = false;

  // Flutter Blue Plus
  bool _isScanning = false;
  List<fbp.ScanResult> _scanResults = [];

  // Subscriptions
  StreamSubscription? _adapterStateSubscription;
  StreamSubscription? _scanResultsSubscription;
  StreamSubscription? _bluetoothStateSubscription;

  // Tambahkan variabel untuk timeout
  Timer? _scanTimeoutTimer;
  static const Duration scanTimeout =
      Duration(seconds: 7); // Timeout setelah 7 detik

  // Tambahkan variabel untuk loading state
  bool _isInitializing = true;
  bool _isCheckingPrinter = false;
  bool _isCheckingBluetooth = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Update state dari provider terlebih dahulu
      var printerProvider =
          Provider.of<PrinterProvider>(context, listen: false);
      if (printerProvider.bluetoothPrint != null && printerProvider.isConnect) {
        setState(() {
          device = printerProvider.bluetoothDevice;
          bluetoothPrint = printerProvider.bluetoothPrint!;
          tips = printerProvider.tips;
          connectedPrinter = true;
        });
      }

      // Kemudian lanjutkan dengan inisialisasi screen
      await initializeScreen();
    });
  }

  @override
  void dispose() {
    // Batalkan semua subscription untuk mencegah memory leak
    _adapterStateSubscription?.cancel();
    _scanResultsSubscription?.cancel();
    _bluetoothStateSubscription?.cancel();
    _scanTimeoutTimer?.cancel(); // Batalkan timer

    // Pastikan untuk menghentikan scan saat widget dihapus
    if (_isScanning) {
      try {
        fbp.FlutterBluePlus.stopScan();
        setState(() {
          _isScanning = false;
          _scanResults = [];
        });
      } catch (e) {
        // Abaikan error saat menghentikan scan
      }
    }
    super.dispose();
  }

  // Modifikasi fungsi initializeScreen
  Future<void> initializeScreen() async {
    try {
      setState(() {
        _isInitializing = true;
        _isCheckingPrinter = false;
        tips = 'Memeriksa izin yang diperlukan...';
      });

      // Periksa dan minta izin terlebih dahulu
      if (Platform.isAndroid) {
        // Minta izin lokasi dan bluetooth
        Map<Permission, PermissionStatus> statuses = await [
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.locationWhenInUse,
          Permission.bluetoothAdvertise,
        ].request();

        // Periksa apakah semua izin telah diberikan
        bool allGranted = statuses.values.every((status) => status.isGranted);

        if (!allGranted) {
          setState(() {
            _isInitializing = false;
            tips = 'Izin diperlukan untuk menggunakan fitur printer';
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Beberapa izin diperlukan untuk menggunakan fitur printer'),
                backgroundColor: MKIColorConstv2.error,
                duration: Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'Pengaturan',
                  textColor: Colors.white,
                  onPressed: () => openAppSettings(),
                ),
              ),
            );
          }
          return;
        }
      }

      setState(() {
        _isCheckingPrinter = true;
        tips = 'Memeriksa printer yang terhubung...';
      });

      // Tambahkan delay 3 detik di awal
      await Future.delayed(Duration(seconds: 3));

      // Cek printer yang terhubung terlebih dahulu
      await checkConnectedPrinter();

      setState(() {
        _isCheckingPrinter = false;
        _isCheckingBluetooth = true;
        tips = 'Memeriksa status Bluetooth...';
      });

      // Kemudian cek status Bluetooth
      await checkBluetoothStatus();
    } catch (e) {
      print("Error inisialisasi screen: $e");
      if (mounted) {
        setState(() {
          tips = 'Error: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _isCheckingBluetooth = false;
        });
      }
    }
  }

  // Cek status Bluetooth
  Future<void> checkBluetoothStatus() async {
    if (!mounted) return;

    try {
      // Tambahkan di awal checkBluetoothStatus()
      if (Platform.isAndroid) {
        if (!await Permission.location.isGranted) {
          await Permission.location.request();
        }
      }

      // Cek apakah Bluetooth tersedia
      _isBluetoothAvailable = await fbp.FlutterBluePlus.isAvailable;

      if (!_isBluetoothAvailable) {
        if (mounted) {
          setState(() {
            tips = 'Bluetooth tidak tersedia pada perangkat ini';
          });
        }
        return;
      }

      // Cek apakah Bluetooth diaktifkan
      fbp.BluetoothAdapterState adapterState =
          await fbp.FlutterBluePlus.adapterState.first;
      _isBluetoothOn = adapterState == fbp.BluetoothAdapterState.on;

      if (_isBluetoothOn) {
        initBluetooth();
      } else {
        if (mounted) {
          setState(() {
            tips = 'Bluetooth tidak aktif. Silakan aktifkan Bluetooth.';
          });
        }

        // Tampilkan dialog untuk mengaktifkan Bluetooth
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showBluetoothOffDialog();
          });
        }

        // Dengarkan perubahan status adapter
        _adapterStateSubscription =
            fbp.FlutterBluePlus.adapterState.listen((state) {
          if (!mounted) return;

          setState(() {
            _isBluetoothOn = state == fbp.BluetoothAdapterState.on;
          });

          if (state == fbp.BluetoothAdapterState.on) {
            initBluetooth();
          } else {
            setState(() {
              _isScanning = false;
              tips = 'Bluetooth tidak aktif. Silakan aktifkan Bluetooth.';
            });
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          tips = 'Error: ${e.toString()}';
        });
      }
    }
  }

  // Tampilkan dialog saat Bluetooth mati
  void showBluetoothOffDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bluetooth_disabled,
                color: MKIColorConstv2.error,
              ),
              SizedBox(width: 10),
              Flexible(
                child: Text(
                  'Bluetooth Tidak Aktif',
                  style: TextStyle(
                    color: MKIColorConstv2.secondaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Untuk menggunakan fitur printer, Bluetooth harus diaktifkan.',
                style: TextStyle(
                  color: MKIColorConstv2.neutral600,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Silakan aktifkan Bluetooth pada perangkat Anda.',
                style: TextStyle(
                  color: MKIColorConstv2.neutral600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Kembali ke halaman sebelumnya
              },
              child: Text(
                'Kembali',
                style: TextStyle(
                  color: MKIColorConstv2.neutral500,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MKIColorConstv2.secondary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                // Coba buka pengaturan Bluetooth
                try {
                  if (Platform.isAndroid) {
                    await fbp.FlutterBluePlus.turnOn();
                  }
                } catch (e) {
                  // Jika gagal, tampilkan pesan
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Tidak dapat membuka pengaturan Bluetooth'),
                        backgroundColor: MKIColorConstv2.error,
                      ),
                    );
                  }
                }
              },
              child: Text('Aktifkan Bluetooth'),
            ),
          ],
        );
      },
    );
  }

  // Modifikasi fungsi checkConnectedPrinter
  Future<void> checkConnectedPrinter() async {
    try {
      print("Mengecek printer yang terhubung...");

      // Cek status koneksi langsung ke printer
      bool isConnected = await bluetoothPrint.isConnected ?? false;
      print("Status koneksi printer: $isConnected");

      if (isConnected) {
        // Jika terhubung, dapatkan daftar perangkat yang dipair
        List<BluetoothDevice> devices = await bluetoothPrint.pairedBluetooths;
        BluetoothDevice? connectedDevice;

        // Cek setiap perangkat yang dipair
        for (var d in devices) {
          // Filter hanya perangkat yang namanya mengandung 'print' atau 'RPP'
          if (d.name.toLowerCase().contains('print') ||
              d.name.toLowerCase().contains('rpp')) {
            connectedDevice = d;
            break;
          }
        }

        if (connectedDevice != null && mounted) {
          setState(() {
            device = connectedDevice;
            connectedPrinter = true;
            tips = 'Printer terhubung: ${connectedDevice!.name}';
          });

          // Update provider
          var printerProvider =
              Provider.of<PrinterProvider>(context, listen: false);
          printerProvider.seBluetoothDevice(connectedDevice);
          printerProvider.setIsConnect(bluetoothPrint);
        } else {
          // Jika tidak menemukan printer yang valid, putuskan koneksi
          await bluetoothPrint.disconnect();
          if (mounted) {
            setState(() {
              device = null;
              connectedPrinter = false;
              tips = 'Tidak ada printer terhubung';
            });
            // Clear provider
            Provider.of<PrinterProvider>(context, listen: false)
                .clearPrinterData();
          }
        }
      } else {
        if (mounted) {
          setState(() {
            connectedPrinter = false;
            device = null;
            tips = 'Tidak ada printer terhubung';
          });
          // Clear provider
          Provider.of<PrinterProvider>(context, listen: false)
              .clearPrinterData();
        }
      }
    } catch (e) {
      print("Error mengecek printer: $e");
      if (mounted) {
        setState(() {
          connectedPrinter = false;
          device = null;
          tips = 'Error: ${e.toString()}';
        });
      }
    }
  }

  // Inisialisasi Bluetooth
  Future<void> initBluetooth() async {
    if (!mounted) return;

    try {
      print("Memulai inisialisasi Bluetooth");

      // Cek printer yang terhubung terlebih dahulu
      await checkConnectedPrinter();

      // Lanjutkan dengan scan
      await fbp.FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15),
        androidUsesFineLocation: true,
        withServices: [],
      );

      _scanResultsSubscription =
          fbp.FlutterBluePlus.scanResults.listen((results) {
        if (!mounted) return;

        for (var result in results) {
          print(
              "Perangkat ditemukan: ${result.device.platformName} (${result.device.remoteId})");
        }

        setState(() {
          _scanResults = results;
        });
      });
    } catch (e) {
      print("Error inisialisasi Bluetooth: $e");
      if (mounted) {
        setState(() {
          tips = 'Error: ${e.toString()}';
        });
      }
    }
  }

  // Mulai scan perangkat Bluetooth
  void startScan() async {
    if (!mounted) return;

    // Periksa izin terlebih dahulu
    if (Platform.isAndroid) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.locationWhenInUse,
        Permission.bluetoothAdvertise,
      ].request();

      bool allGranted = statuses.values.every((status) => status.isGranted);

      if (!allGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Izin diperlukan untuk memindai perangkat'),
            backgroundColor: MKIColorConstv2.error,
            duration: Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Pengaturan',
              textColor: Colors.white,
              onPressed: () => openAppSettings(),
            ),
          ),
        );
        return;
      }
    }

    // Jika Bluetooth tidak aktif, tampilkan dialog
    if (!_isBluetoothOn) {
      showBluetoothOffDialog();
      return;
    }

    // Jika sudah terhubung ke printer, tidak perlu scan
    if (connectedPrinter) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Printer sudah terhubung'),
          backgroundColor: MKIColorConstv2.secondary,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Batalkan subscription dan timer sebelumnya jika ada
    _scanResultsSubscription?.cancel();
    _scanTimeoutTimer?.cancel();

    setState(() {
      _isScanning = true;
      _scanResults = [];
      tips = 'Mencari perangkat...';
    });

    try {
      // Set timer untuk timeout
      _scanTimeoutTimer = Timer(scanTimeout, () {
        if (mounted && _isScanning) {
          stopScan();
          setState(() {
            tips = 'Waktu pencarian habis';
          });
        }
      });

      // Mulai scan
      await fbp.FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15),
        androidUsesFineLocation: true,
      );

      // Dengarkan hasil scan
      _scanResultsSubscription = fbp.FlutterBluePlus.scanResults.listen(
        (results) {
          if (!mounted) return;

          setState(() {
            _scanResults = results;
          });

          // Jika sudah terhubung, hentikan scan
          if (connectedPrinter) {
            stopScan();
          }
        },
        onDone: () {
          if (!mounted) return;

          setState(() {
            _isScanning = false;
            if (_scanResults.isEmpty) {
              tips = 'Tidak ada perangkat ditemukan';
            } else {
              tips = 'Ditemukan ${_scanResults.length} perangkat';
            }
          });
        },
        onError: (error) {
          if (!mounted) return;

          setState(() {
            _isScanning = false;
            tips = 'Error scan: ${error.toString()}';
          });

          if (error.toString().contains('bluetooth') &&
              error.toString().contains('off')) {
            showBluetoothOffDialog();
          }
        },
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isScanning = false;
        tips = 'Error scan: ${e.toString()}';
      });

      if (e.toString().contains('bluetooth') && e.toString().contains('off')) {
        showBluetoothOffDialog();
      }
    }
  }

  // Menghentikan scan
  void stopScan() {
    try {
      fbp.FlutterBluePlus.stopScan();
      _scanResultsSubscription?.cancel();
      _scanTimeoutTimer?.cancel(); // Batalkan timer
    } catch (e) {
      print("Error menghentikan scan: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  // Modifikasi fungsi connectToDevice
  Future<void> connectToDevice(fbp.ScanResult result) async {
    if (!mounted) return;

    // Hentikan scan terlebih dahulu
    stopScan();

    try {
      // Jika sudah ada printer yang terhubung, putuskan dulu
      if (connectedPrinter) {
        await bluetoothPrint.disconnect();
        setState(() {
          device = null;
          connectedPrinter = false;
        });
        // Clear provider
        Provider.of<PrinterProvider>(context, listen: false).clearPrinterData();
      }

      setState(() {
        tips = 'Menghubungkan ke ${result.device.platformName}...';
      });

      try {
        print("Mencoba menghubungkan ke: ${result.device.platformName}");

        // Konversi ke format BluetoothDevice
        BluetoothDevice printerDevice = BluetoothDevice(
          name: result.device.platformName,
          address: result.device.remoteId.str,
        );

        // Tambahkan delay sebelum koneksi
        await Future.delayed(Duration(seconds: 1));

        // Coba koneksi
        bool connected = await bluetoothPrint.connect(printerDevice);

        if (!connected) {
          throw Exception('Gagal terhubung ke printer');
        }

        if (mounted) {
          setState(() {
            device = printerDevice;
            connectedPrinter = true;
            tips = 'Terhubung ke ${printerDevice.name}';
          });

          // Update provider
          var printerProvider =
              Provider.of<PrinterProvider>(context, listen: false);
          printerProvider.seBluetoothDevice(printerDevice);
          printerProvider.setIsConnect(bluetoothPrint);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Berhasil terhubung ke ${printerDevice.name}'),
              backgroundColor: MKIColorConstv2.secondary,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        print("Error saat koneksi: $e");
        // Jika gagal, mungkin perlu pairing
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Silakan pair printer di pengaturan Bluetooth terlebih dahulu'),
            backgroundColor: MKIColorConstv2.error,
            action: SnackBarAction(
              label: 'Pengaturan',
              textColor: Colors.white,
              onPressed: () async {
                // Buka pengaturan Bluetooth dengan cara yang berbeda
                if (Platform.isAndroid) {
                  const platform = MethodChannel('app_settings');
                  try {
                    await platform.invokeMethod('bluetooth');
                  } catch (e) {
                    print("Error membuka pengaturan: $e");
                  }
                }
              },
            ),
            duration: Duration(seconds: 4),
          ),
        );
        return;
      }
    } catch (e) {
      print("Error koneksi: $e");
      if (mounted) {
        setState(() {
          tips = 'Error koneksi: ${e.toString()}';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Gagal terhubung ke printer. Pastikan printer sudah dipair dan dalam jangkauan'),
            backgroundColor: MKIColorConstv2.error,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Tambahkan fungsi untuk disconnect printer
  Future<void> disconnectPrinter() async {
    if (!mounted) return;

    try {
      setState(() {
        tips = 'Memutuskan koneksi printer...';
      });

      // Disconnect dari printer
      bool disconnected = await bluetoothPrint.disconnect();

      if (disconnected) {
        if (mounted) {
          setState(() {
            device = null;
            connectedPrinter = false;
            tips = 'Printer terputus';
          });

          // Update provider
          var printerProvider =
              Provider.of<PrinterProvider>(context, listen: false);
          printerProvider.clearPrinterData();

          // Tampilkan snackbar sukses
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Berhasil memutuskan koneksi printer'),
              backgroundColor: MKIColorConstv2.secondary,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print("Error memutuskan koneksi: $e");
      if (mounted) {
        setState(() {
          tips = 'Error memutuskan koneksi: ${e.toString()}';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memutuskan koneksi printer'),
            backgroundColor: MKIColorConstv2.error,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MKIColorConstv2.neutral200,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Pilih Printer',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                MKIColorConstv2.secondaryDark,
                MKIColorConstv2.secondary.withOpacity(0.95),
              ],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Hentikan scan sebelum pindah screen
            if (_isScanning) {
              try {
                fbp.FlutterBluePlus.stopScan();
                setState(() {
                  _isScanning = false;
                  _scanResults = [];
                });
              } catch (e) {
                // Abaikan error saat menghentikan scan
              }
            }
            NavigationScreen.startIndex = 0;
            Navigator.pushNamedAndRemoveUntil(
              context,
              NavigationScreen.routeName,
              ModalRoute.withName('/'),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(_isScanning ? Icons.stop : Icons.refresh,
                color: Colors.white),
            onPressed: _isScanning ? stopScan : startScan,
            tooltip: _isScanning ? 'Berhenti' : 'Refresh',
          ),
        ],
      ),
      body: _isInitializing
          ? _buildLoadingScreen()
          : RefreshIndicator(
              color: MKIColorConstv2.secondary,
              onRefresh: () async {
                if (!_isScanning && mounted) {
                  startScan();
                }
              },
              child: Column(
                children: [
                  // Status Bar
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: !_isBluetoothOn
                          ? MKIColorConstv2.error.withOpacity(0.1)
                          : connectedPrinter
                              ? MKIColorConstv2.secondarySoft
                              : MKIColorConstv2.primarySoft,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: !_isBluetoothOn
                                ? MKIColorConstv2.error
                                : connectedPrinter
                                    ? MKIColorConstv2.secondary
                                    : MKIColorConstv2.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            !_isBluetoothOn
                                ? Icons.bluetooth_disabled
                                : connectedPrinter
                                    ? Icons.bluetooth_connected
                                    : Icons.bluetooth,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                !_isBluetoothOn
                                    ? 'Bluetooth Tidak Aktif'
                                    : connectedPrinter
                                        ? 'Printer Terhubung'
                                        : 'Status Printer',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: !_isBluetoothOn
                                      ? MKIColorConstv2.error
                                      : connectedPrinter
                                          ? MKIColorConstv2.secondary
                                          : MKIColorConstv2.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tips,
                                style: TextStyle(
                                  color: !_isBluetoothOn
                                      ? MKIColorConstv2.error.withOpacity(0.8)
                                      : connectedPrinter
                                          ? MKIColorConstv2.secondary
                                          : MKIColorConstv2.neutral600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (_isScanning)
                          Container(
                            width: 24,
                            height: 24,
                            margin: const EdgeInsets.only(left: 8),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  MKIColorConstv2.secondary),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Daftar Perangkat atau Pesan Bluetooth Mati
                  Expanded(
                    child: !_isBluetoothOn
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.bluetooth_disabled,
                                  size: 80,
                                  color: MKIColorConstv2.error.withOpacity(0.7),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Bluetooth tidak aktif',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: MKIColorConstv2.error,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40),
                                  child: Text(
                                    'Aktifkan Bluetooth untuk mencari dan menghubungkan printer',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: MKIColorConstv2.neutral600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: MKIColorConstv2.secondary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 2,
                                  ),
                                  onPressed: () async {
                                    try {
                                      if (Platform.isAndroid) {
                                        await fbp.FlutterBluePlus.turnOn();
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Tidak dapat mengaktifkan Bluetooth'),
                                            backgroundColor:
                                                MKIColorConstv2.error,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  icon: const Icon(Icons.bluetooth),
                                  label: const Text('Aktifkan Bluetooth'),
                                ),
                              ],
                            ),
                          )
                        : _scanResults.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.bluetooth_searching,
                                      size: 80,
                                      color: MKIColorConstv2.neutral400,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _isScanning
                                          ? 'Mencari perangkat...'
                                          : 'Tidak ada perangkat ditemukan',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: MKIColorConstv2.neutral500,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    if (!_isScanning)
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              MKIColorConstv2.secondary,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 24, vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          elevation: 2,
                                        ),
                                        onPressed: startScan,
                                        icon: const Icon(Icons.search),
                                        label: const Text('Cari Perangkat'),
                                      ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _scanResults.length,
                                itemBuilder: (context, index) {
                                  final result = _scanResults[index];
                                  final device = result.device;
                                  final name = device.platformName.isNotEmpty
                                      ? device.platformName
                                      : 'Perangkat Tidak Dikenal';

                                  // Filter hanya perangkat yang memiliki nama
                                  if (name == 'Perangkat Tidak Dikenal') {
                                    return const SizedBox.shrink();
                                  }

                                  final isConnected = this.device != null &&
                                      this.device!.address ==
                                          device.remoteId.str &&
                                      connectedPrinter;

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: MKIColorConstv2.neutral200,
                                        width: 1,
                                      ),
                                    ),
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                      leading: Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: isConnected
                                              ? MKIColorConstv2.secondary
                                              : MKIColorConstv2.neutral200,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.print,
                                          color: isConnected
                                              ? Colors.white
                                              : MKIColorConstv2.neutral500,
                                          size: 24,
                                        ),
                                      ),
                                      title: Text(
                                        name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: MKIColorConstv2.secondaryDark,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Text(
                                        device.remoteId.str,
                                        style: TextStyle(
                                          color: MKIColorConstv2.neutral500,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      trailing: isConnected
                                          ? Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12,
                                                      vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: MKIColorConstv2
                                                        .secondarySoft,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: Text(
                                                    'Terhubung',
                                                    style: TextStyle(
                                                      color: MKIColorConstv2
                                                          .secondary,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                IconButton(
                                                  icon: Icon(Icons.link_off),
                                                  color: MKIColorConstv2.error,
                                                  onPressed: () {
                                                    // Tampilkan dialog konfirmasi
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: Text(
                                                              'Putuskan Koneksi'),
                                                          content: Text(
                                                              'Apakah Anda yakin ingin memutuskan koneksi printer?'),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child:
                                                                  Text('Batal'),
                                                            ),
                                                            ElevatedButton(
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                backgroundColor:
                                                                    MKIColorConstv2
                                                                        .error,
                                                                foregroundColor:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                disconnectPrinter();
                                                              },
                                                              child: Text(
                                                                  'Putuskan'),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              ],
                                            )
                                          : ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    MKIColorConstv2.secondary,
                                                foregroundColor: Colors.white,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 8),
                                              ),
                                              onPressed: () =>
                                                  connectToDevice(result),
                                              child: const Text('Hubungkan'),
                                            ),
                                      onTap: isConnected
                                          ? null
                                          : () => connectToDevice(result),
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),

      // Tombol Test Print (jika terhubung) atau Tombol Aktifkan Bluetooth
      floatingActionButton: _isInitializing
          ? null
          : !_isBluetoothOn
              ? FloatingActionButton.extended(
                  backgroundColor: MKIColorConstv2.secondary,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  onPressed: () async {
                    try {
                      if (Platform.isAndroid) {
                        await fbp.FlutterBluePlus.turnOn();
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Tidak dapat mengaktifkan Bluetooth'),
                            backgroundColor: MKIColorConstv2.error,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.bluetooth),
                  label: const Text('Aktifkan Bluetooth'),
                )
              : connectedPrinter
                  ? FloatingActionButton.extended(
                      backgroundColor: MKIColorConstv2.secondary,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      onPressed: () async {
                        await bluetoothPrint.printTest();
                      },
                      icon: const Icon(Icons.print),
                      label: const Text('Test Print'),
                    )
                  : _isScanning
                      ? FloatingActionButton(
                          backgroundColor: MKIColorConstv2.error,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          onPressed: stopScan,
                          child: const Icon(Icons.stop),
                        )
                      : null,
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  MKIColorConstv2.secondary,
                ),
              ),
              if (_isCheckingPrinter)
                Icon(
                  Icons.print,
                  color: MKIColorConstv2.secondary.withOpacity(0.5),
                  size: 24,
                )
              else if (_isCheckingBluetooth)
                Icon(
                  Icons.bluetooth_searching,
                  color: MKIColorConstv2.secondary.withOpacity(0.5),
                  size: 24,
                ),
            ],
          ),
          SizedBox(height: 24),
          Text(
            'Mempersiapkan...',
            style: TextStyle(
              color: MKIColorConstv2.secondary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            tips,
            style: TextStyle(
              color: MKIColorConstv2.neutral600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: MKIColorConstv2.secondarySoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isCheckingPrinter ? Icons.print : Icons.bluetooth_searching,
                  color: MKIColorConstv2.secondary,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  _isCheckingPrinter
                      ? 'Memeriksa printer...'
                      : 'Memeriksa Bluetooth...',
                  style: TextStyle(
                    color: MKIColorConstv2.secondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
