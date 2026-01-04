import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:project_pairs_251230/model/approval.dart';
import 'package:project_pairs_251230/model/approve_purchase.dart';
import 'package:project_pairs_251230/model/product.dart';
import 'package:project_pairs_251230/model/stock.dart';
import 'package:project_pairs_251230/util/global_data.dart';
import 'package:project_pairs_251230/util/message.dart';
import 'package:project_pairs_251230/view/admin/admin_side_bar.dart';
import 'package:project_pairs_251230/util/side_menu.dart';
import 'package:http/http.dart' as http;

class AdminPurchaseOrder extends StatefulWidget {
  const AdminPurchaseOrder({super.key});

  @override
  State<AdminPurchaseOrder> createState() => _AdminPurchaseOrderState();
}

class _AdminPurchaseOrderState extends State<AdminPurchaseOrder> {
  // property
  // 드랍다운
  int dropDownValue = 10;
  final List<int> quantityItems = [10, 20, 30, 50, 100];
  String imageUrl = "${GlobalData.url}/images/view";
  String stockSelectAllUrl = "${GlobalData.url}/stock/selectAll";
  int selectedProduct = 0;
  int selectedQty = 10;
  final Map<String, int> colorMap = {'Red': 1, 'White': 2, 'Black': 3};
  String selectedColor = 'Red';
  List<Product> _productList = [];
  int? selectedProductId;

  late List<ApprovePurchase> _approveList = [];

  Message message = Message();

  // === product insert용 state ===
  int selectedColorId = 1;
  int selectedSizeId = 1;
  int selectedBrandId = 1;
  int selectedCategoryId = 1;
  String productName = '';
  String productDescription = '';
  int productPrice = 0;

  @override
  void initState() {
    super.initState();
    // getProductData();
    getProductList();
    getApprovalList();
  }

