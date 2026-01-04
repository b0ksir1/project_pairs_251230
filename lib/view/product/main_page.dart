import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_pairs_251230/page_chart.dart';
import 'package:project_pairs_251230/util/message.dart';
import 'package:project_pairs_251230/view/category/category_list.dart';
import 'package:project_pairs_251230/view/chat/customer_chat_screen.dart';
import 'package:project_pairs_251230/view/order/shopping_cart.dart';
import 'package:project_pairs_251230/view/product/main_page_home.dart';
import 'package:project_pairs_251230/view/search/search_result.dart';
import 'package:project_pairs_251230/view/user/my_page.dart';
import 'package:project_pairs_251230/vm/database_handler_search.dart';
import 'package:sqflite/sqlite_api.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  // property
  late TabController mainTabController;
  final searchController = TextEditingController(); // 검색 textfield
  late int _prevIndex;        // 검색바만 나오게 하는 값변수
  Message message = Message();    // util message
  late DatabaseHandlerSearch databaseHandlerSearch; 

  @override
  void initState() {
    super.initState();

    databaseHandlerSearch = DatabaseHandlerSearch();

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
        centerTitle: true,
        title:  Image.asset('images/logo.png', scale: 3,),
        toolbarHeight: 70,
        backgroundColor: Colors.black,
        actions: [
          TextButton(onPressed: () => Get.to(PageChart()), child: Text('.')),
          IconButton(
            onPressed: () => Get.to(CustomerChatScreen()),
            icon: Icon(Icons.chat_bubble_outline,
            color: const Color.fromARGB(255, 255, 255, 255),),
          ),
        ],
      ),
      body: TabBarView(
        controller: mainTabController,
        children: [
          MainPageHome(),
          CategoryList(),
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
          indicatorSize: TabBarIndicatorSize.label,
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
  final int customerId = 1; // TODO: 로그인한 고객 id로 바꾸기

  Future<List<String>> loadRecent() {
    return databaseHandlerSearch.querySearch(customerId);
  }

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
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
                        onSubmitted: (value) async {
                          final q = value.trim();
                          if (q.isEmpty) {
                            message.errorSnackBar("검색오류", "검색어를 입력해주세요");
                            return;
                          }

                          // 최근검색 저장(중복 제거 후 insert)
                          await databaseHandlerSearch.deleteSearch(customerId, q);
                          await databaseHandlerSearch.insertSearch(customerId, q);

                          // 시트 닫고 이동(닫힌 다음 이동이 안정적)
                          Get.to(const SearchResult(), arguments: q);

                          searchController.clear();
                        },
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        searchController.clear();
                        Get.back();
                        // setModalState(() {}); // BottomSheet 내부만 갱신
                      },
                      child: const Icon(Icons.close, size: 22),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // 최근 검색어 영역
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "최근 검색어",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                FutureBuilder<List<String>>(
                  future: loadRecent(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      );
                    }

                    final list = snapshot.data ?? [];
                    if (list.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          "최근 검색어가 없어요.",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      );
                    }

                    // 최근검색 4개 보여주기
                    return Column(
                      children: list.map((keyword) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.history, size: 20),
                          title: Text(keyword),
                          trailing: const Icon(Icons.north_west, size: 18),
                          onTap: () async {
                            // 탭하면 해당 키워드로 검색 실행 + 저장(최신화)
                            await databaseHandlerSearch.deleteSearch(customerId, keyword);
                            await databaseHandlerSearch.insertSearch(customerId, keyword);

                            Get.to(const SearchResult(), arguments: keyword);

                            searchController.clear();
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

// Future<void> _openSearchSheet() async {
//   await showModalBottomSheet(
//     context: context,
//     isScrollControlled: true, // 키보드 올라와도 잘 보이게
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
//     ),
//     builder: (ctx) {
//       return Padding(
//         padding: EdgeInsets.only(
//           left: 16,
//           right: 16,
//           top: 16,
//           bottom: MediaQuery.of(ctx).viewInsets.bottom + 16, // 키보드 대응
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // 손잡이
//             Container(
//               width: 50,
//               height: 5,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade300,
//                 borderRadius: BorderRadius.circular(99),
//               ),
//             ),
//             const SizedBox(height: 14),

//             // 검색바
//             Row(
//               children: [
//                 Icon(Icons.search, color: Colors.grey.shade700),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: TextField(
//                     controller: searchController,
//                     autofocus: true,
//                     decoration: const InputDecoration(
//                       hintText: '검색어를 입력하세요',
//                       border: InputBorder.none,
//                       isDense: true,
//                     ),
//                     onSubmitted: (value) async{
//                       final q = value.trim();
//                       if (q.isEmpty){
//                         message.errorSnackBar("검색오류", "검색어를 입력해주세요");
//                         Navigator.pop(context);
//                       }else{
//                         Get.to(
//                           SearchResult(),
//                           arguments: q
//                         );
//                         await databaseHandlerSearch.
//                       }
//                       searchController.clear();
                      
//                     },
//                   ),
//                 ),
//                   GestureDetector(
//                     onTap: () {
//                       searchController.clear();
//                       setState(() {}); // (필요 시)
//                     },
//                     child: const Icon(Icons.close, size: 22),
//                   ),
//               ],
//             ),
//           ],
//         ),
//       );
//     },
//   );
// }

} // class
