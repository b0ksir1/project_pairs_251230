import 'package:flutter/material.dart';

// 클래스 이름을 ProfileEdit로 변경
class ProfileEdit extends StatefulWidget {
  const ProfileEdit({super.key});

  @override
  State<ProfileEdit> createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  // DB에서 GET으로 가져온다고 가정한 초기 데이터
  final String _initialName = '김철수';
  final String _initialPhoneNumber = '010-1234-5678';
  final String _email = 'chulsoo.kim@example.com'; // 이메일은 변경 불가

  // 컨트롤러 선언
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _initialName);
    _phoneController = TextEditingController(text: _initialPhoneNumber);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // 데이터 저장 더미 함수 (DB로 변경된 데이터 PUT/POST 전송)
  void _saveUserInfo() {
    final newPassword = _newPasswordController.text;
    
    // 비밀번호 유효성 검사 (테스트를 위해)
    if (newPassword.isNotEmpty && newPassword != _confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('새 비밀번호가 일치하지 않습니다.')),
      );
      return;
    }

    // [함수 비워둠] 실제 DB 업데이트 API 호출 (변경된 DB가 넘어가는 부분)
    debugPrint('DB 전송 데이터: 이름=${_nameController.text}, 전화번호=${_phoneController.text}, 비밀번호=${newPassword.isNotEmpty ? '변경됨' : '유지'}');
    
    // 성공 피드백
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('회원 정보가 저장되었습니다.')),
    );
  }

  // 회원 탈퇴 더미 함수
  void _withdrawUser() {
    // [함수 비워둠] 실제 회원 탈퇴 로직 (DELETE API 호출 등)
    debugPrint('회원 탈퇴 처리 시도');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('회원 탈퇴가 처리되었습니다.')),
    );
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
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        if (!hintText.isNullOrEmpty) const SizedBox(height: 8),

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
        SizedBox(height: hintText.isNullOrEmpty ? 15 : 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            ),

            // 2. 전화번호 필드
            _buildInputSection(
              label: '전화번호',
              controller: _phoneController,
            ),

            // 3. 이메일 필드 (변경 불가)
            _buildInputSection(
              label: '이메일',
              controller: TextEditingController(text: _email),
              readOnly: true,
            ),

            // 4. 비밀번호 변경 제목
            const Text('비밀번호 변경', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // 5. 새 비밀번호
            _buildInputSection(
              label: '', // 레이블 숨김
              controller: _newPasswordController,
              hintText: '새 비밀번호',
              isPassword: true,
            ),

            // 6. 새 비밀번호 확인 (위젯 간결화를 위해 SizedBox를 15 -> 0으로 설정 후 직접 간격 조정)
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: _buildInputSection(
                label: '', // 레이블 숨김
                controller: _confirmPasswordController,
                hintText: '새 비밀번호 확인',
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
                    onPressed: _saveUserInfo,
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
    );
  }
}

// 힌트 텍스트가 비어있는지 확인하는 확장 함수 (간결한 코드 작성을 위함)
extension StringExtension on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
}