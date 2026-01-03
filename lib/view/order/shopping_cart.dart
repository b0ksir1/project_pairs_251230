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
  final urlPath = GlobalData.url;

  late int customerId;
  late String customerAddress;

  bool isLoading = true;
  List cartItems = [];

  @override
  void initState() {
    super.initState();

    customerId = 1;
    customerAddress = "";

    final args = Get.arguments;
    if (args is Map) {
      customerId = int.tryParse(args["customerId"].toString()) ?? 1;
      customerAddress =
          (args["customerAddress"] ?? args["customer_address"] ?? "")
              .toString();
    } else if (args is int) {
      customerId = args;
    }

    getCartData();
  }

  Future<void> getCartData() async {
    isLoading = true;
    setState(() {});

    try {
      var url = Uri.parse("$urlPath/cart/select/$customerId");
      var response = await http.get(url);

      if (response.statusCode != 200) {
        throw "HTTP ${response.statusCode}";
      }

      var dataConvertedJSON = json.decode(
        utf8.decode(response.bodyBytes),
      );
      List result = dataConvertedJSON["results"] ?? [];

      cartItems = result.map((e) {
        return {
          "cart_id": e["cart_id"] ?? 0,
          "cart_product_id": e["cart_product_id"] ?? 0,
          "product_name": e["product_name"] ?? "",
          "size_name": e["size_name"] ?? "",
          "product_price": e["product_price"] ?? 0,
          "cart_product_quantity": e["cart_product_quantity"] ?? 1,
          "images_id": e["images_id"] ?? 0,
        };
      }).toList();

      isLoading = false;
      setState(() {});
    } catch (e) {
      isLoading = false;
      setState(() {});
      Get.snackbar("장바구니", "불러오기 실패: $e");
    }
  }

  Future<void> deleteCartItem(int index) async {
    try {
      var cartId = cartItems[index]["cart_id"];
      var url = Uri.parse("$urlPath/cart/delete/$cartId");
      var response = await http.delete(url);

      if (response.statusCode != 200) {
        throw "HTTP ${response.statusCode}";
      }

      cartItems.removeAt(index);
      setState(() {});
    } catch (e) {
      Get.snackbar("장바구니", "삭제 실패: $e");
    }
  }

  int getTotalPrice() {
    int sum = 0;
    for (var item in cartItems) {
      int price = int.tryParse(item["product_price"].toString()) ?? 0;
      int qty =
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
    int totalPrice = getTotalPrice();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.offAll(() => const MainPage());
          },
        ),
        title: const Text(
          "장바구니",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
          ? const Center(
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
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];

                int price =
                    int.tryParse(item["product_price"].toString()) ??
                    0;
                int qty =
                    int.tryParse(
                      item["cart_product_quantity"].toString(),
                    ) ??
                    1;
                int itemTotal = price * qty;

                int imagesId =
                    int.tryParse(item["images_id"].toString()) ?? 0;

                final imageUrl =
                    "$urlPath/images/view/$imagesId?t=${DateTime.now().millisecondsSinceEpoch}";

                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: const BoxDecoration(
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
                          color: const Color(0xFFE5E7EB),
                          child: imagesId == 0
                              ? const Icon(
                                  Icons.image,
                                  color: Colors.grey,
                                )
                              : Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(
                                        Icons.image,
                                        color: Colors.grey,
                                      ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
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
                                    item["product_name"].toString(),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => deleteCartItem(index),
                                  child: const Padding(
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
                            const SizedBox(height: 4),
                            Text(
                              "사이즈 : ${item["size_name"]} / 수량:$qty",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              formatWon(itemTotal),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
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
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text(
                    "총 결제 금액",
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    formatWon(totalPrice),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
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
                            () => const PaymentOptions(),
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
                  child: const Text(
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
