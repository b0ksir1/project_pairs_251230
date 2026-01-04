class ProductByCategory {
  int? brand_id;          // auto increment
  String brand_name;
  int product_id;
  String product_name;
  int product_price;

  ProductByCategory(
    {
      this.brand_id,
      required this.brand_name,
      required this.product_id,
      required this.product_name,
      required this.product_price,
    }
  );

  factory ProductByCategory.fromJson(Map<String, dynamic> json) {
    // Json으로 받기
    return ProductByCategory(
      brand_id: json['brand_id'],
      brand_name: json['brand_name'],
      product_id: json['product_id'],
      product_name: json['product_name'],
      product_price: json['product_price']
    );
  }

  Map<String, dynamic> toJson() {
    // Json에 보내기
    return{
      'brand_id': brand_id,
      'brand_name': brand_name,
      'product_id': product_id, 
      'product_name': product_name,
      'product_price': product_price
    };
  }
}