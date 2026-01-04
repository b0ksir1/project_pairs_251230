import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:project_pairs_251230/util/global_data.dart';
import 'package:project_pairs_251230/view/product/product_detail.dart';

class MainPageHome extends StatefulWidget {
  const MainPageHome({super.key});

  @override
  State<MainPageHome> createState() =>
      _MainPageHomeState();
}

class _MainPageHomeState extends State<MainPageHome> {
  final urlPath = GlobalData.url;
  final List _productList = [];
  final _dataList = [];
  @override
  void initState() {
    super.initState();
    // getProductData();
    getJSONData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(
        255,
        255,
        255,
        255,
      ),
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
                child: _dataList.isEmpty
                    ? const Center(
                        child: Text('데이터가 비어있음'),
                      )
                    : ClipRRect(
                        borderRadius:
                            BorderRadius.circular(10),
                        child: Stack(
                          children: [
                            // ================= 배너 =================
                            Positioned.fill(
                              child: Image.network(
                                '$urlPath/images/view/${_dataList[0]['product_id']}',
                                fit: BoxFit.cover,
                              ),
                            ),

                            // ================= 그라데이션 =================
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment
                                        .topCenter,
                                    end: Alignment
                                        .bottomCenter,
                                    colors: [
                                      const Color.fromARGB(
                                        0,
                                        255,
                                        255,
                                        255,
                                      ),
                                      const Color.fromARGB(
                                        153,
                                        0,
                                        0,
                                        0,
                                      ).withAlpha(200),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            Positioned(
                              left: 16,
                              bottom: 16,
                              right: 16,
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    'NEW ARRIVAL',
                                    style: TextStyle(
                                      color: Colors.white
                                          .withAlpha(200),
                                      fontSize: 14,
                                      fontWeight:
                                          FontWeight.w500,
                                    ),
                                  ),

                                  const Text(
                                    '2026 SPRING COLLECTION',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 7,
                                  ),

                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.white,
                                      foregroundColor:
                                          Colors.black,
                                      padding:
                                          const EdgeInsets.symmetric(
                                            horizontal:
                                                20,
                                            vertical: 10,
                                          ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(
                                              20,
                                            ),
                                      ),
                                      elevation: 0,
                                    ),
                                    onPressed: () {
                                      // TODO: 이동 처리
                                    },
                                    child: const Text(
                                      '지금 보러가기',
                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight
                                                .w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
              ),

              const SizedBox(height: 30),

              // =================== 타이틀 ==================
              Text(
                '브랜드별 구매하기',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // =================== 상품 그리드 ==============
              _brandAnchor(context),

              // const SizedBox(height: 32),
              // Text('on & Tap 과 함께하는 2026년 새해 운동', style: _cardTitle()),
              //   _buildProductList(),
            ],
          ),
        ),
      ),
    );
  }

  // =================== widgets ===================

  Widget _brandAnchor(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _brandItem(
            context,
            "images/logo_nike.png",
            "NIKE",
            1,
          ),
          _brandItem(
            context,
            "images/logo_adidas.png",
            "ADIDAS",
            2,
          ),
          _brandItem(
            context,
            "images/logo_newbal.png",
            "NEW BALANCE",
            3,
          ),
          _brandItem(
            context,
            "images/logo_fila.png",
            "FILA",
            4,
          ),
          _brandItem(
            context,
            "images/logo_converse.png",
            "CONVERSE",
            5,
          ),
        ],
      ),
    );
  }

  Widget _brandItem(
    BuildContext context,
    String imagePath,
    String title,
    int brandId,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          elevation: 0,
        ),
        onPressed: () {
          // 👉 나중에 브랜드 페이지 연결
          // Get.to(() => BrandProductPage(
          //   brandId: brandId,
          //   brandName: title,
          // ));
          debugPrint('브랜드 클릭: $title ($brandId)');
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =================== API ===================

  Future getJSONData() async {
    var url = Uri.parse('$urlPath/product/select');
    var response = await http.get(url);

    print(response.body);

    if (response.statusCode == 200) {
      _dataList.clear();
      var dataConvertedData = json.decode(
        utf8.decode(response.bodyBytes),
      );
      List results = dataConvertedData['results'];
      _dataList.addAll(results);
      setState(() {});
    } else {
      print("error : ${response.statusCode}");
    }
  }

  void _showErrorSnackBar(String mag) {
    Get.snackbar("WWWWWWWWWWWWWWWWWWWarning", mag);
  }
}
