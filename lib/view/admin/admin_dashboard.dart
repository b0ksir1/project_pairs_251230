import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:project_pairs_251230/model/stock.dart';
import 'package:project_pairs_251230/util/global_data.dart';
import 'package:project_pairs_251230/view/admin/admin_side_bar.dart';
import 'package:project_pairs_251230/util/side_menu.dart';
import 'package:http/http.dart' as http;

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String imageUrl = "${GlobalData.url}/images/view";
  String stockSelectAllUrl = "${GlobalData.url}/stock/selectAll";

  late List<Stock> _stockList;

  @override
  void initState() {
    super.initState();
    _stockList = [];
    getProductData();
  }

  // ===================== UI =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AdminSideBar(
            selectedMenu: SideMenu.dashboard,
            onMenuSelected: (menu) {},
          ),
          Expanded(
            child: _stockList.isEmpty
                ? const Center(child: Text('데이터가 비어있음'))
                : Column(
                    children: [
                      // ===== Dashboard =====
                      const Text('Dashboard Overview'),
                      const Text('dashboard overview'),
                      const Text('welcome back, here`s happening today'),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 100,
                        child: Row(
                          children: const [
                            Icon(Icons.attach_money_outlined),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [Text('매출'), Text('금액 나오는 곳')],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 400,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Top Selling Shoes'),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'images/dog1.png',
                                        width: 80,
                                        height: 80,
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: const [
                                          Text('제품 이름'),
                                          Text('제품 색상'),
                                          Text('제품 브랜드'),
                                        ],
                                      ),
                                      const SizedBox(width: 20),
                                      const Text('제품 판매 수'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ===== 상품 목록 =====
                      _buildHead(),
                      _buildListView(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ===================== Widgets =====================

  Widget _buildHead() {
    return Row(
      children: [
        const SizedBox(width: 15),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.15,
          child: Text('상품명', style: headerStyle()),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          child: Text('상품 이미지', style: headerStyle()),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.1,
          child: Text('상품 갯수', style: headerStyle()),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.1,
          child: Text('상품 상태', style: headerStyle()),
        ),
      ],
    );
  }

  Widget _buildListView() {
    return Expanded(
      child: ListView.builder(
        itemCount: _stockList.length,
        itemBuilder: (context, index) {
          final stock = _stockList[index];

          return Card(
            child: Row(
              children: [
                const SizedBox(width: 15),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.15,
                  child: Text(stock.productName, style: bodyStyle()),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: Image.network(
                    '${GlobalData.url}/images/view/${stock.productId}?t=${DateTime.now().millisecondsSinceEpoch}',
                    width: 100,
                    height: 100,
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.1,
                  child: Text(stock.productQty.toString(), style: bodyStyle()),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.1,
                  child: Text('상품 상태', style: bodyStyle()),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ===================== Style =====================

  TextStyle headerStyle() {
    return const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
      color: Colors.grey,
    );
  }

  TextStyle bodyStyle() {
    return const TextStyle(fontSize: 12, color: Colors.black);
  }

  // ===================== API =====================

  Future<void> getProductData() async {
    final url = Uri.parse(stockSelectAllUrl);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      _stockList.clear();

      final decoded = json.decode(utf8.decode(response.bodyBytes)) as Map;
      final List results = decoded['results'];

      for (var item in results) {
        _stockList.add(
          Stock(
            stockId: item["s.stock_id"],
            productId: item["s.stock_product_id"],
            productName: item["p.product_name"],
            productQty: item["s.stock_quantity"],
          ),
        );
      }

      setState(() {});
    } else {
      debugPrint("error : ${response.statusCode}");
    }
  }
}
