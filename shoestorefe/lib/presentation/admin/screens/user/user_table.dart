import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoestorefe/domain/entities/user.dart';
import '../../provider/user_provider.dart';
import '../../provider/store_provider.dart';

class UserTable extends StatelessWidget {
  final List<User> users;
  const UserTable({super.key, required this.users});

  String _storeName(StoreProvider provider, int? storeId) {
    if (storeId == null) return '-';
    for (final store in provider.stores) {
      if (store.id == storeId) return store.name;
    }
    return '-';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    final storeProvider = context.watch<StoreProvider>();

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              showCheckboxColumn: false,
              columnSpacing: 20,
              headingTextStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2933),
              ),
              dataTextStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xFF334155),
              ),
              dividerThickness: 0.3,
              headingRowColor: MaterialStateProperty.all(
                const Color(0xFFF1F5F9),
              ),
              dataRowColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return const Color(0xFFEFF6FF);
                }
                return Colors.white;
              }),
              columns: const [
                DataColumn(label: SizedBox(width: 32)),
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Tên')),
                DataColumn(label: Text('Điện thoại')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Giới tính')),
                DataColumn(label: Text('Vai trò')),
                DataColumn(label: Text('Cửa hàng')),
                DataColumn(label: Text('Trạng thái')),
                DataColumn(label: Text('Tạo lúc')),
              ],
              rows: users.map((u) {
                final selected = provider.selectedUserId == u.id;
                return DataRow(
                  selected: selected,
                  onSelectChanged: (v) => provider.selectUser(
                    v == true ? u.id : null,
                  ),
                  cells: [
                    DataCell(
                      Center(
                        child: Checkbox(
                          value: selected,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          onChanged: (v) => provider.selectUser(
                            v == true ? u.id : null,
                          ),
                        ),
                      ),
                    ),
                    DataCell(Text(u.id.toString())),
                    DataCell(
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 200),
                        child: Text(
                          u.fullName,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(Text(u.phone)),
                    DataCell(Text(u.email ?? '-')),
                    DataCell(Text(u.gender == 0 ? 'Male' : 'Female')),
                    DataCell(Text(u.roleName)),
                    DataCell(Text(_storeName(storeProvider, u.storeId))),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: u.statusName.toLowerCase().contains('active')
                              ? const Color(0xFFEFFAF3)
                              : const Color(0xFFFFF1F2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          u.statusName,
                          style: TextStyle(
                            color: u.statusName.toLowerCase().contains('active')
                                ? const Color(0xFF0F9D58)
                                : const Color(0xFFDC2626),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        u.createdAt.toLocal().toString().split('.').first,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

