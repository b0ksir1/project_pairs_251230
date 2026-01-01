import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WishList extends StatefulWidget {
  const WishList({super.key});

  @override
  State<WishList> createState() => _WishListState();
}

class _WishListState extends State<WishList> {
  List<Map<String, dynamic>> items = [
    {"name": "슈퍼스타", "price": 139000, "liked": true},
    {"name": "슈퍼스타", "price": 139000, "liked": true},
  ];

  String formatWon(int value) {
    final s = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idxFromEnd = s.length - i;
      buffer.write(s[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) {
        buffer.write(",");
      }
    }
    return "₩${buffer.toString()}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "위시리스트",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: GridView.builder(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
        itemCount: items.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.71, //제품 카드높이  낮을수록 높이가 길어짐
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          final bool liked = (item["liked"] as bool?) ?? false;

          return Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        height: 140, //  이미지 높이
                        color: Color(0xFFE5E7EB),
                        child: Icon(Icons.image, color: Colors.grey),
                      ),
                    ),
                    Positioned(
                      right: 6,
                      top: 6,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            items[index]["liked"] = !liked;
                          });
                        },
                        child: Icon(
                          liked
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: liked
                              ? Colors.red
                              : Color(0xFF9CA3AF),
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  item["name"].toString(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  formatWon((item["price"] as int?) ?? 0),
                  style: TextStyle(
                    fontSize: 13, //  금액 텍스트 크기
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 38, //  버튼 높이 살짝 키움
                    child: ElevatedButton(
                      onPressed: () {
                        //
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: Text(
                        "장바구니",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
