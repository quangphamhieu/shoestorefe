import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../domain/entities/product.dart';
import '../../provider/product_provider.dart';
import '../../provider/store_provider.dart';
import 'store_quantity_form_dialog.dart';

class StoreProductDetailDialog extends StatefulWidget {
  const StoreProductDetailDialog({super.key});

  @override
  State<StoreProductDetailDialog> createState() =>
      _StoreProductDetailDialogState();
}

class _StoreProductDetailDialogState extends State<StoreProductDetailDialog> {
  Future<Product?>? _productFuture;

  @override
  void initState() {
    super.initState();
    final productProvider = context.read<ProductProvider>();
    final productId = productProvider.selectedProductId;
    _productFuture = productProvider.getSelectedProductDetail();
    Future.microtask(() {
      context.read<StoreProvider>().loadAll();
    });
  }

  void _reloadProduct() {
    final productProvider = context.read<ProductProvider>();
    final productId = productProvider.selectedProductId;
    if (productId != null) {
      setState(() {
        _productFuture = productProvider.getSelectedProductDetail();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final productId = productProvider.selectedProductId;

    if (productId == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder(
      future: _productFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Dialog(
            child: Container(
              padding: const EdgeInsets.all(40),
              child: const Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final product = snapshot.data;
        if (product == null) {
          return const SizedBox.shrink();
        }

        final stores = product.stores;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 30,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chi tiết số lượng tồn kho',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sản phẩm: ${product.name}',
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              final success = await showDialog<bool>(
                                context: context,
                                builder:
                                    (_) => StoreQuantityFormDialog(
                                      productId: productId,
                                      editMode: false,
                                      initialSalePrice: product.originalPrice,
                                    ),
                              );
                              if (success == true && mounted) {
                                _reloadProduct();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Thêm số lượng thành công'),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Thêm'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF90EE90),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(14),
                              topRight: Radius.circular(14),
                            ),
                            border: Border(
                              bottom: BorderSide(
                                color:
                                    stores.isEmpty
                                        ? Colors.transparent
                                        : const Color(0xFFE2E8F0),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Cửa hàng',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1F2933),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Số lượng',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1F2933),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Giá bán',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1F2933),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 100),
                            ],
                          ),
                        ),
                        if (stores.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(40),
                            child: Center(
                              child: Text(
                                'Chưa có thông tin số lượng tại cửa hàng nào',
                                style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ),
                          )
                        else
                          ...stores.map(
                            (store) => Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color:
                                        stores.indexOf(store) <
                                                stores.length - 1
                                            ? const Color(0xFFE2E8F0)
                                            : Colors.transparent,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      store.storeName,
                                      style: const TextStyle(
                                        color: Color(0xFF334155),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              store.quantity > 0
                                                  ? const Color(0xFFEFFAF3)
                                                  : const Color(0xFFFFF1F2),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          store.quantity.toString(),
                                          style: TextStyle(
                                            color:
                                                store.quantity > 0
                                                    ? const Color(0xFF0F9D58)
                                                    : const Color(0xFFDC2626),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        '${store.salePrice.toStringAsFixed(0)} đ',
                                        style: const TextStyle(
                                          color: Color(0xFF334155),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 100,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          onPressed: () async {
                                            final success = await showDialog<
                                              bool
                                            >(
                                              context: context,
                                              builder:
                                                  (_) =>
                                                      StoreQuantityFormDialog(
                                                        productId: productId,
                                                        storeId: store.storeId,
                                                        initialQuantity:
                                                            store.quantity,
                                                        initialSalePrice:
                                                            store.salePrice,
                                                        editMode: true,
                                                      ),
                                            );
                                            if (success == true && mounted) {
                                              _reloadProduct();
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Cập nhật số lượng thành công',
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          icon: const Icon(
                                            Icons.edit_outlined,
                                            color: Color(0xFF2563EB),
                                            size: 20,
                                          ),
                                          tooltip: 'Sửa',
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
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('Đóng'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
