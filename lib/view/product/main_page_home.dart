import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:project_pairs_251230/util/global_data.dart';
import 'package:project_pairs_251230/view/product/product_detail.dart';

class MainPageHome extends StatefulWidget {
  const MainPageHome({super.key});

  @override
  State<MainPageHome> createState() => _MainPageHomeState();
}

class _MainPageHomeState extends State<MainPageHome> {
  final urlPath = GlobalData.url;
  final List _productList = [];

  @override
  void initState() {
    super.initState();
    getProductData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =================== 메인 배너 ===================
              SizedBox(
                width: double.infinity,
                height: 400,
                child: _productList.isEmpty
                    ? const Center(child: Text('데이터가 비어있음'))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          '$urlPath/images/view/${_productList.first['product_id']}',
                          fit: BoxFit.cover,
                        ),
                      ),
              ),

              const SizedBox(height: 24),

              // =================== 타이틀 ===================
              Text('Brands', style: _cardTitle()),
              const SizedBox(height: 12),

              // =================== 상품 그리드 ===================
              _buildProductList(),

              const SizedBox(height: 32),

              Text('on & Tap 과 함께하는 2026년 새해 운동', style: _cardTitle()),
            ],
          ),
        ),
      ),
    );
  }

  // =================== widgets ===================
  Widget _buildProductList() {
    final displayList = _productList.length > 4
        ? _productList.take(4).toList()
        : _productList;

    final double cardWidth = (MediaQuery.of(context).size.width - 12 * 5) / 4;

    return SizedBox(
      height: cardWidth + 70, // 이미지 + 텍스트 높이
      child: GestureDetector(
        onTap: () => Get.to(
          ProductDetail(),
          arguments: 5
        ),
        child: ListView.builder(
          scrollDirection: Axis.horizontal, // ✅ 가로 스크롤
          itemCount: displayList.length,
          itemBuilder: (context, index) {
            final item = displayList[index];
        
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: SizedBox(
                width: cardWidth, // ✅ 카드 고정 너비
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 이미지
                    AspectRatio(
                      aspectRatio: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          '$urlPath/images/view/${item['product_id']}',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
        
                    // 제품명
                    Text(
                      item['product_name'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
        
                    const SizedBox(height: 4),
        
                    // 가격
                    Text(
                      '${item['product_price']}원',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // =================== API ===================
  Future<void> getProductData() async {
    final url = Uri.parse('$urlPath/product/select');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = json.decode(utf8.decode(response.bodyBytes));
      final List results = decoded['results'];

      setState(() {
        _productList
          ..clear()
          ..addAll(results);
      });
    } else {
      debugPrint('error: ${response.statusCode}');
    }
  }

  // =================== style ===================
  TextStyle _cardTitle() {
    return const TextStyle(fontSize: 20, fontWeight: FontWeight.w700);
  }
}
