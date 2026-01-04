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
  final _dataList = [];

  @override
  void initState() {
    super.initState();
    getJSONData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: _buildMainBanner(),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '브랜드별 구매하기',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            _brandAnchor(context),
            const SizedBox(height: 30),
            _buildSectionTitle('추천 상품'),
            _buildHorizontalProductList(),
            const SizedBox(height: 30),
            _buildEventBanner(),
            const SizedBox(height: 30),
            _buildSectionTitle('전체 상품 둘러보기'),
            _buildProductGrid(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMainBanner() {
    return SizedBox(
      width: double.infinity,
      height: 450,
      child: _dataList.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      '$urlPath/images/view/${_dataList[0]['product_id']}',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    bottom: 25,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NEW ARRIVAL',
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '2026 SPRING COLLECTION',
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            elevation: 0,
                          ),
                          onPressed: () {},
                          child: const Text('지금 보러가기', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildHorizontalProductList() {
    if (_dataList.isEmpty) return const SizedBox(height: 200);
    return SizedBox(
      height: 240,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _dataList.length > 5 ? 5 : _dataList.length,
        separatorBuilder: (context, index) => const SizedBox(width: 15),
        itemBuilder: (context, index) {
          final product = _dataList[index];
          return GestureDetector(
            onTap: () => Get.to(() => const ProductDetail(), arguments: product['product_id']),
            child: SizedBox(
              width: 150,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      '$urlPath/images/view/${product['product_id']}',
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    product['product_name'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₩${product['product_price']}',
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('STYLE TIP', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('일상에 스며드는\nOn & Tap 슈즈 코디', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.3)),
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: () {},
                  child: const Text('매거진 읽기 →', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const Icon(Icons.auto_awesome, size: 60, color: Colors.black12),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    if (_dataList.isEmpty) return const SizedBox();
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _dataList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        mainAxisSpacing: 20,
        crossAxisSpacing: 15,
      ),
      itemBuilder: (context, index) {
        final product = _dataList[index];
        return GestureDetector(
          onTap: () => Get.to(() => const ProductDetail(), arguments: product['product_id']),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    '$urlPath/images/view/${product['product_id']}',
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(product['product_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('₩${product['product_price']}', style: const TextStyle(color: Colors.grey)),
            ],
          ),
        );
      },
    );
  }

  Widget _brandAnchor(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          _brandItem(context, "images/logo_nike.png", 1),
          _brandItem(context, "images/logo_adidas.png", 2),
          _brandItem(context, "images/logo_newbal.png", 3),
          _brandItem(context, "images/logo_fila.png", 4),
          _brandItem(context, "images/logo_converse.png", 5),
        ],
      ),
    );
  }

  Widget _brandItem(BuildContext context, String imagePath, int brandId) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        onTap: () => debugPrint('브랜드 클릭: $brandId'),
        child: Container(
          width: 80,
          height: 80,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9F9),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: Image.asset(imagePath, fit: BoxFit.contain),
        ),
      ),
    );
  }

  Future getJSONData() async {
    var url = Uri.parse('$urlPath/product/select');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      _dataList.clear();
      var dataConvertedData = json.decode(utf8.decode(response.bodyBytes));
      _dataList.addAll(dataConvertedData['results']);
      setState(() {});
    }
  }
}