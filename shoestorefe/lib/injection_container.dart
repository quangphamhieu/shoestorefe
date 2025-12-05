import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shoestorefe/data/datasources/cart_remote_data_source.dart';
import 'package:shoestorefe/data/datasources/user_remote_data_source.dart';
import 'package:shoestorefe/data/repositories/cart_repository_impl.dart';
import 'package:shoestorefe/data/repositories/user_repository_impl.dart';
import 'package:shoestorefe/domain/repositories/cart_repository.dart';
import 'package:shoestorefe/domain/repositories/user_repository.dart';
import 'package:shoestorefe/domain/usecases/cart/add_item_to_cart.dart';
import 'package:shoestorefe/domain/usecases/user/create_user.dart';
import 'package:shoestorefe/domain/usecases/user/delete_user.dart';
import 'package:shoestorefe/domain/usecases/user/get_all_user.dart';
import 'package:shoestorefe/domain/usecases/user/get_user_by_id.dart';
import 'package:shoestorefe/domain/usecases/user/login.dart';
import 'package:shoestorefe/domain/usecases/user/reset_password.dart';
import 'package:shoestorefe/domain/usecases/user/sign_up.dart';
import 'package:shoestorefe/domain/usecases/user/update_user.dart';
import 'package:shoestorefe/presentation/admin/provider/login_provider.dart';
import 'package:shoestorefe/presentation/admin/provider/sign_up_provider.dart';
import 'package:shoestorefe/presentation/admin/provider/user_provider.dart';
import 'package:shoestorefe/presentation/customer/provider/product_detail_provider.dart';
import 'package:shoestorefe/presentation/customer/provider/cart_provider.dart';
import 'package:shoestorefe/presentation/customer/provider/checkout_provider.dart';
import 'package:shoestorefe/presentation/customer/provider/order_history_provider.dart';
import 'package:shoestorefe/presentation/customer/provider/profile_provider.dart';
import 'package:shoestorefe/presentation/customer/provider/notification_provider.dart'
    as customer_notif;
