import 'package:flutter/material.dart';
import 'package:karposku/consts/mki_colorsv2.dart';
import 'package:karposku/consts/mki_methods.dart';
import 'package:karposku/consts/mki_urls.dart';
import 'package:karposku/consts/mki_variabels.dart';
import 'package:karposku/models/items_cart_data.dart';
import 'package:karposku/models/items_data.dart';
import 'package:karposku/models/items_category.dart';
import 'package:karposku/providers/items_list_cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:karposku/consts/mki_tabs_widget.dart';

class ItemsSelectionScreen extends StatefulWidget {
  const ItemsSelectionScreen({super.key});

  static const routeName = 'items-selection-screen';

  @override
  State<ItemsSelectionScreen> createState() => _ItemsSelectionScreenState();
}

class _ItemsSelectionScreenState extends State<ItemsSelectionScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<ItemsData> itemsList = [];
  List<ItemsData> filteredItems = [];
  late TabController _tabController;
  List<String> categories = ['Semua']; // Mulai dengan Semua
  List<ItemsCategory> categoryList = [];

  // Tambahkan map untuk menyimpan items yang sudah difilter per kategori
  Map<String, List<ItemsData>> categorizedItems = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
    _loadItemsAndCategories();
  }

  void _handleTabSelection() {
    String selectedCategory = categories[_tabController.index];
    _filterItems(_searchController.text, selectedCategory);
  }

  void _loadItemsAndCategories() async {
    // Load kategori terlebih dahulu
    categoryList = await MKIUrls.getItemsCategory();

    // Load items
    itemsList = await MKIUrls.getItemsList();

    // Pre-filter items berdasarkan kategori
    setState(() {
      // Inisialisasi kategori 'Semua' dengan semua items
      categorizedItems = {'Semua': itemsList};

      // Filter items untuk setiap kategori
      for (var category in categoryList) {
        categorizedItems[category.categoryName] = itemsList
            .where((item) => item.itemsCategory == category.categoryId)
            .toList();
      }

      // Set up categories list
      categories = ['Semua'];
      categories.addAll(categoryList.map((cat) => cat.categoryName));

      // Set filtered items awal ke 'Semua'
      filteredItems = itemsList;

      // Reinisialisasi TabController
      _tabController.dispose();
      _tabController = TabController(length: categories.length, vsync: this);
      _tabController.addListener(_handleTabSelection);
    });
  }

  void _filterItems(String query, [String? category]) {
    setState(() {
      String currentCategory = category ?? categories[_tabController.index];
      List<ItemsData> baseItems = categorizedItems[currentCategory] ?? [];

      if (query.isEmpty) {
        // Jika query kosong, tampilkan semua item untuk kategori yang aktif
        filteredItems = baseItems;
      } else {
        // Filter berdasarkan query dengan pencocokan yang lebih fleksibel
        String normalizedQuery = query.toLowerCase().trim();
        filteredItems = baseItems.where((item) {
          String normalizedName = item.itemsName.toLowerCase();
          String normalizedCode = item.itemsCode.toLowerCase();

          // Cek apakah query ada di nama atau kode barang
          bool matchesName = normalizedName.contains(normalizedQuery);
          bool matchesCode = normalizedCode.contains(normalizedQuery);

          // Cek juga kata-kata individual dalam nama barang
          bool matchesWords = normalizedName
              .split(' ')
              .any((word) => word.startsWith(normalizedQuery));

          return matchesName || matchesCode || matchesWords;
        }).toList();
      }
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
            // Header with Search and Tabs
            Container(
              padding: EdgeInsets.only(top: 50, bottom: 0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    MKIColorConstv2.primaryDark,
                    MKIColorConstv2.primary.withOpacity(0.95),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: MKIColorConstv2.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pilih Barang',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Ketuk dua kali untuk memilih',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) => _filterItems(value),
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: 'Cari barang...',
                            prefixIcon: Icon(Icons.search,
                                color: MKIColorConstv2.primary),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      _filterItems('');
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Category Tabs
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    indicatorColor: Colors.white,
                    indicatorWeight: 3,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white.withOpacity(0.7),
                    tabs: categories
                        .map((category) => Tab(
                              text: category,
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),

            // Content Area with TabBarView
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: categories.map((category) {
                  // Filter items berdasarkan kategori yang aktif
                  List<ItemsData> categoryItems = category == 'Semua'
                      ? filteredItems
                      : filteredItems.where((item) {
                          var categoryData = categoryList.firstWhere(
                            (cat) => cat.categoryName == category,
                            orElse: () =>
                                ItemsCategory(categoryId: '', categoryName: ''),
                          );
                          return item.itemsCategory == categoryData.categoryId;
                        }).toList();

                  return categoryItems.isEmpty &&
                          _searchController.text.isNotEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 48,
                                color: MKIColorConstv2.neutral400,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Barang tidak ditemukan',
                                style: TextStyle(
                                  color: MKIColorConstv2.neutral400,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: EdgeInsets.all(16),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.72,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: categoryItems.length,
                          itemBuilder: (context, index) {
                            return _buildItemCard(
                                context, categoryItems[index]);
                          },
                        );
                }).toList(),
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
          // Tampilkan hint untuk double tap
          MKIMethods.showMessage(
            context,
            MKIColorConstv2.secondary,
            'Ketuk dua kali untuk memilih ${item.itemsName}',
          );
        },
        onDoubleTap: () {
          var packingListProvider =
              Provider.of<ItemsListCartProvider>(context, listen: false);

          // Cek apakah item sudah ada di list
          bool isExists = packingListProvider.isDataExists(item.itemsId);

          if (isExists) {
            // Jika sudah ada, tampilkan pesan error
            MKIMethods.showMessage(
              context,
              Colors.redAccent,
              '${item.itemsName} sudah ada dalam list',
            );
          } else {
            // Jika belum ada, tambahkan item baru
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
          }
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

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
