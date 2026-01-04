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
  final List<String> _tabs = ['전체', '요청', '준비중', '픽업완료', '취소'];
  String _selectedTab = "전체";
  int _selectedIndex = 0;
  late TextEditingController _searchController;
  int customer_id = GlobalData.customerId ?? 1;
  List<Orders> _ordersList = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    getOrderData();
  }

  void _showOrderNumberDialog(String number) {
    Get.defaultDialog(
      title: "주문 정보",
      titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      backgroundColor: Colors.white,
      radius: 20,
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        children: [
          const Text("주문번호", style: TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 12),
          SelectableText(
            number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
        ],
      ),
      confirm: SizedBox(
        width: 120,
        height: 45,
        child: ElevatedButton(
          onPressed: () => Get.back(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: const Text("확인", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          '주문 내역',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          _searchWidget(),
          _selectCategory(),
          const SizedBox(height: 10),
          Expanded(
            child: _ordersList.isEmpty
                ? const Center(child: Text('주문 내역이 없습니다.', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _ordersList.length,
                    itemBuilder: (context, index) => _orderCard(index),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _orderCard(int index) {
    final o = _ordersList[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F1F1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(o.ordersDate, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () => _showOrderNumberDialog(o.ordersNumber),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F8F8),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.receipt_long_outlined, size: 12, color: Colors.black54),
                          SizedBox(width: 4),
                          Text('주문번호 확인', style: TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  getOrderStatus(o.ordersStatus!),
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  '${GlobalData.url}/images/view/${o.ordersId}',
                  width: 85,
                  height: 85,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(width: 85, height: 85, color: const Color(0xFFF5F5F5), child: const Icon(Icons.image_not_supported, color: Colors.grey)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(o.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: -0.5)),
                    const SizedBox(height: 6),
                    Text('Size: ${o.sizeName}  |  ${o.ordersQty}개', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 8),
                    Text(
                      '₩${(o.productPrice * o.ordersQty).toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")}',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () {
                Get.to(
                  () => const OrderDetail(),
                  arguments: {
                    "orders_id": o.ordersId,
                    "orders_customer_id": o.ordersCustomerId,
                    "orders_status": o.ordersStatus,
                    "orders_product_id": o.ordersProductId,
                    "orders_number": o.ordersNumber,
                    "orders_quantity": o.ordersQty,
                    "orders_payment": o.ordersPayment,
                    "orders_date": o.ordersDate,
                    "product_name": o.productName,
                    "product_price": o.productPrice,
                    "size_name": o.sizeName,
                    "store_name": o.storeName,
                    "store_id": o.ordersStoreId,
                  },
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.black, width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('상세 내역 보기', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectCategory() {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _tabs.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          bool isSelected = _selectedIndex == index;
          return ChoiceChip(
            label: Text(_tabs[index]),
            selected: isSelected,
            onSelected: (bool selected) {
              setState(() {
                _selectedIndex = index;
                _selectedTab = _tabs[index];
                if (_selectedIndex == 0) getOrderData();
                else getOrderDataByStatus(_selectedIndex - 1);
              });
            },
            selectedColor: Colors.black,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: BorderSide(color: isSelected ? Colors.black : const Color(0xFFEEEEEE)),
            ),
            showCheckmark: false,
          );
        },
      ),
    );
  }

  Widget _searchWidget() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(30),
        ),
        child: TextField(
          controller: _searchController,
          onSubmitted: (value) {
            _selectedIndex == 0 ? getOrderDataByKeyword() : getOrderDataByStatusKeyword(_selectedIndex - 1);
          },
          style: const TextStyle(fontSize: 14),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search, color: Colors.black, size: 20),
            hintText: '상품명으로 내역을 검색해보세요',
            hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  String getOrderStatus(int i) {
    switch (i) {
      case 1: return "준비 중";
      case 2: return "픽업 완료";
      case 3: return "취소";
      default: return "요청";
    }
  }

  Future getOrderData() async {
    var url = Uri.parse("${GlobalData.url}/orders/selectByCustomer/$customer_id");
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var dataConvertedData = json.decode(utf8.decode(response.bodyBytes));
      makeOrderList(dataConvertedData['results']);
    }
  }

  Future getOrderDataByKeyword() async {
    var url = Uri.parse("${GlobalData.url}/orders/selectByKeyword?customer=$customer_id&search=${_searchController.text}");
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var dataConvertedData = json.decode(utf8.decode(response.bodyBytes));
      makeOrderList(dataConvertedData['results']);
    }
  }

  Future getOrderDataByStatus(int status) async {
    var url = Uri.parse("${GlobalData.url}/orders/selectByCustomerStatus?customer=$customer_id&status=$status");
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var dataConvertedData = json.decode(utf8.decode(response.bodyBytes));
      makeOrderList(dataConvertedData['results']);
    }
  }

  Future getOrderDataByStatusKeyword(int status) async {
    var url = Uri.parse("${GlobalData.url}/orders/selectByCustomerStatusKeyword?customer=$customer_id&status=$status&search=${_searchController.text}");
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var dataConvertedData = json.decode(utf8.decode(response.bodyBytes));
      makeOrderList(dataConvertedData['results']);
    }
  }

  void makeOrderList(List results) {
    _ordersList.clear();
    for (var item in results) {
      Orders order = Orders(
        ordersId: item['orders_id'],
        ordersCustomerId: item['orders_customer_id'],
        ordersStatus: item['orders_status'],
        ordersProductId: item['orders_product_id'] ?? item['product_id'],
        ordersStoreId: item['orders_store_id'] ?? item['store_id'] ?? item['store_store_id'],
        ordersNumber: item['orders_number'].toString(),
        ordersQty: item['orders_quantity'] ?? 0,
        productPrice: item['product_price'] ?? 0,
        ordersPayment: item['orders_payment'].toString(),
        ordersDate: item['orders_date'].toString(),
        storeName: item['store_name'].toString(),
        productName: item['product_name'].toString(),
        brandName: item['brand_name'].toString(),
        sizeName: item['size_name'].toString(),
        categoryName: item['category_name'].toString(),
        colorName: item['color_name'].toString(),
      );
      _ordersList.add(order);
    }
    setState(() {});
  }
}