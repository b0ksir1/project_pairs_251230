import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_pairs_251230/util/message.dart';
import 'package:project_pairs_251230/view/auth/customer_login.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  // Property
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController passwordCheckController;
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late bool agreeTOS; // 서비스 이용약관 동의 체크박스
  late bool agreePP; // 개인정보 처리방침 동의 체크박스

  Message message = Message();

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    passwordCheckController = TextEditingController();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    agreeTOS = false;
    agreePP = false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'On & Tap',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                  child: Text(
                    '회원가입',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                Text(
                  '이메일',
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder( // 기본 상태 테두리
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey)
                      ),
                      focusedBorder: OutlineInputBorder( // 포커스 상태 테두리
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey, width: 2),
                      ),
                      hintText: 'email@example.com',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                Text(
                  '비밀번호',
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
                  child: TextField( // ** 비밀번호 보이기 기능 추가 **
                    controller: passwordController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder( // 기본 상태 테두리
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey)
                      ),
                      focusedBorder: OutlineInputBorder( // 포커스 상태 테두리
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey, width: 2),
                      ),
                      hintText: '비밀번호를 입력해주세요',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    obscureText: true,
                  ),
                ),
                Text(
                  '비밀번호 확인',
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
                  child: TextField( // ** 비밀번호 보이기 기능 추가 **
                    controller: passwordCheckController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder( // 기본 상태 테두리
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey)
                      ),
                      focusedBorder: OutlineInputBorder( // 포커스 상태 테두리
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey, width: 2),
                      ),
                      hintText: '비밀번호를 다시 입력해주세요',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    obscureText: true,
                  ),
                ),
                Text(
                  '이름',
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder( // 기본 상태 테두리
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey)
                      ),
                      focusedBorder: OutlineInputBorder( // 포커스 상태 테두리
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey, width: 2),
                      ),
                      hintText: '본인 이름을 입력해주세요',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                Text(
                  '전화번호',
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
                  child: TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder( // 기본 상태 테두리
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey)
                      ),
                      focusedBorder: OutlineInputBorder( // 포커스 상태 테두리
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey, width: 2),
                      ),
                      hintText: '010-1234-5678',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Checkbox(
                      value: agreeTOS,
                      onChanged: (value) {
                        agreeTOS = value!;
                        setState(() {});
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(5)
                      ),
                      visualDensity: VisualDensity( // Checkbox 기본 여백 줄임
                        horizontal: -4.0,
                        vertical: -4.0
                      ),
                    ),
                    Text(
                      '[필수] 서비스 이용약관 동의',
                      style: TextStyle(
                        color: Color.fromRGBO(0, 0, 0, .7),
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: agreePP,
                      onChanged: (value) {
                        agreePP = value!;
                        setState(() {});
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(5)
                      ),
                      visualDensity: VisualDensity( // Checkbox 기본 여백 줄임
                        horizontal: -4.0,
                        vertical: -4.0
                      ),
                    ),
                    Text(
                      '[필수] 개인정보 처리방침 동의',
                      style: TextStyle(
                        color: Color.fromRGBO(0, 0, 0, .7),
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 30, 0, 10),
                  child: ElevatedButton(
                    onPressed: () => checkSignup(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(16)
                      ),
                      minimumSize: Size(MediaQuery.widthOf(context), 55),
                    ),
                    child: Text(
                      '가입하기',
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '이미 계정이 있으신가요?',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.to(CustomerLogin()),
                      child: Text(
                        '로그인',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  } // build

  // --- Functios ---
  void checkSignup(){
    if(emailController.text.trim().isEmpty){
      // 이메일이 비어있을 경우
      message.errorSnackBar('Error', '이메일을 입력하세요.');
    }else if(passwordController.text.trim().isEmpty){
      // 비밀번호가 비어있을 경우
      message.errorSnackBar('Error', '비밀번호를 입력하세요.');
    }else if(passwordCheckController.text.trim().isEmpty){
      // 비밀번호 확인이 비어있을 경우
      message.errorSnackBar('Error', '비밀번호 확인을 입력하세요.');
    }else if(nameController.text.trim().isEmpty){
      // 이름이 비어있을 경우
      message.errorSnackBar('Error', '이름을 입력하세요.');
    }else if(phoneController.text.trim().isEmpty){
      // 전화번호가 비어있을 경우
      message.errorSnackBar('Error', '전화번호를 입력하세요.');
    }else if(agreeTOS == false || agreePP == false){
      // 약관을 체크하지 않았을 경우
      message.errorSnackBar('Error', '필수 약관이 미동의 되었습니다.');
    }else if(passwordController.text.trim() != passwordCheckController.text.trim()){
      // 비밀번호가 일치하지 않을 경우
      message.errorSnackBar('Error', '비밀번호가 일치하지 않습니다.');
    }else{
      // 회원가입 성공 -> 입력된 내용 지우고 로그인 페이지로 이동
      emailController.clear();
      passwordController.clear();
      passwordCheckController.clear();
      nameController.clear();
      phoneController.clear();
      agreeTOS = false;
      agreePP = false;
      Get.to(CustomerLogin());
    }
  }

} // class