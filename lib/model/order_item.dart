class OrderItem {       // payment_options에 사용했음
   int productId;
   String name;
   int size;
   int price;
   int imageId;
   int qty;

  OrderItem({
    required this.productId,
    required this.name,
    required this.size,
    required this.price,
    required this.imageId,
    required this.qty,
  });

  Map<String, dynamic> toJson() => {
    "productId": productId,
    "name": name,
    "size": size,
    "price": price,
    "imageId": imageId,
    "qty": qty,
  };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    productId: json["productId"],
    name: json["name"],
    size: json["size"],
    price: json["price"],
    imageId: json["imageId"],
    qty: json["qty"],
  );
}