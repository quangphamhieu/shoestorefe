import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../domain/entities/promotion.dart';
import '../../provider/promotion_provider.dart';

class PromotionTable extends StatelessWidget {
  final List<Promotion> promotions;
  const PromotionTable({super.key, required this.promotions});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PromotionProvider>();

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              columnSpacing: 20,
              headingTextStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2933),
              ),
              dataTextStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xFF334155),
              ),
              dividerThickness: 0.3,
              headingRowColor: MaterialStateProperty.all(
                const Color(0xFFF1F5F9),
              ),
              dataRowColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return const Color(0xFFEFF6FF);
                }
                return Colors.white;
              }),
              columns: const [
                DataColumn(label: SizedBox(width: 32)),
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Code')),
                DataColumn(label: Text('Tên')),
                DataColumn(label: Text('Ngày bắt đầu')),
                DataColumn(label: Text('Ngày kết thúc')),
                DataColumn(label: Center(child: Text('Số sản phẩm'))),
                DataColumn(label: Text('Trạng thái')),
              ],
              rows:
                  promotions.map((p) {
                    final selected = provider.selectedPromotionId == p.id;
                    return DataRow(
                      selected: selected,
                      cells: [
                        DataCell(
                          Center(
                            child: Checkbox(
                              value: selected,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              onChanged: (v) {
                                if (v == true) {
                                  provider.selectPromotion(p.id);
                                } else {
                                  provider.selectPromotion(null);
                                }
                              },
                            ),
                          ),
                        ),
                        DataCell(Text(p.id.toString())),
                        DataCell(Text(p.code ?? '-')),
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 200),
                            child: Text(
                              p.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            '${p.startDate.day}/${p.startDate.month}/${p.startDate.year}',
                          ),
                        ),
                        DataCell(
                          Text(
                            '${p.endDate.day}/${p.endDate.month}/${p.endDate.year}',
                          ),
                        ),
                        DataCell(
                          Center(child: Text(p.products.length.toString())),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  p.statusId == 1
                                      ? const Color(0xFFEFFAF3)
                                      : const Color(0xFFFFF1F2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              p.statusId == 1 ? 'Active' : 'Inactive',
                              style: TextStyle(
                                color:
                                    p.statusId == 1
                                        ? const Color(0xFF0F9D58)
                                        : const Color(0xFFDC2626),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
            ),
          ),
        );
      },
    );
  }
}
