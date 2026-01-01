class Product {
  int? product_id;         // auto increment
  String product_name;
  int product_price;
  String product_description;
  int product_color_id;
  int product_size_id;
  int product_category_id;
  int product_brand_id;

  Product(
    {
      this.product_id,
      required this.product_name,
      required this.product_price,
      required this.product_description,
      required this.product_color_id,
      required this.product_size_id,
      required this.product_category_id,
      required this.product_brand_id,
    }
  );

  factory Product.fromJson(Map<String, dynamic> json) {
    // Json으로 받기
    return Product(
      product_id: json['product_id'],
      product_name: json['product_name'],
      product_price: json['product_price'],
      product_description: json['product_description'],
      product_color_id: json['product_color_id'],
      product_size_id: json['product_size_id'],
      product_category_id: json['product_category_id'],
      product_brand_id: json['product_brand_id']
    );
  }

  Map<String, dynamic> toJson() {
    // Json에 보내기
    return{
      'product_id': product_id, 
      'product_name': product_name,
      'product_price': product_price,
      'product_description': product_description,
      'product_color_id': product_color_id,
      'product_size_id': product_size_id,
      'product_category_id': product_category_id,
      'product_brand_id': product_brand_id
    };
  }
}