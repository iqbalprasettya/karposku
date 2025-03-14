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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => checkBluetoothStatus());
  }

  @override
  void dispose() {
    // Batalkan semua subscription untuk mencegah memory leak
    _adapterStateSubscription?.cancel();
    _scanResultsSubscription?.cancel();
    _bluetoothStateSubscription?.cancel();

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

  // Cek status Bluetooth
  Future<void> checkBluetoothStatus() async {
    if (!mounted) return;

    try {
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

  // Inisialisasi Bluetooth
  Future<void> initBluetooth() async {
    if (!mounted) return;

    try {
      // Cek koneksi yang sudah ada
      bool isConnected = await bluetoothPrint.isConnected ?? false;
      if (isConnected && mounted) {
        setState(() {
          connectedPrinter = true;
          tips = 'Terhubung';
        });
      }

      // Dengarkan status koneksi
      _bluetoothStateSubscription = bluetoothPrint.state.listen((state) {
        if (!mounted) return;

        switch (state) {
          case BluetoothPrint.CONNECTED:
            setState(() {
              connectedPrinter = true;
              tips = 'Terhubung';
            });
            break;
          case BluetoothPrint.DISCONNECTED:
            setState(() {
              connectedPrinter = false;
              tips = 'Terputus';
            });
            break;
          default:
            break;
        }
      });

      // Mulai scan otomatis
      startScan();
    } catch (e) {
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

    // Jika Bluetooth tidak aktif, tampilkan dialog
    if (!_isBluetoothOn) {
      showBluetoothOffDialog();
      return;
    }

    // Batalkan subscription sebelumnya jika ada
    _scanResultsSubscription?.cancel();

    setState(() {
      _isScanning = true;
      _scanResults = [];
      tips = 'Mencari perangkat...';
    });

    try {
      // Mulai scan
      await fbp.FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15),
        androidUsesFineLocation: false,
      );

      // Dengarkan hasil scan
      _scanResultsSubscription =
          fbp.FlutterBluePlus.scanResults.listen((results) {
        if (!mounted) return;

        setState(() {
          _scanResults = results;
        });
      }, onDone: () {
        if (!mounted) return;

        setState(() {
          _isScanning = false;
          if (_scanResults.isEmpty) {
            tips = 'Tidak ada perangkat ditemukan';
          } else {
            tips = 'Ditemukan ${_scanResults.length} perangkat';
          }
        });
      }, onError: (error) {
        if (!mounted) return;

        setState(() {
          _isScanning = false;
          tips = 'Error scan: ${error.toString()}';
        });

        // Jika error karena Bluetooth mati, tampilkan dialog
        if (error.toString().contains('bluetooth') &&
            error.toString().contains('off')) {
          showBluetoothOffDialog();
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isScanning = false;
        tips = 'Error scan: ${e.toString()}';
      });

      // Jika error karena Bluetooth mati, tampilkan dialog
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
    } catch (e) {
      // Tangani error saat menghentikan scan
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  // Menghubungkan ke perangkat Bluetooth
  Future<void> connectToDevice(fbp.ScanResult result) async {
    if (!mounted) return;

    try {
      setState(() {
        tips = 'Menghubungkan ke ${result.device.platformName}...';
      });

      // Hubungkan ke perangkat
      await result.device.connect();

      // Konversi ke format BluetoothDevice yang digunakan oleh adapter
      BluetoothDevice printerDevice = BluetoothDevice(
        name: result.device.platformName,
        address: result.device.remoteId.str,
      );

      // Hubungkan menggunakan adapter
      bool connected = await bluetoothPrint.connect(printerDevice);

      if (connected && mounted) {
        setState(() {
          device = printerDevice;
          connectedPrinter = true;
          tips = 'Terhubung ke ${printerDevice.name}';
        });

        // Update provider
        if (mounted) {
          var printerProvider =
              Provider.of<PrinterProvider>(context, listen: false);
          printerProvider.seBluetoothDevice(printerDevice);
          printerProvider.setIsConnect(bluetoothPrint);
        }
      } else if (mounted) {
        setState(() {
          tips = 'Gagal terhubung ke ${printerDevice.name}';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          tips = 'Error koneksi: ${e.toString()}';
        });

        // Tampilkan dialog jika error koneksi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal terhubung: ${e.toString()}'),
            backgroundColor: MKIColorConstv2.error,
            duration: Duration(seconds: 3),
          ),
        );
      }
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
      body: RefreshIndicator(
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
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
                            padding: const EdgeInsets.symmetric(horizontal: 40),
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
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Tidak dapat mengaktifkan Bluetooth'),
                                      backgroundColor: MKIColorConstv2.error,
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
                                    backgroundColor: MKIColorConstv2.secondary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
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
                                this.device!.address == device.remoteId.str &&
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
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                leading: Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isConnected
                                        ? MKIColorConstv2.secondary
                                        : MKIColorConstv2.neutral200,
                                    borderRadius: BorderRadius.circular(12),
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
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: MKIColorConstv2.secondarySoft,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          'Terhubung',
                                          style: TextStyle(
                                            color: MKIColorConstv2.secondary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
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
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
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
      floatingActionButton: !_isBluetoothOn
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
}
