import 'dart:convert';
import 'package:flutter/material.dart';
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

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _user == null 
        ? const Center(child: CircularProgressIndicator(color: Colors.black))
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildUserInfo(context),
                const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                _buildMenuItem(context, '주문 내역', Icons.shopping_bag_outlined, const OrderHistory()),
                _buildMenuItem(context, '위시리스트', Icons.favorite_border, const WishList()),
                _buildMenuItem(context, '구매내역', Icons.receipt_long, const OrderHistory()),
                const Spacer(),
              ],
            ),
          ),
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    return InkWell(
      onTap: () => _navigateTo(context, const ProfileEdit()),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_user!.customer_name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(_user!.customer_email, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon, Widget targetPage) {
    return InkWell(
      onTap: () => _navigateTo(context, targetPage),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18.0),
        child: Row(
          children: [
            Icon(icon, size: 28, color: Colors.black),
            const SizedBox(width: 20),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 18))),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}