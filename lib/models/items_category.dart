class ItemsCategory {
  final String categoryId;
  final String categoryName;
  // final int isActive;

  ItemsCategory({
    required this.categoryId,
    required this.categoryName,
    // required this.isActive,
  });

  factory ItemsCategory.fromJson(Map<String, dynamic> json) {
    return ItemsCategory(
      categoryId: json['_id'],
      categoryName: json['items_category_name'],
      // isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': categoryId,
        'items_category_name': categoryName,
        // 'is_active': isActive,
      };
}
