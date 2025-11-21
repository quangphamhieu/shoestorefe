import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../domain/entities/receipt.dart';
import '../../provider/receipt_provider.dart';

class ReceiptTable extends StatelessWidget {
  final List<Receipt> receipts;
  const ReceiptTable({super.key, required this.receipts});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReceiptProvider>();

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
                DataColumn(label: Text('Số phiếu')),
                DataColumn(label: Text('Nhà cung cấp')),
                DataColumn(label: Text('Cửa hàng')),
                DataColumn(label: Text('Người tạo')),
                DataColumn(label: Text('Ngày tạo')),
                DataColumn(label: Center(child: Text('Số sản phẩm'))),
                DataColumn(label: Text('Tổng tiền')),
                DataColumn(label: Text('Trạng thái')),
              ],
              rows:
                  receipts.map((r) {
                    final selected = provider.selectedReceiptId == r.id;
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
                                  provider.selectReceipt(r.id);
                                } else {
                                  provider.selectReceipt(null);
                                }
                              },
                            ),
                          ),
                        ),
                        DataCell(Text(r.id.toString())),
                        DataCell(Text(r.receiptNumber)),
                        DataCell(Text(r.supplierName ?? '-')),
                        DataCell(Text(r.storeName ?? '-')),
                        DataCell(Text(r.creatorName ?? '-')),
                        DataCell(
                          Text(
                            '${r.createdAt.day}/${r.createdAt.month}/${r.createdAt.year}',
                          ),
                        ),
                        DataCell(
                          Center(child: Text(r.details.length.toString())),
                        ),
                        DataCell(Text('${r.totalAmount.toStringAsFixed(0)} đ')),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  r.statusId == 1
                                      ? const Color(0xFFEFFAF3)
                                      : const Color(0xFFFFF1F2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              r.statusId == 1 ? 'Chờ nhận' : 'Đã nhận',
                              style: TextStyle(
                                color:
                                    r.statusId == 1
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
