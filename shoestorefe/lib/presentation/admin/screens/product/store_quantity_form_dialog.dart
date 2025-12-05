import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/product_provider.dart';
import '../../provider/store_provider.dart';

class StoreQuantityFormDialog extends StatefulWidget {
  final int productId;
  final int? storeId;
  final int? initialQuantity;
  final double? initialSalePrice;
  final bool editMode;

  const StoreQuantityFormDialog({
    super.key,
    required this.productId,
    this.storeId,
    this.initialQuantity,
    this.initialSalePrice,
    required this.editMode,
  });

  @override
  State<StoreQuantityFormDialog> createState() =>
      _StoreQuantityFormDialogState();
}

class _StoreQuantityFormDialogState extends State<StoreQuantityFormDialog> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedStoreId;
  late final TextEditingController _quantityController;
  late final TextEditingController _salePriceController;
  late final double _initialSalePriceValue;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
      text: widget.initialQuantity?.toString() ?? '0',
    );
    _initialSalePriceValue = widget.initialSalePrice ?? 0;
    _salePriceController = TextEditingController(
      text: _initialSalePriceValue.toString(),
    );
    _selectedStoreId = widget.storeId;

    // Đảm bảo stores đã được load
    Future.microtask(() {
      final storeProvider = context.read<StoreProvider>();
      if (storeProvider.stores.isEmpty) {
        storeProvider.loadAll();
      }
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _salePriceController.dispose();
    super.dispose();
  }

  InputDecoration _decoration(
    String label, {
    String? hint,
    bool required = false,
  }) {
    final suffix = required ? ' *' : '';
    return InputDecoration(
      labelText: '$label$suffix',
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFDC2626)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFDC2626)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    );
  }

  Future<void> _handleSubmit() async {
    if (_loading || !_formKey.currentState!.validate()) return;

    final productProvider = context.read<ProductProvider>();
    final storeProvider = context.read<StoreProvider>();
    final quantity = int.parse(_quantityController.text.trim());

    if (widget.editMode) {
      if (_selectedStoreId == null || widget.storeId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi: Không tìm thấy cửa hàng')),
        );
        return;
      }
      // Lấy storeName từ store list
      String? storeName;
      try {
        final store = storeProvider.stores.firstWhere(
          (s) => s.id == widget.storeId,
        );
        storeName = store.name;
      } catch (_) {
        // Nếu không tìm thấy, thử tìm với _selectedStoreId
        try {
          if (_selectedStoreId != null) {
            final store = storeProvider.stores.firstWhere(
              (s) => s.id == _selectedStoreId,
            );
            storeName = store.name;
          }
        } catch (_) {
          storeName = null;
        }
      }

      setState(() => _loading = true);
      try {
        final success = await productProvider.updateStoreQuantity(
          widget.productId,
          widget.storeId!,
          quantity,
          salePrice: null,
          storeName: storeName,
        );
        setState(() => _loading = false);
        if (mounted) {
          if (success) {
            Navigator.of(context).pop(true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cập nhật thất bại. Vui lòng thử lại'),
              ),
            );
          }
        }
      } catch (e) {
        setState(() => _loading = false);
        if (mounted) {
          final errorMsg = e.toString();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi: $errorMsg')));
        }
      }
    } else {
      if (_selectedStoreId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn cửa hàng')));
        return;
      }
      // Lấy storeName từ store list
      String? storeName;
      try {
        final store = storeProvider.stores.firstWhere(
          (s) => s.id == _selectedStoreId,
        );
        storeName = store.name;
      } catch (_) {
        storeName = null;
      }

      setState(() => _loading = true);
      try {
        final success = await productProvider.createStoreQuantity(
          widget.productId,
          _selectedStoreId!,
          quantity,
          salePrice: _initialSalePriceValue,
          storeName: storeName,
        );
        setState(() => _loading = false);
        if (mounted) {
          if (success) {
            Navigator.of(context).pop(true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Thêm thất bại. Cửa hàng đã tồn tại cho sản phẩm này',
                ),
              ),
            );
          }
        }
      } catch (e) {
        setState(() => _loading = false);
        if (mounted) {
          final errorMsg =
              e.toString().contains('Cửa hàng đã tồn tại')
                  ? 'Cửa hàng đã tồn tại cho sản phẩm này'
                  : 'Lỗi: ${e.toString()}';
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errorMsg)));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = context.watch<StoreProvider>();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
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
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.editMode
                        ? 'Cập nhật số lượng'
                        : 'Thêm số lượng tồn kho',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<int?>(
                value:
                    _selectedStoreId != null &&
                            storeProvider.stores.any(
                              (s) => s.id == _selectedStoreId,
                            )
                        ? _selectedStoreId
                        : null,
                decoration: _decoration('Cửa hàng', required: true),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Chọn cửa hàng'),
                  ),
                  ...storeProvider.stores.map(
                    (s) => DropdownMenuItem<int?>(
                      value: s.id,
                      child: Text(s.name),
                    ),
                  ),
                ],
                onChanged:
                    widget.editMode
                        ? null
                        : (value) => setState(() => _selectedStoreId = value),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _quantityController,
                decoration: _decoration('Số lượng', hint: '0', required: true),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty)
                    return 'Vui lòng nhập số lượng';
                  final qty = int.tryParse(value);
                  if (qty == null) return 'Số lượng không hợp lệ';
                  if (qty < 0) return 'Số lượng phải >= 0';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _salePriceController,
                decoration: _decoration('Giá bán tại cửa hàng', hint: '0'),
                readOnly: true,
                enabled: false,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _loading
                            ? null
                            : () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      foregroundColor: const Color(0xFF64748B),
                    ),
                    child: const Text('Hủy'),
                  ),
                  const SizedBox(width: 14),
                  ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          widget.editMode
                              ? const Color(0xFF87CEEB)
                              : const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child:
                        _loading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : Text(widget.editMode ? 'Lưu thay đổi' : 'Thêm'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
