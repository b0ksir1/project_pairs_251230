import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:project_pairs_251230/util/app_bottom_nav.dart';
import 'package:project_pairs_251230/util/global_data.dart';

class OrderDetail extends StatefulWidget {
  const OrderDetail({super.key});

  @override
  State<OrderDetail> createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  final String urlPath = GlobalData.url;

  late final Map<String, dynamic> args;

  // 이미지 불러오기 위해 필요 (orders_product_id)
  int? _productId;
  Future<int?>? _imageIdFuture;

  @override
  void initState() {
    super.initState();

    //  Get.arguments가 null일 수도 있으니 안전하게 빈 Map 처리
    args = ((Get.arguments ?? {}) as Map).cast<String, dynamic>();

    //  productId 키가 여러 방식으로 올 수 있어서(팀원마다 이름 다를 수 있음) 다 받아줌
    _productId = _toInt(
      args['orders_product_id'] ?? args['ordersProductId'],
    );

    //  상품의 대표 이미지 id 조회 (없으면 null)
    _imageIdFuture = _fetchMainImageId(_productId);
  }

  // ------------------------------
  // 1) 숫자 변환: dynamic -> int?
  // ------------------------------
  int? _toInt(dynamic v) {
    // 값이 아예 없으면(null) 그대로 null 반환
    if (v == null) return null;

    // 이미 int 타입이면 변환할 필요 없이 그대로 반환
    if (v is int) return v;

    // String("123") 같은 형태로 들어오면 int로 변환 시도
    // 변환 실패("abc")하면 null 반환 (에러 안 나게 안전처리)
    return int.tryParse(v.toString());
  }

  // 2) 날짜 포맷: 서버 날짜 -> "yyyy.MM.dd"
  String _formatDate(dynamic v) {
    // 값이 없으면 화면에 '-' 표시
    if (v == null) return "-";

    // 어떤 타입이든 문자열로 변환해서 처리
    String s = v.toString();

    // 서버에서 날짜가 이런 형태로 올 수 있음:
    //  - "2026-01-04T12:30:00" (ISO 형식)
    //  - "2026-01-04 12:30:00" (MySQL datetime 형식)
    //
    if (s.contains('T'))
      s = s.split('T')[0]; // "2026-01-04T..." -> "2026-01-04"
    if (s.contains(' '))
      s = s.split(' ')[0]; // "2026-01-04 12..." -> "2026-01-04"

    // "2026-01-04" -> "2026.01.04" 로 바꾸기
    final parts = s.split('-');
    if (parts.length == 3) {
      return "${parts[0]}.${parts[1]}.${parts[2]}";
    }

    // 예상한 형식이 아니면 원본 그대로 보여주기(깨지지 않게)
    return s;
  }

