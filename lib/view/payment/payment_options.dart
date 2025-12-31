// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// // import 'package:shoes_store_app_project/model/product_model.dart';
// // import 'package:shoes_store_app_project/view/shop_select.dart';

// // ------------------------------------------------------------------
// // 주의: 아래 import 경로는 실제 프로젝트 구조에 맞게 수정해야 합니다.
// // ------------------------------------------------------------------
// // import '../util/controllers.dart'; 
// // import '../models/product_model.dart'; 
// // import 'shop_screen.dart'; // ShopSelectionScreen 위젯 경로
// // ------------------------------------------------------------------

// // 픽업 매장 정보를 위한 모델 (fromMap 및 toMap 추가)
// class StoreModel {
//   final String id;
//   final String name;
//   final String address;
//   final double distance; // 킬로미터 단위 가정

//   StoreModel({required this.id, required this.name, required this.address, required this.distance});
  
//   // Map으로부터 StoreModel 객체를 생성하는 팩토리 생성자 (결과를 받을 때 사용)
//   factory StoreModel.fromMap(Map<String, dynamic> map) {
//     return StoreModel(
//       id: map['id'] as String,
//       name: map['name'] as String,
//       address: map['address'] as String,
//       // double 타입으로 명확히 캐스팅
//       distance: (map['distance'] is int) ? (map['distance'] as int).toDouble() : map['distance'] as double,
//     );
//   }

//   // 매장 정보를 Map 형태로 변환하는 메서드 (리턴 시 사용)
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'name': name,
//       'address': address,
//       'distance': distance,
//     };
//   }
// }

// class PaymentOptions extends StatefulWidget {
//   const PaymentOptions({super.key});

//   @override
//   State<PaymentOptions> createState() => _PaymentOptionsState();
// }

// class _PaymentOptionsState extends State<PaymentOptions> {
//   // GetX 컨트롤러 찾기
//   final CartController cartController = Get.find<CartController>();

//   // 상태 관리 변수
//   StoreModel? _selectedStore;
//   String? _selectedPaymentMethod;
  
//   // 더미 데이터: 결제 수단
//   final List<String> _paymentMethods = ['신용/체크카드', '네이버페이', '카카오페이', '휴대폰 결제'];

//   // 더미 데이터: 가까운 매장 목록
//   final List<StoreModel> _nearbyStores = [
//     StoreModel(id: 'S001', name: '강남 플래그십 스토어', address: '서울 강남구 테헤란로 123', distance: 0.5),
//     StoreModel(id: 'S002', name: '홍대 프리미엄점', address: '서울 마포구 와우산로 30', distance: 1.2),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     // 초기에는 가장 가까운 매장을 기본 선택
//     if (_nearbyStores.isNotEmpty) {
//       _selectedStore = _nearbyStores.first;
//     }
//   }

//   // 매장 선택 지도로 이동하는 함수 (ShopSelectionScreen에서 결과 받아옴)
//   void _openStoreMap() async {
//     final selectedStoreMap = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const ShopSelectionScreen()),
//     );

//     // 결과가 StoreModel 타입의 Map으로 돌아왔다면 상태 업데이트
//     if (selectedStoreMap != null && selectedStoreMap is Map<String, dynamic>) {
//       setState(() {
//         _selectedStore = StoreModel.fromMap(selectedStoreMap); 
//       });
//       Get.snackbar("알림", "${_selectedStore!.name}이(가) 픽업 매장으로 선택되었습니다.",
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.blue.withOpacity(0.9),
//         colorText: Colors.white,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // 1. 장바구니에서 마지막 Map 데이터를 가져옵니다.
//     final Map<String, dynamic>? lastProductMap = cartController.cartItems.isNotEmpty
//         ? cartController.cartItems.last 
//         : null;

//     // 2. Map 데이터를 ProductModel 객체로 변환합니다.
//     final ProductModel? lastProduct = lastProductMap != null
//         ? ProductModel.fromMap(lastProductMap) 
//         : null;

//     // 만약 상품 정보가 없다면 에러 처리
//     if (lastProduct == null) {
//       return Scaffold(
//         appBar: _buildAppBar(context),
//         body: const Center(child: Text("주문할 상품 정보가 없습니다.")),
//       );
//     }
    
//     // 합계 금액 계산 (CartController에서 price는 int로 저장됨)
//     final double totalPrice = (lastProductMap?['price'] as int? ?? 0).toDouble();
    
//     // 가격 포맷
//     final priceFormatter = NumberFormat('#,###', 'ko_KR');
//     final formattedPrice = priceFormatter.format(totalPrice);


//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: _buildAppBar(context),
//       body: Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // 1. 선택 상품 정보
//                   _buildProductInfo(lastProduct),
//                   const Divider(height: 40),

//                   // 2. 픽업 매장 선택
//                   _buildStoreSelector(),
//                   const Divider(height: 40),

