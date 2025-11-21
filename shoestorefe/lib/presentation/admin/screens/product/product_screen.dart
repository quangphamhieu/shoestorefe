import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/product_provider.dart';
import '../../provider/brand_provider.dart';
import '../../widgets/side_menu.dart';
import '../../widgets/app_header.dart';
import 'product_table.dart';
import 'product_toolbar.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ProductProvider>().loadAll();
      context.read<BrandProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();

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
                          const ProductToolbar(),
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
                                        child: ProductTable(
                                          products: provider.filteredProducts,
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
