import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:project_pairs_251230/model/product.dart';
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
  int selectedProduct = 0;
  int selectedQty = 10;
  final Map<String, int> colorMap = {'Red': 1, 'White': 2, 'Black': 3};
  String selectedColor = 'Red';
  List<Product> _productList = [];
  int? selectedProductId;
  

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
    _stockList = [];
    getProductData();
    getProductList();
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
                    const Text('제품 이름'),
                    DropdownButton<int>(
                      value: selectedProductId,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: _productList.map((product) {
                        return DropdownMenuItem<int>(
                          
                          value: product.product_id,
                          child: Text(product.product_name),
                        );
                      }).toList(),
                      onChanged: (int? value) {
                        setState(() {
                          String cutText(String text, {int max = 12}){
                            return text.length > max ? '${text.substring(0, max)}...' : text;
                          }
                          selectedProductId = value!;
                        });
                      },
                    ),
                  ],
                ),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('제품 색상'),
                    DropdownButton<String>(
                      value: selectedColor,
                      items: colorMap.entries.map((entry) {
                        return DropdownMenuItem<String>(
                          value: entry.key,
                          child: Text(entry.key),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          selectedColor = value!;
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
                      value: selectedQty,
                      items: quantityItems.map((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text('$value 개'),
                        );
                      }).toList(),
                      onChanged: (int? value) {
                        setState(() {
                          selectedQty = value!;
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
              // 상품 등록 로직
              _showInsertList();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 0, 0, 0),
              foregroundColor: const Color.fromARGB(255, 255, 255, 255),
              // side: const BorderSide(
              //   color: Color(0xFFB1CBD6),
              //   width: 1,
              // ),
              // elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text(
              '상품 등록',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
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

  Future<void> insertProduct() async {
    final url = Uri.parse('${GlobalData.url}/product/insert');
    final int selectedColorId = colorMap[selectedColor]!;
    final request = http.MultipartRequest('POST', url)
      ..fields['product_color_id'] = selectedColorId.toString()
      ..fields['product_size_id'] = selectedSizeId.toString()
      ..fields['product_brand_id'] = selectedBrandId.toString()
      ..fields['product_category_id'] = selectedCategoryId.toString()
      ..fields['product_name'] = productName
      ..fields['product_description'] = productDescription
      ..fields['product_price'] = productPrice.toString()
      ..fields['product_id'] = selectedProductId.toString();

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    final decoded = json.decode(responseBody);

    if (decoded['result'] == "OK") {
      final productId = decoded['product_id'];

      // 👉 여기서 stock insert 호출 가능
      // 👉 목록 다시 불러오기
      await getProductData();
    }
  }

  Future getProductData() async {
    var url = Uri.parse(stockSelectAllUrl);
    var response = await http.get(url);

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

  _showInsertList() {
    final selectedProductName = _productList
        .firstWhere(
          (p) => p.product_id == selectedProductId,
          orElse: () => Product(
            product_name: '선택 안됨',
            product_price: 0,
            product_description: '0',
            product_color_id: 0,
            product_size_id: 0,
            product_category_id: 0,
            product_brand_id: 0,
          ),
        )
        .product_name;

    Get.defaultDialog(
      title: '등록 내용 확인',
      titleStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _dialogRow('제품', selectedProductName),
          _dialogRow('컬러', selectedColor.toString()),
          _dialogRow('수량', '$selectedQty 개'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back(); // 닫기
          },
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () async {
            // TODO: 실제 등록 API 호출
            await insertProduct();
            Get.back();
          },
          child: const Text('확인'),
        ),
      ],
    );
  }

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
