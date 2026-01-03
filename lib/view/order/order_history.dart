import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:project_pairs_251230/model/orders.dart';
import 'package:project_pairs_251230/util/global_data.dart';
import 'package:http/http.dart' as http;
import 'package:project_pairs_251230/view/order/order_detail.dart';

class OrderHistory extends StatefulWidget {
  const OrderHistory({super.key});

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  // === Property ===
  final List<String> _tabs = ['전체', '요청', '준비중', '픽업완료', '취소'];

  String _selectedTab = "전체";
  int _selectedIndex = 0;

  late TextEditingController _searchController;

  int customer_id = 1;

  List<Orders> _ordersList = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    getOrderData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('주문 내역')),
      body: Column(
        children: [
          _searchWidget(),
          const SizedBox(height: 16),
          _selectCategory(),
          const SizedBox(height: 12),
          Expanded(
            child: _ordersList.isEmpty
                ? Center(child: Text('데이터가 없습니다'))
                : ListView.builder(
                    itemCount: _ordersList.length,
                    itemBuilder: (context, index) {
                      return _orderCard(index);
                    },
                  ),
          ),
        ],
      ),
    );
  } // build

  // === Widgets ===

  Widget _orderCard(int index) {
    return Card(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_ordersList[index].ordersDate),
                  Text(_ordersList[index].ordersNumber.toString()),
                ],
              ),
              Container(
                color: Colors.grey[200],
                child: Text(getOrderStatus(_ordersList[index].ordersStatus!)),
              ),
            ],
          ),
          Row(
            children: [
              Image.network(
                '${GlobalData.url}/images/view/${_ordersList[index].ordersId}',
                width: 200,
                height: 200,
              ),
              Column(
                children: [
                  Text(
                    _ordersList[index].productName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '사이즈: ${_ordersList[index].sizeName} / 수량: ${_ordersList[index].ordersQty}',
                  ),
                  Text(
                    'W: ${_ordersList[index].productPrice * _ordersList[index].ordersQty}',
                  ),
                  Text('픽업 매장: ${_ordersList[index].storeName}'),
                ],
              ),
            ],
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  Get.to(OrderDetail());
                  // Get.to(OrderDetail());
                },
                child: Text('주문 상세'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Get.to(OrderDetail());
                },
                child: Text('픽업 안내'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _selectCategory() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Container(
        width: MediaQuery.widthOf(context) * 0.35,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        color:Colors.grey[200],
        ),
        height: 36,
        child: Center(
          child: DropdownButton<String>(
            dropdownColor: Theme.of(context).colorScheme.onPrimary,
            iconEnabledColor: Theme.of(context).colorScheme.error,
            iconDisabledColor: Theme.of(context).colorScheme.onError,
            value: _selectedTab,
            items: _tabs.map((e) {
              return DropdownMenuItem<String>(value: e, child: Text(e));
            }).toList(),
            onChanged: (String? v) {
              if (v == null) return;
              _selectedTab = v;
              _selectedIndex = _tabs.indexOf(_selectedTab);
              if (_selectedIndex == 0) {
                getOrderData();
              } else {
                getOrderDataByStatus(_selectedIndex - 1);
              }
              setState(() {});
            },
          ),
        ),
        // child: Row(
        //   children: List.generate(_tabs.length, (index) {
        //     final isSelected = index == _selectedTab;
        //     return Expanded(
        //       child: Padding(
        //         padding: const EdgeInsets.symmetric(horizontal: 4),
        //         child: ElevatedButton(
        //           onPressed: () {
        //             setState(() {
        //               _selectedTab = index;
        //               if(_selectedTab == 0)
        //               {
        //                 getOrderData();
        //               }
        //               else
        //               {
        //                 getOrderDataByStatus(_selectedTab-1);
        //               }
        //             });
        //           },
        //           style: ElevatedButton.styleFrom(
        //             foregroundColor: isSelected ? Colors.white : Colors.black,
        //             backgroundColor:
        //                 isSelected ? const Color.fromARGB(255, 0, 0, 0) : Colors.grey[200],
        //             shape: RoundedRectangleBorder(
        //               borderRadius: BorderRadius.circular(20),
        //             ),
        //           ),
        //           child: Text(
        //             _tabs[index],
        //             style: TextStyle(
        //               fontSize: 12
        //             ),
        //           ),
        //         ),
        //       ),
        //     );
        //   }),
        // ),
      ),
    );
  }

  Widget _searchWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                onSubmitted: (value) {
                  _selectedIndex == 0 
                  ? getOrderDataByKeyword()
                  : getOrderDataByStatusKeyword(_selectedIndex-1);
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: '주문번호 / 상품명',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === Functions ===

  String getOrderStatus(int i) {
    String status = "요청";
    switch (i) {
      case 1:
        status = "준비 중";
      case 2:
        status = "픽업 완료";
      case 3:
        status = "취소";
    }
    return status;
  }

  Future getOrderData() async {
    var url = Uri.parse(
      "${GlobalData.url}/orders/selectByCustomer/$customer_id",
    );
    var response = await http.get(url);
    print(response.body);
    if (response.statusCode == 200) {
      var dataConvertedData = json.decode(utf8.decode(response.bodyBytes));
      List results = dataConvertedData['results'];
      makeOrderList(results);
    } else {
      print("error : ${response.statusCode}");
    }
  }

  Future getOrderDataByKeyword() async {
    var url = Uri.parse(
      "${GlobalData.url}/orders/selectByKeyword?customer=$customer_id&search=${_searchController.text}",
    );
    var response = await http.get(url);
    print(response.body);
    if (response.statusCode == 200) {
      var dataConvertedData = json.decode(utf8.decode(response.bodyBytes));
      List results = dataConvertedData['results'];
      makeOrderList(results);
    } else {
      print("error : ${response.statusCode}");
    }
  }

  Future getOrderDataByStatus(int status) async {
    var url = Uri.parse(
      "${GlobalData.url}/orders/selectByCustomerStatus?customer=$customer_id&status=$status",
    );
    var response = await http.get(url);
    print(response.body);
    if (response.statusCode == 200) {
      var dataConvertedData = json.decode(utf8.decode(response.bodyBytes));
      List results = dataConvertedData['results'];
      makeOrderList(results);
    } else {
      print("error : ${response.statusCode}");
    }
  }

  Future getOrderDataByStatusKeyword(int status) async {
    var url = Uri.parse(
      "${GlobalData.url}/orders/selectByCustomerStatusKeyword?customer=$customer_id&status=$status&search=${_searchController.text}",
    );
    var response = await http.get(url);
    print(response.body);
    if (response.statusCode == 200) {
      var dataConvertedData = json.decode(utf8.decode(response.bodyBytes));
      List results = dataConvertedData['results'];
      makeOrderList(results);
    } else {
      print("error : ${response.statusCode}");
    }
  }

  void makeOrderList(List results) {
    _ordersList.clear();
    for (var item in results) {
      Orders order = Orders(
        ordersId: item['orders_id'],
        ordersNumber: item['orders_number'],
        ordersQty: item['orders_quantity'],
        productPrice: item['product_price'],
        ordersPayment: item['orders_payment'],
        ordersDate: item['orders_date'],
        ordersStatus: item['orders_status'],
        storeName: item['store_name'],
        productName: item['product_name'],
        brandName: item['brand_name'],
        sizeName: item['size_name'],
        categoryName: item['category_name'],
        colorName: item['color_name'],
      );

      _ordersList.add(order);
    }
    setState(() {});
  }
} // class
