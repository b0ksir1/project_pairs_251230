import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_pairs_251230/util/global_data.dart';
import 'package:project_pairs_251230/util/message.dart';
// import 'package:project_pairs_251230/view/auth/find_id_password.dart';
import 'package:project_pairs_251230/view/auth/sign_up.dart';
import 'package:project_pairs_251230/view/product/main_page.dart';
import 'package:http/http.dart' as http;

class CustomerLogin extends StatefulWidget {
  const CustomerLogin({super.key});

  @override
  State<CustomerLogin> createState() => _CustomerLoginState();
}

class _CustomerLoginState extends State<CustomerLogin> {
  // Property
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late bool showPassword; // 비밀번호 숨김 on/off 토글

  Message message = Message(); // util Message 기능 사용

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    showPassword = true;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'images/logo.png',
                    width: 100,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'On & Tap',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '이메일',
                        style: TextStyle(
                          fontWeight: FontWeight.bold
                        ),
                      )
                    ),
                  ),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(
                        Icons.email,
                        color: Colors.grey,
                      ),
                      hintText: 'email@example.com',
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[200]
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '비밀번호',
                        style: TextStyle(
                          fontWeight: FontWeight.bold
                        ),
                      )
                    ),
                  ),
                  TextField(
                    controller: passwordController,
                    obscureText: showPassword,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(
                        Icons.lock,
                        color: Colors.grey,
                      ),
                      hintText: 'password',
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[200],
                      suffixIcon: IconButton(
                        icon: Icon(
                          showPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          showPassword = !showPassword;
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  // Align(
                  //   alignment: Alignment.centerRight,
                  //   child: TextButton(
                  //     onPressed: () => Get.to(FindIdPassword()),
                  //     child: Text(
                  //       '아이디 / 비밀번호 찾기',
                  //       style: TextStyle(
                  //           color: Colors.grey,
                  //           fontWeight: FontWeight.bold,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  Padding(
                    // 위 TextButton 활성화 시 (0, 10, 0, 30)로 변경
                    padding: const EdgeInsets.fromLTRB(0, 40, 0, 30),
                    child: ElevatedButton(
                      onPressed: () => checkLogin(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(16)
                        ),
                        minimumSize: Size(MediaQuery.widthOf(context), 55),
                      ),
                      child: Text(
                        '로그인',
                        style: TextStyle(
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color: Colors.grey[300]
                        )
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          '처음이신가요?',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color: Colors.grey[300]
                        )
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => Get.to(SignUp()),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '회원가입하기',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_outlined,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      ),
    );
  } // build

  // --- Functios ---
  void checkLogin(){
    if(emailController.text.trim().isEmpty){
      // 이메일이 비어있을 경우 -> SnackBar 처리
      message.errorSnackBar('Error', '이메일을 입력하세요.');
    }else if(passwordController.text.trim().isEmpty){
      // 비밀번호가 비어있을 경우 -> SnackBar 처리
      message.errorSnackBar('Error', '비밀번호를 입력하세요.');
    }else{
      customerLogin();
    } 
  }

  Future<void> customerLogin() async{
    var url = Uri.parse("${GlobalData.url}/customer/login");
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({ // 백엔드 서버로 로그인 데이터 전송
        'email': emailController.text.trim(),
        'password': passwordController.text.trim(),
      }),
    );

    var jsonData = json.decode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) {
      GlobalData.customerId = jsonData['id'];
      // 로그인 성공 -> MainPage 이동
      Get.to(MainPage());
    } else {
      // 로그인 실패 -> errorSnackBar 출력
      message.errorSnackBar('Error', jsonData['detail']);
    }
  }

} // class