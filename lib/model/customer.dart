class Customer {
  int? customer_id;         // auto increment
  String customer_email;
  String customer_password;
  String customer_name;
  String customer_phone;
  String customer_address;
  String? customer_signup_date;
  String? customer_withdraw_date;

  Customer(
    {
      this.customer_id,
      required this.customer_email,
      required this.customer_password,
      required this.customer_name,
      required this.customer_phone,
      required this.customer_address,
      this.customer_signup_date,
      this.customer_withdraw_date,
    }
  );

  factory Customer.fromJson(Map<String, dynamic> json) {
    // Json으로 받기
    return Customer(
      customer_id: json['customer_id'],
      customer_email: json['customer_email'],
      customer_password: json['customer_password'],
      customer_name: json['customer_name'],
      customer_phone: json['customer_phone'],
      customer_address: json['customer_address'],
      customer_signup_date: json['customer_signup_date'],
      customer_withdraw_date: json['customer_withdraw_date']
    );
  }

  Map<String, dynamic> toJson() {
    // Json에 보내기
    return {
      'customer_id': customer_id, 
      'customer_email': customer_email,
      'customer_password': customer_password,
      'customer_name': customer_name,
      'customer_phone': customer_phone,
      'customer_address': customer_email,
      'customer_signup_date': customer_signup_date,
      'customer_withdraw_date': customer_withdraw_date
    };
  }
}