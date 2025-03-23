import 'package:flutter/material.dart';
import 'package:karposku/consts/mki_colorsv2.dart';
import 'package:karposku/consts/mki_urls.dart';
import 'package:intl/intl.dart';

class InvoicePackingScreen extends StatefulWidget {
  const InvoicePackingScreen({super.key});

  static String routeName = 'invoice-packing-screen';

  @override
  State<InvoicePackingScreen> createState() => _InvoicePackingScreenState();
}

class _InvoicePackingScreenState extends State<InvoicePackingScreen> {
  List<dynamic> invoiceList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInvoiceData();
  }

  Future<void> _fetchInvoiceData() async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await MKIUrls.getInvoicePacking();

      if (response != null && response['status'] == 'success') {
        setState(() {
          invoiceList = response['data'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          invoiceList = [];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
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
                                .where((i) => i['doc_status'] == 'new')
                                .length,
                            onTap: () {},
                            isDark: true,
                          ),
                          _buildFilterChip(
                            'Diproses',
                            count: invoiceList
                                .where((i) => i['doc_status'] == 'process')
                                .length,
                            onTap: () {},
                            isDark: true,
                          ),
                          _buildFilterChip(
                            'Selesai',
                            count: invoiceList
                                .where((i) => i['doc_status'] == 'done')
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
                      onRefresh: _fetchInvoiceData,
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

  Widget _buildInvoiceCard(
      Map<String, dynamic> invoice, NumberFormat formatter) {
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
                      invoice['customer_name'],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatter.format(invoice['total']),
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
                  color: invoice['doc_status'] == 'new'
                      ? MKIColorConstv2.secondarySoft.withOpacity(0.2)
                      : MKIColorConstv2.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  invoice['doc_status'].toUpperCase(),
                  style: TextStyle(
                    color: invoice['doc_status'] == 'new'
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
                          'Detail Item (${invoice['detail'].length})',
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
                    itemCount: invoice['detail'].length,
                    itemBuilder: (context, index) {
                      final item = invoice['detail'][index];
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
                                '${item['qty']}x',
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
                                item['items_name'] ??
                                    'Nama item tidak tersedia',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            Text(
                              formatter.format(item['subtotal']),
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
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              // TODO: Implementasi edit
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: MKIColorConstv2.secondary,
                              side: BorderSide(
                                color:
                                    MKIColorConstv2.secondary.withOpacity(0.5),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: const Text('Edit'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: Implementasi print
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: MKIColorConstv2.primary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: const Text('Cetak'),
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
