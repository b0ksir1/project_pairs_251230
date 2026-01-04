import 'dart:async';
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

  int? _ordersId;
  int? _productId;
  Future<int?>? _imageIdFuture;

  Timer? _returnTimer;

  int? _customerId;
  int? _storeId;
  bool _metaLoading = false;

  // null = 반품 없음
  // 0 = 반품 대기
  // 1 = 반품 완료
  int? _returnStatus;
  bool _returnLoading = false;

  @override
  void initState() {
    super.initState();

    args = ((Get.arguments ?? {}) as Map).cast<String, dynamic>();

    _ordersId = _toInt(args['orders_id'] ?? args['ordersId']);
    _productId = _toInt(
      args['orders_product_id'] ?? args['ordersProductId'],
    );

    _customerId = _toInt(
      args['orders_customer_id'] ??
          args['ordersCustomerId'] ??
          args['customer_id'] ??
          args['customerId'],
    );

    _storeId = _toInt(
      args['orders_store_id'] ??
          args['ordersStoreId'] ??
          args['store_id'] ??
          args['storeId'],
    );

    print("OrderDetail args: $args");
    print(
      "ordersId=$_ordersId customerId=$_customerId storeId=$_storeId",
    );

    _startReturnPolling();

    if (_ordersId != null &&
        (_customerId == null || _storeId == null)) {
      _fetchOrderMetaFromSelect(_ordersId!);
    } else {
      _refreshReturnStatus();
    }

    _imageIdFuture = _fetchMainImageId(_productId);
  }

  @override
  void dispose() {
    _returnTimer?.cancel();
    super.dispose();
  }

  void _startReturnPolling() {
    _returnTimer?.cancel();
    _returnTimer = Timer.periodic(Duration(seconds: 5), (_) async {
      await _refreshReturnStatus();
      if (_returnStatus == 1) {
        _returnTimer?.cancel();
      }
    });
  }

  int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  String _formatDate(dynamic v) {
    if (v == null) return "-";
    String s = v.toString();

    if (s.contains('T')) s = s.split('T')[0];
    if (s.contains(' ')) s = s.split(' ')[0];

    final parts = s.split('-');
    if (parts.length == 3) {
      return "${parts[0]}.${parts[1]}.${parts[2]}";
    }
    return s;
  }

  String _comma(int n) {
    return n.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => ',',
    );
  }

  String _won(int n) => "${_comma(n)}원";

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

  String _returnText(int? status) {
    if (status == 0) return "반품 대기중";
    if (status == 1) return "반품 완료";
    return "반품 없음";
  }

  Color _returnColor(int? status) {
    if (status == 0) return Color(0xFFDC2626);
    if (status == 1) return Color(0xFF16A34A);
    return Color(0xFF6B7280);
  }

  Future<int?> _fetchMainImageId(int? productId) async {
    if (productId == null) return null;

    final uri = Uri.parse("$urlPath/images/select/$productId");
    final res = await http.get(uri);

    if (res.statusCode != 200) return null;

    final decoded = jsonDecode(utf8.decode(res.bodyBytes));
    final results = decoded['results'];

    if (results is! List || results.isEmpty) return null;

    final last = results.last;
    return _toInt(last['images_id']);
  }

  Widget _imgPlaceholder(IconData icon) {
    return Container(
      color: Color(0xFFE5E7EB),
      child: Center(child: Icon(icon, color: Colors.grey)),
    );
  }

  Widget _buildHistoryImageFirst() {
    if (_ordersId != null) {
      return Image.network(
        "$urlPath/images/view/$_ordersId",
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Color(0xFFE5E7EB),
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildProductFallbackImage();
        },
      );
    }

    return _buildProductFallbackImage();
  }

  Widget _buildProductFallbackImage() {
    if (_imageIdFuture == null) {
      return _imgPlaceholder(Icons.image);
    }

    return FutureBuilder<int?>(
      future: _imageIdFuture,
      builder: (context, snapshot) {
        final imageId = snapshot.data;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: Color(0xFFE5E7EB),
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (imageId == null) {
          return _imgPlaceholder(Icons.image);
        }

        return Image.network(
          "$urlPath/images/view/$imageId",
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _imgPlaceholder(Icons.broken_image);
          },
        );
      },
    );
  }

  Future<void> _refreshReturnStatus() async {
    if (_ordersId == null || _customerId == null) return;

    try {
      if (!mounted) return;
      _returnLoading = true;
      setState(() {});

      final uri = Uri.parse(
        "$urlPath/returns/selectByCustomer/$_customerId",
      );
      final res = await http.get(uri);

      if (res.statusCode != 200) return;

      final decoded = jsonDecode(utf8.decode(res.bodyBytes));
      final results = decoded["results"];

      int? foundStatus;

      if (results is List) {
        for (final item in results) {
          if (item is Map) {
            final oid = _toInt(item["returns_orders_id"]);
            if (oid == _ordersId) {
              foundStatus = _toInt(item["returns_status"]);
              break;
            }
          }
        }
      }

      if (!mounted) return;
      _returnStatus = foundStatus;
      setState(() {});
    } catch (e) {
      print("refresh return status error: $e");
    } finally {
      if (!mounted) return;
      _returnLoading = false;
      setState(() {});
    }
  }

  Future<void> _fetchOrderMetaFromSelect(int ordersId) async {
    try {
      if (!mounted) return;
      _metaLoading = true;
      setState(() {});

      final uri = Uri.parse("$urlPath/orders/select");
      final res = await http.get(uri);

      print("orders/select status: ${res.statusCode}");
      print("orders/select body: ${utf8.decode(res.bodyBytes)}");

      if (res.statusCode != 200) return;

      final decoded = jsonDecode(utf8.decode(res.bodyBytes));
      final results = decoded['results'];

      if (results is! List) return;

      Map<String, dynamic>? found;
      for (final item in results) {
        if (item is Map) {
          final id = _toInt(item['orders_id']);
          if (id == ordersId) {
            found = Map<String, dynamic>.from(item);
            break;
          }
        }
      }

      if (found == null) {
        print("orders/select: orders_id=$ordersId not found");
        return;
      }

      _customerId = _toInt(found['orders_customer_id']);
      _storeId = _toInt(found['orders_store_id']);

      print("meta loaded: customerId=$_customerId storeId=$_storeId");

      if (!mounted) return;
      setState(() {});

      await _refreshReturnStatus();
    } catch (e) {
      print("meta fetch error: $e");
    } finally {
      if (!mounted) return;
      _metaLoading = false;
      setState(() {});
    }
  }

  Future<void> _showReturnDialogAndSend({
    required int? ordersId,
    required int? customerId,
    required int? storeId,
  }) async {
    if (_returnStatus != null) {
      Get.snackbar("반품 요청", "이미 해당 주문은 반품 요청이 접수되어 있어요.");
      return;
    }

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
          "returns_employee_id": "0",
          "returns_description": desc,
          "returns_orders_id": ordersId.toString(),
          "store_store_id": storeId.toString(),
        },
      );

      print("returns/insert status: ${res.statusCode}");
      print("returns/insert body: ${utf8.decode(res.bodyBytes)}");

      if (res.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));

        if (decoded["results"] == "OK") {
          _returnStatus = 0;
          if (mounted) setState(() {});
          Get.snackbar("반품 요청", "반품 요청이 접수되었습니다.");
          return;
        }

        if (decoded["results"] == "Error") {
          final msg = (decoded["message"] ?? "").toString();

          if (msg.contains("이미") || msg.contains("접수")) {
            _returnStatus = 0;
            if (mounted) setState(() {});
            Get.snackbar("반품 요청", msg);
            return;
          }

          Get.snackbar("반품 요청", msg.isEmpty ? "요청 실패" : msg);
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

    final int? ordersId = _ordersId;
    final int? customerId = _customerId;
    final int? storeId = _storeId;

    final bool canReturn =
        !_metaLoading &&
        ordersId != null &&
        customerId != null &&
        storeId != null;

    final bool alreadyReturned = (_returnStatus != null);

    String statusLabel;
    Color statusColor;

    if (_returnLoading) {
      statusLabel = "반품 상태 확인중";
      statusColor = Color(0xFF6B7280);
    } else if (_returnStatus != null) {
      statusLabel = _returnText(_returnStatus);
      statusColor = _returnColor(_returnStatus);
    } else {
      statusLabel = _statusText(ordersStatus);
      statusColor = _statusColor(ordersStatus);
    }

    final String returnBtnText = _returnLoading
        ? "확인중..."
        : (_returnStatus == 0
              ? "반품 대기중"
              : _returnStatus == 1
              ? "반품 완료"
              : _metaLoading
              ? "로딩중..."
              : "반품 요청");

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
                          statusLabel,
                          valueColor: statusColor,
                          valueWeight: FontWeight.w800,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
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
                                child: _buildHistoryImageFirst(),
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
                      onPressed: (!canReturn || alreadyReturned)
                          ? () {
                              if (_returnLoading) {
                                Get.snackbar(
                                  "반품 요청",
                                  "반품 상태 확인중입니다.",
                                );
                                return;
                              }
                              if (alreadyReturned) {
                                Get.snackbar(
                                  "반품 요청",
                                  "이미 해당 주문은 반품 요청이 접수되어 있어요.",
                                );
                                return;
                              }
                              if (_metaLoading) {
                                Get.snackbar(
                                  "반품 요청",
                                  "주문 정보를 불러오는 중입니다. 잠시만요.",
                                );
                                return;
                              }
                              Get.snackbar(
                                "반품 요청",
                                "주문 정보가 부족해서 반품 요청을 보낼 수 없어요.",
                              );
                            }
                          : () async {
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
                        returnBtnText,
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
