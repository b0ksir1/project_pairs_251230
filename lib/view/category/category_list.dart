import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_pairs_251230/model/category.dart';
import 'package:project_pairs_251230/model/product_by_category.dart';
import 'package:project_pairs_251230/util/global_data.dart';
import 'package:http/http.dart' as http;
import 'package:project_pairs_251230/view/product/product_detail.dart';

class CategoryList extends StatefulWidget {
  const CategoryList({super.key});

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  final TextEditingController searchController = TextEditingController();
  List<Category> categoryList = [];
  int categoryListIndex = 0;
  List<ProductByCategory> productList = [];

  @override
  void initState() {
    super.initState();
    getcategoryData();
    getProductData();
  }

  Future<void> getcategoryData() async {
    var url = Uri.parse("${GlobalData.url}/category/select");
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var data = json.decode(utf8.decode(response.bodyBytes));
      List result = data["results"];
      setState(() {
        categoryList = result.map((e) => Category(category_name: e['category_name'])).toList();
      });
    }
  }

  Future<void> getProductData() async {
    var url = Uri.parse("${GlobalData.url}/product/products");
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var data = json.decode(utf8.decode(response.bodyBytes));
      List results = data["results"] ?? [];
      productList.clear();

      for (var brand in results) {
        String bName = brand['brand_name'] ?? 'Brand';
        int? bId = brand['brand_id'];
        List pItems = brand['products'] ?? [];

        for (var p in pItems) {
          productList.add(ProductByCategory(
            brand_id: bId,
            brand_name: bName,
            product_id: p['product_id'],
            product_name: p['product_name'] ?? '',
            product_price: p['product_price'] ?? 0,
          ));
        }
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text('카테고리 탐색', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildTabs(),
          const SizedBox(height: 10),
          Expanded(
            child: productList.isEmpty
                ? const Center(child: CircularProgressIndicator(color: Colors.black))
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 24,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: productList.length,
                    itemBuilder: (context, index) => _buildProductItem(index),
                  ),
          )
        ],
      ),
    );
  }

  Widget _buildProductItem(int index) {
    final p = productList[index];
    return GestureDetector(
      onTap: () => Get.to(() => const ProductDetail(), arguments: p.product_id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(30),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.network(
                  '${GlobalData.url}/images/view/${p.product_id}',
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(p.brand_name, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(p.product_name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(
            '₩${p.product_price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        height: 52,
        decoration: BoxDecoration(color: const Color(0xFFF8F8F8), borderRadius: BorderRadius.circular(30)),
        child: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: '원하시는 카테고리나 상품 검색',
            hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
            prefixIcon: Icon(Icons.search, color: Colors.black, size: 20),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: categoryList.length,
        separatorBuilder: (c, i) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final sel = index == categoryListIndex;
          return GestureDetector(
            onTap: () => setState(() => categoryListIndex = index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: sel ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: sel ? Colors.black : const Color(0xFFEEEEEE)),
              ),
              alignment: Alignment.center,
              child: Text(
                categoryList[index].category_name,
                style: TextStyle(color: sel ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          );
        },
      ),
    );
  }
}