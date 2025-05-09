import 'package:flutter/material.dart';
import 'package:karposku/consts/mki_colorsv2.dart';
import 'package:karposku/consts/mki_urls.dart';
import 'package:intl/intl.dart';
import 'package:karposku/models/invoice_packing_data.dart';
import 'package:karposku/utilities/printer_adapter.dart';
import 'package:karposku/providers/printer_provider.dart';
import 'package:provider/provider.dart';
import 'package:karposku/consts/mki_variabels.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:karposku/utilities/local_storage.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';

class InvoicePackingScreen extends StatefulWidget {
  const InvoicePackingScreen({super.key});

  static String routeName = 'invoice-packing-screen';

  @override
  State<InvoicePackingScreen> createState() => _InvoicePackingScreenState();
}

class _InvoicePackingScreenState extends State<InvoicePackingScreen> {
  List<InvoicePackingData> invoiceList = [];
  List<InvoicePackingData> filteredInvoiceList = [];
  String selectedFilter = 'Semua';
  Map<String, String> itemsNameMap =
      {}; // Untuk menyimpan mapping items_id ke nama
  bool isLoading = true;
  BluetoothPrint? bluetoothPrint;
  bool isPrinterConnect = false;
  final TextEditingController _paymentController = TextEditingController();
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
    _getUserData();
  }

  Future<void> _getUserData() async {
    try {
      final userDataString = await LocalStorage.load('user_data');
      if (userDataString != null && userDataString != '') {
        setState(() {
          userData = json.decode(userDataString);
        });
      }
    } catch (e) {
      print('Error getting user data: $e');
    }
  }

  void filterInvoices(String filter) {
    setState(() {
      selectedFilter = filter;
      if (filter == 'Semua') {
        filteredInvoiceList = List.from(invoiceList);
      } else {
        String status = '';
        switch (filter) {
          case 'Baru':
            status = 'new';
            break;
          case 'Diproses':
            status = 'process';
            break;
          case 'Selesai':
            status = 'done';
            break;
        }
        filteredInvoiceList = invoiceList
            .where((invoice) => invoice.docStatus == status)
            .toList();
      }
    });
  }

  Future<void> _fetchAllData() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Fetch master items terlebih dahulu
      final itemsList = await MKIUrls.getItemsList();

      // Buat mapping dari items_id ke items_name
      itemsNameMap = {for (var item in itemsList) item.itemsId: item.itemsName};

      // Kemudian fetch invoice data
      final response = await MKIUrls.getInvoicePacking();

      if (response != null && response['status'] == 'success') {
        final List<InvoicePackingData> tempList = (response['data'] as List)
            .map((item) => InvoicePackingData.fromJson(item))
            .toList();

        // Update items name dalam detail
        for (var invoice in tempList) {
          for (var detail in invoice.detail) {
            if (itemsNameMap.containsKey(detail.itemsId)) {
              detail.itemsName =
                  itemsNameMap[detail.itemsId] ?? detail.itemsName;
            }
          }
        }

        // Mengurutkan data berdasarkan createdAt terbaru
        tempList.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        setState(() {
          invoiceList = tempList;
          filterInvoices(selectedFilter); // Terapkan filter yang aktif
          isLoading = false;
        });
      } else {
        setState(() {
          invoiceList = [];
          filteredInvoiceList = [];
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error in _fetchAllData: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    await _fetchAllData();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: MKIColorConstv2.neutral200,
      body: Column(
        children: [
          // Header dengan gradient (gabungan AppBar dan header)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  MKIColorConstv2.secondaryDark,
                  MKIColorConstv2.secondary.withOpacity(0.95),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.only(bottom: 20),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Actions di bagian atas (ex-AppBar)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 8, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.receipt_long,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Invoice Packing',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${invoiceList.length} Transaksi',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Row(
                        //   children: [
                        //     IconButton(
                        //       icon: const Icon(
                        //         Icons.search,
                        //         color: Colors.white,
                        //       ),
                        //       onPressed: () {
                        //         // TODO: Implementasi search
                        //       },
                        //     ),
                        //     IconButton(
                        //       icon: const Icon(
                        //         Icons.filter_list,
                        //         color: Colors.white,
                        //       ),
                        //       onPressed: () {
                        //         // TODO: Implementasi filter
                        //       },
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                  // Filter chips
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            'Semua',
                            isSelected: selectedFilter == 'Semua',
                            onTap: () => filterInvoices('Semua'),
                            isDark: true,
                          ),
                          _buildFilterChip(
                            'Baru',
                            count: invoiceList
                                .where((i) => i.docStatus == 'new')
                                .length,
                            isSelected: selectedFilter == 'Baru',
                            onTap: () => filterInvoices('Baru'),
                            isDark: true,
                          ),
                          _buildFilterChip(
                            'Selesai',
                            count: invoiceList
                                .where((i) => i.docStatus == 'done')
                                .length,
                            isSelected: selectedFilter == 'Selesai',
                            onTap: () => filterInvoices('Selesai'),
                            isDark: true,
                          ),
                          _buildFilterChip(
                            'Diproses',
                            count: invoiceList
                                .where((i) => i.docStatus == 'process')
                                .length,
                            isSelected: selectedFilter == 'Diproses',
                            onTap: () => filterInvoices('Diproses'),
                            isDark: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content section
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: MKIColorConstv2.neutral200,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: filteredInvoiceList.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredInvoiceList.length,
                              itemBuilder: (context, index) {
                                final invoice = filteredInvoiceList[index];
                                return _buildInvoiceCard(
                                    invoice, currencyFormatter);
                              },
                            ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: MKIColorConstv2.secondarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: MKIColorConstv2.secondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Invoice',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: MKIColorConstv2.secondaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Buat packing baru untuk membuat invoice',
            style: TextStyle(
              color: MKIColorConstv2.neutral500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(InvoicePackingData invoice, NumberFormat formatter) {
    // Dapatkan printer provider
    var printerProvider = Provider.of<PrinterProvider>(context);
    if (printerProvider.bluetoothPrint != null && printerProvider.isConnect) {
      bluetoothPrint = printerProvider.bluetoothPrint;
      isPrinterConnect = printerProvider.isConnect;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: MKIColorConstv2.neutral300.withOpacity(0.2),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          childrenPadding: EdgeInsets.zero,
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: MKIColorConstv2.secondarySoft.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.person_outline,
                  color: MKIColorConstv2.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoice.customerName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatter.format(invoice.total),
                      style: TextStyle(
                        color: MKIColorConstv2.primary,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: invoice.docStatus == 'new'
                      ? MKIColorConstv2.secondarySoft.withOpacity(0.2)
                      : invoice.docStatus == 'process'
                          ? MKIColorConstv2.primarySoft.withOpacity(0.2)
                          : MKIColorConstv2.primarySoft.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  invoice.docStatus == 'new'
                      ? 'Baru'
                      : invoice.docStatus == 'process'
                          ? 'Diproses'
                          : 'Selesai',
                  style: TextStyle(
                    color: invoice.docStatus == 'new'
                        ? MKIColorConstv2.secondary
                        : invoice.docStatus == 'process'
                            ? MKIColorConstv2.primary
                            : MKIColorConstv2.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          children: [
            Container(
              decoration: BoxDecoration(
                color: MKIColorConstv2.neutral100,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 16,
                          color: MKIColorConstv2.neutral500,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Detail Item (${invoice.detail.length})',
                          style: TextStyle(
                            fontSize: 13,
                            color: MKIColorConstv2.neutral600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: invoice.detail.length,
                    itemBuilder: (context, index) {
                      final item = invoice.detail[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: MKIColorConstv2.neutral200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${item.qty}x',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: MKIColorConstv2.neutral600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item.itemsName,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            Text(
                              formatter.format(item.subtotal),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: MKIColorConstv2.neutral700,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: isPrinterConnect
                              ? () => _printInvoice(invoice)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MKIColorConstv2.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            minimumSize: const Size(double.infinity, 45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            disabledBackgroundColor: MKIColorConstv2.neutral300,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.print_rounded,
                                size: 20,
                                color: isPrinterConnect
                                    ? Colors.white
                                    : MKIColorConstv2.neutral500,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isPrinterConnect
                                    ? 'Cetak Invoice'
                                    : 'Printer Tidak Terhubung',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isPrinterConnect
                                      ? Colors.white
                                      : MKIColorConstv2.neutral500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: invoice.docStatus == 'done'
                              ? null
                              : () => _showPaymentDialog(invoice),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MKIColorConstv2.secondary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            minimumSize: const Size(double.infinity, 45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            disabledBackgroundColor: MKIColorConstv2.neutral300,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.payment, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                invoice.docStatus == 'done'
                                    ? 'Pembayaran Selesai'
                                    : 'Proses Pembayaran',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Future<void> _printInvoice(InvoicePackingData invoice) async {
    if (bluetoothPrint == null) return;

    bool connected = await PrintBluetoothThermal.connectionStatus;
    if (connected) {
      List<int> bytes = [];

      // Inisialisasi generator
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);

      // Reset printer
      bytes += generator.reset();

      // Header dengan data user
      if (userData != null) {
        bytes += generator.text(
          userData!['company_name'] ?? 'Karbo Tech',
          styles: PosStyles(
            align: PosAlign.center,
            width: PosTextSize.size1,
            height: PosTextSize.size1,
            bold: true,
          ),
        );
        bytes += generator.text(
          userData!['address'] ?? 'Tangerang',
          styles: PosStyles(align: PosAlign.center),
        );
        bytes += generator.text(
          userData!['npwp'] ?? '125.120.155523.141',
          styles: PosStyles(align: PosAlign.center),
        );
      } else {
        bytes += generator.text(
          'Karbo Tech',
          styles: PosStyles(
            align: PosAlign.center,
            width: PosTextSize.size1,
            height: PosTextSize.size1,
            bold: true,
          ),
        );
        bytes += generator.text(
          'Tangerang',
          styles: PosStyles(align: PosAlign.center),
        );
        bytes += generator.text(
          '125.120.123.141',
          styles: PosStyles(align: PosAlign.center),
        );
      }

      bytes += generator.hr(); // Garis pemisah

      // Info Transaksi
      String currentDate = DateFormat('dd/MM/yy HH:mm').format(DateTime.now());
      bytes += generator.text(
        'No      : INV${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
        styles: PosStyles(align: PosAlign.left),
      );
      bytes += generator.text(
        'Tanggal : $currentDate',
        styles: PosStyles(align: PosAlign.left),
      );
      bytes += generator.text(
        'Customer: ${invoice.customerName}',
        styles: PosStyles(align: PosAlign.left),
      );

      bytes += generator.hr(); // Garis pemisah

      // Detail Items
      for (var item in invoice.detail) {
        bytes += generator.text(
          item.itemsName,
          styles: PosStyles(align: PosAlign.left),
        );

        // Format: Qty x Harga = Subtotal
        bytes += generator.row([
          PosColumn(
            text:
                '${item.qty}x${MKIVariabels.formatter.format(item.price).replaceAll('Rp ', '')}',
            width: 6,
            styles: PosStyles(align: PosAlign.left),
          ),
          PosColumn(
            text: MKIVariabels.formatter
                .format(item.subtotal)
                .replaceAll('Rp ', ''),
            width: 6,
            styles: PosStyles(align: PosAlign.right),
          ),
        ]);
      }

      bytes += generator.hr(); // Garis pemisah

      // Total
      bytes += generator.row([
        PosColumn(
          text: 'TOTAL',
          width: 6,
          styles: PosStyles(
            align: PosAlign.left,
            bold: true,
          ),
        ),
        PosColumn(
          text: MKIVariabels.formatter
              .format(invoice.total)
              .replaceAll('Rp ', ''),
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
            bold: true,
          ),
        ),
      ]);

      bytes += generator.hr(); // Garis pemisah

      // Footer
      bytes += generator.text(
        'Terima Kasih!',
        styles: PosStyles(align: PosAlign.center, bold: true),
      );
      bytes += generator.text(
        'KarposKu',
        styles: PosStyles(align: PosAlign.center),
      );
      bytes += generator.text(
        '0821 7888 1717',
        styles: PosStyles(align: PosAlign.center),
      );
      bytes += generator.text(
        'Info : https://karbo.tech/',
        styles: PosStyles(align: PosAlign.center),
      );

      // Feed paper and cut
      bytes += generator.feed(2);
      bytes += generator.cut();

      await PrintBluetoothThermal.writeBytes(bytes);
    }
  }

  void _showPaymentDialog(InvoicePackingData invoice) {
    double totalPayment = invoice.total;
    _paymentController.text = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            double payment = _paymentController.text.isEmpty
                ? 0
                : double.parse(
                    _paymentController.text.replaceAll(RegExp(r'[^0-9]'), ''));
            double change = payment - totalPayment;

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Proses Pembayaran',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.close,
                              color: MKIColorConstv2.neutral500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Total Pembayaran
                      Text(
                        'Total Pembayaran',
                        style: TextStyle(
                          fontSize: 14,
                          color: MKIColorConstv2.neutral600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        MKIVariabels.formatter.format(totalPayment),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: MKIColorConstv2.primary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Input Pembayaran
                      Text(
                        'Jumlah Pembayaran',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: MKIColorConstv2.neutral700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _paymentController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          prefixText: 'Rp ',
                          prefixStyle: TextStyle(
                            color: MKIColorConstv2.neutral700,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          filled: true,
                          fillColor: MKIColorConstv2.neutral100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: MKIColorConstv2.neutral200,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: MKIColorConstv2.primary,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 16),

                      // Kembalian (hanya muncul jika pembayaran cukup atau lebih)
                      if (_paymentController.text.isNotEmpty &&
                          payment >= totalPayment)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                MKIColorConstv2.secondarySoft.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Kembalian',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: MKIColorConstv2.secondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                MKIVariabels.formatter.format(change),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: MKIColorConstv2.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Tombol Aksi
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(
                                  color: MKIColorConstv2.neutral300,
                                ),
                              ),
                              child: Text(
                                'Batal',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: MKIColorConstv2.neutral700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: payment >= totalPayment
                                  ? () =>
                                      _processPayment(invoice, payment, change)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: MKIColorConstv2.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                disabledBackgroundColor:
                                    MKIColorConstv2.neutral300,
                              ),
                              child: const Text(
                                'Proses',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _processPayment(
      InvoicePackingData invoice, double payment, double change) async {
    try {
      // print('Processing payment for invoice ID: ${invoice.id}');

      // Validasi ID invoice
      if (invoice.id.isEmpty) {
        throw Exception('ID Invoice tidak ditemukan');
      }

      // print('Payment amount: $payment');
      // print('Change amount: $change');

      // 1. Update status invoice temporary menjadi done
      // print('Step 1: Updating invoice temporary status to done');
      final updateResult = await MKIUrls.updateInvoiceTempStatus(invoice.id);
      // print('Update result: $updateResult');

      if (updateResult['status'] != 'success') {
        throw Exception(
            updateResult['message'] ?? 'Gagal mengupdate status invoice');
      }

      // 2. Menyiapkan data untuk API invoice tetap
      // print('Step 2: Preparing data for permanent invoice');
      Map<String, dynamic> requestBody = {
        'total': invoice.total,
        'total_discount': 0,
        'total_payment': payment,
        'list_product': invoice.detail
            .map((item) => {
                  'items_id': item.itemsId,
                  'items_name': item.itemsName,
                  'qty': item.qty,
                  'price_sell': item.price,
                  'promo_value': 0,
                })
            .toList(),
      };
      // print('Request body: $requestBody');

      // 3. Proses ke invoice tetap
      // print('Step 3: Processing permanent invoice');
      final result = await MKIUrls.processInvoicePayment(requestBody);
      // print('Process result: $result');

      if (result['status'] == 'success') {
        // print('Payment process completed successfully');
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pembayaran berhasil diproses'),
            backgroundColor: Colors.green,
          ),
        );
        _fetchAllData();
      } else {
        throw Exception(result['message'] ?? 'Gagal memproses pembayaran');
      }
    } catch (e) {
      // print('Error in _processPayment: $e');
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildFilterChip(
    String label, {
    bool isSelected = false,
    int? count,
    required VoidCallback onTap,
    bool isDark = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? MKIColorConstv2.primary : Colors.white,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (count != null && count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? MKIColorConstv2.primary.withOpacity(0.1)
                      : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? MKIColorConstv2.primary : Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
