class InvoicePackingData {
  final String id;
  final String customerName;
  final double total;
  final String docStatus;
  final List<InvoicePackingItem> detail;

  InvoicePackingData({
    required this.id,
    required this.customerName,
    required this.total,
    required this.docStatus,
    required this.detail,
  });

  factory InvoicePackingData.fromJson(Map<String, dynamic> json) {
    return InvoicePackingData(
      id: json['id'] ?? '',
      customerName: json['customer_name'] ?? '',
      total: double.parse(json['total'].toString()),
      docStatus: json['doc_status'] ?? '',
      detail: (json['detail'] as List)
          .map((item) => InvoicePackingItem.fromJson(item))
          .toList(),
    );
  }
}

class InvoicePackingItem {
  final String itemsId;
  String itemsName;
  final int qty;
  final double price;
  final double subtotal;

  InvoicePackingItem({
    required this.itemsId,
    required this.itemsName,
    required this.qty,
    required this.price,
    required this.subtotal,
  });

  factory InvoicePackingItem.fromJson(Map<String, dynamic> json) {
    return InvoicePackingItem(
      itemsId: json['items_id'] ?? '',
      itemsName: json['items_name'] ?? '',
      qty: json['qty'] ?? 0,
      price: double.parse(json['price'].toString()),
      subtotal: double.parse(json['subtotal'].toString()),
    );
  }
}
