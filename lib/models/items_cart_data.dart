class ItemsCartData {
  final String itemsId;
  final String itemsCode;
  final String itemsName;
  final String itemsPrice;
  final int qty;
  final String itemsIcon;

  ItemsCartData({
    required this.itemsId,
    required this.itemsCode,
    required this.itemsName,
    required this.itemsPrice,
    required this.qty,
    required this.itemsIcon,
  });

  factory ItemsCartData.fromJson(Map<String, dynamic> json) {
    return ItemsCartData(
      itemsId: json['_id'],
      itemsCode: json['items_code'],
      itemsName: json['items_name'],
      itemsPrice: json['price_sell'],
      qty: json['qty'],
      itemsIcon: json['icon'],
    );
  }

  Map<String, dynamic> toJson() => {
        'items_id': itemsId,
        'items_code': itemsCode,
        'items_name': itemsName,
        'price_sell': itemsPrice,
        'qty': qty,
        'icon': itemsIcon,
      };

  // Map<String, dynamic> toJsonNoImage() => {
  //       'items_id': itemsId,
  //       'items_code': itemsCode,
  //       'items_name': itemsName,
  //       'price_sell': itemsPrice,
  //       'qty': qty,
  //     };
}
