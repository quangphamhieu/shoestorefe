import 'package:dio/dio.dart';
import '../../core/constants/api_endpoint.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/json_utils.dart';
import '../models/product_model.dart';

class ProductRemoteDataSource {
  final ApiClient client;
  ProductRemoteDataSource(this.client);

  Future<List<ProductModel>> getAll() async {
    final response = await client.get(ApiEndpoint.products);
    final data = response.data;
    if (data is List) {
      return data
          .map((e) => ProductModel.fromJson(JsonUtils.normalizeMap(e)))
          .toList();
    }
    return [];
  }
  Future<List<ProductModel>> getProductsByName(String name) async{
    final responese = await client.get('${ApiEndpoint.products}/getByName?name=${Uri.encodeComponent(name)}');
    print(responese.data);
    final data = responese.data;
    if(data is List){
      return data
      .map((e) => ProductModel.fromJson(JsonUtils.normalizeMap(e)),).toList();
    }
    return [];
  }
  Future<ProductModel?> getById(int id) async {
    final response = await client.get('${ApiEndpoint.products}/$id');
    final data = response.data;
    if (data is Map || data is Map<String, dynamic>) {
      return ProductModel.fromJson(JsonUtils.normalizeMap(data));
    }
    return null;
  }

  Future<ProductModel> create({
    required String name,
    int? brandId,
    int? supplierId,
    required double costPrice,
    required double originalPrice,
    String? color,
    String? size,
    String? description,
    String? imageUrl,
    String? imageFilePath,
    List<int>? imageBytes,
    String? imageFileName,
  }) async {
    final formData = FormData.fromMap({
      'Name': name,
      if (brandId != null) 'BrandId': brandId,
      if (supplierId != null) 'SupplierId': supplierId,
      'CostPrice': costPrice,
      'OriginalPrice': originalPrice,
      if (color != null) 'Color': color,
      if (size != null) 'Size': size,
      if (description != null) 'Description': description,
      if (imageUrl != null && imageFilePath == null && imageBytes == null)
        'ImageUrl': imageUrl,
      if (imageBytes != null && imageFileName != null)
        'ImageFile': MultipartFile.fromBytes(
          imageBytes,
          filename: imageFileName,
        )
      else if (imageFilePath != null)
        'ImageFile': await MultipartFile.fromFile(
          imageFilePath,
          filename: imageFilePath.split('/').last,
        ),
    });

    final response = await client.postMultipart(ApiEndpoint.products, formData);
    return ProductModel.fromJson(JsonUtils.normalizeMap(response.data));
  }

  Future<ProductModel?> update(
    int id, {
    required String name,
    int? brandId,
    int? supplierId,
    required double costPrice,
    required double originalPrice,
    String? color,
    String? size,
    String? description,
    String? imageUrl,
    String? imageFilePath,
    List<int>? imageBytes,
    String? imageFileName,
    required int statusId,
  }) async {
    final formData = FormData.fromMap({
      'Name': name,
      if (brandId != null) 'BrandId': brandId,
      if (supplierId != null) 'SupplierId': supplierId,
      'CostPrice': costPrice,
      'OriginalPrice': originalPrice,
      if (color != null) 'Color': color,
      if (size != null) 'Size': size,
      if (description != null) 'Description': description,
      if (imageUrl != null && imageFilePath == null && imageBytes == null)
        'ImageUrl': imageUrl,
      'StatusId': statusId,
      if (imageBytes != null && imageFileName != null)
        'ImageFile': MultipartFile.fromBytes(
          imageBytes,
          filename: imageFileName,
        )
      else if (imageFilePath != null)
        'ImageFile': await MultipartFile.fromFile(
          imageFilePath,
          filename: imageFilePath.split('/').last,
        ),
    });

    final response = await client.putMultipart(
      '${ApiEndpoint.products}/$id',
      formData,
    );
    final data = response.data;
    if (data is Map || data is Map<String, dynamic>) {
      return ProductModel.fromJson(JsonUtils.normalizeMap(data));
    }
    return null;
  }

