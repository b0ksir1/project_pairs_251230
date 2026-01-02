class Store {
  int? store_id;         // auto increment
  String store_name;
  String store_phone;
  double store_lat;
  double store_lng;

  double? km_distance;

  Store(
    {
      this.store_id,
      required this.store_name,
      required this.store_phone,
      required this.store_lat,
      required this.store_lng,
      this.km_distance = 0
    }
  );

  factory Store.fromJson(Map<String, dynamic> json) {
    // Json으로 받기
    return Store(
      store_id: json['store_id'],
      store_name: json['store_name'],
      store_phone: json['store_phone'],
      store_lat: json['store_lat'],
      store_lng: json['store_lng'],
    );
  }

  Map<String, dynamic> toJson() {
    // Json에 보내기
    return {
      'store_id': store_id, 
      'store_name': store_name,
      'store_phone': store_phone,
      'store_lat': store_lat,
      'store_lng': store_lng,
    };
  }
}