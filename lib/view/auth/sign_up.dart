import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_pairs_251230/model/customer.dart';
import 'package:project_pairs_251230/util/global_data.dart';
import 'package:project_pairs_251230/util/message.dart';
import 'package:project_pairs_251230/view/auth/customer_login.dart';
import 'package:http/http.dart' as http;

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late bool agreeTOS;
  late bool agreePP;
  late bool showPassword;
  late bool showConfirmPassword;
  late bool emailChecked;

  Message message = Message();

  final _formKey = GlobalKey<FormState>();
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$');
  final phoneRegex = RegExp(r'^01[016789]-\d{3,4}-\d{4}$');

  String selectUrl = "${GlobalData.url}/customer/select";
  String insertUrl = "${GlobalData.url}/customer/insert";
  List<Customer> customerList = [];

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

  Future<void> getcustomerData() async {
    var url = Uri.parse(selectUrl);
    var response = await http.get(url);
    customerList.clear();
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataConvertedJSON["results"];
    for (var item in result) {
      Customer customer = Customer(
          customer_email: item['customer_email'],
          customer_password: item['customer_password'],
          customer_name: item['customer_name'],
          customer_phone: item['customer_phone'],
          customer_address: item['customer_address']);
      customerList.add(customer);
    }
    setState(() {});
  }

  Future<bool> insertCustomer() async {
    var url = Uri.parse(insertUrl);
    var response = await http.post(
      url,
      body: {
        'customer_email': emailController.text.trim(),
        'customer_password': passwordController.text.trim(),
        'customer_name': nameController.text.trim(),
        'customer_phone': phoneController.text.trim(),
        'customer_address': "N/A",
      },
    );

    if (response.statusCode == 200) {
      var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
      if (dataConvertedJSON['results'] == 'OK') {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
            onPressed: () => Get.back(),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'On & Tap',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '회원가입',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey),
                  ),
                  const SizedBox(height: 40),
                  _buildLabel('이메일'),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _buildInputDecoration('email@example.com'),
                            validator: (value) {
                              if (value == null || value.isEmpty) return '이메일을 입력해주세요.';
                              if (!emailRegex.hasMatch(value)) return '올바른 이메일 형식이 아닙니다.';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () => checkEmailDuplicate(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            minimumSize: const Size(100, 52),
                          ),
                          child: const Text('중복 확인', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  _buildLabel('비밀번호'),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 20),
                    child: TextFormField(
                      controller: passwordController,
                      obscureText: showPassword,
                      decoration: _buildInputDecoration('비밀번호를 입력해주세요').copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(showPassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey, size: 20),
                          onPressed: () => setState(() => showPassword = !showPassword),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return '비밀번호를 입력해주세요.';
                        if (!passwordRegex.hasMatch(value)) return '8자 이상, 영문/숫자/특수문자 포함';
                        return null;
                      },
                    ),
                  ),
                  _buildLabel('비밀번호 확인'),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 20),
                    child: TextFormField(
                      controller: confirmPasswordController,
                      obscureText: showConfirmPassword,
                      decoration: _buildInputDecoration('비밀번호를 다시 입력해주세요').copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(showConfirmPassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey, size: 20),
                          onPressed: () => setState(() => showConfirmPassword = !showConfirmPassword),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return '비밀번호 확인을 입력해주세요.';
                        if (value != passwordController.text) return '비밀번호가 일치하지 않습니다.';
                        return null;
                      },
                    ),
                  ),
                  _buildLabel('이름'),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 20),
                    child: TextFormField(
                      controller: nameController,
                      decoration: _buildInputDecoration('본인 이름을 입력해주세요'),
                      validator: (value) {
                        if (value == null || value.isEmpty) return '이름을 입력해주세요.';
                        return null;
                      },
                    ),
                  ),
                  _buildLabel('전화번호'),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    child: TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: _buildInputDecoration('010-1234-5678'),
                      validator: (value) {
                        if (value == null || value.isEmpty) return '전화번호를 입력해주세요.';
                        if (!phoneRegex.hasMatch(value)) return '올바른 전화번호 형식이 아닙니다.';
                        return null;
                      },
                    ),
                  ),
                  _buildCheckboxRow(agreeTOS, (val) => setState(() => agreeTOS = val!), '[필수] 서비스 이용약관 동의'),
                  _buildCheckboxRow(agreePP, (val) => setState(() => agreePP = val!), '[필수] 개인정보 처리방침 동의'),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => checkSignup(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    child: const Text('가입하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('이미 계정이 있으신가요?', style: TextStyle(color: Colors.grey, fontSize: 14)),
                      TextButton(
                        onPressed: () => Get.to(CustomerLogin()),
                        child: const Text('로그인', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black));
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      filled: true,
      fillColor: const Color(0xFFF8F8F8),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black, width: 1)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red, width: 1)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red, width: 1)),
    );
  }

  Widget _buildCheckboxRow(bool value, Function(bool?) onChanged, String label) {
    return Row(
      children: [
        SizedBox(
          height: 32,
          width: 32,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            side: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Color(0xFF424242), fontSize: 14)),
      ],
    );
  }

  Future<void> checkSignup() async {
    if (_formKey.currentState!.validate()) {
      if (emailChecked != true) {
        message.errorSnackBar('Error', '이메일 중복 확인을 해주세요.');
      } else if (agreeTOS != true || agreePP != true) {
        message.errorSnackBar('Error', '필수 약관에 동의해주세요.');
      } else {
        bool isSuccess = await insertCustomer();
        if (isSuccess) {
          Get.defaultDialog(
            title: '회원가입 완료',
            titleStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            middleText: 'On & Tap의 회원이 되신 것을 환영합니다.',
            middleTextStyle: const TextStyle(fontSize: 14, color: Colors.grey),
            backgroundColor: Colors.white,
            radius: 20,
            contentPadding: const EdgeInsets.all(24),
            confirm: SizedBox(
              width: 100,
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  emailController.clear();
                  passwordController.clear();
                  confirmPasswordController.clear();
                  nameController.clear();
                  phoneController.clear();
                  agreeTOS = false;
                  agreePP = false;
                  emailChecked = false;
                  Get.to(CustomerLogin());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('확인', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          );
        } else {
          message.errorSnackBar('Error', '회원가입 중 서버 오류가 발생했습니다.');
        }
      }
    }
  }

  void checkEmailDuplicate() async {
    String email = emailController.text.trim();
    if (!emailRegex.hasMatch(email)) {
      return message.errorSnackBar('Error', '올바른 이메일을 입력하세요.');
    }
    await getcustomerData();
    bool isDuplicate = customerList.any((customer) => customer.customer_email.trim() == email);
    if (!isDuplicate) {
      emailChecked = true;
      message.successSnackBar('Success', '$email\n사용 가능한 이메일입니다.');
    } else {
      emailChecked = false;
      message.errorSnackBar('Error', '$email\n이미 사용 중인 이메일입니다.');
    }
    setState(() {});
  }
}