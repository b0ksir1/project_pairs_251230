import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminFindPassword extends StatefulWidget {
  const AdminFindPassword({super.key});

  @override
  State<AdminFindPassword> createState() =>
      _AdminFindPasswordState();
}

class _AdminFindPasswordState
    extends State<AdminFindPassword> {
  // =========== property =================
  TextEditingController adminIdController =
      TextEditingController();
  TextEditingController adminNameController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('관리자 정보 찾기'),
        toolbarHeight: 80,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            100,
            130,
            100,
            100,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '관리자 계정 확인',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  0,
                  20,
                  0,
                  5,
                ),
                child: Text(
                  '등록된 이메일을 입력하세요.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
              TextField(
                controller: adminIdController,
                decoration: InputDecoration(
                  hintText: 'abc@gmail.com',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      2,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  0,
                  10,
                  0,
                  5,
                ),
                child: Text(
                  '관리자 이름을 입력하세요.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
              TextField(
                controller: adminNameController,
                decoration: InputDecoration(
                  hintText: '김00',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      2,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  0,
                  30,
                  0,
                  0,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: () {
                      if (adminIdController
                              .text
                              .isEmpty ||
                          adminNameController
                              .text
                              .isEmpty) {
                        Get.snackbar(
                          '입력 오류',
                          '이메일과 이름을 모두 입력해주세요.',
                        );
                        return;
                      }
                      _findInfoDialog();
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadiusGeometry.circular(
                              3,
                            ),
                      ),
                    ),
                    child: Text('다음'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  } // build

  // ============== functions =================
  void _findInfoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            '입력하신 이메일로\n비밀번호를 전송했습니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              height: 42,

              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadiusGeometry.circular(3),
                  ),
                ),
                child: Text('확인'),
              ),
            ),
          ],
        );
      },
    );
  }
} // class
