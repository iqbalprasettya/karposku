import 'package:flutter/material.dart';
import 'package:karposku/consts/mki_colors.dart';
import 'package:karposku/consts/mki_tabs_widget.dart';

class ItemListScreen extends StatefulWidget {
  const ItemListScreen({super.key});

  static List<Widget> tabContentWidget = [];
  static int tabsIdxPosition = 0;
  static TextEditingController homeTextController = TextEditingController();

  @override
  State<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // var itemsProvider = Provider.of<ItemsSearchListProvider>(
    //   context,
    //   listen: false,
    // );

    // double screeenWidth = MediaQuery.of(context).size.width;
    // double screenHeight = MediaQuery.of(context).size.height;
    // return DefaultTabController(
    //   length: MKITabsWidget.categoriesTitle.length,
    //   child: Scaffold(
    //     appBar: AppBar(
    //       elevation: 0,
    //       flexibleSpace: Container(
    //         // height: screenHeight * 0.1,
    //         decoration: BoxDecoration(
    //           gradient: MKIColorConst.mainGoldBlueAppBarAlt,
    //         ),
    //       ),
    //       centerTitle: true,
    //       title: Text(
    //         'HOME',
    //         style: TextStyle(color: MKIColorConst.mainBlue),
    //       ),
    //       bottom: TabBar(
    //         // isScrollable: true,
    //         isScrollable:
    //             MKITabsWidget.categoriesTitle.length > 5 ? true : false,
    //         labelColor: MKIColorConst.mkiGoldLight,
    //         unselectedLabelColor: MKIColorConst.mkiWhiteBackground,
    //         indicatorColor: MKIColorConst.mkiGoldLight,
    //         // tabAlignment: TabAlignment.fill,
    //         indicatorWeight: 5,

    //         tabs: MKITabsWidget.categoriesTitle,

    //         onTap: (value) {
    //           setState(() {
    //             HomeScreen.tabsIdxPosition = value;
    //           });
    //         },
    //       ),
    //     ),
    //     body: TabBarView(children: MKITabsWidget.categoriesWidgetContent),
    //   ),
    // );

    return MaterialApp(
      title: 'msc',
      home: DefaultTabController(
        length: MKITabsWidget.categoryGroupTitle.length,
        // length: 2,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Container(
              // color: Colors.green,
              decoration: BoxDecoration(
                gradient: MKIColorConst.mainGoldBlueAppBarAlt,
              ),
              child: SafeArea(
                child: Column(
                  children: <Widget>[
                    Expanded(child: Container()),
                    TabBar(
                      tabAlignment: TabAlignment.center,
                      isScrollable: true,
                      labelColor: MKIColorConst.mkiGoldLight,
                      unselectedLabelColor: MKIColorConst.mkiWhiteBackground,
                      indicatorColor: MKIColorConst.mkiGoldLight,
                      indicatorWeight: 1,
                      tabs: MKITabsWidget.categoryGroupTitle,
                      // tabs: [
                      //   Text('SATU'),
                      //   Text('DUA'),
                      // ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: TabBarView(children: MKITabsWidget.categoriesWidgetContent),
        ),
      ),
    );
  }
}
