import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:project_pairs_251230/model/customer.dart';
import 'package:http/http.dart' as http;
import 'package:project_pairs_251230/util/global_data.dart';
import 'package:project_pairs_251230/util/message.dart';

// 클래스 이름을 ProfileEdit로 변경
class ProfileEdit extends StatefulWidget {
  const ProfileEdit({super.key});

  @override
  State<ProfileEdit> createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  // Property
  late String _initialName;
  late String _initialPhone;
  
  String? _email; // 이메일은 변경 불가

  // 컨트롤러 선언
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  Message message = Message();

  Customer? _user; // 서버에서 받아온 정보를 담을 변수
  
  // 서버에서 유저 정보 가져오기
  Future<void> _fetchUserData() async {
    if (GlobalData.customerId == null) return;

    final url = Uri.parse("${GlobalData.url}/customer/select/${GlobalData.customerId}");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        _user = Customer.fromJson(json.decode(utf8.decode(response.bodyBytes)));

        _initialName = _user!.customer_name;
        _initialPhone = _user!.customer_phone;
        _email = _user!.customer_email;

        _nameController = TextEditingController(text: _initialName);
        _phoneController = TextEditingController(text: _initialPhone);
      });
    }else{
      message.errorSnackBar('Error', '서버 오류가 발생했습니다.');
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _fetchUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // 회원 정보 수정
  Future<void> _updateProfile() async{
    if (_email == null) {
      message.errorSnackBar('Error', '유저 정보 로딩 중입니다.');
      return;
    }

    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    if(newPassword.isNotEmpty && newPassword != confirmPassword){ // 비밀번호 유효성 검사
      message.errorSnackBar('Error', '새 비밀번호가 일치하지 않습니다.');
      return;
    }

    try{
      final customer = Customer(
        customer_email: _email!,
        customer_password: _newPasswordController.text.trim(),
        customer_name: _nameController.text.trim(),
        customer_phone: _phoneController.text.trim(),
        customer_address: "N/A"
      );
      final url = Uri.parse("${GlobalData.url}/customer/update/${GlobalData.customerId}");
      final response = await http.post(
        url,
        headers: {'Content-Type' : 'application/json'},
        body: json.encode(customer.toJson()),
      );
      final data = json.decode(utf8.decode(response.bodyBytes));
      final result = data['results'];

      if(result == 'OK'){
        if(_nameController.text.isEmpty){
          message.errorSnackBar('Error', '이름을 입력해 주세요.');
        }else if(_phoneController.text.isEmpty){
          message.errorSnackBar('Error', '전화번호를 입력해 주세요.');
        }else if(newPassword.isEmpty){
          message.errorSnackBar('Error', '새 비밀번호를 입력해 주세요.');
        }else{
        message.showDialog('Success', '회원 정보가 수정되었습니다.');
        }
      } else {
        message.errorSnackBar('Error', '회원 정보 수정에 실패했습니다.');
      }
    } catch(e){
      debugPrint('updateProfile error: $e');
      message.errorSnackBar('Error', '회원 정보 수정에 실패했습니다.');
    }
  }

  // 회원 탈퇴
  Future<void> _withdrawUser() async{
    if (_email == null) {
      message.errorSnackBar('Error', '유저 정보 로딩 중입니다.');
      return;
    }

    try{
    //   final customer = Customer(
    //     customer_email: _email,
    //     customer_password: _newPasswordController.text.trim(),
    //     customer_name: _nameController.text.trim(),
    //     customer_phone: _phoneController.text.trim(),
    //     customer_address: "N/A"
    //   );
      final url = Uri.parse("${GlobalData.url}/customer/delete/${GlobalData.customerId}");
      final response = await http.post(
        url,
        headers: {'Content-Type' : 'application/json'},
        // body: json.encode(customer.toJson()),
        body: json.encode({'customer_email': _email!}),
      );
      final data = json.decode(utf8.decode(response.bodyBytes));
      final result = data['results'];
      
      if(result == 'OK'){
        message.showDialog('Success', '회원 탈퇴가 완료되었습니다.');
      }else{
        message.errorSnackBar('Error', '회원 탈퇴에 실패했습니다.');
      }
    } catch(e){
      debugPrint('withdrawUser error: $e');
      message.errorSnackBar('Error', '회원 탈퇴에 실패했습니다.');
    }
  }

  // 간결해진 공통 입력 필드 위젯
  Widget _buildInputSection({
    required String label,
    required TextEditingController controller,
    String? hintText,
    bool readOnly = false,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!hintText.isNullOrEmpty) 
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),

        Container(
          height: 50,
          decoration: BoxDecoration(
            color: readOnly ? Colors.grey[100] : Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            obscureText: isPassword,
            keyboardType: label == '전화번호' && !readOnly ? TextInputType.phone : TextInputType.text,
            style: TextStyle(color: readOnly ? Colors.grey[700] : Colors.black),
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              hintText: hintText,
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
              border: InputBorder.none,
              // 이메일 필드에만 잠금 아이콘 표시
              suffixIcon: Padding(
                // 텍스트 가운데 정렬을 위해 suffixIcon padding 조절
                padding: const EdgeInsets.only(right: 10),
                child: label == '이메일' && readOnly 
                    ? const Icon(Icons.lock_outline, color: Colors.grey) 
                    : null,
              ),
            ),
          ),
        ),
        // SizedBox(height: hintText.isNullOrEmpty ? 15 : 20),
      ],
    );
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
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: const Column(
            children: [
              Text('On & Tap', style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold)),
              Text('회원 정보 수정', style: TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 이름 필드
              _buildInputSection(
                label: '이름',
                controller: _nameController,
                hintText: '이름을 입력하세요.',
              ),
      
              // 2. 전화번호 필드
              _buildInputSection(
                label: '전화번호',
                controller: _phoneController,
                hintText: '전화번호를 입력하세요.',
              ),
      
              // 3. 이메일 필드 (변경 불가)
              _buildInputSection(
                label: '이메일',
                controller: TextEditingController(text: _email),
                readOnly: true,
                hintText: ' ',
              ),
      
              // 4. 비밀번호 변경 제목
              const Text('비밀번호 변경', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              // const SizedBox(height: 8),
      
              // 5. 새 비밀번호
              _buildInputSection(
                label: '', // 레이블 숨김
                controller: _newPasswordController,
                hintText: '새 비밀번호를 입력하세요.',
                isPassword: true,
              ),
      
              // 6. 새 비밀번호 확인 (위젯 간결화를 위해 SizedBox를 15 -> 0으로 설정 후 직접 간격 조정)
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: _buildInputSection(
                  label: '', // 레이블 숨김
                  controller: _confirmPasswordController,
                  hintText: '새 비밀번호 확인을 입력하세요.',
                  isPassword: true,
                ),
              ),
              
              // 7. 버튼 영역 (정보 저장 및 탈퇴하기)
              Row(
                children: [
                  // 탈퇴하기 버튼
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _withdrawUser,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red, width: 1.5),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('탈퇴하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // 정보 저장 버튼
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: const Text(
                        '정보 저장',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 힌트 텍스트가 비어있는지 확인하는 확장 함수 (간결한 코드 작성을 위함)
extension StringExtension on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
}