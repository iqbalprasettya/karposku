class InvoiceData {
  // final String doId;
  final String status;
  final String total;
  final String message;
  final List<InvData> data;

  InvoiceData(
    // this.doId,
    this.status,
    this.total,
    this.message,
    this.data,
  );

  factory InvoiceData.fromJson(dynamic json) {
    if (json['data'] != null) {
      var tagObjsJson = json['data'] as List;
      List<InvData> invData =
          tagObjsJson.map((tagJson) => InvData.fromJson(tagJson)).toList();

      return InvoiceData(
        // json['do_id'] as String,
        json['status'] as String,
        json['total'] as String,
        json['message'] as String,
        invData,
      );
    } else {
      return InvoiceData(
        // json['do_id'] as String,
        json['status'] as String,
        json['total'] as String,
        json['message'] as String,
        [],
      );
    }
  }

  @override
  String toString() {
    return '{ $status, $total, $message, $data }';
  }
}

class InvData {
  final String id;
  final String invoiceNo;
  final String invoiceDate;
  final String invoiceStatus;
  final String grandTotal;
  final List<ItemsMasterData> itemsData;

  InvData(
    this.id,
    this.invoiceNo,
    this.invoiceDate,
    this.invoiceStatus,
    this.grandTotal,
    this.itemsData,
  );

  factory InvData.fromJson(dynamic json) {
    if (json['detail_invoice'] != null) {
      var tagObjsJson = json['detail_invoice'] as List;
      List<ItemsMasterData> itemsData = tagObjsJson
          .map((tagJson) => ItemsMasterData.fromJson(tagJson))
          .toList();

      return InvData(
        json['_id'] as String,
        json['invoice_no'] as String,
        json['invoice_date'] as String,
        json['doc_status'] as String,
        json['grand_total'] as String,
        itemsData,
      );
    } else {
      return InvData(
        json['_id'] as String,
        json['invoice_no'] as String,
        json['invoice_date'] as String,
        json['doc_status'] as String,
        json['grand_total'] as String,
        [],
      );
    }
  }

  @override
  String toString() {
    return '{ $id, $invoiceNo, $invoiceDate, $invoiceStatus, $grandTotal }';
  }
}

class ItemsMasterData {
  String itemsId;
  String itemsCode;
  String itemsName;
  int qty;
  // int gallonQty;
  String price;
  String subtotal;
  // bool isContainer;

  ItemsMasterData(
    this.itemsId,
    this.itemsCode,
    this.itemsName,
    this.qty,
    // this.gallonQty,
    this.price,
    this.subtotal,
    // this.isContainer,
  );

  factory ItemsMasterData.fromJson(dynamic json) {
    return ItemsMasterData(
      json['_id'] as String,
      json['items_code'] as String,
      json['items_name'] as String,
      json['qty'] as int,
      // json['gallon_qty'] as int,
      json['price'] as String,
      json['subtotal'] as String,
      // json['is_container'] as bool,
    );
  }

  @override
  String toString() {
    // return '{ ${this.name}, ${this.quantity} }';
    return '{ $itemsId, $itemsCode, $itemsName, $qty,  $price, $subtotal }';
  }
}
