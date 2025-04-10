import 'package:flutter/material.dart';
import 'package:karposku/consts/mki_colorsv2.dart';
import 'package:karposku/consts/mki_urls.dart';
import 'package:intl/intl.dart';
import 'package:karposku/models/invoice_packing_data.dart';
import 'package:karposku/utilities/printer_adapter.dart';
import 'package:karposku/providers/printer_provider.dart';
import 'package:provider/provider.dart';
import 'package:karposku/consts/mki_variabels.dart';

class InvoicePackingScreen extends StatefulWidget {
  const InvoicePackingScreen({super.key});

  static String routeName = 'invoice-packing-screen';

  @override
  State<InvoicePackingScreen> createState() => _InvoicePackingScreenState();
}

class _InvoicePackingScreenState extends State<InvoicePackingScreen> {
  List<InvoicePackingData> invoiceList = [];
  Map<String, String> itemsNameMap =
      {}; // Untuk menyimpan mapping items_id ke nama
  bool isLoading = true;
  BluetoothPrint? bluetoothPrint;
  bool isPrinterConnect = false;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
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

        setState(() {
          invoiceList = tempList;
          isLoading = false;
        });
      } else {
        setState(() {
          invoiceList = [];
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
                                  '${invoiceList.length} pesanan dalam proses',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.search,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                // TODO: Implementasi search
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.filter_list,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                // TODO: Implementasi filter
                              },
                            ),
                          ],
                        ),
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
                            isSelected: true,
                            onTap: () {},
                            isDark: true,
                          ),
                          _buildFilterChip(
                            'Baru',
                            count: invoiceList
                                .where((i) => i.docStatus == 'new')
                                .length,
                            onTap: () {},
                            isDark: true,
                          ),
                          _buildFilterChip(
                            'Diproses',
                            count: invoiceList
                                .where((i) => i.docStatus == 'process')
                                .length,
                            onTap: () {},
                            isDark: true,
                          ),
                          _buildFilterChip(
                            'Selesai',
                            count: invoiceList
                                .where((i) => i.docStatus == 'done')
                                .length,
                            onTap: () {},
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
                      child: invoiceList.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: invoiceList.length,
                              itemBuilder: (context, index) {
                                final invoice = invoiceList[index];
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
                      : MKIColorConstv2.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  invoice.docStatus.toUpperCase(),
                  style: TextStyle(
                    color: invoice.docStatus == 'new'
                        ? MKIColorConstv2.secondary
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
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isPrinterConnect
                            ? () => _printInvoice(invoice)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MKIColorConstv2.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          disabledBackgroundColor: MKIColorConstv2.neutral300,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
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

    Map<String, dynamic> config = {};
    List<LineText> list = [];

    // Fungsi helper untuk membuat teks center
    String centerText(String text, {int paperWidth = 32}) {
      if (text.length >= paperWidth) return text;
      int spaces = (paperWidth - text.length) ~/ 2;
      return ' ' * spaces + text + ' ' * (paperWidth - text.length - spaces);
    }

    // Fungsi helper untuk membuat teks justify (space between)
    String justifyText(String leftText, String rightText,
        {int paperWidth = 32}) {
      int totalLength = leftText.length + rightText.length;
      if (totalLength >= paperWidth) return leftText + rightText;
      int spaces = paperWidth - totalLength;
      return leftText + ' ' * spaces + rightText;
    }

    // Header
    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: centerText('KARBOTECH JAYA'),
      align: LineText.ALIGN_LEFT,
      weight: 2,
      linefeed: 1,
    ));

    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: centerText('Jl.Menganti 108'),
      align: LineText.ALIGN_LEFT,
      linefeed: 1,
    ));

    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: centerText('08217888171'),
      align: LineText.ALIGN_LEFT,
      linefeed: 1,
    ));

    // Garis pemisah
    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: '--------------------------------',
      align: LineText.ALIGN_LEFT,
      linefeed: 1,
    ));

    // Info transaksi dengan justify
    String currentDate = DateFormat('dd/MM/yy HH:mm').format(DateTime.now());
    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: justifyText('Tanggal', currentDate),
      align: LineText.ALIGN_LEFT,
      linefeed: 1,
    ));

    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: justifyText('Pelanggan', invoice.customerName),
      align: LineText.ALIGN_LEFT,
      linefeed: 1,
    ));

    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: '--------------------------------',
      align: LineText.ALIGN_LEFT,
      linefeed: 1,
    ));

    // Detail items dengan format yang lebih baik
    for (var item in invoice.detail) {
      // Nama item di baris pertama
      String itemName = item.itemsName;
      if (itemName.length > 32) {
        itemName = '${itemName.substring(0, 29)}...';
      }
      list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: itemName,
        align: LineText.ALIGN_LEFT,
        linefeed: 1,
      ));

      // Qty dan harga di baris kedua dengan justify
      String qtyPrice = justifyText(
        '${item.qty} x ${MKIVariabels.formatter.format(item.price).replaceAll('Rp ', '').replaceAll('.000', '')}',
        MKIVariabels.formatter
            .format(item.subtotal)
            .replaceAll('Rp ', '')
            .replaceAll('.000', ''),
      );
      list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: qtyPrice,
        align: LineText.ALIGN_LEFT,
        linefeed: 1,
      ));
    }

    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: '--------------------------------',
      align: LineText.ALIGN_LEFT,
      linefeed: 1,
    ));

    // Total dengan justify
    String totalAmount = MKIVariabels.formatter
        .format(invoice.total)
        .replaceAll('Rp ', '')
        .replaceAll('.000', '');
    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: justifyText('TOTAL', totalAmount),
      align: LineText.ALIGN_LEFT,
      weight: 1,
      linefeed: 1,
    ));

    // Info pembayaran
    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: centerText('BCA:86500-28288'),
      align: LineText.ALIGN_LEFT,
      linefeed: 1,
    ));

    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: centerText('A/N KARBOTECH'),
      align: LineText.ALIGN_LEFT,
      linefeed: 2,
    ));

    // Footer
    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: centerText('--Terima Kasih--'),
      align: LineText.ALIGN_LEFT,
      linefeed: 1,
    ));

    // Tambahkan beberapa baris kosong di akhir agar tidak terpotong
    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: '',
      align: LineText.ALIGN_LEFT,
      linefeed: 4,
    ));

    await bluetoothPrint?.printReceipt(config, list);
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