import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_pairs_251230/util/global_data.dart';
import 'package:http/http.dart' as http;

class SearchResult extends StatefulWidget {
  const SearchResult({super.key});

  @override
  State<SearchResult> createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  // Property
  final urlPath = GlobalData.url;
  final List productData = []; // 상품 검색 데이터
  final List productImage = []; // 상품 이미지 한개
  var value = Get.arguments ?? "__"; // 0. 검색결과

  @override
  void initState() {
    super.initState();
    getProductdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('검색 결과: $value'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
            Get.back();
          },
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.7, // 사진과 텍스트 공간을 고려한 비율
        ),
        itemCount: productData.length,
        itemBuilder: (context, index) {
          final item = productData[index];
          final imageUrl =
              '$urlPath/images/view/${productImage[index]['images_id']}?t=${DateTime.now().millisecondsSinceEpoch}';
          final price = item['product_price'];
          final priceText = NumberFormat('#,###').format(price);

          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              // TODO: 상세 페이지 이동 등
              // Get.to(ProductDetail(), arguments: item);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 이미지 영역
                    Expanded(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: Colors.grey[100],
                                      alignment: Alignment.center,
                                      child: const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    );
                                  },
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey[100],
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Colors.grey[400],
                                  size: 34,
                                ),
                              ),
                            ),
                          ),
                          // 좌하단 배지 (예: 카테고리/브랜드/재고 등)
                          Positioned(
                            left: 10,
                            bottom: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.65),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                "${item['product_brand'] ?? ''}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 텍스트 영역
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['product_name'] ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // 가격 + 부가 정보(카테고리)
                          Row(
                            children: [
                              Text(
                                "$priceText원",
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.red,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                "${item['product_category'] ?? ''}",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          // 재고 표시
                          if (item['total_stock'] != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              "재고 ${item['total_stock']}개",
                              style: TextStyle(
                                fontSize: 11,
                                color: (item['total_stock'] == 0)
                                    ? Colors.red[300]
                                    : Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  } // build

  // -------------------------- functions ------------------------------------
  Future<void> getProductdata() async {
    // product 가져오기
    var url = Uri.parse("$urlPath/product/select/$value");
    var response = await http.get(url);

    productData.clear();

    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataConvertedJSON['results'];
    productData.addAll(result);
    await getImagedata(productData);
    setState(() {});
  }

  Future<void> getImagedata(List product) async {
    // image 가져오기

    int proid = 0;
    for (int i = 0; i < product.length; i++) {
      proid = product[i]['product_id'];
      var urlImage = Uri.parse("$urlPath/images/select/$proid");
      var response = await http.get(urlImage);
      var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
      List results = dataConvertedJSON['results'];
      productImage.add(results[0]);
    }
    setState(() {});
  }
} // class
