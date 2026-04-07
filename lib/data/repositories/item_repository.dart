import '../models/item_model.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';

class ItemRepository {
  final ApiClient _client;
  ItemRepository(this._client);

  Future<List<ItemModel>> getItems() async {
    final response = await _client.get(ApiEndpoints.items);
    final body = response.data as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>;
    final list = data['items'] as List;
    return list
        .map((e) => ItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
