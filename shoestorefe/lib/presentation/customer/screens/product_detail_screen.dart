import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/comment.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/store_quantity.dart';
import '../../../injection_container.dart';
import '../provider/product_detail_provider.dart';
import '../widgets/customer_header.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productName;
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '',
    decimalDigits: 0,
  );
  static final DateFormat _commentDateFormat =
      DateFormat('dd/MM/yyyy HH:mm');

  const ProductDetailScreen({super.key, required this.productName});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
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

  Future<void> _showEditCommentDialog(
    Comment comment,
    ProductDetailProvider provider,
  ) async {
    final controller = TextEditingController(text: comment.content);
    final updatedContent = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Chỉnh sửa bình luận'),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Nội dung bình luận',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (updatedContent == null) return;
    final result = await provider.updateComment(comment.id, updatedContent);
    if (!mounted) return;
    if (result != null) {
      _showMessage(result);
    } else {
      _showMessage('Đã cập nhật bình luận', isError: false);
    }
  }

  Future<void> _confirmDeleteComment(
    Comment comment,
    ProductDetailProvider provider,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa bình luận'),
        content: const Text('Bạn có chắc muốn xóa bình luận này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    final result = await provider.deleteComment(comment.id);
    if (!mounted) return;
    if (result != null) {
      _showMessage(result);
    } else {
      _showMessage('Đã xóa bình luận', isError: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProductDetailProvider>(
      create: (_) => ProductDetailProvider(
        getListProductByNameUseCase: sl(),
        getCommentsByProductIdUseCase: sl(),
        createCommentUseCase: sl(),
        updateCommentUseCase: sl(),
        deleteCommentUseCase: sl(),
      )..loadByName(widget.productName),
      child: Consumer<ProductDetailProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: const Color(0xFFFFF6F8),
            body: Column(
              children: [
                const CustomerHeader(),
                Expanded(
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : provider.variants.isEmpty
                          ? const Center(child: Text('Không tìm thấy sản phẩm'))
                          : _buildContent(context, provider),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ProductDetailProvider provider,
  ) {
    final Product? displayVariant = provider.displayVariant;
    final StoreQuantity? onlineStore = provider.onlineStoreQuantity;

    if (displayVariant == null) {
      return const Center(child: Text('Không tìm thấy sản phẩm phù hợp'));
    }

    final bool hasStock = (onlineStore?.quantity ?? 0) > 0;
    final double price = onlineStore?.salePrice ?? displayVariant.originalPrice;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isNarrow = constraints.maxWidth < 1100;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isNarrow
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildImageSection(provider, displayVariant),
                            const SizedBox(height: 32),
                            _buildInfoSection(
                              provider: provider,
                              displayVariant: displayVariant,
                              price: price,
                              hasStock: hasStock,
                              onlineStore: onlineStore,
                            ),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildImageSection(
                                provider,
                                displayVariant,
                              ),
                            ),
                            const SizedBox(width: 48),
                            Expanded(
                              child: _buildInfoSection(
                                provider: provider,
                                displayVariant: displayVariant,
                                price: price,
                                hasStock: hasStock,
                                onlineStore: onlineStore,
                              ),
                            ),
                          ],
                        ),
                  const SizedBox(height: 32),
                  _buildCommentSection(context, provider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildColorSelector(ProductDetailProvider provider) {
    final List<String> colors = provider.availableColors.toList();
    if (colors.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Màu',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: colors.map((color) {
            final bool isSelected = provider.effectiveSelectedColor == color;
            final String? previewImage = provider.imageForColor(color);

            return GestureDetector(
              onTap: () => provider.selectColor(isSelected ? null : color),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 88,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFE53935) : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 60,
                        width: double.infinity,
                        child: previewImage != null
                            ? Image.network(
                                previewImage,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                ),
                              )
                            : Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.image, color: Colors.grey),
                              ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      color,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.black : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildImageSection(
    ProductDetailProvider provider,
    Product displayVariant,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              color: Colors.grey[100],
              child: displayVariant.imageUrl != null
                  ? Image.network(
                      displayVariant.imageUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Center(
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
        ),
        if (provider.availableColors.isNotEmpty) ...[
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: _buildColorSelector(provider),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoSection({
    required ProductDetailProvider provider,
    required Product displayVariant,
    required double price,
    required bool hasStock,
    required StoreQuantity? onlineStore,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displayVariant.name,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          displayVariant.description ?? 'Sản phẩm huyền thoại',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '${_formatCurrency(price)} VND',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: Color(0xFFE53935),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          hasStock
              ? 'Tình trạng: Còn hàng (${onlineStore!.quantity})'
              : 'Tình trạng: Hết hàng',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: hasStock ? const Color(0xFF2E7D32) : Colors.red,
          ),
        ),
        const SizedBox(height: 32),
        _buildSizeSelector(provider),
        const SizedBox(height: 32),
        _buildStoreInfo(onlineStore),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: hasStock ? () {} : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'MUA NGAY',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton(
                onPressed: hasStock ? () {} : null,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Color(0xFFE53935), width: 2),
                  foregroundColor: const Color(0xFFE53935),
                ),
                child: const Text(
                  'THÊM VÀO GIỎ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSizeSelector(ProductDetailProvider provider) {
    final List<String> sizes = provider.availableSizes.toList()..sort();
    if (sizes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chọn size',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: sizes.map((size) {
            final bool isSelected = provider.selectedSize == size;
            return GestureDetector(
              onTap: () => provider.selectSize(isSelected ? null : size),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 60,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFE53935) : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                  color: isSelected ? const Color(0xFFFFEBEE) : Colors.white,
                ),
                child: Text(
                  size,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? const Color(0xFFE53935) : Colors.black87,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            foregroundColor: Colors.grey[700],
          ),
          child: const Text('Hướng dẫn chọn size'),
        ),
      ],
    );
  }

  Widget _buildStoreInfo(StoreQuantity? store) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
        color: Colors.grey[50],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tồn kho cửa hàng online',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Số lượng: ${store?.quantity ?? 0}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            store != null
                ? 'Sale price: ${_formatCurrency(store.salePrice)} VND'
                : 'Sale price: Đang cập nhật',
            style: TextStyle(
              fontSize: 15,
              color: store != null ? Colors.black87 : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatCurrency(double value) {
    return ProductDetailScreen._currencyFormat.format(value);
  }

  Widget _buildCommentSection(
    BuildContext context,
    ProductDetailProvider provider,
  ) {
    final comments = provider.comments;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bình luận',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
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
            'Chưa có bình luận nào cho sản phẩm này. Hãy là người đầu tiên!',
            style: TextStyle(color: Colors.black54),
          )
        else
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: comments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, index) =>
                _buildCommentTile(context, comments[index], provider),
          ),
      ],
    );
  }

  Widget _buildCommentInput(ProductDetailProvider provider) {
    final bool canInteract =
        provider.isUserLoggedIn && !provider.isMutatingComment;
    final String hint = provider.isUserLoggedIn
        ? 'Chia sẻ cảm nhận của bạn về sản phẩm...'
        : 'Đăng nhập để bình luận';

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
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            filled: true,
            fillColor: Colors.grey[100],
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: canInteract
                ? () => _handleSubmitComment(provider)
                : null,
            icon: provider.isMutatingComment
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send, size: 18),
            label: const Text('Thêm bình luận'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentTile(
    BuildContext context,
    Comment comment,
    ProductDetailProvider provider,
  ) {
    final bool isOwner = provider.ownsComment(comment);
    final initials =
        comment.userName.isNotEmpty ? comment.userName[0].toUpperCase() : '?';
    final dateLabel =
        ProductDetailScreen._commentDateFormat.format(comment.createdAt);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFFFCDD2),
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE53935),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
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
              if (isOwner)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      tooltip: 'Chỉnh sửa',
                      onPressed: provider.isMutatingComment
                          ? null
                          : () => _showEditCommentDialog(comment, provider),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      tooltip: 'Xóa',
                      onPressed: provider.isMutatingComment
                          ? null
                          : () => _confirmDeleteComment(comment, provider),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment.content,
            style: const TextStyle(fontSize: 15, height: 1.4),
          ),
        ],
      ),
    );
  }
}


