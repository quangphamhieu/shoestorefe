import 'package:flutter/foundation.dart' show kIsWeb;

class ApiEndpoint {
  static const baseUrl = "https://helloshoestore.runasp.net/api"; //sử dụng https
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
  static const chat = "https://shoestorefe.onrender.com/chat";
}
