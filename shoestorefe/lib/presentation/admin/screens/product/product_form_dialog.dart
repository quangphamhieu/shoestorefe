import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../../provider/product_provider.dart';
import '../../provider/brand_provider.dart';
import '../../provider/supplier_provider.dart';
import '../../../../core/utils/image_picker_stub.dart'
    if (dart.library.io) 'package:image_picker/image_picker.dart';

class ProductFormDialog extends StatefulWidget {
  final bool editMode;
  const ProductFormDialog({super.key, required this.editMode});

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _costPriceController;
  late final TextEditingController _originalPriceController;
  late final TextEditingController _colorController;
  late final TextEditingController _sizeController;
  late final TextEditingController _descriptionController;

  int? _brandId;
  int? _supplierId;
  int _statusId = 1;
  bool _loading = false;
  bool _prefillLoading = false;
  String? _imageUrl;
  File? _imageFile;
  Uint8List? _imageBytes;
  String? _imageFileName;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _costPriceController = TextEditingController();
    _originalPriceController = TextEditingController();
    _colorController = TextEditingController();
    _sizeController = TextEditingController();
    _descriptionController = TextEditingController();

    Future.microtask(() {
      context.read<BrandProvider>().loadAll();
      context.read<SupplierProvider>().loadAll();
    });

    if (widget.editMode) {
      _prefillLoading = true;
      final provider = context.read<ProductProvider>();
      provider.getSelectedProductDetail().then((p) {
        if (!mounted) return;
        if (p != null) {
          setState(() {
            _nameController.text = p.name;
            _brandId = p.brandId;
            _supplierId = p.supplierId;
            _costPriceController.text = p.costPrice.toString();
            _originalPriceController.text = p.originalPrice.toString();
            _colorController.text = p.color ?? '';
            _sizeController.text = p.size ?? '';
            _descriptionController.text = p.description ?? '';
            _imageUrl = p.imageUrl;
            _statusId = p.statusId;
            _prefillLoading = false;
          });
        } else {
          setState(() => _prefillLoading = false);
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _costPriceController.dispose();
    _originalPriceController.dispose();
    _colorController.dispose();
    _sizeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      if (kIsWeb) {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );
        if (result != null && result.files.single.bytes != null && mounted) {
          setState(() {
            _imageBytes = result.files.single.bytes;
            _imageFileName = result.files.single.name;
            _imageFile = null;
            _imageUrl = null;
          });
        }
      } else {
        // Use image_picker for mobile
        try {
          final picker = ImagePicker();
          final XFile? image = await picker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 85,
          );
          if (image != null && mounted) {
            setState(() {
              _imageFile = File(image.path);
              _imageBytes = null;
              _imageFileName = null;
              _imageUrl = null;
            });
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi khi chọn ảnh từ thư viện: $e')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi chọn ảnh: $e')));
      }
    }
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

