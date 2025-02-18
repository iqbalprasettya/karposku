class ItemsData {
  final String itemsId;
  final String itemsCode;
  final String itemsName;
  final String itemsCategory;
  final String desc;
  final int buyPrice;
  final int sellPrice;
  final int promoValue;
  final int finalPrice;
  final bool isPromo;
  final String imgPath;

  ItemsData({
    required this.itemsId,
    required this.itemsCode,
    required this.itemsName,
    required this.itemsCategory,
    required this.desc,
    required this.buyPrice,
    required this.sellPrice,
    required this.promoValue,
    required this.finalPrice,
    required this.isPromo,
    required this.imgPath,
  });

  factory ItemsData.fromJson(Map<String, dynamic> json) {
    return ItemsData(
      itemsId: json['_id'],
      itemsCode: json['items_code'],
      itemsName: json['items_name'],
      itemsCategory: json['items_category'],
      desc: json['items_info'],
      buyPrice: json['price_buy'],
      sellPrice: json['price_sell'],
      promoValue: json['promo_value'],
      finalPrice: json['final_price'],
      isPromo: json['has_promo'],
      imgPath: json['icon'],
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': itemsId,
        'items_code': itemsCode,
        'items_name': itemsName,
        'items_category': itemsCategory,
        'items_info': desc,
        'price_buy': buyPrice,
        'price_sell': sellPrice,
        'promo_value': promoValue,
        'final_price': finalPrice,
        'has_promo': isPromo,
        'icon': imgPath,
      };
}
