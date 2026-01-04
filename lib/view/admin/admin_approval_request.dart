import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_pairs_251230/model/approve_employee.dart';
import 'package:project_pairs_251230/model/approve_product.dart';
import 'package:project_pairs_251230/util/global_data.dart';
import 'package:project_pairs_251230/util/message.dart';
import 'package:project_pairs_251230/util/side_menu.dart';
import 'package:project_pairs_251230/view/admin/admin_side_bar.dart';
import 'package:http/http.dart' as http;

class AdminApprovalRequest extends StatefulWidget {
  const AdminApprovalRequest({super.key});

  @override
  State<AdminApprovalRequest> createState() => _AdminApprovalRequestState();
}

class _AdminApprovalRequestState extends State<AdminApprovalRequest> {
  // === Property ===
  final String _imageUrl = "${GlobalData.url}/images/view";
  final String _productUrl = "${GlobalData.url}/product/selectApprove";
  final String _employeeUrl = "${GlobalData.url}/employee/getNameWithApproval";

  late List<String> _productNameList = [];
  late List<ApproveProduct> _productList = [];
  String _selectedProductValue = "";
  int _selectedProductId = 1;
  int _employeeId = 1;
  int _qty = 1;
  ApproveEmployee? _employee;
  @override
  void initState() {
    super.initState();
    getProductData();
    getEmployeeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AdminSideBar(
            selectedMenu: SideMenu.procure,
            onMenuSelected: (menu) {},
          ),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '상품 발주 품의',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: DropdownButton(
                    dropdownColor: Theme.of(context).colorScheme.onPrimary,
                    iconEnabledColor: Theme.of(context).colorScheme.error,
                    iconDisabledColor: Theme.of(context).colorScheme.onError,
                    value: _selectedProductValue,
                    icon: Icon(Icons.keyboard_arrow_down),
                    items: _productNameList.map((String list) {
                      return DropdownMenuItem(
                        value: list,
                        child: Text(
                          list,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      _selectedProductValue = value!;
                      _selectedProductId =
                          _productList[_productNameList.indexOf(
                                _selectedProductValue,
                              )]
                              .productId!;
                      setState(() {});
                    },
                  ),
                ),
                SizedBox(height: 20,),
                                _productList.isEmpty ? Center() : _buildCenter(),
                SizedBox(height: 20,),
                                _employee == null ? Center() : _buildEmployee(),
                SizedBox(height: 20,),
                                _buildQtySelector(context),
                SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                ElevatedButton(onPressed: () {
                  Get.back();
                }, child: Text('취소')),
                ElevatedButton(onPressed: () {
                  insertApproval();
                }, child: Text('확인'))
              ],)

              ],
            ),
          ),
        ],
      ),
    );
  } // build

  // === Widgets ===

  Widget _buildCenter() {
    return Column(
      children: [
        Text('상품명: ${_productList[_selectedProductId-1].productName}',style: _style(),),
        Text('사이즈: ${_productList[_selectedProductId-1].productSize}',style: _style()),
        Text('브랜드: ${_productList[_selectedProductId-1].productBrand}',style: _style()),
        Text('종류  : ${_productList[_selectedProductId-1].productCategory}',style: _style()),
        Text('가격  : ${_productList[_selectedProductId-1].productPrice}',style: _style()),
        Text('재고  : ${_productList[_selectedProductId-1].qty}',style: _style()),
      ],
    );
  }

  Widget _buildEmployee() {
    return Column(
      children: [
        Text('품의자: ${_employee!.employeeName}',style: _style()),
        Text('팀장  : ${_employee!.seniorEmployeeName}',style: _style()),
        Text('임원  : ${_employee!.directorEmployeeName}',style: _style()),
      ],
    );
  }

  Widget _buildQtySelector(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // < 버튼
        ElevatedButton(
          onPressed: () {
            setState(() {
              if (_qty > 0) {
                _qty--;
              }
            });
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(40, 40),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                topRight: Radius.zero,
                bottomRight: Radius.zero,
              ),
            ),
          ),
          child: const Text('-'),
        ),

        // 숫자 표시
        Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width * 0.1,
          height: 40,
          color: Colors.grey[200],
          child: Text(_qty.toString(), style: const TextStyle(fontSize: 16)),
        ),

        // > 버튼
        ElevatedButton(
          onPressed: () {
            setState(() {
                _qty++;
            });
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(40, 40),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                topLeft: Radius.zero,
                bottomLeft: Radius.zero,
              ),
            ),
          ),
          child: const Text('+'),
        ),
      ],
    );
  }

  TextStyle _style()
  {
    return TextStyle(
      fontSize: 20
    );
  }

  // === Functions ===

  Future getProductData() async {
    var url = Uri.parse(_productUrl);
    var response = await http.get(url);

    // print(response.body);

    if (response.statusCode == 200) {
      _productList.clear();
      _productNameList.clear();
      var dataConvertedData = json.decode(utf8.decode(response.bodyBytes));
      List results = dataConvertedData['results'];
      for (var item in results) {
        ApproveProduct product = ApproveProduct.fromJson(item);
        _productList.add(product);
        _productNameList.add(
          "${product.productName}/ 색상: ${product.productColor}/ 사이즈: ${product.productSize} ",
        );
      }
      _selectedProductValue = _productNameList.first;
      _selectedProductId = 1;
      setState(() {});
    } else {
      print("error : ${response.statusCode}");
    }
  }

  Future getEmployeeData() async {
    var url = Uri.parse('$_employeeUrl/$_employeeId');
    var response = await http.get(url);


    if (response.statusCode == 200) {
      var dataConvertedData = json.decode(utf8.decode(response.bodyBytes));
      var results = dataConvertedData['results'];
      _employee = ApproveEmployee(
        employeeId: _employeeId, 
        senioremployeeId: results.first['sid'], 
        directorEmployeeId: results.first['did'],
        employeeName: results.first['name'], 
        seniorEmployeeName: results.first['sname'], 
        directorEmployeeName: results.first['dname']);
      setState(() {});
    } else {
      print("error : ${response.statusCode}");
    }
  }

  Future insertApproval() async {
    var url = Uri.parse('${GlobalData.url}/approve/insert');
    var response = await http.post(
      url,
      body: {
        'approve_product_id': _productList[_selectedProductId -1].productId.toString(),
        'approve_quantity': _qty.toString(),
        'approve_employee_id': _employeeId.toString(),
        'approve_senior_id': _employee!.senioremployeeId.toString(),
        'approve_director_id': _employee!.directorEmployeeId.toString(), // Form에 주소 필드가 없으므로 임시로 'N/A' 전송
      },
    );

    if (response.statusCode == 200) {
      var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
      if (dataConvertedJSON['results'] == 'OK') {
        Message message = Message();
        message.successSnackBar('발주 성공', '발주가 정상 처리 되었답니다.'); 
        Get.back();
        return true; // 삽입 성공
      }
    }
    return false; // 삽입 실패
  }
}