//                   // 3. 결제 수단 선택
//                   _buildPaymentSelector(),
//                   const Divider(height: 40),

//                   // 4. 합계 금액
//                   _buildTotalPrice(formattedPrice),
//                 ],
//               ),
//             ),
//           ),
//           // 5. 하단 결제하기 버튼
//           _buildBottomCheckoutButton(totalPrice, formattedPrice),
//         ],
//       ),
//     );
//   }

//   // 앱바 (오른쪽 닫기 버튼 포함)
//   AppBar _buildAppBar(BuildContext context) {
//     return AppBar(
//       backgroundColor: Colors.white,
//       elevation: 0,
//       centerTitle: true,
//       title: const Text(
//         "결제하기",
//         style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
//       ),
//       leading: IconButton(
//         icon: const Icon(Icons.arrow_back, color: Colors.black),
//         onPressed: () => Navigator.pop(context),
//       ),
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.close, color: Colors.black), 
//           onPressed: () => Navigator.pop(context), 
//         ),
//       ],
//     );
//   }

//   // 1. 선택 상품 정보 위젯
//   Widget _buildProductInfo(ProductModel product) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "주문 상품",
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 12),
//         Row(
//           children: [
//             // 상품 이미지
//             Container(
//               width: 60,
//               height: 60,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(8),
//                 image: DecorationImage(
//                   image: NetworkImage(product.selectedColorImageUrl),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             // 상품 이름, 사이즈
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     product.title,
//                     style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     "${product.selectedSize} 사이즈 | ${product.price}",
//                     style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   // 2. 픽업 매장 선택 위젯
//   Widget _buildStoreSelector() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Text(
//               "픽업 매장 선택",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             TextButton.icon(
//               onPressed: _openStoreMap, // ShopSelectionScreen 호출
//               icon: const Icon(Icons.map_outlined, size: 18),
//               label: const Text("다른 매장 선택", style: TextStyle(fontSize: 14)),
//               style: TextButton.styleFrom(foregroundColor: Colors.black),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         if (_selectedStore != null)
//           _buildStoreTile(_selectedStore!),
//       ],
//     );
//   }

//   // 개별 매장 타일 위젯
//   Widget _buildStoreTile(StoreModel store) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.black, width: 1),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.storefront, color: Colors.black),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   store.name,
//                   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   store.address,
//                   style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 10),
//           Text(
//             "${store.distance.toStringAsFixed(1)}km",
//             style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//           ),
//         ],
//       ),
//     );
//   }


//   // 3. 결제 수단 선택 위젯
//   Widget _buildPaymentSelector() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "결제 수단 선택",
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 12),
//         ..._paymentMethods.map((method) {
//           final isSelected = _selectedPaymentMethod == method;
//           return Padding(
//             padding: const EdgeInsets.only(bottom: 8.0),
//             child: ListTile(
//               onTap: () {
//                 setState(() {
//                   _selectedPaymentMethod = method;
//                 });
//               },
//               contentPadding: EdgeInsets.zero,
//               leading: Icon(
//                 isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
//                 color: isSelected ? Colors.black : Colors.grey,
//               ),
//               title: Text(method),
//               trailing: const Icon(Icons.keyboard_arrow_right, color: Colors.grey),
//             ),
//           );
//         }).toList(),
//       ],
//     );
//   }

//   // 4. 합계 금액 위젯
//   Widget _buildTotalPrice(String formattedPrice) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text("상품 금액", style: TextStyle(fontSize: 16, color: Colors.grey)),
//               Text("$formattedPrice원", style: const TextStyle(fontSize: 16)),
//             ],
//           ),
//           const SizedBox(height: 8),
//           const Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text("배송비", style: TextStyle(fontSize: 16, color: Colors.grey)),
//               Text("무료", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             ],
//           ),
//           const Divider(height: 30),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text("최종 결제 금액", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//               Text("$formattedPrice원", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // 5. 하단 결제하기 버튼
//   Widget _buildBottomCheckoutButton(double totalPrice, String formattedPrice) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, -5),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         child: SizedBox(
//           width: double.infinity,
//           height: 56,
//           child: ElevatedButton(
//             onPressed: () {
//               if (_selectedStore == null) {
//                 Get.snackbar("경고", "픽업 매장을 선택해주세요.");
//                 return;
//               }
//               if (_selectedPaymentMethod == null) {
//                 Get.snackbar("경고", "결제 수단을 선택해주세요.");
//                 return;
//               }
              
//               Get.snackbar("결제 완료!", 
//                 "${formattedPrice}원 결제가 ${_selectedPaymentMethod}으로 요청되었습니다.",
//                 snackPosition: SnackPosition.TOP,
//                 backgroundColor: Colors.green,
//                 colorText: Colors.white,
//               );
//               Navigator.pop(context); 
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.black,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
//               elevation: 0,
//             ),
//             child: Text(
//               "${formattedPrice}원 결제하기",
//               style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }