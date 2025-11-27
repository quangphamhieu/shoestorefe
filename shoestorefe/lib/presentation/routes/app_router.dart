import 'package:go_router/go_router.dart';
import 'package:shoestorefe/presentation/admin/screens/user/sign_up_screen.dart';
import 'package:shoestorefe/presentation/admin/screens/user/user_screen.dart';
import 'package:shoestorefe/core/network/token_handler.dart';
import 'package:shoestorefe/core/utils/auth_utils.dart';
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
  initialLocation: '/',
  redirect: (context, state) {
    final isLoggedIn = TokenHandler().hasToken();
    final String location = state.matchedLocation;

    final bool isAuthRoute =
        location == '/login' || location == '/signup';

    // Các route public mà user chưa đăng nhập vẫn xem được
    final Set<String> publicRoutes = {
      '/',
      '/home',
      '/login',
      '/signup',
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
        return '/home';
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
