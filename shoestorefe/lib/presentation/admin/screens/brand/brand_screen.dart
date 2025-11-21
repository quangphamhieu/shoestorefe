import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/brand_provider.dart';
import '../../widgets/side_menu.dart';
import '../../widgets/app_header.dart';
import 'brand_table.dart';
import 'brand_toolbar.dart';

class BrandScreen extends StatefulWidget {
  const BrandScreen({super.key});

  @override
  State<BrandScreen> createState() => _BrandScreenState();
}

class _BrandScreenState extends State<BrandScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<BrandProvider>().loadAll());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BrandProvider>();

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
                          const BrandToolbar(),
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
                                      : SingleChildScrollView(
                                        padding: const EdgeInsets.all(20),
                                        child: BrandTable(
                                          brands: provider.filteredBrands,
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
