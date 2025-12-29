import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../provider/customer_provider.dart';
import '../provider/cart_provider.dart';
import '../provider/order_history_provider.dart';
import 'package:shoestorefe/core/network/token_handler.dart';
import 'package:shoestorefe/core/utils/auth_utils.dart';
import 'web_cart_overlay.dart';
import 'web_order_history_overlay.dart';
import 'web_profile_overlay.dart';

class CustomerHeader extends StatefulWidget {
  const CustomerHeader({super.key});

  @override
  State<CustomerHeader> createState() => _CustomerHeaderState();
}

class _CustomerHeaderState extends State<CustomerHeader> {
  final LayerLink _cartLayerLink = LayerLink();
  final LayerLink _historyLayerLink = LayerLink();
  final LayerLink _profileLayerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  String? _activeOverlay; // 'cart', 'history', 'profile'

  @override
  void dispose() {
    _closeOverlay();
    super.dispose();
  }

  void _closeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _activeOverlay = null;
  }

  void _toggleOverlay(
      BuildContext context, LayerLink link, String name, Widget overlayWidget, double width) {
    if (_activeOverlay == name) {
      _closeOverlay();
      return;
    }

    _closeOverlay(); // Close others first

    // Load data
    if (name == 'cart') {
      context.read<CartProvider>().loadCart();
    } else if (name == 'history') {
      context.read<OrderHistoryProvider>().loadOrders();
    }

    // Alignment logic
    Offset offset;
    if (name == 'profile') {
      // Profile is typically right-aligned or below the name
      offset = const Offset(0, 30);
    } else {
       // Icon size is 36. Alignment: right aligned.
       offset = Offset(36.0 - width, 45.0);
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeOverlay,
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            width: width,
            child: CompositedTransformFollower(
              link: link,
              showWhenUnlinked: false,
              offset: offset,
              child: Material(
                color: Colors.transparent,
                child: overlayWidget,
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _activeOverlay = name;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CustomerProvider>();
    final isLoggedIn = TokenHandler().hasToken();
    final userName = isLoggedIn ? TokenHandler().getUserName() : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final isMobile = maxWidth < 760;
        final isTablet = maxWidth < 1100;

        // Search Bar
        final searchBar = SizedBox(
          width: isMobile ? double.infinity : 250,
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              onChanged: provider.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm sản phẩm...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[400],
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ),
        );

        final actionIcons = [
          // History Icon
           if (isLoggedIn)
            _buildInteractiveIcon(
              _historyLayerLink,
              Icons.receipt_long_outlined, // History icon
              onTap: () => _toggleOverlay(
                context, _historyLayerLink, 'history', const WebOrderHistoryOverlay(), 400),
            ),
          // Cart Icon
          Stack(
            clipBehavior: Clip.none,
            children: [
               _buildInteractiveIcon(
                _cartLayerLink,
                Icons.shopping_bag_outlined,
                onTap: () => _toggleOverlay(
                  context, _cartLayerLink, 'cart', const WebCartOverlay(), 350),
              ),
              Consumer<CartProvider>(
                builder: (context, cartProvider, child) {
                  final itemCount = cartProvider.cart?.items.length ?? 0;
                  if (itemCount == 0) return const SizedBox.shrink();
                  return Positioned(
                    right: -4,
                    top: -4,
                    child: IgnorePointer(
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                        child: Text(
                          '$itemCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }
              ),
            ],
          ),
        ];

        final authWidgets =
            isLoggedIn && userName != null
                ? [
                    CompositedTransformTarget(
                      link: _profileLayerLink,
                      child: InkWell(
                        onTap: () => _toggleOverlay(
                          context, 
                          _profileLayerLink, 
                          'profile', 
                          WebProfileOverlay(onClose: _closeOverlay), 
                          200
                        ),
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person, size: 20, color: Colors.grey[700]),
                              const SizedBox(width: 8),
                              Text(
                                userName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_drop_down, size: 20, color: Colors.black54),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ]
                : [
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: _buildHeaderButton('Đăng Nhập'),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/signup'),
                      child: _buildHeaderButton('Đăng ký', isPrimary: true),
                    ),
                  ];

        final actions =
            isMobile
                ? Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    ...actionIcons,
                    ...authWidgets,
                  ],
                )
                : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < actionIcons.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      actionIcons[i],
                    ],
                    const SizedBox(width: 16),
                    ...authWidgets,
                  ],
                );

        // Logo with GestureDetector
        final logo = GestureDetector(
          onTap: () => context.go('/home'),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/brand_icon.jpg',
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.store, color: Colors.black54),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Cửa hàng giày thể thao Hello',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 16 : 24,
            vertical: isMobile ? 12 : 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
                isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              if (isMobile) ...[
                logo,
                const SizedBox(height: 12),
                searchBar,
                const SizedBox(height: 12),
                actions,
              ] else ...[
                Row(
                  children: [
                    logo,
                    const Spacer(), // Push search and actions to right, or keep search center? 
                    // Let's keep search reasonably close or centered if possible, but Spacer is safe choice for "Menu gone"
                    searchBar,
                    const SizedBox(width: 24),
                    actions,
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildInteractiveIcon(LayerLink link, IconData icon, {required VoidCallback onTap}) {
    return CompositedTransformTarget(
      link: link,
      child: Material( // Material for ripple effect
        color: Colors.transparent, 
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Colors.black87),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderButton(String label, {bool isPrimary = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isPrimary ? Colors.red : Colors.transparent,
        border: Border.all(color: isPrimary ? Colors.red : Colors.grey[300]!),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isPrimary ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}
