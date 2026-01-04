import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:project_pairs_251230/model/approval.dart';
import 'package:project_pairs_251230/model/approve_product.dart';
import 'package:project_pairs_251230/util/approve_status.dart';
import 'package:project_pairs_251230/util/global_data.dart';
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

  late List<String> _productNameList;
  late List<Approval> _approveList;

  int _empolyeeId = 1;

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
      body: Row(
        children: [
          AdminSideBar(
            selectedMenu: SideMenu.procure,
            onMenuSelected: (menu) {},
          ),

          Expanded(
            child: SizedBox(
              width:  double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      '품의 리스트',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 8),
                        ElevatedButton(onPressed: () {
                          Get.to(AdminApprovalRequest());
                        }, child: Text('새 품의')),
                    SizedBox(height: 8),
                    _buildHead(),
                    SizedBox(height: 8),
                    Expanded(child: _approveList.isEmpty
                        ? Center(child: Text('품의 내역이 없습니다.'))
                        : ListView.builder(
                            itemCount: _approveList.length,
                            itemBuilder: (context, index) =>
                                _buildApprovalCard(index),
                          ),)
                    
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  } // build

  // === Widgets ===

  Widget _buildApprovalCard(int index)
  {
    return Card(
      child: Row(
        children: [
          SizedBox(
          width: MediaQuery.of(context).size.width * 0.05,
          child: Center(child: Text(_approveList[index].approvalId.toString(), style: headerStyle()))
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.2,
          child: Center(child: Text('${_approveList[index].approvalProductName} ${_approveList[index].approvalProductQty}개', style: headerStyle()))
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.05,
          child: Center(child: Text(_approveList[index].approvalemplyeeName, style: headerStyle()))
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.05,
          child: Center(child: Text(_approveList[index].approvalemplyeeSeniorName, style: headerStyle()))
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.05,
          child: Center(child: Text(_approveList[index].approvalemplyeeDirectorName, style: headerStyle()))
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.1,
          child: Center(child: Text(_approveList[index].approvalDate.toString().substring(0,10), style: headerStyle()))
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.1,
          child: Center(child: Text(_approveList[index].approvalSeniorAssignDate.toString(), style: headerStyle()))
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.1,
          child: Center(child: Text(_approveList[index].approvalDirectorAssignDate.toString(), style: headerStyle()))
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.1,
          child: Center(child: Text(_approveList[index].status.toString(), style: headerStyle()))
        )
        ],
      ),
    );
  }

  Widget _buildHead() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.05,
          child: Center(child: Text('품의 번호', style: headerStyle()))
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.2,
          child: Center(child: Text('품의 내용', style: headerStyle()))
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.05,
          child: Center(child: Text('품의자 ', style: headerStyle()))
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.05,
          child: Center(child: Text('팀장 ', style: headerStyle()))
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.05,
          child: Center(child: Text('임원 ', style: headerStyle()))
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.1,
          child: Center(child: Text('품의일 ', style: headerStyle()))
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.1,
          child: Center(child: Text('팀장 승인일 ', style: headerStyle()))
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.1,
          child: Center(child: Text('임원 승인일 ', style: headerStyle()))
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.1,
          child: Center(child: Text('품의 상태', style: headerStyle()))
        ),
      ],
    );
  }

  TextStyle headerStyle() {
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
      color: Colors.grey,
    );
  }

  TextStyle bodyStyle() {
    return TextStyle(
      fontSize: 12,
      color: Colors.black,
    );
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
  Future<int> getStockData(int productId) async {
    var url = Uri.parse('$_stockUrl/$productId');
    var response = await http.get(url);

    print(response.body);

    if (response.statusCode == 200) {
      var dataConvertedData = json.decode(
        utf8.decode(response.bodyBytes),
      );
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

  Future getApprovalData() async {
    var url = Uri.parse('$_approveUrl/$_empolyeeId');
    var response = await http.get(url);

    print(response.body);

    if (response.statusCode == 200) {
      _approveList.clear();
      _productNameList.clear();
      var dataConvertedData = json.decode(
        utf8.decode(response.bodyBytes),
      );
      List results = dataConvertedData['results'];
      print('$results / len : ${results.length}');

      for (var item in results) {
        Approval product = Approval(
          approvalId:  item['approve_id'],
          approvalProductID: item['approve_product_id'], 
          approvalProductName: item['product_name'], 
          approvalProductQty: item['approve_quantity'], 
          employeeId: item['approve_employee_id'], 
          seniorEmployeeId: item['approve_senior_id'], 
          directorEmployeeId: item['approve_director_id'], 
          approvalemplyeeName: item['approve_employee_name'], 
          approvalemplyeeSeniorName: item['approve_senior_name'], 
          approvalemplyeeDirectorName: item['approve_director_name'], 
          approvalDate: item['approve_date'], 
          approvalSeniorAssignDate: item['approve_senior_assign_date'] ?? "", 
          approvalDirectorAssignDate: item['approve_director_assign_date']??"", 
          status: item['approve_status']);
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