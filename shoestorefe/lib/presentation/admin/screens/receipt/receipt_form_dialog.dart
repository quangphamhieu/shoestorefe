import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../domain/entities/product.dart';
import '../../provider/receipt_provider.dart';
import '../../provider/product_provider.dart';
import '../../provider/supplier_provider.dart';
import '../../provider/store_provider.dart';

class ReceiptFormDialog extends StatefulWidget {
  final bool editMode;
  final bool isReceiveMode; // true = nhận hàng, false = sửa thông tin
  const ReceiptFormDialog({
    super.key,
    required this.editMode,
    required this.isReceiveMode,
  });

  @override
  State<ReceiptFormDialog> createState() => _ReceiptFormDialogState();
}

class _ReceiptFormDialogState extends State<ReceiptFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _searchController;
  late final Map<int, TextEditingController> _quantityControllers;
  late final Map<int, TextEditingController> _receivedQuantityControllers;

  int? _supplierId;
  int? _storeId;
  bool _loading = false;
  bool _prefillLoading = false;

  List<Map<String, Object?>> _selectedProducts =
      <Map<String, Object?>>[]; // [{productId, productName, sku, supplierId, quantityOrdered, receivedQuantity, receiptDetailId?}]
  List<Product> _searchResults = [];
  bool _supplierReminderQueued = false;

  bool get _requiresSupplierSelection => !widget.isReceiveMode;

  void _showSupplierReminder() {
    if (!_requiresSupplierSelection) return;
    if (_supplierReminderQueued) return;
    _supplierReminderQueued = true;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vui lòng chọn nhà cung cấp trước')),
    );
    Future.delayed(const Duration(milliseconds: 1500), () {
      _supplierReminderQueued = false;
    });
  }

  void _removeSelectedProductsWhere(
    bool Function(Map<String, Object?>) predicate,
  ) {
    final removing = _selectedProducts.where(predicate).toList();
    for (final product in removing) {
      final id = product['productId'] as int;
      _quantityControllers[id]?.dispose();
      _quantityControllers.remove(id);
      _receivedQuantityControllers[id]?.dispose();
      _receivedQuantityControllers.remove(id);
    }
    _selectedProducts.removeWhere(predicate);
  }

  void _handleSupplierChange(int? supplierId) {
    final productProvider = context.read<ProductProvider>();
    setState(() {
      _supplierId = supplierId;
      _searchController.clear();
      _searchResults = [];

      if (supplierId == null) {
        _removeSelectedProductsWhere((_) => true);
      } else {
        final allowedIds =
            productProvider.products
                .where((p) => p.supplierId == supplierId)
                .map((p) => p.id)
                .toSet();
        _removeSelectedProductsWhere(
          (product) => !allowedIds.contains(product['productId'] as int),
        );
      }
    });
  }

  List<Product> _productsForSupplier(ProductProvider provider) {
    if (_supplierId == null) return [];
    return provider.products.where((p) => p.supplierId == _supplierId).toList();
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _quantityControllers = {};
    _receivedQuantityControllers = {};

    Future.microtask(() {
      context.read<ProductProvider>().loadAll();
      context.read<SupplierProvider>().loadAll();
      context.read<StoreProvider>().loadAll();
    });

    if (widget.editMode) {
      _prefillLoading = true;
      final provider = context.read<ReceiptProvider>();
      provider.getSelectedReceiptDetail().then((r) {
        if (!mounted || r == null) {
          setState(() => _prefillLoading = false);
          return;
        }
        setState(() {
          _supplierId = r.supplierId;
          _storeId = r.storeId;
          _selectedProducts =
              r.details
                  .map(
                    (d) => Map<String, Object?>.from({
                      'productId': d.productId,
                      'productName': d.productName ?? 'Unknown',
                      'sku': d.sku ?? d.productName ?? 'Unknown',
                      'supplierId': r.supplierId,
                      'quantityOrdered': d.quantityOrdered,
                      'receiptDetailId': d.id,
                      'receivedQuantity': d.receivedQuantity ?? 0,
                    }),
                  )
                  .toList();
          for (var product in _selectedProducts) {
            final productId = product['productId'] as int;
            _quantityControllers[productId] = TextEditingController(
              text: product['quantityOrdered'].toString(),
            );
            if (widget.isReceiveMode || widget.editMode) {
              _receivedQuantityControllers[productId] = TextEditingController(
                text: (product['receivedQuantity'] ?? 0).toString(),
              );
            }
          }
          _prefillLoading = false;
        });
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    for (var controller in _quantityControllers.values) {
      controller.dispose();
    }
    for (var controller in _receivedQuantityControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _searchProducts(String query) {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    if (_supplierId == null && _requiresSupplierSelection) {
      setState(() => _searchResults = []);
      _showSupplierReminder();
      return;
    }

    final productProvider = context.read<ProductProvider>();
    final q = query.toLowerCase();
    setState(() {
      _searchResults =
          _productsForSupplier(productProvider)
              .where((p) {
                final name = p.name.toLowerCase();
                final sku = (p.sku ?? '').toLowerCase();
                return name.contains(q) || sku.contains(q);
              })
              .where(
                (p) => !_selectedProducts.any(
                  (sp) => (sp['productId'] as int) == p.id,
                ),
              )
              .toList();
    });
  }

  void _addProduct(Product product) {
    if (_requiresSupplierSelection && _supplierId == null) {
      _showSupplierReminder();
      return;
    }

    if (_supplierId != null && product.supplierId != _supplierId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sản phẩm không thuộc nhà cung cấp này')),
      );
      return;
    }

    if (_selectedProducts.any((p) => p['productId'] == product.id)) return;

    setState(() {
      _selectedProducts.add(Map<String, Object?>.from({
        'productId': product.id,
        'productName': product.name,
        'sku': product.sku ?? product.name,
        'supplierId': product.supplierId,
        'quantityOrdered': 0,
        'receivedQuantity': 0,
      }));
      _quantityControllers[product.id] = TextEditingController(text: '0');
      if (widget.isReceiveMode || widget.editMode) {
        _receivedQuantityControllers[product.id] = TextEditingController(
          text: '0',
        );
      }
      _searchController.clear();
      _searchResults = [];
    });
  }

  void _removeProduct(int productId) {
    setState(() {
      _selectedProducts.removeWhere(
        (p) => (p['productId'] as int) == productId,
      );
      _quantityControllers[productId]?.dispose();
      _quantityControllers.remove(productId);
      _receivedQuantityControllers[productId]?.dispose();
      _receivedQuantityControllers.remove(productId);
    });
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    );
  }

  Future<void> _handleSubmit() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    if (_selectedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng thêm ít nhất một sản phẩm')),
      );
      return;
    }
    if (_supplierId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn nhà cung cấp')),
      );
      return;
    }

    final provider = context.read<ReceiptProvider>();
    bool success = false;

    setState(() => _loading = true);

    if (widget.isReceiveMode) {
      // Nhận hàng - update received quantities
      final details =
          _selectedProducts
              .map(
                (p) {
                  final productId = p['productId'] as int;
                  return {
                    'receiptDetailId': p['receiptDetailId'],
                    'receivedQuantity': int.parse(
                      _receivedQuantityControllers[productId]!.text,
                    ),
                  };
                },
              )
              .toList();
      final id = provider.selectedReceiptId;
      if (id != null) {
        success = await provider.updateReceiptReceived(id, details: details);
      }
    } else if (widget.editMode) {
      // Sửa thông tin - update info
      final details =
          _selectedProducts
              .map(
                (p) {
                  final productId = p['productId'] as int;
                  return {
                    'productId': productId,
                    'quantityOrdered': int.parse(
                      _quantityControllers[productId]!.text,
                    ),
                  };
                },
              )
              .toList();
      final id = provider.selectedReceiptId;
      if (id != null) {
        success = await provider.updateReceiptInfo(
          id,
          supplierId: _supplierId!,
          storeId: _storeId,
          details: details,
        );
      }
    } else {
      // Tạo mới
      final details =
          _selectedProducts
              .map(
                (p) {
                  final productId = p['productId'] as int;
                  return {
                    'productId': productId,
                    'quantityOrdered': int.parse(
                      _quantityControllers[productId]!.text,
                    ),
                  };
                },
              )
              .toList();
      success = await provider.createReceipt(
        supplierId: _supplierId!,
        storeId: _storeId,
        details: details,
      );
    }

    if (!mounted) return;

    setState(() => _loading = false);

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isReceiveMode
                ? 'Nhận hàng thất bại'
                : widget.editMode
                ? 'Cập nhật thất bại'
                : 'Tạo mới thất bại',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final supplierProvider = context.watch<SupplierProvider>();
    final storeProvider = context.watch<StoreProvider>();
    final productProvider = context.watch<ProductProvider>();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800, maxHeight: 900),
            child: Container(
              padding: const EdgeInsets.all(28),
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
              child:
                  _prefillLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  widget.isReceiveMode
                                      ? 'Nhận hàng'
                                      : widget.editMode
                                      ? 'Sửa phiếu nhập'
                                      : 'Thêm phiếu nhập',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                IconButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(false),
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<int?>(
                                    value:
                                        _supplierId != null &&
                                                supplierProvider.suppliers.any(
                                                  (s) => s.id == _supplierId,
                                                )
                                            ? _supplierId
                                            : null,
                                    decoration: _decoration(
                                      'Nhà cung cấp',
                                      required: true,
                                    ),
                                    items: [
                                      const DropdownMenuItem<int?>(
                                        value: null,
                                        child: Text('Chọn nhà cung cấp'),
                                      ),
                                      ...supplierProvider.suppliers.map(
                                        (s) => DropdownMenuItem<int?>(
                                          value: s.id,
                                          child: Text(s.name),
                                        ),
                                      ),
                                    ],
                                    onChanged:
                                        (widget.isReceiveMode ||
                                                widget.editMode)
                                            ? null
                                            : (v) => _handleSupplierChange(v),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: DropdownButtonFormField<int?>(
                                    value:
                                        _storeId != null &&
                                                storeProvider.stores.any(
                                                  (s) => s.id == _storeId,
                                                )
                                            ? _storeId
                                            : null,
                                    decoration: _decoration('Cửa hàng'),
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
                                        widget.isReceiveMode
                                            ? null
                                            : (v) =>
                                                setState(() => _storeId = v),
                                  ),
                                ),
                              ],
                            ),
                            if (!widget.isReceiveMode) ...[
                              const SizedBox(height: 20),
                              // Search and add products section
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.search,
                                          color: Color(0xFF64748B),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Tìm kiếm và thêm sản phẩm',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const Spacer(),
                                        IconButton(
                                          onPressed:
                                              _supplierId == null
                                                  ? _showSupplierReminder
                                                  : () {
                                                    final products =
                                                        _productsForSupplier(
                                                              productProvider,
                                                            )
                                                            .where(
                                                              (p) =>
                                                                  !_selectedProducts.any(
                                                                    (sp) =>
                                                                        (sp['productId'] as int) ==
                                                                        p.id,
                                                                  ),
                                                            )
                                                            .toList();
                                                    showDialog(
                                                      context: context,
                                                      builder:
                                                          (_) =>
                                                              _ProductSearchDialog(
                                                                products:
                                                                    products,
                                                                onSelect:
                                                                    _addProduct,
                                                              ),
                                                    );
                                                  },
                                          icon: Icon(
                                            Icons.add_circle_outline,
                                            color:
                                                _supplierId == null
                                                    ? Colors.grey
                                                    : const Color(0xFF2563EB),
                                          ),
                                          tooltip: 'Thêm sản phẩm',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: _searchController,
                                      onChanged: _searchProducts,
                                      enabled: _supplierId != null,
                                      decoration: InputDecoration(
                                        hintText:
                                            _supplierId == null
                                                ? 'Chọn nhà cung cấp trước'
                                                : 'Tìm kiếm sản phẩm...',
                                        prefixIcon: const Icon(
                                          Icons.search,
                                          color: Color(0xFF64748B),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              vertical: 12,
                                              horizontal: 16,
                                            ),
                                      ),
                                    ),
                                    if (_searchResults.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      Container(
                                        constraints: const BoxConstraints(
                                          maxHeight: 200,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFE2E8F0),
                                          ),
                                        ),
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: _searchResults.length,
                                          itemBuilder: (context, index) {
                                            final product =
                                                _searchResults[index];
                                            final sku =
                                                product.sku?.isNotEmpty == true
                                                    ? product.sku!
                                                    : product.name;
                                            return ListTile(
                                              title: Text(sku),
                                              trailing: IconButton(
                                                icon: const Icon(
                                                  Icons.add,
                                                  color: Color(0xFF2563EB),
                                                ),
                                                onPressed:
                                                    () => _addProduct(product),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),
                            // Selected products list
                            if (_selectedProducts.isNotEmpty) ...[
                              Text(
                                widget.isReceiveMode
                                    ? 'Sản phẩm nhận hàng'
                                    : 'Sản phẩm đã thêm',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                constraints: const BoxConstraints(
                                  maxHeight: 300,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _selectedProducts.length,
                                  itemBuilder: (context, index) {
                                    final product = _selectedProducts[index];
                                    final productId = product['productId'] as int;
                                    final sku =
                                        (product['sku'] as String?) ??
                                        (product['productName'] as String?) ??
                                        'Sản phẩm';
                                    final quantityOrdered =
                                        (product['quantityOrdered'] as int?) ?? 0;
                                    final receivedQuantity =
                                        (product['receivedQuantity'] as int?) ?? 0;
                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  sku ?? 'Sản phẩm',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                if (widget.isReceiveMode)
                                                  Text(
                                                    'Đã đặt: $quantityOrdered',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          if (!widget.isReceiveMode)
                                            SizedBox(
                                              width: 100,
                                              child: TextFormField(
                                                controller:
                                                    _quantityControllers[productId],
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                  labelText: 'Số lượng đặt',
                                                  isDense: true,
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty)
                                                    return 'Nhập SL';
                                                  final qty = int.tryParse(
                                                    value,
                                                  );
                                                  if (qty == null || qty <= 0)
                                                    return '> 0';
                                                  return null;
                                                },
                                              ),
                                            ),
                                          if (widget.editMode &&
                                              !widget.isReceiveMode)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                  ),
                                              child: SizedBox(
                                                width: 120,
                                                child: TextFormField(
                                                  controller:
                                                      _receivedQuantityControllers[productId],
                                                  readOnly: true,
                                                  decoration: InputDecoration(
                                                    labelText: 'Số lượng nhận',
                                                    isDense: true,
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          if (widget.isReceiveMode)
                                            SizedBox(
                                              width: 120,
                                              child: TextFormField(
                                                controller:
                                                    _receivedQuantityControllers[productId],
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                  labelText: 'Nhận',
                                                  isDense: true,
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty)
                                                    return 'Nhập SL';
                                                  final qty = int.tryParse(
                                                    value,
                                                  );
                                                  if (qty == null || qty < 0)
                                                    return '>= 0';
                                                  if (qty > quantityOrdered) {
                                                    return '<= $quantityOrdered';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                          const SizedBox(width: 12),
                                          if (!widget.isReceiveMode)
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                color: Color(0xFFDC2626),
                                              ),
                                              onPressed:
                                                  () =>
                                                      _removeProduct(productId),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed:
                                      _loading
                                          ? null
                                          : () =>
                                              Navigator.of(context).pop(false),
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
                                  onPressed:
                                      _prefillLoading
                                          ? null
                                          : () => _handleSubmit(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        widget.isReceiveMode
                                            ? const Color(0xFF0F9D58)
                                            : widget.editMode
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
                                          : Text(
                                            widget.isReceiveMode
                                                ? 'Xác nhận nhận hàng'
                                                : widget.editMode
                                                ? 'Lưu thay đổi'
                                                : 'Tạo phiếu nhập',
                                          ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductSearchDialog extends StatelessWidget {
  final List<Product> products;
  final Function(Product) onSelect;

  const _ProductSearchDialog({required this.products, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Chọn sản phẩm',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  final displaySku =
                      product.sku?.isNotEmpty == true
                          ? product.sku!
                          : product.name;
                  return ListTile(
                    title: Text(displaySku),
                    trailing: IconButton(
                      icon: const Icon(Icons.add, color: Color(0xFF2563EB)),
                      onPressed: () {
                        onSelect(product);
                        Navigator.of(context).pop();
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
