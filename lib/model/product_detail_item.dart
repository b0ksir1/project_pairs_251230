class  ProductDetailItem {
  int? productId;         // auto increment
  String productName;
  int colorId;
  String colorName;
  int sizeId;
  String sizeName;
  int brandId;
  int categoryId;
  String productDescription;
  int price;
  int qty;

  ProductDetailItem({
    this.productId,
    required this.productName,
    required this.colorId,
    required this.colorName,
    required this.sizeId,
    required this.sizeName,
    required this.brandId,
    required this.categoryId,
    required this.productDescription,
    required this.price,
    required this.qty,

  });

  factory ProductDetailItem.fromJson(Map<String, dynamic> json) {
    // Json으로 받기
    return ProductDetailItem(
      productId: json['product_id'],
      productName: json['product_name'], 
      colorId: json['product_color_id'],
      colorName: json['product_color_name'],
      sizeId: json['product_size_id'],
      sizeName: json['product_size_name'],
      brandId: json['product_brand_id'],
      categoryId: json['product_category_id'],
      productDescription: json['product_description'],
      price: json['product_price'],
      qty: json['stock_quantity']
    );
  }
}