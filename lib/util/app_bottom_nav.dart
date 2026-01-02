import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_pairs_251230/view/category/category_list.dart';
import 'package:project_pairs_251230/view/order/shopping_cart.dart';
import 'package:project_pairs_251230/view/product/main_page.dart';
import 'package:project_pairs_251230/view/product/main_page_home.dart';
import 'package:project_pairs_251230/view/user/my_page.dart';

class AppBottomNav extends StatefulWidget {
  const AppBottomNav({super.key});

  @override
  State<AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<AppBottomNav> {
  static const List<String> _routes = [
    '/MainPageHome',
    '/CategoryList',
    '/MainPage',
    '/MyPage',
    '/ShoppingCart',
  ];

  int _currentIndexFromRoute() {
    final current = Get.currentRoute; // 현재 라우트 이름
    final idx = _routes.indexOf(current);
    return idx >= 0 ? idx : 0; // 매칭 안 되면 기본 0
  }

  void _move(int index) {
    switch (index) {
      case 0:
        Get.off(() => const MainPageHome());
        break;
      case 1:
        Get.off(() => const CategoryList());
        break;
      case 2:
        Get.off(() => const MainPage());
        break;
      case 3:
        Get.off(() => const MyPage());
        break;
      case 4:
        Get.off(() => const ShoppingCart());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndexFromRoute();

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: _move,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: "홈",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_view_outlined),
          label: "카테고리",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: "검색",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: "마이페이지",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag_outlined),
          label: "장바구니",
        ),
      ],
    );
  }
}
