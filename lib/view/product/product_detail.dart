import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_pairs_251230/model/order_item.dart';
import 'package:project_pairs_251230/model/product.dart';
import 'package:project_pairs_251230/model/product_detail_item.dart';
import 'package:project_pairs_251230/util/global_data.dart';
import 'package:http/http.dart' as http;
import 'package:project_pairs_251230/util/message.dart';
import 'package:project_pairs_251230/view/chat/customer_chat_screen.dart';
import 'package:project_pairs_251230/view/order/shopping_cart.dart';
import 'package:project_pairs_251230/view/payment/payment_options.dart';
import 'package:intl/intl.dart';

class ProductDetail extends StatefulWidget {
  const ProductDetail({super.key});

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  final formatter = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');
  late final PageController _pageController;
  int _currentImageIndex = 0;
  int _selectedColorIndex = 0;
  int _selectedSizeIndex = 0;
  bool _isLiked = false;
  Message message = Message();
  ProductDetailItem? _product;
  late List<int> _productImages = [];
  List _productSizeId = [];
  List _productSizeList = [];
  List _productColorId = [];
  List _productColorList = [];
  List _productMainImageProductIdList = [];
  List orderItem = [];

  String? _selectedSize;
  int _qty = 1;
  late List<Product> list;
  int product_id = Get.arguments ?? 1;
  int customer_id = 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    getProductData(product_id);
    getProductImages(product_id);
    loadWishList();
  }

  Future getProductImages(int id) async {
    var url = Uri.parse('${GlobalData.url}/images/select/$id');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var dataConvertedData = json.decode(utf8.decode(response.bodyBytes));
      var results = dataConvertedData['results'];
      _productImages.clear();
      for (var item in results) {
        _productImages.add(item['images_id']);
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _product == null
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageCarousel(),
                  _buildColorSelector(),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _product!.productName,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          formatter.format(_product!.price),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 30),
                        _buildSizeSelector(),
                        const SizedBox(height: 30),
                        _buildQtySelector(),
                        const SizedBox(height: 30),
                        _buildActionButtons(),
                        const SizedBox(height: 30),
                        _buildInfoBox(),
                        const SizedBox(height: 30),
                        const Text("제품 설명", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text(
                          _product!.productDescription!,
                          style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 30),
                          child: Divider(height: 1),
                        ),
                        _buildChattingButton(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future getProductData(int id) async {
    var url = Uri.parse('${GlobalData.url}/product/selectById/$id');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var dataConvertedData = json.decode(utf8.decode(response.bodyBytes));
      var results = dataConvertedData['results'];
      _product = ProductDetailItem.fromJson(results.first);
      getMainImageToColorByName(_product!.productName);
      getProductSize(_product!.productName, _product!.colorId);
      getProductColor(_product!.productName);
      setState(() {});
    }
  }

  Future getMainImageToColorByName(String name) async {
    var url = Uri.parse('${GlobalData.url}/product/getMainImageToColorByName/$name');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      _productMainImageProductIdList.clear();
      var dataConvertedData = json.decode(utf8.decode(response.bodyBytes));
      List results = dataConvertedData['results'];
      for (var item in results) {
        _productMainImageProductIdList.add(item['image_id']);
      }
      setState(() {});
    }
  }

  Future getProductColor(String name) async {
    var url = Uri.parse('${GlobalData.url}/product/getAllColorByName?product_name=$name');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      _productColorId.clear();
      _productColorList.clear();
      var dataConvertedData = json.decode(utf8.decode(response.bodyBytes));
      List results = dataConvertedData['results'];
      for (var item in results) {
        _productColorId.add(item['color_id']);
        _productColorList.add(item['color_name']);
      }
      _selectedColorIndex = _productColorId.indexOf(_product!.colorId);
      setState(() {});
    }
  }

  Future getProductSize(String name, int colorId) async {
    var url = Uri.parse('${GlobalData.url}/product/getAllSizeByName?product_name=$name&color_id=$colorId');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      _productSizeId.clear();
      var dataConvertedData = json.decode(utf8.decode(response.bodyBytes));
      List results = dataConvertedData['results'];
      for (var item in results) {
        _productSizeId.add(item['size_id']);
        _productSizeList.add(item['size_name']);
      }
      _selectedSize = _product!.sizeName;
      _selectedSizeIndex = _productSizeList.indexOf(_product!.sizeName);
      setState(() {});
    }
  }

  Future getProductId(String name, int color, int size) async {
    var url = Uri.parse('${GlobalData.url}/product/selectProductByNameSizeColor?product_name=$name&size=$size&color=$color');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var dataConvertedData = json.decode(utf8.decode(response.bodyBytes));
      var results = dataConvertedData['results'];
      getProduct(results.first['product_id']);
    }
  }

  Future getProduct(int id) async {
    product_id = id;
    var url = Uri.parse('${GlobalData.url}/product/selectById/$id');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var dataConvertedData = json.decode(utf8.decode(response.bodyBytes));
      var results = dataConvertedData['results'];
      _product = ProductDetailItem.fromJson(results.first);
      getProductImages(product_id);
      loadWishList();
      setState(() {});
    }
  }

  Future loadWishList() async {
    var url = Uri.parse('${GlobalData.url}/wishlist/hasProduct?customer_id=$customer_id&product_id=$product_id');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var dataConvertedData = json.decode(utf8.decode(response.bodyBytes));
      var results = dataConvertedData['results'];
      _isLiked = results.first['count'] == 0 ? false : true;
      setState(() {});
    }
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
        onPressed: () => Get.back(),
      ),
      title: Text(
        _product != null ? _product!.productName : '',
        style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: [
        IconButton(icon: const Icon(Icons.share_outlined, color: Colors.black), onPressed: () {}),
        IconButton(icon: const Icon(Icons.search, color: Colors.black), onPressed: () {}),
      ],
    );
  }

  Widget _buildImageCarousel() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        AspectRatio(
          aspectRatio: 1.0,
          child: PageView.builder(
            itemCount: _productImages.length,
            onPageChanged: (index) => setState(() => _currentImageIndex = index),
            itemBuilder: (context, index) {
              return Image.network(
                '${GlobalData.url}/images/view/${_productImages[index]}',
                fit: BoxFit.cover,
              );
            },
          ),
        ),
        Positioned(
          bottom: 20,
          child: Row(
            children: List.generate(_productImages.length, (index) {
              return Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentImageIndex == index ? Colors.black : Colors.grey[300],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Center(
        child: ListView.separated(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: _productMainImageProductIdList.length,
          separatorBuilder: (context, index) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            bool isSelected = _selectedColorIndex == index;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColorIndex = index;
                  getProductId(_product!.productName, _productColorId[index], _productSizeId[_selectedSizeIndex]);
                });
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isSelected ? Colors.black : Colors.grey[200]!, width: 2),
                  image: DecorationImage(
                    image: NetworkImage('${GlobalData.url}/images/view/${_productMainImageProductIdList[index]}'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSizeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("사이즈 선택", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text("재고: ${_product!.qty}", style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 45,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _productSizeList.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              String size = _productSizeList[index];
              bool isSelected = _selectedSize == size;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedSize = size;
                    _selectedSizeIndex = index;
                    getProductId(_product!.productName, _productColorId[_selectedColorIndex], _productSizeId[index]);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: isSelected ? Colors.black : Colors.grey[300]!),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    size,
                    style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQtySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("수량", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              IconButton(onPressed: () => setState(() => _qty > 1 ? _qty-- : null), icon: const Icon(Icons.remove, size: 18)),
              Text('$_qty', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => setState(() => _product!.qty > _qty ? _qty++ : null), icon: const Icon(Icons.add, size: 18)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () async {
              if (_selectedSize == null) {
                Get.snackbar("경고", "사이즈를 선택해주세요");
                return;
              }
              if (_product!.qty <= 0) {
                Get.snackbar("경고", "품절된 사이즈입니다");
                return;
              }
              try {
                var url = Uri.parse("${GlobalData.url}/cart/insert");
                var res = await http.post(url, headers: {"Content-Type": "application/x-www-form-urlencoded"}, body: {
                  "cart_customer_id": customer_id.toString(),
                  "cart_product_id": product_id.toString(),
                  "cart_product_quantity": _qty.toString(),
                });
                if (res.statusCode == 200) {
                  var body = json.decode(res.body);
                  if (body["results"] == "OK") Get.snackbar("장바구니", "장바구니에 담았습니다");
                }
              } catch (e) {
                Get.snackbar("에러", "실패하였습니다");
              }
              Get.to(ShoppingCart());
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 0),
            child: const Text("장바구니 담기", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: () async {
                    if (_selectedSize == null) {
                      Get.snackbar("경고", "사이즈를 선택해주세요");
                      return;
                    }
                    if (_product!.qty <= 0) {
                      Get.snackbar("경고", "품절된 사이즈입니다");
                      return;
                    }
                    final item = OrderItem(
                        productId: _product!.productId!,
                        name: _product!.productName,
                        size: int.parse(_selectedSize!),
                        price: _product!.price,
                        imageId: _productMainImageProductIdList[_selectedColorIndex],
                        qty: _qty);
                    Get.to(PaymentOptions(), arguments: {"customerId": customer_id, "items": [item.toJson()]})!.then((value) => getProductData(product_id));
                  },
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.black), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                  child: const Text("구매하기", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 50,
              height: 50,
              child: OutlinedButton(
                onPressed: () async {
                  if (_isLiked) {
                    try {
                      var url = Uri.parse("${GlobalData.url}/wishlist/deleteByCustomerProduct/$customer_id/$product_id");
                      var res = await http.delete(url);
                      if (res.statusCode == 200 && json.decode(res.body)["results"] == "OK") setState(() => _isLiked = false);
                    } catch (e) {}
                  } else {
                    try {
                      var url = Uri.parse("${GlobalData.url}/wishlist/insert");
                      var res = await http.post(url, headers: {"Content-Type": "application/x-www-form-urlencoded"}, body: {
                        "wishlist_customer_id": customer_id.toString(),
                        "wishlist_product_id": product_id.toString(),
                      });
                      if (res.statusCode == 200 && json.decode(res.body)["results"] == "OK") setState(() => _isLiked = true);
                    } catch (e) {}
                  }
                },
                style: OutlinedButton.styleFrom(padding: EdgeInsets.zero, side: BorderSide(color: Colors.grey[300]!), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                child: Icon(_isLiked ? Icons.favorite : Icons.favorite_border, color: _isLiked ? Colors.red : Colors.black),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[200]!)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("무료 반품 안내", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("제품 수령일로부터 14일 동안 무료 반품 서비스를 제공합니다.", style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildChattingButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () async {
          final docRef = FirebaseFirestore.instance.collection('chatting').doc(customer_id.toString());
          final docSnap = await docRef.get();
          if (docSnap.exists) {
            Get.to(CustomerChatScreen());
          } else {
            await FirebaseFirestore.instance.collection("chatting").doc(customer_id.toString()).set({
              'customerId': customer_id.toString(),
              'startAt': DateTime.now().toString(),
              'employeeId': 'empty',
              'dialog': FieldValue.arrayUnion([]),
            }).then((value) => Get.to(CustomerChatScreen()));
          }
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[100], elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        child: const Text("1:1 문의하기", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}