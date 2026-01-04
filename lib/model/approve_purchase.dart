class ApprovePurchase {
  int? approvalId;         // auto increment
  int approvalProductID;
  String approvalProductName;
  int approvalProductQty;
  int status;
  ApprovePurchase(
    {
      this.approvalId,
      required this.approvalProductID,
      required this.approvalProductName,
      required this.approvalProductQty,
      required this.status,
    }
  );

  factory ApprovePurchase.fromJson(Map<String, dynamic> json) {
    // Json으로 받기
    return ApprovePurchase(
      approvalId: json['approve_id'],
      approvalProductID: json['approve_product_id'],
      approvalProductName: json['product_name'],
      approvalProductQty: json['approve_quantity'],
      status : json['approve_status'],
    );
  }
}