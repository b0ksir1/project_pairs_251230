import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:project_pairs_251230/util/global_data.dart';
import 'package:project_pairs_251230/view/admin/admin_side_bar.dart';
import 'package:project_pairs_251230/util/side_menu.dart';
import 'package:http/http.dart' as http;

class AdminPurchaseManage extends StatefulWidget {
  const AdminPurchaseManage({super.key});
  @override
  State<AdminPurchaseManage> createState() =>
      _AdminPurchaseManageState();
}

class _AdminPurchaseManageState
    extends State<AdminPurchaseManage> {
  String imageUrl = "${GlobalData.url}/images/view";
  String stockSelectAllUrl =
      "${GlobalData.url}/stock/selectAll";
  List viewData = [];
  @override
  void initState() {
    super.initState();
    getOrderList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          AdminSideBar(
            selectedMenu: SideMenu.orders,
            onMenuSelected: (menu) {},
          ),
          Expanded(
            child: Container(
              color: const Color(0xFFF9F9F9),
              padding: const EdgeInsets.fromLTRB(
                40,
                60,
                40,
                0,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.receipt_long_rounded,
                        size: 32,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '구매 내역 관리',
                        style: _adminTitle(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  _buildHead(),
                  const SizedBox(height: 10),
                  Expanded(
                    child: viewData.isEmpty
                        ? const Center(
                            child:
                                CircularProgressIndicator(
                                  color: Colors.black,
                                ),
                          )
                        : _buildListView(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHead() {
    return Container(
      width: double.infinity,
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          cell(
            child: Text('NO', style: headerStyle()),
            flex: 1,
          ),
          cell(
            child: Text('상품명', style: headerStyle()),
            flex: 4,
          ),
          cell(
            child: Text('수량', style: headerStyle()),
            flex: 2,
          ),
          cell(
            child: Text('결제금액', style: headerStyle()),
            flex: 2,
          ),
          cell(
            child: Text('상태', style: headerStyle()),
            flex: 2,
          ),
        ],
      ),
    );
  }

  Widget cell({
    required Widget child,
    required int flex,
    Alignment alignment = Alignment.center,
  }) {
    return Expanded(
      flex: flex,
      child: Align(alignment: alignment, child: child),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 40),
      itemCount: viewData.length,
      itemBuilder: (context, index) {
        final order = viewData[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          height: 60,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFFEEEEEE),
            ),
          ),
          child: Row(
            children: [
              cell(
                child: Text(
                  '${index + 1}',
                  style: bodyStyle(),
                ),
                flex: 1,
              ),
              cell(
                child: Text(
                  order['name'],
                  style: bodyStyle().copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                flex: 4,
                alignment: Alignment.centerLeft,
              ),
              cell(
                child: Text(
                  '${order['qty']}개',
                  style: bodyStyle(),
                ),
                flex: 2,
              ),
              cell(
                child: Text(
                  '${order['price']}원',
                  style: bodyStyle(),
                ),
                flex: 2,
              ),
              cell(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(
                      4,
                    ),
                  ),
                  child: const Text(
                    '주문 완료',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                flex: 2,
              ),
            ],
          ),
        );
      },
    );
  }

  TextStyle headerStyle() {
    return const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 13,
      color: Colors.white,
    );
  }

  TextStyle bodyStyle() {
    return const TextStyle(
      fontSize: 13,
      color: Colors.black87,
    );
  }

  Future<void> getOrderList() async {
    final url = Uri.parse(
      '${GlobalData.url}/orders/select/summary',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decoded = json.decode(
          utf8.decode(response.bodyBytes),
        );
        final List results = decoded['results'];
        viewData = results
            .map(
              (o) => {
                'id': o['orders_id'],
                'name': o['product_name'],
                'qty': o['orders_quantity'],
                'price': o['orders_totalprice'],
              },
            )
            .toList();
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  TextStyle _adminTitle() {
    return const TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
    );
  }
}
