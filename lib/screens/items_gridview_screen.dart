import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:karposku/consts/mki_colors.dart';
import 'package:karposku/consts/mki_methods.dart';
import 'package:karposku/consts/mki_styles.dart';
import 'package:karposku/models/items_cart_data.dart';
import 'package:karposku/models/items_data.dart';
import 'package:karposku/providers/items_list_cart_provider.dart';
import 'package:provider/provider.dart';

//  itemsPrice: json['price'],
//       isContainer: json['is_container'],
//       qty: json['qty'],
//       itemsIcon: json['icon'],
//     );

// final itemsList = [
//   ItemsDataSample(
//     itemsId: '0001',
//     itemsCode: 'AQ-0001',
//     itemsName: 'AQUA GALON',
//     itemsPrice: '20000',
//     isContainer: true,
//     qty: 1,
//     itemsIcon: '',
//   ),
//   ItemsDataSample(
//     itemsId: '0002',
//     itemsCode: 'AM-0001',
//     itemsName: 'AMIDIS',
//     itemsPrice: '21000',
//     isContainer: true,
//     qty: 1,
//     itemsIcon: '',
//   ),
//   ItemsDataSample(
//     itemsId: '0003',
//     itemsCode: 'AD-0001',
//     itemsName: 'ADES',
//     itemsPrice: '20000',
//     isContainer: true,
//     qty: 1,
//     itemsIcon: '',
//   ),
//   ItemsDataSample(
//     itemsId: '0001',
//     itemsCode: 'AQ-0001',
//     itemsName: 'ADES',
//     itemsPrice: '20000',
//     isContainer: true,
//     qty: 1,
//     itemsIcon: '',
//   ),
//   ItemsDataSample(
//     itemsId: '0001',
//     itemsCode: 'AQ-0001',
//     itemsName: 'AQUA GALON',
//     itemsPrice: '20000',
//     isContainer: true,
//     qty: 1,
//     itemsIcon: '',
//   ),
// ];

final TextEditingController _searchController = TextEditingController();

class ItemsGridViewScreen extends StatefulWidget {
  const ItemsGridViewScreen({super.key, required this.categoryName});

  final String categoryName;

  static String routeName = 'items_master-screen';

  static List<ItemsData> startlistItem = [];

  @override
  State<ItemsGridViewScreen> createState() => _ItemsGridViewScreenState();
}

class _ItemsGridViewScreenState extends State<ItemsGridViewScreen> {
  // List<Map<String, dynamic>> _foundItems = [];
  List<ItemsData> listItem = [];
  List<ItemsData> itemsFound = [];
  String itemsId = '';

  void getItemsList() async {
    listItem = ItemsGridViewScreen.startlistItem
        .where((element) => element.itemsCategory == widget.categoryName)
        .toList();
    setState(() {
      itemsFound = listItem;
    });
  }

  @override
  void initState() {
    super.initState();
    getItemsList();
  }

