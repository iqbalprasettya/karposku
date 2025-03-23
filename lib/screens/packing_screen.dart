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
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          // Header Fixed
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
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Packing List',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: MKIColorConstv2.neutral100,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          isEmpty
                              ? 'Belum ada item'
                              : '${packingListProvider.itemList.length} items',
                          style: TextStyle(
                            fontSize: 12,
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
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ItemsSelectionScreen()),
                          ),
                        ),
                        if (!isEmpty) ...[
                          SizedBox(width: 8),
                          _buildHeaderButton(
                            icon: Icons.delete_outline,
                            onPressed: () => _showClearListDialog(
                                context, packingListProvider),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Scrollable Content
          Expanded(
            child: Stack(
              children: [
                CustomScrollView(
                  slivers: [
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
                        padding: EdgeInsets.symmetric(horizontal: 12),
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

                    SliverPadding(
                      padding: EdgeInsets.only(bottom: 140),
                    ),
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
        ],
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
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
        ),
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
              MaterialPageRoute(
                  builder: (context) => const ItemsSelectionScreen()),
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
      margin: EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
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
                    borderRadius: BorderRadius.circular(8),
                    child: Image(
                      image: item.itemsIcon != ''
                          ? NetworkImage(item.itemsIcon)
                          : AssetImage('assets/images/karbotech.png')
                              as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.itemsName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: MKIColorConstv2.secondaryDark,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Rp ${MKIVariabels.formatter.format(int.parse(item.itemsPrice))}',
                        style: TextStyle(
                          fontSize: 13,
                          color: MKIColorConstv2.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: MKIColorConstv2.secondarySoft.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: MKIColorConstv2.secondary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildQuantityButton(
                        icon: Icons.remove,
                        onPressed: () {
                          if (item.qty > 1) provider.decItemsQty(item);
                        },
                        size: 20,
                        backgroundColor:
                            MKIColorConstv2.secondary.withOpacity(0.1),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '${item.qty}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: MKIColorConstv2.secondaryDark,
                          ),
                        ),
                      ),
                      _buildQuantityButton(
                        icon: Icons.add,
                        onPressed: () => provider.incItemsQty(item),
                        size: 20,
                        backgroundColor:
                            MKIColorConstv2.secondary.withOpacity(0.1),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () => provider.removeItemData(item.itemsId),
                    icon: Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.red,
                    ),
                    padding: EdgeInsets.all(8),
                    constraints: BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
    double size = 20,
    Color? backgroundColor,
  }) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(8),
          constraints: BoxConstraints(
            minWidth: 36,
            minHeight: 36,
          ),
          child: Icon(
            icon,
            size: size,
            color: MKIColorConstv2.secondary,
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingPanel(ItemsListCartProvider provider) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: MKIColorConstv2.secondarySoft.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      color: MKIColorConstv2.secondary,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 12),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Pembayaran',
                        style: TextStyle(
                          color: MKIColorConstv2.neutral500,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Rp ${MKIVariabels.formatter.format(provider.total)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: MKIColorConstv2.secondaryDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MKIColorConstv2.primary,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: () => _showSubmitDialog(context, provider),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Proses',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ],
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
