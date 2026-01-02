import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:project_pairs_251230/util/global_data.dart';
import 'package:project_pairs_251230/view/payment/product_data_test.dart';

class MainPageHome extends StatefulWidget {
  const MainPageHome({super.key});

  @override
  State<MainPageHome> createState() => _MainPageHomeState();
}

class _MainPageHomeState extends State<MainPageHome> {
  // property
  final _dataList = [];
  final urlPath = GlobalData.url;
  @override
  void initState() {
    super.initState();
    getJSONData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: Column(
              children: [
                Stack(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 400,
                      child: _dataList.isEmpty
                          ? Center(child: Text('데이터가 비어있음'))
                          : ClipRRect(
                              borderRadius: BorderRadiusGeometry.circular(10),

                              child: Image.network(
                                '$urlPath/images/view/${_dataList[0]['product_id']}?t=${DateTime.now().millisecondsSinceEpoch}',
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                    Positioned(
                      bottom: 15,
                      left: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '인기 상품',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '인기상품을 만나보세요',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.blueGrey,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // 쇼핑하기 버튼 누르면 어디로 갈지...
                              Get.to(ProductDataTest());
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: BorderSide(width: 1, color: Colors.white),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 5,
                              ),
                            ),
                            child: Text(
                              '쇼핑 하기',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Brand',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    SizedBox(
                      width: 130,
                      child: Column(
                        children: [
                          Image.asset("images/dog1.png", width: 130),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                            child: Text(
                              '러닝화, 테니스, 축구화 등',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'on & Tap 과 함께하는 2026년 새해 운동',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    SizedBox(
                      width: 130,
                      child: Column(
                        children: [
                          Image.asset("images/dog2.png", width: 130),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                            child: Text(
                              '러닝, 테니스, 축구화 등',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  } // build
  // ================ functions ==================

  Future getJSONData() async {
    var url = Uri.parse('$urlPath/product/select');
    var response = await http.get(url);

    print(response.body);

    if (response.statusCode == 200) {
      _dataList.clear();
      var dataConvertedData = json.decode(utf8.decode(response.bodyBytes));
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
} // class
