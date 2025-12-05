import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/customer_provider.dart';

class ProductFilter extends StatelessWidget {
  const ProductFilter({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CustomerProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          // Filter Icon
          const Icon(Icons.tune, size: 20),
          const SizedBox(width: 24),
          // Color Filter
          _buildDropdown(
            context,
            label: 'Màu sắc',
            value: provider.selectedColor,
            items: [
              'Black',
              'White',
              'Red',
              'Blue',
              'Yellow',
              'Gray',
              'Green',
              'Orange',
              'Pink',
              'Purple',
            ],
            displayMap: {
              'Black': 'Đen',
              'White': 'Trắng',
              'Red': 'Đỏ',
              'Blue': 'Xanh dương',
              'Yellow': 'Vàng',
              'Gray': 'Xám',
              'Green': 'Xanh lá',
              'Orange': 'Cam',
              'Pink': 'Hồng',
              'Purple': 'Tím',
            },
            onChanged: (value) => provider.setColor(value),
          ),
          const SizedBox(width: 16),
          // Size Filter
          _buildDropdown(
            context,
            label: 'Kích thước',
            value: provider.selectedSize,
            items: [
              '35',
              '36',
              '37',
              '38',
              '39',
              '40',
              '41',
              '42',
              '43',
              '44',
              '45',
            ],
            onChanged: (value) => provider.setSize(value),
          ),
          const SizedBox(width: 16),
          // Price Filter
          _buildDropdown(
            context,
            label: 'Giá',
            value: null,
            items: ['Dưới 500k', '500k - 1tr', '1tr - 2tr', 'Trên 2tr'],
            onChanged: (value) {
              switch (value) {
                case 'Dưới 500k':
                  provider.setPriceRange(null, 500000);
                  break;
                case '500k - 1tr':
                  provider.setPriceRange(500000, 1000000);
                  break;
                case '1tr - 2tr':
                  provider.setPriceRange(1000000, 2000000);
                  break;
                case 'Trên 2tr':
                  provider.setPriceRange(2000000, null);
                  break;
              }
            },
          ),
          const Spacer(),
          // Sort Dropdown
          _buildDropdown(
            context,
            label: 'Sắp xếp theo',
            value: provider.sortBy,
            items: ['newest', 'price-asc', 'price-desc', 'name'],
            displayMap: {
              'newest': 'Mới nhất',
              'price-asc': 'Giá tăng dần',
              'price-desc': 'Giá giảm dần',
              'name': 'Tên A-Z',
            },
            onChanged: (value) => provider.setSortBy(value!),
            width: 180,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    BuildContext context, {
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    Map<String, String>? displayMap,
    double? width,
  }) {
    return Container(
      width: width ?? 150,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 20,
            color: Colors.grey[600],
          ),
          items:
              items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    displayMap?[item] ?? item,
                    style: const TextStyle(fontSize: 13),
                  ),
                );
              }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
