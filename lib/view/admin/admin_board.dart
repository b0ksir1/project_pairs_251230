import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_pairs_251230/model/board_post.dart';
import 'package:project_pairs_251230/util/side_menu.dart';
import 'package:project_pairs_251230/view/admin/admin_board_view.dart';
import 'package:project_pairs_251230/view/admin/admin_board_write.dart';
import 'package:project_pairs_251230/view/admin/admin_side_bar.dart';

class AdminBoard extends StatefulWidget {
  const AdminBoard({super.key});

  @override
  State<AdminBoard> createState() => _AdminBoardState();
}

class _AdminBoardState extends State<AdminBoard> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 241, 250, 253),
      body: Row(
        children: [
          AdminSideBar(selectedMenu: SideMenu.board, onMenuSelected: (menu) {}),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 80, 30, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                        child: Icon(Icons.inventory, size: 30),
                      ),
                      Text('게시판 관리', style: _adminTitle()),
                    ],
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Get.to(AdminBoardWrite());
                    },
                    child: Text('새 글 작성'),
                  ),
                  SizedBox(height: 8),
                  _buildHead(),
                  SizedBox(height: 8),
                  _buildBody()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  } // build

  // === Widgets ===

  Widget _buildCard(DocumentSnapshot doc) 
  {
    final post = BoardPost(
      title: doc['title'], 
      msg: doc['msg'], 
      date: doc['date'], 
      employeeId: doc['employeeId'], 
      reply: doc['reply'],
      id: doc.id);
    return SizedBox(
      height: 50,
      child: GestureDetector(
        onTap: () {
          Get.to(AdminBoardView(), arguments: post);
          
        },
        child: Card(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              child: Center(child: Text(post.title, style: headerStyle())),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.2,
              // child: Center(child: Text(post.employeeId.toString(), style: headerStyle())),
              child: Center(child: Text('관리자', style: headerStyle())),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.2,
              child: Center(child: Text(post.date, style: headerStyle())),
            ),
          ],),
        ),
      ),
    );
  }
  Widget _buildBody()
  {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('board')
            .orderBy('date',descending: false)
            .snapshots(),
        builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  final documents = snapshot.data!.docs;
                  return Expanded(
                    child: ListView(
                                  children: documents.map((e)=> _buildCard(e),).toList()
                                ),
                  );
                }
              },
            );
  }
  Widget _buildHead()
  {
     return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          child: Center(child: Text('제목', style: headerStyle())),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.2,
          child: Center(child: Text('작성자', style: headerStyle())),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.2,
          child: Center(child: Text('등록일 ', style: headerStyle())),
        ),
      ],
    ); 
  }

  TextStyle _adminTitle() {
    return TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  }

  TextStyle headerStyle() {
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
      color: Colors.black,
    );
  }

  // === Functions ===
}// class 
