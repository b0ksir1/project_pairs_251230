class Approval {
  int? approvalId;         // auto increment
  int approvalProductID;
  String approvalProductName;
  int approvalProductQty;
  int employeeId;
  int seniorEmployeeId;
  int directorEmployeeId;
  String approvalemplyeeName;
  String approvalemplyeeSeniorName;
  String approvalemplyeeDirectorName;
  int status;
  String date;
  Approval(
    {
      this.approvalId,
      required this.approvalProductID,
      required this.approvalProductName,
      required this.approvalProductQty,
      required this.employeeId,
      required this.seniorEmployeeId,
      required this.directorEmployeeId,
      required this.approvalemplyeeName,
      required this.approvalemplyeeSeniorName,
      required this.approvalemplyeeDirectorName,
      required this.status,
      required this.date
    }
  );

  factory Approval.fromJson(Map<String, dynamic> json) {
    // Json으로 받기
    return Approval(
      approvalId: json['approve_id'],
      approvalProductID: json['approve_product_id'],
      approvalProductName: json['product_name'],
      approvalProductQty: json['approve_quantity'],
      employeeId: json['approve_employee_id'],
      seniorEmployeeId: json['approve_senior_id'],
      directorEmployeeId: json['approve_director_id'],
      approvalemplyeeName: json['approve_employee_name'],
      approvalemplyeeSeniorName: json['approve_senior_name'],
      approvalemplyeeDirectorName: json['approve_director_name'],
      status : json['approve_status'],
      date:json['date']
    );
  }
}