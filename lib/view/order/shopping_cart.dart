import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:project_pairs_251230/util/global_data.dart';
import 'package:project_pairs_251230/view/payment/payment_options.dart';
import 'package:project_pairs_251230/view/product/main_page.dart';

class ShoppingCart extends StatefulWidget {
  const ShoppingCart({super.key});

  @override
  State<ShoppingCart> createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {
  final String urlPath = GlobalData.url;

  late int customerId;
  late String customerAddress;

  bool isLoading = true;

  List<Map<String, dynamic>> cartItems = [];

  @override
  void initState() {
    super.initState();
    _initArgs();
    fetchCartData();
  }

  void _initArgs() {
    customerId = 1;
    customerAddress = "";

    final args = Get.arguments as Map<String, dynamic>?;
    if (args == null) return;

    customerId = int.tryParse(args["customerId"].toString()) ?? 1;
    customerAddress =
        (args["customerAddress"] ?? args["customer_address"] ?? "")
            .toString();
  }

  Future<void> fetchCartData() async {
    try {
      setState(() => isLoading = true);

      final url = Uri.parse("$urlPath/cart/select/$customerId");
      final response = await http.get(url);

      if (response.statusCode != 200) {
        setState(() => isLoading = false);
        Get.snackbar("장바구니", "서버 오류: ${response.statusCode}");
        return;
      }

      final data = json.decode(utf8.decode(response.bodyBytes));
      final List list = data["results"] ?? [];

      setState(() {
        cartItems = List<Map<String, dynamic>>.from(list);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      Get.snackbar("장바구니", "불러오기 실패: $e");
    }
  }

  Future<void> deleteCartItem(int index) async {
    try {
      final item = cartItems[index];
      final cartId = item["cart_id"] ?? 0;

      final url = Uri.parse("$urlPath/cart/delete/$cartId");
      final response = await http.delete(url);

      if (response.statusCode != 200) {
        Get.snackbar("장바구니", "삭제 실패: ${response.statusCode}");
        return;
      }

      setState(() {
        cartItems.removeAt(index);
      });
    } catch (e) {
      Get.snackbar("장바구니", "삭제 실패: $e");
    }
  }

  int getTotalPrice() {
    int sum = 0;

    for (final item in cartItems) {
      final int price =
          int.tryParse(item["product_price"].toString()) ?? 0;
      final int qty =
          int.tryParse(item["cart_product_quantity"].toString()) ?? 1;
      sum += price * qty;
    }

    return sum;
  }

  String formatWon(int value) {
    final reg = RegExp(r'\B(?=(\d{3})+(?!\d))');
    return "₩${value.toString().replaceAllMapped(reg, (m) => ",")}";
  }

  @override
  Widget build(BuildContext context) {
    final int totalPrice = getTotalPrice();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.offAll(() => MainPage());
          },
        ),
        title: Text(
          "장바구니",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
          ? Center(
              child: Text(
                "장바구니가 비어있습니다",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6B7280),
                ),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final Map<String, dynamic> item = cartItems[index];
                final int cartId =
                    int.tryParse(item["cart_id"].toString()) ?? 0;
                final int productId =
                    int.tryParse(
                      item["cart_product_id"].toString(),
                    ) ??
                    0;
                final String productName =
                    (item["product_name"] ?? "").toString();
                final String sizeName = (item["size_name"] ?? "")
                    .toString();
                final int price =
                    int.tryParse(item["product_price"].toString()) ??
                    0;
                final int qty =
                    int.tryParse(
                      item["cart_product_quantity"].toString(),
                    ) ??
                    1;

                final int itemTotal = price * qty;

                final int imagesId =
                    int.tryParse(item["images_id"].toString()) ?? 0;

                final String imageUrl =
                    "$urlPath/images/view/$imagesId?t=${DateTime.now().millisecondsSinceEpoch}";

                return Container(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFFE5E7EB),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 100,
                          height: 100,
                          color: Color(0xFFE5E7EB),
                          child: imagesId == 0
                              ? Icon(Icons.image, color: Colors.grey)
                              : Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) {
                                    return Icon(
                                      Icons.image,
                                      color: Colors.grey,
                                    );
                                  },
                                ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    productName,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  // 나중에 수정/기능 추가할 때도 쉬움
                                  onTap: () => deleteCartItem(index),
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: Icon(
                                      Icons.close,
                                      size: 18,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(
                              "사이즈 : $sizeName / 수량 : $qty",
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              formatWon(itemTotal),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                              ),
                            ),

                            // Text("cartId=$cartId / productId=$productId"),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
          ),
          padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    "총 결제 금액",
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Spacer(),
                  Text(
                    formatWon(totalPrice),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: cartItems.isEmpty
                      ? null
                      : () {
                          if (customerAddress.trim().isEmpty) {
                            Get.snackbar("경고", "고객 주소가 없습니다.");
                            return;
                          }

                          Get.to(
                            () => PaymentOptions(),
                            arguments: {
                              "customerId": customerId,
                              "customerAddress": customerAddress,
                              "totalPrice": totalPrice,
                              "cartItems": cartItems,
                            },
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    "결제하기",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
