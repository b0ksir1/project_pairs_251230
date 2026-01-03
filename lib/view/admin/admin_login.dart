import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:project_pairs_251230/view/admin/admin_dashboard.dart';
import 'package:http/http.dart' as http;
import 'package:project_pairs_251230/view/admin/admin_find_password.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  // -----------property-----------

  final TextEditingController adminIdController = TextEditingController();
  final TextEditingController adminPwController = TextEditingController();
  final adminBox = GetStorage();
  bool adminRemember = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    adminIdController.dispose();
    adminPwController.dispose();
    super.dispose();
  }

  //============= 로그인 =====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'images/admin_login_image.png',
                  fit: BoxFit.cover,
                  height: double.infinity,
                ),
                Container(color: Colors.black.withAlpha(120)),
                Positioned(
                  bottom: 40,
                  left: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ON & Tap',
                        style: TextStyle(
                          color: const Color.fromARGB(201, 255, 255, 255),
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Manage Your Inventory\nStreamline operations, track orders, and keep your store \nrunning smoothly.',
                        style: TextStyle(
                          color: const Color.fromARGB(201, 255, 255, 255),
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(50, 150, 50, 0),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    '관리자 로그인',
                    style: TextStyle(fontSize: 40, color: Colors.black),
                  ),
                  Text(
                    '환영합니다. 로그인 해주세요.',
                    style: TextStyle(fontSize: 30, color: Colors.black),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 5),
                    child: Text('관리자 아이디', style: TextStyle(fontSize: 16)),
                  ),
                  TextField(
                    controller: adminIdController,
                    decoration: InputDecoration(
                      hintText: 'abc@gmail.com',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(3),
                        borderSide: BorderSide(color: Colors.black, width: 1),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),

                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2),
                        borderSide: const BorderSide(color: Colors.red),
                      ),

                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                    child: Text('관리자 비밀번호', style: TextStyle(fontSize: 16)),
                  ),

                  TextField(
                    controller: adminPwController,
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(3),
                        borderSide: BorderSide(color: Colors.black, width: 1),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),

                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2),
                        borderSide: const BorderSide(color: Colors.red),
                      ),

                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Row(
                      //   children: [
                      //     Checkbox(
                      //       value: adminRemember,
                      //       activeColor: Colors.black,
                      //       side: BorderSide(
                      //         color: Colors.black,
                      //         width: 2,
                      //       ),
                      //       onChanged: (value) {
                      //         adminRemember = value!;
                      //         setState(() {});
                      //       },
                      //     ),
                      //     Text('Remember me'),
                      //   ],
                      // ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              Get.to(AdminFindPassword());
                            },
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(color: Colors.blueAccent),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(3),
                          ),
                        ),
                        onPressed: () async {
                          await adminLogin();
                        },
                        child: Text('로그인', style: TextStyle(fontSize: 20)),
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

  Future<void> adminLogin() async {
    final url = Uri.parse("http://172.16.250.250:8000/employee/adminLogin");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'employee_email': adminIdController.text.trim(),
        'employee_password': adminPwController.text.trim(),
      }),
    );
    print('3️⃣ 응답 받음');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['result'] == 'OK') {
        adminBox.write('employee_email', adminIdController.text.trim());
        adminBox.write('employee_token', data['token']);
        adminBox.write('isAdminLogin', true);

        Get.offAll(() => const AdminDashboard());
      } else {
        Get.snackbar('로그인 실패', '아이디 또는 비밀번호를 확인하세요.');
      }
    }
  }
} // class
