import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/customer_provider.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late List<String> selectedColors;
  late List<String> selectedSizes;
  double? minPrice;
  double? maxPrice;

  @override
  void initState() {
    super.initState();
    final provider = context.read<CustomerProvider>();
    selectedColors =
        provider.selectedColor != null ? [provider.selectedColor!] : [];
    selectedSizes =
        provider.selectedSize != null ? [provider.selectedSize!] : [];
    minPrice = provider.minPrice;
    maxPrice = provider.maxPrice;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CustomerProvider>();

    // Get available colors and sizes from all products
    final availableColors =
        provider.products
            .where((p) => p.color != null)
            .map((p) => p.color!)
            .toSet()
            .toList()
          ..sort();

    final availableSizes =
        provider.products
            .where((p) => p.size != null)
            .map((p) => p.size!)
            .toSet()
            .toList()
          ..sort();

    // Get price range
    final prices = provider.products.map((p) => p.originalPrice).toList();
    final minPriceRange =
        prices.isEmpty ? 0.0 : prices.reduce((a, b) => a < b ? a : b);
    final maxPriceRange =
        prices.isEmpty ? 10000000.0 : prices.reduce((a, b) => a > b ? a : b);
    final priceRange = RangeValues(minPriceRange, maxPriceRange);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bộ lọc'),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                selectedColors.clear();
                selectedSizes.clear();
                minPrice = priceRange.start;
                maxPrice = priceRange.end;
              });
            },
            child: const Text('Đặt lại', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Màu sắc',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8,
              children:
                  availableColors.map((color) {
                    final isSelected = selectedColors.contains(color);
                    return FilterChip(
                      label: Text(color),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedColors.add(color);
                          } else {
                            selectedColors.remove(color);
                          }
                        });
                      },
                    );
                  }).toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Kích cỡ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8,
              children:
                  availableSizes.map((size) {
                    final isSelected = selectedSizes.contains(size);
                    return FilterChip(
                      label: Text(size),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedSizes.add(size);
                          } else {
                            selectedSizes.remove(size);
                          }
                        });
                      },
                    );
                  }).toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Khoảng giá',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            RangeSlider(
              values: RangeValues(
                minPrice ?? priceRange.start,
                maxPrice ?? priceRange.end,
              ),
              min: priceRange.start,
              max: priceRange.end,
              divisions: 20,
              labels: RangeLabels(
                (minPrice ?? priceRange.start).toStringAsFixed(0),
                (maxPrice ?? priceRange.end).toStringAsFixed(0),
              ),
              onChanged: (values) {
                setState(() {
                  minPrice = values.start;
                  maxPrice = values.end;
                });
              },
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Apply single color/size filters (CustomerProvider uses single values)
                      provider.setColor(
                        selectedColors.isNotEmpty ? selectedColors.first : null,
                      );
                      provider.setSize(
                        selectedSizes.isNotEmpty ? selectedSizes.first : null,
                      );
                      provider.setPriceRange(minPrice, maxPrice);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Áp dụng'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
