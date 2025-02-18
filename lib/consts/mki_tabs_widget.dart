import 'package:flutter/cupertino.dart';

class MKITabsWidget {
  static List<Widget> categoryGroupTitle = [];
  static List<Widget> categoriesWidgetContent = [];

  static Widget categoryWidget(String title) {
    return Center(
      child: FittedBox(
        child: Text(
          title,
          style: const TextStyle(fontSize: 17),
        ),
      ),
    );
  }
}

class WidgetDataTitle extends StatefulWidget {
  final String title;
  const WidgetDataTitle({super.key, required this.title});

  @override
  State<WidgetDataTitle> createState() => _WidgetDataTitleState();
}

class _WidgetDataTitleState extends State<WidgetDataTitle> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        child: Text(
          widget.title,
          style: const TextStyle(fontSize: 19),
        ),
      ),
    );
  }
}

class WidgetContent extends StatelessWidget {
  final String title;
  const WidgetContent({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        child: Text(
          title,
          style: const TextStyle(fontSize: 17),
        ),
      ),
    );
  }
}
