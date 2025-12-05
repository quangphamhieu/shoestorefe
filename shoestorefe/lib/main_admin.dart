import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoestorefe/presentation/admin/provider/login_provider.dart';
import 'package:shoestorefe/presentation/admin/provider/sign_up_provider.dart';
import 'package:shoestorefe/presentation/admin/provider/user_provider.dart';
import 'injection_container.dart' as di;
import 'presentation/routes/app_router.dart';
import 'core/network/token_handler.dart';
import 'presentation/admin/provider/brand_provider.dart';
import 'presentation/admin/provider/menu_provider.dart';
import 'presentation/admin/provider/store_provider.dart';
import 'presentation/admin/provider/supplier_provider.dart';
import 'presentation/admin/provider/product_provider.dart';
import 'presentation/admin/provider/promotion_provider.dart';
import 'presentation/admin/provider/receipt_provider.dart';
import 'presentation/admin/provider/notification_provider.dart';
import 'presentation/admin/provider/order_provider.dart';
import 'presentation/staff/provider/staff_order_provider.dart';
import 'presentation/admin/provider/dashboard_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  await TokenHandler().init();
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => di.sl<LoginProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<BrandProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<StoreProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<SupplierProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<ProductProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<PromotionProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<ReceiptProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<NotificationProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<OrderProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<DashboardProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<StaffOrderProvider>()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => di.sl<SignUpProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<UserProvider>()),
      ],
      child: MaterialApp.router(
        title: 'ShoeStore Admin',
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
      ),
    );
  }
}
