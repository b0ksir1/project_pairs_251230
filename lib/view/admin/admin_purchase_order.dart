import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:project_pairs_251230/model/stock.dart';
import 'package:project_pairs_251230/util/global_data.dart';
import 'package:project_pairs_251230/view/admin/admin_side_bar.dart';
import 'package:project_pairs_251230/util/side_menu.dart';
import 'package:http/http.dart' as http;

class AdminPurchaseOrder extends StatefulWidget {
  const AdminPurchaseOrder({super.key});

  @override
  State<AdminPurchaseOrder> createState() =>
      _AdminPurchaseOrderState();
}

class _AdminPurchaseOrderState
    extends State<AdminPurchaseOrder> {
  String imageUrl = "${GlobalData.url}/images/view";
  String stockSelectAllUrl =
      "${GlobalData.url}/stock/selectAll";

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
            selectedMenu: SideMenu.procure,
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
                  width:
                      MediaQuery.of(context).size.width *
                      0.15,
                  child: Text(
                    _stockList[index].productName,
                    style: bodyStyle(),
                  ),
                ),
                SizedBox(
                  width:
                      MediaQuery.of(context).size.width *
                      0.3,
                  child: Image.network(
                    '${GlobalData.url}/images/view/${_stockList[index].productId}?t=${DateTime.now().millisecondsSinceEpoch}',
                    width: 100,
                    height: 100,
                  ),
                ),
                SizedBox(
                  width:
                      MediaQuery.of(context).size.width *
                      0.1,
                  child: Text(
                    _stockList[index].productQty
                        .toString(),
                    style: bodyStyle(),
                  ),
                ),
                SizedBox(
                  width:
                      MediaQuery.of(context).size.width *
                      0.1,
                  child: Text(
                    '상품 상태',
                    style: bodyStyle(),
                  ),
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
      var dataConvertedData = json.decode(
        utf8.decode(response.bodyBytes),
      );
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
