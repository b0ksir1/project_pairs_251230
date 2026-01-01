import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:project_pairs_251230/model/stock.dart';
import 'package:project_pairs_251230/util/global_data.dart';
import 'package:project_pairs_251230/view/admin/admin_side_bar.dart';
import 'package:project_pairs_251230/util/side_menu.dart';
import 'package:http/http.dart' as http;

class AdminStockList extends StatefulWidget {
  const AdminStockList({super.key});

  @override
  State<AdminStockList> createState() => _AdminStockListState();
}

class _AdminStockListState extends State<AdminStockList> {
  String imageUrl = "${GlobalData.url}/images/view";
  String stockSelectAllUrl = "${GlobalData.url}/stock/selectAll";

  late List<Stock> _stockList;

  @override
  void initState() {
    super.initState();
    _stockList = [];

    getProductData();
  }

  // === Property ===
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AdminSideBar(selectedMenu: SideMenu.stock, onMenuSelected: (menu) {}),
          Expanded(
            child: _stockList.isEmpty
                ? Center(child: Text('데이터가 비어있음'))
                : Column(
                  children: [
                    _buildHead(), 
                    _buildListView()]),
          ),
        ],
      ),
    );
  } // build

  // === Widget ===


  Widget _buildListView() {
    return Expanded(
      child: ListView.builder(
        itemCount: _stockList.length,
        itemBuilder: (context, index) {
          return Card(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 15),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.15,
                  child: Text(_stockList[index].productName, style: bodyStyle())
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: Image.network(
                            '${GlobalData.url}/images/view/${_stockList[index].productId}?t=${DateTime.now().millisecondsSinceEpoch}',
                          width: 100,
                          height: 100,
                          )
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.1,
                  child: Text(_stockList[index].productQty.toString(), style: bodyStyle())
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.1,
                  child: Text('상품 상태', style: bodyStyle())
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  Widget _buildHead() {
    return Row(
       mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(width: 15),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.15,
          child: Text('상품명', style: headerStyle())
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          child: Text('상품 이미지', style: headerStyle())
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.1,
          child: Text('상품 갯수', style: headerStyle())
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.1,
          child: Text('상품 상태', style: headerStyle())
        ),
        
      ],
    );
  }

  TextStyle headerStyle() {
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
      color: Colors.grey,
    );
  }

  TextStyle bodyStyle() {
    return TextStyle(
      fontSize: 12,
      color: Colors.black,
    );
  }

  // === Functions ===

  Future getProductData() async {
    var url = Uri.parse(stockSelectAllUrl);
    var response = await http.get(url);

    print(response.body);

    if (response.statusCode == 200) {
      _stockList.clear();
      var dataConvertedData = json.decode(utf8.decode(response.bodyBytes));
      List results = dataConvertedData['results'];
      for (var item in results) {
        Stock stock = Stock(
          stockId: item["s.stock_id"],
          productId: item["s.stock_product_id"],
          productName: item["p.product_name"],
          productQty: item["s.stock_quantity"],
        );
        _stockList.add(stock);
      }
      setState(() {});
    } else {
      print("error : ${response.statusCode}");
    }
  }
} // class

/// MAIN CONTENT --------------------------------------------------------------

class _InventoryBody extends StatelessWidget {
  const _InventoryBody();

  @override
  Widget build(BuildContext context) {
    final items = _dummyItems;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Column(
        children: [
          _InventoryHeaderRow(),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  _InventoryColumnHeader(),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: Color(0xFFF3F4F6)),
                      itemBuilder: (context, index) {
                        return _InventoryRow(item: items[index]);
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'Showing 1 to 4 of 142 products',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Previous'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {},
                          child: const Text('Next'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InventoryHeaderRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(value: false, onChanged: (_) {}),
        const SizedBox(width: 8),
        const Text(
          'Product List',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _InventoryColumnHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const headerStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Colors.grey,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: const [
          SizedBox(width: 32), // checkbox
          SizedBox(
            child: Text('Product Image', style: headerStyle)),
          Expanded(flex: 3, child: Text('Product Name', style: headerStyle)),
          Expanded(flex: 2, child: Text('LOCATION', style: headerStyle)),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text('QUANTITY', style: headerStyle),
            ),
          ),
          SizedBox(
            width: 80,
            child: Center(child: Text('STATUS', style: headerStyle)),
          ),
          SizedBox(
            width: 48,
            child: Center(child: Text('ACTIONS', style: headerStyle)),
          ),
        ],
      ),
    );
  }
}

