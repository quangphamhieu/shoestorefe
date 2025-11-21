import 'package:flutter/material.dart';
import '../../widgets/side_menu.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: const [
          SideMenu(),
          Expanded(child: Center(child: Text('Dashboard content here'))),
        ],
      ),
    );
  }
}
