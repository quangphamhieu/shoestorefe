import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shoestorefe/core/utils/auth_utils.dart';

class StaffSideMenu extends StatelessWidget {
  const StaffSideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final state = GoRouterState.of(context);
    final String currentLocation = state.uri.path;

    final List<Map<String, dynamic>> items = [
      {
        'icon': Icons.shopping_cart_outlined,
        'title': 'Đơn hàng',
        'route': '/staff/order',
      },
      {'icon': Icons.logout, 'title': 'Đăng xuất', 'route': '/logout'},
    ];

    return Container(
      width: 260,
      decoration: const BoxDecoration(color: Color(0xFFECF1F4)),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16, bottom: 8),
            child: Text(
              'MENU',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          ...items.map((item) {
            final String route = item['route'] as String;
            final String title = item['title'] as String;
            final IconData icon = item['icon'] as IconData;

            final bool isLogout = title == 'Đăng xuất';
            final bool isActive =
                !isLogout && currentLocation == route;

            return InkWell(
              onTap: () {
                if (isLogout) {
                  AuthUtils.logout(context);
                } else {
                  context.go(route);
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      color: isActive ? Colors.deepOrange : Colors.grey[700],
                    ),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: TextStyle(
                        color: isActive ? Colors.deepOrange : Colors.grey[700],
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

