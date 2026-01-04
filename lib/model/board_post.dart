class BoardPost {
  String title;
  String msg;
  String date;
  int employeeId;
  List reply;
  String id;

  BoardPost({
    required this.title,
    required this.msg,
    required this.date,
    required this.employeeId,
    required this.reply,
    required this.id
  });
}