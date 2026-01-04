class Returns {
  int returns_id;
  int returns_customer_id;
  int returns_employee_id;
  String returns_description;
  int returns_orders_id;
  int store_store_id;
  int returns_status; // ✅ 추가 (0: 대기중, 1: 완료)
  String? returns_create_date;
  String? returns_update_date;

  String? customer_name;
  String? store_name;
  String? orders_number;
  String? orders_date;
  int? orders_quantity;
  int? total_price;
  String? product_name;
  int? product_id;
  int? product_price;
  String? size_name;
  int? images_id;

  Returns({
    required this.returns_id,
    required this.returns_customer_id,
    required this.returns_employee_id,
    required this.returns_description,
    required this.returns_orders_id,
    required this.store_store_id,
    required this.returns_status,
    this.returns_create_date,
    this.returns_update_date,
    this.customer_name,
    this.store_name,
    this.orders_number,
    this.orders_date,
    this.orders_quantity,
    this.total_price,
    this.product_name,
    this.product_id,
    this.product_price,
    this.size_name,
    this.images_id,
  });

  factory Returns.fromJson(Map<String, dynamic> json) {
    return Returns(
      returns_id: json['returns_id'],
      returns_customer_id: json['returns_customer_id'],
      returns_employee_id: json['returns_employee_id'],
      returns_description: json['returns_description'],
      returns_orders_id: json['returns_orders_id'],
      store_store_id: json['store_store_id'],
      returns_status: json['returns_status'] ?? 0,
      returns_create_date: json['returns_create_date'],
      returns_update_date: json['returns_update_date'],

      customer_name: json['customer_name'],
      store_name: json['store_name'],
      orders_number: json['orders_number'],
      orders_date: json['orders_date'],
      orders_quantity: json['orders_quantity'],
      total_price: json['total_price'],
      product_name: json['product_name'],
      product_id: json['product_id'],
      product_price: json['product_price'],
      size_name: json['size_name'],
      images_id: json['images_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'returns_id': returns_id,
      'returns_customer_id': returns_customer_id,
      'returns_employee_id': returns_employee_id,
      'returns_description': returns_description,
      'returns_orders_id': returns_orders_id,
      'store_store_id': store_store_id,
      'returns_status': returns_status,
      'returns_create_date': returns_create_date,
      'returns_update_date': returns_update_date,

      'customer_name': customer_name,
      'store_name': store_name,
      'orders_number': orders_number,
      'orders_date': orders_date,
      'orders_quantity': orders_quantity,
      'total_price': total_price,
      'product_name': product_name,
      'product_id': product_id,
      'product_price': product_price,
      'size_name': size_name,
      'images_id': images_id,
    };
  }
}
