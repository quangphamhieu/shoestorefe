import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../injection_container.dart';
import '../../../domain/entities/product.dart';
import '../provider/product_detail_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productName;

  const ProductDetailScreen({super.key, required this.productName});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProductDetailProvider>(
      create: (_) => ProductDetailProvider(
        getListProductByNameUseCase: sl(),
      )..loadByName(productName),
      child: Consumer<ProductDetailProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            appBar: AppBar(
              title: Text(provider.productName.isEmpty
                  ? 'Chi tiết sản phẩm'
                  : provider.productName),
            ),
            body: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.variants.isEmpty
                    ? const Center(
                        child: Text('Không tìm thấy sản phẩm'),
                      )
                    : _buildContent(context, provider),
          );
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ProductDetailProvider provider,
  ) {
    final Product representative = provider.variants.first;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ảnh + tên sản phẩm
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: representative.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          representative.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 60,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.image,
                          size: 60,
                          color: Colors.grey,
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      representative.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      representative.description ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Chọn màu
          if (provider.availableColors.isNotEmpty) ...[
            const Text(
              'Màu sắc',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: provider.availableColors.map((color) {
                final bool isSelected = provider.selectedColor == color;
                return ChoiceChip(
                  label: Text(color),
                  selected: isSelected,
                  onSelected: (_) {
                    provider.selectColor(isSelected ? null : color);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
          // Chọn size
          if (provider.availableSizes.isNotEmpty) ...[
            const Text(
              'Kích thước',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: provider.availableSizes.map((size) {
                final bool isSelected = provider.selectedSize == size;
                return ChoiceChip(
                  label: Text(size),
                  selected: isSelected,
                  onSelected: (_) {
                    provider.selectSize(isSelected ? null : size);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
          // Tồn kho
          const Text(
            'Tồn kho trong cửa hàng',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tổng số lượng: ${provider.filteredStockQuantity}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          ...provider.stockByStore.entries.map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                '${e.key}: ${e.value}',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


