import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../domain/entities/role_permission.dart';
import '../../provider/role_permission_provider.dart';

class RolePermissionTable extends StatelessWidget {
  final List<Role> roles;

  const RolePermissionTable({super.key, required this.roles});

  @override
  Widget build(BuildContext context) {
    if (roles.isEmpty) {
      return const Center(child: Text("Không có dữ liệu"));
    }

    return DataTable(
      headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
      dataRowColor: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return const Color(0xFF4CAF50).withOpacity(0.08);
          }
          return null;
        },
      ),
      columns: const [
        DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('Mã Role', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('Tên Role', style: TextStyle(fontWeight: FontWeight.bold))),
      ],
      rows: roles.map((role) {
        final isSelected = context.watch<RolePermissionProvider>().selectedRoleId == role.id;
        return DataRow(
          selected: isSelected,
          onSelectChanged: (bool? selected) {
             context.read<RolePermissionProvider>().selectRole(selected == true ? role.id : null);
          },
          cells: [
            DataCell(Text(role.id.toString())),
            DataCell(Text(role.code)),
            DataCell(Text(role.name)),
          ],
        );
      }).toList(),
    );
  }
}
