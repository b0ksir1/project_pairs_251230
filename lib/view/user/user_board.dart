// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// /// ✅ 자유 게시판 "껍데기 UI" (리뷰/탭 제거 버전)
// /// - 상단: 게시판 타이틀
// /// - 검색창 + 정렬(최신/인기/댓글)
// /// - 게시글 카드 리스트
// /// - 우하단 글쓰기 버튼(검정)
// ///
// /// ⚠️ 아직 DB/API 연결 없음
// /// 나중에 연결할 위치는 // TODO: 로 표시
// class UserBoard extends StatefulWidget {
//   const UserBoard({super.key});

//   @override
//   State<UserBoard> createState() => _UserBoardState();
// }

// class _UserBoardState extends State<UserBoard> {
//   String _sort = "latest"; // latest | popular | comments
//   String _query = "";

//   @override
//   void initState() {
//     super.initState();

//     // TODO: initState에서 게시글 목록 불러오기
//     // fetchPosts(boardType: 'free', sort: _sort, q: _query);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bg = const Color(0xFFF6F3FF); // 스샷 느낌 연한 배경

//     return Scaffold(
//       backgroundColor: bg,
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: bg,
//         title: const Text(
//           "게시판",
//           style: TextStyle(
//             fontWeight: FontWeight.w900,
//             letterSpacing: -0.2,
//           ),
//         ),
//       ),

//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () {
//           // TODO: 글쓰기 페이지로 이동
//           // Navigator.push(context, MaterialPageRoute(builder: (_) => PostWriteShell()));
//         },
//         backgroundColor: Colors.black,
//         foregroundColor: Colors.white,
//         icon: const Icon(Icons.edit_outlined),
//         label: const Text(
//           "글쓰기",
//           style: TextStyle(fontWeight: FontWeight.w900),
//         ),
//       ),

//       body: SafeArea(
//         child: Column(
//           children: [
//             // ===== 리스트 =====
//             Expanded(
//               child: _PostListShell(
//                 onTapPost: () {
//                   // TODO: 상세로 이동 (postId 전달)
//                   // Navigator.push(context, MaterialPageRoute(builder: (_) => PostDetailShell(postId: id)));
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ===================== Components =====================

// class _SortDropDown extends StatelessWidget {
//   final String value;
//   final ValueChanged<String> onChanged;

//   const _SortDropDown({
//     required this.value,
//     required this.onChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 48,
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.95),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           value: value,
//           style: const TextStyle(
//             fontWeight: FontWeight.w900,
//             color: Colors.black,
//           ),
//           items: const [
//             DropdownMenuItem(value: "latest", child: Text("최신")),
//             DropdownMenuItem(value: "popular", child: Text("인기")),
//             DropdownMenuItem(value: "comments", child: Text("댓글")),
//           ],
//           onChanged: (v) {
//             if (v != null) onChanged(v);
//           },
//         ),
//       ),
//     );
//   }
// }

// /// ✅ 게시글 리스트 껍데기 (현재는 더미 카드 표시)
// class _PostListShell extends StatelessWidget {
//   final VoidCallback onTapPost;

//   const _PostListShell({
//     required this.onTapPost,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // TODO: 실제 posts 리스트 받아오기
//     // final posts = controller.posts;
//     // itemCount: posts.length
//     // itemBuilder: (context, index) => PostCard(post: posts[index])

//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//                   .collection('컬럼명적어주세요')
//                   .orderBy('뭐를 기준점잡을건지', descending: false)
//                   .snapshots(), 
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return Center(
//             child: CircularProgressIndicator(),
//           );
//           final documents = snapshot.data!.docs;
//           return Listview(
//             children: documents.map((e) => buildItemWidget(e)).toList()
//           );
//         }
//       },
//     );




//     // ListView.separated(
//     //   padding: const EdgeInsets.fromLTRB(16, 6, 16, 90),
//     //   itemCount: 12, // TODO: 실제 데이터 길이로 변경
//     //   separatorBuilder: (_, __) => const SizedBox(height: 12),
//     //   itemBuilder: (context, index) {
//     //     // TODO: 실제 데이터로 교체
//     //     final title = "자유글 제목 ${index + 1}";
//     //     final content = "여기는 내용 미리보기 영역입니다. API 연결 후 content로 바꿔주세요.";
//     //     final author = "사용자";
//     //     final timeText = "${(index + 1) * 5}분 전";
//     //     final commentCount = 2 + (index % 4);
//     //     final likeCount = 10 + index;

//     //     return _PostCardShell(
//     //       title: title,
//     //       content: content,
//     //       author: author,
//     //       timeText: timeText,
//     //       commentCount: commentCount,
//     //       likeCount: likeCount,
//     //       onTap: () {
//     //         // TODO: postId 넘겨 상세로 이동
//     //         onTapPost();
//     //       },
//     //     );
//     //   },
//     // );
//   }
// }

// /// ✅ 게시글 카드 껍데기 (스샷 느낌)
// class _PostCardShell extends StatelessWidget {
//   // TODO: 실제 모델로 교체될 필드들
//   final String title;
//   final String content;
//   final String author;
//   final String timeText;
//   final int commentCount;
//   final int likeCount;

//   final VoidCallback onTap;

//   const _PostCardShell({
//     required this.title,
//     required this.content,
//     required this.author,
//     required this.timeText,
//     required this.commentCount,
//     required this.likeCount,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       borderRadius: BorderRadius.circular(18),
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.96),
//           borderRadius: BorderRadius.circular(18),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.04),
//               blurRadius: 18,
//               offset: const Offset(0, 10),
//             ),
//           ],
//         ),
//         padding: const EdgeInsets.all(14),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 제목
//             Text(
//               title,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(
//                 fontWeight: FontWeight.w900,
//                 fontSize: 16,
//                 letterSpacing: -0.2,
//               ),
//             ),
//             const SizedBox(height: 6),

//             // 내용 미리보기
//             Text(
//               content,
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(
//                 fontSize: 13,
//                 height: 1.25,
//                 color: Colors.black54,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//             const SizedBox(height: 12),

//             // 하단 메타: 작성자/시간 + 댓글/좋아요
//             Row(
//               children: [
//                 Text(
//                   "$author · $timeText",
//                   style: const TextStyle(
//                     fontSize: 12,
//                     color: Colors.black38,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//                 const Spacer(),
//                 _MetaIconText(icon: Icons.chat_bubble_outline_rounded, text: "$commentCount"),
//                 const SizedBox(width: 10),
//                 _MetaIconText(icon: Icons.favorite_border_rounded, text: "$likeCount"),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _MetaIconText extends StatelessWidget {
//   final IconData icon;
//   final String text;

//   const _MetaIconText({
//     required this.icon,
//     required this.text,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Icon(icon, size: 16, color: Colors.black38),
//         const SizedBox(width: 4),
//         Text(
//           text,
//           style: const TextStyle(
//             fontSize: 12,
//             color: Colors.black38,
//             fontWeight: FontWeight.w900,
//           ),
//         ),
//       ],
//     );
//   }
// }
