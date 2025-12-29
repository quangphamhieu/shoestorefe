import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/customer_provider.dart';
import '../widgets/customer_header.dart';
import '../widgets/product_card.dart';
import '../widgets/product_filter.dart';
import '../widgets/chat_bubble.dart'; // THÊM
import '../widgets/chat_popup.dart'; // THÊM

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isChatOpen = false;

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
      body: Stack(
        children: [
          Column(
            children: [
              const CustomerHeader(),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Responsive banner height
                      Container(
                        height: width < 600 ? 200 : (width < 900 ? 300 : 400),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/Backgroud.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // Shipping promotion banner
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: width < 600 ? 16 : 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (width >= 600)
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios),
                                onPressed: () {},
                              ),
                            if (width >= 600) const SizedBox(width: 16),
                            Flexible(
                              child: Text(
                                'Miễn phí vận chuyển với đơn hàng trên 500,000đ',
                                style: TextStyle(fontSize: width < 600 ? 12 : 14),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                            if (width >= 600) const SizedBox(width: 16),
                            if (width >= 600)
                              IconButton(
                                icon: const Icon(Icons.arrow_forward_ios),
                                onPressed: () {},
                              ),
                          ],
                        ),
                      ),

                      const ProductFilter(),

                      provider.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : provider.filteredProductGroups.isEmpty
                          ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(40.0),
                              child: Text(
                                'Không tìm thấy sản phẩm',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          )
                          : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 40),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    childAspectRatio: 0.68,
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
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (isChatOpen)
            ChatPopup(
              onClose: () {
                setState(() => isChatOpen = false);
              }),
          if(!isChatOpen)
            ChatBubble(
              onTap: () {
                setState(() => isChatOpen = true);
              },
            ),
        ],
      ),
    );
  }
}
