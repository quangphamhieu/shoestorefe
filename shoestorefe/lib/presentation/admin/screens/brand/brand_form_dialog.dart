import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/brand_provider.dart';

class BrandFormDialog extends StatefulWidget {
  final bool editMode;
  const BrandFormDialog({super.key, required this.editMode});

  @override
  State<BrandFormDialog> createState() => _BrandFormDialogState();
}

class _BrandFormDialogState extends State<BrandFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  int _statusId = 1;
  bool _loading = false;
  bool _prefillLoading = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();

    if (widget.editMode) {
      _prefillLoading = true;
      final provider = context.read<BrandProvider>();
      provider.getSelectedBrandDetail().then((b) {
        if (!mounted) return;
        if (b != null) {
          setState(() {
            _statusId = b.statusId;
            _codeController.text = b.code ?? '';
            _nameController.text = b.name;
            _descriptionController.text = b.description ?? '';
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
    _codeController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(
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

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _codeController,
            decoration: _inputDecoration(
              'Mã thương hiệu',
              hint: 'Nhập mã định danh',
              required: true,
            ),
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập mã thương hiệu';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _nameController,
            decoration: _inputDecoration(
              'Tên thương hiệu',
              hint: 'Nhập tên hiển thị',
              required: true,
            ),
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập tên thương hiệu';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _descriptionController,
            maxLines: 4,
            textInputAction: TextInputAction.newline,
            decoration: _inputDecoration(
              'Mô tả',
              hint: 'Mô tả ngắn gọn về thương hiệu',
              required: true,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập mô tả';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          if (widget.editMode)
            DropdownButtonFormField<int>(
              value: _statusId,
              decoration: _inputDecoration('Trạng thái', required: true),
              items: const [
                DropdownMenuItem(value: 1, child: Text('Active')),
                DropdownMenuItem(value: 2, child: Text('Inactive')),
              ],
              onChanged: (v) => setState(() => _statusId = v ?? 1),
            ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit(BuildContext context) async {
    if (_loading) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<BrandProvider>();
    final code = _codeController.text.trim();
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    setState(() => _loading = true);

    bool success = false;
    if (widget.editMode) {
      final id = provider.selectedBrandId;
      if (id != null) {
        success = await provider.updateBrand(
          id,
          name: name,
          code: code,
          description: description,
          statusId: _statusId,
        );
      }
    } else {
      success = await provider.createBrand(
        name: name,
        code: code,
        description: description,
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
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 26),
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
                          widget.editMode
                              ? 'Cập nhật thương hiệu'
                              : 'Thêm thương hiệu mới',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Điền đầy đủ thông tin bên dưới để ${widget.editMode ? 'chỉnh sửa' : 'tạo'} thương hiệu.',
                          style: const TextStyle(color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFF94A3B8),
                      ),
                      tooltip: 'Đóng',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (_prefillLoading)
                  const SizedBox(
                    height: 160,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  _buildForm(context),
                const SizedBox(height: 26),
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
                      onPressed:
                          _prefillLoading ? null : () => _handleSubmit(context),
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
                                    : 'Tạo thương hiệu',
                              ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
