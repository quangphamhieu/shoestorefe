import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoestorefe/domain/entities/store.dart';
import '../../provider/store_provider.dart';

class StoreTable extends StatelessWidget {
  final List<Store> stores;
  const StoreTable({super.key, required this.stores});

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StoreProvider>();

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
                DataColumn(label: Text('Địa chỉ')),
                DataColumn(label: Text('Số điện thoại')),
                DataColumn(label: Text('Trạng thái')),
                DataColumn(label: Text('Ngày tạo')),
              ],
              rows:
                  stores.map((store) {
                    final selected = provider.selectedStoreId == store.id;
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
                              onChanged: (value) {
                                if (value == true) {
                                  provider.selectStore(store.id);
                                } else {
                                  provider.selectStore(null);
                                }
                              },
                            ),
                          ),
                        ),
                        DataCell(Text(store.id.toString())),
                        DataCell(Text(store.code ?? '-')),
                        DataCell(Text(store.name)),
                        DataCell(
                          Text(
                            store.address?.isNotEmpty == true
                                ? store.address!
                                : '-',
                          ),
                        ),
                        DataCell(
                          Text(
                            store.phone?.isNotEmpty == true
                                ? store.phone!
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
                                  store.statusId == 1
                                      ? const Color(0xFFEFFAF3)
                                      : const Color(0xFFFFF1F2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              store.statusId == 1 ? 'Active' : 'Inactive',
                              style: TextStyle(
                                color:
                                    store.statusId == 1
                                        ? const Color(0xFF0F9D58)
                                        : const Color(0xFFDC2626),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        DataCell(Text(_formatDate(store.createdAt))),
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
