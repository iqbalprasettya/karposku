import 'package:flutter/material.dart';
import 'package:karposku/consts/mki_colorsv2.dart';
import 'package:karposku/consts/mki_urls.dart';
import 'package:intl/intl.dart';

class PackingHistoryScreen extends StatefulWidget {
  const PackingHistoryScreen({super.key});

  static String routeName = 'packing-history-screen';

  @override
  State<PackingHistoryScreen> createState() => _PackingHistoryScreenState();
}

class _PackingHistoryScreenState extends State<PackingHistoryScreen> {
  bool isLoading = true;
  Map<String, dynamic> packingHistoryData = {
    'status': 'success',
    'message': 'data retrieved successfully',
    'data': []
  };

  @override
  void initState() {
    super.initState();
    _loadPackingHistory();
  }

  Future<void> _loadPackingHistory() async {
    try {
      final response = await MKIUrls.getPackingHistory(
          limit: 0); // limit 0 untuk mengambil semua data
      if (response['status'] == 'success') {
        setState(() {
          packingHistoryData = response;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error mengambil data riwayat: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });
    await _loadPackingHistory();
  }

  Widget _buildRiwayatItem(
      String invNo, String items, String amount, String customerName) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MKIColorConstv2.neutral100,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: MKIColorConstv2.neutral200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: MKIColorConstv2.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  color: MKIColorConstv2.neutral100,
                  size: 20,
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invNo,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: MKIColorConstv2.secondaryDark,
                      ),
                    ),
                    if (customerName.isNotEmpty) ...[
                      SizedBox(height: 4),
                      Text(
                        'Pelanggan: $customerName',
                        style: TextStyle(
                          color: MKIColorConstv2.neutral500,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    SizedBox(height: 4),
                    Text(
                      items,
                      style: TextStyle(
                        color: MKIColorConstv2.neutral500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(
            color: MKIColorConstv2.neutral200,
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total:',
                style: TextStyle(
                  color: MKIColorConstv2.neutral500,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Rp $amount',
                style: TextStyle(
                  color: MKIColorConstv2.primaryLight,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: MKIColorConstv2.neutral100,
        ),
        title: Text(
          'Riwayat Packing',
          style: TextStyle(
            color: MKIColorConstv2.neutral100,
            fontWeight: FontWeight.bold,
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
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: MKIColorConstv2.secondary,
        backgroundColor: MKIColorConstv2.neutral100,
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: MKIColorConstv2.secondary,
                ),
              )
            : packingHistoryData['data'].isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 64,
                          color: MKIColorConstv2.neutral300,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Belum ada riwayat packing',
                          style: TextStyle(
                            color: MKIColorConstv2.neutral500,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: EdgeInsets.all(20),
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: packingHistoryData['data'].map<Widget>((item) {
                      String items = item['detail'].join(', ');
                      return _buildRiwayatItem(
                        item['_id'] ?? '',
                        items,
                        NumberFormat('#,##0', 'id_ID')
                            .format(item['total'] ?? 0),
                        item['customer_name'] ?? '',
                      );
                    }).toList(),
                  ),
      ),
    );
  }
}
