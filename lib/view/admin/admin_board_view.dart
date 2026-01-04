import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:project_pairs_251230/model/board_post.dart';
import 'package:project_pairs_251230/model/board_reply.dart';
import 'package:project_pairs_251230/util/side_menu.dart';
import 'package:project_pairs_251230/view/admin/admin_side_bar.dart';

class AdminBoardView extends StatefulWidget {
  const AdminBoardView({super.key});

  @override
  State<AdminBoardView> createState() => _AdminBoardViewState();
}

class _AdminBoardViewState extends State<AdminBoardView> {
  BoardPost post = Get.arguments;
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 241, 250, 253),
      body: Row(
        children: [
          AdminSideBar(selectedMenu: SideMenu.board, onMenuSelected: (menu) {}),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.of(context).maybePop();
                        },
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "게시판 관리",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 12),
                                Text(
                                  post.title,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: Colors.black12,
                                      child: Icon(Icons.person, size: 16),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "관리자",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Divider(height: 1),
                          // 본문
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      24,
                                      20,
                                      24,
                                      24,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          post.msg,
                                          style: TextStyle(
                                            fontSize: 14,
                                            height: 1.6,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Divider(height: 1),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      24,
                                      12,
                                      24,
                                      16,
                                    ),
                                    child: Row(
                                      children: [
                                        Text('댓글 ${post.reply.length}개'),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      24,
                                      12,
                                      24,
                                      16,
                                    ),
                                    child: SizedBox(
                                      height: 300,
                                      child: StreamBuilder<DocumentSnapshot>(
                                        stream: FirebaseFirestore.instance
                                            .collection('board')
                                            .doc(post.id)
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return Center(
                                              child: CircularProgressIndicator(),
                                            );
                                          } else {
                                            final documents = snapshot.data!;
                                            final List dialogs =
                                                documents['reply'] ?? [];
                                      
                                            return ListView(
                                              children: dialogs
                                                  .map((e) => reply(e))
                                                  .toList(),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                    // child: ListView.builder(
                                    //   shrinkWrap: true,
                                    //   itemCount: post.reply.length,
                                    //   itemBuilder: (context, index) {
                                    //     return reply(index);
                                    //   },
                                    // ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      24,
                                      12,
                                      24,
                                      16,
                                    ),
                                    child: TextField(
                                      controller: _controller,
                                      decoration: InputDecoration(
                                        hintText: '댓글을 달아주세요',
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      24,
                                      12,
                                      24,
                                      16,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            if (_controller.text
                                                .trim()
                                                .isNotEmpty) {
                                              sendMessage();
                                            }
                                          },
                                          child: Text('댓글 입력'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Divider(height: 1),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  } // build

  // === Widgets ===

  Widget reply(dynamic d) {
    final msg = BoardReply(
      text: d['text'], 
      emlpoyee: d['employee'], 
      date: d['date']);
    return Card(
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  // 'dsdsdd',
                  '${msg.emlpoyee} / ${msg.date}',
                ),
              ),
            ],
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                // child: Text('sdsdssdsdsd'),
                child: Text(msg.text),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // === Functions ===

  Future sendMessage() async {
    await FirebaseFirestore.instance.collection("board").doc(post.id).update({
      'reply': FieldValue.arrayUnion([
        {
          'date': DateTime.now().toString(),
          'text': _controller.text.trim(),
          'employee': 'employee',
        },
      ]),
    });
    setState(() {});
  }
} // class
