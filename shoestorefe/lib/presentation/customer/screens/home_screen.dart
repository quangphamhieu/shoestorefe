import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/customer_provider.dart';
import '../widgets/customer_header.dart';
import '../widgets/product_card.dart';
import '../widgets/product_filter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CustomerProvider>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CustomerProvider>();
    final width = MediaQuery.of(context).size.width;

    // Responsive số cột theo kích thước màn hình
    int crossAxisCount;
    if (width >= 1400) {
      crossAxisCount = 4;
    } else if (width >= 1100) {
      crossAxisCount = 3;
    } else if (width >= 800) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 1;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const CustomerHeader(),
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Banner Section
                  Container(
                    height: 400,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/Backgroud.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Navigation arrows
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          onPressed: () {},
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Miễn phí vận chuyển với đơn hàng trên 500,000đ',
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  // Filter Section
                  const ProductFilter(),
                  // Products Grid
                  provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : provider.filteredProductGroups.isEmpty
                      ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Text(
                            'Không tìm thấy sản phẩm',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      )
                      : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 40),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    childAspectRatio: 0.72,
                                    crossAxisSpacing: 20,
                                    mainAxisSpacing: 20,
                                  ),
                              itemCount: provider.filteredProductGroups.length,
                              itemBuilder: (context, index) {
                                return ProductCard(
                                  productGroup:
                                      provider.filteredProductGroups[index],
                                );
                              },
                            );
                          },
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
