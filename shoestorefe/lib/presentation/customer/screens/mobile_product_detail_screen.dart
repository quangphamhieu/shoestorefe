import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/comment.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/store_quantity.dart';
import '../../../injection_container.dart';
import '../provider/product_detail_provider.dart';
import '../provider/cart_provider.dart';
import '../provider/checkout_provider.dart';

class MobileProductDetailScreen extends StatefulWidget {
  final String productName;
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '',
    decimalDigits: 0,
  );
  static final DateFormat _commentDateFormat = DateFormat('dd/MM/yyyy HH:mm');

  const MobileProductDetailScreen({super.key, required this.productName});

  @override
  State<MobileProductDetailScreen> createState() =>
      _MobileProductDetailScreenState();
}

class _MobileProductDetailScreenState extends State<MobileProductDetailScreen> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _handleSubmitComment(ProductDetailProvider provider) async {
    final result = await provider.addComment(_commentController.text);
    if (!mounted) return;
    if (result != null) {
      _showMessage(result);
      return;
    }
    _commentController.clear();
    _showMessage('Đã thêm bình luận', isError: false);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProductDetailProvider>(
      create:
          (_) => ProductDetailProvider(
            getListProductByNameUseCase: sl(),
            getCommentsByProductIdUseCase: sl(),
            createCommentUseCase: sl(),
            updateCommentUseCase: sl(),
            deleteCommentUseCase: sl(),
            addItemToCartUseCase: sl(),
          )..loadByName(widget.productName),
      child: Consumer<ProductDetailProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => context.pop(),
              ),
              title: const Text(
                'Chi tiết sản phẩm',
                style: TextStyle(color: Colors.black),
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.black,
                  ),
                  onPressed: () => context.push('/cart'),
                ),
              ],
            ),
            body:
                provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.variants.isEmpty
                    ? const Center(child: Text('Không tìm thấy sản phẩm'))
                    : _buildContent(context, provider),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, ProductDetailProvider provider) {
    final Product? displayVariant = provider.displayVariant;
    final StoreQuantity? onlineStore = provider.onlineStoreQuantity;

    if (displayVariant == null) {
      return const Center(child: Text('Không tìm thấy sản phẩm phù hợp'));
    }

    final bool hasStock = (onlineStore?.quantity ?? 0) > 0;
    final double price = onlineStore?.salePrice ?? displayVariant.originalPrice;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    color: Colors.grey[100],
                    child:
                        displayVariant.imageUrl != null
                            ? Image.network(
                              displayVariant.imageUrl!,
                              fit: BoxFit.contain,
                              errorBuilder:
                                  (context, error, stackTrace) => const Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 72,
                                      color: Colors.grey,
                                    ),
                                  ),
                            )
                            : const Center(
                              child: Icon(
                                Icons.image,
                                size: 72,
                                color: Colors.grey,
                              ),
                            ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name
                      Text(
                        displayVariant.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Price
                      Text(
                        '${_formatCurrency(price)}đ',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE53935),
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Stock Status
                      Text(
                        hasStock
                            ? 'Còn hàng (${onlineStore!.quantity})'
                            : 'Hết hàng',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color:
                              hasStock ? const Color(0xFF2E7D32) : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Description
                      Text(
                        displayVariant.description ?? 'Sản phẩm chất lượng cao',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Color Selector
                      if (provider.availableColors.isNotEmpty) ...[
                        _buildColorSelector(provider),
                        const SizedBox(height: 24),
                      ],

                      // Size Selector
                      if (provider.availableSizes.isNotEmpty) ...[
                        _buildSizeSelector(provider),
                        const SizedBox(height: 24),
                      ],

                      // Quantity Selector
                      const Text(
                        'Số lượng',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          IconButton(
                            onPressed: provider.decreaseQty,
                            icon: const Icon(Icons.remove_circle_outline),
                            iconSize: 32,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              provider.quantity.toString(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: provider.increaseQty,
                            icon: const Icon(Icons.add_circle_outline),
                            iconSize: 32,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Comments Section
                      _buildCommentSection(context, provider),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom Action Buttons
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        hasStock
                            ? () async {
                              // Validate màu và size
                              if (provider.availableColors.length > 1 &&
                                  provider.effectiveSelectedColor == null) {
                                _showMessage('Vui lòng chọn màu sắc');
                                return;
                              }
                              if (provider.availableSizes.length > 1 &&
                                  provider.selectedSize == null) {
                                _showMessage('Vui lòng chọn kích cỡ');
                                return;
                              }

                              try {
                                await provider.addToCart();
                                if (!mounted) return;

                                // Reload cart immediately
                                print(
                                  '[MobileProductDetail] Reloading cart after add...',
                                );
                                await context.read<CartProvider>().loadCart();

                                _showMessage(
                                  "Đã thêm vào giỏ hàng",
                                  isError: false,
                                );
                              } catch (e) {
                                if (!mounted) return;
                                print(
                                  '[MobileProductDetail] Error adding to cart: $e',
                                );
                                _showMessage('Lỗi: $e');
                              }
                            }
                            : null,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: const BorderSide(
                        color: Color(0xFFE53935),
                        width: 2,
                      ),
                      foregroundColor: const Color(0xFFE53935),
                    ),
                    child: const Text(
                      'THÊM VÀO GIỎ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        hasStock
                            ? () async {
                              // Validate màu và size (chỉ yêu cầu chọn nếu có nhiều hơn 1 option)
                              if (provider.availableColors.length > 1 &&
                                  provider.effectiveSelectedColor == null) {
                                _showMessage('Vui lòng chọn màu sắc');
                                return;
                              }
                              if (provider.availableSizes.length > 1 &&
                                  provider.selectedSize == null) {
                                _showMessage('Vui lòng chọn kích cỡ');
                                return;
                              }

                              try {
                                // MUA NGAY: Navigate to checkout with product info
                                // Store temporary checkout data in CheckoutProvider
                                final checkoutProvider =
                                    context.read<CheckoutProvider>();
                                final displayVariant = provider.displayVariant;

                                if (displayVariant == null) {
                                  _showMessage('Không tìm thấy sản phẩm');
                                  return;
                                }

                                final onlineStore =
                                    provider.onlineStoreQuantity;
                                if (onlineStore == null) {
                                  _showMessage('Sản phẩm không có sẵn');
                                  return;
                                }

                                // Set direct buy mode with product details
                                checkoutProvider.setDirectBuyProduct(
                                  productId: displayVariant.id,
                                  productName: displayVariant.name,
                                  unitPrice: onlineStore.salePrice,
                                  quantity: provider.quantity,
                                  imageUrl: displayVariant.imageUrl,
                                );

                                print(
                                  '[MUA NGAY] Quantity=${provider.quantity}, Product=${displayVariant.id}, Price=${onlineStore.salePrice}',
                                );

                                // Chuyển sang trang checkout
                                if (!mounted) return;
                                context.push('/checkout');
                              } catch (e) {
                                if (!mounted) return;
                                _showMessage('Lỗi: $e');
                              }
                            }
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'MUA NGAY',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelector(ProductDetailProvider provider) {
    final List<String> colors = provider.availableColors.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Màu sắc',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children:
              colors.map((color) {
                final bool isSelected =
                    provider.effectiveSelectedColor == color;
                return GestureDetector(
                  onTap: () => provider.selectColor(isSelected ? null : color),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            isSelected
                                ? const Color(0xFFE53935)
                                : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                      color:
                          isSelected ? const Color(0xFFFFEBEE) : Colors.white,
                    ),
                    child: Text(
                      color,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color:
                            isSelected
                                ? const Color(0xFFE53935)
                                : Colors.black87,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildSizeSelector(ProductDetailProvider provider) {
    final List<String> sizes = provider.availableSizes.toList()..sort();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kích cỡ',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children:
              sizes.map((size) {
                final bool isSelected = provider.selectedSize == size;
                return GestureDetector(
                  onTap: () => provider.selectSize(isSelected ? null : size),
                  child: Container(
                    width: 60,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            isSelected
                                ? const Color(0xFFE53935)
                                : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                      color:
                          isSelected ? const Color(0xFFFFEBEE) : Colors.white,
                    ),
                    child: Text(
                      size,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color:
                            isSelected
                                ? const Color(0xFFE53935)
                                : Colors.black87,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildCommentSection(
    BuildContext context,
    ProductDetailProvider provider,
  ) {
    final comments = provider.comments;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        const Text(
          'Đánh giá sản phẩm',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildCommentInput(provider),
        const SizedBox(height: 24),
        if (provider.isCommentsLoading)
          const Center(child: CircularProgressIndicator())
        else if (provider.commentError != null)
          Text(
            provider.commentError!,
            style: const TextStyle(color: Colors.red),
          )
        else if (comments.isEmpty)
          const Text(
            'Chưa có đánh giá nào. Hãy là người đầu tiên!',
            style: TextStyle(color: Colors.black54),
          )
        else
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: comments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, index) => _buildCommentTile(comments[index]),
          ),
      ],
    );
  }

  Widget _buildCommentInput(ProductDetailProvider provider) {
    final bool canInteract =
        provider.isUserLoggedIn && !provider.isMutatingComment;
    final String hint =
        provider.isUserLoggedIn
            ? 'Viết đánh giá của bạn...'
            : 'Đăng nhập để đánh giá';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _commentController,
          minLines: 2,
          maxLines: 4,
          enabled: provider.isUserLoggedIn,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.grey[100],
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed:
                canInteract ? () => _handleSubmitComment(provider) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child:
                provider.isMutatingComment
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Text('Gửi đánh giá'),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentTile(Comment comment) {
    final initials =
        comment.userName.isNotEmpty ? comment.userName[0].toUpperCase() : '?';
    final dateLabel = MobileProductDetailScreen._commentDateFormat.format(
      comment.createdAt,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFFFCDD2),
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE53935),
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.userName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      dateLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment.content,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }

  static String _formatCurrency(double value) {
    return MobileProductDetailScreen._currencyFormat.format(value);
  }
}
