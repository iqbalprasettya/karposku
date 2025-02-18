import 'package:flutter/material.dart';
import 'package:karposku/consts/mki_methods.dart';
import 'package:karposku/models/items_cart_data.dart';

class ItemsListCartProvider with ChangeNotifier {
  final List<ItemsCartData> _itemList = [];
  int _total = 0;

  List<ItemsCartData> get itemList {
    return _itemList;
  }

  int get total {
    _total = 0;
    for (int i = 0; i < _itemList.length; i++) {
      int tQty = _itemList[i].qty;
      int tPrice = MKIMethods.isNumber(_itemList[i].itemsPrice)
          ? int.parse(_itemList[i].itemsPrice)
          : 0;
      int subTotal = tQty * tPrice;
      _total = _total + subTotal;
    }
    return _total;
  }

  void addItemsData(ItemsCartData newItemsData) {
    _itemList.add(newItemsData);
    notifyListeners();
  }

  void addItemsDataIfEmpty(String itemsId, BuildContext ctx) {
    ItemsCartData newItemsData =
        _itemList.firstWhere((itemsNew) => itemsNew.itemsId == itemsId,
            orElse: () => ItemsCartData(
                  itemsId: '',
                  itemsCode: '',
                  itemsName: '',
                  itemsPrice: '',
                  qty: 0,
                  itemsIcon: '',
                ));
    if (newItemsData.itemsName != '') {
      _itemList.add(newItemsData);
      notifyListeners();
    } else {
      MKIMethods.showMessage(
          ctx, Colors.redAccent, 'Barang $itemsId sudah terdaftar');
    }

    // print('Is Exists : $isExists');
    // if (!isExists) {
    //   _itemList.add(newItemsData);
    // } else {
    //   MKIMethods.showMessage(ctx, Colors.redAccent, 'Barang sudah ada');
    // }
    // notifyListeners();
  }

  // void isDataExists(String itemsId) {
  //   int data = _itemList.indexWhere((element) => element.itemsId == itemsId);
  //   if (data >= 0) {
  //     print('Data exists');
  //   } else {
  //     print('Data does not exists');
  //   }
  // }

  bool isDataExists(String itemsId) {
    ItemsCartData newItemsData =
        _itemList.firstWhere((itemsNew) => itemsNew.itemsId == itemsId,
            orElse: () => ItemsCartData(
                  itemsId: '',
                  itemsCode: '',
                  itemsName: '',
                  itemsPrice: '',
                  qty: 0,
                  itemsIcon: '',
                ));
    bool isDataExists = false;
    if (newItemsData.itemsName != '') {
      isDataExists = true;
      // print('Data sudah ada');
    } else {
      // print('Data belum ada');
    }
    return isDataExists;
  }

  void removeItemData(String itemsId) {
    _itemList.removeWhere((itemsData) => itemsData.itemsId == itemsId);
    notifyListeners();
  }

  void setItemsQty(ItemsCartData replacedItems, int qty) {
    _itemList[_itemList.indexWhere((element) => element == replacedItems)] =
        ItemsCartData(
      itemsId: replacedItems.itemsId,
      itemsCode: replacedItems.itemsCode,
      itemsName: replacedItems.itemsName,
      itemsPrice: replacedItems.itemsPrice,
      qty: qty,
      itemsIcon: replacedItems.itemsIcon,
    );
    notifyListeners();
  }

  void incItemsQty(ItemsCartData replacedItems) {
    _itemList[_itemList.indexWhere((element) => element == replacedItems)] =
        ItemsCartData(
      itemsId: replacedItems.itemsId,
      itemsCode: replacedItems.itemsCode,
      itemsName: replacedItems.itemsName,
      itemsPrice: replacedItems.itemsPrice,
      qty: replacedItems.qty + 1,
      itemsIcon: replacedItems.itemsIcon,
    );
    notifyListeners();
  }

  void decItemsQty(ItemsCartData replacedItems) {
    _itemList[_itemList.indexWhere((element) => element == replacedItems)] =
        ItemsCartData(
      itemsId: replacedItems.itemsId,
      itemsCode: replacedItems.itemsCode,
      itemsName: replacedItems.itemsName,
      itemsPrice: replacedItems.itemsPrice,
      // qty: replacedItems.qty > 1 ? replacedItems.qty - 1 : 1,
      qty: replacedItems.qty - 1,
      itemsIcon: replacedItems.itemsIcon,
    );
    notifyListeners();
  }

  void clearItemsData() {
    _itemList.clear();
    notifyListeners();
  }
}
