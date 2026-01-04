class Category {
  int? category_id;         // auto increment
  String category_name;

  Category(
    {
      this.category_id,
      required this.category_name,
    }
  );

  factory Category.fromJson(Map<String, dynamic> json) {
    // Json으로 받기
    return Category(
      category_id: json['category_id'],
      category_name: json['category_name']
    );
  }

  Map<String, dynamic> toJson() {
    // Json에 보내기
    return {
      'category_id': category_id, 
      'category_name': category_name,
    };
  }
}