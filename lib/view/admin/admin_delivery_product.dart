import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:project_pairs_251230/model/orders_delivery.dart';
import 'package:project_pairs_251230/util/order_status.dart';
import 'package:project_pairs_251230/util/side_menu.dart';
import 'package:project_pairs_251230/view/admin/admin_side_bar.dart';
import 'package:http/http.dart' as http;
import 'package:project_pairs_251230/util/global_data.dart';

class AdminDeliveryProduct extends StatefulWidget {
  const AdminDeliveryProduct({super.key});

  @override
  State<AdminDeliveryProduct> createState() => _AdminDeliveryProductState();
}

class _AdminDeliveryProductState extends State<AdminDeliveryProduct> {
  // === Property ===
  late List<OrdersDelivery> _ordersList;
  late List<String> _storeList;

  final String _ordersUrl = "${GlobalData.url}/orders";
  final String _storeUrl = "${GlobalData.url}/store/select";
  final String _stockUrl = "${GlobalData.url}/stock/select";
  final TextEditingController _searchController = TextEditingController();

  String _selectedStoreValue = "";

  @override
  void initState() {
    super.initState();
    _ordersList = [];
    _storeList = [];
    getStoreData();
    getOrderData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AdminSideBar(
            selectedMenu: SideMenu.delivery,
            onMenuSelected: (menu) {},
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('대리점 발송', 
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54 
                ),),
              ),
              Expanded(
                child: _ordersList.isEmpty
                    ? Center(child: Text('데이터가 비어있음'))
                    : Column(
                        children: [
                          TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search),
                              hintText: '주문번호, 고객명으로 검색',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 0,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButton(
                                  dropdownColor: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  iconEnabledColor: Theme.of(
                                    context,
                                  ).colorScheme.error,
                                  iconDisabledColor: Theme.of(
                                    context,
                                  ).colorScheme.onError,
                                  value: _selectedStoreValue,
                                  icon: Icon(Icons.keyboard_arrow_down),
                                  items: _storeList.map((String list) {
                                    return DropdownMenuItem(
                                      value: list,
                                      child: Text(
                                        list,
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    _selectedStoreValue = value!;
                                    setState(() {});
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // 리스트
                          Expanded(
                            child: ListView.builder(
                              itemCount: _ordersList.length,
                              itemBuilder: (context, index) {
                                return _buildOrderCard(index);
                              },
                            ),
                          ),
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

  Widget _buildOrderCard(int index) {
    return Card(
      child: Column(
        children: [
          Row(
            children: [
              Image.network(
                '${GlobalData.url}/images/view/${_ordersList[index].ordersId}',
                width: 200,
                height: 200,
              ),
              Column(
                children: [
                  Text(_ordersList[index].productName),
                  Text('고객명: ${_ordersList[index].customerName}'),
                  Text('희망 대리점: ${_ordersList[index].storeName}'),
                ],
              ),
            ],
          ),
          ElevatedButton(onPressed: () {
            updateOrderStatus();
          }, child: Text('발송 처리')),
        ],
      ),
    );
  } // _buildOrderCard

  // === Functions ===

  Future updateOrderStatus() async {
    print('대리점으로 발송');
  }

  Future getOrderData() async {
    var url = Uri.parse(
      '$_ordersUrl/selectByStatus${OrderStatus.request.code}',
    );
    var response = await http.get(url);
    // print("getOrderData : ${response.body} / $url ");
    if (response.statusCode == 200) {
      _ordersList.clear();
      var dataConvertedData = json.decode(utf8.decode(response.bodyBytes));
      List results = dataConvertedData['results'];
      for (var item in results) {
        OrdersDelivery order = OrdersDelivery(
          ordersId: item['orders_id'],
          ordersNumber: item['orders_number'],
          ordersQty: item['orders_quantity'],
          ordersDate: item['orders_date'],
          storeName: item['store_name'],
          productName: item['product_name'],
          customerName: item['customer_name'],
        );
        _ordersList.add(order);
      }
      setState(() {});
    } else {
      print("error : ${response.statusCode}");
    }
  } // getOrderData

  Future getStoreData() async {
    var url = Uri.parse('$_storeUrl');
    var response = await http.get(url);
    // print("getOrderData : ${response.body} / $url ");
    if (response.statusCode == 200) {
      _storeList.clear();
      var dataConvertedData = json.decode(utf8.decode(response.bodyBytes));
      List results = dataConvertedData['results'];
      for (var item in results) {
        // Store store = Store(
        //   storeId: item['store_id'],
        //   storeName: item['store_name'],
        //   storePhone: item['store_phone'],
        //   storeLat: item['store_lat'],
        //   storeLng: item['store_lng'],
        // );
        _storeList.add(item['store_name']);
      }
      _selectedStoreValue = _storeList.first;
      setState(() {});
    } else {
      print("error : ${response.statusCode}");
    }
  } // getStoreData
} // class
