import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:project_pairs_251230/model/approval.dart';
import 'package:project_pairs_251230/util/global_data.dart';
import 'package:project_pairs_251230/util/message.dart';
import 'package:project_pairs_251230/util/side_menu.dart';
import 'package:project_pairs_251230/view/admin/admin_approval_request.dart';
import 'package:project_pairs_251230/view/admin/admin_side_bar.dart';

class AdminApprovalList extends StatefulWidget {
  const AdminApprovalList({super.key});

  @override
  State<AdminApprovalList> createState() => _AdminApprovalListState();
}

class _AdminApprovalListState extends State<AdminApprovalList> {
  // === Property ===
  final String _imageUrl = "${GlobalData.url}/images/view";
  final String _stockUrl = "${GlobalData.url}/stock/selectQty";
  final String _approveUrl = "${GlobalData.url}/approve/select";
  Message message = Message();

  late List<String> _productNameList;
  late List<Approval> _approveList;

  int _employeeId = 1;
  int _employeeRole =3;

  @override
  void initState() {
    super.initState();
    _productNameList = [];
    // _stockList = [];
    _approveList = [];
    getApprovalData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 241, 250, 253),
      
      body: Row(
        children: [
          AdminSideBar(
            selectedMenu: SideMenu.approval,
            onMenuSelected: (menu) {},
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 80, 30, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                        child: Icon(Icons.approval_outlined, size: 30),
                      ),
                      Text('품의 관리', style: _adminTitle()),
                    ],
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Get.to(AdminApprovalRequest())!.then((value) {
                        getApprovalData();
                      });
                    },
                    child: Text('새 품의'),
                  ),
                  SizedBox(height: 8),
                  _buildHead(),
                  SizedBox(height: 8),
                  Expanded(
                    child: _approveList.isEmpty
                        ? Center(child: Text('품의 내역이 없습니다.'))
                        : ListView.builder(
                            itemCount: _approveList.length,
                            itemBuilder: (context, index) =>
                                _buildApprovalCard(index),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  } // build

  // === Widgets ===

  TextStyle _adminTitle() {
    return TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  }

  Widget _buildApprovalCard(int index) {
    return GestureDetector(
      onTap: () {
        showApprovalDialog(index);
      },
      child: Card(
        child: Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.15,
              child: Center(
                child: Text(
                  _approveList[index].approvalId.toString(),
                  style: headerStyle(),
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.15,
              child: Center(
                child: Text(
                  '${_approveList[index].approvalProductName} ${_approveList[index].approvalProductQty}개',
                  style: headerStyle(),
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.15,
              child: Center(
                child: Text(
                  _approveList[index].approvalemplyeeName,
                  style: headerStyle(),
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.15,
              child: Center(
                child: Text(
                  _approveList[index].date == ""
                      ? ""
                      : _approveList[index].date.toString().substring(0, 10),
                  style: headerStyle(),
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.15,
              child: Center(
                child: Text(
                  returnApprovalStatusCode(_approveList[index].status),
                  style: headerStyle(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showApprovalDialog(int index) {
    Get.defaultDialog(
      title: '품의 확인',

      middleText: '',
      actions: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('품의자: ${_approveList[index].approvalemplyeeName}'),
            Text('팀장  : ${_approveList[index].approvalemplyeeSeniorName}'),
            Text('임원: ${_approveList[index].approvalemplyeeDirectorName}'),
            Text('품의 일자: ${_approveList[index].date.substring(0, 10)}'),
            Text('상태: ${returnApprovalStatusCode(_approveList[index].status)}'),
            Text(
              '품의 내용: ${_approveList[index].approvalProductName} ${_approveList[index].approvalProductQty}개 주문 품의 합니다.',
            ),

            _employeeRole == 1 ? employeeButton(index) : seniorButton(index),
          ],
        ),
      ],
    );
  }

  Widget employeeButton(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              showCancelApprovalDialog(index);
            },
            child: Text('품의 취소'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              Get.back();
            },
            child: Text('확인'),
          ),
        ),
      ],
    );
  }

  Widget seniorButton(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              if (_approveList[index].status == _employeeRole - 1) {
                updateApprovalData(index, false, 9);
              } else {
                message.errorSnackBar('실패', '지금은 품의를 반려 할 수 없습니다.');
              }
            },
            child: Text('품의 반려'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              if (_approveList[index].status == _employeeRole - 1) {
                updateApprovalData(index, true, _approveList[index].status + 1);
              } else {
                message.errorSnackBar('실패', '지금은 품의를 승인 할 수 없습니다.');
              }
            },
            child: Text('품의 승인'),
          ),
        ),
      ],
    );
  }

  void showCancelApprovalDialog(int index) {
    Get.defaultDialog(
      title: '품의 취소',
      middleText:
          '${_approveList[index].approvalProductName} ${_approveList[index].approvalProductQty}개 주문 품의를 취소하시겠습니까?',
      actions: [
        ElevatedButton(
          onPressed: () {
            Get.back();
          },
          child: Text('아니오'),
        ),
        ElevatedButton(
          onPressed: () {
            Get.back();
            Get.back();
            updateApprovalData(index, false, 8);
          },
          child: Text('예'),
        ),
      ],
    );
  }

  // void showApprovalDialog(int index)
  // {
  //   String cancelText = "반려";
  //   String okText = "승인";
  //   if(_approveList[index].status <=2)
  //   {
  //     cancelText = _approveList[index].status == 0 && _employeeRole == 0? '품의 취소':'반려';
  //     okText = _approveList[index].status == 0 && _employeeRole == 0? '확인':'승인';
  //     bool possible = false;
  //           possible = _approveList[index].status == 1 && _employeeRole == 1? true:false;
  //           possible = _approveList[index].status == 2 && _employeeRole == 2? true:false;

  //     Get.defaultDialog(
  //       title: '품의 확인',
  //       middleText: '${_approveList[index].approvalProductName} ${_approveList[index].approvalProductQty}개 주문 품의 합니다.',
  //       actions: [

  //         ElevatedButton(onPressed: () {
  //           _employeeRole == 0
  //           ? showCancelApprovalDialog(index)
  //           : updateApprovalData(index, false);

  //         }, child: Text(cancelText)),
  //         ElevatedButton(onPressed: () {
  //           possible? updateApprovalData(index, true):Get.back();

  //         },  child: Text(okText)),
  //       ]
  //     );
  //   }
  // }

  Widget _buildHead() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.15,
          child: Center(child: Text('품의 번호', style: headerStyle())),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.15,
          child: Center(child: Text('품의 내용', style: headerStyle())),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.15,
          child: Center(child: Text('품의자 ', style: headerStyle())),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.15,
          child: Center(child: Text('품의일 ', style: headerStyle())),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.15,
          child: Center(child: Text('품의 상태', style: headerStyle())),
        ),
      ],
    );
  }

  TextStyle headerStyle() {
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
      color: Colors.black,
    );
  }

  TextStyle bodyStyle() {
    return TextStyle(fontSize: 12, color: Colors.black);
  }

  // === Functions ===

  // void requestApproval()
  // {
  //   Get.defaultDialog(
  //     title: '상품 발주 품의',
  //     middleText: '',
  //     actions: [
  //          DropdownButton(
  //                 dropdownColor: Theme.of(
  //                   context,
  //                 ).colorScheme.onPrimary,
  //                 iconEnabledColor: Theme.of(
  //                   context,
  //                 ).colorScheme.error,
  //                 iconDisabledColor: Theme.of(
  //                   context,
  //                 ).colorScheme.onError,
  //                 value: _selectedProductValue,
  //                 icon: Icon(Icons.keyboard_arrow_down),
  //                 items: _productNameList.map((String list) {
  //                   return DropdownMenuItem(
  //                     value: list,
  //                     child: Text(
  //                       list,
  //                       style: TextStyle(
  //                         color: Theme.of(
  //                           context,
  //                         ).colorScheme.primary,
  //                       ),
  //                     ),
  //                   );
  //                 }).toList(),
  //                 onChanged: (value) {
  //                   _selectedProductValue = value!;
  //                   // _selectedProductId = _productList[_productNameList.indexOf(_selectedProductValue)].productId!;
  //                   setState(() {});
  //                 },
  //               ),
  //     ]);
  // }

  String returnApprovalStatusCode(int code) {
    String status = "";
    switch (code) {
      case 1:
        status = "팀장 승인 대기 중";
      case 2:
        status = "임원 승인 대기 중";
      case 3:
        status = "발주 승인 완료";
      case 4:
        status = "발주 중";
      case 5:
        status = "수주 대기 중";
      case 6:
        status = "수주 확인 대기 중";
      case 7:
        status = "완료";
      case 8:
        status = "취소";
      case 9:
        status = "반려";
    }
    return status;
  }

  Future<int> getStockData(int productId) async {
    var url = Uri.parse('$_stockUrl/$productId');
    var response = await http.get(url);

    print(response.body);

    if (response.statusCode == 200) {
      var dataConvertedData = json.decode(utf8.decode(response.bodyBytes));
      // print(dataConvertedData['results']);

      return dataConvertedData['results'].first;
      // for (var item in results) {
      //   Stock stock = Stock(
      //     stockId: item["s.stock_id"],
      //     productId: item["s.stock_product_id"],
      //     productName: item["p.product_name"],
      //     productQty: item["s.stock_quantity"],
      //   );
      //   _stockList.add(stock);
      // }
    } else {
      print("error : ${response.statusCode}");
      return 0;
    }
  } // getStockData

  Future updateApprovalData(int index, bool confirm, int status) async {
    // String urlLink = '';

    //   _employeeRole == 1
    //   ? confirm
    //     ? urlLink = '${GlobalData.url}/approve/confirmSenior'
    //     : urlLink = '${GlobalData.url}/approve/rejectSenior'
    //   : _employeeRole == 2
    //     ? confirm
    //       ? urlLink = '${GlobalData.url}/approve/confirmDirector'
    //       : urlLink = '${GlobalData.url}/approve/rejectDirector'
    //     :  urlLink = '${GlobalData.url}/approve/cancel';

    var url = Uri.parse('${GlobalData.url}/approve/updateStatus');
    print(url);
    var response = await http.post(
      url,
      body: {
        'approve_id': _approveList[index].approvalId.toString(),
        'status': status.toString(),
      },
    );
    if (response.statusCode == 200) {
      var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
      if (dataConvertedJSON['results'] == 'OK') {
        String msg = '';
        _employeeId == 0
            ? msg = '정상적으로 취소 되었습니다.'
            : confirm
            ? msg = '품의 승인이 완료 되었습니다'
            : msg = '품의 반려가 완료 되었습니다';

        insertDate(_approveList[index].approvalId!, status, msg);
        return true; // 삽입 성공
      } else {}
    }
  }

  Future insertDate(int id, int status, String msg) async {
    var url = Uri.parse('${GlobalData.url}/approve_date/insert');
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {'approve_id': id.toString(), 'status': status.toString()},
    );
    if (response.statusCode == 200) {
      var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
      if (dataConvertedJSON['results'] == 'OK') {
        Get.back();
        message.successSnackBar('품의 성공', '품의가 정상 처리 되었답니다.');

        getApprovalData();

        return true; // 삽입 성공
      }
    }
    return false; // 삽입 실패
  }

  Future getApprovalData() async {
    var url = Uri.parse('$_approveUrl/$_employeeId');
    var response = await http.get(url);

    print(response.body);

    if (response.statusCode == 200) {
      _approveList.clear();
      _productNameList.clear();
      var dataConvertedData = json.decode(utf8.decode(response.bodyBytes));
      List results = dataConvertedData['results'];
      print('$results / len : ${results.length}');

      for (var item in results) {
        Approval product = Approval(
          approvalId: item['approve_id'],
          approvalProductID: item['approve_product_id'],
          approvalProductName: item['product_name'],
          approvalProductQty: item['approve_quantity'],
          employeeId: item['approve_employee_id'],
          seniorEmployeeId: item['approve_senior_id'],
          directorEmployeeId: item['approve_director_id'],
          approvalemplyeeName: item['approve_employee_name'],
          approvalemplyeeSeniorName: item['approve_senior_name'],
          approvalemplyeeDirectorName: item['approve_director_name'],
          status: item['approve_status'],
          date: item['date'],
        );
        _approveList.add(product);
        //   _productNameList.add("${product.productName}/ 색상: ${product.productColor}/ 사이즈: ${product.productSize} ");
      }
      // _selectedProductValue = _productNameList.first;
      // _selectedProductId = _productList.first.productId!;
      setState(() {});
    } else {
      print("error : ${response.statusCode}");
    }
  } // getApprovalData
} // class
