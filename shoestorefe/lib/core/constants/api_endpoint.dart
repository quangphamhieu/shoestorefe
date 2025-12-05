class ApiEndpoint {
  // Để chạy trên điện thoại: Thay "localhost" bằng IP máy tính (ví dụ: 192.168.1.5)
  // Để chạy trên web/emulator: Dùng "localhost"
  static const baseUrl =
      "https://192.168.1.56:7097/api"; // ⚠️ Dùng HTTPS port 7097
  static const brands = "$baseUrl/brands";
  static const stores = "$baseUrl/store";
  static const suppliers = "$baseUrl/supplier";
  static const products =
      "$baseUrl/products"; // ASP.NET Core routes are case-insensitive
  static const comments = "$baseUrl/comments";
  static const orders = "$baseUrl/order";
  static const promotions = "$baseUrl/promotion";
  static const receipts = "$baseUrl/receipts";
  static const notifications = "$baseUrl/notifications";
  static const user = "$baseUrl/user";
  static const dashboard = "$baseUrl/dashboard";
  static const cart = "$baseUrl/cart";
}
