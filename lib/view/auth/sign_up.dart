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
  late TextEditingController confirmPasswordController;
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late bool agreeTOS; // 서비스 이용약관 동의 체크박스
  late bool agreePP; // 개인정보 처리방침 동의 체크박스
  late bool showPassword; // 비밀번호 숨김 on/off 토글
  late bool showConfirmPassword; // 비밀번호 숨김 on/off 토글
  late bool emailChecked; // 이메일 중복 확인했는지 체크

  Message message = Message();

  // Form 안의 모든 TextFormField 검증
  final _formKey = GlobalKey<FormState>();
  // 이메일 정규식
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  // 비밀번호 정규식: 최소 8자, 영문 + 숫자 + 특수문자 포함
  final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$');
  // 전화번호 정규식 
  final phoneRegex = RegExp(r'^01[016789]-\d{3,4}-\d{4}$');

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    agreeTOS = false;
    agreePP = false;
    showPassword = true;
    showConfirmPassword = true;
    emailChecked = false;
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
            child: Form(
              key: _formKey,
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 250,
                          child: TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'email@example.com',
                              hintStyle: TextStyle(color: Colors.grey),
                              enabledBorder: OutlineInputBorder( // 기본 상태 테두리
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.grey)
                              ),
                              focusedBorder: OutlineInputBorder( // 포커스 상태 테두리
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.grey, width: 2),
                              ),
                            ),
                            validator: (value){
                              if(value == null || value.isEmpty){
                                return '이메일을 입력해주세요.';
                              }else if(!emailRegex.hasMatch(value)){
                                return '올바른 이메일 형식이 아닙니다.';
                              }else{
                                return null; // 검증 통과
                              }
                            },
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => checkEmailDuplicate(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(16)
                            ),
                            minimumSize: Size(40, 55),
                          ),
                          child: Text(
                            '중복 확인',
                            style: TextStyle(
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ],
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
                    child: TextFormField(
                      controller: passwordController,
                      obscureText: showPassword,
                      decoration: InputDecoration(
                        hintText: '비밀번호를 입력해주세요',
                        hintStyle: TextStyle(color: Colors.grey),
                        enabledBorder: OutlineInputBorder( // 기본 상태 테두리
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey)
                        ),
                        focusedBorder: OutlineInputBorder( // 포커스 상태 테두리
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey, width: 2),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            showPassword ? Icons.visibility_off : Icons.visibility
                          ),
                          onPressed: () {
                            showPassword = !showPassword;
                            setState(() {});
                          },
                        ),
                      ),
                      validator: (value){
                        if(value == null || value.isEmpty){
                          return '비밀번호를 입력해주세요.';
                        }else if(!passwordRegex.hasMatch(value)){
                          return '8자 이상, 영문/숫자/특수문자 포함';
                        }else{
                          return null; // 검증 통과
                        }
                      },
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
                    child: TextFormField(
                      controller: confirmPasswordController,
                      obscureText: showConfirmPassword,
                      decoration: InputDecoration(
                        hintText: '비밀번호를 다시 입력해주세요',
                        hintStyle: TextStyle(color: Colors.grey),
                        enabledBorder: OutlineInputBorder( // 기본 상태 테두리
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey)
                        ),
                        focusedBorder: OutlineInputBorder( // 포커스 상태 테두리
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey, width: 2),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            showConfirmPassword ? Icons.visibility_off : Icons.visibility
                          ),
                          onPressed: () {
                            showConfirmPassword = !showConfirmPassword;
                            setState(() {});
                          },
                        ),
                      ),
                      validator: (value){
                        if(value == null || value.isEmpty){
                          return '비밀번호 확인을 입력해주세요.';
                        }else if(value != passwordController.text){
                          return '비밀번호가 일치하지 않습니다.';
                        }else{
                          return null; // 검증 통과
                        }
                      },
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
                    child: TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: '본인 이름을 입력해주세요',
                        hintStyle: TextStyle(color: Colors.grey),
                        enabledBorder: OutlineInputBorder( // 기본 상태 테두리
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey)
                        ),
                        focusedBorder: OutlineInputBorder( // 포커스 상태 테두리
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey, width: 2),
                        ),
                      ),
                      validator: (value){
                        if(value == null || value.isEmpty){
                          return '이름을 입력해주세요.';
                        }else{
                          return null; // 검증 통과
                        }
                      },
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
                    child: TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: '010-1234-5678',
                        hintStyle: TextStyle(color: Colors.grey),
                        enabledBorder: OutlineInputBorder( // 기본 상태 테두리
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey)
                        ),
                        focusedBorder: OutlineInputBorder( // 포커스 상태 테두리
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey, width: 2),
                        ),
                      ),
                      validator: (value){
                        if(value == null || value.isEmpty){
                          return '전화번호를 입력해주세요.';
                        }else if(!phoneRegex.hasMatch(value)){
                          return '올바른 전화번호 형식이 아닙니다.';
                        }else{
                          return null; // 검증 통과
                        }
                      },
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
      ),
    );
  } // build

  // --- Functios ---
  void checkSignup(){
    // Form 안의 TextFormField validator 전체 검사
    if(_formKey.currentState!.validate()){
      if(emailChecked != true){
        // 이메일 중복 체크하지 않았을 경우
        message.errorSnackBar('Error', '이메일 중복 확인을 해주세요.');
      }else if(agreeTOS != true || agreePP != true){
        // 약관을 체크하지 않았을 경우
        message.errorSnackBar('Error', '필수 약관에 동의해주세요.');
      }else{
        // 모든 조건 통과 -> 회원가입 성공
        Get.defaultDialog(
          title: 'Success',
          middleText:'회원가입 완료! 🎉',
          actions: [
            TextButton(
              onPressed: () {
                // Dialog 닫기
                Get.back();

                // 입력된 내용 초기화
                emailController.clear();
                passwordController.clear();
                confirmPasswordController.clear();
                nameController.clear();
                phoneController.clear();
                agreeTOS = false;
                agreePP = false;

                // 페이지 이동
                Get.to(CustomerLogin());
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: Text('확인'),
            ),
          ],
        );
      }
    }
  }

  // 이메일 중복 체크
  void checkEmailDuplicate() async{
    String email = emailController.text.trim();

    if(!emailRegex.hasMatch(email)){
      // 중복 체크 -> 잘못된 이메일
      return message.errorSnackBar('Error', '올바른 이메일을 입력하세요.');
    }

    // *** 수정 ***
    // 서버 API 호출(임시)
    await Future.delayed(Duration(seconds: 1));
    bool emailAvailable = email != "test@example.com";

    if(emailAvailable){
      // 중복 체크 -> 사용 가능
      emailChecked = true;
      message.successSnackBar('Success', '$email\n사용 가능한 이메일입니다.');
      setState(() {}); // 버튼 활성화 상태 갱신
    }else {
      // 중복 체크 -> 사용 불가
      emailChecked = false;
      message.errorSnackBar('Error', '$email\n이미 사용 중인 이메일입니다.');
    }
  }

} // class