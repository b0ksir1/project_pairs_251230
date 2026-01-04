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
  // property
  String imageUrl = "${GlobalData.url}/images/view";
  String stockSelectAllUrl =
      "${GlobalData.url}/stock/selectAll";

  List viewData = [];

  @override
  void initState() {
    super.initState();
  }

  // === Property ===
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AdminSideBar(
            selectedMenu: SideMenu.orders,
            onMenuSelected: (menu) {},
          ),
          Expanded(
            child: viewData.isEmpty
                ? Center(child: Text('데이터가 비어있음'))
                : Padding(
                    padding: const EdgeInsets.fromLTRB(
                      30,
                      80,
                      30,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(
                                    0,
                                    0,
                                    5,
                                    0,
                                  ),
                              child: Icon(
                                Icons
                                    .add_shopping_cart_sharp,
                                size: 30,
                              ),
                            ),
                            Text(
                              '구매 내역',
                              style: _adminTitle(),
                            ),
                          ],
                        ),

                        SizedBox(height: 35),
                        _buildHead(),
                        _buildListView(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  } // build

  // ======================= Widget =================================

  // 제품 목차 타이틀
  Widget _buildHead() {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: containerStyle(),

      child: Row(
        children: [
          cell(
            child: Text('NO', style: headerStyle()),
            flex: 1,
            alignment: Alignment.center,
          ),

          cell(
            child: Text('상품명', style: headerStyle()),
            alignment: Alignment.center,
            flex: 3,
          ),

          cell(
            child: Text('상품 갯수', style: headerStyle()),
            alignment: Alignment.center,
            flex: 2,
          ),
          cell(
            child: Text('상품 상태', style: headerStyle()),
            alignment: Alignment.center,
            flex: 2,
          ),
        ],
      ),
    );
  }

  Widget cell({
    required Widget child,
    required int flex,
    Alignment alignment = Alignment.centerLeft,
  }) {
    return Expanded(
      flex: flex,
      child: Align(alignment: alignment, child: child),
    );
  }

  Widget _buildListView() {
    return Expanded(
      child: ListView.builder(
        itemCount: viewData.length,
        itemBuilder: (context, index) {
          final order = viewData[index];

          return Card(
            margin: const EdgeInsets.symmetric(
              vertical: 4,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                0,
                12,
                0,
                12,
              ),
              child: Row(
                children: [
                  // NO
                  cell(
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                    flex: 1,
                  ),

                  // 상품명
                  cell(
                    child: Text(
                      order['name'],
                      style: bodyStyle(),
                    ),
                    flex: 4,
                    alignment: Alignment.center,
                  ),

                  // 수량
                  cell(
                    child: Text(
                      order['qty'].toString(),
                      style: bodyStyle(),
                    ),
                    flex: 2,
                    alignment: Alignment.center,
                  ),

                  // 가격
                  cell(
                    child: Text(
                      '${order['price']}원',
                      style: bodyStyle(),
                    ),
                    flex: 2,
                    alignment: Alignment.center,
                  ),

                  // 상태 (임시)
                  cell(
                    child: const Text(
                      '주문 완료',
                      style: TextStyle(fontSize: 12),
                    ),
                    flex: 2,
                    alignment: Alignment.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  TextStyle headerStyle() {
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
      color: Colors.grey,
    );
  }

  TextStyle bodyStyle() {
    return TextStyle(fontSize: 12, color: Colors.black);
  }

  // === Functions ===

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
      } else {
        debugPrint(
          'orders list error: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('orders list exception: $e');
    }
  }

  // ================ style ===========================
  // 타이틀
  TextStyle _adminTitle() {
    return TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.bold,
    );
  }

  // container
  BoxDecoration containerStyle() {
    return BoxDecoration(
      color: const Color.fromARGB(255, 250, 238, 220),
      border: Border.all(
        color: const Color.fromARGB(255, 177, 203, 214),
      ),
      borderRadius: BorderRadius.circular(6),
    );
  }
} // class
