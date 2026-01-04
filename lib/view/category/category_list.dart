import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:project_pairs_251230/model/category.dart';
import 'package:project_pairs_251230/util/global_data.dart';
import 'package:http/http.dart' as http;

class CategoryList extends StatefulWidget {
  const CategoryList({super.key});

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  // Property
  final TextEditingController searchController = TextEditingController();
  List<Category> categoryList = [];
  int categoryListIndex = 0;

  // 카테고리 조회
  Future<void> getcategoryData() async{
    var url = Uri.parse("${GlobalData.url}/category/select");
    var response = await http.get(url);
    categoryList.clear();
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataConvertedJSON["results"];
    for(var item in result){
      Category category = Category(
        category_name: item['category_name']
      );
      categoryList.add(category);
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getcategoryData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          '카테고리',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildTabs(),
        ],
      ),
    );
  } //build

  // --- UI: 검색 바 ---
  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: TextField(
        controller: searchController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: '카테고리 검색',
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey,
          ),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // --- UI: 카테고리 탭 ---
  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(categoryList.length, (i) {
            final selected = i == categoryListIndex;
            
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => setState(() => categoryListIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? Colors.black :  Colors.white,
                    borderRadius: BorderRadius.circular(100),
                    border: selected ? Border.all(color: Colors.black) : Border.all(color: Colors.grey.shade300)
                  ),
                  child: Text(
                    categoryList[i].category_name,
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.grey[700],
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

} // class