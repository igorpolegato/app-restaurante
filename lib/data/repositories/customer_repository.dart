import '../models/customer_model.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';

class CustomerRepository {
  final ApiClient _client;
  CustomerRepository(this._client);

  Future<CustomerModel> createCustomer(String name) async {
    final response = await _client.post(
      ApiEndpoints.createCustomer,
      data: {'name': name},
    );
    final body = response.data as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>;
    return CustomerModel.fromJson(data['customer'] as Map<String, dynamic>);
  }
}