class _InventoryRow extends StatelessWidget {
  final InventoryItem item;

  const _InventoryRow({required this.item});

  Color _statusBg() {
    switch (item.status) {
      case StockStatus.inStock:
        return const Color(0xFFE5F9ED);
      case StockStatus.lowStock:
        return const Color(0xFFFFF1F2);
      case StockStatus.outOfStock:
        return const Color(0xFFF3F4F6);
    }
  }

  Color _statusColor() {
    switch (item.status) {
      case StockStatus.inStock:
        return const Color(0xFF16A34A);
      case StockStatus.lowStock:
        return const Color(0xFFDC2626);
      case StockStatus.outOfStock:
        return const Color(0xFF6B7280);
    }
  }

  String _statusText() {
    switch (item.status) {
      case StockStatus.inStock:
        return 'In Stock';
      case StockStatus.lowStock:
        return 'Low Stock';
      case StockStatus.outOfStock:
        return 'Out of Stock';
    }
  }

  @override
  Widget build(BuildContext context) {
    final qtyColor = item.status == StockStatus.lowStock
        ? const Color(0xFFDC2626)
        : Colors.black;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Checkbox(value: false, onChanged: (_) {}),
          const SizedBox(width: 8),
          // PRODUCT
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.image, size: 22, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.category,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // SKU / SUPPLIER
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.sku,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.home_work_outlined,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        item.supplier,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // LOCATION
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.locationMain,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.locationSub,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          // QUANTITY
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.quantity.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: qtyColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Reorder Pt: ${item.reorderPoint}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          // STATUS
          SizedBox(
            width: 80,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _statusBg(),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _statusText(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _statusColor(),
                  ),
                ),
              ),
            ),
          ),
          // ACTIONS
          SizedBox(
            width: 48,
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_horiz, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

/// DATA ----------------------------------------------------------------------

enum StockStatus { inStock, lowStock, outOfStock }

class InventoryItem {
  final String name;
  final String category;
  final String sku;
  final String supplier;
  final String locationMain;
  final String locationSub;
  final int quantity;
  final int reorderPoint;
  final StockStatus status;

  InventoryItem({
    required this.name,
    required this.category,
    required this.sku,
    required this.supplier,
    required this.locationMain,
    required this.locationSub,
    required this.quantity,
    required this.reorderPoint,
    required this.status,
  });
}

final List<InventoryItem> _dummyItems = [
  InventoryItem(
    name: 'Nike Air Max Red',
    category: 'Sports / Running',
    sku: 'NK-AM-2023',
    supplier: 'Nike Korea Ltd.',
    locationMain: 'Warehouse A',
    locationSub: 'Zone A-12 · Shelf 4',
    quantity: 450,
    reorderPoint: 50,
    status: StockStatus.inStock,
  ),
  InventoryItem(
    name: 'Jordan High Tops',
    category: 'Lifestyle / High-top',
    sku: 'JD-HT-RED',
    supplier: 'Jumpman Inc.',
    locationMain: 'Warehouse B',
    locationSub: 'Zone C-09 · Bin 2',
    quantity: 12,
    reorderPoint: 20,
    status: StockStatus.lowStock,
  ),
  InventoryItem(
    name: 'Classic Oxford',
    category: 'Formal / Leather',
    sku: 'CL-OX-BRN',
    supplier: 'Artisan Shoes',
    locationMain: 'Warehouse A',
    locationSub: 'Zone B-05 · Shelf 1',
    quantity: 120,
    reorderPoint: 30,
    status: StockStatus.inStock,
  ),
  InventoryItem(
    name: 'Adidas Ultraboost',
    category: 'Sports / Performance',
    sku: 'AD-UB-BLK',
    supplier: 'Adidas KR',
    locationMain: 'Store Front',
    locationSub: 'Display A',
    quantity: 0,
    reorderPoint: 10,
    status: StockStatus.outOfStock,
  ),
];
