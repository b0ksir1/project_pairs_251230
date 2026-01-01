import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_pairs_251230/view/admin/admin_approval_request.dart';

class AdminInsertPrd extends StatefulWidget {
  const AdminInsertPrd({super.key});

  @override
  State<AdminInsertPrd> createState() =>
      _AdminInsertPrdState();
}

class _AdminInsertPrdState extends State<AdminInsertPrd> {
  // property
  // 드랍다운
  int dropDownValue = 10;

  final List<int> quantityItems = [10, 20, 30, 50, 100];

  // 구매 내역 페이지
  final List<PurchaseOrder> data = [
    PurchaseOrder(
      po: '#PO-8821',
      date: 'Oct 25, 2023',
      supplier: 'Kicks Wholesale Inc.',
      product: 'Nike Air Max Red',
      qtyInfo: 'Qty: 50 · Unit: \$90.00',
      totalCost: 4500,
      status: 'Received',
    ),
    PurchaseOrder(
      po: '#PO-8820',
      date: 'Oct 24, 2023',
      supplier: 'Adidas Global Dist.',
      product: 'Jordan High Tops',
      qtyInfo: 'Qty: 20 · Unit: \$140.00',
      totalCost: 4450,
      status: 'Shipped',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          // 대시보드
          Column(
            // 대시보드
            children: [
              Text('dashboard overview'),
              Text(
                'welcome back, here`s happening today',
              ),
              SizedBox(
                width: double.infinity,
                height: 100,
                child: Row(
                  children: [
                    Icon(Icons.attach_money_outlined),
                    Column(
                      children: [
                        Text('매출'),
                        // server
                        Text('금액 나오는 곳'),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 400,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text('Top Selling Shoes'),
                    Row(
                      children: [
                        Container(
                          child: Row(
                            children: [
                              Image.asset(
                                'images/dog1.png',
                              ),
                              Column(
                                children: [
                                  Text('제품 이름'),
                                  Text('제품 색상'),
                                  Text('제품 브랜드'),
                                ],
                              ),
                              Text('제품 판매 수'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 대시보드 (end)

              // 상품등록 (start)
              Container(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.add_shopping_cart_sharp,
                        ),
                        Text('제품 등록'),
                      ],
                    ),
                    Row(
                      children: [
                        Column(
                          children: [
                            Text('제품'),
                            DropdownButton(
                              dropdownColor: Theme.of(
                                context,
                              ).colorScheme.secondary,
                              iconEnabledColor: Theme.of(
                                context,
                              ).colorScheme.error,
                              value: dropDownValue,
                              icon: Icon(
                                Icons.keyboard_arrow_down,
                              ),
                              items: items.map((
                                String items,
                              ) {
                                return DropdownMenuItem(
                                  value: items,
                                  child: Text(
                                    items,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                dropDownValue = value!;
                                imageName = value;
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text('제품 브랜드'),
                            DropdownButton(
                              dropdownColor: Theme.of(
                                context,
                              ).colorScheme.secondary,
                              iconEnabledColor: Theme.of(
                                context,
                              ).colorScheme.error,
                              value: dropDownValue,
                              icon: Icon(
                                Icons.keyboard_arrow_down,
                              ),
                              items: items.map((
                                String items,
                              ) {
                                return DropdownMenuItem(
                                  value: items,
                                  child: Text(
                                    items,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                dropDownValue = value!;

                                setState(() {});
                              },
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text('수량'),
                            DropdownButton<int>(
                              dropdownColor: Theme.of(
                                context,
                              ).colorScheme.secondary,
                              iconEnabledColor: Theme.of(
                                context,
                              ).colorScheme.error,
                              value: dropDownValue,
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                              ),

                              items: quantityItems.map((
                                int value,
                              ) {
                                return DropdownMenuItem<
                                  int
                                >(
                                  value: value,
                                  child: Text(
                                    '$value 개',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                    ),
                                  ),
                                );
                              }).toList(),

                              onChanged: (int? value) {
                                setState(() {
                                  dropDownValue = value!;
                                });
                              },
                            ),

                            // DropdownButtonFormField<int>(
                            //   value: dropDownValue,
                            //   decoration: InputDecoration(
                            //     contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                            //     border: OutlineInputBorder(
                            //       borderRadius: BorderRadius.circular(8),
                            //     ),
                            //   ),
                            //   items: quantityItems.map((int value) {
                            //     return DropdownMenuItem<int>(
                            //       value: value,
                            //       child: Text('$value 개'),
                            //     );
                            //   }).toList(),
                            //   onChanged: (value) {
                            //     setState(() {
                            //       dropDownValue = value!;
                            //     });
                            //   },
                            // ),
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          Get.to(AdminApprovalRequest()),
                      child: Text('상품 등록? 신청?'),
                    ),
                    // 제품 등록 (end)
                    //
                  ],
                ),
              ),
            ],
          ),
    );
  } // build

  // 제품 상태 테이블
  // 상태 뱃지 위젯
  Widget statusBadge(String status) {
    Color bg;
    Color text;

    switch (status) {
      case 'Received':
        bg = Colors.green.shade100;
        text = Colors.green;
        break;
      case 'Shipped':
        bg = Colors.blue.shade100;
        text = Colors.blue;
        break;
      case 'Pending':
        bg = Colors.orange.shade100;
        text = Colors.orange;
        break;
      case 'Cancelled':
        bg = Colors.grey.shade300;
        text = Colors.grey.shade700;
        break;
      default:
        bg = Colors.grey.shade200;
        text = Colors.black;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: text,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // 테이블 헤더
  Widget tableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: const [
          SizedBox(width: 40),
          Expanded(flex: 2, child: Text('PURCHASE INFO')),
          Expanded(flex: 2, child: Text('SUPPLIER')),
          Expanded(flex: 3, child: Text('PRODUCT')),
          Expanded(flex: 2, child: Text('TOTAL COST')),
          Expanded(flex: 2, child: Text('STATUS')),
          Expanded(flex: 1, child: Text('ACTIONS')),
        ],
      ),
    );
  }

  // 테이블 한 줄
  Widget tableRow(PurchaseOrder item) {
    // 데이터 불러올때 수정
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 40,
            child: Checkbox(
              value: false,
              onChanged: null,
            ),
          ),

          /// PURCHASE INFO
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  item.po,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  item.date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          /// SUPPLIER
          Expanded(flex: 2, child: Text(item.supplier)),

          /// PRODUCT
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(item.product),
                Text(
                  item.qtyInfo,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          /// TOTAL COST
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  '\$${item.totalCost.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Net 30',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          /// STATUS
          Expanded(
            flex: 2,
            child: statusBadge(item.status),
          ),

          /// ACTIONS
          const Expanded(
            flex: 1,
            child: Icon(Icons.more_horiz),
          ),
        ],
      ),
    );
  }
}
