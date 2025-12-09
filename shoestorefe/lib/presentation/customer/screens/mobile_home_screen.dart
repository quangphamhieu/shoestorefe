import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../provider/customer_provider.dart';
import '../provider/notification_provider.dart';
import '../widgets/customer_bottom_nav.dart';
import 'filter_screen.dart';
import 'mobile_notifications_screen.dart';

class MobileHomeScreen extends StatefulWidget {
  const MobileHomeScreen({super.key});

  @override
  State<MobileHomeScreen> createState() => _MobileHomeScreenState();
}

class _MobileHomeScreenState extends State<MobileHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CustomerProvider>().loadProducts();
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CustomerProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'ShoeStore',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              _showSearchDialog(context, provider);
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MobileNotificationsScreen(),
                    ),
                  );
                },
              ),
              Consumer<NotificationProvider>(
                builder: (context, notifProvider, _) {
                  if (notifProvider.unreadCount > 0) {
                    return Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          notifProvider.unreadCount > 9
                              ? '9+'
                              : notifProvider.unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ],
      ),
      body:
          provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: () => provider.loadProducts(),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Banner Section
                    Container(
                      height: 160,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade400,
                            Colors.purple.shade400,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 20,
                            top: 30,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Giày thể thao',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Giảm đến 50%',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.blue,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text('Mua ngay'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Categories Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Danh mục',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Xem tất cả'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildCategoryCard('Thể thao', Icons.sports_soccer),
                          _buildCategoryCard('Cao gót', Icons.landscape),
                          _buildCategoryCard('Sandal', Icons.beach_access),
                          _buildCategoryCard('Giày tây', Icons.work),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Products Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Sản phẩm nổi bật',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
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
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (_) => ChangeNotifierProvider.value(
                                          value: provider,
                                          child: const FilterScreen(),
                                        ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Active filters chips
                    if (provider.hasActiveFilters) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (provider.selectedColor != null)
                            Chip(
                              label: Text('Màu: ${provider.selectedColor}'),
                              onDeleted: () => provider.setColor(null),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              backgroundColor: Colors.blue.shade50,
                            ),
                          if (provider.selectedSize != null)
                            Chip(
                              label: Text('Size: ${provider.selectedSize}'),
                              onDeleted: () => provider.setSize(null),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              backgroundColor: Colors.blue.shade50,
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
                              backgroundColor: Colors.blue.shade50,
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),

                    // Product Grid
                    provider.filteredProductGroups.isEmpty
                        ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Text('Chưa có sản phẩm nào'),
                          ),
                        )
                        : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.7,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                          itemCount: provider.filteredProductGroups.length,
                          itemBuilder: (context, index) {
                            final productGroup =
                                provider.filteredProductGroups[index];
                            final product = productGroup.representative;
                            return _buildProductCard(context, product);
                          },
                        ),
                  ],
                ),
              ),
      bottomNavigationBar: const CustomerBottomNav(currentIndex: 0),
    );
  }

  Widget _buildCategoryCard(String label, IconData icon) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: Colors.black87),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, dynamic product) {
    final imageUrl = product.imageUrl ?? '';
    final name = product.name ?? 'Không có tên';
    final price =
        product.stores?.isNotEmpty == true
            ? product.stores[0].salePrice ?? product.originalPrice ?? 0
            : product.originalPrice ?? 0;

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
              child: Container(
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

  void _showSearchDialog(BuildContext context, CustomerProvider provider) {
    final TextEditingController searchController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Tìm kiếm sản phẩm'),
            content: TextField(
              controller: searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Nhập tên sản phẩm...',
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  Navigator.pop(ctx);
                  _performSearch(value.trim(), provider);
                }
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  final query = searchController.text.trim();
                  if (query.isNotEmpty) {
                    Navigator.pop(ctx);
                    _performSearch(query, provider);
                  }
                },
                child: const Text('Tìm'),
              ),
            ],
          ),
    );
  }

  void _performSearch(String query, CustomerProvider provider) {
    // Navigate to search results screen
    context.push('/search-results', extra: query);
  }
}
