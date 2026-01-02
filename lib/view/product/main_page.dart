import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_pairs_251230/page_chart.dart';
import 'package:project_pairs_251230/util/message.dart';
import 'package:project_pairs_251230/view/order/shopping_cart.dart';
import 'package:project_pairs_251230/view/product/main_page_home.dart';
import 'package:project_pairs_251230/view/search/search_result.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  // property
  late TabController mainTabController;
  final searchController = TextEditingController();
  late int _prevIndex;        // 검색바만 나오게 하는 값변수
  Message message = Message();    // util message

  @override
  void initState() {
    super.initState();

    mainTabController = TabController(length: 5, vsync: this);
    _prevIndex = mainTabController.index;

    mainTabController.addListener(    
      () {
        if (!mainTabController.indexIsChanging) {
          _prevIndex = mainTabController.index;
        }
      },
    );
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
          const SizedBox(),     // 검색은 container로만
          ShoppingCart(),
          MyPage(),
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

          onTap: (value) async{
            // 검색 탭이면 페이지 이동 대신 container
            if (value == 2) {
              mainTabController.animateTo(_prevIndex);

              // search바 띄우기
              await _openSearchSheet();

              return;
            }
          },

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
  } // build

  // =============== function ===================== 
Future<void> _openSearchSheet() async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true, // 키보드 올라와도 잘 보이게
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16, // 키보드 대응
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 손잡이
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 14),

            // 검색바
            Row(
              children: [
                Icon(Icons.search, color: Colors.grey.shade700),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: '검색어를 입력하세요',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onSubmitted: (value) {
                      final q = value.trim();
                      if (q.isEmpty){
                        message.errorSnackBar("검색오류", "검색어를 입력해주세요");
                        Navigator.pop(context);
                      }else{
                        Get.to(
                          SearchResult(),
                          arguments: q
                        );
                      }
                      searchController.clear();
                      
                    },
                  ),
                ),
                  GestureDetector(
                    onTap: () {
                      searchController.clear();
                      setState(() {}); // (필요 시)
                    },
                    child: const Icon(Icons.close, size: 22),
                  ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

} // class
