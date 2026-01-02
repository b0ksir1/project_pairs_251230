import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ImageView extends StatefulWidget {
  const ImageView({super.key});

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  // === Property ===
  final _dataList = [];
  final urlPath = 'http://172.16.250.171:8001';
  @override
  void initState() {
    super.initState();
    getJSONData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('메인 페이지')),
      body: Center(
        child: _dataList.isEmpty
            ? Center(child: Text('데이터가 비어있음'))
            : ListView.builder(
                itemCount: _dataList.length,
                itemBuilder: (context, index) {
                  final productId = _dataList[index]['product_id'];
                  return GestureDetector(
                    onTap: () {
                      // Get.to(UpdateAddress(), arguments: _dataList[index])!.then((value) {
                      //   getJSONData();
                      // },);
                    },
                    child: Card(
                      child: Row(
                        children: [
                          Image.network(
                            '$urlPath/images/view/$productId?t=${DateTime.now().millisecondsSinceEpoch}',
                            width: 100,
                          ), // 이미지로 변경
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

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
}
