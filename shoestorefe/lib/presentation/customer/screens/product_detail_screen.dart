import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../injection_container.dart';
import '../../../domain/entities/product.dart';
import '../provider/product_detail_provider.dart';
import '../widgets/customer_header.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productName;

  const ProductDetailScreen({super.key, required this.productName});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProductDetailProvider>(
      create: (_) => ProductDetailProvider(
        getListProductByNameUseCase: sl(),
        addItemToCartUseCase: sl(),
      )..loadByName(productName),
      child: Consumer<ProductDetailProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              children: [
                const CustomerHeader(),
                Expanded(
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : provider.variants.isEmpty
                      ? const Center(child: Text('Không tìm thấy sản phẩm'))
                      : _buildContent(context, provider),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, ProductDetailProvider provider) {
    final Product product = provider.variants.first;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------- ẢNH & THÔNG TIN ----------------
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ẢNH
              Expanded(
                flex: 4,
                child: Container(
                  height: 260,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      product.imageUrl ?? '',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                      const Icon(Icons.image_not_supported, size: 80),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // TEXT INFO + COLOR + SIZE
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên sản phẩm
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Mô tả
                    Text(
                      product.description ?? '',
                      style:
                      TextStyle(fontSize: 14, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 20),

                    // ---------------- COLOR ----------------
                    if (provider.availableColors.isNotEmpty) ...[
                      const Text('Màu sắc',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        children: provider.availableColors.map((color) {
                          final isSelected = provider.selectedColor == color;
                          return ChoiceChip(
                            label: Text(color),
                            selected: isSelected,
                            onSelected: (_) =>
                                provider.selectColor(isSelected ? null : color),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ---------------- SIZE ----------------
                    if (provider.availableSizes.isNotEmpty) ...[
                      const Text('Kích thước',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        children: provider.availableSizes.map((size) {
                          final isSelected = provider.selectedSize == size;
                          return ChoiceChip(
                            label: Text(size),
                            selected: isSelected,
                            onSelected: (_) =>
                                provider.selectSize(isSelected ? null : size),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ---------------- STOCK ----------------
                    const Text('Tình trạng kho',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(
                      'Tổng số lượng: ${provider.filteredStockQuantity}',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),

                    // List store
                    ...provider.stockByStore.entries.map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text('${e.key}: ${e.value}',
                          style: const TextStyle(fontSize: 14)),
                    )),

                    const SizedBox(height: 20),

                    // ---------------- QUANTITY ----------------
                    const Text('Số lượng',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        IconButton(
                          onPressed: provider.decreaseQty,
                          icon: const Icon(Icons.remove),
                        ),
                        Text(provider.quantity.toString(),
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                          onPressed: provider.increaseQty,
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ---------------- BUTTONS ----------------
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                padding:
                                const EdgeInsets.symmetric(vertical: 14)),
                            onPressed: () {},
                            child: const Text('MUA NGAY'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                                padding:
                                const EdgeInsets.symmetric(vertical: 14)),
                            onPressed:
                            (provider.selectedColor == null ||
                                provider.selectedSize == null)
                                ? null
                                : () async {
                              await provider.addToCart();

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Đã thêm sản phẩm vào giỏ hàng"),
                                ),
                              );
                            },
                            child: const Text('THÊM VÀO GIỎ'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
