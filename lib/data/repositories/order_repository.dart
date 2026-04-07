import '../models/order_model.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';

class OrderRepository {
  final ApiClient _client;
  OrderRepository(this._client);

  Future<OrderModel> createOrder({
    required int customerId,
    required List<Map<String, dynamic>> items,
  }) async {
    final response = await _client.post(
      ApiEndpoints.createOrder,
      data: {
        'customer_id': customerId,
        'items': items,
      },
    );
    final body = response.data as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>;
    return OrderModel.fromJson(data['order'] as Map<String, dynamic>);
  }

  Future<List<OrderModel>> getOrdersByCustomer(int customerId) async {
    final response =
        await _client.get(ApiEndpoints.ordersByCustomer(customerId));
    final body = response.data as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>;
    final raw = data['orders'];
    if (raw is! List) return [];
    return raw
        .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
