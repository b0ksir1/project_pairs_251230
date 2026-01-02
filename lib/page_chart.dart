import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_pairs_251230/view/admin/admin_approval_confirm.dart';
import 'package:project_pairs_251230/view/admin/admin_approval_request.dart';
import 'package:project_pairs_251230/view/admin/admin_chat.dart';
import 'package:project_pairs_251230/view/admin/admin_chat_list.dart';
import 'package:project_pairs_251230/view/admin/admin_dashboard.dart';
import 'package:project_pairs_251230/view/admin/admin_delivery_product.dart';
import 'package:project_pairs_251230/view/admin/admin_insert_product.dart';
import 'package:project_pairs_251230/view/admin/admin_login.dart';
import 'package:project_pairs_251230/view/admin/admin_purchase_manage.dart';
import 'package:project_pairs_251230/view/admin/admin_purchase_order.dart';
import 'package:project_pairs_251230/view/admin/admin_return_product.dart';
import 'package:project_pairs_251230/view/admin/admin_sales_chart.dart';
import 'package:project_pairs_251230/view/admin/admin_sales_order.dart';
import 'package:project_pairs_251230/view/admin/admin_stock_list.dart';
import 'package:project_pairs_251230/view/auth/customer_login.dart';
import 'package:project_pairs_251230/view/auth/profile_edit.dart';
import 'package:project_pairs_251230/view/auth/sign_up.dart';
import 'package:project_pairs_251230/view/board/customer_board.dart';
import 'package:project_pairs_251230/view/category/category_list.dart';
import 'package:project_pairs_251230/view/chat/customer_chat_screen.dart';
import 'package:project_pairs_251230/view/order/order_detail.dart';
import 'package:project_pairs_251230/view/order/order_history.dart';
import 'package:project_pairs_251230/view/order/shopping_cart.dart';
import 'package:project_pairs_251230/view/order/wish_list.dart';
import 'package:project_pairs_251230/view/payment/payment_map.dart';
import 'package:project_pairs_251230/view/product/product_detail.dart';
import 'package:project_pairs_251230/view/user/my_page.dart';

class PageChart extends StatefulWidget {
  const PageChart({super.key});

  @override
  State<PageChart> createState() => _PageChartState();
}

class _PageChartState extends State<PageChart> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 70, 10, 10),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 180,
                    child: Column(
                      children: [
                        Text('앱 화면'),
                        TextButton(
                          onPressed: () => Get.to(CustomerLogin()),
                          child: Text('로그인(고객)'),
                        ),
                        TextButton(
                          onPressed: () => Get.to(SignUp()),
                          child: Text('회원가입'),
                        ),
                        TextButton(
                          onPressed: () => Get.to(ProfileEdit()),
                          child: Text('회원 정보 수정'),
                        ),
                        TextButton(
                          onPressed: () => Get.to(MyPage()),
                          child: Text('마이 페이지'),
                        ),
                        TextButton(
                          onPressed: () => Get.to(ProductDetail()),
                          child: Text('상품 상세 페이지'),
                        ),
                        TextButton(
                          onPressed: () => Get.to(OrderHistory()),
                          child: Text('구매 내역'),
                        ),
                        TextButton(
                          onPressed: () => Get.to(OrderDetail()),
                          child: Text('구매 상세 페이지'),
                        ),
                        TextButton(
                          onPressed: () => Get.to(PaymentMap()),
                          child: Text('결제 할 때 지도 보여주기'),
                        ),
                        TextButton(
                          onPressed: () {
                            //
                          },
                          child: Text('결제 방법, 픽업 지역 선택'),
                        ),
                        TextButton(
                          onPressed: () => Get.to(CategoryList()),
                          child: Text('카테고리'),
                        ),
                        TextButton(
                          onPressed: () {
                            //
                          },
                          child: Text('채팅 리스트'),
                        ),
                        TextButton(
                          onPressed: () => Get.to(CustomerChatScreen()),
                          child: Text('채팅 화면'),
                        ),
                        TextButton(
                          onPressed: () => Get.to(CustomerBoard()),
                          child: Text('게시판 확인'),
                        ),
                        TextButton(
                          onPressed: () => Get.to(ShoppingCart()),
                          child: Text('장바구니'),
                        ),
                        TextButton(
                          onPressed: () => Get.to(WishList()),
                          child: Text('위시 리스트'),
                        ),
                        TextButton(
                          onPressed: () {
                            //
                          },
                          child: Text('결제 완료 화면'),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    child: Column(
                      children: [
                        Text('태블릿 화면'),
                        TextButton(
                          onPressed: () => Get.to(AdminLogin()),
                          child: Text('관리자 로그인'),
                        ),
                        TextButton(
                          onPressed: () => Get.to(AdminDashboard()),
                          child: Text('관리자 대시보드'),
                        ),
                        TextButton(
                          onPressed: () => Get.to(AdminInsertProduct()),
                          child: Text('상품 등록'),
                        ),
                        TextButton(
                          onPressed: () => Get.to(AdminPurchaseManage()),
                          child: Text('구매 내역 페이지'),
                        ),
                        TextButton(
                          onPressed: () => Get.to(AdminReturnProduct()),
                          child: Text('반품 내역 페이지'),
                        ),
                        TextButton(
                          onPressed: () => Get.to(AdminStockList()),
                          child: Text('재고 확인 페이지'),
                        ),
                        TextButton(
                          onPressed: () => Get.to(AdminSalesChart()),
                          child: Text('매출 확인 페이지'),
                        ),
                        TextButton(
                          onPressed: () => Get.to(AdminDeliveryProduct()),
                          child: Text('대리점 발송 페이지'),
                        ),
                        TextButton(
                          onPressed: () => Get.to(AdminPurchaseOrder()),
                          child: Text('발주 신청 페이지'),
                        ),
                        TextButton(
                          onPressed: () => Get.to(AdminSalesOrder()),
                          child: Text('수주 신청 페이지'),
                        ),
                        TextButton(onPressed: () => Get.to(AdminChatList()), child: Text('채팅 리스트 페이지')),
                        TextButton(onPressed: () => Get.to(AdminChat()), child: Text('채팅 답변')),
                        TextButton(onPressed: () {}, child: Text('게시판')),
                        TextButton(
                          onPressed: () => Get.to(AdminApprovalRequest()),
                          child: Text('품의 요청 페이지'),
                        ),
                        TextButton(
                          onPressed: () => Get.to(AdminApprovalConfirm()),
                          child: Text('품의 확인 페이지'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