  // ---------------------------------------
  // 3) 숫자 콤마: 139000 -> "139,000"
  // ---------------------------------------
  String _comma(int n) {
    // 숫자를 문자열로 바꾸고, 정규식으로 3자리마다 콤마 추가
    // 예) 139000 -> 139,000
    return n.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => ',',
    );
  }
  //추가적으로 헷갈리지않게 다음에는 패키지 사용

  String _won(int n) => "${_comma(n)}원";

  //  주문 상태 int -> 텍스트
  String _statusText(int? status) {
    switch (status) {
      case 0:
        return "픽업 요청";
      case 1:
        return "픽업 완료";
      case 2:
        return "반품 요청";
      case 3:
        return "반품 완료";
      default:
        return "상태 미정";
    }
  }

  //  주문 상태 int -> 색상
  Color _statusColor(int? status) {
    switch (status) {
      case 1:
        return Color(0xFF16A34A);
      case 0:
        return Color(0xFF2563EB);
      case 2:
        return Color(0xFFDC2626);
      default:
        return Color(0xFF6B7280);
    }
  }

  //  images/select/{productId} 로 이미지 id 리스트를 받아서
  //  마지막(최신) images_id를 골라서 반환
  Future<int?> _fetchMainImageId(int? productId) async {
    if (productId == null) return null;

    final uri = Uri.parse("$urlPath/images/select/$productId");
    final res = await http.get(uri);

    if (res.statusCode != 200) return null;

    final decoded = jsonDecode(utf8.decode(res.bodyBytes));
    final results = decoded['results'];

    if (results is! List || results.isEmpty) return null;

    // 최신 이미지(마지막) 사용
    final last = results.last;
    return _toInt(last['images_id']);
  }

  //  반품 요청 다이얼로그 + 서버 전송(returns/insert)
  Future<void> _showReturnDialogAndSend({
    required int? ordersId,
    required int? customerId,
    required int? storeId,
  }) async {
    final controller = TextEditingController();

    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "반품 요청",
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "반품 사유를 입력해주세요.",
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "예) 사이즈가 맞지 않아요",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("취소"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("요청"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final desc = controller.text.trim();
    if (desc.isEmpty) {
      Get.snackbar("반품 요청", "반품 사유를 입력해주세요.");
      return;
    }

    //  returns 테이블 insert에 필요한 값 체크
    // returns_customer_id, returns_employee_id, returns_description,
    // returns_orders_id, store_store_id
    //
    // 여기서 employee_id는 고객 화면에서는 보통 없어서 0으로 넣는 방식(팀 규칙 필요)
    // 만약 DB에서 NOT NULL이면 0/1 같은 기본값이라도 있어야 함
    if (ordersId == null || customerId == null || storeId == null) {
      Get.snackbar("반품 요청", "주문 정보가 부족해서 반품 요청을 보낼 수 없어요.");
      return;
    }

    final uri = Uri.parse("$urlPath/returns/insert");

    try {
      final res = await http.post(
        uri,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "returns_customer_id": customerId.toString(),
          "returns_employee_id": "0", //  고객 화면에서 임시값(팀 규칙 정해지면 수정)
          "returns_description": desc,
          "returns_orders_id": ordersId.toString(),
          "store_store_id": storeId.toString(),
        },
      );

      if (res.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));
        if (decoded["results"] == "OK") {
          Get.snackbar("반품 요청", "반품 요청이 접수되었습니다.");
          return;
        }
      }

      Get.snackbar("반품 요청", "요청 실패. 서버 응답을 확인해주세요.");
    } catch (e) {
      Get.snackbar("반품 요청", "네트워크 오류: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    //  args에서 화면에 필요한 값들 꺼내기 (키 이름이 다를 수 있어 여러 후보 처리)
    final String orderNumber =
        (args['orders_number'] ?? args['ordersNumber'] ?? "-")
            .toString();
    final String orderDate = _formatDate(
      args['orders_date'] ?? args['ordersDate'],
    );

    final int? ordersStatus = _toInt(
      args['orders_status'] ?? args['ordersStatus'],
    );

    final String productName =
        (args['product_name'] ?? args['productName'] ?? "-")
            .toString();

    final String sizeName =
        (args['size_name'] ?? args['sizeName'] ?? "-").toString();

    final int qty =
        _toInt(args['orders_quantity'] ?? args['ordersQty']) ?? 0;

    final int price =
        _toInt(args['product_price'] ?? args['productPrice']) ?? 0;

    final String payMethod =
        (args['orders_payment'] ?? args['ordersPayment'] ?? "-")
            .toString();

    final String storeName =
        (args['store_name'] ?? args['storeName'] ?? "-").toString();

    final int total = price * qty;

    //  반품 insert에 필요한 값들 (orders_id, customer_id, store_id)
    final int? ordersId = _toInt(
      args['orders_id'] ?? args['ordersId'],
    );
    final int? customerId = _toInt(
      args['orders_customer_id'] ??
          args['ordersCustomerId'] ??
          args['customer_id'] ??
          args['customerId'],
    );
    final int? storeId = _toInt(
      args['orders_store_id'] ??
          args['ordersStoreId'] ??
          args['store_id'] ??
          args['storeId'],
    );

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
          "결제 상세 내역",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Column(
                children: [
                  SizedBox(height: 5),

                  // ===================== 주문 정보 =====================
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(30),
                    decoration: BoxDecoration(color: Colors.white),
                    child: Column(
                      children: [
                        _infoRow("주문 번호", orderNumber),
                        SizedBox(height: 10),
                        _infoRow("주문 일자", orderDate),
                        SizedBox(height: 10),
                        _infoRow(
                          "주문 상태",
                          _statusText(ordersStatus),
                          valueColor: _statusColor(ordersStatus),
                          valueWeight: FontWeight.w800,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 10),

                  // ===================== 구매 상품 =====================
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "구매 상품",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                width: 64,
                                height: 64,
                                child: FutureBuilder<int?>(
                                  future: _imageIdFuture,
                                  builder: (context, snapshot) {
                                    final imageId = snapshot.data;

                                    //  로딩 중
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Container(
                                        color: Color(0xFFE5E7EB),
                                        child: Center(
                                          child: SizedBox(
                                            width: 18,
                                            height: 18,
                                            child:
                                                CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                ),
                                          ),
                                        ),
                                      );
                                    }

                                    //  이미지 없음(또는 에러)
                                    if (imageId == null) {
                                      return Container(
                                        color: Color(0xFFE5E7EB),
                                        child: Icon(
                                          Icons.image,
                                          color: Colors.grey,
                                        ),
                                      );
                                    }

                                    //  이미지 보여주기
                                    return Image.network(
                                      "$urlPath/images/view/$imageId",
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Container(
                                              color: Color(
                                                0xFFE5E7EB,
                                              ),
                                              child: Icon(
                                                Icons.broken_image,
                                                color: Colors.grey,
                                              ),
                                            );
                                          },
                                    );
                                  },
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    productName,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    "사이즈: $sizeName",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B7280),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "수량: $qty",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B7280),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              _won(price),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 10),

                  // ===================== 결제 정보 =====================
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "결제 정보",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 12),
                        _infoRow(
                          "총 결제 금액",
                          _won(total),
                          valueWeight: FontWeight.w900,
                        ),
                        SizedBox(height: 10),
                        _infoRow("결제 수단", payMethod),
                      ],
                    ),
                  ),

                  SizedBox(height: 10),

                  // ===================== 픽업 정보 =====================
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "픽업 정보",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "픽업 매장",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          storeName,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 12),
                ],
              ),
            ),
          );
        },
      ),

      // ===================== 하단 버튼 + 네비 =====================
      bottomNavigationBar: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.snackbar("문의하기", "문의하기 버튼 클릭");
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size.fromHeight(52),
                        side: BorderSide(color: Color(0xFFE5E7EB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        "문의하기",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        //  반품 요청 버튼 누르면 사유 입력받고 returns/insert로 전송
                        await _showReturnDialogAndSend(
                          ordersId: ordersId,
                          customerId: customerId,
                          storeId: storeId,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        minimumSize: Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        "반품 요청",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppBottomNav(),
          ],
        ),
      ),
    );
  }

  //  공통 라벨/값 UI
  Widget _infoRow(
    String label,
    String value, {
    Color valueColor = Colors.black,
    FontWeight valueWeight = FontWeight.w700,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                color: valueColor,
                fontWeight: valueWeight,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
