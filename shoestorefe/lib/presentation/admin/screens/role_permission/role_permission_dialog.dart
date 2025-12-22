import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../domain/entities/role_permission.dart';
import '../../provider/role_permission_provider.dart';
import 'package:collection/collection.dart'; // For grouping

class RolePermissionDialog extends StatefulWidget {
  final int roleId;
  final String roleName;

  const RolePermissionDialog({
    super.key,
    required this.roleId,
    required this.roleName,
  });

  @override
  State<RolePermissionDialog> createState() => _RolePermissionDialogState();
}

class _RolePermissionDialogState extends State<RolePermissionDialog> {
  Map<int, bool> _permissionStatus = {};
  bool _initialized = false;

  final Map<String, String> _groupTitles = {
    'PRODUCT': 'Sản phẩm',
    'USER': 'Người dùng',
    'ORDER': 'Đơn hàng',
    'ROLE': 'Vai trò',
    'PERMISSION': 'Quyền hạn',
    'BRAND': 'Thương hiệu',
    'CATEGORY': 'Danh mục',
    'STORE': 'Cửa hàng',
    'SUPPLIER': 'Nhà cung cấp',
    'RECEIPT': 'Phiếu nhập',
    'PROMOTION': 'Khuyến mãi',
    'NOTIFICATION': 'Thông báo',
    'COMMENT': 'Bình luận',
    'CART': 'Giỏ hàng',
    'DASHBOARD': 'Thống kê',
    'AUDIT': 'Lịch sử',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = context.read<RolePermissionProvider>();
    await provider.fetchRolePermissions(widget.roleId);

    if (mounted) {
      final selectedPermissions =
          provider.selectedRolePermissions?.permissions ?? [];
      final selectedIds = selectedPermissions.map((p) => p.id).toSet();

      setState(() {
        _permissionStatus = {};
        for (var perm in provider.allPermissions) {
          _permissionStatus[perm.id] = selectedIds.contains(perm.id);
        }
        _initialized = true;
      });
    }
  }

  void _onSave() async {
    final selectedIds = _permissionStatus.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    await context.read<RolePermissionProvider>().updateRolePermissions(
          widget.roleId,
          selectedIds,
        );

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật quyền thành công'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _getGroupName(String code) {
    final prefix = code.split('_').first;
    return _groupTitles[prefix] ?? prefix;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 900, // Wider for modern feel
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quản lý quyền hạn',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Vai trò: ${widget.roleName}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  color: Colors.grey,
                ),
              ],
            ),
            const Divider(height: 32),

            // Content
            Expanded(
              child: Consumer<RolePermissionProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading && !_initialized) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.error != null) {
                    return Center(
                      child: Text(
                        'Lỗi: ${provider.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final allPermissions = provider.allPermissions;
                  if (allPermissions.isEmpty) {
                    return const Center(child: Text('Không có dữ liệu quyền.'));
                  }

                  // Group permissions
                  final groups = groupBy(allPermissions,
                      (Permission p) => _getGroupName(p.code));

                  return ListView.builder(
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      final groupName = groups.keys.elementAt(index);
                      final permissions = groups[groupName]!;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[200]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(8)),
                              ),
                              child: Text(
                                groupName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Wrap(
                                spacing: 24,
                                runSpacing: 16,
                                children: permissions.map((perm) {
                                  final isChecked =
                                      _permissionStatus[perm.id] ?? false;
                                  return SizedBox(
                                    width: 250,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _permissionStatus[perm.id] =
                                              !isChecked;
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(4),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: Checkbox(
                                              value: isChecked,
                                              activeColor:
                                                  Theme.of(context).primaryColor,
                                              onChanged: (val) {
                                                setState(() {
                                                  _permissionStatus[perm.id] =
                                                      val ?? false;
                                                });
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  perm.code,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                if (perm.description.isNotEmpty)
                                                  Text(
                                                    perm.description,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    foregroundColor: Colors.grey[700],
                  ),
                  child: const Text('Hủy'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _onSave,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Lưu thay đổi'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
