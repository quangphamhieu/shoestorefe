import 'package:go_router/go_router.dart';
import 'package:shoestorefe/presentation/admin/screens/user/sign_up_screen.dart';
import 'package:shoestorefe/presentation/admin/screens/user/user_screen.dart';
import 'package:shoestorefe/core/network/token_handler.dart';
import 'package:shoestorefe/core/utils/auth_utils.dart';
import 'package:shoestorefe/presentation/customer/screens/cart_screen.dart';
import 'package:shoestorefe/presentation/customer/screens/mobile_checkout_screen.dart';
import 'package:shoestorefe/presentation/customer/screens/web_checkout_screen.dart'; // NEW
import 'package:shoestorefe/presentation/customer/screens/web_order_detail_screen.dart'; // NEW
import 'package:shoestorefe/domain/entities/order.dart'; // NEW
import 'package:shoestorefe/presentation/customer/screens/mobile_home_screen.dart';
import 'package:shoestorefe/presentation/customer/screens/mobile_login_screen.dart';
import 'package:shoestorefe/presentation/customer/screens/mobile_product_detail_screen.dart';
import 'package:shoestorefe/presentation/customer/screens/mobile_signup_screen.dart';
import 'package:shoestorefe/presentation/customer/screens/order_history_screen.dart';
import 'package:shoestorefe/presentation/customer/screens/profile_screen.dart';
import 'package:shoestorefe/presentation/customer/screens/search_results_screen.dart';
import '../admin/screens/dashboard/dashboard_screen.dart';
import '../admin/screens/brand/brand_screen.dart';
import '../admin/screens/supplier/supplier_screen.dart';
import '../admin/screens/product/product_screen.dart';
import '../admin/screens/order/order_screen.dart';
import '../admin/screens/receipt/receipt_screen.dart';
import '../admin/screens/store/store_screen.dart';
import '../admin/screens/promotion/promotion_screen.dart';
import '../admin/screens/user/login_screen.dart';
import '../customer/screens/home_screen.dart';
import '../customer/screens/product_detail_screen.dart';
import '../staff/screens/order/staff_order_screen.dart';

final GoRouter appRouter = GoRouter(
  // Màn hình mặc định luôn là trang home của customer
  initialLocation: '/', //Nếu là mobile thì đổi thành '/mobile-login'
  redirect: (context, state) {
    final isLoggedIn = TokenHandler().hasToken();
    final String location = state.matchedLocation;

    final bool isAuthRoute =
        location == '/login' ||
        location == '/signup' ||
        location == '/mobile-login' ||
        location == '/mobile-signup';

    // Các route public mà user chưa đăng nhập vẫn xem được
    final Set<String> publicRoutes = {
      '/',
      '/home',
      '/login',
      '/signup',
      '/mobile-login',
      '/mobile-signup',
    };

    // Các route chỉ dành cho admin (dashboard + module quản trị)
    final Set<String> adminRoutes = {
      '/dashboard',
      '/brand',
      '/supplier',
      '/product',
      '/order',
      '/receipt',
      '/store',
      '/promotion',
      '/user',
    };

    // Các route dành cho staff
    final Set<String> staffRoutes = {
      '/staff/order',
    };

    // Chưa đăng nhập mà truy cập admin/staff route -> chuyển sang login
    if (!isLoggedIn && (adminRoutes.contains(location) || staffRoutes.contains(location))) {
      return '/login';
    }

    // Đã đăng nhập mà vẫn ở trang login/signup -> chuyển theo role
    if (isLoggedIn && isAuthRoute) {
      final role = AuthUtils.getUserRole();
      if (role == "Super Admin" || role == "Admin") {
        return '/dashboard';
      } else if (role == "Staff") {
        return '/staff/order';
      } else if (role == "Customer") {
        return '/home'; //Nếu là mobile thì đổi thành '/mobile-home'
      }
    }

    // Nếu là route public hoặc đã pass các rule trên thì không redirect
    if (publicRoutes.contains(location) || 
        (!adminRoutes.contains(location) && !staffRoutes.contains(location))) {
      return null;
    }

    return null;
  },
  routes: [
    // Trang home customer luôn ở root
    GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(
      path: '/product-detail',
      builder: (_, state) {
        final name = state.extra as String? ?? '';
        return ProductDetailScreen(productName: name);
      },
    ),
    // Customer mobile routes
    GoRoute(path: '/mobile-home', builder: (_, __) => const MobileHomeScreen()),
    GoRoute(
      path: '/mobile-login',
      builder: (_, __) => const MobileLoginScreen(),
    ),
    GoRoute(
      path: '/mobile-signup',
      builder: (_, __) => const MobileSignUpScreen(),
    ),
    GoRoute(
      path: '/mobile-product-detail',
      builder: (_, state) {
        final name = state.extra as String? ?? '';
        return MobileProductDetailScreen(productName: name);
      },
    ),
    GoRoute(
      path: '/search-results',
      builder: (_, state) {
        final query = state.extra as String? ?? '';
        return SearchResultsScreen(query: query);
      },
    ),
    GoRoute(path: '/cart', builder: (_, __) => const CartScreen()),
    GoRoute(path: '/checkout', builder: (_, __) => const CheckoutScreen()),
    GoRoute(path: '/web-checkout', builder: (_, __) => const WebCheckoutScreen()),
    GoRoute(
      path: '/web-order-detail', 
      builder: (_, state) {
        // Need to import Order entity
        final order = state.extra as Order;
        return WebOrderDetailScreen(order: order);
      }
    ),
    GoRoute(path: '/orders', builder: (_, __) => const OrderHistoryScreen()),
    GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
    GoRoute(path: '/signup', builder: (_, __) => const SignUpScreen()),
    GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
    GoRoute(path: '/brand', builder: (_, __) => const BrandScreen()),
    GoRoute(path: '/supplier', builder: (_, __) => const SupplierScreen()),
    GoRoute(path: '/product', builder: (_, __) => const ProductScreen()),
    GoRoute(path: '/order', builder: (_, __) => const OrderScreen()),
    GoRoute(path: '/receipt', builder: (_, __) => const ReceiptScreen()),
    GoRoute(path: '/store', builder: (_, __) => const StoreScreen()),
    GoRoute(path: '/promotion', builder: (_, __) => const PromotionScreen()),
    GoRoute(path: '/user', builder: (_, __) => const UserScreen()),
    // Staff routes
    GoRoute(path: '/staff/order', builder: (_, __) => const StaffOrderScreen()),
  ],
);
