class OrdersDelivery {
  int? ordersId;
  int ordersQty;
  int stockQty;
  String ordersNumber;
  String ordersDate;
  String productName;
  String storeName;
  String customerName;
  int productId;

  OrdersDelivery({
    this.ordersId,
    required this.ordersQty,
    required this.stockQty,
    required this.ordersNumber,
    required this.ordersDate,
    required this.productName,
    required this.storeName,
    required this.customerName,
    required this.productId
  });
}