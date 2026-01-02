import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class WishList extends StatefulWidget {
  const WishList({super.key});

  @override
  State<WishList> createState() => _WishListState();
}

class _WishListState extends State<WishList> {
  String baseUrl = "http://172.30.1.78:8000";
  int customerId = 1;

  bool isLoading = true;

  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    fetchWishlist();
  }

  String formatWon(int value) {
    final reg = RegExp(r'\B(?=(\d{3})+(?!\d))');
    return "₩${value.toString().replaceAllMapped(reg, (m) => ",")}";
  }

  Future<void> fetchWishlist() async {
    try {
      setState(() {
        isLoading = true;
      });

      var url = Uri.parse("$baseUrl/wishlist/select/$customerId");
      var res = await http.get(url);

      if (res.statusCode != 200) {
        throw Exception("서버 응답 오류: ${res.statusCode}");
      }

      var data = json.decode(res.body);
      var list = (data["results"] as List?) ?? [];

      List<Map<String, dynamic>> parsed = [];
      for (final x in list) {
        final m = x as Map<String, dynamic>;
        parsed.add({
          "product_id": m["wishlist_product_id"],
          "name": (m["product_name"] ?? "").toString(),
          "price": (m["product_price"] is int)
              ? m["product_price"]
              : int.tryParse("${m["product_price"]}") ?? 0,
          "image_base64": m["image_base64"],
          "liked": true,
        });
      }

      setState(() {
        items = parsed;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Get.snackbar("위시리스트", "불러오기 실패: $e");
    }
  }

  Future<void> toggleLike(int index) async {
    final item = items[index];
    final int productId = (item["product_id"] is int)
        ? item["product_id"]
        : int.tryParse("${item["product_id"]}") ?? 0;

    final bool before = (item["liked"] as bool?) ?? true;

    if (before == true) {
      final removed = items[index];

      setState(() {
        items.removeAt(index);
      });

      try {
        var url = Uri.parse(
          "$baseUrl/wishlist/deleteByCustomerProduct/$customerId/$productId",
        );
        var res = await http.delete(url);

        if (res.statusCode != 200) {
          throw Exception("삭제 실패: ${res.statusCode}");
        }

        var body = json.decode(res.body);
        if ((body["results"] ?? "") != "OK") {
          throw Exception("삭제 실패: ${res.body}");
        }
      } catch (e) {
        setState(() {
          items.insert(index, removed);
        });
        Get.snackbar("위시리스트", "삭제 실패(복구됨): $e");
      }
    } else {
      setState(() {
        items[index]["liked"] = true;
      });

      try {
        var url = Uri.parse("$baseUrl/wishlist/insert");
        var res = await http.post(
          url,
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
          },
          body: {
            "wishlist_customer_id": customerId.toString(),
            "wishlist_product_id": productId.toString(),
          },
        );

        if (res.statusCode != 200) {
          throw Exception("추가 실패: ${res.statusCode}");
        }

        var body = json.decode(res.body);
        if ((body["results"] ?? "") != "OK") {
          throw Exception("추가 실패: ${res.body}");
        }
      } catch (e) {
        setState(() {
          items[index]["liked"] = false;
        });
        Get.snackbar("위시리스트", "추가 실패(복구됨): $e");
      }
    }
  }

  Future<void> addToCart(int index) async {
    try {
      final item = items[index];
      final int productId = (item["product_id"] is int)
          ? item["product_id"]
          : int.tryParse("${item["product_id"]}") ?? 0;

      if (productId == 0) {
        Get.snackbar("장바구니", "product_id가 올바르지 않습니다");
        return;
      }

      var url = Uri.parse("$baseUrl/cart/insert");
      var res = await http.post(
        url,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "cart_customer_id": customerId.toString(),
          "cart_product_id": productId.toString(),
          "cart_product_quantity": "1",
        },
      );

      if (res.statusCode != 200) {
        throw Exception("추가 실패: ${res.statusCode}");
      }

      var body = json.decode(res.body);
      if ((body["results"] ?? "") != "OK") {
        throw Exception("추가 실패: ${res.body}");
      }

      Get.snackbar("장바구니", "장바구니에 담았습니다");
    } catch (e) {
      Get.snackbar("장바구니", "담기 실패: $e");
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
                final bool liked = (item["liked"] as bool?) ?? false;

                Uint8List? imageBytes;
                try {
                  String? b64 = item["image_base64"];
                  if (b64 != null && b64.isNotEmpty) {
                    imageBytes = base64Decode(b64);
                  }
                } catch (_) {}

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
                              child: imageBytes != null
                                  ? Image.memory(
                                      imageBytes,
                                      fit: BoxFit.cover,
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
                              onTap: () => toggleLike(index),
                              child: Icon(
                                liked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: liked
                                    ? Colors.red
                                    : Color(0xFF9CA3AF),
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        item["name"].toString(),
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
                        formatWon((item["price"] as int?) ?? 0),
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
                            onPressed: () => addToCart(index),
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
