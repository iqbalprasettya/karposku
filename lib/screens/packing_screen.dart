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
    var packingListProvider =
        Provider.of<ItemsListCartProvider>(context, listen: true);
    isEmpty = packingListProvider.itemList.isEmpty;

    return Scaffold(
      backgroundColor: MKIColorConstv2.neutral200,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                // Header yang mirip dengan HomeScreen
                SliverAppBar(
                  expandedHeight: 140,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
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
                        padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Packing List',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: MKIColorConstv2.neutral100,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      isEmpty ? 'Belum ada item' : '${packingListProvider.itemList.length} items',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: MKIColorConstv2.neutral300,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    _buildHeaderButton(
                                      icon: Icons.add_circle_outline,
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const ItemsSelectionScreen()),
                                      ),
                                    ),
                                    if (!isEmpty) ...[
                                      SizedBox(width: 8),
                                      _buildHeaderButton(
                                        icon: Icons.delete_outline,
                                        onPressed: () => _showClearListDialog(context, packingListProvider),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Content
                SliverToBoxAdapter(
                  child: isEmpty
                      ? _buildEmptyState()
                      : Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'Daftar Item',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: MKIColorConstv2.secondaryDark,
                            ),
                          ),
                        ),
                ),

                if (!isEmpty)
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildModernItemCard(
                          context,
                          packingListProvider.itemList[index],
                          packingListProvider,
                        ),
                        childCount: packingListProvider.itemList.length,
                      ),
                    ),
                  ),

                SliverPadding(padding: EdgeInsets.only(bottom: 100)),
              ],
            ),

            if (!isEmpty)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildFloatingPanel(packingListProvider),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        padding: EdgeInsets.all(12),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: MKIColorConstv2.secondarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 60,
              color: MKIColorConstv2.secondary,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Belum Ada Item',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: MKIColorConstv2.secondaryDark,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Mulai tambahkan item ke daftar packing',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: MKIColorConstv2.neutral500,
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: MKIColorConstv2.secondary,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ItemsSelectionScreen()),
            ),
            icon: Icon(Icons.add_shopping_cart, color: Colors.white),
            label: Text(
              'Tambah Item',
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

  Widget _buildModernItemCard(
    BuildContext context,
    ItemsCartData item,
    ItemsListCartProvider provider,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Image container with gradient overlay
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        MKIColorConstv2.primaryLight.withOpacity(0.1),
                        MKIColorConstv2.primary.withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image(
                      image: item.itemsIcon != ''
                          ? NetworkImage(item.itemsIcon)
                          : AssetImage('assets/images/karbotech.png')
                              as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.itemsName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: MKIColorConstv2.secondaryDark,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Rp ${MKIVariabels.formatter.format(int.parse(item.itemsPrice))}',
                        style: TextStyle(
                          fontSize: 14,
                          color: MKIColorConstv2.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 12),
                      // Quantity controls
                      Container(
                        decoration: BoxDecoration(
                          color: MKIColorConstv2.neutral100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildQuantityButton(
                              icon: Icons.remove,
                              onPressed: () {
                                if (item.qty > 1) provider.decItemsQty(item);
                              },
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                '${item.qty}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            _buildQuantityButton(
                              icon: Icons.add,
                              onPressed: () => provider.incItemsQty(item),
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
          // Delete button
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              onPressed: () => provider.removeItemData(item.itemsId),
              icon: Icon(
                Icons.close,
                size: 20,
                color: MKIColorConstv2.neutral400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 20,
            color: MKIColorConstv2.secondary,
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingPanel(ItemsListCartProvider provider) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      color: MKIColorConstv2.neutral500,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Rp ${MKIVariabels.formatter.format(provider.total)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: MKIColorConstv2.secondaryDark,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MKIColorConstv2.primary,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => _showSubmitDialog(context, provider),
              child: Text(
                'Proses Packing',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
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
