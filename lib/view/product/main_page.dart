import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_pairs_251230/page_chart.dart';
import 'package:project_pairs_251230/view/order/shopping_cart.dart';
import 'package:project_pairs_251230/view/product/main_page_home.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  // property
  late TabController mainTabController;

  @override
  void initState() {
    super.initState();

    mainTabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    mainTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Design'),
        actions: [
          TextButton(onPressed: () => Get.to(PageChart()), child: Text('Page')),
          IconButton(
            onPressed: () {
              //
            },
            icon: Icon(Icons.chat),
          ),
        ],
      ),
      body: TabBarView(
        controller: mainTabController,
        children: [
          MainPageHome(),
          ShoppingCart(),
          ShoppingCart(),
          ShoppingCart(),
          ShoppingCart(),
        ],
      ),
      bottomNavigationBar: Container(
        color: const Color.fromARGB(255, 235, 235, 235),
        height: 80,
        child: TabBar(
          controller: mainTabController,
          labelColor: const Color.fromARGB(255, 0, 0, 0),
          labelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 10),
          indicatorColor: const Color.fromARGB(255, 0, 0, 0),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorWeight: 2,

          tabs: [
            Tab(icon: Icon(Icons.home), text: '홈'),
            Tab(icon: Icon(Icons.category_outlined), text: '카테고리'),
            Tab(icon: Icon(Icons.search_outlined), text: '검색'),
            Tab(icon: Icon(Icons.shopping_bag_outlined), text: '장바구니'),
            Tab(icon: Icon(Icons.person_2_outlined), text: '마이 페이지'),
          ],
        ),
      ),
    );
  }
}
