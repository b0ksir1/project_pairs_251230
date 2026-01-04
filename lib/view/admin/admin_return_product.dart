import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:project_pairs_251230/util/global_data.dart';
import 'package:project_pairs_251230/util/message.dart';
import 'package:project_pairs_251230/view/admin/admin_side_bar.dart';
import 'package:project_pairs_251230/util/side_menu.dart';

class AdminReturnProduct extends StatefulWidget {
  const AdminReturnProduct({super.key});

  @override
  State<AdminReturnProduct> createState() =>
      _AdminReturnProductState();
}

class _AdminReturnProductState extends State<AdminReturnProduct> {
  final String urlPath = GlobalData.url;

  // returns/selectAdmin
  late final String _returnsAdminUrl;
  // returns/updateStatus
  late final String _returnsUpdateStatusUrl;

  Message message = Message();

  List<Map<String, dynamic>> _list = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _returnsAdminUrl = "$urlPath/returns/selectAdmin";
    _returnsUpdateStatusUrl = "$urlPath/returns/updateStatus";
    _fetchReturns();
  }

  // ----------------------------
  // API: 관리자 반품 리스트 조회
  // ----------------------------
  Future<void> _fetchReturns() async {
    setState(() => _loading = true);
    try {
      final uri = Uri.parse(_returnsAdminUrl);
      final res = await http.get(uri);

      if (res.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));
        final results = decoded['results'];

        if (results is List) {
          _list = results.cast<Map<String, dynamic>>();
        } else {
          _list = [];
        }
      } else {
        _list = [];
        message.errorSnackBar("조회 실패", "서버 상태코드: ${res.statusCode}");
      }
    } catch (e) {
      _list = [];
      message.errorSnackBar("네트워크 오류", e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  // ----------------------------
  // API: 상태 변경 (0 대기 / 1 완료)
  // ----------------------------
  Future<bool> _updateStatus({
    required int returnsId,
    required int status,
  }) async {
    try {
      final uri = Uri.parse(_returnsUpdateStatusUrl);
      final res = await http.post(
        uri,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "returns_id": returnsId.toString(),
          "returns_status": status.toString(),
        },
      );

      if (res.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));
        return decoded["results"] == "OK";
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // ----------------------------
  // util
  // ----------------------------
  int _toInt(dynamic v, {int fallback = 0}) {
    if (v == null) return fallback;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? fallback;
  }

  String _toStr(dynamic v, {String fallback = "-"}) {
    if (v == null) return fallback;
    final s = v.toString();
    if (s.trim().isEmpty) return fallback;
    return s;
  }

  String _formatDate(dynamic v) {
    if (v == null) return "-";
    String s = v.toString();
    if (s.contains('T')) s = s.split('T')[0];
    if (s.contains(' ')) s = s.split(' ')[0];
    final parts = s.split('-');
    if (parts.length == 3)
      return "${parts[0]}.${parts[1]}.${parts[2]}";
    return s;
  }

  String _comma(int n) {
    return n.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => ',',
    );
  }

  String _won(int n) => "${_comma(n)}원";

  String _statusText(int status) {
    // 0: 대기중, 1: 완료
    if (status == 1) return "반품 완료";
    return "대기중";
  }

  Color _statusColor(int status) {
    if (status == 1) return Colors.green;
    return Colors.orange;
  }

  // ----------------------------
  // 상세 다이얼로그
  // ----------------------------
  void _openDetail(Map<String, dynamic> item) {
    final int returnsId = _toInt(item["returns_id"]);
    final int status = _toInt(item["returns_status"]);
    final int imagesId = _toInt(item["images_id"], fallback: 0);

    final String customerName = _toStr(item["customer_name"]);
    final String storeName = _toStr(item["store_name"]);
    final String ordersNumber = _toStr(item["orders_number"]);
    final String ordersDate = _formatDate(item["orders_date"]);
    final String returnsDate = _formatDate(
      item["returns_create_date"],
    );

    final String productName = _toStr(item["product_name"]);
    final String sizeName = _toStr(item["size_name"]);
    final int qty = _toInt(item["orders_quantity"]);
    final int totalPrice = _toInt(item["total_price"]);

    final String desc = _toStr(
      item["returns_description"],
      fallback: "",
    );

    Get.defaultDialog(
      title: "반품 상세",
      titleStyle: TextStyle(fontWeight: FontWeight.w900),
      content: SizedBox(
        width: 520,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _kv("반품 번호", returnsId.toString()),
            _kv("반품 일자", returnsDate),
            _kv(
              "상태",
              _statusText(status),
              valueColor: _statusColor(status),
            ),
            Divider(height: 18),

            _kv("고객명", customerName),
            _kv("매장", storeName),
            _kv("주문번호", ordersNumber),
            _kv("주문일자", ordersDate),
            Divider(height: 18),

            Text(
              "상품 정보",
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: imagesId == 0
                        ? Container(
                            color: Color(0xFFE5E7EB),
                            child: Icon(
                              Icons.image,
                              color: Colors.grey,
                            ),
                          )
                        : Image.network(
                            "$urlPath/images/view/$imagesId",
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) {
                              return Container(
                                color: Color(0xFFE5E7EB),
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "사이즈: $sizeName",
                        style: TextStyle(color: Colors.black54),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "수량: $qty",
                        style: TextStyle(color: Colors.black54),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "총 구매금액: ${_won(totalPrice)}",
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(height: 18),

            Text(
              "반품 사유",
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                desc.isEmpty ? "-" : desc,
                style: TextStyle(color: Colors.black87),
              ),
            ),
            SizedBox(height: 16),

            // 완료 처리 버튼 (이미 완료면 비활성)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: status == 1
                        ? null
                        : () async {
                            final ok = await _updateStatus(
                              returnsId: returnsId,
                              status: 1,
                            );

                            if (ok) {
                              Get.back();
                              message.successSnackBar(
                                "완료 처리",
                                "반품 상태가 완료로 변경되었습니다.",
                              );
                              await _fetchReturns();
                            } else {
                              message.errorSnackBar(
                                "실패",
                                "상태 변경에 실패했습니다.",
                              );
                            }
                          },
                    child: Text("반품 완료 처리"),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    child: Text("닫기"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v, {Color valueColor = Colors.black}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              k,
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              v,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------
  // UI
  // ----------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AdminSideBar(
            selectedMenu: SideMenu.procure, // 너희 메뉴 구조에 맞게 변경 가능
            onMenuSelected: (menu) {},
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "반품 내역",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Spacer(),
                      ElevatedButton.icon(
                        onPressed: _fetchReturns,
                        icon: Icon(Icons.refresh),
                        label: Text("새로고침"),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  _buildHeader(),

                  SizedBox(height: 8),

                  Expanded(
                    child: _loading
                        ? Center(child: CircularProgressIndicator())
                        : _list.isEmpty
                        ? Center(child: Text("반품 내역이 없습니다."))
                        : ListView.builder(
                            itemCount: _list.length,
                            itemBuilder: (context, index) {
                              final item = _list[index];
                              return _buildRow(item);
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _headCell("반품번호", flex: 1),
          _headCell("고객", flex: 2),
          _headCell("상품", flex: 3),
          _headCell("요청일", flex: 2),
          _headCell("상태", flex: 2),
          _headCell("총금액", flex: 2),
        ],
      ),
    );
  }

  Widget _buildRow(Map<String, dynamic> item) {
    final int returnsId = _toInt(item["returns_id"]);
    final String customerName = _toStr(item["customer_name"]);
    final String productName = _toStr(item["product_name"]);
    final String reqDate = _formatDate(item["returns_create_date"]);
    final int status = _toInt(item["returns_status"]);
    final int totalPrice = _toInt(item["total_price"]);

    return InkWell(
      onTap: () => _openDetail(item),
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 6),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          child: Row(
            children: [
              _cell(returnsId.toString(), flex: 1),
              _cell(customerName, flex: 2),
              _cell(productName, flex: 3),
              _cell(reqDate, flex: 2),
              _cell(
                _statusText(status),
                flex: 2,
                textColor: _statusColor(status),
                fontWeight: FontWeight.w900,
              ),
              _cell(
                _won(totalPrice),
                flex: 2,
                fontWeight: FontWeight.w900,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headCell(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _cell(
    String text, {
    required int flex,
    Color textColor = Colors.black87,
    FontWeight fontWeight = FontWeight.w700,
  }) {
    return Expanded(
      flex: flex,
      child: Center(
        child: Text(
          text,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: textColor, fontWeight: fontWeight),
        ),
      ),
    );
  }
}
