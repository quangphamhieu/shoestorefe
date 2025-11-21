import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoestorefe/domain/entities/supplier.dart';
import '../../provider/supplier_provider.dart';

class SupplierTable extends StatelessWidget {
  final List<Supplier> suppliers;
  const SupplierTable({super.key, required this.suppliers});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SupplierProvider>();

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              columnSpacing: 28,
              dataRowMinHeight: 90,
              dataRowMaxHeight: 120,
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
                DataColumn(label: Text('Thông tin liên hệ')),
                DataColumn(label: Text('Trạng thái')),
              ],
              rows:
                  suppliers.map((s) {
                    final selected = provider.selectedSupplierId == s.id;
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
                                  provider.selectSupplier(s.id);
                                } else {
                                  provider.selectSupplier(null);
                                }
                              },
                            ),
                          ),
                        ),
                        DataCell(Text(s.id.toString())),
                        DataCell(Text(s.code ?? '-')),
                        DataCell(Text(s.name)),
                        DataCell(
                          Container(
                            constraints: const BoxConstraints(maxWidth: 350),
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              s.contactInfo?.isNotEmpty == true
                                  ? s.contactInfo!
                                  : '-',
                              softWrap: true,
                              maxLines: null,
                              style: const TextStyle(fontSize: 13, height: 1.5),
                            ),
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
                                  s.statusId == 1
                                      ? const Color(0xFFEFFAF3)
                                      : const Color(0xFFFFF1F2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              s.statusId == 1 ? 'Active' : 'Inactive',
                              style: TextStyle(
                                color:
                                    s.statusId == 1
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
