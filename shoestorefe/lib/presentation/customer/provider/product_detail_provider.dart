import 'package:flutter/material.dart';

import '../../../core/network/token_handler.dart';
import '../../../domain/entities/comment.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/store_quantity.dart';

import '../../../domain/usecases/comment/create_comment_usecase.dart';
import '../../../domain/usecases/comment/delete_comment_usecase.dart';
import '../../../domain/usecases/comment/get_comments_by_product_id_usecase.dart';
import '../../../domain/usecases/comment/update_comment_usecase.dart';

import '../../../domain/usecases/product/get_list_product_by_name.dart';
import '../../../domain/usecases/cart/add_item_to_cart.dart';

class ProductDetailProvider extends ChangeNotifier {
  final GetListProductByNameUseCase getListProductByNameUseCase;
  final GetCommentsByProductIdUseCase getCommentsByProductIdUseCase;
  final CreateCommentUseCase createCommentUseCase;
  final UpdateCommentUseCase updateCommentUseCase;
  final DeleteCommentUseCase deleteCommentUseCase;
  final AddItemToCart addItemToCartUseCase;

  final TokenHandler _tokenHandler;
  static const int _onlineStoreId = 1;

  ProductDetailProvider({
    required this.getListProductByNameUseCase,
    required this.getCommentsByProductIdUseCase,
    required this.createCommentUseCase,
    required this.updateCommentUseCase,
    required this.deleteCommentUseCase,
    required this.addItemToCartUseCase,
    TokenHandler? tokenHandler,
  }) : _tokenHandler = tokenHandler ?? TokenHandler();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _productName = '';
  String get productName => _productName;

  List<Product> _variants = [];
  List<Product> get variants => _variants;

  bool _isCommentsLoading = false;
  bool get isCommentsLoading => _isCommentsLoading;

  bool _isMutatingComment = false;
  bool get isMutatingComment => _isMutatingComment;

  List<Comment> _comments = [];
  List<Comment> get comments => _comments;

  String? _commentError;
  String? get commentError => _commentError;

  // ─────────────────────────────────────────────
  // Product Filters
  String? _selectedColor;
  String? get selectedColor => _selectedColor;

  String? _selectedSize;
  String? get selectedSize => _selectedSize;

  Set<String> get availableColors =>
      _variants.where((p) => p.color != null).map((p) => p.color!).toSet();

  Set<String> get availableSizes =>
      _variants.where((p) => p.size != null).map((p) => p.size!).toSet();

  String? get effectiveSelectedColor => _selectedColor ?? displayVariant?.color;

  /// Tổng số lượng tồn kho theo filter màu/size hiện tại (cộng dồn tất cả store)
  int get filteredStockQuantity {
    final filtered = _filteredVariants;
    int total = 0;
    for (final product in filtered) {
      for (final StoreQuantity sq in product.stores) {
        total += sq.quantity;
      }
    }
    return total;
  }

  /// Danh sách store + tồn kho theo filter hiện tại
  Map<String, int> get stockByStore {
    final Map<String, int> result = {};
    for (final product in _filteredVariants) {
      for (final StoreQuantity sq in product.stores) {
        result.update(
          sq.storeName,
          (value) => value + sq.quantity,
          ifAbsent: () => sq.quantity,
        );
      }
    }
    return result;
  }

  Product? get displayVariant {
    if (_variants.isEmpty) return null;
    final filtered = _filteredVariants;
    if (filtered.isNotEmpty) {
      return filtered.first;
    }
    if (_selectedColor != null) {
      try {
        return _variants.firstWhere((p) => p.color == _selectedColor);
      } catch (_) {}
    }
    return _variants.first;
  }

  StoreQuantity? get onlineStoreQuantity {
    final Product? variant = displayVariant;
    if (variant == null) return null;
    try {
      return variant.stores.firstWhere((sq) => sq.storeId == _onlineStoreId);
    } catch (_) {
      return null;
    }
  }

  String? imageForColor(String color) {
    try {
      return _variants
          .firstWhere((p) => p.color == color && p.imageUrl != null)
          .imageUrl;
    } catch (_) {
      return null;
    }
  }

  List<Product> get _filteredVariants {
    return _variants.where((p) {
      final matchColor =
          _selectedColor == null ||
          p.color == null ||
          p.color == _selectedColor;

      final matchSize =
          _selectedSize == null || p.size == null || p.size == _selectedSize;

      return matchColor && matchSize;
    }).toList();
  }

