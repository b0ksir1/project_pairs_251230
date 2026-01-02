import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:project_pairs_251230/util/global_data.dart';

class ShoppingCart extends StatefulWidget {
  const ShoppingCart({super.key});

  @override
  State<ShoppingCart> createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {
  String baseUrl = GlobalData.url; // 우리 FastAPI 주소로 수정
  late int customerId; // 로그인 가능할떄 Get.arguments 로 수정해야함
  bool isLoading = true;

  List<Map<String, dynamic>> cartItems = [];

  @override
  void initState() {
    super.initState();
    customerId = _resolveCustomerId();
    fetchCart();
  }

  int _resolveCustomerId() {
    final args = Get.arguments;

    if (args is int) return args;
    if (args is Map) {
      final v = args["customerId"];
      if (v is int) return v;
      return int.tryParse("$v") ?? 1;
    }
    return 1;
  }

  Future<void> fetchCart() async {
    try {
      setState(() {
        isLoading = true;
      });

      var url = Uri.parse("$baseUrl/cart/select/$customerId");
      var res = await http.get(url);

      if (res.statusCode != 200) {
        throw Exception("서버 응답 오류: ${res.statusCode}");
      }
      debugPrint("GET => $baseUrl/cart/select/$customerId");

      var data = json.decode(res.body);
      var list = (data["results"] as List?) ?? [];

      List<Map<String, dynamic>> parsed = [];
      for (final x in list) {
        final m = x as Map<String, dynamic>;
        parsed.add({
          "cart_id": m["cart_id"],
          "name": (m["product_name"] ?? "").toString(),
          "size": (m["size_name"] ?? "").toString(),
          "price": (m["product_price"] is int)
              ? m["product_price"]
              : int.tryParse("${m["product_price"]}") ?? 0,
          "qty": (m["cart_product_quantity"] is int)
              ? m["cart_product_quantity"]
              : int.tryParse("${m["cart_product_quantity"]}") ?? 1,
          "image_base64": m["image_base64"],
        });
      }

      setState(() {
        cartItems = parsed;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Get.snackbar("장바구니", "불러오기 실패: $e");
    }
  }

  Future<void> deleteCartItem(int index) async {
    try {
      var cartId = cartItems[index]["cart_id"];
      var url = Uri.parse("$baseUrl/cart/delete/$cartId");

      var res = await http.delete(url);

      if (res.statusCode != 200) {
        throw Exception("삭제 실패: ${res.statusCode}");
      }

      setState(() {
        cartItems.removeAt(index);
      });
    } catch (e) {
      Get.snackbar("장바구니", "삭제 실패: $e");
    }
  }

  int get totalPrice {
    int sum = 0;
    for (final item in cartItems) {
      int price = (item["price"] is int)
          ? item["price"]
          : int.tryParse("${item["price"]}") ?? 0;
      int qty = (item["qty"] is int)
          ? item["qty"]
          : int.tryParse("${item["qty"]}") ?? 1;
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
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
                final item = cartItems[index];

                int price = (item["price"] is int)
                    ? item["price"]
                    : int.tryParse("${item["price"]}") ?? 0;
                int qty = (item["qty"] is int)
                    ? item["qty"]
                    : int.tryParse("${item["qty"]}") ?? 1;
                int itemTotal = price * qty;

                Uint8List? imageBytes;
                try {
                  String? b64 = item["image_base64"];
                  if (b64 != null && b64.isNotEmpty) {
                    imageBytes = base64Decode(b64);
                  }
                } catch (_) {}

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
                          child: imageBytes != null
                              ? Image.memory(imageBytes)
                              : Icon(Icons.image, color: Colors.grey),
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
                                    item["name"].toString(),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    deleteCartItem(index);
                                  },
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
                              "사이즈 : ${item["size"]} / 수량:$qty",
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
                      : () async {
                          final result = await Get.to(
                            () => const (),
                            arguments: {
                              "customerId": customerId,
                              "cartItems": cartItems,
                              "totalPrice": totalPrice,
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
