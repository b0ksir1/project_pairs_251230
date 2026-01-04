import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:project_pairs_251230/model/approval.dart';
import 'package:project_pairs_251230/model/stock.dart';
import 'package:project_pairs_251230/util/global_data.dart';
import 'package:project_pairs_251230/view/admin/admin_side_bar.dart';
import 'package:project_pairs_251230/util/side_menu.dart';
import 'package:http/http.dart' as http;
class AdminSalesOrder extends StatefulWidget {
  const AdminSalesOrder({super.key});

  @override
  State<AdminSalesOrder> createState() => _AdminSalesOrderState();
}

class _AdminSalesOrderState extends State<AdminSalesOrder> {
  // === Property ===
  String imageUrl = "${GlobalData.url}/images/view";
  String stockSelectAllUrl =
      "${GlobalData.url}/stock/selectAll";

  late List<Stock> _stockList;

  late List<Approval> _approveList;
  @override
  void initState() {
    super.initState();
    _stockList = [];

    getProductData();
    getApprovalList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AdminSideBar(
            selectedMenu: SideMenu.procure,
            onMenuSelected: (menu) {},
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('수주 관리', 
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54 
                ),),
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
  Future getApprovalList() async{
    var url = Uri.parse('${GlobalData.url}/selectPurchased');
    var response = await http.get(url);

    print(url);
    print(response.body);


    if (response.statusCode == 200) {
      _approveList.clear();
      var dataConvertedData = json.decode(utf8.decode(response.bodyBytes));
      List results = dataConvertedData['results'];
      print('$results / len : ${results.length}');

      // for (var item in results) {
      //   Approval product = Approval(
      //     approvalId: item['approve_id'],
      //     approvalProductID: item['approve_product_id'],
      //     approvalProductName: item['product_name'],
      //     approvalProductQty: item['approve_quantity'],
      //     employeeId: item['approve_employee_id'],
      //     seniorEmployeeId: item['approve_senior_id'],
      //     directorEmployeeId: item['approve_director_id'],
      //     approvalemplyeeName: item['approve_employee_name'],
      //     approvalemplyeeSeniorName: item['approve_senior_name'],
      //     approvalemplyeeDirectorName: item['approve_director_name'],
      //     status: item['approve_status'],
      //     date: item['date'],
      //   );
      //   _approveList.add(product);
      //   //   _productNameList.add("${product.productName}/ 색상: ${product.productColor}/ 사이즈: ${product.productSize} ");
      // }
      // _selectedProductValue = _productNameList.first;
      // _selectedProductId = _productList.first.productId!;
      setState(() {});
    } else {
      print("error : ${response.statusCode}");
    }
  }
  Future getProductData() async {
    var url = Uri.parse(stockSelectAllUrl);
    var response = await http.get(url);

    // print(response.body);

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