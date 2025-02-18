import 'package:flutter/material.dart';
import 'package:karposku/consts/mki_colors.dart';
import 'package:karposku/consts/mki_variabels.dart';
import 'package:karposku/screens/invoice_list_screen.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    // double screeenWidth = MediaQuery.of(context).size.width;
    // double screenHeight = MediaQuery.of(context).size.height;
    InvoiceListScreen.reportPeriod = MKIVariabels.dailyData;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'SALES',
            style: TextStyle(color: MKIColorConst.mainBlue),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: MKIColorConst.mainGoldBlueAppBarAlt,
            ),
          ),
          bottom: TabBar(
            // isScrollable: true,
            // tabAlignment: TabAlignment.fill,
            labelColor: MKIColorConst.mkiGoldLight,
            // labelColor: Colors.white,
            unselectedLabelColor: MKIColorConst.mkiWhiteBackground,
            indicatorColor: MKIColorConst.mkiGoldLight,
            // tabAlignment: TabAlignment.fill,
            indicatorWeight: 4,
            tabs: const [
              MyTab(label: 'Daily'),
              MyTab(label: 'Monthly'),
              MyTab(label: 'All'),
            ],
            onTap: (value) {
              // print(value);
              if (value == 0) {
                InvoiceListScreen.reportPeriod = MKIVariabels.dailyData;
              } else if (value == 1) {
                InvoiceListScreen.reportPeriod = MKIVariabels.monthlyData;
              } else if (value == 2) {
                InvoiceListScreen.reportPeriod = MKIVariabels.yearlyData;
              }
            },
          ),
        ),
        body: const TabBarView(
          children: [
            InvoiceListScreen(),
            InvoiceListScreen(),
            InvoiceListScreen(),
            // Center(
            //   child: Text("Monthly Sales"),
            // ),
            // Center(
            //   child: Text("All Sales"),
            // ),
          ],
        ),
      ),
    );
  }
}

class MyTab extends StatelessWidget {
  const MyTab({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Center(
        child: FittedBox(
          child: Text(
            label,
            style: const TextStyle(fontSize: 17),
          ),
        ),
      ),
    );
  }
}
