import 'package:flutter/material.dart';
import 'package:karposku/consts/mki_colorsv2.dart';
import 'package:karposku/models/items_cart_data.dart';
import 'package:karposku/providers/items_list_cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:karposku/screens/items_selection_screen.dart';

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
        // TODO: Implement list item widget
        return Container();
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
    // TODO: Implement submit dialog
  }

  void _showClearListDialog(
      BuildContext context, ItemsListCartProvider provider) {
    // TODO: Implement clear list dialog
  }
}
