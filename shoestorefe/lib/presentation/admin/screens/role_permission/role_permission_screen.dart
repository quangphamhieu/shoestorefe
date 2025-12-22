import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_header.dart';
import '../../widgets/side_menu.dart';
import '../../provider/role_permission_provider.dart';
import 'role_permission_table.dart';
import 'role_permission_toolbar.dart';

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
      context.read<RolePermissionProvider>().fetchPermissions();
      // Reset selection when entering screen
      context.read<RolePermissionProvider>().selectRole(null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RolePermissionProvider>();

    return Scaffold(
      body: Row(
        children: [
          const SideMenu(),
          Expanded(
            child: Container(
              color: const Color(0xFFF5F7FA),
              child: Column(
                children: [
                   const AppHeader(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const RolePermissionToolbar(),
                          const SizedBox(height: 24),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 25,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: provider.isLoading && provider.roles.isEmpty
                                  ? const Center(child: CircularProgressIndicator())
                                  : provider.error != null
                                      ? Center(child: Text('Error: ${provider.error}'))
                                      : SingleChildScrollView(
                                          padding: const EdgeInsets.all(20),
                                          child: SizedBox(
                                            width: double.infinity,
                                            child: RolePermissionTable(roles: provider.roles),
                                          ),
                                        ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
