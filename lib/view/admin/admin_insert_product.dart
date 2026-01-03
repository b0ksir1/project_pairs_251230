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

class AdminInsertProduct extends StatefulWidget {
  const AdminInsertProduct({super.key});

  @override
  State<AdminInsertProduct> createState() => _AdminInsertProductState();
}

class _AdminInsertProductState extends State<AdminInsertProduct> {
  // property
  // 드랍다운
  int dropDownValue = 10;

  final List<int> quantityItems = [10, 20, 30, 50, 100];

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
            selectedMenu: SideMenu.product,
            onMenuSelected: (menu) {},
          ),
          Expanded(
            child: _stockList.isEmpty
                ? Center(child: Text('데이터가 비어있음'))
                : Padding(
                    padding: const EdgeInsets.fromLTRB(30, 80, 30, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                              child: Icon(
                                Icons.add_shopping_cart_sharp,
                                size: 30,
                              ),
                            ),
                            Text('제품 등록', style: _adminTitle()),
                          ],
                        ),
                        SizedBox(height: 10),
                        _insertContainer(),
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
  Widget _insertContainer() {
    return Container(
      width: double.infinity,
      height: 80,
      decoration: containerStyle(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 아이콘
          const SizedBox(width: 8),

          // 제목
          const Text(
            '제품 등록',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(width: 24),

          // 입력 영역
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('제품'),
                    DropdownButton<int>(
                      value: dropDownValue,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: quantityItems.map((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text('$value 개'),
                        );
                      }).toList(),
                      onChanged: (int? value) {
                        setState(() {
                          dropDownValue = value!;
                        });
                      },
                    ),
                  ],
                ),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('제품 수량'),
                    DropdownButton<int>(
                      value: dropDownValue,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: quantityItems.map((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text('$value 개'),
                        );
                      }).toList(),
                      onChanged: (int? value) {
                        setState(() {
                          dropDownValue = value!;
                        });
                      },
                    ),
                  ],
                ),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('수량'),
                    DropdownButton<int>(
                      value: dropDownValue,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: quantityItems.map((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text('$value 개'),
                        );
                      }).toList(),
                      onChanged: (int? value) {
                        setState(() {
                          dropDownValue = value!;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(width: 16),

          // 등록 버튼
          ElevatedButton(
            onPressed: () {
              // TODO: 상품 등록 로직
              // Get.to(AdminApprovalRequest());
            },
            child: const Text('상품 등록'),
          ),
        ],
      ),
    );
  }

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

  // ================ style ===========================
  // 타이틀
  TextStyle _adminTitle() {
    return TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  }

  // container
  BoxDecoration containerStyle() {
    return BoxDecoration(
      color: const Color.fromARGB(255, 250, 238, 220),
      border: Border.all(color: const Color.fromARGB(255, 177, 203, 214)),
      borderRadius: BorderRadius.circular(6),
    );
  }
} // class
