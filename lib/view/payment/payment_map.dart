// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// // StoreModel 정의 파일 import 경로를 확인하세요. (OrderScreen과 동일 폴더에 있다고 가정)
// // import 'order.dart'; 

// class PaymentMap extends StatefulWidget {
//   const PaymentMap({super.key});

//   @override
//   State<PaymentMap> createState() => _PaymentMapState();
// }

// class _PaymentMapState extends State<PaymentMap> {
//     // 더미 데이터: 모든 매장 목록
//   final List<StoreModel> _allStores = [
//     StoreModel(id: 'S001', name: '강남 플래그십 스토어', address: '서울 강남구 테헤란로 123', distance: 0.5),
//     StoreModel(id: 'S002', name: '홍대 프리미엄점', address: '서울 마포구 와우산로 30', distance: 1.2),
//     StoreModel(id: 'S003', name: '여의도 더 현대점', address: '서울 영등포구 여의대로 108', distance: 5.8),
//     StoreModel(id: 'S004', name: '판교 테크노벨리점', address: '경기 성남시 분당구 판교역로 235', distance: 15.1),
//     StoreModel(id: 'S005', name: '부산 해운대점', address: '부산 해운대구 마린시티 2로 38', distance: 380.0),
//   ];
  
//   // 현재 선택된 매장 (초기에는 null)
//   StoreModel? _selectedStore;

//   // 매장 선택 완료 시 OrderScreen으로 결과를 전달하고 돌아갑니다.
//   void _selectStore(StoreModel store) {
//     setState(() {
//       _selectedStore = store;
//     });
//     // 결과를 Map 형태로 OrderScreen에 전달
//     Navigator.pop(context, store.toMap()); 
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: _buildAppBar(context),
//       body: Column(
//         children: [
//           // 1. 지도 뷰 (더미 이미지 또는 실제 지도 위젯 대체)
//           _buildMapView(),

//           // 2. 매장 목록
//           Expanded(
//             child: ListView(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               children: [
//                 const SizedBox(height: 20),
//                 const Text(
//                   "모든 픽업 매장",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 12),
//                 ..._allStores.map((store) => 
//                   _buildStoreListTile(store)
//                 ).toList(),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // 앱바 (닫기 버튼 포함)
//   AppBar _buildAppBar(BuildContext context) {
//     return AppBar(
//       backgroundColor: Colors.white,
//       elevation: 0,
//       centerTitle: true,
//       title: const Text(
//         "매장 찾기",
//         style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
//       ),
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.close, color: Colors.black), // 닫기(X) 버튼
//           onPressed: () => Navigator.pop(context), // 화면 닫기
//         ),
//       ],
//     );
//   }
  
//   // 지도 더미 뷰
//   Widget _buildMapView() {
//     return Container(
//       height: 250,
//       width: double.infinity,
//       color: Colors.grey.shade200,
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           // 실제 지도 SDK (Google Maps, Naver Map 등)가 들어갈 공간
//           Center(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Icon(Icons.map, size: 50, color: Colors.grey),
//                 const SizedBox(height: 10),
//                 Text(
//                   "실시간 지도 뷰 (현재 사용자 위치 기준)",
//                   style: TextStyle(color: Colors.grey.shade600),
//                 ),
//               ],
//             ),
//           ),
//           // 현재 위치 표시 및 가까운 매장 정보 오버레이 (옵션)
//           Positioned(
//             bottom: 10,
//             right: 10,
//             child: FloatingActionButton.extended(
//               onPressed: () {
//                 Get.snackbar("알림", "현재 위치를 중심으로 매장을 검색합니다.");
//               },
//               label: const Text("내 위치 보기"),
//               icon: const Icon(Icons.my_location),
//               backgroundColor: Colors.black,
//               foregroundColor: Colors.white,
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   // 매장 목록 타일
//   Widget _buildStoreListTile(StoreModel store) {
//     final isSelected = store.id == _selectedStore?.id;
    
//     return InkWell(
//       onTap: () => _selectStore(store),
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 16),
//         decoration: BoxDecoration(
//           border: Border(
//             bottom: BorderSide(color: Colors.grey.shade200),
//           ),
//         ),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Icon(
//               isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
//               color: isSelected ? Colors.black : Colors.grey,
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     store.name,
//                     style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     store.address,
//                     style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 10),
//             Text(
//               "${store.distance.toStringAsFixed(1)}km",
//               style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }