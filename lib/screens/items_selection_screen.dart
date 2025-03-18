import 'package:flutter/material.dart';
import 'package:karposku/consts/mki_colorsv2.dart';
import 'package:karposku/consts/mki_methods.dart';
import 'package:karposku/consts/mki_urls.dart';
import 'package:karposku/consts/mki_variabels.dart';
import 'package:karposku/models/items_cart_data.dart';
import 'package:karposku/models/items_data.dart';
import 'package:karposku/providers/items_list_cart_provider.dart';
import 'package:provider/provider.dart';

class ItemsSelectionScreen extends StatefulWidget {
  const ItemsSelectionScreen({super.key});

  static const routeName = 'items-selection-screen';

  @override
  State<ItemsSelectionScreen> createState() => _ItemsSelectionScreenState();
}

class _ItemsSelectionScreenState extends State<ItemsSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ItemsData> itemsList = [];
  List<ItemsData> filteredItems = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    // Menggunakan method yang sudah ada untuk load items
    itemsList = await MKIUrls.getItemsList();
    setState(() {
      filteredItems = itemsList;
    });
  }

  void _filterItems(String query) {
    setState(() {
      filteredItems = itemsList
          .where((item) =>
              item.itemsName.toLowerCase().contains(query.toLowerCase()) ||
              item.itemsCode.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: MKIColorConstv2.neutral200,
        ),
        child: Column(
          children: [
            // Header with Search
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
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.arrow_back,
                            color: MKIColorConstv2.neutral100,
                          ),
                        ),
                        Text(
                          'Pilih Barang',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: MKIColorConstv2.neutral100,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _filterItems,
                        decoration: InputDecoration(
                          hintText: 'Cari barang...',
                          prefixIcon: Icon(Icons.search),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Items Grid
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  return _buildItemCard(context, filteredItems[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, ItemsData item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          var packingListProvider =
              Provider.of<ItemsListCartProvider>(context, listen: false);

          ItemsCartData dataItems = ItemsCartData(
            itemsId: item.itemsId,
            itemsCode: item.itemsCode,
            itemsName: item.itemsName,
            itemsPrice: item.finalPrice.toString(),
            qty: 1,
            itemsIcon: item.imgPath,
          );

          packingListProvider.addItemsData(dataItems);
          MKIMethods.showMessage(
            context,
            Colors.green,
            '${item.itemsName} ditambahkan',
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image dan Promo Badge
            Container(
              height: 130,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: MKIColorConstv2.neutral100,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: item.imgPath != ''
                              ? NetworkImage(item.imgPath)
                              : AssetImage('assets/images/karbotech.png')
                                  as ImageProvider,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  if (item.isPromo)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: MKIColorConstv2.primaryLight,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  MKIColorConstv2.primaryLight.withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.local_offer,
                              color: Colors.white,
                              size: 12,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Promo',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Info Produk
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Nama Produk
                    Text(
                      item.itemsName,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.2,
                        fontWeight: FontWeight.w600,
                        color: MKIColorConstv2.secondaryDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Harga dan Promo Info
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (item.isPromo) ...[
                          // Label Diskon dengan Badge
                          Container(
                            margin: EdgeInsets.only(bottom: 4),
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  MKIColorConstv2.primaryLight.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.arrow_downward,
                                  size: 12,
                                  color: MKIColorConstv2.primaryLight,
                                ),
                                SizedBox(width: 2),
                                Text(
                                  '${((item.promoValue / item.sellPrice) * 100).round()}%',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: MKIColorConstv2.primaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Harga Asli (Coret)
                          Container(
                            margin: EdgeInsets.only(bottom: 2),
                            padding: EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: MKIColorConstv2.neutral200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Rp ${MKIVariabels.formatter.format(item.sellPrice)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: MKIColorConstv2.neutral500,
                                decoration: TextDecoration.lineThrough,
                                decorationColor: MKIColorConstv2.neutral400,
                                decorationThickness: 2,
                              ),
                            ),
                          ),
                          SizedBox(height: 4),
                        ],
                        // Harga Final
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Rp ',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: item.isPromo
                                    ? MKIColorConstv2.primaryLight
                                    : MKIColorConstv2.secondary,
                              ),
                            ),
                            Text(
                              MKIVariabels.formatter.format(item.finalPrice),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: item.isPromo
                                    ? MKIColorConstv2.primaryLight
                                    : MKIColorConstv2.secondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
