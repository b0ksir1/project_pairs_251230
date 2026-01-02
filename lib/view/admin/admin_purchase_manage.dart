import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:project_pairs_251230/model/stock.dart';
import 'package:project_pairs_251230/util/global_data.dart';
import 'package:project_pairs_251230/view/admin/admin_side_bar.dart';
import 'package:project_pairs_251230/util/side_menu.dart';
import 'package:http/http.dart' as http;

class AdminPurchaseManage extends StatefulWidget {
  const AdminPurchaseManage({super.key});

  @override
  State<AdminPurchaseManage> createState() => _AdminPurchaseManageState();
}

class _AdminPurchaseManageState extends State<AdminPurchaseManage> {
  // property
  // 구매 내역 페이지

  // final List<PurchaseOrder> data = [
  //   PurchaseOrder(
  //     po: '#PO-8821',
  //     date: 'Oct 25, 2023',
  //     supplier: 'Kicks Wholesale Inc.',
  //     product: 'Nike Air Max Red',
  //     qtyInfo: 'Qty: 50 · Unit: \$90.00',
  //     totalCost: 4500,
  //     status: 'Received',
  //   ),
  //   PurchaseOrder(
  //     po: '#PO-8820',
  //     date: 'Oct 24, 2023',
  //     supplier: 'Adidas Global Dist.',
  //     product: 'Jordan High Tops',
  //     qtyInfo: 'Qty: 20 · Unit: \$140.00',
  //     totalCost: 4450,
  //     status: 'Shipped',
  //   ),
  // ];

  // 상태 뱃지 위젯
  Widget statusBadge(String status) {
    Color bg;
    Color text;

    switch (status) {
      case 'Received':
        bg = Colors.green.shade100;
        text = Colors.green;
        break;
      case 'Shipped':
        bg = Colors.blue.shade100;
        text = Colors.blue;
        break;
      case 'Pending':
        bg = Colors.orange.shade100;
        text = Colors.orange;
        break;
      case 'Cancelled':
        bg = Colors.grey.shade300;
        text = Colors.grey.shade700;
        break;
      default:
        bg = Colors.grey.shade200;
        text = Colors.black;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: text,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String imageUrl = "${GlobalData.url}/images/view";
  String stockSelectAllUrl = "${GlobalData.url}/stock/selectAll";

  late List<Stock> _stockList;

  @override
  void initState() {
    super.initState();
    _stockList = [];

    getProductData();
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
            child: _stockList.isEmpty
                ? Center(child: Text('데이터가 비어있음'))
                : Column(
                    children: [
                      Text('Dashboard Overview'),
                      _buildHead(),
                      _buildListView(),
                    ],
                  ),
          ),
        ],
      ),
    );
  } // build

  // === Widget ===

  Widget _buildListView() {
    return Expanded(
      child: ListView.builder(
        itemCount: _stockList.length,
        itemBuilder: (context, index) {
          return Card(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 15),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.15,
                  child: Text(
                    _stockList[index].productName,
                    style: bodyStyle(),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: Image.network(
                    '${GlobalData.url}/images/view/${_stockList[index].productId}?t=${DateTime.now().millisecondsSinceEpoch}',
                    width: 100,
                    height: 100,
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.1,
                  child: Text(
                    _stockList[index].productQty.toString(),
                    style: bodyStyle(),
                  ),
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

  Widget _buildHead() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(width: 15),
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

  // 테이블
  // 테이블 헤더
  Widget tableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: const [
          SizedBox(width: 40),
          Expanded(flex: 2, child: Text('PURCHASE INFO')),
          Expanded(flex: 2, child: Text('SUPPLIER')),
          Expanded(flex: 3, child: Text('PRODUCT')),
          Expanded(flex: 2, child: Text('TOTAL COST')),
          Expanded(flex: 2, child: Text('STATUS')),
          Expanded(flex: 1, child: Text('ACTIONS')),
        ],
      ),
    );
  }

  // 테이블 한 줄
  // Widget tableRow(PurchaseOrder item) {
  //   // 데이터 불러올때 수정
  //   return Container(
  //     padding: const EdgeInsets.symmetric(
  //       vertical: 16,
  //       horizontal: 12,
  //     ),
  //     decoration: BoxDecoration(
  //       border: Border(
  //         bottom: BorderSide(color: Colors.grey.shade200),
  //       ),
  //     ),
  //     child: Row(
  //       children: [
  //         const SizedBox(
  //           width: 40,
  //           child: Checkbox(
  //             value: false,
  //             onChanged: null,
  //           ),
  //         ),

  //         /// PURCHASE INFO
  //         Expanded(
  //           flex: 2,
  //           child: Column(
  //             crossAxisAlignment:
  //                 CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 item.po,
  //                 style: const TextStyle(
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //               Text(
  //                 item.date,
  //                 style: const TextStyle(
  //                   fontSize: 12,
  //                   color: Colors.grey,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),

  //         /// SUPPLIER
  //         Expanded(flex: 2, child: Text(item.supplier)),

  //         /// PRODUCT
  //         Expanded(
  //           flex: 3,
  //           child: Column(
  //             crossAxisAlignment:
  //                 CrossAxisAlignment.start,
  //             children: [
  //               Text(item.product),
  //               Text(
  //                 item.qtyInfo,
  //                 style: const TextStyle(
  //                   fontSize: 12,
  //                   color: Colors.grey,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),

  //         /// TOTAL COST
  //         Expanded(
  //           flex: 2,
  //           child: Column(
  //             crossAxisAlignment:
  //                 CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 '\$${item.totalCost.toStringAsFixed(2)}',
  //                 style: const TextStyle(
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //               const Text(
  //                 'Net 30',
  //                 style: TextStyle(
  //                   fontSize: 12,
  //                   color: Colors.grey,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),

  //         /// STATUS
  //         Expanded(
  //           flex: 2,
  //           child: statusBadge(item.status),
  //         ),

  //         /// ACTIONS
  //         const Expanded(
  //           flex: 1,
  //           child: Icon(Icons.more_horiz),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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

  Future getProductData() async {
    var url = Uri.parse(stockSelectAllUrl);
    var response = await http.get(url);

    print(response.body);

    if (response.statusCode == 200) {
      _stockList.clear();
      var dataConvertedData = json.decode(utf8.decode(response.bodyBytes));
      List results = dataConvertedData['results'];
      for (var item in results) {
        Stock stock = Stock(
          stockId: item["s.stock_id"],
          productId: item["s.stock_product_id"],
          productName: item["p.product_name"],
          productQty: item["s.stock_quantity"],
        );
        _stockList.add(stock);
      }
      setState(() {});
    } else {
      print("error : ${response.statusCode}");
    }
  }
} // class
