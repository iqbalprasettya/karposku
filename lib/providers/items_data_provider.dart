import 'package:flutter/material.dart';
import 'package:karposku/models/items_data.dart';

class ItemsDataProvider with ChangeNotifier {
  late ItemsData _itemsData = ItemsData(
    itemsId: '',
    itemsCode: '',
    itemsName: '',
    itemsCategory: '',
    desc: '',
    buyPrice: 0,
    sellPrice: 0,
    promoValue: 0,
    finalPrice: 0,
    isPromo: false,
    imgPath: '',
  );

  ItemsData get itemsData {
    return _itemsData;
  }

  void addItemsData(ItemsData itemsData) {
    _itemsData = ItemsData(
      itemsId: itemsData.itemsId,
      itemsCode: itemsData.itemsCode,
      itemsName: itemsData.itemsName,
      itemsCategory: itemsData.itemsCategory,
      desc: itemsData.desc,
      buyPrice: itemsData.buyPrice,
      sellPrice: itemsData.sellPrice,
      promoValue: itemsData.promoValue,
      finalPrice: itemsData.finalPrice,
      isPromo: itemsData.isPromo,
      imgPath: itemsData.imgPath,
    );
    notifyListeners();
  }
}
