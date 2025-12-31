import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_pairs_251230/model/chat_message.dart';

class AdminChat extends StatefulWidget {
  const AdminChat({super.key});

  @override
  State<AdminChat> createState() => _AdminChatState();
}

class _AdminChatState extends State<AdminChat> {
  // === Property ===
  String customerID = "employee01";
  String _id = Get.arguments ?? "__";
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('채팅')),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chatting')
                  .doc(_id)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  final documents = snapshot.data!;
                  final List dialogs = documents['dialog'] ?? [];
                  return ListView(
                    children: dialogs.map((e) => buildItemWidget(e)).toList(),
                  );
                }
              },
            ),
          ),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(labelText: "메시지 입력"),
                ),
              ),
              ElevatedButton(
                onPressed: () => sendMessage(),
                child: Text('보내기'),
              ),
            ],
          ),
        ],
      ),
    );
  } // build

  // === Widget ===

  Widget buildItemWidget(dynamic d) {
    final msg = ChatMessage(
      talker: d['talker'],
      msg: d['message'],
      date: d['date'],
    );
    bool isMe = msg.talker == 'customer' ? false : true;
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: isMe ? Colors.yellowAccent : Colors.grey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                msg.msg,
                style: TextStyle(
                  color: isMe ? Colors.black : Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // === Functions ===

  Future sendMessage() async {
    await FirebaseFirestore.instance.collection("chatting").doc(_id).update({
      'dialog': FieldValue.arrayUnion([
        {
          'date': Timestamp.now().toString().substring(0, 10),
          'message': _controller.text.trim(),
          'talker': 'employee',
        },
      ]),
    });
  }
} // class
