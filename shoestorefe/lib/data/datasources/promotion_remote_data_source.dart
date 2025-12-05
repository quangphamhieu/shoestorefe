import 'package:dio/dio.dart';
import '../../core/constants/api_endpoint.dart';
import '../../core/network/api_client.dart';
import '../models/promotion_model.dart';

class PromotionRemoteDataSource {
  final ApiClient client;
  PromotionRemoteDataSource(this.client);

  Future<List<PromotionModel>> getAll() async {
    final response = await client.get(ApiEndpoint.promotions);
    final data = response.data;
    if (data is List) {
      return data
          .map((e) => PromotionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<PromotionModel?> getById(int id) async {
    final response = await client.get('${ApiEndpoint.promotions}/$id');
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return PromotionModel.fromJson(data);
    }
    return null;
  }

  Future<PromotionModel> create(PromotionModel promotion) async {
    try {
      final response = await client.post(
        ApiEndpoint.promotions,
        promotion.toCreateJson(),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return PromotionModel.fromJson(data);
      }
      throw Exception('Invalid response format');
    } on DioException catch (e) {
      final errorData = e.response?.data;
      String? errorMessage;
      
      if (errorData is Map) {
        // Try to get message from different possible fields
        errorMessage = errorData['message']?.toString() ??
            errorData['title']?.toString() ??
            errorData['error']?.toString();
        
        // If there are validation errors, include them
        if (errorData.containsKey('errors')) {
          final errors = errorData['errors'];
          if (errors != null) {
            errorMessage = '$errorMessage\nErrors: $errors';
          }
        }
      }
      
      // Default messages based on status code
      if (e.response?.statusCode == 409) {
        errorMessage = errorMessage ?? 
            'Khuyến mãi đã tồn tại hoặc cửa hàng đang có khuyến mãi hoạt động';
      } else if (e.response?.statusCode == 400) {
        errorMessage = errorMessage ?? 'Dữ liệu không hợp lệ';
      }
      
      throw Exception(
        errorMessage ?? e.message ?? 'Lỗi khi tạo khuyến mãi',
      );
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Lỗi khi tạo khuyến mãi: $e');
    }
  }

  Future<PromotionModel?> update(int id, PromotionModel promotion) async {
    try {
      final response = await client.put(
        '${ApiEndpoint.promotions}/$id',
        promotion.toUpdateJson(),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return PromotionModel.fromJson(data);
      }
      return null;
    } on DioException catch (e) {
      final errorData = e.response?.data;
      String? errorMessage;
      
      if (errorData is Map) {
        errorMessage = errorData['message']?.toString() ??
            errorData['title']?.toString() ??
            errorData['error']?.toString();
        
        if (errorData.containsKey('errors')) {
          final errors = errorData['errors'];
          if (errors != null) {
            errorMessage = '$errorMessage\nErrors: $errors';
          }
        }
      }
      
      if (e.response?.statusCode == 409) {
        errorMessage = errorMessage ?? 
            'Khuyến mãi đã tồn tại hoặc cửa hàng đang có khuyến mãi hoạt động';
      } else if (e.response?.statusCode == 400) {
        errorMessage = errorMessage ?? 'Dữ liệu không hợp lệ';
      } else if (e.response?.statusCode == 404) {
        errorMessage = errorMessage ?? 'Không tìm thấy khuyến mãi';
      }
      
      throw Exception(
        errorMessage ?? e.message ?? 'Lỗi khi cập nhật khuyến mãi',
      );
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Lỗi khi cập nhật khuyến mãi: $e');
    }
  }

  Future<bool> delete(int id) async {
    final response = await client.delete('${ApiEndpoint.promotions}/$id');
    return response.statusCode == 204 || response.statusCode == 200;
  }
}
