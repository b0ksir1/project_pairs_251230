import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_pairs_251230/view/admin/admin_chat.dart';

class AdminChatList extends StatefulWidget {
  const AdminChatList({super.key});

  @override
  State<AdminChatList> createState() => _AdminChatListState();
}

class _AdminChatListState extends State<AdminChatList> {
  // === Property ===
  String employeeID = "employee01";

  List myCustomers = [];
  List newCustomers = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('채팅')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chatting')
            .where('employeeId', whereIn: ['empty', employeeID])
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else {
            final documents = snapshot.data!.docs;
            myCustomers.clear();
            newCustomers.clear();

            for (var item in documents) {
              item['employeeId'] == employeeID
                  ? myCustomers.add(item)
                  : newCustomers.add(item);
            }
            return ListView(
              children: [

                 Text('내가 상담하는 고객', style: TextStyle(fontSize: 20),),

                ...myCustomers.map((e) => buildItemWidget(e)),

                Divider(color: Colors.black, height: 2),
                 Text('담당자가 없는 고객', style: TextStyle(fontSize: 20),),

                ...newCustomers.map((e) => buildItemWidget(e)),
              ],
            );
          }
        },
      ),
    );
  } // build

  // === Functions ===
  Widget buildItemWidget(DocumentSnapshot doc) {
    return GestureDetector(
      onTap: () {
        Get.to(AdminChat(), arguments: doc.id);
      },
      child: Card(child: Text(doc.id)),
    );
  }
  // === Functions ===

  Future openChatting() async {
    DocumentReference ref = await FirebaseFirestore.instance
        .collection("chatting")
        .add({
          'employeeId': employeeID,
          'startAt': DateTime.now().toString().substring(0, 10),
          'dialog': FieldValue.arrayUnion([]),
        });

    Get.to(AdminChatList(), arguments: ref.id);
  }
} // class
