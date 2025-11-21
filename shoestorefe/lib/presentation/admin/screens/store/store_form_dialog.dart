import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/store_provider.dart';

class StoreFormDialog extends StatefulWidget {
  final bool editMode;
  const StoreFormDialog({super.key, required this.editMode});

  @override
  State<StoreFormDialog> createState() => _StoreFormDialogState();
}

class _StoreFormDialogState extends State<StoreFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  int _statusId = 1;
  bool _loading = false;
  bool _prefillLoading = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _phoneController = TextEditingController();

    if (widget.editMode) {
      _prefillLoading = true;
      final provider = context.read<StoreProvider>();
      provider.getSelectedStoreDetail().then((store) {
        if (!mounted) return;
        if (store != null) {
          setState(() {
            _codeController.text = store.code ?? '';
            _nameController.text = store.name;
            _addressController.text = store.address ?? '';
            _phoneController.text = store.phone ?? '';
            _statusId = store.statusId;
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
    _addressController.dispose();
    _phoneController.dispose();
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

  Widget _form(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _codeController,
            textInputAction: TextInputAction.next,
            decoration: _decoration(
              'Mã cửa hàng',
              hint: 'Nhập mã định danh',
              required: true,
            ),
            validator:
                (value) =>
                    (value == null || value.trim().isEmpty)
                        ? 'Vui lòng nhập mã cửa hàng'
                        : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _nameController,
            textInputAction: TextInputAction.next,
            decoration: _decoration(
              'Tên cửa hàng',
              hint: 'Nhập tên hiển thị',
              required: true,
            ),
            validator:
                (value) =>
                    (value == null || value.trim().isEmpty)
                        ? 'Vui lòng nhập tên cửa hàng'
                        : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _addressController,
            textInputAction: TextInputAction.next,
            minLines: 1,
            maxLines: 3,
            decoration: _decoration(
              'Địa chỉ',
              hint: 'Nhập địa chỉ cụ thể',
              required: true,
            ),
            validator:
                (value) =>
                    (value == null || value.trim().isEmpty)
                        ? 'Vui lòng nhập địa chỉ'
                        : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _phoneController,
            textInputAction: TextInputAction.done,
            decoration: _decoration(
              'Số điện thoại',
              hint: 'Nhập số liên hệ',
              required: true,
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập số điện thoại';
              }
              final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
              if (digitsOnly.length < 8) {
                return 'Số điện thoại không hợp lệ';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          if (widget.editMode)
            DropdownButtonFormField<int>(
              value: _statusId,
              decoration: _decoration('Trạng thái', required: true),
              items: const [
                DropdownMenuItem(value: 1, child: Text('Active')),
                DropdownMenuItem(value: 2, child: Text('Inactive')),
              ],
              onChanged: (value) => setState(() => _statusId = value ?? 1),
            ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_loading || !_formKey.currentState!.validate()) return;

    final provider = context.read<StoreProvider>();
    final code = _codeController.text.trim();
    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    final phone = _phoneController.text.trim();

    setState(() => _loading = true);

    bool success = false;
    if (widget.editMode) {
      final id = provider.selectedStoreId;
      if (id != null) {
        success = await provider.updateStore(
          id,
          name: name,
          code: code,
          address: address,
          phone: phone,
          statusId: _statusId,
        );
      }
    } else {
      success = await provider.createStore(
        name: name,
        code: code,
        address: address,
        phone: phone,
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
            widget.editMode
                ? 'Cập nhật cửa hàng thất bại'
                : 'Thêm cửa hàng thất bại',
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
          constraints: const BoxConstraints(maxWidth: 540),
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
                              ? 'Cập nhật cửa hàng'
                              : 'Thêm cửa hàng mới',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Điền đầy đủ thông tin bên dưới để ${widget.editMode ? 'chỉnh sửa' : 'tạo'} cửa hàng.',
                          style: const TextStyle(color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed:
                          _loading
                              ? null
                              : () => Navigator.of(context).pop(false),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFF94A3B8),
                      ),
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
                  _form(context),
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
                      onPressed: _prefillLoading ? null : _submit,
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
                                    : 'Tạo cửa hàng',
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
