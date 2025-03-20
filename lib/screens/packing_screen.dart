import 'package:flutter/material.dart';
import 'package:karposku/consts/mki_colorsv2.dart';
import 'package:karposku/models/items_cart_data.dart';
import 'package:karposku/providers/items_list_cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:karposku/screens/items_selection_screen.dart';
import 'package:karposku/consts/mki_variabels.dart';
import 'package:karposku/consts/mki_urls.dart';
import 'package:karposku/utilities/local_storage.dart';

class PackingScreen extends StatefulWidget {
  const PackingScreen({super.key});

  static const routeName = 'packing-screen';

  @override
  State<PackingScreen> createState() => _PackingScreenState();
}

class _PackingScreenState extends State<PackingScreen> {
  bool isEmpty = true;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    var packingListProvider =
        Provider.of<ItemsListCartProvider>(context, listen: true);

    if (packingListProvider.itemList.isNotEmpty) {
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
                      'Packing',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: MKIColorConstv2.neutral100,
                      ),
                    ),
                    Row(
                      children: [
                        // Add Item Button
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ItemsSelectionScreen(),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.add_circle_outline,
                            color: MKIColorConstv2.neutral100,
                            size: 28,
                          ),
                        ),
                        // Submit Button
                        IconButton(
                          onPressed: () {
                            if (!isEmpty) {
                              _showSubmitDialog(context, packingListProvider);
                            }
                          },
                          icon: Icon(
                            Icons.check_circle_outline,
                            color: MKIColorConstv2.neutral100,
                            size: 28,
                          ),
                        ),
                        // Clear List Button
                        IconButton(
                          onPressed: () {
                            if (!isEmpty) {
                              _showClearListDialog(
                                  context, packingListProvider);
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

            // Content Area
            Expanded(
              child: isEmpty
                  ? _buildEmptyList()
                  : _buildPackingList(packingListProvider),
            ),

            // Total Items
            if (!isEmpty) _buildTotalItems(packingListProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: MKIColorConstv2.neutral400,
          ),
          SizedBox(height: 16),
          Text(
            'Belum ada data packing',
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

  Widget _buildPackingList(ItemsListCartProvider packingListProvider) {
    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: packingListProvider.itemList.length,
      itemBuilder: (context, index) {
        var item = packingListProvider.itemList[index];
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Gambar Produk
              Container(
                width: 100,
                height: 100,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: MKIColorConstv2.neutral200,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: item.itemsIcon != ''
                            ? NetworkImage(item.itemsIcon)
                            : AssetImage('assets/images/karbotech.png')
                                as ImageProvider,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              // Informasi Produk
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.itemsName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: MKIColorConstv2.secondaryDark,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Rp ${MKIVariabels.formatter.format(int.parse(item.itemsPrice))}',
                        style: TextStyle(
                          fontSize: 14,
                          color: MKIColorConstv2.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          // Tombol Kurangi
                          IconButton(
                            onPressed: () {
                              if (item.qty > 1) {
                                packingListProvider.decItemsQty(item);
                              }
                            },
                            icon: Icon(
                              Icons.remove_circle_outline,
                              color: MKIColorConstv2.secondary,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                          // Quantity
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 12),
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: MKIColorConstv2.secondarySoft,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${item.qty}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: MKIColorConstv2.secondary,
                              ),
                            ),
                          ),
                          // Tombol Tambah
                          IconButton(
                            onPressed: () {
                              packingListProvider.incItemsQty(item);
                            },
                            icon: Icon(
                              Icons.add_circle_outline,
                              color: MKIColorConstv2.secondary,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                          Spacer(),
                          // Tombol Hapus
                          IconButton(
                            onPressed: () {
                              packingListProvider.removeItemData(item.itemsId);
                            },
                            icon: Icon(
                              Icons.delete_outline,
                              color: MKIColorConstv2.error,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTotalItems(ItemsListCartProvider packingListProvider) {
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
                'Total Item',
                style: TextStyle(
                  fontSize: 14,
                  color: MKIColorConstv2.neutral500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '${packingListProvider.itemList.length} items',
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
              if (!isEmpty) {
                _showSubmitDialog(context, packingListProvider);
              }
            },
            child: Text(
              'Submit Packing',
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

  void _showSubmitDialog(BuildContext context, ItemsListCartProvider provider) {
    final TextEditingController customerNameController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Konfirmasi Packing',
          style: TextStyle(
            color: MKIColorConstv2.secondaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: customerNameController,
              decoration: InputDecoration(
                labelText: 'Nama Customer',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Total: Rp ${MKIVariabels.formatter.format(provider.total)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: MKIColorConstv2.secondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: TextStyle(color: MKIColorConstv2.neutral500),
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
              if (customerNameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Nama customer harus diisi'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                double total = provider.total.toDouble();

                String result = await MKIUrls.createTempPacking(
                  total,
                  customerNameController.text,
                  total,
                  provider.itemList,
                );

                Navigator.pop(context);

                if (result.toLowerCase() == 'success') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Packing berhasil dibuat'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  provider.clearItemsData();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal membuat packing'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Terjadi kesalahan: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(
              'Submit',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearListDialog(
      BuildContext context, ItemsListCartProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Hapus Semua Item',
          style: TextStyle(
            color: MKIColorConstv2.secondaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text('Apakah Anda yakin ingin menghapus semua item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: TextStyle(color: MKIColorConstv2.neutral500),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              provider.clearItemsData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Semua item telah dihapus'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text(
              'Hapus',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
