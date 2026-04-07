import '../models/category_model.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';

class CategoryRepository {
  final ApiClient _client;
  CategoryRepository(this._client);

  Future<List<CategoryModel>> getCategories() async {
    final response = await _client.get(ApiEndpoints.categories);
    final body = response.data as Map<String, dynamic>;
    final raw = body['data'];
    final list = raw is List ? raw : (raw as Map<String, dynamic>)['categories'] as List;
    return list
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