  // ─────────────────────────────────────────────
  // Load Product + Comments
  Future<void> loadByName(String name) async {
    _productName = name;
    _isLoading = true;
    notifyListeners();

    try {
      _variants = await getListProductByNameUseCase(name);
      await _loadCommentsForVariants();
    } catch (_) {
      _variants = [];
      _comments = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadCommentsForVariants() async {
    final ids = _variants.map((p) => p.id).toSet();

    if (ids.isEmpty) {
      _comments = [];
      return;
    }

    _isCommentsLoading = true;
    _commentError = null;
    notifyListeners();

    try {
      final futures = ids.map((id) => getCommentsByProductIdUseCase(id));
      final results = await Future.wait(futures);

      _comments =
          results.expand((list) => list).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      _commentError = "Không thể tải bình luận: $e";
    }

    _isCommentsLoading = false;
    notifyListeners();
  }

  // ─────────────────────────────────────────────
  // Select Color / Size
  void selectColor(String? color) {
    _selectedColor = color;

    if (color != null && _selectedSize != null) {
      final hasCombo = _variants.any(
        (p) => p.color == color && p.size == _selectedSize,
      );
      if (!hasCombo) _selectedSize = null;
    }

    notifyListeners();
  }

  void selectSize(String? size) {
    _selectedSize = size;
    notifyListeners();
  }

  void clearSelection() {
    _selectedColor = null;
    _selectedSize = null;
    notifyListeners();
  }

  // ─────────────────────────────────────────────
  // User, Comment CRUD
  bool get isUserLoggedIn => _tokenHandler.hasToken();

  bool ownsComment(Comment comment) {
    final userId = _tokenHandler.getUserId();
    if (userId == null) return false;
    return comment.userId.toString() == userId;
  }

  Future<String?> addComment(String content) async {
    final userIdStr = _tokenHandler.getUserId();
    if (userIdStr == null) return "Bạn cần đăng nhập để bình luận";

    final product = displayVariant;
    if (product == null) return "Không xác định ở sản phẩm để comment";

    final trimmed = content.trim();
    if (trimmed.length < 3) return "Bình luận phải có ít nhất 3 ký tự";

    final userId = int.tryParse(userIdStr);
    if (userId == null) return "Không đọc được userId";

    _isMutatingComment = true;
    notifyListeners();

    try {
      final comment = await createCommentUseCase(
        userId: userId,
        productId: product.id,
        content: trimmed,
      );

      _comments = [comment, ..._comments]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return null;
    } catch (e) {
      return "Không thể thêm bình luận: $e";
    } finally {
      _isMutatingComment = false;
      notifyListeners();
    }
  }

  Future<String?> updateComment(int commentId, String content) async {
    final trimmed = content.trim();
    if (trimmed.length < 3) return "Bình luận phải có ít nhất 3 ký tự";

    _isMutatingComment = true;
    notifyListeners();

    try {
      final updated = await updateCommentUseCase(commentId, content: trimmed);

      if (updated == null) return "Không tìm thấy bình luận";

      _comments =
          _comments.map((c) => c.id == updated.id ? updated : c).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return null;
    } catch (e) {
      return "Không thể cập nhật bình luận: $e";
    } finally {
      _isMutatingComment = false;
      notifyListeners();
    }
  }

  Future<String?> deleteComment(int commentId) async {
    _isMutatingComment = true;
    notifyListeners();

    try {
      final success = await deleteCommentUseCase(commentId);

      if (success) {
        _comments = _comments.where((c) => c.id != commentId).toList();
        notifyListeners();
        return null;
      }

      return "Không thể xóa bình luận";
    } catch (e) {
      return "Không thể xóa bình luận: $e";
    } finally {
      _isMutatingComment = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────
  // ADD TO CART + QUANTITY (merge từ file dưới)
  int _quantity = 1;
  int get quantity => _quantity;

  void increaseQty() {
    _quantity++;
    notifyListeners();
  }

  void decreaseQty() {
    if (_quantity > 1) {
      _quantity--;
      notifyListeners();
    }
  }

  Future<void> addToCart() async {
    final variant = displayVariant;
    if (variant == null) {
      print('[ProductDetailProvider] Error: No variant selected');
      throw Exception('Không có sản phẩm được chọn');
    }

    print(
      '[ProductDetailProvider] Adding to cart: Product ID=${variant.id}, Quantity=$_quantity',
    );

    try {
      await addItemToCartUseCase.call(variant.id, _quantity);
      print('[ProductDetailProvider] Added to cart successfully');
    } catch (e) {
      print('[ProductDetailProvider] Error adding to cart: $e');
      rethrow;
    }
  }
}
