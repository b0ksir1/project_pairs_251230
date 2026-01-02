import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:project_pairs_251230/model/store.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:project_pairs_251230/util/message.dart';
import 'package:project_pairs_251230/view/payment/payment_map.dart';
// import 'package:shoes_store_app_project/model/product_model.dart';
// import 'package:shoes_store_app_project/view/shop_select.dart';

// ------------------------------------------------------------------
// 주의: 아래 import 경로는 실제 프로젝트 구조에 맞게 수정해야 합니다.
// ------------------------------------------------------------------
// import '../util/controllers.dart';
// import '../models/product_model.dart';
// import 'shop_screen.dart'; // ShopSelectionScreen 위젯 경로
// ------------------------------------------------------------------

class PaymentOptions extends StatefulWidget {
  const PaymentOptions({super.key});

  @override
  State<PaymentOptions> createState() => _PaymentOptionsState();
}

class _PaymentOptionsState extends State<PaymentOptions> {
  // Property
  final urlPath = 'http://172.16.250.179:8000'; // 자기 ip
  late List<Store> storeData; // 매장 data저장
  late int product_id;
  late String product_name;
  late int product_size;
  late int product_price;
  late int product_image_seq;
  late int customer_id;
  late String customer_address;
  var value = Get.arguments ?? "__"; // 0. 상품id , 1. 상품이름 , 2. 선택한 사이즈 ,
  // 3. 상품가격 , 4. 이미지 seq번호 , 5. 고객id , 6. 고객 주소
  Message message = Message();

  // 상태 관리 변수
  Store? _selectedStore;
  String? _selectedPaymentMethod;
  latlng.LatLng? _userPos;

  // 더미 데이터: 결제 수단
  final List<String> _paymentMethods = ['신용/체크카드', '픽업결제'];

  @override
  void initState() {
    super.initState();
    product_id = value[0];
    product_name = value[1];
    product_size = value[2];
    product_price = value[3];
    product_image_seq = value[4];
    customer_id = value[5];
    customer_address = value[6];
    storeData = [];
    getStoredata();
  }

  // 매장 선택 지도로 이동하는 함수 (ShopSelectionScreen에서 결과 받아옴)
  // void _openStoreMap() async {
  //   final selectedStoreMap = await Navigator.push(
  //     // context,
  //     // MaterialPageRoute(builder: (context) => const ShopSelectionScreen()),
  //   );

  //   // 결과가 StoreModel 타입의 Map으로 돌아왔다면 상태 업데이트
  //   if (selectedStoreMap != null && selectedStoreMap is Map<String, dynamic>) {
  //     setState(() {
  //       _selectedStore = Store.fromMap(selectedStoreMap);
  //     });
  //     Get.snackbar("알림", "${_selectedStore!.name}이(가) 픽업 매장으로 선택되었습니다.",
  //       snackPosition: SnackPosition.BOTTOM,
  //       backgroundColor: Colors.blue.withOpacity(0.9),
  //       colorText: Colors.white,
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // // 만약 상품 정보가 없다면 에러 처리
    // if (lastProduct == null) {
    //   return Scaffold(
    //     appBar: _buildAppBar(context),
    //     body: const Center(child: Text("주문할 상품 정보가 없습니다.")),
    //   );
    // }

    // 합계 금액 계산 (CartController에서 price는 int로 저장됨)
    final double totalPrice = product_price.toDouble();

    // 가격 포맷
    final priceFormatter = NumberFormat('#,###', 'ko_KR');
    final formattedPrice = priceFormatter.format(totalPrice);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. 선택 상품 정보
                  _buildProductInfo(),
                  const Divider(height: 40),

                  // 2. 픽업 매장 선택
                  _buildStoreSelector(),
                  const Divider(height: 40),

                  // 3. 결제 수단 선택
                  _buildPaymentSelector(),
                  const Divider(height: 40),

                  // 4. 합계 금액
                  _buildTotalPrice(formattedPrice),
                ],
              ),
            ),
          ),
          // 5. 하단 결제하기 버튼
          _buildBottomCheckoutButton(totalPrice, formattedPrice),
        ],
      ),
    );
  }

  // 앱바 (오른쪽 닫기 버튼 포함)
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        "결제하기",
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Get.back(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ],
    );
  }

  // 1. 선택 상품 정보 위젯
  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "주문 상품",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // 상품 이미지
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(
                    '$urlPath/images/view/$product_image_seq?t=${DateTime.now().millisecondsSinceEpoch}',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 상품 이름, 사이즈
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product_name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$product_size 사이즈 | $product_price",
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 2. 픽업 매장 선택 위젯
  Widget _buildStoreSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "픽업 매장 선택",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () async {
                // 여기가 클릭하면 지도 나오는곳
                Get.to(
                  PaymentMap(),
                  arguments: [
                    storeData, // 매장데이터
                    _userPos, // 고객 위치데이터
                    _selectedStore, // 선택한 매장
                  ],
                )!.then((value) {
                  _selectedStore = value;
                  setState(() {});
                });
              },
              icon: const Icon(Icons.map_outlined, size: 18),
              label: const Text("다른 매장 선택", style: TextStyle(fontSize: 14)),
              style: TextButton.styleFrom(foregroundColor: Colors.black),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_selectedStore != null) _buildStoreTile(_selectedStore!),
      ],
    );
  }

  // 개별 매장 타일 위젯
  Widget _buildStoreTile(Store store) {
    final meter =
        (_userPos == null) // meter변환
        ? null
        : latlng.Distance()(
            _userPos!,
            latlng.LatLng(store.store_lat, store.store_lng),
          );

    final km = meter == null ? null : meter / 1000.0; // km 변환

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.storefront, color: Colors.black),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store.store_name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  store.store_phone,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            km == null ? "-" : "${km.toStringAsFixed(1)}km",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // 3. 결제 수단 선택 위젯
  Widget _buildPaymentSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "결제 수단 선택",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._paymentMethods.map((method) {
          final isSelected = _selectedPaymentMethod == method;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ListTile(
              onTap: () {
                setState(() {
                  _selectedPaymentMethod = method;
                });
              },
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: isSelected ? Colors.black : Colors.grey,
              ),
              title: Text(method),
              trailing: const Icon(
                Icons.keyboard_arrow_right,
                color: Colors.grey,
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  // 4. 합계 금액 위젯
  Widget _buildTotalPrice(String formattedPrice) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "상품 금액",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Text("$formattedPrice원", style: const TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("배송비", style: TextStyle(fontSize: 16, color: Colors.grey)),
              Text(
                "무료",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "최종 결제 금액",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                "$formattedPrice원",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 5. 하단 결제하기 버튼
  Widget _buildBottomCheckoutButton(double totalPrice, String formattedPrice) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              if (_selectedStore == null) {
                Get.snackbar("경고", "픽업 매장을 선택해주세요.");
                return;
              }
              if (_selectedPaymentMethod == null) {
                Get.snackbar("경고", "결제 수단을 선택해주세요.");
                return;
              }

              if (_selectedPaymentMethod != null && _selectedStore != null) {
                Get.snackbar(
                  "결제 완료!",
                  "${formattedPrice}원 결제가 ${_selectedPaymentMethod}으로 요청되었습니다.",
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
                insertOrderAction();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            child: Text(
              "${formattedPrice}원 결제하기",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  //--------------------------------Functions--------------------------------
  Future<void> insertOrderAction()  async{
    var request = http.MultipartRequest(
      'POST', 
      Uri.parse('$urlPath/orders/insert')
    );
    request.fields['orders_customer_id'] = customer_id.toString();
    request.fields['orders_product_id'] = product_id.toString();
    request.fields['orders_number'] = product_price.toString();   // price속성이 없어서 여기에다가 가격적음
    request.fields['orders_quantity'] = 1.toString();       // 아직 장바구니구현안해서 구매하기만
    request.fields['orders_payment'] = _selectedPaymentMethod.toString(); // 결제방법
    request.fields['orders_store_id'] = _selectedStore!.store_id.toString();
    request.fields['orders_employee_id'] = 1.toString();        // null값 = 아직 employee가 누구인지 모름

    var res = await request.send();
    if (res.statusCode == 200) {
      message.showDialog("주문이 완료되었습니다.", "픽업 준비가 시작되면 알려드릴게요");
    }else{
      message.errorSnackBar("죄송합니다. 주문에 실패했습니다.", "주문에 실패했습니다. 다시 시도해 보세요.");
    }
  }

  Future<void> getStoredata() async {
    // Store 데이터 가져오기
    var url = Uri.parse("$urlPath/store/select");
    var response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("HTTP ${response.statusCode}: ${response.body}");
    }

    storeData.clear();

    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataConvertedJSON['results'];
    storeData = result.map((e) => Store.fromJson(e)).toList();
    getDistanceStore();
    setState(() {});
  }

  // 가까운 매장 순으로 정렬하기
  Future<void> getDistanceStore() async {
    if (storeData.isEmpty) {
      return;
    }

    final distanceCalc = latlng.Distance();
    final userPos = await getCurrentLocation();

    storeData.sort((a, b) {
      final da = distanceCalc(userPos, latlng.LatLng(a.store_lat, a.store_lng));
      final db = distanceCalc(userPos, latlng.LatLng(b.store_lat, b.store_lng));

      return da.compareTo(db);
    });

    _selectedStore ??= storeData.first;
    _userPos = userPos;

    await getCurrentLocation();
    setState(() {});
  }

  //주소로부터 위도 경도 추출하는 코드
  Future<latlng.LatLng> getCurrentLocation() async {
    List<Location> locations = await locationFromAddress(customer_address);

    final _latData = locations.first.latitude;
    final _lngData = locations.first.longitude;
    return latlng.LatLng(_latData, _lngData);
  }
} // class
