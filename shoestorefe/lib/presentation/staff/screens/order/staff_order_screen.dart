import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/staff_order_provider.dart';
import '../../../admin/widgets/app_header.dart';
import '../../widgets/staff_side_menu.dart';
import 'staff_order_detail_panel.dart';
import 'staff_order_table.dart';
import 'staff_order_toolbar.dart';

class StaffOrderScreen extends StatefulWidget {
  const StaffOrderScreen({super.key});

  @override
  State<StaffOrderScreen> createState() => _StaffOrderScreenState();
}

class _StaffOrderScreenState extends State<StaffOrderScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<StaffOrderProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StaffOrderProvider>();

    return Scaffold(
      body: Row(
        children: [
          const StaffSideMenu(),
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
                          const StaffOrderToolbar(),
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
                              child:
                                  provider.isLoading
                                      ? const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                      : provider.filteredOrders.isEmpty
                                      ? const Center(
                                        child: Text('Không có đơn hàng nào.'),
                                      )
                                      : SingleChildScrollView(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            StaffOrderTable(
                                              orders: provider.filteredOrders,
                                            ),
                                            if (provider.selectedOrder != null)
                                              StaffOrderDetailPanel(
                                                order: provider.selectedOrder!,
                                              ),
                                          ],
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

