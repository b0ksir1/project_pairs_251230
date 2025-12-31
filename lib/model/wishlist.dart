class Wishlist {
  int wishlist_id;
  int wishlist_customer_id;
  int wishlist_product_id;
  String? wishlist_date;

  Wishlist({
    required this.wishlist_id,
    required this.wishlist_customer_id,
    required this.wishlist_product_id,
    this.wishlist_date,
  });
  factory Wishlist.fromMap(Map<String, dynamic> map) {
    return Wishlist(
      wishlist_id: map['wishlist_id'],
      wishlist_customer_id: map['wishlist_customer_id'],
      wishlist_product_id: map['wishlist_product_id'],
      wishlist_date: map['wishlist_date'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'wishlist_id': wishlist_id,
      'wishlist_customer_id': wishlist_customer_id,
      'wishlist_product_id': wishlist_product_id,
      'wishlist_date': wishlist_date,
    };
  }

  factory Wishlist.fromJson(Map<String, dynamic> json) {
    return Wishlist(
      wishlist_id: json['wishlist_id'],
      wishlist_customer_id: json['wishlist_customer_id'],
      wishlist_product_id: json['wishlist_product_id'],
      wishlist_date: json['wishlist_date'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'wishlist_id': wishlist_id,
      'wishlist_customer_id': wishlist_customer_id,
      'wishlist_product_id': wishlist_product_id,
      'wishlist_date': wishlist_date,
    };
  }
}
