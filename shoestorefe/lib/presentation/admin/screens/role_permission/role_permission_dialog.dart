import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../domain/entities/role_permission.dart';
import '../../provider/role_permission_provider.dart';

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
  // Map of Permission ID to checked status
  Map<int, bool> _permissionStatus = {};
  bool _initialized = false;

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
    
    // Initialize checked status based on fetched data
    if (mounted) {
      final selectedPermissions = provider.selectedRolePermissions?.permissions ?? [];
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
        const SnackBar(content: Text('Permissions updated successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Manage Permissions for ${widget.roleName}'),
      content: SizedBox(
        width: double.maxFinite,
        height: 500,
        child: Consumer<RolePermissionProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && !_initialized) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null) {
              return Center(child: Text('Error: ${provider.error}'));
            }

            // Using allPermissions ensuring we show unchecked ones too
            final allPermissions = provider.allPermissions;

            if (allPermissions.isEmpty) {
              return const Center(child: Text('No permissions available.'));
            }

            return ListView.builder(
              itemCount: allPermissions.length,
              itemBuilder: (context, index) {
                final permission = allPermissions[index];
                final isChecked = _permissionStatus[permission.id] ?? false;

                return CheckboxListTile(
                  title: Text(permission.code),
                  subtitle: Text(permission.description),
                  value: isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      _permissionStatus[permission.id] = value ?? false;
                    });
                  },
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _onSave,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
