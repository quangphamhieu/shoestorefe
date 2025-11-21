import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/user_provider.dart';
import '../../provider/store_provider.dart';

class UserFormDialog extends StatefulWidget {
  final bool editMode;
  const UserFormDialog({super.key, required this.editMode});

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameC;
  late TextEditingController _phoneC;
  late TextEditingController _emailC;
  late TextEditingController _passwordC;
  int _gender = 0;
  int _roleId = 2;
  int? _storeId;
  int _statusId = 1;
  bool _loading = false;
  bool _prefillLoading = false;

  int _mapRoleNameToId(String roleName) {
    final lower = roleName.toLowerCase();
    if (lower.contains('admin')) return 2;
    if (lower.contains('staff')) return 3;
    return 3;
  }

  @override
  void initState() {
    super.initState();
    _nameC = TextEditingController();
    _phoneC = TextEditingController();
    _emailC = TextEditingController();
    _passwordC = TextEditingController();

    Future.microtask(() {
      context.read<StoreProvider>().loadAll();
    });

    if (widget.editMode) {
      _prefillLoading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final provider = context.read<UserProvider>();
        final u = await provider.getSelectedUserDetail();
        if (!mounted) return;
        if (u != null) {
          _nameC.text = u.fullName;
          _phoneC.text = u.phone;
          _emailC.text = u.email ?? '';
          _gender = u.gender;
          _roleId = _mapRoleNameToId(u.roleName);
          _statusId = u.statusName.toLowerCase().contains('active') ? 1 : 2;
          _storeId = u.storeId;
        }
        setState(() => _prefillLoading = false);
      });
    }
  }

  @override
  void dispose() {
    _nameC.dispose();
    _phoneC.dispose();
    _emailC.dispose();
    _passwordC.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final provider = context.read<UserProvider>();
    final name = _nameC.text.trim();
    final phone = _phoneC.text.trim();
    final email = _emailC.text.trim().isEmpty ? null : _emailC.text.trim();

    bool success = false;
    if (widget.editMode) {
      final id = provider.selectedUserId;
      if (id != null) {
        success = await provider.updateUser(
          id: id,
          fullName: name,
          phone: phone,
          email: email,
          gender: _gender,
          roleId: _roleId,
          storeId: _storeId,
          statusId: _statusId,
        );
      }
    } else {
      success = await provider.createUser(
        fullName: name,
        phone: phone,
        email: email,
        password: _passwordC.text.trim(),
        gender: _gender,
        roleId: _roleId,
        storeId: _storeId,
      );
    }

    if (!mounted) return;
    setState(() => _loading = false);
    if (success) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.editMode ? 'Cập nhật thất bại' : 'Tạo thất bại'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    final storeProvider = context.watch<StoreProvider>();
    final submitting = _loading || provider.isCreating || provider.isUpdating;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                                      ? 'Sửa người dùng'
                                      : 'Thêm người dùng',
                                  style: const TextStyle(
                                    fontSize: 20,
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
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _nameC,
                              decoration: InputDecoration(
                                labelText: 'Họ & tên *',
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator:
                                  (v) =>
                                      v == null || v.trim().isEmpty
                                          ? 'Vui lòng nhập tên'
                                          : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _phoneC,
                              decoration: InputDecoration(
                                labelText: 'Số điện thoại *',
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator:
                                  (v) =>
                                      v == null || v.trim().isEmpty
                                          ? 'Vui lòng nhập số điện thoại'
                                          : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _emailC,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (!widget.editMode)
                              TextFormField(
                                controller: _passwordC,
                                decoration: InputDecoration(
                                  labelText: 'Mật khẩu *',
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                obscureText: true,
                                validator:
                                    (v) =>
                                        v == null || v.trim().isEmpty
                                            ? 'Vui lòng nhập mật khẩu'
                                            : null,
                              ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<int>(
                                    value: _gender,
                                    decoration: InputDecoration(
                                      labelText: 'Giới tính',
                                      filled: true,
                                      fillColor: const Color(0xFFF8FAFC),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 0,
                                        child: Text('Male'),
                                      ),
                                      DropdownMenuItem(
                                        value: 1,
                                        child: Text('Female'),
                                      ),
                                    ],
                                    onChanged:
                                        (v) => setState(() => _gender = v ?? 0),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DropdownButtonFormField<int>(
                                    value: _roleId,
                                    decoration: InputDecoration(
                                      labelText: 'Vai trò *',
                                      filled: true,
                                      fillColor: const Color(0xFFF8FAFC),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 2,
                                        child: Text('Admin'),
                                      ),
                                      DropdownMenuItem(
                                        value: 3,
                                        child: Text('Staff'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      if (value == null) return;
                                      setState(() => _roleId = value);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<int?>(
                              value: _storeId,
                              decoration: InputDecoration(
                                labelText: 'Cửa hàng',
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              items: [
                                const DropdownMenuItem<int?>(
                                  value: null,
                                  child: Text('Chọn cửa hàng'),
                                ),
                                ...storeProvider.stores.map(
                                  (store) => DropdownMenuItem<int?>(
                                    value: store.id,
                                    child: Text(store.name),
                                  ),
                                ),
                              ],
                              onChanged:
                                  (value) => setState(() {
                                    _storeId = value;
                                  }),
                            ),
                            const SizedBox(height: 12),
                            if (widget.editMode)
                              DropdownButtonFormField<int>(
                                value: _statusId,
                                decoration: InputDecoration(
                                  labelText: 'Trạng thái',
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
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
                            const SizedBox(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(false),
                                  child: const Text('Hủy'),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: submitting ? null : _submit,
                                  child:
                                      submitting
                                          ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                          : Text(
                                            widget.editMode ? 'Lưu' : 'Tạo',
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