import 'core/network/api_client.dart';
import 'data/datasources/brand_remote_data_source.dart';
import 'data/datasources/store_remote_data_source.dart';
import 'data/datasources/supplier_remote_data_source.dart';
import 'data/datasources/product_remote_data_source.dart';
import 'data/datasources/promotion_remote_data_source.dart';
import 'data/datasources/receipt_remote_data_source.dart';
import 'data/datasources/notification_remote_data_source.dart';
import 'data/datasources/order_remote_data_source.dart';
import 'data/datasources/dashboard_remote_data_source.dart';
import 'data/datasources/comment_remote_data_source.dart';
import 'data/repositories/brand_repository_impl.dart';
import 'data/repositories/store_repository_impl.dart';
import 'data/repositories/supplier_repository_impl.dart';
import 'data/repositories/product_repository_impl.dart';
import 'data/repositories/promotion_repository_impl.dart';
import 'data/repositories/receipt_repository_impl.dart';
import 'data/repositories/notification_repository_impl.dart';
import 'data/repositories/order_repository_impl.dart';
import 'data/repositories/dashboard_repository_impl.dart';
import 'data/repositories/comment_repository_impl.dart';
import 'domain/repositories/brand_repository.dart';
import 'domain/repositories/store_repository.dart';
import 'domain/repositories/supplier_repository.dart';
import 'domain/repositories/product_repository.dart';
import 'domain/repositories/promotion_repository.dart';
import 'domain/repositories/receipt_repository.dart';
import 'domain/repositories/notification_repository.dart';
import 'domain/repositories/order_repository.dart';
import 'domain/repositories/dashboard_repository.dart';
import 'domain/repositories/comment_repository.dart';
import 'domain/usecases/brand/get_all_brands_usecase.dart';
import 'domain/usecases/brand/get_brand_by_id_usecase.dart';
import 'domain/usecases/brand/create_brand_usecase.dart';
import 'domain/usecases/brand/update_brand_usecase.dart';
import 'domain/usecases/brand/delete_brand_usecase.dart';
import 'domain/usecases/store/get_all_stores_usecase.dart';
import 'domain/usecases/store/get_store_by_id_usecase.dart';
import 'domain/usecases/store/create_store_usecase.dart';
import 'domain/usecases/store/update_store_usecase.dart';
import 'domain/usecases/store/delete_store_usecase.dart';
import 'domain/usecases/supplier/get_all_suppliers_usecase.dart';
import 'domain/usecases/supplier/get_supplier_by_id_usecase.dart';
import 'domain/usecases/supplier/create_supplier_usecase.dart';
import 'domain/usecases/supplier/update_supplier_usecase.dart';
import 'domain/usecases/supplier/delete_supplier_usecase.dart';
import 'domain/usecases/product/get_all_products_usecase.dart';
import 'domain/usecases/product/get_product_by_id_usecase.dart';
import 'domain/usecases/product/create_product_usecase.dart';
import 'domain/usecases/product/update_product_usecase.dart';
import 'domain/usecases/product/delete_product_usecase.dart';
import 'domain/usecases/product/search_products_usecase.dart';
import 'domain/usecases/product/get_list_product_by_name.dart';
import 'domain/usecases/product/create_store_quantity_usecase.dart';
import 'domain/usecases/product/update_store_quantity_usecase.dart';
import 'domain/usecases/promotion/get_all_promotions_usecase.dart';
import 'domain/usecases/promotion/get_promotion_by_id_usecase.dart';
import 'domain/usecases/promotion/create_promotion_usecase.dart';
import 'domain/usecases/promotion/update_promotion_usecase.dart';
import 'domain/usecases/promotion/delete_promotion_usecase.dart';
import 'domain/usecases/receipt/get_all_receipts_usecase.dart';
import 'domain/usecases/receipt/get_receipt_by_id_usecase.dart';
import 'domain/usecases/receipt/create_receipt_usecase.dart';
import 'domain/usecases/receipt/update_receipt_info_usecase.dart';
import 'domain/usecases/receipt/update_receipt_received_usecase.dart';
import 'domain/usecases/receipt/delete_receipt_usecase.dart';
import 'domain/usecases/notification/get_all_notifications_usecase.dart';
import 'domain/usecases/notification/get_notification_by_id_usecase.dart';
import 'domain/usecases/notification/delete_notification_usecase.dart';
import 'domain/usecases/order/get_all_orders_usecase.dart';
import 'domain/usecases/order/create_order_usecase.dart';
import 'domain/usecases/order/update_order_status_usecase.dart';
import 'domain/usecases/order/update_order_detail_usecase.dart';
import 'domain/usecases/order/delete_order_detail_usecase.dart';
import 'domain/usecases/dashboard/get_dashboard_overview_usecase.dart';
import 'domain/usecases/comment/get_comments_by_product_id_usecase.dart';
import 'domain/usecases/comment/create_comment_usecase.dart';
import 'domain/usecases/comment/update_comment_usecase.dart';
import 'domain/usecases/comment/delete_comment_usecase.dart';
import 'presentation/admin/provider/brand_provider.dart';
import 'presentation/admin/provider/store_provider.dart';
import 'presentation/admin/provider/supplier_provider.dart';
import 'presentation/admin/provider/product_provider.dart';
import 'presentation/admin/provider/promotion_provider.dart';
import 'presentation/admin/provider/receipt_provider.dart';
import 'presentation/admin/provider/notification_provider.dart';
import 'presentation/admin/provider/order_provider.dart';
import 'presentation/admin/provider/dashboard_provider.dart';
import 'presentation/staff/provider/staff_order_provider.dart';
import 'presentation/customer/provider/customer_provider.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  sl.registerLazySingleton(() => ApiClient(dio: Dio()));

  // Data source
  sl.registerLazySingleton(() => UserRemoteDataSource(sl()));
  sl.registerLazySingleton(() => BrandRemoteDataSource(sl()));
  sl.registerLazySingleton(() => StoreRemoteDataSource(sl()));
  sl.registerLazySingleton(() => SupplierRemoteDataSource(sl()));
  sl.registerLazySingleton(() => ProductRemoteDataSource(sl()));
  sl.registerLazySingleton(() => PromotionRemoteDataSource(sl()));
  sl.registerLazySingleton(() => ReceiptRemoteDataSource(sl()));
  sl.registerLazySingleton(() => NotificationRemoteDataSource(sl()));
  sl.registerLazySingleton(() => OrderRemoteDataSource(sl()));
  sl.registerLazySingleton(() => DashboardRemoteDataSource(sl()));
  sl.registerLazySingleton(() => CommentRemoteDataSource(sl()));
  sl.registerLazySingleton(() => CartRemoteDataSource(sl()));

  // Repository
  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(sl()));
  sl.registerLazySingleton<BrandRepository>(() => BrandRepositoryImpl(sl()));
  sl.registerLazySingleton<StoreRepository>(() => StoreRepositoryImpl(sl()));
  sl.registerLazySingleton<SupplierRepository>(
    () => SupplierRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<PromotionRepository>(
    () => PromotionRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ReceiptRepository>(
    () => ReceiptRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<OrderRepository>(() => OrderRepositoryImpl(sl()));
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<CommentRepository>(
    () => CommentRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<CartRepository>(() => CartRepositoryImpl(sl()));

  // Usecases
  sl.registerLazySingleton(() => GetAllUsers(sl()));
  sl.registerLazySingleton(() => GetUserById(sl()));
  sl.registerLazySingleton(() => CreateUser(sl()));
  sl.registerLazySingleton(() => UpdateUser(sl()));
  sl.registerLazySingleton(() => DeleteUser(sl()));
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => SignupUser(sl()));
  sl.registerLazySingleton(() => ResetPassword(sl()));
  sl.registerLazySingleton(() => GetAllBrandsUseCase(sl()));
  sl.registerLazySingleton(() => GetBrandByIdUseCase(sl()));
  sl.registerLazySingleton(() => CreateBrandUseCase(sl()));
  sl.registerLazySingleton(() => UpdateBrandUseCase(sl()));
  sl.registerLazySingleton(() => DeleteBrandUseCase(sl()));
  sl.registerLazySingleton(() => GetAllStoresUseCase(sl()));
  sl.registerLazySingleton(() => GetStoreByIdUseCase(sl()));
  sl.registerLazySingleton(() => CreateStoreUseCase(sl()));
  sl.registerLazySingleton(() => UpdateStoreUseCase(sl()));
  sl.registerLazySingleton(() => DeleteStoreUseCase(sl()));
  sl.registerLazySingleton(() => GetAllSuppliersUseCase(sl()));
  sl.registerLazySingleton(() => GetSupplierByIdUseCase(sl()));
  sl.registerLazySingleton(() => CreateSupplierUseCase(sl()));
  sl.registerLazySingleton(() => UpdateSupplierUseCase(sl()));
  sl.registerLazySingleton(() => DeleteSupplierUseCase(sl()));
  sl.registerLazySingleton(() => GetAllProductsUseCase(sl()));
  sl.registerLazySingleton(() => GetProductByIdUseCase(sl()));
  sl.registerLazySingleton(() => CreateProductUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProductUseCase(sl()));
  sl.registerLazySingleton(() => DeleteProductUseCase(sl()));
  sl.registerLazySingleton(() => SearchProductsUseCase(sl()));
  sl.registerLazySingleton(() => GetListProductByNameUseCase(sl()));
  sl.registerLazySingleton(() => CreateStoreQuantityUseCase(sl()));
  sl.registerLazySingleton(() => UpdateStoreQuantityUseCase(sl()));
  sl.registerLazySingleton(() => GetAllPromotionsUseCase(sl()));
  sl.registerLazySingleton(() => GetPromotionByIdUseCase(sl()));
  sl.registerLazySingleton(() => CreatePromotionUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePromotionUseCase(sl()));
  sl.registerLazySingleton(() => DeletePromotionUseCase(sl()));
  sl.registerLazySingleton(() => GetAllReceiptsUseCase(sl()));
  sl.registerLazySingleton(() => GetReceiptByIdUseCase(sl()));
  sl.registerLazySingleton(() => CreateReceiptUseCase(sl()));
  sl.registerLazySingleton(() => UpdateReceiptInfoUseCase(sl()));
  sl.registerLazySingleton(() => UpdateReceiptReceivedUseCase(sl()));
  sl.registerLazySingleton(() => DeleteReceiptUseCase(sl()));
  sl.registerLazySingleton(() => GetAllNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => GetNotificationByIdUseCase(sl()));
  sl.registerLazySingleton(() => DeleteNotificationUseCase(sl()));
  sl.registerLazySingleton(() => GetAllOrdersUseCase(sl()));
  sl.registerLazySingleton(() => CreateOrderUseCase(sl()));
  sl.registerLazySingleton(() => UpdateOrderStatusUseCase(sl()));
  sl.registerLazySingleton(() => UpdateOrderDetailUseCase(sl()));
  sl.registerLazySingleton(() => DeleteOrderDetailUseCase(sl()));
  sl.registerLazySingleton(() => GetDashboardOverviewUseCase(sl()));
  sl.registerLazySingleton(() => GetCommentsByProductIdUseCase(sl()));
  sl.registerLazySingleton(() => CreateCommentUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCommentUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCommentUseCase(sl()));
  sl.registerLazySingleton(() => AddItemToCart(sl()));

  // Provider: register factory so each provider instance created by provider package is new if needed
  sl.registerFactory(() => SignUpProvider(sl()));
  sl.registerFactory(() => LoginProvider(sl()));

  // Customer providers
  sl.registerFactory(
    () => CartProvider(cartRepository: sl(), productRepository: sl()),
  );
  sl.registerFactory(() => CheckoutProvider(orderRepository: sl()));
  sl.registerFactory(() => OrderHistoryProvider(orderRepository: sl()));
  sl.registerFactory(() => ProfileProvider(userRepository: sl()));
  sl.registerFactory(
    () => customer_notif.NotificationProvider(notificationRepository: sl()),
  );
  sl.registerFactory(
    () => UserProvider(
      getAllUsers: sl(),
      getUserById: sl(),
      createUserUc: sl(),
      updateUserUc: sl(),
      deleteUserUc: sl(),
    ),
  );
  sl.registerFactory(
    () => BrandProvider(
      getAllUseCase: sl(),
      getByIdUseCase: sl(),
      createUseCase: sl(),
      updateUseCase: sl(),
      deleteUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => StoreProvider(
      getAllUseCase: sl(),
      getByIdUseCase: sl(),
      createUseCase: sl(),
      updateUseCase: sl(),
      deleteUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => SupplierProvider(
      getAllUseCase: sl(),
      getByIdUseCase: sl(),
      createUseCase: sl(),
      updateUseCase: sl(),
      deleteUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => ProductProvider(
      getAllUseCase: sl(),
      getByIdUseCase: sl(),
      createUseCase: sl(),
      updateUseCase: sl(),
      deleteUseCase: sl(),
      searchUseCase: sl(),
      createStoreQuantityUseCase: sl(),
      updateStoreQuantityUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => PromotionProvider(
      getAllUseCase: sl(),
      getByIdUseCase: sl(),
      createUseCase: sl(),
      updateUseCase: sl(),
      deleteUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => ReceiptProvider(
      getAllUseCase: sl(),
      getByIdUseCase: sl(),
      createUseCase: sl(),
      updateInfoUseCase: sl(),
      updateReceivedUseCase: sl(),
      deleteUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => NotificationProvider(
      getAllUseCase: sl(),
      getByIdUseCase: sl(),
      deleteUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => OrderProvider(
      getAllUseCase: sl(),
      updateStatusUseCase: sl(),
      updateDetailUseCase: sl(),
      deleteDetailUseCase: sl(),
    ),
  );
  sl.registerFactory(() => DashboardProvider(sl()));
  sl.registerFactory(
    () => StaffOrderProvider(
      getAllUseCase: sl(),
      createUseCase: sl(),
      updateStatusUseCase: sl(),
      updateDetailUseCase: sl(),
      deleteDetailUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => CustomerProvider(
      getAllProductsUseCase: sl(),
      searchProductsUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => ProductDetailProvider(
      getListProductByNameUseCase: sl(),
      getCommentsByProductIdUseCase: sl(),
      createCommentUseCase: sl(),
      updateCommentUseCase: sl(),
      deleteCommentUseCase: sl(),
      addItemToCartUseCase: sl(),
    ),
  );
}
