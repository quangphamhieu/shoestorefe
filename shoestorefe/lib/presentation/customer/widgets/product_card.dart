import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/store_quantity.dart';
import '../provider/customer_provider.dart';

class ProductCard extends StatefulWidget {
  final ProductGroup productGroup;

  const ProductCard({super.key, required this.productGroup});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.productGroup.representative;

    // Get the sale price from warehouse store (id = 1) if available
    StoreQuantity? warehouseEntry;
    if (product.stores.isNotEmpty) {
      try {
        warehouseEntry = product.stores.firstWhere(
          (store) => store.storeId == CustomerProvider.warehouseStoreId,
        );
      } catch (_) {
        warehouseEntry = product.stores.first;
      }
    }
    final salePrice = warehouseEntry?.salePrice ?? product.originalPrice;

    final hasDiscount = salePrice < product.originalPrice;
    final discountPercent = hasDiscount
        ? (((product.originalPrice - salePrice) / product.originalPrice) * 100)
            .round()
        : 0;

    return GestureDetector(
      onTap: () {
        // Điều hướng đến màn hình chi tiết sản phẩm với tên sản phẩm đại diện
        context.go(
          '/product-detail',
          extra: product.name,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          AspectRatio(
            aspectRatio: 0.95,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child:
                      product.imageUrl != null
                          ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Image.network(
                              product.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => const Center(
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
                // Favorite Button
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isFavorite = !_isFavorite;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: _isFavorite ? Colors.red : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                // Discount Badge
                if (hasDiscount)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '-$discountPercent%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
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
                // Size and Color Info
                Row(
                  children: [
                    if (widget.productGroup.availableSizes.isNotEmpty) ...[
                      Text(
                        '${widget.productGroup.availableSizes.length} size',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    if (widget.productGroup.availableSizes.isNotEmpty &&
                        widget.productGroup.availableColors.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    if (widget.productGroup.availableColors.isNotEmpty) ...[
                      Text(
                        '${widget.productGroup.availableColors.length} màu sắc',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                // Product Name
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                // Price
                Text(
                  '${salePrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}đ',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (hasDiscount) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Giá gốc ${product.originalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}đ',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                      decoration: TextDecoration.lineThrough,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
