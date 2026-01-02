class Cart {
  int cart_id;
  int cart_customer_id;
  int cart_product_id;
  String? cart_date;
  int cart_product_quantity;

  Cart({
    required this.cart_id,
    required this.cart_customer_id,
    required this.cart_product_id,
    this.cart_date,
    required this.cart_product_quantity,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      cart_id: json['cart_id'],
      cart_customer_id: json['cart_customer_id'],
      cart_product_id: json['cart_product_id'],
      cart_date: json['cart_date'],
      cart_product_quantity: json['cart_product_quantity'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'cart_id': cart_id,
      'cart_customer_id': cart_customer_id,
      'cart_product_id': cart_product_id,
      'cart_date': cart_date,
      'cart_product_quantity': cart_product_quantity,
    };
  }
}
