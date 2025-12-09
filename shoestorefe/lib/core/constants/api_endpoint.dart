class ApiEndpoint {
  static const baseUrl = "https://172.16.52.127:7097/api"; // Chỉnh dựa theo ip lan của mạng
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
