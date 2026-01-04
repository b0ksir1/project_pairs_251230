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
  
  List<Map<String, dynamic>> allProducts = []; // 전체 데이터를 원본으로 보관
  List<Map<String, dynamic>> filteredProducts = []; // 화면에 보여줄 필터링된 데이터

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
        categoryList = [Category(category_name: '전체')];
        categoryList.addAll(result.map((e) => Category.fromJson(e)).toList());
      });
    }
  }

  Future<void> getProductData() async {
    var url = Uri.parse("${GlobalData.url}/product/selectAll");
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var data = json.decode(utf8.decode(response.bodyBytes));
      setState(() {
        allProducts = List<Map<String, dynamic>>.from(data["results"] ?? []);
        filteredProducts = allProducts;
      });
    }
  }

  void _filterByCategory(int index) {
    setState(() {
      categoryListIndex = index;
      if (index == 0) {
        filteredProducts = allProducts;
      } else {
        String selectedName = categoryList[index].category_name;
        filteredProducts = allProducts.where((p) => p['product_category'] == selectedName).toList();
      }
    });
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
        title: const Text('카테고리', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildTabs(),
          const SizedBox(height: 10),
          Expanded(
            child: filteredProducts.isEmpty
                ? const Center(child: Text('해당 상품이 없습니다.', style: TextStyle(color: Colors.grey)))
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 24,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) => _buildProductItem(index),
                  ),
          )
        ],
      ),
    );
  }

  Widget _buildProductItem(int index) {
    final p = filteredProducts[index];
    return GestureDetector(
      onTap: () => Get.to(() => const ProductDetail(), arguments: p['product_id']),
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
                  '${GlobalData.url}/images/view/${p['product_id']}',
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(p['product_brand'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(p['product_name'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('₩${p['product_price']}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        height: 50,
        decoration: BoxDecoration(color: const Color(0xFFF8F8F8), borderRadius: BorderRadius.circular(30)),
        child: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: '카테고리 또는 상품 검색',
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
      height: 45,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: categoryList.length,
        separatorBuilder: (c, i) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final sel = index == categoryListIndex;
          return GestureDetector(
            onTap: () => _filterByCategory(index),
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
                style: TextStyle(color: sel ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          );
        },
      ),
    );
  }
}