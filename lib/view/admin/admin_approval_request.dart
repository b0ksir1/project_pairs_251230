import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:project_pairs_251230/model/approve_product.dart';
import 'package:project_pairs_251230/model/product.dart';
import 'package:project_pairs_251230/model/stock.dart';
import 'package:project_pairs_251230/util/global_data.dart';
import 'package:project_pairs_251230/util/side_menu.dart';
import 'package:project_pairs_251230/view/admin/admin_side_bar.dart';
import 'package:http/http.dart' as http;

class AdminApprovalRequest extends StatefulWidget {
  const AdminApprovalRequest({super.key});

  @override
  State<AdminApprovalRequest> createState() => _AdminApprovalRequestState();
}

class _AdminApprovalRequestState extends State<AdminApprovalRequest> {
  // === Property ===
  final String _imageUrl = "${GlobalData.url}/images/view";
  final String _stockUrl = "${GlobalData.url}/stock/selectQty";
  final String _productUrl = "${GlobalData.url}/product/selectApprove";

  late List<String> _productNameList;
  // late List<Stock> _stockList;
  late List<ApproveProduct> _productList;
  String _selectedProductValue = "";
  int _selectedProductId = 1;

  @override
  void initState() {
    super.initState();
    _productNameList = [];
    // _stockList = [];
    _productList = [];
    // getStockData();
    getProductData();
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

          _productList.isEmpty
          ? Center(child: Text(""))
          : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('품의 요청', 
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54 
                ),),
              ),
              Text('상품 발주 품의'),
              DropdownButton(
                  dropdownColor: Theme.of(
                    context,
                  ).colorScheme.onPrimary,
                  iconEnabledColor: Theme.of(
                    context,
                  ).colorScheme.error,
                  iconDisabledColor: Theme.of(
                    context,
                  ).colorScheme.onError,
                  value: _selectedProductValue,
                  icon: Icon(Icons.keyboard_arrow_down),
                  items: _productNameList.map((String list) {
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
                    _selectedProductValue = value!;
                    _selectedProductId = _productList[_productNameList.indexOf(_selectedProductValue)].productId!;
                    setState(() {});
                  },
                ),
                Text('남은 재고: ${getStockData(_selectedProductId)}')
            ],
          ),
        ],
      ),
    );
  } // build

  // === Functions === 
  Future<int> getStockData(int productId) async {
    var url = Uri.parse('$_stockUrl/$productId');
    var response = await http.get(url);

    print(response.body);

    if (response.statusCode == 200) {
      var dataConvertedData = json.decode(
        utf8.decode(response.bodyBytes),
      );
      print(dataConvertedData['results']);
      setState(() {
        
      });
      return dataConvertedData['results'].first;
      // for (var item in results) {
      //   Stock stock = Stock(
      //     stockId: item["s.stock_id"],
      //     productId: item["s.stock_product_id"],
      //     productName: item["p.product_name"],
      //     productQty: item["s.stock_quantity"],
      //   );
      //   _stockList.add(stock);
      // }
    } else {
      print("error : ${response.statusCode}");
      return 0;
    }
  }

  Future getProductData() async {
    var url = Uri.parse(_productUrl);
    var response = await http.get(url);

    print(response.body);

    if (response.statusCode == 200) {
      _productList.clear();
      _productNameList.clear();
      var dataConvertedData = json.decode(
        utf8.decode(response.bodyBytes),
      );
      List results = dataConvertedData['results'];
      for (var item in results) {

        ApproveProduct product = ApproveProduct.fromJson(item);
        _productList.add(product);
        _productNameList.add("${product.productName}/ 색상: ${product.productColor}/ 사이즈: ${product.productSize} ");
      }
      _selectedProductValue = _productNameList.first;
      _selectedProductId = _productList.first.productId!;
      setState(() {});
    } else {
      print("error : ${response.statusCode}");
    }
  }
}
