class Cart {
  int cart_id;
  int cart_customer_id;
  int cart_product_id;
  String? cart_date;
  int cart_product_quantity;
  String? product_name;
  int? product_price;
  String? size_name;
  int? images_id;

  Cart({
    required this.cart_id,
    required this.cart_customer_id,
    required this.cart_product_id,
    this.cart_date,
    required this.cart_product_quantity,
    this.product_name,
    this.product_price,
    this.size_name,
    this.images_id,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      cart_id: json['cart_id'],
      cart_customer_id: json['cart_customer_id'],
      cart_product_id: json['cart_product_id'],
      cart_date: json['cart_date'],
      cart_product_quantity: json['cart_product_quantity'],
      product_name: json['product_name'],
      product_price: json['product_price'],
      size_name: json['size_name'],
      images_id: json['images_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cart_id': cart_id,
      'cart_customer_id': cart_customer_id,
      'cart_product_id': cart_product_id,
      'cart_date': cart_date,
      'cart_product_quantity': cart_product_quantity,
      'product_name': product_name,
      'product_price': product_price,
      'size_name': size_name,
      'images_id': images_id,
    };
  }
}
