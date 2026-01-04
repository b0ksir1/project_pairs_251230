import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:project_pairs_251230/util/global_data.dart';

class WishList extends StatefulWidget {
  const WishList({super.key});

  @override
  State<WishList> createState() => _WishListState();
}

class _WishListState extends State<WishList> {
  final String baseUrl = GlobalData.url;
  late final int customerId;

  bool isLoading = true;

  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    customerId = _getCustomerId();
    fetchWishlist();
  }

  int _getCustomerId() {
    final args = Get.arguments as Map<String, dynamic>?;
    return (args?["customerId"] as int?) ?? 1;
  }

  String formatWon(int value) {
    final reg = RegExp(r'\B(?=(\d{3})+(?!\d))');
    return "₩${value.toString().replaceAllMapped(reg, (m) => ",")}";
  }

  Future<void> fetchWishlist() async {
    try {
      setState(() => isLoading = true);

      final url = Uri.parse("$baseUrl/wishlist/select/$customerId");
      final res = await http.get(url);

      if (res.statusCode != 200) {
        throw Exception("서버 응답 오류: ${res.statusCode}");
      }

      final data = json.decode(utf8.decode(res.bodyBytes));
      final List list = data["results"] ?? [];

      setState(() {
        items = List<Map<String, dynamic>>.from(list);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      Get.snackbar("위시리스트", "불러오기 실패: $e");
    }
  }

  Future<void> removeFromWishlist(int index) async {
    final removed = items[index];
    final int productId = removed["wishlist_product_id"] ?? 0;

    setState(() => items.removeAt(index));

    try {
      final url = Uri.parse(
        "$baseUrl/wishlist/deleteByCustomerProduct/$customerId/$productId",
      );
      final res = await http.delete(url);

      if (res.statusCode != 200)
        throw Exception("삭제 실패: ${res.statusCode}");

      final body = json.decode(utf8.decode(res.bodyBytes));
      if ((body["results"] ?? "") != "OK") {
        throw Exception("삭제 실패: ${utf8.decode(res.bodyBytes)}");
      }
    } catch (e) {
      setState(() => items.insert(index, removed));
      Get.snackbar("위시리스트", "삭제 실패(복구됨): $e");
    }
  }

  Future<void> moveToCart(int index) async {
    final removed = items[index];
    final int productId = removed["wishlist_product_id"] ?? 0;

    setState(() => items.removeAt(index));

    try {
      final url = Uri.parse("$baseUrl/wishlist/moveToCart");
      final res = await http.post(
        url,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "customer_id": customerId.toString(),
          "product_id": productId.toString(),
          "quantity": "1",
        },
      );

      if (res.statusCode != 200)
        throw Exception("이동 실패: ${res.statusCode}");

      final body = json.decode(utf8.decode(res.bodyBytes));
      if ((body["results"] ?? "") != "OK") {
        throw Exception("이동 실패: ${utf8.decode(res.bodyBytes)}");
      }

      Get.snackbar("장바구니", "장바구니로 이동했습니다");
    } catch (e) {
      setState(() => items.insert(index, removed));
      Get.snackbar("장바구니", "이동 실패(복구됨): $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "위시리스트",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? Center(
              child: Text(
                "위시리스트가 비어있습니다",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6B7280),
                ),
              ),
            )
          : GridView.builder(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
              itemCount: items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.71,
              ),
              itemBuilder: (context, index) {
                final item = items[index];

                final String name = (item["product_name"] ?? "")
                    .toString();
                final int price = item["product_price"] ?? 0;
                final int? imagesId = item["images_id"];

                return Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: double.infinity,
                              height: 140,
                              color: Color(0xFFE5E7EB),
                              child: imagesId != null
                                  ? Image.network(
                                      "$baseUrl/images/view/$imagesId",
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) {
                                        return Icon(
                                          Icons.broken_image,
                                          color: Colors.grey,
                                        );
                                      },
                                    )
                                  : Icon(
                                      Icons.image,
                                      color: Colors.grey,
                                    ),
                            ),
                          ),
                          Positioned(
                            right: 6,
                            top: 6,
                            child: InkWell(
                              onTap: () => removeFromWishlist(index),
                              child: Icon(
                                Icons.favorite,
                                color: Colors.red,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        formatWon(price),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                        child: SizedBox(
                          width: double.infinity,
                          height: 38,
                          child: ElevatedButton(
                            onPressed: () => moveToCart(index),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  22,
                                ),
                              ),
                            ),
                            child: Text(
                              "장바구니",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
