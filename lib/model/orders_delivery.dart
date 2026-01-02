class OrdersDelivery {
  int? ordersId;
  int ordersQty;
  int ordersNumber;
  String ordersDate;
  String productName;
  String storeName;
  String customerName;

  OrdersDelivery({
    this.ordersId,
    required this.ordersQty,
    required this.ordersNumber,
    required this.ordersDate,
    required this.productName,
    required this.storeName,
    required this.customerName,
  });
}