  @override
  Widget build(BuildContext context) {
    double screeenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // var size = MediaQuery.of(context).size;
    /*24 is for notification bar on Android*/
    // final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
    // final double itemWidth = size.width / 2;

    // var itemsSearchProvider = Provider.of<ItemsSearchListProvider>(
    //   context,
    //   listen: true,
    // );
    // itemsSearchProvider.addItemsData(itemsFound);
    // print(itemsSearchProvider.itemsData.length);
    // print(ItemsListScreen.varTest);

    return Scaffold(
      body: Column(
        children: [
          // Stack(
          //   children: [],
          // ),
          Container(
            margin: const EdgeInsets.only(bottom: 5),
            padding: const EdgeInsets.only(
              left: 0,
              right: 0,
              top: 5,
              bottom: 5,
            ),
            width: screeenWidth,
            height: MediaQuery.of(context).orientation == Orientation.portrait
                ? screenHeight * 0.07
                : screenHeight * 0.14,
            color: MKIColorConst.mkiSeaBlue,
            // decoration: BoxDecoration(
            //   gradient: MKIColorConst.mainGoldBlueAppBar,
            //   // borderRadius: BorderRadius.circular(25),
            // ),
            child: CupertinoTextField(
              placeholder: 'Search...',
              placeholderStyle: const TextStyle(color: Colors.black),
              controller: _searchController,
              prefix: const Padding(
                padding: EdgeInsets.only(left: 15),
                child: Icon(
                  Icons.search,
                ),
              ),
              suffix: IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    itemsFound = listItem;
                  });
                },
                icon: const Icon(Icons.cancel_outlined, color: Colors.black),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              onChanged: (value) {
                List<ItemsData> result = [];

                if (_searchController.text.isEmpty) {
                  result = listItem;
                } else {
                  result = listItem
                      .where(
                        (element) =>
                            element.itemsName.toString().toLowerCase().contains(
                                  value.toLowerCase(),
                                ),
                      )
                      .toList();
                }
                setState(() {
                  itemsFound = result;
                });
              },
            ),
          ),
          /* Items List Content */
          Expanded(
            child: GridView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: itemsFound.length,
              itemBuilder: ((context, index) {
                // return MKIStyles.mkiCard(
                //   context,
                //   index,
                //   itemsFound[index].itemsName,
                //   itemsFound[index].sellPrice,
                //   itemsFound[index].imgPath,
                //   true,
                // );

                return Container(
                  // padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    // color: MKIColorConst.mkiGoldLight.withOpacity(0.2),
                    // border: Border(top: ),
                    // color: Colors.amberAccent.withOpacity(0.5),
                    // border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: InkWell(
                    splashColor: Colors.grey.withOpacity(0.1),
                    customBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    onTap: () {},
                    onDoubleTap: () {
                      var cartListProvider = Provider.of<ItemsListCartProvider>(
                        context,
                        listen: false,
                      );
                      bool isDataAdded = cartListProvider
                          .isDataExists(itemsFound[index].itemsId);

                      if (isDataAdded) {
                        MKIMethods.showMessage(context, Colors.redAccent,
                            'Items sudah ditambahkan sebelumnya');
                      } else {
                        ItemsCartData dataItems = ItemsCartData(
                          itemsId: itemsFound[index].itemsId,
                          itemsCode: itemsFound[index].itemsCode,
                          itemsName: itemsFound[index].itemsName,
                          itemsPrice: itemsFound[index].finalPrice.toString(),
                          qty: 1,
                          itemsIcon: itemsFound[index].imgPath,
                        );
                        cartListProvider.addItemsData(dataItems);

                        MKIMethods.showMessage(
                            context, Colors.green, 'Items sudah ditambahkan');
                      }
                    },
                    /* Items Card View */
                    child: MKIStyles.mkiCardDisplayNew(
                      context,
                      index,
                      itemsFound[index].itemsName,
                      itemsFound[index].sellPrice,
                      itemsFound[index].finalPrice,
                      itemsFound[index].imgPath,
                      true,
                      /* Promo Sign */
                      promoWidget: itemsFound[index].isPromo &&
                              itemsFound[index].promoValue == 0
                          ? Padding(
                              padding: EdgeInsets.only(
                                top: 10,
                                left: 10,
                              ),
                              // child: Container(
                              //   height: 30,
                              //   width: 30,
                              //   decoration: BoxDecoration(
                              //     color: Colors.orange,
                              //     borderRadius: BorderRadius.circular(30),
                              //   ),
                              //   child: IconButton(
                              //     onPressed: () {},
                              //     icon: Icon(Icons.discount),
                              //   ),
                              // ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(30),
                                onTap: () {
                                  // print('Promo Euy');
                                  showCupertinoModalPopup(
                                    context: context,
                                    builder: (BuildContext context) => Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(10),
                                          width: screeenWidth * 0.8,
                                          decoration: BoxDecoration(
                                            color: MKIColorConst.mkiGrecianBlue,
                                            // border: Border.all(
                                            //   color: Colors.grey,
                                            //   width: 1.5,
                                            // ),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(15),
                                              topRight: Radius.circular(15),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'PROMO',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 20,
                                                fontWeight: FontWeight.normal,
                                                decoration: TextDecoration.none,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: screeenWidth * 0.8,
                                          child: Divider(
                                            color: Colors.grey,
                                            height: 1.0,
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.all(10),
                                          width: screeenWidth * 0.8,
                                          height: 150,
                                          decoration: BoxDecoration(
                                            color: MKIColorConst.mkiSilver,
                                            // border: Border.all(
                                            //   color: Colors.blueGrey,
                                            //   width: 2.0,
                                            // ),
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(15),
                                              bottomRight: Radius.circular(15),
                                            ),
                                          ),
                                          child: Text(
                                            itemsFound[index].desc,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20,
                                              fontWeight: FontWeight.normal,
                                              decoration: TextDecoration.none,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: MKIStyles.promoContainer(
                                    35, 35, Colors.orange),
                              ),
                            )
                          : SizedBox(),
                    ),
                  ),
                );
              }),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:
                    MediaQuery.of(context).orientation == Orientation.portrait
                        ? 2
                        : 4,
                childAspectRatio:
                    MediaQuery.of(context).orientation == Orientation.portrait
                        ? 1.3
                        : 1.2,
                // mainAxisSpacing: 2,
                // crossAxisSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
