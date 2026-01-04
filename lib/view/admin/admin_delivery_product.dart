import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_pairs_251230/model/orders_delivery.dart';
import 'package:project_pairs_251230/util/message.dart';
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

   final List productImage = []; // 상품 이미지 한개

  // final String _ordersUrl = "${GlobalData.url}/orders";
  final String _storeUrl = "${GlobalData.url}/store/select";
  final TextEditingController _searchController = TextEditingController();

  String _selectedStoreValue = "";
  int _selectedStoreIndex = 1;
  Message message = Message();

  @override
  void initState() {
    super.initState();
    _ordersList = [];
    _storeList = [];
    getStoreData();
    getOrderData(_selectedStoreIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 241, 250, 253),
      
      body: Row(
        children: [
          AdminSideBar(
            selectedMenu: SideMenu.delivery,
            onMenuSelected: (menu) {},
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 80, 30, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                        child: Icon(Icons.view_in_ar_rounded, size: 30),
                      ),
                      Text('대리점 발송', style: _adminTitle()),
                    ],
                  ),
                  SizedBox(height: 8),
                  _buildSearch(),
                  SizedBox(height: 8),
                  _buildDropDownButton(),
                  SizedBox(height: 8),
                  Expanded(
                    child: _ordersList.isEmpty
                        ? Center(child: Text('주문 내역이 없습니다.'))
                        : ListView.builder(
                            itemCount: _ordersList.length,
                            itemBuilder: (context, index) =>
                                _buildOrderCard(index),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  } // build
  // === Widget ===

  TextStyle _adminTitle() {
    return TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  }

  Widget _buildDropDownButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Container(
        height: 44,
        width: MediaQuery.widthOf(context) * 0.15,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey[200],
        ),
        child: Center(
          child: SizedBox(
            width: MediaQuery.widthOf(context) * 0.1,
            child: DropdownButton<String>(
              isExpanded: true,
              dropdownColor: Theme.of(context).colorScheme.onPrimary,
              iconEnabledColor: Theme.of(context).colorScheme.error,
              iconDisabledColor: Theme.of(context).colorScheme.onError,
              value: _selectedStoreValue,
              icon: const Icon(Icons.keyboard_arrow_down),
              items: _storeList.map((list) {
                return DropdownMenuItem<String>(
                  value: list,
                  child: Text(
                    list,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;
                _selectedStoreValue = value;
                _selectedStoreIndex = _storeList.indexOf(_selectedStoreValue);
                getOrderData(_selectedStoreIndex + 1);
                setState(() {});
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return SizedBox(
      width: double.infinity,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search),
          hintText: '고객명으로 검색',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
        ),
        onSubmitted: (value) {
          if (_searchController.text.trim().isNotEmpty) {
            getOrderDataByKeyword(_selectedStoreIndex);
          }
        },
      ),
    );
  }

  Widget _buildOrderCard(int index) {
    return Card(
      child: Column(
        children: [
          Row(
            children: [
              Image.network(
                '${GlobalData.url}/images/viewOne/${_ordersList[index].productId}',
                width: 200,
                height: 200,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('주문 번호: ${_ordersList[index].ordersNumber}'),
                  Text('상품명: ${_ordersList[index].productName}'),
                  Text('고객명: ${_ordersList[index].customerName}'),
                  Text('희망 대리점: ${_ordersList[index].storeName}'),
                  Text('재고 수량: ${_ordersList[index].stockQty}'),
                ],
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              showDialog(index);
            },
            child: Text('발송 처리'),
          ),
        ],
      ),
    );
  } // _buildOrderCard

  // === Functions ===

  Future updateOrderStatus(int index) async {
    var orderUrl = Uri.parse("${GlobalData.url}/orders/updateStatus");
    var orderRes = await http.post(
      orderUrl,
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
        "orders_status": "1",
        "orders_id": _ordersList[index].ordersId.toString(),
      },
    );

    if (orderRes.statusCode != 200) {
      throw Exception("추가 실패: ${orderRes.statusCode}");
    }

    var body = json.decode(orderRes.body);
    if ((body["results"] ?? "") != "OK") {
      throw Exception("추가 실패: ${orderRes.body}");
    } else {
      var stockUrl = Uri.parse("${GlobalData.url}/stock/update");
      var stockRes = await http.post(
        stockUrl,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          "stock_quantity":
              (_ordersList[index].stockQty - _ordersList[index].ordersQty)
                  .toString(),
          "stock_product_id": _ordersList[index].productId.toString(),
        },
      );

      if (stockRes.statusCode != 200) {
        throw Exception("추가 실패: ${stockRes.statusCode}");
      } else {
        var body = json.decode(stockRes.body);
        if ((body["results"] ?? "") != "OK") {
          throw Exception("추가 실패: ${stockRes.body}");
        } else {
          message.successSnackBar('발송 완료', '정상적으로 발송이 완료 되었답니다.');
          getOrderData(_selectedStoreIndex);
        }
      }
    }
  }

  Future getOrderData(int store) async {
    var url = Uri.parse("${GlobalData.url}/orders/selectRequestByStore/$store");
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
          stockQty: item['stock_quantity'],
          ordersDate: item['orders_date'],
          storeName: item['store_name'],
          productName: item['product_name'],
          customerName: item['customer_name'],
          productId: item['product_id'],
        );
        _ordersList.add(order);
      }
      setState(() {});
    } else {
      print("error : ${response.statusCode}");
    }
  } // getOrderData

  Future getOrderDataByKeyword(int store) async {
    var url = Uri.parse(
      "${GlobalData.url}/orders/selectRequestByStoreKeyword?store_id=$store&search=${_searchController.text.trim()}",
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
          stockQty: item['stock_quantity'],
          ordersDate: item['orders_date'],
          storeName: item['store_name'],
          productName: item['product_name'],
          customerName: item['customer_name'],
          productId: item['product_id'],
        );
        _ordersList.add(order);
      }
      setState(() {});
    } else {
      print("error : ${response.statusCode}");
    }
  } // getOrderData

  Future getStoreData() async {
    var url = Uri.parse(_storeUrl);
    var response = await http.get(url);
    // print("getOrderData : ${response.body} / $url ");
    if (response.statusCode == 200) {
      _storeList.clear();
      var dataConvertedData = json.decode(utf8.decode(response.bodyBytes));
      List results = dataConvertedData['results'];
      for (var item in results) {
        _storeList.add(item['store_name']);
      }
      _selectedStoreValue = _storeList.first;
      setState(() {});
    } else {
      print("error : ${response.statusCode}");
    }
  } // getStoreData

  Future<void> getImagedata(List product) async {
    // image 가져오기

    int proid = 0;
    for (int i = 0; i < product.length; i++) {
      proid = product[i]['product_id'];
      var urlImage = Uri.parse("${GlobalData.url}/images/select/$proid");
      var response = await http.get(urlImage);
      var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
      List results = dataConvertedJSON['results'];
      // print('proid : $proid / $results / ${results[0]}');
      productImage.add(results.first['images_id']);
    }
    setState(() {});
  }

  void showDialog(int index) {
    Get.defaultDialog(
      title: '상품 발송',
      middleText:
          '${_ordersList[index].storeName} 대리점으로 ${_ordersList[index].productName} 상품을 ${_ordersList[index].ordersQty}개 보내겠습니까?',
      actions: [
        ElevatedButton(
          onPressed: () {
            Get.back();
          },
          child: Text('취소'),
        ),

        ElevatedButton(
          onPressed: () {
            if (_ordersList[index].stockQty >= _ordersList[index].ordersQty) {
              updateOrderStatus(index);
            } else {
              message.errorSnackBar('상품 발송 실패', '남은 재고가 부족합니다.');
            }
            Get.back();
          },
          child: Text('확인'),
        ),
      ],
    );
  }
} // class
