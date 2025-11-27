class ApiEndpoint {
  static const baseUrl = "https://localhost:7097/api"; // thay bằng port backend
  static const brands = "$baseUrl/brands";
  static const stores = "$baseUrl/store";
  static const suppliers = "$baseUrl/supplier";
  static const products =
      "$baseUrl/products"; // ASP.NET Core routes are case-insensitive
  static const orders = "$baseUrl/order";
  static const promotions = "$baseUrl/promotion";
  static const receipts = "$baseUrl/receipts";
  static const notifications = "$baseUrl/notifications";
  static const user = "$baseUrl/user";
  static const dashboard = "$baseUrl/dashboard";
}
