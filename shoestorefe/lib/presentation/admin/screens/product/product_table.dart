import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../domain/entities/product.dart';
import '../../provider/product_provider.dart';
import '../../provider/brand_provider.dart';

class ProductTable extends StatelessWidget {
  final List<Product> products;
  const ProductTable({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final brandProvider = context.watch<BrandProvider>();

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
                DataColumn(label: Text('Hình ảnh')),
                DataColumn(label: Text('Tên')),
                DataColumn(label: Text('Thương hiệu')),
                DataColumn(label: Text('Màu sắc')),
                DataColumn(label: Center(child: Text('Kích thước'))),
                DataColumn(label: Text('Giá gốc')),
                DataColumn(label: Center(child: Text('Số lượng tồn'))),
                DataColumn(label: Text('Trạng thái')),
              ],
              rows:
                  products.map((p) {
                    final selected = provider.selectedProductId == p.id;
                    final totalQuantity = p.stores.fold<int>(
                      0,
                      (sum, s) => sum + s.quantity,
                    );
                    final brandName =
                        p.brandId != null &&
                                brandProvider.brands.any(
                                  (b) => b.id == p.brandId,
                                )
                            ? brandProvider.brands
                                .firstWhere((b) => b.id == p.brandId)
                                .name
                            : '-';

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
                                  provider.selectProduct(p.id);
                                } else {
                                  provider.selectProduct(null);
                                }
                              },
                            ),
                          ),
                        ),
                        DataCell(Text(p.id.toString())),
                        DataCell(
                          p.imageUrl != null && p.imageUrl!.isNotEmpty
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  p.imageUrl!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (
                                    context,
                                    child,
                                    loadingProgress,
                                  ) {
                                    if (loadingProgress == null) return child;
                                    return const SizedBox(
                                      width: 60,
                                      height: 60,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    // Log error để debug
                                    debugPrint(
                                      'Error loading image for product ${p.id}: ${p.imageUrl} - $error',
                                    );
                                    return const Icon(
                                      Icons.image_not_supported,
                                      size: 40,
                                      color: Colors.grey,
                                    );
                                  },
                                ),
                              )
                              : const Icon(
                                Icons.image_not_supported,
                                size: 40,
                                color: Colors.grey,
                              ),
                        ),
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 200),
                            child: Text(
                              p.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(Text(brandName)),
                        DataCell(Text(p.color ?? '-')),
                        DataCell(Center(child: Text(p.size ?? '-'))),
                        DataCell(
                          Text('${p.originalPrice.toStringAsFixed(0)} đ'),
                        ),
                        DataCell(Center(child: Text(totalQuantity.toString()))),
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