  // === Property ===
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 241, 250, 253),
      body: Row(
        children: [
          AdminSideBar(
            selectedMenu: SideMenu.procure,
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
                        child: Icon(Icons.add_shopping_cart_sharp, size: 30),
                      ),
                      Text('발주 신청 페이지', style: _adminTitle()),
                    ],
                  ),
                  // SizedBox(height: 10),
                  // _insertContainer(),
                  SizedBox(height: 35),
                  _buildHead(),

                  SizedBox(height: 8),
                  _approveList.isEmpty
                      ? Center(child: Text('발주 내역이 없습니다'))
                      : Expanded(
                          child: ListView.builder(
                            itemCount: _approveList.length,
                            itemBuilder: (context, index) {
                              return Card(

                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        cell(
                                          child: Text(_approveList[index].approvalId.toString(), style: headerStyle()),
                                          flex: 1,
                                          alignment: Alignment.center,
                                        ),
                                        cell(
                                          child: Text(_approveList[index].approvalProductName, style: headerStyle()),
                                          flex: 2,
                                          alignment: Alignment.center,
                                        ),
                                        cell(
                                          child: Text(_approveList[index].approvalProductQty.toString(), style: headerStyle()),
                                          alignment: Alignment.center,
                                          flex: 2,
                                        ),
                                        cell(
                                          child: Text(
                                            returnApprovalStatusCode(_approveList[index].status),
                                            style: headerStyle(),
                                          ),
                                          alignment: Alignment.center,
                                          flex: 2,
                                        ),
                                      ],
                                    ),
                                        _approveList[index].status == 6
                                        ? ElevatedButton(onPressed: () {
                                    
                                          updateApprovalData(index, 7);
                                          insertQty(_approveList[index].approvalProductID, _approveList[index].approvalProductQty);
                                    
                                        }, child: Text('수주 확인'))
                                        : Center()
                                  ],
                                ),
                              );
                            },
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

  // ======================= Widget =================================

  // 제품 목차 타이틀
  Widget _buildHead() {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: containerStyle(),

      child: Row(
        children: [
          cell(
            child: Text('발주 번호', style: headerStyle()),
            flex: 1,
            alignment: Alignment.center,
          ),
          cell(
            child: Text('상품명', style: headerStyle()),
            flex: 2,
            alignment: Alignment.center,
          ),
          cell(
            child: Text('상품 갯수', style: headerStyle()),
            alignment: Alignment.center,
            flex: 2,
          ),
          cell(
            child: Text('발주 상태', style: headerStyle()),
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

  Future updateApprovalData(int index, int status) async {

    var url = Uri.parse('${GlobalData.url}/approve/updateStatus');
    print(url);
    var response = await http.post(
      url,
      body: {
        'approve_id': _approveList[index].approvalId.toString(),
        'status': status.toString(),
      },
    );
    if (response.statusCode == 200) {
      var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
      if (dataConvertedJSON['results'] == 'OK') {
        String msg = '';
        insertDate(_approveList[index].approvalId!, status, msg);
        return true; // 삽입 성공
      } else {}
    }
  }

  Future insertQty(int id, int qty)async{
    
      var stockUrl = Uri.parse("${GlobalData.url}/stock/update");
      var stockRes = await http.post(
        stockUrl,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          "stock_quantity":
              (-qty)
                  .toString(),
          "stock_product_id": id.toString(),
        },
      );

      if (stockRes.statusCode != 200) {
        throw Exception("추가 실패: ${stockRes.statusCode}");
      } else {
        var body = json.decode(stockRes.body);
        if ((body["results"] ?? "") != "OK") {
          throw Exception("추가 실패: ${stockRes.body}");
        } else {
          setState(() {
            
          });
          message.successSnackBar('수주 완료', '정상적으로 상품이 도착했어요!');
        }
      }
  }

  Future insertDate(int id, int status, String msg) async {
    var url = Uri.parse('${GlobalData.url}/approve_date/insert');
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {'approve_id': id.toString(), 'status': status.toString()},
    );
    if (response.statusCode == 200) {
      var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
      if (dataConvertedJSON['results'] == 'OK') {
        // Get.back();
        // message.successSnackBar('품의 성공', '품의가 정상 처리 되었답니다.');

        return true; // 삽입 성공
      }
    }
    return false; // 삽입 실패
  }


  Future<void> getProductList() async {
    final url = Uri.parse('${GlobalData.url}/product/select');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = json.decode(utf8.decode(response.bodyBytes));
      final List results = decoded['results'];

      _productList = results.map((item) => Product.fromJson(item)).toList();
      // 기본값 세팅
      if (_productList.isNotEmpty) {
        selectedProductId ??= _productList.first.product_id;
      }
      setState(() {});
    } else {
      debugPrint('product list error: ${response.statusCode}');
    }
  }


String returnApprovalStatusCode(int code) {
    String status = "";
    switch (code) {
      case 1:
        status = "팀장 승인 대기 중";
      case 2:
        status = "임원 승인 대기 중";
      case 3:
        status = "발주 승인 완료";
      case 4:
        status = "발주 중";
      case 5:
        status = "수주 대기 중";
      case 6:
        status = "수주 확인 대기 중";
      case 7:
        status = "완료";
      case 8:
        status = "취소";
      case 9:
        status = "반려";
    }
    return status;
  }
  

  Future getApprovalList() async {
    var url = Uri.parse('${GlobalData.url}/approve/selectPurchased');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      _approveList.clear();
      var dataConvertedData = json.decode(utf8.decode(response.bodyBytes));
      List results = dataConvertedData['results'];
      print('$results / len : ${results.length}');

      for(var item in results)
      {
        ApprovePurchase purchase = ApprovePurchase(
          approvalId: item['approve_id'],
          approvalProductID: item['approve_product_id'], 
          approvalProductName: item['product_name'], 
          approvalProductQty: item['approve_quantity'], 
          status: item['approve_status']);

          _approveList.add(purchase);
      }

      setState(() {});

      for(int i = 0; i < _approveList.length; i++)
      {
        if(_approveList[i].status  < 6)
        {
          updateApprovalData(i, 6);
        }
      }
    } else {
      print("error : ${response.statusCode}");
    }
  }

  // _showInsertList() {
  //   final selectedProductName = _productList
  //       .firstWhere(
  //         (p) => p.product_id == selectedProductId,
  //         orElse: () => Product(
  //           product_name: '선택 안됨',
  //           product_price: 0,
  //           product_description: '0',
  //           product_color_id: 0,
  //           product_size_id: 0,
  //           product_category_id: 0,
  //           product_brand_id: 0,
  //         ),
  //       )
  //       .product_name;

  //   Get.defaultDialog(
  //     title: '등록 내용 확인',
  //     titleStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //     content: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         _dialogRow('제품', selectedProductName),
  //         _dialogRow('컬러', selectedColor.toString()),
  //         _dialogRow('수량', '$selectedQty 개'),
  //       ],
  //     ),
  //     actions: [
  //       TextButton(
  //         onPressed: () {
  //           Get.back(); // 닫기
  //         },
  //         child: const Text('취소'),
  //       ),
  //       ElevatedButton(
  //         onPressed: () async {
  //           // TODO: 실제 등록 API 호출
  //           await insertProduct();
  //           Get.back();
  //         },
  //         child: const Text('확인'),
  //       ),
  //     ],
  //   );
  // }

  Widget _dialogRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
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