  Widget _buildImagePlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            'Chọn ảnh',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_loading || !_formKey.currentState!.validate()) return;

    final provider = context.read<ProductProvider>();
    final name = _nameController.text.trim();
    final costPrice = double.parse(_costPriceController.text.trim());
    final originalPrice = double.parse(_originalPriceController.text.trim());
    final color =
        _colorController.text.trim().isEmpty
            ? null
            : _colorController.text.trim();
    final size =
        _sizeController.text.trim().isEmpty
            ? null
            : _sizeController.text.trim();
    final description =
        _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim();

    setState(() => _loading = true);

    bool success = false;
    if (widget.editMode) {
      final id = provider.selectedProductId;
      if (id != null) {
        success = await provider.updateProduct(
          id,
          name: name,
          brandId: _brandId,
          supplierId: _supplierId,
          costPrice: costPrice,
          originalPrice: originalPrice,
          color: color,
          size: size,
          description: description,
          imageUrl:
              (_imageFile == null && _imageBytes == null) ? _imageUrl : null,
          imageFilePath: _imageFile?.path,
          imageBytes: _imageBytes?.toList(),
          imageFileName: _imageFileName,
          statusId: _statusId,
        );
      }
    } else {
      success = await provider.createProduct(
        name: name,
        brandId: _brandId,
        supplierId: _supplierId,
        costPrice: costPrice,
        originalPrice: originalPrice,
        color: color,
        size: size,
        description: description,
        imageUrl:
            (_imageFile == null && _imageBytes == null) ? _imageUrl : null,
        imageFilePath: _imageFile?.path,
        imageBytes: _imageBytes?.toList(),
        imageFileName: _imageFileName,
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
            widget.editMode ? 'Cập nhật thất bại' : 'Tạo mới thất bại',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final brandProvider = context.watch<BrandProvider>();
    final supplierProvider = context.watch<SupplierProvider>();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
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
                                  widget.editMode
                                      ? 'Sửa sản phẩm'
                                      : 'Thêm sản phẩm',
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
                            TextFormField(
                              controller: _nameController,
                              decoration: _decoration(
                                'Tên sản phẩm',
                                hint: 'Nhập tên sản phẩm',
                                required: true,
                              ),
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty)
                                  return 'Vui lòng nhập tên sản phẩm';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<int?>(
                                    value:
                                        _brandId != null &&
                                                brandProvider.brands.any(
                                                  (b) => b.id == _brandId,
                                                )
                                            ? _brandId
                                            : null,
                                    decoration: _decoration('Thương hiệu'),
                                    items: [
                                      const DropdownMenuItem<int?>(
                                        value: null,
                                        child: Text('Chọn thương hiệu'),
                                      ),
                                      ...brandProvider.brands.map(
                                        (b) => DropdownMenuItem<int?>(
                                          value: b.id,
                                          child: Text(b.name),
                                        ),
                                      ),
                                    ],
                                    onChanged:
                                        (v) => setState(() => _brandId = v),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: DropdownButtonFormField<int?>(
                                    value:
                                        _supplierId != null &&
                                                supplierProvider.suppliers.any(
                                                  (s) => s.id == _supplierId,
                                                )
                                            ? _supplierId
                                            : null,
                                    decoration: _decoration('Nhà cung cấp'),
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
                                        (v) => setState(() => _supplierId = v),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _costPriceController,
                                    decoration: _decoration(
                                      'Giá vốn',
                                      hint: '0',
                                      required: true,
                                    ),
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.next,
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty)
                                        return 'Vui lòng nhập giá vốn';
                                      if (double.tryParse(value) == null)
                                        return 'Giá không hợp lệ';
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: TextFormField(
                                    controller: _originalPriceController,
                                    decoration: _decoration(
                                      'Giá gốc',
                                      hint: '0',
                                      required: true,
                                    ),
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.next,
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty)
                                        return 'Vui lòng nhập giá gốc';
                                      if (double.tryParse(value) == null)
                                        return 'Giá không hợp lệ';
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _colorController,
                                    decoration: _decoration(
                                      'Màu sắc',
                                      hint: 'Nhập màu sắc',
                                    ),
                                    textInputAction: TextInputAction.next,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: TextFormField(
                                    controller: _sizeController,
                                    decoration: _decoration(
                                      'Kích thước',
                                      hint: 'Nhập kích thước',
                                    ),
                                    textInputAction: TextInputAction.next,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _descriptionController,
                              maxLines: 3,
                              decoration: _decoration(
                                'Mô tả',
                                hint: 'Mô tả sản phẩm',
                              ),
                              textInputAction: TextInputAction.newline,
                            ),
                            const SizedBox(height: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hình ảnh sản phẩm',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: _pickImage,
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    height: 120,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    child:
                                        _imageFile != null
                                            ? Stack(
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  child: Image.file(
                                                    _imageFile!,
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 8,
                                                  right: 8,
                                                  child: IconButton(
                                                    icon: const Icon(
                                                      Icons.close,
                                                      color: Colors.white,
                                                    ),
                                                    style: IconButton.styleFrom(
                                                      backgroundColor:
                                                          Colors.black54,
                                                      padding:
                                                          const EdgeInsets.all(
                                                            4,
                                                          ),
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        _imageFile = null;
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ],
                                            )
                                            : _imageBytes != null
                                            ? Stack(
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  child: Image.memory(
                                                    _imageBytes!,
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 8,
                                                  right: 8,
                                                  child: IconButton(
                                                    icon: const Icon(
                                                      Icons.close,
                                                      color: Colors.white,
                                                    ),
                                                    style: IconButton.styleFrom(
                                                      backgroundColor:
                                                          Colors.black54,
                                                      padding:
                                                          const EdgeInsets.all(
                                                            4,
                                                          ),
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        _imageBytes = null;
                                                        _imageFileName = null;
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ],
                                            )
                                            : _imageUrl != null &&
                                                _imageUrl!.isNotEmpty
                                            ? Stack(
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  child: Image.network(
                                                    _imageUrl!,
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                    errorBuilder:
                                                        (_, __, ___) =>
                                                            _buildImagePlaceholder(),
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 8,
                                                  right: 8,
                                                  child: IconButton(
                                                    icon: const Icon(
                                                      Icons.close,
                                                      color: Colors.white,
                                                    ),
                                                    style: IconButton.styleFrom(
                                                      backgroundColor:
                                                          Colors.black54,
                                                      padding:
                                                          const EdgeInsets.all(
                                                            4,
                                                          ),
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        _imageUrl = null;
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ],
                                            )
                                            : _buildImagePlaceholder(),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            if (widget.editMode && !_prefillLoading)
                              DropdownButtonFormField<int>(
                                value:
                                    _statusId == 1 || _statusId == 2
                                        ? _statusId
                                        : 1,
                                decoration: _decoration(
                                  'Trạng thái',
                                  required: true,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 1,
                                    child: Text('Active'),
                                  ),
                                  DropdownMenuItem(
                                    value: 2,
                                    child: Text('Inactive'),
                                  ),
                                ],
                                onChanged:
                                    (v) => setState(() => _statusId = v ?? 1),
                              ),
                            const SizedBox(height: 24),
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
                                          : Text(
                                            widget.editMode
                                                ? 'Lưu thay đổi'
                                                : 'Tạo sản phẩm',
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
