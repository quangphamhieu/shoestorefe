import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/role_permission_provider.dart';
import 'widgets/role_permission_dialog.dart';

class RolePermissionScreen extends StatefulWidget {
  static const String routeName = '/admin/role-permissions';

  const RolePermissionScreen({super.key});

  @override
  State<RolePermissionScreen> createState() => _RolePermissionScreenState();
}

class _RolePermissionScreenState extends State<RolePermissionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RolePermissionProvider>().fetchRoles();
      context.read<RolePermissionProvider>().fetchPermissions(); // Pre-fetch all permissions
    });
  }

  void _showPermissionDialog(BuildContext context, int roleId, String roleName) {
    showDialog(
      context: context,
      builder: (context) => RolePermissionDialog(
        roleId: roleId,
        roleName: roleName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Role Permissions'),
        centerTitle: true,
      ),
      body: Consumer<RolePermissionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.roles.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }

          if (provider.roles.isEmpty) {
            return const Center(child: Text('No roles found.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: provider.roles.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final role = provider.roles[index];
              return Card(
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(role.code.isNotEmpty ? role.code[0] : '?'),
                  ),
                  title: Text(role.name),
                  subtitle: Text('Code: ${role.code}'),
                  trailing: ElevatedButton.icon(
                    onPressed: () => _showPermissionDialog(context, role.id, role.name),
                    icon: const Icon(Icons.edit),
                    label: const Text('Update Permission'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
