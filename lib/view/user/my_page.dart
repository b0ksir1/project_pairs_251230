import 'package:flutter/material.dart';
import 'package:project_pairs_251230/view/auth/profile_edit.dart';
import 'package:project_pairs_251230/view/order/order_history.dart';
import 'package:project_pairs_251230/view/order/wish_list.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  // DB에서 GET으로 가져온다고 가정한 회원 정보
  final String userName = '김철수';
  final String userEmail = 'chulsoo.kim@example.com';

  // 목록 항목 구조를 간결하게 정의
  final List<Map<String, dynamic>> menuItems = const [
    {'title': '주문 내역', 'icon': Icons.shopping_bag_outlined, 'page': OrderHistory()},
    {'title': '위시리스트', 'icon': Icons.favorite_border, 'page': WishList()},
    {'title': '구매내역', 'icon': Icons.receipt_long, 'page': OrderHistory()}, // 예시로 구매내역도 OrderHistory로 연결
  ];

  // 네비게이션 함수 (GET 요청 시뮬레이션)
  void _navigateTo(BuildContext context, Widget page) {
    // 실제로는 GET 요청 후 데이터를 받아 이동해야 하지만, 여기서는 화면 이동만 시뮬레이션합니다.
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  // 메뉴 항목을 빌드하는 위젯 함수
  Widget _buildMenuItem(BuildContext context, String title, IconData icon, Widget targetPage) {
    return InkWell(
      onTap: () => _navigateTo(context, targetPage),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18.0),
        child: Row(
          children: [
            Icon(icon, size: 28, color: Colors.black),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // 회원 정보 영역 위젯
  Widget _buildUserInfo(BuildContext context) {
    return InkWell(
      onTap: () => _navigateTo(context, const ProfileEdit()), // 회원 정보 수정 페이지로 이동
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userEmail,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // 하단 네비게이션 바 위젯
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(fontSize: 10),
      currentIndex: 3, // 마이페이지 (4번째 항목) 활성화
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
        BottomNavigationBarItem(icon: Icon(Icons.folder_open), label: '카테고리'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: '검색'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: '장바구니'),
      ],
      onTap: (index) {
        // 실제 앱에서는 화면 전환 로직이 들어갑니다.
        debugPrint('Bottom Nav item clicked: $index');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '마이페이지',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Colors.white,
      
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            // 회원 이름 및 이메일, 정보 수정 버튼 영역
            _buildUserInfo(context),
            
            const Divider(height: 1, thickness: 1, color: Colors.grey),

            // 메뉴 목록
            ...menuItems.map((item) {
              return _buildMenuItem(
                context,
                item['title'] as String,
                item['icon'] as IconData,
                item['page'] as Widget,
              );
            }).toList(),
            
            // 나머지 여백
            const Spacer(),
          ],
        ),
      ),
      
      // 하단 네비게이션 바
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }
}