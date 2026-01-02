import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  int _selectedTab = 0;

  late TextEditingController _searchController;

  int customer_id = 1;

  String _ordersUrl = "${GlobalData.url}/orders/selectByCustomer";
 
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
            child:_ordersList.isEmpty
            ? Center(child: Text('데이터가 없습니다'),)
            : ListView.builder(
              itemCount: _ordersList.length,
              itemBuilder: (context, index) {
                return _orderCard(index);
              },)
          ),
        ],
      ),
    );
  } // build

  // === Widgets ===

  Widget _orderCard(int index)
  {
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
                  Text(_ordersList[index].ordersNumber.toString())
                ],
              ),
              Container(
                color: Colors.grey[200],
                child: Text(getOrderStatus(_ordersList[index].ordersStatus!)),
              )
            ],
          ),
          Row(
            children: [
              Image.network(
                  '${GlobalData.url}/images/view/${_ordersList[index].ordersId}',
                  width: 200,
                  height: 200,),
                  Column(
                    children: [
                      Text(_ordersList[index].productName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold
                        ),),
                      Text('사이즈: ${_ordersList[index].sizeName} / 수량: ${_ordersList[index].ordersQty}'),
                      Text('W: ${_ordersList[index].productPrice * _ordersList[index].ordersQty }'),
                      Text('픽업 매장: ${_ordersList[index].storeName}'),
                    ],
                  ),
            ],
          ),
      Row(
        children: [
          ElevatedButton(onPressed: () {
            // Get.to(OrderDetail());
          }, child: Text('주문 상세')),
          ElevatedButton(onPressed: () {
            // Get.to(OrderDetail());
          }, child: Text('픽업 안내'))
      ],)

        ],
      ),
    );
  }

  Widget _selectCategory() {
  return SizedBox(
    height: 36,
    child: Row(
      children: List.generate(_tabs.length, (index) {
        final isSelected = index == _selectedTab;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedTab = index;
                });
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: isSelected ? Colors.white : Colors.black,
                backgroundColor:
                    isSelected ? Colors.black : Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                _tabs[index],
                style: TextStyle(
                  fontSize: 12
                ),
              ),
            ),
          ),
        );
      }),
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

  String getOrderStatus(int i)
  {
    String status = "요청";
    switch(i)
    {
      case 1:
        status = "준비 중";
      case 2:
        status = "픽업 완료";
      case 3:
        status = "취소";
    }
    return status;
  }

  // === Functions ===
  Future getOrderData()async{
    var url = Uri.parse('$_ordersUrl/$customer_id');
    var response = await http.get(url);
    print(response.body);
    if (response.statusCode == 200) {
      _ordersList.clear();
      var dataConvertedData = json.decode(utf8.decode(response.bodyBytes));
      List results = dataConvertedData['results'];
      for(var item in results)
      {
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
    } else {
      print("error : ${response.statusCode}");
    }
  }
} // class