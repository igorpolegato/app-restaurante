import 'package:flutter/material.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';

class OrderProvider extends ChangeNotifier {
  final OrderRepository _repo;
  OrderProvider(this._repo);

  List<OrderModel> _customerOrders = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;

  List<OrderModel> get customerOrders => _customerOrders;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  Future<bool> createOrder({
    required int customerId,
    required List<Map<String, dynamic>> items,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      await _repo.createOrder(
        customerId: customerId,
        items: items,
      );
      await loadCustomerOrders(customerId);
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erro ao fazer pedido. Tente novamente.';
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadCustomerOrders(int customerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _customerOrders = await _repo.getOrdersByCustomer(customerId);
    } catch (_) {
      _error = 'Erro ao carregar pedidos.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
