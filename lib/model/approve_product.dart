class ApproveProduct {
  int? productId;         // auto increment
  String productName;
  String productColor;
  String productSize;
  String productBrand;
  String productCategory;
  int productPrice;

  ApproveProduct(
    {
      this.productId,
      required this.productName,
      required this.productColor,
      required this.productSize,
      required this.productBrand,
      required this.productCategory,
      required this.productPrice,
    }
  );

  factory ApproveProduct.fromJson(Map<String, dynamic> json) {
    // Json으로 받기
    return ApproveProduct(
      productId: json['productId'],
      productName: json['productName'],
      productColor: json['color'],
      productSize: json['size'],
      productBrand: json['brand'],
      productCategory: json['category'],
      productPrice: json['price'],
    );
  }
}