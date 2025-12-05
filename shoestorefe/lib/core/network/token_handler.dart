import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TokenHandler {
  static final TokenHandler _instance = TokenHandler._internal();

  String? _token;

  factory TokenHandler() {
    return _instance;
  }

  TokenHandler._internal();

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
  }

  String getToken() {
    return _token ?? "";
  }

  Future<void> addToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  bool hasToken() {
    return _token != null && _token!.isNotEmpty;
  }

  String? getUserName() {
    final decodedToken = decodeToken();
    if (decodedToken.isEmpty) return null;

    final claims = [
      'name',
      'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name',
    ];

    for (final claim in claims) {
      if (decodedToken.containsKey(claim)) {
        final name = decodedToken[claim]?.toString();
        if (name != null && name.isNotEmpty) {
          return name;
        }
      }
    }

    return null;
  }

  String? getUserId() {
    final decodedToken = decodeToken();
    if (decodedToken.isEmpty) return null;

    final claims = [
      'sub',
      'userId',
      'nameid',
      'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier',
    ];

    for (final claim in claims) {
      if (decodedToken.containsKey(claim)) {
        final userId = decodedToken[claim]?.toString();
        if (userId != null && userId.isNotEmpty) {
          return userId;
        }
      }
    }

    return null;
  }

  String? getUserRole() {
    final decodedToken = decodeToken();
    if (decodedToken.isEmpty) return null;

    final roleData =
        decodedToken['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'];

    // Chuyển đổi roleData thành string
    String? role;
    if (roleData == null) {
      role = null;
    } else if (roleData is List) {
      // Nếu là array, lấy phần tử đầu tiên (nếu có)
      role = roleData.isNotEmpty ? roleData[0].toString() : null;
    } else {
      // Nếu là string hoặc kiểu dữ liệu khác, chuyển đổi thành string
      role = roleData.toString();
    }

    return role;
  }

  Map<String, dynamic> decodeToken() {
    final token = getToken();
    if (token.isEmpty) return {};

    try {
      final parts = token.split('.');
      if (parts.length != 3) return {};

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final map = json.decode(decoded);

      if (map is Map<String, dynamic>) {
        return map;
      }

      return {};
    } catch (e) {
      return {};
    }
  }
}
