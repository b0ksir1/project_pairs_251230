import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:project_pairs_251230/model/customer.dart';
import 'package:project_pairs_251230/util/global_data.dart';
import 'package:project_pairs_251230/view/payment/payment_options.dart';

class ProductDataTest extends StatefulWidget {
  const ProductDataTest({super.key});

  @override
  State<ProductDataTest> createState() => _ProductDataTestState();
}

class _ProductDataTestState extends State<ProductDataTest> {
  // Property
  final List productData = []; // 신발 JSON data
  late Map<String,int> productSizeData; // 가지고있는 신발 사이즈
  final List sizeData = []; // 신발사이즈 JSON data
  late List sizeDataEmpty;  // 신발사이즈 깡통
  final List imageData = []; // 신발이미지 JSON data
  late List<Customer> customerData;

  late int sizeStockCheck; // 사이즈 선택 변수
  int _currentImageIndex = 0; // image 선택 초기값
  String? _selectedSize;  // 현재 선택된 사이즈

  bool _isInitLoading = true; // 초기 로딩 여부
  final urlPath = GlobalData.url;

  @override
  void initState() {
    super.initState();
    productSizeData = {};
    sizeDataEmpty = [];
    sizeStockCheck = 0;
    customerData = [];
    _initData();
  }

  Future<void> _initData() async {
    try {
      await Future.wait(
        // 2개이상 데이터를 동시에 받아오는 곳
        [getProductdata(), getSizedata(), getImagedata(1), getCustomerData()],
      );
    } catch (e) {
      debugPrint('init error: $e');
    } finally {
      if (mounted) {
        // stateful이 가지고있는 함수(변수) => build가 구성이 되었나
        _isInitLoading = false;
        setState(() {});
      }
    }
  }

   Future<void> getCustomerData() async {
    // size가져오기
    var url = Uri.parse("$urlPath/customer/select");
    var response = await http.get(url);

    sizeData.clear();

    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List results1 = dataConvertedJSON['results'];
    customerData = results1.map((e) => Customer.fromJson(e)).toList();
    setState(() {});
  }


  Future<void> getProductdata() async {
    // product가져오기
    var url = Uri.parse("$urlPath/product/selectAll");
    var response = await http.get(url);

    productData.clear();
    productSizeData.clear();

    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataConvertedJSON['results'];
    productData.addAll(result);
    for (int i = 0; i < productData.length; i++) {
      final String size = productData[i]['product_size'];
      final int qty = productData[i]['stock_quantity'];
      productSizeData[size] = qty;
    }
    // print(productSizeData);
    setState(() {});
  }

  Future<void> getSizedata() async {
    // size가져오기
    var url = Uri.parse("$urlPath/size/select");
    var response = await http.get(url);

    sizeData.clear();

    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List results = dataConvertedJSON['results'];
    sizeData.addAll(results);
    sizeDataEmpty = sizeData.map((e) => e['size_name']).toList();
    setState(() {});
  }

  Future<void> getImagedata(int seq) async {
    // 이미지가져오기
    imageData.clear();
    imageData.add("$urlPath/images/view/$seq");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('신발Test')),
      body: productData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageCarousel(),
                  _buildProductData(),
                  const SizedBox(height: 30),
                  _buildSizeSelector(),
                  const SizedBox(height: 20),
                  _buildActionButtons(),

                ],
              ),
          ),
    );
  } // build

  // --- Widget ---

  _buildActionButtons(){
    return Column(
      children: [
        // 장바구니 (검정)
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () async {
              if (_selectedSize == null) {
                Get.snackbar(
                  "경고",
                  "사이즈를 선택해주세요",
                  snackPosition: SnackPosition.TOP,
                );
                return;
              }
              final selectedSizeInt = int.tryParse(_selectedSize!) ?? 0;
              final stock = productSizeData[_selectedSize!] ?? 0;

              if (stock <= 0) {
                Get.snackbar(
                  "경고",
                  "품절된 사이즈입니다",
                  snackPosition: SnackPosition.TOP,
                );
                return;
              }
              // await cartController.addToCart(
              //   productId: variantId,
              //   title: product!.product_name,
              //   price: product!.product_price,
              //   image: product!.mainImageUrl ?? "",
              //   size: _selectedSize!,
              // );

              // Get.to(ShoppingCartView());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            child: const Text(
              "장바구니",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // 구매하기 & 위시리스트
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 56,
                child: OutlinedButton(
                  onPressed: () async {
                    if (_selectedSize == null) {
                      Get.snackbar(
                        "경고",
                        "사이즈를 선택해주세요",
                        snackPosition: SnackPosition.TOP,
                      );
                      return;
                    }
                    final selectedSizeInt = int.tryParse(_selectedSize!) ?? 0;
                    final stock = productSizeData[_selectedSize!] ?? 0;

                    if (stock <= 0) {
                      Get.snackbar(
                        "경고",
                        "품절된 사이즈입니다",
                        snackPosition: SnackPosition.TOP,
                      );
                      return;
                    }
                    Get.to(
                      PaymentOptions(),
                      arguments: [
                        productData[0]['product_id'],   // 상품 primary key
                        productData[0]['product_name'], // 상품이름
                        selectedSizeInt,    // 선택한 사이즈
                        productData[0]['product_price'],   // 상품가격
                        1,                   // 이미지 seq번호
                        customerData[0].customer_id,    // 고객 id
                        customerData[0].customer_address  // 고객 주소
                      ],
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "구매하기",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ],
    );


  }

    // 사이즈 선택 버튼 (A1: 가로 스크롤 선택 버튼)
  Widget _buildSizeSelector() {
    int selectedQty() {
      // size check
      if (_selectedSize == null) {
        return 0;
      }
      final s = productSizeData[_selectedSize!] ?? 0;
      sizeStockCheck = s;
      return s;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            _selectedSize == null
                ? "사이즈를 선택해주세요"
                : "선택된 사이즈: ${_selectedSize!} | 재고: ${selectedQty()}",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 50,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: sizeDataEmpty.map((size) {
                final isSelected = _selectedSize == size;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSize = isSelected ? null : size;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black : Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      size,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // 상품 상세 정보들
  Widget _buildProductData() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 3. 상품 정보 (타이틀, 가격)
          const SizedBox(height: 20),
          Text(
            productData[0]['product_name'], // widget.title
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${productData[0]['product_brand']} 신발', //widget.subtitle
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Text(
            '₩${productData[0]['product_price']}', //widget.price
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // 이미지 슬라이더
  Widget _buildImageCarousel() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        AspectRatio(
          aspectRatio: 1.1, // 정사각형에 가깝게
          child: PageView.builder(
            itemCount: imageData.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Container(
                color: const Color(0xFFF5F5F5), // 연한 회색 배경
                child: Image.network(
                  imageData[index],
                  fit: BoxFit.cover, // 사진 꽉 채우기 or contain
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(imageData.length, (index) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentImageIndex == index
                      ? Colors.black
                      : Colors.grey.withOpacity(0.5),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
} // class
