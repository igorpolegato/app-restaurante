import 'package:flutter/material.dart';
import '../../core/utils/session_manager.dart';

class SessionProvider extends ChangeNotifier {
  int? _customerId;
  int? _mesa;
  String _customerName = '';
  bool _isLoading = false;

  int? get customerId => _customerId;
  int? get mesa => _mesa;
  String get customerName => _customerName;
  bool get hasSession => _customerId != null && _mesa != null;
  bool get isLoading => _isLoading;

  Future<void> loadSession() async {
    _isLoading = true;
    notifyListeners();

    final session = await SessionManager.getSession();
    if (session != null) {
      _customerId = session['customerId'] as int;
      _mesa = session['mesa'] as int;
      _customerName = session['name'] as String;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> startSession({
    required int customerId,
    required int mesa,
    required String name,
  }) async {
    _customerId = customerId;
    _mesa = mesa;
    _customerName = name;
    await SessionManager.saveSession(
      customerId: customerId,
      mesa: mesa,
      name: name,
    );
    notifyListeners();
  }

  Future<void> clearSession() async {
    _customerId = null;
    _mesa = null;
    _customerName = '';
    await SessionManager.clearSession();
    notifyListeners();
  }
}
