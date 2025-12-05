import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'token_handler.dart';

class ApiClient {
  final Dio dio;
  ApiClient({Dio? dio})
    : dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              headers: {"Content-Type": "application/json"},
            ),
          ) {
    // Bypass SSL certificate verification for development (self-signed certificate)
    this.dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      },
    );

    this.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final tokenHandler = TokenHandler();
          final token = tokenHandler.getToken();
          final userId = tokenHandler.getUserId();

          print('[ApiClient] 🔐 Request to: ${options.path}');
          print('[ApiClient] 🔐 Has token: ${token.isNotEmpty}');
          if (userId != null) {
            print('[ApiClient] 👤 UserId from token: $userId');
          } else {
            print('[ApiClient] ⚠️ UserId not found in token!');
          }

          if (token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          } else {
            options.headers.remove('Authorization');
            print('[ApiClient] ⚠️ No token available!');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          print(
            '[ApiClient] ✅ Response from ${response.requestOptions.path}: ${response.statusCode}',
          );
          handler.next(response);
        },
        onError: (error, handler) {
          print(
            '[ApiClient] ❌ Error on ${error.requestOptions.path}: ${error.message}',
          );
          if (error.response != null) {
            print('[ApiClient] ❌ Error response: ${error.response?.data}');
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<Response> get(String url, {Map<String, dynamic>? queryParameters}) =>
      dio.get(url, queryParameters: queryParameters);

  Future<Response> post(String url, dynamic data) => dio.post(url, data: data);

  Future<Response> postMultipart(String url, FormData formData) => dio.post(
    url,
    data: formData,
    options: Options(contentType: 'multipart/form-data'),
  );

  Future<Response> put(String url, dynamic data) => dio.put(url, data: data);

  Future<Response> putMultipart(String url, FormData formData) => dio.put(
    url,
    data: formData,
    options: Options(contentType: 'multipart/form-data'),
  );

  Future<Response> delete(String url) => dio.delete(url);
}
