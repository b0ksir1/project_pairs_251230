import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_pairs_251230/util/message.dart';
import 'package:project_pairs_251230/util/side_menu.dart';
import 'package:project_pairs_251230/view/admin/admin_side_bar.dart';

class AdminBoardWrite extends StatefulWidget {
  const AdminBoardWrite({super.key});

  @override
  State<AdminBoardWrite> createState() => _AdminBoardWriteState();
}

class _AdminBoardWriteState extends State<AdminBoardWrite> {
 final _titleCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();

  bool _saving = false;

  Message message = Message();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    final msg = _msgCtrl.text.trim();

    if (title.isEmpty || msg.isEmpty) {
      message.errorSnackBar('입력 오류', '제목과 내용을 입력하세요.');
      return;
    }

    setState(() => _saving = true);

    try {
      final docRef = FirebaseFirestore.instance.collection('board').doc(); // 자동 id
      await docRef.set({
        'title': title,
        'msg': msg,
        'employeeId': 1,
        'date': DateTime.now().toString().substring(0,10),
        'reply': [], // 댓글 배열 초기화
      });
      message.successSnackBar("완료", "게시글이 등록되었습니다.");
      Navigator.of(context).maybePop();
    } catch (e) {
      message.errorSnackBar("실패", "등록 중 오류가 발생했습니다.\n$e");
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

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
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "게시글 작성",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: _saving ? null : _submit,
                        child: _saving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text("등록"),
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
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "제목",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _titleCtrl,
                              decoration: const InputDecoration(
                                hintText: "제목을 입력하세요",
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                            const SizedBox(height: 20),

                            const Text(
                              "내용",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _msgCtrl,
                              minLines: 12,
                              maxLines: null,
                              decoration: const InputDecoration(
                                hintText: "내용을 입력하세요",
                                border: OutlineInputBorder(),
                                alignLabelWithHint: true,
                              ),
                            ),

                            const SizedBox(height: 20),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                  onPressed: _saving
                                      ? null
                                      : () => Navigator.of(context).maybePop(),
                                  child: const Text("취소"),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: _saving ? null : _submit,
                                  child: const Text("등록"),
                                ),
                              ],
                            ),
                          ],
                        ),
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
  }
}