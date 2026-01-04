import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 관리자 역할(네 프로젝트 enum이 있으면 그걸로 교체)
enum AdminRole { storeManager, headOffice, executive }

/// 기간 프리셋
enum SalesRangePreset { today, week, month, custom }

class AdminSalesChart extends StatefulWidget {
  // final AdminRole role;
  const AdminSalesChart({super.key, });

  @override
  State<AdminSalesChart> createState() => _AdminSalesChartState();
}

class _AdminSalesChartState extends State<AdminSalesChart> {
  final _currency = NumberFormat.currency(locale: 'ko_KR', symbol: '₩', decimalDigits: 0);

  SalesRangePreset preset = SalesRangePreset.today;
  DateTimeRange? customRange;

  // TODO: 실제 데이터로 교체 (Controller/Service에서 가져오기)
  int totalRevenue = 12450000;
  int totalOrders = 862;
  int totalQty = 1284;

  List<_ProductSalesRow> productRows = const [
    _ProductSalesRow(name: 'Nike Air Max', qty: 120, revenue: 2400000),
    _ProductSalesRow(name: 'Adidas Samba', qty: 95, revenue: 1850000),
    _ProductSalesRow(name: 'New Balance 530', qty: 80, revenue: 1600000),
    _ProductSalesRow(name: 'Converse Chuck 70', qty: 60, revenue: 900000),
  ];

