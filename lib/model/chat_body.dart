class ChatBody {
  String customerId;
  String employeeId;
  List dialog;
  String startAt;

  ChatBody({
    required this.customerId,
    required this.employeeId,
    required this.dialog,
    required this.startAt
  });
}