  Future<bool> delete(int id) async {
    final response = await client.delete('${ApiEndpoint.products}/$id');
    return response.statusCode == 204 || response.statusCode == 200;
  }

  Future<List<ProductModel>> search({
    String? name,
    String? color,
    String? size,
    double? minPrice,
    double? maxPrice,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (color != null) body['color'] = color;
    if (size != null) body['size'] = size;
    if (minPrice != null) body['minPrice'] = minPrice;
    if (maxPrice != null) body['maxPrice'] = maxPrice;

    final response = await client.post('${ApiEndpoint.products}/search', body);
    final data = response.data;
    if (data is List) {
      return data
          .map((e) => ProductModel.fromJson(JsonUtils.normalizeMap(e)))
          .toList();
    }
    return [];
  }

  Future<List<String>> suggest(String keyword) async {
    final response = await client.get(
      '${ApiEndpoint.products}/suggest',
      queryParameters: {'keyword': keyword},
    );
    final data = response.data;
    if (data is List) {
      return data.map((e) => e.toString()).toList();
    }
    return [];
  }

  Future<StoreQuantityModel?> createStoreQuantity(
    int productId,
    int storeId,
    int quantity, {
    double? salePrice,
    String? storeName,
  }) async {
    final body = <String, dynamic>{
      'storeId': storeId,
      'storeName': storeName ?? '',
      'quantity': quantity,
      if (salePrice != null) 'salePrice': salePrice,
    };
    try {
      final url = '${ApiEndpoint.products}/$productId/store-quantity';
      final response = await client.post(url, body);
      final data = response.data;
      if (data is Map || data is Map<String, dynamic>) {
        return StoreQuantityModel.fromJson(JsonUtils.normalizeMap(data));
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('Cửa hàng đã tồn tại cho sản phẩm này');
      }
      final errorData = e.response?.data;
      String? errorMessage;
      if (errorData is Map) {
        errorMessage = errorData['message']?.toString();
        // Log thêm thông tin lỗi để debug
        if (errorData.containsKey('errors')) {
          final errors = errorData['errors'];
          if (errors != null) {
            errorMessage = '$errorMessage\nErrors: $errors';
          }
        }
      }
      throw Exception(
        errorMessage ?? e.message ?? 'Lỗi khi thêm số lượng tồn kho',
      );
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Lỗi khi thêm số lượng tồn kho: $e');
    }
  }

  Future<StoreQuantityModel?> updateStoreQuantity(
    int productId,
    int storeId,
    int quantity, {
    double? salePrice,
    String? storeName,
  }) async {
    final body = <String, dynamic>{
      'storeId': storeId,
      'storeName': storeName ?? '',
      'quantity': quantity,
      if (salePrice != null) 'salePrice': salePrice,
    };
    try {
      final url = '${ApiEndpoint.products}/$productId/store-quantity';
      final response = await client.put(url, body);
      final data = response.data;
      if (data is Map || data is Map<String, dynamic>) {
        return StoreQuantityModel.fromJson(JsonUtils.normalizeMap(data));
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Không tìm thấy số lượng tồn kho cho cửa hàng này');
      }
      final errorData = e.response?.data;
      String? errorMessage;
      if (errorData is Map) {
        errorMessage = errorData['message']?.toString();
        // Log thêm thông tin lỗi để debug
        if (errorData.containsKey('errors')) {
          final errors = errorData['errors'];
          if (errors != null) {
            errorMessage = '$errorMessage\nErrors: $errors';
          }
        }
      }
      throw Exception(
        errorMessage ?? e.message ?? 'Lỗi khi cập nhật số lượng tồn kho',
      );
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Lỗi khi cập nhật số lượng tồn kho: $e');
    }
  }
}
