import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_pairs_251230/util/side_menu.dart';
import 'package:project_pairs_251230/view/admin/admin_approval_list.dart';
import 'package:project_pairs_251230/view/admin/admin_approval_request.dart';
import 'package:project_pairs_251230/view/admin/admin_board.dart';
import 'package:project_pairs_251230/view/admin/admin_dashboard.dart';
import 'package:project_pairs_251230/view/admin/admin_delivery_product.dart';
import 'package:project_pairs_251230/view/admin/admin_insert_product.dart';
import 'package:project_pairs_251230/view/admin/admin_purchase_manage.dart';
import 'package:project_pairs_251230/view/admin/admin_purchase_order.dart';
import 'package:project_pairs_251230/view/admin/admin_return_product.dart';
import 'package:project_pairs_251230/view/admin/admin_sales_chart.dart';
import 'package:project_pairs_251230/view/admin/admin_sales_order.dart';
import 'package:project_pairs_251230/view/admin/admin_side_item.dart';
import 'package:project_pairs_251230/view/admin/admin_stock_list.dart';

class AdminSideBar extends StatelessWidget {
  final SideMenu selectedMenu;
  final ValueChanged<SideMenu> onMenuSelected;

  const AdminSideBar({
    super.key,
    required this.selectedMenu,
    required this.onMenuSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: const Color(0xFF0F172A),
      child: Column(
        children: [
          const SizedBox(height: 24),

          AdminSideItem(
            icon: Icons.dashboard_outlined,
            text: '대시보드',
            selected: selectedMenu == SideMenu.dashboard,
            onTap: () {
              Get.to(AdminDashboard());
            },
          ),
          AdminSideItem(
            icon: Icons.view_in_ar_rounded,
            text: '상품 관리',
            selected: selectedMenu == SideMenu.product,
            onTap: () {
              Get.to(AdminInsertProduct());
            },
          ),
          AdminSideItem(
            icon: Icons.view_in_ar_rounded,
            text: '대리점 발송',
            selected: selectedMenu == SideMenu.delivery,
            onTap: () {
              Get.to(AdminDeliveryProduct());
            },
          ),
          AdminSideItem(
            icon: Icons.shopping_cart_outlined,
            text: '구매 내역',
            selected: selectedMenu == SideMenu.orders,
            onTap: () {
              Get.to(AdminPurchaseManage());
            },
          ),
          AdminSideItem(
            icon: Icons.local_shipping_outlined,
            text: '반품 내역',
            selected: selectedMenu == SideMenu.returns,
            onTap: () {
              Get.to(AdminReturnProduct());
            },
          ),
          AdminSideItem(
            icon: Icons.inventory,
            text: '재고 관리',
            selected: selectedMenu == SideMenu.stock,
            onTap: () {
              Get.to(AdminStockList());
            },
          ),
          AdminSideItem(
            icon: Icons.bar_chart_sharp,
            text: '매출 확인',
            selected: selectedMenu == SideMenu.sales,
            onTap: () {
              Get.to(AdminSalesChart());
            },
          ),
          AdminSideItem(
            icon: Icons.call_made,
            text: '발주 페이지',
            selected: selectedMenu == SideMenu.procure,
            onTap: () {
              Get.to(AdminPurchaseOrder());
            },
          ),
          // AdminSideItem(
          //   icon: Icons.call_received,
          //   text: '수주 페이지',
          //   selected: selectedMenu == SideMenu.obtain,
          //   onTap: () {
          //     Get.to(AdminSalesOrder());
          //   },
          // ),
          AdminSideItem(
            icon: Icons.border_all_rounded,
            text: '게시판',
            selected: selectedMenu == SideMenu.board,
            onTap: () {
              Get.to(AdminBoard());
            },
          ),
          AdminSideItem(
            icon: Icons.approval_outlined,
            text: '품의',
            selected: selectedMenu == SideMenu.approval,
            onTap: () {
              Get.to(AdminApprovalList());
            },
          ),
          // AdminSideItem(
          //   icon: Icons.settings_outlined,
          //   text: '설정',
          //   selected: selectedMenu == SideMenu.settings,
          //   onTap: () {
          //     // Get.to(());
          //   },
          // ),
        ],
      ),
    );
  }
}
