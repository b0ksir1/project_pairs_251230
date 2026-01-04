import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:project_pairs_251230/model/customer.dart';
import 'package:project_pairs_251230/util/global_data.dart';
import 'package:project_pairs_251230/view/auth/profile_edit.dart';
import 'package:project_pairs_251230/view/order/order_history.dart';
import 'package:project_pairs_251230/view/order/wish_list.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  Customer? _user; // 서버에서 받아온 정보를 담을 변수

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // 서버에서 유저 정보 가져오기
  Future<void> _fetchUserData() async {
    if (GlobalData.customerId == null) return;

    final url = Uri.parse("${GlobalData.url}/customer/select/${GlobalData.customerId}");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        _user = Customer.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      });
    }
  }

  void _navigateTo(Widget page) {
    Get.to(() => page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // 앱바 추가: 뒤로가기 버튼과 제목이 나타납니다.
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '마이페이지',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: _user == null 
        ? const Center(child: CircularProgressIndicator(color: Colors.black))
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                _buildUserInfo(context),
                const Divider(height: 1, thickness: 1, color: Color(0xFFF5F5F5)),
                _buildMenuItem('주문 내역', Icons.shopping_bag_outlined, const OrderHistory()),
                _buildMenuItem('위시리스트', Icons.favorite_border, const WishList()),
                _buildMenuItem('구매내역', Icons.receipt_long, const OrderHistory()),
                const Spacer(),
              ],
            ),
          ),
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    return InkWell(
      onTap: () => _navigateTo(const ProfileEdit()),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _user!.customer_name, 
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _user!.customer_email, 
                    style: const TextStyle(fontSize: 14, color: Colors.grey)
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

  Widget _buildMenuItem(String title, IconData icon, Widget targetPage) {
    return InkWell(
      onTap: () => _navigateTo(targetPage),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Row(
          children: [
            Icon(icon, size: 26, color: Colors.black),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                title, 
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w400)
              )
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFE0E0E0)),
          ],
        ),
      ),
    );
  }
}