  DateTimeRange get _effectiveRange {
    final now = DateTime.now();
    switch (preset) {
      case SalesRangePreset.today:
        final start = DateTime(now.year, now.month, now.day);
        final end = start.add(const Duration(days: 1));
        return DateTimeRange(start: start, end: end);
      case SalesRangePreset.week:
        // 월요일 시작 기준(원하면 변경)
        final start = DateTime(now.year, now.month, now.day).subtract(Duration(days: (now.weekday - 1)));
        final end = start.add(const Duration(days: 7));
        return DateTimeRange(start: start, end: end);
      case SalesRangePreset.month:
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 1);
        return DateTimeRange(start: start, end: end);
      case SalesRangePreset.custom:
        return customRange ??
            DateTimeRange(
              start: DateTime(now.year, now.month, now.day),
              end: DateTime(now.year, now.month, now.day).add(const Duration(days: 1)),
            );
    }
  }

  // String get _roleScopeLabel {
  //   switch (widget.role) {
  //     case AdminRole.storeManager:
  //       return "대리점 매출";
  //     case AdminRole.headOffice:
  //       return "전체 매출(본사)";
  //     case AdminRole.executive:
  //       return "전체 매출(임원)";
  //   }
  // }

  double get _avgOrderValue {
    if (totalOrders == 0) return 0;
    return totalRevenue / totalOrders;
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 1),
      initialDateRange: customRange ?? _effectiveRange,
      helpText: "기간 선택",
      saveText: "적용",
    );

    if (picked != null) {
      setState(() {
        customRange = picked;
        preset = SalesRangePreset.custom;
      });
      // TODO: 선택된 기간으로 매출 데이터 재조회
    }
  }

  void _exportCsv() {
    // TODO: 실제로는 파일 저장/공유 플로우 붙이기
    // (웹이면 다운로드, 모바일이면 share_plus 등)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("CSV 내보내기(샘플) - TODO 구현")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final range = _effectiveRange;
    final rangeText =
        "${DateFormat('yyyy.MM.dd').format(range.start)} ~ ${DateFormat('yyyy.MM.dd').format(range.end.subtract(const Duration(days: 1)))}";

    return Scaffold(
      appBar: AppBar(
        title: Text("매출 확인 · "),
        actions: [
          IconButton(
            tooltip: "CSV 내보내기",
            onPressed: _exportCsv,
            icon: const Icon(Icons.download_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: 새로고침 시 데이터 재조회
          await Future.delayed(const Duration(milliseconds: 400));
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _RangeFilterBar(
              preset: preset,
              rangeText: rangeText,
              onPresetChanged: (p) {
                setState(() => preset = p);
                if (p == SalesRangePreset.custom) {
                  _pickCustomRange();
                } else {
                  // TODO: 프리셋 기간으로 매출 데이터 재조회
                }
              },
              onPickCustom: _pickCustomRange,
            ),
            const SizedBox(height: 12),

            _KpiGrid(
              currency: _currency,
              totalRevenue: totalRevenue,
              totalOrders: totalOrders,
              totalQty: totalQty,
              avgOrderValue: _avgOrderValue,
            ),
            const SizedBox(height: 16),

            _SectionHeader(
              title: "매출 추이",
              trailing: _ChartModeToggle(
                onChanged: (mode) {
                  // TODO: 차트 모드(일/주/월) 전환 + 데이터 재조회 or 변환
                },
              ),
            ),
            const SizedBox(height: 8),
            _ChartPlaceholder(height: 220),
            const SizedBox(height: 16),

            _SectionHeader(title: "상품별 매출", trailing: Text("총 ${productRows.length}개")),
            const SizedBox(height: 8),
            _ProductSalesTable(currency: _currency, rows: productRows),
            const SizedBox(height: 24),

            _BottomActionBar(
              onExport: _exportCsv,
              onViewOrders: () {
                // TODO: 주문 목록 페이지로 이동
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("주문목록 보기 - TODO 연결")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// ------------------------
/// UI Components
/// ------------------------

class _RangeFilterBar extends StatelessWidget {
  final SalesRangePreset preset;
  final String rangeText;
  final ValueChanged<SalesRangePreset> onPresetChanged;
  final VoidCallback onPickCustom;

  const _RangeFilterBar({
    required this.preset,
    required this.rangeText,
    required this.onPresetChanged,
    required this.onPickCustom,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _presetChip(context, SalesRangePreset.today, "오늘"),
                  _presetChip(context, SalesRangePreset.week, "이번주"),
                  _presetChip(context, SalesRangePreset.month, "이번달"),
                  _presetChip(context, SalesRangePreset.custom, "기간선택"),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text("선택 기간", style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(rangeText, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _presetChip(BuildContext context, SalesRangePreset value, String label) {
    final selected = preset == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        onPresetChanged(value);
        if (value == SalesRangePreset.custom) onPickCustom();
      },
    );
  }
}

class _KpiGrid extends StatelessWidget {
  final NumberFormat currency;
  final int totalRevenue;
  final int totalOrders;
  final int totalQty;
  final double avgOrderValue;

  const _KpiGrid({
    required this.currency,
    required this.totalRevenue,
    required this.totalOrders,
    required this.totalQty,
    required this.avgOrderValue,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final wide = c.maxWidth >= 700;
        final crossAxisCount = wide ? 4 : 2;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: wide ? 2.6 : 2.2,
          children: [
            _KpiCard(
              icon: Icons.payments_outlined,
              title: "총 매출",
              value: currency.format(totalRevenue),
              subtitle: "기간 내 결제 합계",
            ),
            _KpiCard(
              icon: Icons.receipt_long_outlined,
              title: "주문 수",
              value: "${NumberFormat.decimalPattern('ko_KR').format(totalOrders)}건",
              subtitle: "결제 완료 기준",
            ),
            _KpiCard(
              icon: Icons.inventory_2_outlined,
              title: "판매 수량",
              value: "${NumberFormat.decimalPattern('ko_KR').format(totalQty)}개",
              subtitle: "상품 수량 합계",
            ),
            _KpiCard(
              icon: Icons.trending_up_outlined,
              title: "평균 객단가",
              value: currency.format(avgOrderValue.round()),
              subtitle: "총 매출 ÷ 주문 수",
            ),
          ],
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  const _KpiCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              child: Icon(icon),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const _SectionHeader({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

enum _ChartMode { daily, weekly, monthly }

class _ChartModeToggle extends StatefulWidget {
  final ValueChanged<_ChartMode> onChanged;
  const _ChartModeToggle({required this.onChanged});

  @override
  State<_ChartModeToggle> createState() => _ChartModeToggleState();
}

class _ChartModeToggleState extends State<_ChartModeToggle> {
  _ChartMode mode = _ChartMode.daily;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<_ChartMode>(
      segments: const [
        ButtonSegment(value: _ChartMode.daily, label: Text("일별")),
        ButtonSegment(value: _ChartMode.weekly, label: Text("주별")),
        ButtonSegment(value: _ChartMode.monthly, label: Text("월별")),
      ],
      selected: {mode},
      onSelectionChanged: (set) {
        final next = set.first;
        setState(() => mode = next);
        widget.onChanged(next);
      },
    );
  }
}

class _ChartPlaceholder extends StatelessWidget {
  final double height;
  const _ChartPlaceholder({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text("차트 영역 (fl_chart 붙일 자리)", style: TextStyle(color: Colors.grey)),
      ),
    );
  }
}

class _ProductSalesTable extends StatefulWidget {
  final NumberFormat currency;
  final List<_ProductSalesRow> rows;

  const _ProductSalesTable({required this.currency, required this.rows});

  @override
  State<_ProductSalesTable> createState() => _ProductSalesTableState();
}

class _ProductSalesTableState extends State<_ProductSalesTable> {
  int? sortColumnIndex = 2; // revenue
  bool ascending = false;

  List<_ProductSalesRow> get _sorted {
    final list = widget.rows.toList();
    if (sortColumnIndex == null) return list;

    int cmp(_ProductSalesRow a, _ProductSalesRow b) {
      switch (sortColumnIndex) {
        case 0:
          return a.name.compareTo(b.name);
        case 1:
          return a.qty.compareTo(b.qty);
        case 2:
          return a.revenue.compareTo(b.revenue);
        default:
          return 0;
      }
    }

    list.sort((a, b) => ascending ? cmp(a, b) : cmp(b, a));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final totalRevenue = widget.rows.fold<int>(0, (p, e) => p + e.revenue);

    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          sortColumnIndex: sortColumnIndex,
          sortAscending: ascending,
          columns: [
            DataColumn(
              label: const Text("상품명"),
              onSort: (_, asc) => _sort(0, asc),
            ),
            DataColumn(
              numeric: true,
              label: const Text("판매수량"),
              onSort: (_, asc) => _sort(1, asc),
            ),
            DataColumn(
              numeric: true,
              label: const Text("매출"),
              onSort: (_, asc) => _sort(2, asc),
            ),
            const DataColumn(
              numeric: true,
              label: Text("비중"),
            ),
          ],
          rows: _sorted.map((r) {
            final ratio = totalRevenue == 0 ? 0 : (r.revenue / totalRevenue) * 100;
            return DataRow(
              cells: [
                DataCell(Text(r.name)),
                DataCell(Text(NumberFormat.decimalPattern('ko_KR').format(r.qty))),
                DataCell(Text(widget.currency.format(r.revenue))),
                DataCell(Text("${ratio.toStringAsFixed(1)}%")),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _sort(int col, bool asc) {
    setState(() {
      sortColumnIndex = col;
      ascending = asc;
    });
  }
}

class _BottomActionBar extends StatelessWidget {
  final VoidCallback onExport;
  final VoidCallback onViewOrders;

  const _BottomActionBar({required this.onExport, required this.onViewOrders});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onViewOrders,
            icon: const Icon(Icons.list_alt_outlined),
            label: const Text("주문목록 보기"),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: onExport,
            icon: const Icon(Icons.download_outlined),
            label: const Text("CSV 내보내기"),
          ),
        ),
      ],
    );
  }
}

class _ProductSalesRow {
  final String name;
  final int qty;
  final int revenue;
  const _ProductSalesRow({required this.name, required this.qty, required this.revenue});
}
