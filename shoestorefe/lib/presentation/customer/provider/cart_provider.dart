import 'package:flutter/material.dart';
import 'package:shoestorefe/domain/entities/cart.dart';
import 'package:shoestorefe/domain/entities/cart_item.dart';
import 'package:shoestorefe/domain/repositories/cart_repository.dart';
import 'package:shoestorefe/domain/entities/product.dart';
import 'package:shoestorefe/domain/repositories/product_repository.dart';

class CartProvider extends ChangeNotifier {
  final CartRepository cartRepository;
  final ProductRepository productRepository;

  CartProvider({required this.cartRepository, required this.productRepository});

  Cart? _cart;
  Cart? get cart => _cart;

  Map<int, Product> _products = {};
  Map<int, bool> _selectedItems = {};

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Get product details for cart item
  Product? getProduct(int productId) => _products[productId];

  // Check if item is selected
  bool isSelected(int cartItemId) => _selectedItems[cartItemId] ?? false;

  // Get all selected items
  List<CartItem> get selectedItems {
    if (_cart == null) return [];
    return _cart!.items
        .where((item) => _selectedItems[item.id] == true)
        .toList();
  }

  // Calculate total for selected items
  double get selectedTotal {
    return selectedItems.fold(
      0,
      (sum, item) => sum + (item.unitPrice * item.quantity),
    );
  }

  // Toggle item selection
  void toggleSelection(int cartItemId) {
    _selectedItems[cartItemId] = !(_selectedItems[cartItemId] ?? false);
    notifyListeners();
  }

  // Select all items
  void selectAll(bool value) {
    if (_cart != null) {
      for (var item in _cart!.items) {
        _selectedItems[item.id] = value;
      }
      notifyListeners();
    }
  }

  // Clear all selections
  void clearAllSelections() {
    _selectedItems.clear();
    notifyListeners();
  }

  // Load cart from API
  Future<void> loadCart() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('[CartProvider] Loading cart...');
      _cart = await cartRepository.getCartByUserId();
      print(
        '[CartProvider] Cart loaded: ${_cart?.id}, Items: ${_cart?.items.length}',
      );

      // Load product details for each cart item
      if (_cart != null && _cart!.items.isNotEmpty) {
        print(
          '[CartProvider] Loading ${_cart!.items.length} product details...',
        );
        for (var item in _cart!.items) {
          if (!_products.containsKey(item.productId)) {
            print('[CartProvider] Loading product ${item.productId}...');
            final product = await productRepository.getById(item.productId);
            if (product != null) {
              _products[item.productId] = product;
              print(
                '[CartProvider] Product ${item.productId} loaded: ${product.name}',
              );
            }
          }
        }
      }
      print('[CartProvider] Cart load complete');
    } catch (e) {
      print('[CartProvider] Error loading cart: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update quantity
  Future<void> updateQuantity(int cartItemId, int newQuantity) async {
    if (newQuantity < 1) return;

    try {
      await cartRepository.updateItemQuantity(cartItemId, newQuantity);
      await loadCart(); // Reload to get updated cart
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Remove item
  Future<void> removeItem(int cartItemId) async {
    try {
      await cartRepository.removeItemFromCart(cartItemId);
      _selectedItems.remove(cartItemId);
      await loadCart();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Remove selected items
  Future<void> removeSelectedItems() async {
    final itemsToRemove = selectedItems.map((item) => item.id).toList();

    for (var itemId in itemsToRemove) {
      try {
        await cartRepository.removeItemFromCart(itemId);
        _selectedItems.remove(itemId);
      } catch (e) {
        _error = e.toString();
      }
    }

    await loadCart();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
