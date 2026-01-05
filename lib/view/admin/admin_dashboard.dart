import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  // property
  final _dataList = [];
  final urlPath = GlobalData.url;
  String imageUrl = "${GlobalData.url}/images/view";
  String stockSelectAllUrl = "${GlobalData.url}/stock/selectAll";
  String monthSalesUrl = "${GlobalData.url}/orders/month";

  late List<Stock> _stockList;
  int monthSales = 0;

  @override
  void initState() {
    super.initState();
    _stockList = [];
    getProductData();
    getJSONData();
    getMonthSales();
  }

  // 금액 comma
  String formatCurrency(int value) {
    final formatter = NumberFormat('#,###');
    return formatter.format(value);
  }

  // ===================== UI =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 241, 250, 253),
      body: Row(
        children: [
          AdminSideBar(
            selectedMenu: SideMenu.dashboard,
            onMenuSelected: (menu) {},
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(30, 80, 30, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dashboard Overview', style: _adminTitle()),
                  Text(
                    "welcome back, here's happening today",
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 20),
                  Container(
                    height: 80,
                    width: double.infinity,
                    decoration: containerStyle(),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: Icon(Icons.attach_money_outlined),
                        ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '매출',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
                              child: Text(
                                '${formatCurrency(monthSales)}원',
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 0, 0, 0),
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 400,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                          child: Text(
                            'Top Selling Shoes',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // ===== 상품 목록 =====
                        _buildHead(),
                        _buildListView(),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== Widgets =====================
  // 테이블 타이틀
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
            child: Text('상품 이미지', style: headerStyle()),
            flex: 2,
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
        itemCount: _stockList.length,
        itemBuilder: (context, index) {
          final stock = _stockList[index];

          return Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
              child: Row(
                children: [
                  cell(
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    flex: 1,
                  ),

                  cell(
                    child: Image.network(
                      '${GlobalData.url}/images/view/${stock.productId}?t=${DateTime.now().millisecondsSinceEpoch}',
                      width: 120,
                      height: 100,
                    ),

                    flex: 2,
                    alignment: Alignment.center,
                  ),
                  cell(
                    child: Text(stock.productName, style: bodyStyle()),
                    flex: 3,
                    alignment: Alignment.center,
                  ),

                  cell(
                    child: Text(
                      stock.productQty.toString(),
                      style: bodyStyle(),
                    ),
                    flex: 2,
                    alignment: Alignment.center,
                  ),
                  cell(
                    child: Text('상품 상태', style: bodyStyle()),
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

  // ===================== Style =====================

  // 타이틀
  TextStyle _adminTitle() {
    return TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  }

  // container
  BoxDecoration containerStyle() {
    return BoxDecoration(
      color: const Color.fromARGB(255, 255, 255, 255),
      border: Border.all(color: const Color.fromARGB(255, 177, 203, 214)),
      borderRadius: BorderRadius.circular(6),
    );
  }

  TextStyle headerStyle() {
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
      color: const Color(0xFF222222),
    );
  }

  TextStyle bodyStyle() {
    return TextStyle(fontSize: 16, color: Colors.black);
  }

  // ===================== API =====================
  Future getJSONData() async {
    var url = Uri.parse('$urlPath/product/select');
    var response = await http.get(url);
    print(response.body);
    if (response.statusCode == 200) {
      _dataList.clear();
      var dataConvertedData = json.decode(utf8.decode(response.bodyBytes));
      List results = dataConvertedData['results'];
      _dataList.addAll(results);
      setState(() {});
    } else {
      print("error : ${response.statusCode}");
    }
  }

  Future<void> getMonthSales() async {
    final url = Uri.parse(monthSalesUrl);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decoded = json.decode(utf8.decode(response.bodyBytes)) as Map;
      monthSales = decoded['month_sales'] ?? 0;

      setState(() {});
    } else {
      debugPrint('month sales error: ${response.statusCode}');
    }
  }

  Future<void> getProductData() async {
    final url = Uri.parse(stockSelectAllUrl);
    final response = await http.get(url);
    // 월 판매 금액

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

  Future<void> getOrders() async {
    final url = Uri.parse('$urlPath/orders/select');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = json.decode(utf8.decode(response.bodyBytes));
      final List results = decoded['result'];

      for (var item in results) {
        print(item['orders_id']);
        print(item['orders_quantity']);
        print(item['orders_status']);
      }
    }
  }
}
