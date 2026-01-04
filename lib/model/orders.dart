class Orders {
  int? ordersId;
  int? ordersCustomerId;
  int? ordersStatus;
  int? ordersProductId;
  String ordersNumber;
  int ordersQty;
  int productPrice;
  String ordersPayment;
  int? ordersStoreId;
  String ordersDate;
  String productName;
  String storeName;
  String sizeName;
  String colorName;
  String brandName;
  String categoryName;

  Orders({
    this.ordersId,
    this.ordersCustomerId,
    this.ordersStatus,
    this.ordersProductId,
    this.ordersStoreId,
    required this.ordersNumber,
    required this.ordersQty,
    required this.productPrice,
    required this.ordersPayment,
    required this.ordersDate,
    required this.productName,
    required this.storeName,
    required this.sizeName,
    required this.colorName,
    required this.brandName,
    required this.categoryName,
  });
}
