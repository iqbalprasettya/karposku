import 'package:flutter/material.dart';
import 'package:karposku/models/items_cart_data.dart';
import 'package:karposku/consts/mki_methods.dart';

class PackingProvider with ChangeNotifier {
  final List<ItemsCartData> _packingItems = [];
  int _total = 0;

  List<ItemsCartData> get packingItems => [..._packingItems];

  int get itemCount => _packingItems.length;

  double get totalAmount {
    double total = 0;
    for (var item in _packingItems) {
      total += double.parse(item.itemsPrice) * item.qty;
    }
    return total;
  }

  bool get isEmpty => _packingItems.isEmpty;

  void addItem(ItemsCartData item) {
    if (!isItemExists(item.itemsId)) {
      _packingItems.add(item);
      notifyListeners();
    }
  }

  void removeItem(String itemId) {
    _packingItems.removeWhere((item) => item.itemsId == itemId);
    notifyListeners();
  }

  void increaseQty(ItemsCartData item) {
    final index = _packingItems.indexWhere((i) => i.itemsId == item.itemsId);
    if (index >= 0) {
      final updatedItem = ItemsCartData(
        itemsId: item.itemsId,
        itemsCode: item.itemsCode,
        itemsName: item.itemsName,
        itemsPrice: item.itemsPrice,
        qty: item.qty + 1,
        itemsIcon: item.itemsIcon,
      );
      _packingItems[index] = updatedItem;
      notifyListeners();
    }
  }

  void decreaseQty(ItemsCartData item) {
    if (item.qty > 1) {
      final index = _packingItems.indexWhere((i) => i.itemsId == item.itemsId);
      if (index >= 0) {
        final updatedItem = ItemsCartData(
          itemsId: item.itemsId,
          itemsCode: item.itemsCode,
          itemsName: item.itemsName,
          itemsPrice: item.itemsPrice,
          qty: item.qty - 1,
          itemsIcon: item.itemsIcon,
        );
        _packingItems[index] = updatedItem;
        notifyListeners();
      }
    }
  }

  bool isItemExists(String itemId) {
    return _packingItems.any((item) => item.itemsId == itemId);
  }

  void clearPacking() {
    _packingItems.clear();
    notifyListeners();
  }
}
