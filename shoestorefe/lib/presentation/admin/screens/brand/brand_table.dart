import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoestorefe/domain/entities/brand.dart';
import '../../provider/brand_provider.dart';

class BrandTable extends StatelessWidget {
  final List<Brand> brands;
  const BrandTable({super.key, required this.brands});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BrandProvider>();

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              columnSpacing: 28,
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
                DataColumn(label: Text('Mô tả')),
                DataColumn(label: Text('Trạng thái')),
              ],
              rows:
                  brands.map((b) {
                    final selected = provider.selectedBrandId == b.id;
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
                                  provider.selectBrand(b.id);
                                } else {
                                  provider.selectBrand(null);
                                }
                              },
                            ),
                          ),
                        ),
                        DataCell(Text(b.id.toString())),
                        DataCell(Text(b.code ?? '-')),
                        DataCell(Text(b.name)),
                        DataCell(
                          Text(
                            b.description?.isNotEmpty == true
                                ? b.description!
                                : '-',
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  b.statusId == 1
                                      ? const Color(0xFFEFFAF3)
                                      : const Color(0xFFFFF1F2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              b.statusId == 1 ? 'Active' : 'Inactive',
                              style: TextStyle(
                                color:
                                    b.statusId == 1
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
