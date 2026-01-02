class Store {
  int? storeId;
  String storeName;
  String storePhone;
  double storeLat;
  double storeLng;

  Store({
    this.storeId,
    required this.storeName,
    required this.storePhone,
    required this.storeLat,
    required this.storeLng,
  });
}