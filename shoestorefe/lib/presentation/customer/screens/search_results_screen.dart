import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../provider/customer_provider.dart';
import 'filter_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  final String query;

  const SearchResultsScreen({super.key, required this.query});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  @override
  void initState() {
    super.initState();
    // Clear filters when entering search screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CustomerProvider>();
      provider.clearFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CustomerProvider>();

    // Filter product groups based on query and applied filters
    final searchQuery = widget.query.toLowerCase();
    var results =
        provider.productGroups.where((group) {
          final name = group.representative.name.toLowerCase();
          final colors =
              group.availableColors.map((c) => c.toLowerCase()).toList();
          final sizes =
              group.availableSizes.map((s) => s.toLowerCase()).toList();

          return name.contains(searchQuery) ||
              colors.any((c) => c.contains(searchQuery)) ||
              sizes.any((s) => s.contains(searchQuery));
        }).toList();

    // Apply filters from provider
    if (provider.selectedColor != null) {
      results =
          results
              .where(
                (group) =>
                    group.availableColors.contains(provider.selectedColor),
              )
              .toList();
    }

    if (provider.selectedSize != null) {
      results =
          results
              .where(
                (group) => group.availableSizes.contains(provider.selectedSize),
              )
              .toList();
    }

    if (provider.minPrice != null) {
      results =
          results
              .where(
                (group) =>
                    group.representative.originalPrice >= provider.minPrice!,
              )
              .toList();
    }

    if (provider.maxPrice != null) {
      results =
          results
              .where(
                (group) =>
                    group.representative.originalPrice <= provider.maxPrice!,
              )
              .toList();
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kết quả tìm kiếm',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '"${widget.query}"',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body:
          results.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Không tìm thấy sản phẩm "${widget.query}"',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Quay lại'),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  // Header with count and filter button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tìm thấy ${results.length} sản phẩm',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            if (provider.hasActiveFilters)
                              TextButton.icon(
                                icon: const Icon(Icons.close, size: 16),
                                label: const Text('Xóa lọc'),
                                onPressed: () {
                                  provider.clearFilters();
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                ),
                              ),
                            IconButton(
                              icon: Icon(
                                Icons.tune,
                                color:
                                    provider.hasActiveFilters
                                        ? Colors.blue
                                        : Colors.black,
                              ),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => const FilterScreen(),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Active filters chips
                  if (provider.hasActiveFilters)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (provider.selectedColor != null)
                            Chip(
                              label: Text('Màu: ${provider.selectedColor}'),
                              onDeleted: () => provider.setColor(null),
                              deleteIcon: const Icon(Icons.close, size: 16),
                            ),
                          if (provider.selectedSize != null)
                            Chip(
                              label: Text('Size: ${provider.selectedSize}'),
                              onDeleted: () => provider.setSize(null),
                              deleteIcon: const Icon(Icons.close, size: 16),
                            ),
                          if (provider.minPrice != null ||
                              provider.maxPrice != null)
                            Chip(
                              label: Text(
                                'Giá: ${provider.minPrice?.toStringAsFixed(0) ?? '0'} - ${provider.maxPrice?.toStringAsFixed(0) ?? '∞'}',
                              ),
                              onDeleted:
                                  () => provider.setPriceRange(null, null),
                              deleteIcon: const Icon(Icons.close, size: 16),
                            ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final productGroup = results[index];
                        return _buildProductCard(context, productGroup);
                      },
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildProductCard(BuildContext context, dynamic productGroup) {
    final rep = productGroup.representative;
    final imageUrl = rep.imageUrl ?? '';
    final name = rep.name ?? 'Không có tên';
    final price =
        rep.stores?.isNotEmpty == true
            ? rep.stores[0].salePrice ?? rep.originalPrice ?? 0
            : rep.originalPrice ?? 0;

    return GestureDetector(
      onTap: () {
        context.push('/mobile-product-detail', extra: name);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      image:
                          imageUrl.isNotEmpty
                              ? DecorationImage(
                                image: NetworkImage(imageUrl),
                                fit: BoxFit.cover,
                              )
                              : null,
                    ),
                    child:
                        imageUrl.isEmpty
                            ? const Center(
                              child: Icon(
                                Icons.image,
                                size: 48,
                                color: Colors.grey,
                              ),
                            )
                            : null,
                  ),
                  if (productGroup.totalVariants > 1)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${productGroup.totalVariants} màu',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Product Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${price.toStringAsFixed(0)}đ',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
