// import 'package:flutter/material.dart';

// class SearchResult extends StatefulWidget {
//   final String query;


//   const SearchResult({super.key, required this.query});

//   @override
//   State<SearchResult> createState() => _SearchResultState();
// }

// class _SearchResultState extends State<SearchResult> {
//   @override
//   Widget build(BuildContext context) {
//     // 임시 상품 데이터 (검색어와 무관하게 고정)
//     final List<Map<String, String>> searchResults = [
//       {"name": "검색 결과 상품 1", "image": "https://via.placeholder.com/150?text=Result1"},
//       {"name": "검색 결과 상품 2", "image": "https://via.placeholder.com/150?text=Result2"},
//       {"name": "검색 결과 상품 3", "image": "https://via.placeholder.com/150?text=Result3"},
//       {"name": "검색 결과 상품 4", "image": "https://via.placeholder.com/150?text=Result4"},
//     ];
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('검색 결과: "$query"'),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: GridView.builder(
//         padding: const EdgeInsets.all(12),
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           crossAxisSpacing: 10,
//           mainAxisSpacing: 10,
//           childAspectRatio: 0.7, // 사진과 텍스트 공간을 고려한 비율
//         ),
//         itemCount: searchResults.length,
//         itemBuilder: (context, index) {
//           final item = searchResults[index];
//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(
//                 child: Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(8),
//                     color: Colors.grey[100],
//                     image: DecorationImage(
//                       image: NetworkImage(item['image']!),
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 item['name']!,
//                 style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//                 overflow: TextOverflow.ellipsis,
//               ),
//               const Text(
//                 '가격 정보',
//                 style: TextStyle(fontSize: 12, color: Colors.red),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }