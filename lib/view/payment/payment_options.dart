import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:project_pairs_251230/model/store.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:project_pairs_251230/util/global_data.dart';
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
/*
  ※ 결제카드 정보 ※
  카드번호: 4242 4242 4242 4242
  유효기간: 아무 미래 날짜
  CVC: 아무 3자리
*/

class PaymentOptions extends StatefulWidget {
  const PaymentOptions({super.key});

  @override
  State<PaymentOptions> createState() => _PaymentOptionsState();
}

class _PaymentOptionsState extends State<PaymentOptions> {
  // Property
  final urlPath = GlobalData.url; // 자기 ip
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

  @override
  Widget build(BuildContext context) {

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
                print(_selectedPaymentMethod);
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
            onPressed: () async{
              if (_selectedStore == null) {
                message.errorSnackBar("경고", "픽업 매장을 선택해주세요.");
                return;
              }
              if (_selectedPaymentMethod == null) {
                message.errorSnackBar("경고", "결제 수단을 선택해주세요.");
                return;
              }

              if (_selectedPaymentMethod == "픽업결제" && _selectedStore != null) {
                message.successSnackBar("결제 완료!", "$formattedPrice원 결제가 $_selectedPaymentMethod으로 요청되었습니다.");
                insertOrderAction();
              }else if(_selectedPaymentMethod == "신용/체크카드" && _selectedStore != null) {
                await pay(totalPrice.toInt());
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
    request.fields['orders_number'] = generateOrderNumber();   // price속성이 없어서 여기에다가 가격적음
    request.fields['orders_quantity'] = 1.toString();       // 아직 장바구니구현안해서 구매하기만
    request.fields['orders_payment'] = _selectedPaymentMethod.toString(); // 결제방법
    request.fields['orders_store_id'] = _selectedStore!.store_id.toString();
    request.fields['orders_employee_id'] = 1.toString();        // null값 = 아직 employee가 누구인지 모름
    request.fields['orders_totalprice'] = product_price.toString();
    request.fields['orders_status'] = 1.toString();


    var res = await request.send();
    if (res.statusCode == 200) {
      await updateStockAction();
      message.showDialog("주문이 완료되었습니다.", "주문이 정상적으로 접수되었습니다.");
    }else{
      message.errorSnackBar("죄송합니다. 주문에 실패했습니다.", "주문에 실패했습니다. 다시 시도해 보세요.");
    }
  }

  Future<void> updateStockAction()  async{    // 재고 반영
    var request = http.MultipartRequest(
      'POST', 
      Uri.parse('$urlPath/stock/update')
    );
    request.fields['stock_quantity'] = 1.toString();
    request.fields['stock_product_id'] = product_id.toString();
    final res = await request.send();
    if (res.statusCode != 200) {
      throw Exception("재고 업데이트 실패: ${res.statusCode}");
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

// clientSecret 받아오기
Future<String> createPaymentIntent(int amount) async {
  final res = await http.post(
    Uri.parse(
        "$urlPath/payment/create-payment-intent"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "amount": amount,
      "currency": "krw",
    }),
  );

  final data = jsonDecode(res.body);
  return data["clientSecret"];
}

// 신용카드 결제부분
Future<void> pay(int amount) async {
  try {
    // 서버에서 clientSecret 받기
    final clientSecret = await createPaymentIntent(amount);

    // PaymentSheet 초기화
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: "OnAndTap (Test)",
        style: ThemeMode.light,
      ),
    );

    // 결제 UI 표시
    await Stripe.instance.presentPaymentSheet();

    // 여기까지 오면 결제 성공
    insertOrderAction();
  } catch (e) {
    message.errorSnackBar("결제실패", "$e");
  }
}

String generateOrderNumber(){
  final date = DateFormat('yyyyMMdd').format(DateTime.now());
  final random = Random().nextInt(90000) + 10000;
  return 'ORD-$date-$random';
}

} // class
