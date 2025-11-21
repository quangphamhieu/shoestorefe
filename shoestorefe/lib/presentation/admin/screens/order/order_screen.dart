import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/order_provider.dart';
import '../../widgets/app_header.dart';
import '../../widgets/side_menu.dart';
import 'order_detail_panel.dart';
import 'order_table.dart';
import 'order_toolbar.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<OrderProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();

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
                          const OrderToolbar(),
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
                                            OrderTable(
                                              orders: provider.filteredOrders,
                                            ),
                                            if (provider.selectedOrder != null)
                                              OrderDetailPanel(
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
